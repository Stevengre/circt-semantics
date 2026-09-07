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
    value = hashlib.sha256()
    try:
        with path.open('rb') as stream:
            for block in iter(lambda: stream.read(64 * 1024), b''):
                value.update(block)
    except OSError as error:
        raise TraceError(StopCode.MISSING_ARTIFACT, '无法读取引用文件', path=str(path)) from error
    return value.hexdigest()


def load_relocations(path: Path | str) -> dict[str, Path]:
    """读取显式重定位文档；复制证据路径相对于该文档解析。"""
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
        mapping = load_relocations(relocations) if isinstance(relocations, (str, Path)) else dict(relocations or {})
        normalized = Path(normalization_output).absolute() if normalization_output is not None else None
        with RunArtifacts.open(path, budget=budget, relocations=mapping, normalization_output=normalized) as run:
            return cls(run.path, run.manifest.run_id, run.manifest_sha256, mapping)

    def _open(self, budget: Budget | None = None) -> RunArtifacts:
        run = RunArtifacts.open(self.path, budget=budget, relocations=self.relocations)
        if run.manifest.run_id != self.run_id or run.manifest_sha256 != self.manifest_sha256:
            run.close()
            raise TraceError(StopCode.IDENTITY_MISMATCH, '运行 manifest 自公共门面打开后发生变化')
        return run

    def run_reference(self, carrier: Path | str) -> RecordRef:
        return _record(self.path, Path(carrier).absolute(), self.run_id)

    def resolve_record(self, reference: RecordRef, carrier: Path | str) -> Path:
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
    return run.import_checks(format, expected, observations, carrier=carrier, budget=budget)


def load_check_reference(reference: RecordRef, carrier: Path | str, trace_run: TraceRun) -> CheckRecord:
    """加载 raw CheckRecord 或 trace_checks bundle，并固定其 run/check 身份。"""
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
