"""持久化逐层调查；保存动作和身份，恢复时重新读取工件并重放，绝不信任缓存值。"""

from __future__ import annotations

import fcntl
import hashlib
import json
import os
import time
from dataclasses import dataclass, field, replace
from pathlib import Path
from typing import TYPE_CHECKING, Any, Literal

from .artifacts import RunArtifacts, _json
from .checks import import_checks, normalize_check
from .comparison import evidence_sha256
from .model import (
    Budget,
    Frontier,
    JsonModel,
    QueryRequest,
    RecordRef,
    StopCode,
    StopReason,
    TraceEdge,
    TraceError,
    _nonempty,
)
from .query import _BUDGET, _REJECT, _Query, _reason
from .report import attach_sources
from .semantics import bind_semantics
from .source import bind_sources
from .topology import TraceTopology

if TYPE_CHECKING:
    from . import TraceRun
    from .model import CheckRecord, ObservationMap, TraceReport
    from .query import _Dependency

Branch = Literal['all', 'data', 'control', 'history']
_BRANCH = {
    'data': {'data', 'alias', 'capture', 'write', 'static_candidate'},
    'control': {'control'},
    'history': {'prior_state'},
}


def _hash(value: Any) -> str:
    """按固定 JSON 编码绑定日志内容。"""
    return hashlib.sha256(json.dumps(value, sort_keys=True, ensure_ascii=False, allow_nan=False).encode()).hexdigest()


@dataclass(frozen=True)
class SessionBudget(JsonModel):
    """跨查询、失败动作与恢复重放累计的主动计算预算，不包含用户思考时间。"""

    max_seconds: float = 3600.0
    max_read_bytes: int = 8 * 1024 * 1024 * 1024
    max_actions: int = 1000
    max_queries: int = 100

    def _validate(self) -> None:
        """累计预算必须为有限正数。"""
        for name in ('max_seconds', 'max_read_bytes', 'max_actions', 'max_queries'):
            value = getattr(self, name)
            if value <= 0 or (name == 'max_seconds' and not float(value) < float('inf')):
                raise TraceError(StopCode.INVALID_BUDGET, '会话预算必须为有限正数', field=name)


@dataclass
class _Investigation:
    engine: _Query
    pending: set[str] = field(default_factory=set)
    dependencies: dict[str, tuple[_Dependency, ...]] = field(default_factory=dict)
    applied: dict[str, set[int]] = field(default_factory=dict)

    def report(self) -> TraceReport:
        """仅在返回视图中添加待展开边界，不污染完整查询的语义证据。"""
        report = self.engine.report()
        pending = tuple(
            Frontier(StopReason(StopCode.PENDING_EXPANSION, '等待用户请求展开'), node, self.engine.nodes[node].ref)
            for node in sorted(self.pending)
        )
        return replace(
            report,
            frontier=report.frontier + pending,
            status=(
                replace(report.status, query='partial')
                if pending and report.status.query == 'complete'
                else report.status
            ),
        )

    def expand(self, node: str, branch: Branch) -> None:
        """执行单节点的局部规则，仅提交所选类的直接依赖，其他分支保留 pending。"""
        if node not in self.engine.nodes or branch not in ('all', *_BRANCH):
            raise TraceError(StopCode.INVALID_INPUT, '展开需要已发现节点与有效分支')
        if node not in self.pending:
            return
        try:
            if node not in self.dependencies:
                self.dependencies[node] = self.engine._expand(node)
            dependencies = self.dependencies[node]
            applied = self.applied.setdefault(node, set())
            for index, dependency in enumerate(dependencies):
                if index in applied or (branch != 'all' and dependency.kind not in _BRANCH[branch]):
                    continue
                child = self.engine._add(dependency.ref, candidate=not dependency.expand)
                edge = TraceEdge(child, node, dependency.kind, dependency.label)
                if edge not in self.engine.edges:
                    self.engine.edges.append(edge)
                applied.add(index)
                if dependency.expand:
                    # source -> target，沿 target 方向可达 child 时形成有向环。
                    todo, seen = [node], set()
                    while todo:
                        current = todo.pop()
                        if current in seen:
                            continue
                        seen.add(current)
                        todo.extend(item.target for item in self.engine.edges if item.source == current)
                    if child in seen:
                        frontier = Frontier(StopReason(StopCode.CYCLE, '候选依赖在同一读取视图形成环'), child)
                        if frontier not in self.engine.frontier:
                            self.engine.frontier.append(frontier)
                    elif child not in self.engine.expanded:
                        self.pending.add(child)
            if len(applied) == len(dependencies):
                self.pending.discard(node)
                self.engine.expanded.add(node)
        except TraceError as error:
            if error.code in _BUDGET or error.code in _REJECT:
                raise
            self.engine.frontier.append(Frontier(_reason(error), node, self.engine.nodes[node].ref))
            self.pending.discard(node)
            self.engine.expanded.add(node)


class InvestigationSession:
    """单写者调查会话；每个动作先持久化预算预留，再提交结果及哈希链。"""

    def __init__(self, path: Path, document: dict[str, Any], relocations: dict[str, Path]) -> None:
        """内部初始化；使用 create/resume 建立经过验证的会话。"""
        self.path, self.document, self.relocations = path, document, relocations
        self.budget = SessionBudget.from_dict(document['budget'])
        self.queries: dict[str, _Investigation] = {}
        self.selected: str | None = None
        self.selected_node: str | None = None
        self._runs: list[RunArtifacts] = []
        self._active_budget = Budget()
        self._deadline = float('inf')
        self._before: dict[int, tuple[int, int]] = {}
        self._verification_bytes = 0
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._lock = self.path.with_name(self.path.name + '.lock').open('a+b')
        try:
            fcntl.flock(self._lock.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
            if self.path.exists() and _json(self.path.read_text()) != document:
                raise TraceError(StopCode.IDENTITY_MISMATCH, '会话在打开期间已由其他写者更新')
        except (OSError, TraceError) as error:
            self._lock.close()
            raise TraceError(StopCode.INVALID_INPUT, '会话已被其他写者打开或修改') from error

    @classmethod
    def create(
        cls,
        trace_run: TraceRun,
        request: QueryRequest,
        path: Path | str,
        *,
        actor: str,
        budget: SessionBudget | None = None,
        check_carrier: Path | str | None = None,
    ) -> InvestigationSession:
        """固定运行身份并只核验初始查询根；已存在的日志绝不覆盖。"""
        destination = Path(path).absolute()
        if destination.exists():
            raise TraceError(StopCode.INVALID_INPUT, '会话文件已存在', path=str(destination))
        document: dict[str, Any] = {
            'schema_version': 1,
            'kind': 'trace_investigation_session',
            'run': trace_run.run_reference(destination).to_dict(),
            'budget': (budget or SessionBudget()).to_dict(),
            'journal': [],
        }
        document['header_sha256'] = _hash({key: value for key, value in document.items() if key != 'journal'})
        session = cls(destination, document, dict(trace_run.relocations))
        session._save()
        try:
            session.query(request, actor=actor, check_carrier=check_carrier)
        except BaseException:
            session.close()
            raise
        return session

    @classmethod
    def resume(
        cls,
        path: Path | str,
        *,
        actor: str,
        budget: Budget | None = None,
        relocations: dict[str, Path] | None = None,
    ) -> InvestigationSession:
        """校验日志链、原始工件并重放成功动作；重放同样消耗会话累计预算。"""
        path = Path(path).absolute()
        try:
            document = _json(path.read_text())
        except OSError as error:
            raise TraceError(StopCode.MISSING_ARTIFACT, '会话文件不可读', path=str(path)) from error
        cls._validate(document)
        session = cls(path, document, dict(relocations or {}))
        intents = {item['sequence']: item for item in document['journal'] if item['kind'] == 'intent'}
        committed = [
            intents[item['intent']]
            for item in document['journal']
            if item['kind'] == 'receipt' and item['status'] == 'ok' and intents[item['intent']]['operation'] != 'resume'
        ]
        expected = {
            item['intent']: item['result']
            for item in document['journal']
            if item['kind'] == 'receipt' and item['status'] == 'ok'
        }

        def replay() -> dict[str, Any]:
            """新 reader 重建证据；不导入日志内保存的节点值。"""
            for intent in committed:
                session._tick()
                result = session._apply(intent['operation'], intent['request'])
                if result != expected[intent['sequence']]:
                    raise TraceError(
                        StopCode.INCONSISTENT_EVIDENCE, '重放结果与已提交动作不同', action=intent['sequence']
                    )
            return {
                'queries': list(session.queries),
                'selected': session.selected,
                'selected_node': session.selected_node,
            }

        try:
            session._action('resume', {}, actor, budget or Budget(), replay)
        except BaseException:
            session.close()
            raise
        return session

    @staticmethod
    def _validate(document: Any) -> None:
        """拒绝版本、日志链、动作配对或持久化预算遭更改的会话。"""
        if not isinstance(document, dict) or document.get('kind') != 'trace_investigation_session':
            raise TraceError(StopCode.INVALID_INPUT, '不是调查会话')
        if document.get('schema_version') != 1:
            raise TraceError(StopCode.UNSUPPORTED_SCHEMA, '不支持此会话版本')
        header = {key: value for key, value in document.items() if key not in {'journal', 'header_sha256'}}
        if document.get('header_sha256') != _hash(header) or not isinstance(document.get('journal'), list):
            raise TraceError(StopCode.HASH_MISMATCH, '会话头哈希不一致')
        previous = document['header_sha256']
        intents: set[int] = set()
        receipts: set[int] = set()
        for sequence, entry in enumerate(document['journal']):
            if not isinstance(entry, dict) or entry.get('sequence') != sequence or entry.get('previous') != previous:
                raise TraceError(StopCode.HASH_MISMATCH, '会话日志链不连续')
            if entry.get('sha256') != _hash({key: value for key, value in entry.items() if key != 'sha256'}):
                raise TraceError(StopCode.HASH_MISMATCH, '会话动作哈希不一致', action=sequence)
            previous = entry['sha256']
            if entry['kind'] == 'intent':
                Budget.from_dict(entry['budget'])
                _nonempty(entry['actor'], 'actor')
                intents.add(sequence)
            elif entry['kind'] == 'receipt' and entry.get('intent') in intents and entry['intent'] not in receipts:
                receipts.add(entry['intent'])
            else:
                raise TraceError(StopCode.INVALID_INPUT, '会话动作和回执不匹配')

    def _save(self) -> None:
        """同目录临时文件加原子替换；中断保留已写意图，不能悄悄免除预算。"""
        self.path.parent.mkdir(parents=True, exist_ok=True)
        temporary = self.path.with_name(self.path.name + '.tmp')
        with temporary.open('w') as stream:
            json.dump(self.document, stream, ensure_ascii=False, indent=2, allow_nan=False)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, self.path)

    def _append(self, item: dict[str, Any]) -> int:
        """追加绑定上一条记录的动作，并立即持久化。"""
        journal = self.document['journal']
        item = dict(
            item, sequence=len(journal), previous=journal[-1]['sha256'] if journal else self.document['header_sha256']
        )
        item['sha256'] = _hash(item)
        journal.append(item)
        self._save()
        return item['sequence']

    @property
    def cost(self) -> dict[str, int | float]:
        """返回实际累计成本；没有回执的中断动作按其完整预算保守计费。"""
        return self._cost()

    def _cost(self, query_id: str | None = None) -> dict[str, int | float]:
        """按会话或查询汇总已提交成本及中断预留。"""
        receipts = {item['intent']: item for item in self.document['journal'] if item['kind'] == 'receipt'}
        seconds, read_bytes, states, actions, queries = 0.0, 0, 0, 0, 0
        for item in self.document['journal']:
            if item['kind'] != 'intent':
                continue
            if query_id is not None and item['request'].get('query_id') != query_id:
                continue
            actions += 1
            queries += item['operation'] == 'query'
            receipt = receipts.get(item['sequence'])
            seconds += receipt['cost']['elapsed_seconds'] if receipt else item['budget']['max_seconds']
            read_bytes += receipt['cost']['read_bytes'] if receipt else item['budget']['max_read_bytes']
            states += receipt['cost']['states_read'] if receipt else item['budget']['max_states']
        return {
            'elapsed_seconds': seconds,
            'read_bytes': read_bytes,
            'states_read': states,
            'actions': actions,
            'queries': queries,
        }

    def _tick(self) -> None:
        """检查当前动作截止时间。"""
        if time.monotonic() >= self._deadline:
            raise TraceError(StopCode.TIME_BUDGET, '调查动作达到截止时间')

    def _path(self, declared: str) -> Path:
        """相对会话解析路径；缺失时只使用显式重定位，不猜测相似文件。"""
        path = (self.path.parent / declared).resolve()
        if path.exists():
            return path
        for key, value in sorted(self.relocations.items(), key=lambda pair: len(pair[0]), reverse=True):
            for candidate in (declared, str(path)):
                if candidate == key or candidate.startswith(key.rstrip('/') + '/'):
                    return Path(value) / candidate[len(key) :].lstrip('/')
        return path

    def _remaining_budget(self) -> Budget:
        """所有重放子查询共享一个动作读取额度，不能为每个 reader 重置。"""
        read_bytes = self._verification_bytes + sum(
            run.reader.read_bytes - self._before.get(id(run), (0, 0))[0] for run in self._runs
        )
        states = sum(run.reader.states_read - self._before.get(id(run), (0, 0))[1] for run in self._runs)
        if read_bytes >= self._active_budget.max_read_bytes:
            raise TraceError(StopCode.READ_BYTES_BUDGET, '调查动作累计读取预算耗尽')
        return replace(
            self._active_budget,
            max_read_bytes=self._active_budget.max_read_bytes - read_bytes,
            max_states=max(1, self._active_budget.max_states - states),
        )

    def _read_verified(self, path: Path, *, text_limit: int | None = None) -> bytes | str:
        """计入实际核验扫描字节；解析器的二次文本读取另有单文件大小和时间上限。"""
        digest = hashlib.sha256()
        contents = bytearray()
        try:
            with path.open('rb') as stream:
                while True:
                    self._tick()
                    remaining = self._remaining_budget().max_read_bytes
                    block = stream.read(min(64 * 1024, remaining + 1))
                    if not block:
                        break
                    self._verification_bytes += len(block)
                    if len(block) > remaining:
                        raise TraceError(StopCode.READ_BYTES_BUDGET, '调查动作工件核验读取预算耗尽')
                    if text_limit is None:
                        digest.update(block)
                    else:
                        contents.extend(block)
                        if len(contents) > text_limit:
                            raise TraceError(StopCode.STATE_BYTES_BUDGET, 'JSON 工件超过单文件预算')
        except OSError as error:
            raise TraceError(StopCode.MISSING_ARTIFACT, '调查工件不可读取', path=str(path)) from error
        return bytes(contents) if text_limit is not None else digest.hexdigest()

    def _open_run(self) -> RunArtifacts:
        """为查询或源码动作打开计量工件；局部子类不会替换全局 I/O 函数。"""
        session = self

        class ActionRun(RunArtifacts):
            def _hash(self, path: Path) -> str:
                digest = session._read_verified(path)
                assert isinstance(digest, str)
                remaining = session._remaining_budget()
                states = sum(
                    item.reader.states_read - session._before.get(id(item), (0, 0))[1] for item in session._runs
                )
                self.reader.budget = replace(
                    self.reader.budget,
                    max_read_bytes=self.reader.read_bytes + remaining.max_read_bytes,
                    max_states=max(1, self.reader.states_read + session._active_budget.max_states - states),
                )
                return digest

            @staticmethod
            def _text(path: Path, limit: int) -> str:
                contents = session._read_verified(path, text_limit=limit)
                assert isinstance(contents, bytes)
                try:
                    return contents.decode('utf-8')
                except UnicodeDecodeError as error:
                    raise TraceError(StopCode.INVALID_INPUT, 'JSON 工件不是 UTF-8') from error

        reference = RecordRef.from_dict(self.document['run'])
        states = sum(run.reader.states_read - self._before.get(id(run), (0, 0))[1] for run in self._runs)
        if states >= self._active_budget.max_states:
            raise TraceError(StopCode.STATE_BUDGET, '调查动作累计解码状态预算耗尽')
        run = ActionRun.open(self._path(reference.path), budget=self._remaining_budget(), relocations=self.relocations)
        self._runs.append(run)
        run.reader.deadline = self._deadline
        if run.manifest.run_id != reference.id or run.manifest_sha256 != reference.sha256:
            raise TraceError(StopCode.HASH_MISMATCH, '会话运行工件身份不一致')
        return run

    def _configure(self, engine: _Query) -> None:
        """每动作重设 reader 截止时间和累计读取上限；关闭旧 worker 以刷新局部预算。"""
        reader = engine.run.reader
        reader.close()
        remaining = self._remaining_budget()
        reader.budget = replace(
            remaining,
            max_read_bytes=min(engine.request.budget.max_read_bytes, reader.read_bytes + remaining.max_read_bytes),
            max_states=reader.states_read + remaining.max_states,
        )
        reader.deadline = self._deadline
        engine.deadline = self._deadline

    def _snapshot(self) -> dict[str, Any]:
        """保存轻量图和审计提交点；失败动作的解码成本仍记账，结果不部分提交。"""
        result: dict[str, Any] = {}
        for key, investigation in self.queries.items():
            engine = investigation.engine
            result[key] = (
                dict(engine.nodes),
                list(engine.edges),
                list(engine.frontier),
                set(engine.expanded),
                set(engine.state_ids),
                dict(engine.memory_writes),
                set(investigation.pending),
                dict(investigation.dependencies),
                {node: set(indices) for node, indices in investigation.applied.items()},
                dict(engine.run.checked_states),
                set(engine.run.checked_history),
                dict(engine.run.verified_artifacts),
            )
        return result

    def _restore(self, snapshot: dict[str, Any]) -> None:
        """回滚失败动作的图、选择和审计；缓存只影响成本，不作为证据导入。"""
        for key in list(self.queries):
            if key not in snapshot:
                self.queries.pop(key).engine.run.close()
                continue
            investigation = self.queries[key]
            engine = investigation.engine
            (
                engine.nodes,
                engine.edges,
                engine.frontier,
                engine.expanded,
                engine.state_ids,
                engine.memory_writes,
                investigation.pending,
                investigation.dependencies,
                investigation.applied,
                engine.run.checked_states,
                engine.run.checked_history,
                engine.run.verified_artifacts,
            ) = snapshot[key]

    def _action(
        self, operation: str, request: dict[str, Any], actor: str, budget: Budget, callback: Any = None
    ) -> dict[str, Any]:
        """预留、运行、记账并提交一次动作；异常与恢复不绕过累计限制。"""
        if self._lock.closed:
            raise TraceError(StopCode.INVALID_INPUT, '会话已关闭')
        _nonempty(actor, 'actor')
        used = self.cost
        seconds = self.budget.max_seconds - used['elapsed_seconds']
        read_bytes = int(self.budget.max_read_bytes - used['read_bytes'])
        query_id = request.get('query_id')
        if query_id in self.queries:
            query_budget = self.queries[query_id].engine.request.budget
            query_cost = self._cost(query_id)
            seconds = min(seconds, query_budget.max_seconds - query_cost['elapsed_seconds'])
            read_bytes = min(read_bytes, int(query_budget.max_read_bytes - query_cost['read_bytes']))
        if seconds <= 0 or read_bytes <= 0 or used['actions'] >= self.budget.max_actions:
            raise TraceError(StopCode.INVALID_BUDGET, '会话累计预算已耗尽', cost=used)
        if operation == 'query' and used['queries'] >= self.budget.max_queries:
            raise TraceError(StopCode.INVALID_BUDGET, '会话查询次数预算已耗尽', cost=used)
        self._active_budget = replace(
            budget, max_seconds=min(budget.max_seconds, seconds), max_read_bytes=min(budget.max_read_bytes, read_bytes)
        )
        self._verification_bytes = 0
        start = time.monotonic()
        self._deadline = start + self._active_budget.max_seconds
        snapshot = self._snapshot()
        selected = self.selected, self.selected_node
        before = {id(run): (run.reader.read_bytes, run.reader.states_read) for run in self._runs}
        self._before = before
        intent = self._append(
            {
                'kind': 'intent',
                'operation': operation,
                'request': request,
                'actor': actor,
                'requested_budget': budget.to_dict(),
                'budget': self._active_budget.to_dict(),
                'request_sha256': _hash(request),
            }
        )
        status, caught = 'ok', None
        result: dict[str, Any] = {}
        try:
            self._tick()
            result = callback() if callback is not None else self._apply(operation, request)
            self._tick()
        except Exception as error:
            caught = error if isinstance(error, TraceError) else TraceError(StopCode.INTERNAL_ERROR, str(error))
            status = 'error'
            result = {'code': caught.code.value, 'message': caught.message, 'details': caught.details}
            self._restore(snapshot)
            self.selected, self.selected_node = selected
        finally:
            cost = {
                'elapsed_seconds': time.monotonic() - start,
                'read_bytes': sum(run.reader.read_bytes - before.get(id(run), (0, 0))[0] for run in self._runs),
                'states_read': sum(run.reader.states_read - before.get(id(run), (0, 0))[1] for run in self._runs),
                'verification_bytes': self._verification_bytes,
            }
            cost['state_read_bytes'] = cost['read_bytes']
            cost['read_bytes'] += self._verification_bytes
            for run in self._runs:
                run.reader.close()
        self._append({'kind': 'receipt', 'intent': intent, 'status': status, 'result': result, 'cost': cost})
        if caught is not None:
            raise caught
        return result

    def _apply(self, operation: str, request: dict[str, Any]) -> dict[str, Any]:
        """执行一个可重放动作；查询根之外的节点仅由 expand 请求产生。"""
        if operation == 'query':
            return self._new_query(request)
        query_id = request['query_id']
        if query_id not in self.queries:
            raise TraceError(StopCode.INVALID_INPUT, '未知查询', query_id=query_id)
        investigation = self.queries[query_id]
        engine = investigation.engine
        self._configure(engine)
        # 每次动作都确认 manifest 身份，包含不读取值的 select/revisit。
        engine.run._unchanged()
        for state_id in engine.run.checked_states:
            key = engine.run.states[state_id].artifact
            if key is not None:
                engine.run.resolve(engine.run.manifest.artifacts[key])
        node = request.get('node')
        if node is not None and node not in engine.nodes:
            raise TraceError(StopCode.INVALID_INPUT, '节点不属于此查询', node=node)
        self.selected, self.selected_node = query_id, node
        if operation == 'expand':
            if not isinstance(node, str):
                raise TraceError(StopCode.INVALID_INPUT, '展开需要节点身份')
            original = engine.request
            engine.request = replace(
                original,
                budget=replace(
                    original.budget,
                    max_nodes=min(original.budget.max_nodes, len(engine.nodes) + self._active_budget.max_nodes),
                    max_states=min(original.budget.max_states, len(engine.state_ids) + self._active_budget.max_states),
                ),
            )
            try:
                investigation.expand(node, request['branch'])
            finally:
                engine.request = original
        elif operation == 'locate':
            binding = self._path(request['binding']) if request.get('binding') is not None else None
            run = self._open_run()
            binding_hash = self._read_verified(binding) if binding is not None else None
            sources = bind_sources(run, binding)
            located = attach_sources(investigation.report(), engine.topology, sources)
            return {
                'query_id': query_id,
                'node': node,
                'binding_sha256': binding_hash,
                'locations': [
                    location.to_dict() for item in located.nodes if item.id == node for location in item.locations
                ],
                'limitations': list(located.limitations),
            }
        elif operation not in {'select', 'revisit'}:
            raise TraceError(StopCode.INVALID_INPUT, '未知调查动作', operation=operation)
        return {'query_id': query_id, 'node': node, 'evidence_sha256': evidence_sha256(investigation.report())}

    def _new_query(self, payload: dict[str, Any]) -> dict[str, Any]:
        """重新绑定请求和检查来源，建立仅有根的查询。"""
        from . import TraceRun, load_check_reference

        request = QueryRequest.from_dict(payload['request'])
        run = self._open_run()
        topology = TraceTopology.from_run(run)
        binding = topology.resolve(request.target)
        check: CheckRecord | None = None
        check_hash: str | None = None
        carrier = self._path(payload['check_carrier']) if payload.get('check_carrier') is not None else self.path
        if request.check is not None:
            session = self

            # 复用加载器的原始预期/映射重导入，但共享本动作 reader，防止隐式第二份预算。
            class SharedCheckRun(TraceRun):
                def resolve_record(self, reference: RecordRef, carrier: Path | str) -> Path:
                    candidate = session._path(str((Path(carrier).absolute().parent / reference.path).resolve()))
                    digest = run._hash(candidate)
                    if reference.sha256 is not None and reference.sha256 != digest:
                        raise TraceError(StopCode.HASH_MISMATCH, '检查引用哈希不一致')
                    return candidate

                def import_checks(
                    self,
                    format: str,
                    expected: Path | str,
                    observations: ObservationMap,
                    *,
                    carrier: Path | None = None,
                    budget: Budget | None = None,
                ) -> tuple[CheckRecord, ...]:
                    return import_checks(run, topology, format, expected, observations, carrier=carrier)

            facade = SharedCheckRun(run.path, run.manifest.run_id, run.manifest_sha256, run.relocations)
            check_path = facade.resolve_record(request.check, carrier)
            contents = self._read_verified(check_path, text_limit=self._active_budget.max_state_bytes)
            assert isinstance(contents, bytes)
            check_hash = hashlib.sha256(contents).hexdigest()
            package = _json(contents.decode('utf-8'))
            if isinstance(package, dict) and package.get('kind') == 'trace_checks':
                from .model import ArtifactRef

                for key in ('expected', 'observations'):
                    reference = ArtifactRef._from_dict(package[key], require_version=False)
                    run.resolve(reference, carrier=check_path)
            check = load_check_reference(request.check, carrier, facade)
            if check.source.record is not None:
                facade.resolve_record(check.source.record, check_path)
            check = normalize_check(run, topology, check, carrier=check_path)
            observed, dump = run.locate(check.observation)
            requested, requested_dump = run.locate(request.observation)
            if (observed.state_id, dump.dump_id if dump else None) != (
                requested.state_id,
                requested_dump.dump_id if requested_dump else None,
            ) or not any(
                topology.resolve(target).target_id == binding.target_id and target.bit_range == request.target.bit_range
                for target in check.targets
            ):
                raise TraceError(StopCode.INVALID_INPUT, '查询目标和位置必须属于所绑定检查')
        engine = _Query(run, request, topology, bind_semantics(run), check)
        engine.deadline = self._deadline
        root = engine.start(binding)
        identity = payload['query_id']
        if identity in self.queries:
            raise TraceError(StopCode.DUPLICATE_IDENTITY, '查询身份重复')
        investigation = _Investigation(engine, {root})
        self.queries[identity] = investigation
        self.selected, self.selected_node = identity, root
        return {
            'query_id': identity,
            'node': root,
            'check_sha256': check_hash,
            'evidence_sha256': evidence_sha256(investigation.report()),
        }

    def query(
        self,
        request: QueryRequest,
        *,
        actor: str,
        check_carrier: Path | str | None = None,
        budget: Budget | None = None,
    ) -> str:
        """追加独立请求；改变窗口使用新请求，旧查询保留以供重访。"""
        identity = 'q' + str(int(self.cost['queries']) + 1)
        carrier = (
            os.path.relpath(Path(check_carrier).absolute(), self.path.parent) if check_carrier is not None else None
        )
        payload = {'query_id': identity, 'request': request.to_dict(), 'check_carrier': carrier}
        requested_budget = budget or request.budget
        effective = Budget(
            **{
                name: min(value, getattr(request.budget, name))
                for name, value in requested_budget.to_dict().items()
                if name != 'schema_version'
            }
        )
        self._action('query', payload, actor, effective)
        return identity

    def expand(
        self,
        node: str,
        *,
        actor: str,
        query_id: str | None = None,
        branch: Branch = 'all',
        budget: Budget | None = None,
    ) -> TraceReport:
        """只展开一个已发现节点的一层，不预先计算全图。"""
        identity = query_id or self.selected
        self._action('expand', {'query_id': identity, 'node': node, 'branch': branch}, actor, budget or Budget())
        return self.report(identity)

    def select(
        self, node: str, *, actor: str, query_id: str | None = None, budget: Budget | None = None
    ) -> TraceReport:
        """保存节点选择，选择本身不展开依赖。"""
        identity = query_id or self.selected
        self._action('select', {'query_id': identity, 'node': node}, actor, budget or Budget())
        return self.report(identity)

    def revisit(self, query_id: str, *, actor: str, budget: Budget | None = None) -> TraceReport:
        """重新选择已保存查询，并验证当前 manifest 身份。"""
        self._action('revisit', {'query_id': query_id}, actor, budget or Budget())
        return self.report(query_id)

    def locate(
        self,
        node: str,
        *,
        actor: str,
        query_id: str | None = None,
        source_binding: Path | str | None = None,
        budget: Budget | None = None,
    ) -> dict[str, Any]:
        """返回真实定位精度和缺源原因；定位结果不冒充根因结论。"""
        binding = (
            os.path.relpath(Path(source_binding).absolute(), self.path.parent) if source_binding is not None else None
        )
        return self._action(
            'locate',
            {'query_id': query_id or self.selected, 'node': node, 'binding': binding},
            actor,
            budget or Budget(),
        )

    def report(self, query_id: str | None = None) -> TraceReport:
        """返回已核验图的当前快照，pending 不会被标为完整。"""
        identity = query_id or self.selected
        if identity not in self.queries:
            raise TraceError(StopCode.INVALID_INPUT, '没有可返回的查询')
        report = self.queries[identity].report()
        cost = self._cost(identity)
        return replace(
            report,
            cost=replace(
                report.cost, elapsed_seconds=float(cost['elapsed_seconds']), read_bytes=int(cost['read_bytes'])
            ),
        )

    def close(self) -> None:
        """释放所有查询的解析进程；已提交会话可在其他进程恢复。"""
        for run in self._runs:
            run.close()
        if not self._lock.closed:
            fcntl.flock(self._lock.fileno(), fcntl.LOCK_UN)
            self._lock.close()

    def __enter__(self) -> InvestigationSession:
        """进入资源管理上下文。"""
        return self

    def __exit__(self, *_args: Any) -> None:
        """退出时关闭 reader，不丢弃持久化日志。"""
        self.close()
