"""离线动态错误追踪的公共 Python 门面。"""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
from typing import TYPE_CHECKING, Any

from .artifacts import RunArtifacts
from .checks import import_checks as _import_checks
from .model import (
    CheckRecord,
    ObservationMap,
    RecordRef,
    StopCode,
    TraceError,
)
from .query import query as _query
from .report import link_report, write_report
from .source import bind_sources
from .topology import TraceTopology

if TYPE_CHECKING:
    from .model import Budget, QueryRequest, TraceReport


def _digest(path: Path) -> str:
    """分块计算引用文件的 SHA-256；读取失败统一报告为工件缺失。"""
    value = hashlib.sha256()
    try:
        with path.open('rb') as stream:
            for block in iter(lambda: stream.read(64 * 1024), b''):
                value.update(block)
    except OSError as error:
        raise TraceError(StopCode.MISSING_ARTIFACT, '无法读取引用文件', path=str(path)) from error
    return value.hexdigest()


def load_relocations(path: Path | str) -> dict[str, Path]:
    """读取并校验显式重定位文档，返回声明路径到本地副本的映射。

    副本路径相对于重定位 JSON 解析；逐项核对文件哈希并拒绝重复声明路径。
    """
    carrier = Path(path).absolute()
    try:
        document = json.loads(carrier.read_text(encoding='utf-8'))
    except (OSError, ValueError) as error:
        raise TraceError(StopCode.INVALID_INPUT, '无法读取 relocations JSON', path=str(carrier)) from error
    if (
        not isinstance(document, dict)
        or document.get('schema_version') != 1
        or document.get('kind') != 'trace_relocations'
        or not isinstance(document.get('entries'), list)
    ):
        raise TraceError(StopCode.INVALID_INPUT, 'relocations 必须是 schema_version=1 的 trace_relocations')
    result = {}
    for entry in document['entries']:
        if (
            not isinstance(entry, dict)
            or not isinstance(entry.get('declared_path'), str)
            or not isinstance(entry.get('copied_path'), str)
            or not isinstance(entry.get('sha256'), str)
        ):
            raise TraceError(StopCode.INVALID_INPUT, 'relocations 条目缺少路径或哈希')
        copied = (carrier.parent / entry['copied_path']).resolve()
        if not copied.is_file() or _digest(copied) != entry['sha256']:
            raise TraceError(StopCode.HASH_MISMATCH, '重定位副本缺失或哈希不一致', path=str(copied))
        if entry['declared_path'] in result:
            raise TraceError(StopCode.DUPLICATE_IDENTITY, 'relocations 包含重复声明路径')
        result[entry['declared_path']] = copied
    return result


def _record(path: Path, carrier: Path, identity: str | None = None) -> RecordRef:
    """为文件生成相对于承载文档的引用，并固定可选记录 ID 和当前文件哈希。"""
    return RecordRef(Path(os.path.relpath(path, carrier.parent)).as_posix(), identity, _digest(path))


class TraceRun:
    """固定一次运行身份；每个公共操作使用独立 RunArtifacts 和读取预算。"""

    def __init__(
        self,
        path: Path,
        run_id: str,
        manifest_sha256: str,
        relocations: dict[str, Path],
    ) -> None:
        """保存运行路径、运行 ID 和 manifest 哈希，并复制重定位映射以固定门面配置。"""
        self.path = path
        self.run_id = run_id
        self.manifest_sha256 = manifest_sha256
        self.relocations = dict(relocations)

    @classmethod
    def open(
        cls,
        path: Path | str,
        *,
        relocations: dict[str, Path] | Path | str | None = None,
        normalization_output: Path | str | None = None,
        budget: Budget | None = None,
    ) -> TraceRun:
        """打开并校验运行工件，记录运行身份后关闭此次读取会话。

        接受直接传入的重定位映射或重定位 JSON；旧格式的规范化输出交由 RunArtifacts 处理。
        返回的门面不持有打开的读取器，后续每个操作分别使用自己的读取预算。
        """
        mapping = load_relocations(relocations) if isinstance(relocations, (str, Path)) else dict(relocations or {})
        normalized = Path(normalization_output).absolute() if normalization_output is not None else None
        with RunArtifacts.open(path, budget=budget, relocations=mapping, normalization_output=normalized) as run:
            return cls(run.path, run.manifest.run_id, run.manifest_sha256, mapping)

    def _open(self, budget: Budget | None = None) -> RunArtifacts:
        """为一次操作创建独立读取器，并确认运行 ID 与 manifest 字节未自首次打开后改变。

        身份不符时先关闭新读取器再报错；成功返回的读取器由调用方负责关闭。
        """
        run = RunArtifacts.open(self.path, budget=budget, relocations=self.relocations)
        if run.manifest.run_id != self.run_id or run.manifest_sha256 != self.manifest_sha256:
            run.close()
            raise TraceError(StopCode.IDENTITY_MISMATCH, '运行 manifest 自公共门面打开后发生变化')
        return run

    def run_reference(self, carrier: Path | str) -> RecordRef:
        """生成相对于指定承载文件的运行引用，附带已固定的运行 ID 和文件当前哈希。"""
        return _record(self.path, Path(carrier).absolute(), self.run_id)

    def resolve_record(self, reference: RecordRef, carrier: Path | str) -> Path:
        """相对承载文件解析记录引用，原文件缺失时尝试显式重定位并校验可选哈希。"""
        carrier = Path(carrier).absolute()
        path = (carrier.parent / reference.path).resolve()
        if not path.is_file():
            path = self.relocations.get(reference.path, path)
        if not path.is_file():
            raise TraceError(StopCode.MISSING_ARTIFACT, '引用文件不存在', path=str(path))
        if reference.sha256 is not None and _digest(path) != reference.sha256:
            raise TraceError(StopCode.HASH_MISMATCH, '引用文件哈希不一致', path=str(path))
        return path

    def list_targets(self, *, budget: Budget | None = None, kind: str | None = None) -> tuple[dict[str, Any], ...]:
        """在独立读取预算内构建运行拓扑，返回按可选种类筛选的目标字典。"""
        with self._open(budget) as run:
            return tuple(item.to_dict() for item in TraceTopology.from_run(run).list_targets(kind))

    def query(
        self,
        request: QueryRequest,
        *,
        check: CheckRecord | None = None,
        check_carrier: Path | None = None,
        source_binding: Path | str | None = None,
        output: Path | str | None = None,
        copy_evidence: bool = False,
    ) -> TraceReport:
        """执行一次离线查询，并按需附加源码位置或写出可复核报告目录。

        查询及源码绑定共享本次 request 的读取预算；提供 output 时可同时复制引用证据，
        未提供 output 时返回内存中的结构化报告。
        """
        with self._open(request.budget) as run:
            topology = TraceTopology.from_run(run)
            report = _query(run, request, check=check, check_carrier=check_carrier)
            sources = bind_sources(run, source_binding) if source_binding is not None else None
            if output is not None:
                return write_report(
                    report,
                    output,
                    run=run,
                    topology=topology,
                    source_index=sources,
                    check_carrier=check_carrier,
                    copy_evidence=copy_evidence,
                )
            if sources is not None:
                from .report import attach_sources

                return attach_sources(report, topology, sources)
            return report

    def import_checks(
        self,
        format: str,
        expected: Path | str,
        observations: ObservationMap,
        *,
        carrier: Path | None = None,
        budget: Budget | None = None,
    ) -> tuple[CheckRecord, ...]:
        """按显式采样映射比较预期文件与运行观测，在独立预算内返回差异检查记录。"""
        with self._open(budget) as run:
            return _import_checks(
                run,
                TraceTopology.from_run(run),
                format,
                expected,
                observations,
                carrier=carrier,
            )


def list_targets(run: TraceRun, *, budget: Budget | None = None, kind: str | None = None) -> tuple[dict[str, Any], ...]:
    """通过公共运行门面列出目标，保留调用方指定的种类过滤和读取预算。"""
    return run.list_targets(budget=budget, kind=kind)


def query(
    run: TraceRun,
    request: QueryRequest,
    *,
    check: CheckRecord | None = None,
    check_carrier: Path | None = None,
    source_binding: Path | str | None = None,
    output: Path | str | None = None,
    copy_evidence: bool = False,
) -> TraceReport:
    """将查询请求、检查来源和可选报告输出设置委托给对应的运行门面。"""
    return run.query(
        request,
        check=check,
        check_carrier=check_carrier,
        source_binding=source_binding,
        output=output,
        copy_evidence=copy_evidence,
    )


def import_checks(
    run: TraceRun,
    format: str,
    expected: Path | str,
    observations: ObservationMap,
    *,
    carrier: Path | None = None,
    budget: Budget | None = None,
) -> tuple[CheckRecord, ...]:
    """通过公共运行门面导入 CSV 或 VCD 差异，使用调用方给定的观测映射。"""
    return run.import_checks(format, expected, observations, carrier=carrier, budget=budget)


def load_check_reference(reference: RecordRef, carrier: Path | str, trace_run: TraceRun) -> CheckRecord:
    """加载单条检查或 trace_checks 包，并唯一选中属于当前运行的检查记录。

    检查包需校验运行及来源工件引用，再从原预期和观测映射重新导入，确认包内记录未失真。
    未指定检查 ID 时也必须只匹配一条记录，避免默选多个差异中的某一条。
    """
    carrier = Path(carrier).absolute()
    path = trace_run.resolve_record(reference, carrier)
    text = path.read_text(encoding='utf-8')
    try:
        document = json.loads(text)
    except ValueError as error:
        raise TraceError(StopCode.INVALID_INPUT, '检查文件不是有效 JSON') from error
    if isinstance(document, dict) and document.get('kind') == 'trace_checks':
        from .model import ArtifactRef

        if (
            document.get('schema_version') != 1
            or document.get('run_id') != trace_run.run_id
            or document.get('format') not in {'csv', 'vcd'}
        ):
            raise TraceError(StopCode.IDENTITY_MISMATCH, '检查包与当前运行身份不一致')
        try:
            run_ref = RecordRef._from_dict(document['run'], require_version=False)
            expected_ref = ArtifactRef._from_dict(document['expected'], require_version=False)
            observations_ref = ArtifactRef._from_dict(document['observations'], require_version=False)
        except (KeyError, TraceError) as error:
            raise TraceError(StopCode.INVALID_INPUT, 'trace_checks 缺少有效的运行或来源引用') from error
        if run_ref.id != trace_run.run_id or trace_run.resolve_record(run_ref, path) != trace_run.path:
            raise TraceError(StopCode.IDENTITY_MISMATCH, 'trace_checks.run 不属于当前运行')

        def artifact(ref: ArtifactRef, role: str) -> Path:
            """解析检查包中的来源工件，并核对角色、文件大小和哈希后返回本地路径。"""
            candidate = (path.parent / ref.path).resolve()
            if (
                ref.role != role
                or not candidate.is_file()
                or candidate.stat().st_size != ref.size_bytes
                or _digest(candidate) != ref.sha256
            ):
                raise TraceError(StopCode.HASH_MISMATCH, 'trace_checks 来源工件缺失或身份不符', role=role)
            return candidate

        expected_path = artifact(expected_ref, 'check_source')
        observations_path = artifact(observations_ref, 'observation_map')
        observations = ObservationMap.from_json(observations_path.read_text(encoding='utf-8'))
        records = document.get('checks')
        if not isinstance(records, list):
            raise TraceError(StopCode.INVALID_INPUT, 'trace_checks.checks 必须是数组')
        checks = tuple(CheckRecord._from_dict(item, require_version=False) for item in records)
        # 文件引用正确还不足以证明包中结论真实，需按原预期和采样映射重新生成比对。
        regenerated = trace_run.import_checks(document['format'], expected_path, observations, carrier=path)
        if checks != regenerated:
            raise TraceError(StopCode.INCONSISTENT_EVIDENCE, 'trace_checks 内容与绑定来源重新导入结果不同')
    else:
        checks = (CheckRecord.from_json(text),)
    candidates = [item for item in checks if reference.id is None or item.id == reference.id]
    if len(candidates) != 1:
        raise TraceError(
            StopCode.IDENTITY_MISMATCH,
            '检查引用未唯一命中检查记录',
            check_id=reference.id,
            candidates=[item.id for item in candidates],
        )
    if candidates[0].run_id != trace_run.run_id:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '检查记录属于另一运行')
    return candidates[0]


__all__ = [
    'TraceRun',
    'import_checks',
    'link_report',
    'list_targets',
    'load_check_reference',
    'load_relocations',
    'query',
]
