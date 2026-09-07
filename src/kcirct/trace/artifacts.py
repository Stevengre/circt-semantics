"""绑定离线运行工件，按实际读取范围审计状态并保留历史缺口。"""

from __future__ import annotations

import hashlib
import json
import os
import re
import time
from collections import OrderedDict
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING, Any
from uuid import uuid4

from .kore import KoreReader, history_matches, metadata_differences
from .model import (
    ArtifactRef,
    CompletionEvidence,
    DumpIndexEntry,
    PortSpec,
    QueryCost,
    RecordRef,
    RunManifest,
    StateIndexEntry,
    StopCode,
    StopReason,
    TraceError,
)

if TYPE_CHECKING:
    from collections.abc import Callable

    from .kore import DecodedState
    from .model import Budget, Observation

_BLOCK = 64 * 1024
_TIME_UNITS = {'s': 10**15, 'ms': 10**12, 'us': 10**9, 'ns': 10**6, 'ps': 10**3, 'fs': 1}
_METADATA = ('connection', 'procedures', 'register', 'hw-instances', 'top-module', 'top-ins')


def exact_time(value: int, unit: str) -> int:
    """将整数物理时刻转换成 fs；不经过浮点数。"""
    match = re.fullmatch(r'(1|10|100)?(s|ms|us|ns|ps|fs)', unit)
    if type(value) is not int or value < 0 or match is None:
        raise TraceError(StopCode.INVALID_INPUT, '时间必须为非负整数，单位必须是有效整数 VCD 单位')
    return value * int(match[1] or 1) * _TIME_UNITS[match[2]]


def _json(text: str) -> Any:
    def pairs(items: list[tuple[str, Any]]) -> dict[str, Any]:
        result: dict[str, Any] = {}
        for key, value in items:
            if key in result:
                raise TraceError(StopCode.INVALID_INPUT, 'JSON 包含重复字段', key=key)
            result[key] = value
        return result

    def nonfinite(value: str) -> Any:
        raise TraceError(StopCode.INVALID_INPUT, 'JSON 包含非有限数', value=value)

    try:
        return json.loads(text, object_pairs_hook=pairs, parse_constant=nonfinite)
    except (json.JSONDecodeError, RecursionError) as error:
        raise TraceError(StopCode.INVALID_INPUT, '无法解析 JSON', error=str(error)) from error


class RunArtifacts:
    """一次查询持有一份运行和一个有预算的 reader，不共享运行缓存。"""

    def __init__(
        self, path: Path, manifest: RunManifest, reader: KoreReader, relocations: dict[str, Path], manifest_sha256: str
    ) -> None:
        self.path = path
        self.manifest = manifest
        self.reader = reader
        self.relocations = relocations
        self.states: dict[str, StateIndexEntry] = {}
        self.dumps: dict[str, DumpIndexEntry] = {}
        self.issues: list[StopReason] = []
        self.verified_artifacts: dict[str, str] = {}
        self.checked_states: dict[str, dict[str, Any]] = {}
        self.checked_history: set[tuple[str, str]] = set()
        self._cache: OrderedDict[str, DecodedState] = OrderedDict()
        self.cache_bytes = 0
        self.peak_cache_bytes = 0
        self.manifest_sha256 = manifest_sha256
        self._unchanged()
        self._load_index()

    @classmethod
    def open(
        cls,
        path: Path | str,
        *,
        budget: Budget | None = None,
        relocations: dict[str, Path] | None = None,
        normalization_output: Path | None = None,
    ) -> RunArtifacts:
        """接受新 manifest 或旧 simulate v1 result；旧规范化只写入新目录。"""
        path = Path(path).expanduser().resolve()
        reader = KoreReader(budget)
        mapping = {key: Path(value).expanduser().resolve() for key, value in (relocations or {}).items()}
        try:
            text = cls._text(path, reader.budget.max_state_bytes)
            document = _json(text)
            if isinstance(document, dict) and 'trace_manifest' in document:
                reference = document['trace_manifest']
                if not isinstance(reference, str) or Path(reference).is_absolute():
                    raise TraceError(StopCode.INVALID_INPUT, 'result 的 trace_manifest 必须是相对路径')
                path = path.parent / reference
                text = cls._text(path, reader.budget.max_state_bytes)
                manifest = RunManifest.from_json(text)
                if document.get('run_id') != manifest.run_id:
                    raise TraceError(StopCode.IDENTITY_MISMATCH, 'result 与 manifest 的 run_id 不一致')
            elif isinstance(document, dict) and 'artifacts' in document:
                manifest = RunManifest.from_json(text)
            else:
                if normalization_output is None:
                    raise TraceError(StopCode.INVALID_INPUT, '旧 result.json 需要指定新的 normalization_output 目录')
                path = _normalize_legacy(path, document, normalization_output, mapping, reader)
                text = cls._text(path, reader.budget.max_state_bytes)
                manifest = RunManifest.from_json(text)
            return cls(path, manifest, reader, mapping, hashlib.sha256(text.encode('utf-8')).hexdigest())
        except BaseException:
            reader.close()
            raise

    def __enter__(self) -> RunArtifacts:
        return self

    def __exit__(self, *_args: Any) -> None:
        self.close()

    def close(self) -> None:
        self.reader.close()
        self._cache.clear()
        self.cache_bytes = 0

    @staticmethod
    def _text(path: Path, limit: int) -> str:
        try:
            with path.open('rb') as stream:
                data = stream.read(limit + 1)
            if len(data) > limit:
                raise TraceError(StopCode.STATE_BYTES_BUDGET, 'JSON 工件超过单文件读取上限', path=str(path))
            return data.decode('utf-8')
        except (FileNotFoundError, IsADirectoryError) as error:
            raise TraceError(StopCode.MISSING_ARTIFACT, '找不到所需工件', path=str(path)) from error
        except UnicodeDecodeError as error:
            raise TraceError(StopCode.INVALID_INPUT, 'JSON 工件不是 UTF-8', path=str(path)) from error

    def _deadline(self) -> None:
        if time.monotonic() >= self.reader.deadline:
            raise TraceError(StopCode.TIME_BUDGET, '工件校验已到查询截止时间')

    def _hash(self, path: Path) -> str:
        return _hash_file(path, self._deadline)

    def _unchanged(self) -> None:
        if self._hash(self.path) != self.manifest_sha256:
            raise TraceError(StopCode.HASH_MISMATCH, '读取期间 manifest 内容发生变化', path=str(self.path))
        if self.manifest.state_index is not None:
            self.resolve(self.manifest.state_index)

    def resolve(self, ref: ArtifactRef, *, carrier: Path | None = None) -> Path:
        """相对于承载引用的 JSON 解析路径；默认载体为本次 manifest。"""
        self._deadline()
        declared_path = (carrier or self.path).absolute().parent / ref.path
        path = _relocated(declared_path, ref.path, self.relocations)
        try:
            size = path.stat().st_size
        except OSError as error:
            raise TraceError(StopCode.MISSING_ARTIFACT, '工件路径缺失或不可读取', path=str(path)) from error
        if size != ref.size_bytes or self._hash(path) != ref.sha256:
            raise TraceError(StopCode.HASH_MISMATCH, '工件大小或 SHA-256 不一致', path=str(path), role=ref.role)
        self.verified_artifacts[str(declared_path)] = ref.sha256
        return path

    def verify_artifact(self, key: str) -> Path:
        self._unchanged()
        if key not in self.manifest.artifacts:
            raise TraceError(StopCode.MISSING_ARTIFACT, 'manifest 未登记所需工件', artifact=key)
        return self.resolve(self.manifest.artifacts[key])

    def _load_index(self) -> None:
        if self.manifest.state_index is None:
            self.issues.append(StopReason(StopCode.NOT_RETAINED, '运行未记录状态索引'))
            return
        if self.manifest.state_index.size_bytes > self.reader.budget.max_state_bytes:
            raise TraceError(StopCode.STATE_BYTES_BUDGET, '索引元数据超过单文件读取上限')
        path = self.resolve(self.manifest.state_index)
        used_positions: set[tuple[int | None, int | None, str]] = set()
        with path.open('r', encoding='utf-8') as stream:
            while True:
                self._deadline()
                line = stream.readline(self.reader.budget.max_state_bytes + 1)
                if not line:
                    break
                if len(line.encode('utf-8')) > self.reader.budget.max_state_bytes:
                    raise TraceError(StopCode.STATE_BYTES_BUDGET, '状态索引单条记录超过读取上限')
                if not line.strip():
                    raise TraceError(StopCode.INVALID_INPUT, '状态索引不允许空记录')
                document = _json(line)
                if not isinstance(document, dict):
                    raise TraceError(StopCode.INVALID_INPUT, '状态索引记录必须是对象')
                if document.get('phase') == 'dump':
                    dump = DumpIndexEntry.from_dict(document)
                    if dump.dump_id in self.dumps:
                        raise TraceError(StopCode.DUPLICATE_IDENTITY, 'dump_id 重复', dump_id=dump.dump_id)
                    self.dumps[dump.dump_id] = dump
                else:
                    entry = StateIndexEntry.from_dict(document)
                    position = (entry.event_index, entry.evaluation, entry.phase)
                    if entry.state_id in self.states or position in used_positions:
                        raise TraceError(StopCode.DUPLICATE_IDENTITY, '状态身份或位置重复', state_id=entry.state_id)
                    used_positions.add(position)
                    self.states[entry.state_id] = entry
        self.resolve(self.manifest.state_index)
        for entry in self.states.values():
            if entry.artifact is not None and entry.artifact not in self.manifest.artifacts:
                raise TraceError(StopCode.MISSING_ARTIFACT, '索引引用未登记的状态工件', state_id=entry.state_id)
            if entry.predecessor == entry.state_id:
                raise TraceError(StopCode.INCONSISTENT_EVIDENCE, '状态不能以自身为前驱', state_id=entry.state_id)
        for dump in self.dumps.values():
            bound_entry = self.states.get(dump.state_id)
            if bound_entry is None or bound_entry.phase != 'post_eval':
                raise TraceError(StopCode.IDENTITY_MISMATCH, 'dump 未绑定已登记的 post_eval 状态', dump_id=dump.dump_id)
            if (bound_entry.event_index, bound_entry.evaluation) != (dump.event_index, dump.evaluation):
                raise TraceError(StopCode.IDENTITY_MISMATCH, 'dump 的 event/evaluation 与绑定状态不同')
            if (
                bound_entry.time is not None
                and bound_entry.time_unit is not None
                and exact_time(bound_entry.time, bound_entry.time_unit) != exact_time(dump.time, dump.time_unit)
            ):
                raise TraceError(StopCode.IDENTITY_MISMATCH, 'dump 时间与绑定状态不同')

    @property
    def setup_id(self) -> str:
        setups = [entry.state_id for entry in self.states.values() if entry.phase == 'setup']
        if len(setups) != 1:
            raise TraceError(StopCode.MISSING_ARTIFACT, '查询需要唯一的 setup 状态', candidates=setups)
        return setups[0]

    @property
    def cost(self) -> QueryCost:
        return QueryCost(
            elapsed_seconds=self.reader.elapsed_seconds,
            states_read=self.reader.states_read,
            read_bytes=self.reader.read_bytes,
            peak_cache_bytes=self.peak_cache_bytes,
        )

    @property
    def audit(self) -> dict[str, Any]:
        return {
            'states': dict(self.checked_states),
            'history_edges': [list(edge) for edge in sorted(self.checked_history)],
            'artifacts': dict(self.verified_artifacts),
            'metadata_cells': list(_METADATA),
            'scope': '仅覆盖列出的状态、工件和连续前驱边',
            'semantics_binding': self.manifest.identities.get('semantics_binding', {'status': 'unknown'}),
        }

    def _state(self, state_id: str) -> tuple[StateIndexEntry, DecodedState]:
        self._unchanged()
        entry = self.states.get(state_id)
        if entry is None:
            raise TraceError(StopCode.HISTORY_GAP, '状态索引缺少请求位置', state_id=state_id)
        if entry.retention == 'not_retained':
            raise TraceError(StopCode.NOT_RETAINED, '该状态未保留；需要在新运行启用 keep-states', state_id=state_id)
        if entry.artifact is None:
            raise TraceError(StopCode.MISSING_ARTIFACT, '该状态没有持久工件', state_id=state_id)
        ref = self.manifest.artifacts[entry.artifact]
        if ref.role != 'state':
            raise TraceError(StopCode.IDENTITY_MISMATCH, '状态索引引用了其他角色的工件', state_id=state_id)
        path = self.resolve(ref)
        content_hash = ref.uncompressed_sha256 if ref.compression == 'gzip' else ref.sha256
        if entry.content_sha256 is not None and entry.content_sha256 != content_hash:
            raise TraceError(StopCode.HASH_MISMATCH, '索引与状态工件的原始哈希不一致', state_id=state_id)
        assert content_hash is not None
        cache_key = ref.sha256 + ':' + content_hash
        decoded = self._cache.get(cache_key)
        if decoded is not None:
            self._cache.move_to_end(cache_key)
        else:
            decoded = self.reader.read(
                path, compression=ref.compression, artifact_sha256=ref.sha256, uncompressed_sha256=content_hash
            )
            if ref.uncompressed_size_bytes is not None and decoded.read_bytes != ref.uncompressed_size_bytes:
                raise TraceError(StopCode.HASH_MISMATCH, '解压后大小与登记值不一致', state_id=state_id)
            if decoded.view_bytes <= self.reader.budget.max_cache_bytes:
                while self._cache and self.cache_bytes + decoded.view_bytes > self.reader.budget.max_cache_bytes:
                    _, evicted = self._cache.popitem(last=False)
                    self.cache_bytes -= evicted.view_bytes
                self._cache[cache_key] = decoded
                self.cache_bytes += decoded.view_bytes
                self.peak_cache_bytes = max(self.peak_cache_bytes, self.cache_bytes)
        if ref.uncompressed_size_bytes is not None and decoded.read_bytes != ref.uncompressed_size_bytes:
            raise TraceError(StopCode.HASH_MISMATCH, '解压后大小与登记值不一致', state_id=state_id)
        if entry.completion.status == 'incomplete' or decoded.completion.status != 'completed':
            raise TraceError(
                StopCode.INCOMPLETE_EXECUTION,
                '状态未完成，不能作为可信设计解释',
                state_id=state_id,
                recorded=entry.completion.status,
                observed=decoded.completion.to_dict(),
            )
        return entry, decoded

    def read_state(self, state_id: str) -> DecodedState:
        """原记录未知时做本次终态审计，保留原记录；不推断全运行都完成。"""
        entry, decoded = self._state(state_id)
        if entry.phase != 'setup':
            setup_entry, setup = self._state(self.setup_id)
            self.checked_states[setup_entry.state_id] = {
                'content_sha256': setup.uncompressed_sha256,
                'recorded_completion': setup_entry.completion.status,
                'observed_completion': setup.completion.status,
                'metadata_integrity': 'valid',
            }
            differences = metadata_differences(setup, decoded)
            if differences:
                raise TraceError(
                    StopCode.METADATA_CORRUPTION,
                    '状态的只读元数据与 setup 不一致',
                    state_id=state_id,
                    cells=list(differences),
                )
        self.checked_states[state_id] = {
            'content_sha256': decoded.uncompressed_sha256,
            'recorded_completion': entry.completion.status,
            'observed_completion': decoded.completion.status,
            'metadata_integrity': 'valid',
        }
        return decoded

    def predecessor(self, state_id: str) -> DecodedState:
        """只有明确连续的位置和 history/signals 相符才建立历史边。"""
        current = self.read_state(state_id)
        entry = self.states[state_id]
        if entry.phase == 'setup':
            raise TraceError(StopCode.INITIALIZATION, '已到 setup 初始化状态', state_id=state_id)
        previous = self.states.get(entry.predecessor or '')
        if previous is None:
            raise TraceError(StopCode.HISTORY_GAP, '真实前驱未登记，不能跨越历史缺口', state_id=state_id)
        evaluations = self.manifest.protocol.get('evaluations_per_input')
        contiguous = False
        if previous.phase == 'setup':
            contiguous = entry.event_index == 0 and entry.evaluation == 1
        elif entry.event_index == previous.event_index:
            contiguous = entry.evaluation == (previous.evaluation or 0) + 1
        elif type(evaluations) is int and evaluations > 0:
            contiguous = (
                previous.evaluation == evaluations
                and entry.evaluation == 1
                and entry.event_index == (previous.event_index if previous.event_index is not None else -1) + 1
            )
        if not contiguous:
            raise TraceError(StopCode.HISTORY_GAP, '前驱位置不连续或协议不足以证明连续性', state_id=state_id)
        try:
            predecessor = self.read_state(previous.state_id)
        except TraceError as error:
            if error.code in {StopCode.NOT_RETAINED, StopCode.MISSING_ARTIFACT}:
                raise TraceError(StopCode.HISTORY_GAP, '前驱状态未保留或缺失', state_id=previous.state_id) from error
            raise
        if not history_matches(predecessor, current):
            raise TraceError(
                StopCode.INCONSISTENT_EVIDENCE,
                'history 与真实前驱 signals 不一致',
                state_id=state_id,
                predecessor=previous.state_id,
            )
        self.checked_history.add((previous.state_id, state_id))
        return predecessor

    def locate(self, observation: Observation) -> tuple[StateIndexEntry, DumpIndexEntry | None]:
        """返回唯一的实际保存位置；sample 必须先经 ObservationMap 显式映射。"""
        candidates: list[tuple[StateIndexEntry, DumpIndexEntry | None]] = []
        if observation.phase == 'dump':
            for dump in self.dumps.values():
                if observation.dump_id is not None and dump.dump_id != observation.dump_id:
                    continue
                entry = self.states[dump.state_id]
                candidates.append((entry, dump))
        else:
            candidates.extend((entry, None) for entry in self.states.values() if entry.phase == observation.phase)
        for name in ('event_index', 'evaluation', 'state_id'):
            value = getattr(observation, name)
            if value is not None:
                candidates = [pair for pair in candidates if getattr(pair[0], name) == value]
        if observation.time is not None and observation.time_unit is not None:
            wanted = exact_time(observation.time, observation.time_unit)
            candidates = [
                pair
                for pair in candidates
                if pair[0].time is not None
                and pair[0].time_unit is not None
                and exact_time(pair[0].time, pair[0].time_unit) == wanted
            ]
        if observation.sample is not None and all(
            item is None
            for item in (observation.event_index, observation.time, observation.state_id, observation.dump_id)
        ):
            candidates = []
        if len(candidates) != 1:
            raise TraceError(
                StopCode.AMBIGUOUS_OBSERVATION,
                '观测不能唯一映射到状态；需要明确的位置或 ObservationMap',
                candidates=[
                    {'state_id': entry.state_id, 'dump_id': dump.dump_id if dump else None}
                    for entry, dump in candidates
                ],
            )
        return candidates[0]


def _hash_file(path: Path, check_deadline: Callable[[], None]) -> str:
    digest = hashlib.sha256()
    try:
        with path.open('rb') as stream:
            while True:
                check_deadline()
                block = stream.read(_BLOCK)
                if not block:
                    break
                digest.update(block)
    except OSError as error:
        raise TraceError(StopCode.MISSING_ARTIFACT, '无法读取工件', path=str(path)) from error
    return digest.hexdigest()


def _relocated(path: Path, relative: str, relocations: dict[str, Path]) -> Path:
    if relative in relocations:
        return relocations[relative]
    absolute = Path(os.path.abspath(path))
    matches = [
        (Path(key), destination)
        for key, destination in relocations.items()
        if Path(key).is_absolute() and absolute.is_relative_to(Path(key))
    ]
    if matches:
        source, destination = max(matches, key=lambda pair: len(pair[0].parts))
        return destination / absolute.relative_to(source)
    return absolute


def _normalize_legacy(
    source: Path, document: Any, output: Path, relocations: dict[str, Path], reader: KoreReader
) -> Path:
    if (
        not isinstance(document, dict)
        or type(document.get('schema_version')) is not int
        or document['schema_version'] != 1
    ):
        raise TraceError(StopCode.UNSUPPORTED_SCHEMA, '只支持明确的 simulate v1 result')
    if not isinstance(document.get('top_module'), str):
        raise TraceError(StopCode.INVALID_INPUT, '旧 result 缺少 top_module')
    output = output.expanduser().absolute()
    if output.exists():
        raise TraceError(StopCode.INVALID_INPUT, '规范化输出目录必须新建，不能覆盖已有材料', path=str(output))

    def deadline() -> None:
        if time.monotonic() >= reader.deadline:
            raise TraceError(StopCode.TIME_BUDGET, '旧材料规范化已到截止时间')

    artifacts: dict[str, ArtifactRef] = {}
    limitations: list[str] = ['旧运行没有逐求值完成审计；本次读取时另行校验，原记录保持 not_checked']

    def register(key: str, path: Path, role: str, digest: str | None = None, raw_hash: str | None = None) -> str | None:
        relocated = _relocated(path, str(path), relocations)
        if not relocated.is_file():
            limitations.append(f'缺少旧工件：{key}')
            return None
        actual_hash = _hash_file(relocated, deadline)
        if digest is not None and digest != actual_hash:
            raise TraceError(StopCode.HASH_MISMATCH, '旧工件不符合原 result 中的哈希', artifact=key)
        compressed = raw_hash is not None and relocated.suffix == '.gz'
        if raw_hash is not None and not compressed and raw_hash != actual_hash:
            raise TraceError(StopCode.HASH_MISMATCH, '旧状态不符合索引中的原始内容哈希', artifact=key)
        artifacts[key] = ArtifactRef(
            role,
            Path(os.path.relpath(relocated, output)).as_posix(),
            actual_hash,
            relocated.stat().st_size,
            compression='gzip' if compressed else 'none',
            uncompressed_sha256=raw_hash if compressed else None,
        )
        return key

    register('legacy_result', source, 'execution_result')
    register('execution_ir', source.parent / 'design.generic.mlir', 'execution_ir', document.get('input_sha256'))
    register('inputs', source.parent / 'inputs.json', 'inputs', document.get('inputs_sha256'))
    for key, field_name, digest_name, role in (
        ('parser', 'parser', 'parser_sha256', 'parser'),
        ('vcd', 'vcd_path', 'vcd_sha256', 'waveform'),
    ):
        if isinstance(document.get(field_name), str):
            register(key, Path(document[field_name]), role, document.get(digest_name))
    if isinstance(document.get('definition_dir'), str):
        definition = Path(document['definition_dir']) / 'definition.kore'
        # 缺失旧定义保留缺口；同路径已有别版定义也不能当成原构建。
        relocated = _relocated(definition, str(definition), relocations)
        if relocated.is_file() and _hash_file(relocated, deadline) == document.get('definition_sha256'):
            register('definition', definition, 'compiled_definition', document.get('definition_sha256'))
        else:
            limitations.append('原 definition.kore 不可获得；不使用当前同名编译产物代替')
    setups: list[StateIndexEntry] = []
    if register('state/setup', source.parent / 'setup.kore', 'state') is not None:
        setups.append(
            StateIndexEntry(
                'setup',
                'setup',
                artifact='state/setup',
                retention='retained',
                content_sha256=artifacts['state/setup'].sha256,
            )
        )
    evaluations, timescale = document.get('evaluations_per_input'), document.get('timescale')
    declared_protocol = type(evaluations) is int and evaluations > 0 and isinstance(timescale, str)
    if declared_protocol and isinstance(timescale, str):
        exact_time(0, timescale)
    index = source.parent / 'states.json'
    old_entries = _json(RunArtifacts._text(index, reader.budget.max_state_bytes)) if index.is_file() else []
    if not isinstance(old_entries, list):
        raise TraceError(StopCode.INVALID_INPUT, '旧 states.json 必须为数组')
    entries: dict[tuple[int, int], StateIndexEntry] = {}
    for old in old_entries:
        if not isinstance(old, dict) or not isinstance(old.get('path'), str):
            raise TraceError(StopCode.INVALID_INPUT, '旧状态索引缺少明确工件路径')
        event, evaluation, timestamp = old.get('event_index'), old.get('evaluation'), old.get('time')
        if type(event) is not int or event < 0 or type(evaluation) is not int or evaluation <= 0:
            raise TraceError(StopCode.INVALID_INPUT, '旧状态索引缺少明确 event/evaluation')
        if (event, evaluation) in entries:
            raise TraceError(StopCode.DUPLICATE_IDENTITY, '旧状态索引含重复 event/evaluation')
        if not isinstance(old.get('sha256_uncompressed'), str):
            raise TraceError(StopCode.INVALID_INPUT, '旧状态索引缺少原始内容哈希')
        state_id = f'event-{event}.eval-{evaluation}'
        filename = Path(old['path'])
        if filename.name in {'simulated.0.kore', 'simulated.1.kore'}:
            raise TraceError(StopCode.NOT_RETAINED, '滚动文件不能当作历史状态归档')
        artifact_key = register(
            'state/' + state_id, source.parent / filename, 'state', raw_hash=old['sha256_uncompressed']
        )
        entries[event, evaluation] = StateIndexEntry(
            state_id,
            'post_eval',
            event_index=event,
            evaluation=evaluation,
            time=timestamp if declared_protocol else None,
            time_unit=timescale if declared_protocol else None,
            artifact=artifact_key,
            retention='retained' if artifact_key is not None else 'missing',
            content_sha256=old['sha256_uncompressed'],
        )
    # 没有归档时只允许已完成运行明确绑定的 last-state；失败调用的位置不是其前驱位置。
    if document.get('status') == 'pass' and document.get('stage') == 'complete':
        event, evaluation = document.get('event_index'), document.get('evaluation')
        if type(event) is int and type(evaluation) is int and (event, evaluation) not in entries:
            last = source.parent / 'last-state.kore'
            artifact_key = register('state/last', last, 'state', document.get('last_state_sha256'))
            if artifact_key is not None:
                entries[event, evaluation] = StateIndexEntry(
                    f'event-{event}.eval-{evaluation}',
                    'post_eval',
                    event_index=event,
                    evaluation=evaluation,
                    time=document.get('event_time') if declared_protocol else None,
                    time_unit=timescale if declared_protocol else None,
                    artifact=artifact_key,
                    retention='retained',
                    content_sha256=artifacts[artifact_key].sha256,
                )
    elif document.get('last_state'):
        limitations.append('失败旧运行的 last-state 位置未经记录，未用失败调用位置猜测其身份')
    for position, entry in list(entries.items()):
        event, evaluation = position
        predecessor = None
        if evaluation > 1:
            predecessor = f'event-{event}.eval-{evaluation - 1}'
        elif event == 0 and setups:
            predecessor = 'setup'
        elif declared_protocol:
            predecessor = f'event-{event - 1}.eval-{evaluations}'
        entries[position] = replace(entry, predecessor=predecessor)
    ordered = [entries[position] for position in sorted(entries)]
    dumps: list[DumpIndexEntry] = []
    completed = document.get('events_completed')
    if declared_protocol and type(completed) is int and isinstance(timescale, str):
        for entry in ordered:
            if entry.evaluation == evaluations and entry.event_index is not None and entry.event_index < completed:
                if entry.time is not None and entry.evaluation is not None:
                    dumps.append(
                        DumpIndexEntry(
                            f'dump-{entry.event_index}',
                            entry.state_id,
                            entry.event_index,
                            entry.evaluation,
                            entry.time,
                            timescale,
                            artifact=artifacts.get('vcd'),
                        )
                    )
    output.mkdir(parents=True, exist_ok=False)
    index_path = output / 'trace-states.jsonl'
    with index_path.open('w', encoding='utf-8') as stream:
        for record in [*setups, *ordered, *dumps]:
            stream.write(json.dumps(record.to_dict(), ensure_ascii=False) + '\n')
    state_index = ArtifactRef(
        'state_index', index_path.name, _hash_file(index_path, deadline), index_path.stat().st_size
    )
    ports = tuple(
        PortSpec.from_dict({'schema_version': 1, 'name': port['name'], 'direction': direction, 'width': port['width']})
        for direction, group in (('input', 'inputs'), ('output', 'outputs'))
        for port in document.get('ports', {}).get(group, [])
    )
    manifest = RunManifest(
        'legacy-' + str(uuid4()),
        document['top_module'],
        artifacts=artifacts,
        ports=ports,
        protocol={
            'status': 'declared' if declared_protocol else 'unknown',
            'evaluations_per_input': evaluations,
            'timescale': timescale,
            'sampling_phase': 'dump' if declared_protocol else 'unknown',
        },
        identities={
            'legacy_recorded': {
                key: value
                for key, value in document.items()
                if key
                in {
                    'package_version',
                    'kframework_version',
                    'api_sha256',
                    'simulator_sha256',
                    'definition_sha256',
                    'parser_sha256',
                }
            },
            'semantics_binding': {'status': 'unknown'},
            'compiled_runtime': {'status': 'unknown'},
        },
        state_index=state_index,
        state_coverage={'status': 'partial', 'limitations': limitations, 'indexed_states': len(setups) + len(ordered)},
        completion=CompletionEvidence(
            status='not_checked', details={'legacy_status': document.get('status', 'unknown')}
        ),
        origin=RecordRef(artifacts['legacy_result'].path, sha256=artifacts['legacy_result'].sha256),
        origin_description='从旧 simulate v1 显式字段建立规范化身份；未重新执行仿真，也未补造历史审计',
    )
    destination = output / 'trace-run.json'
    destination.write_text(manifest.to_json(), encoding='utf-8')
    return destination
