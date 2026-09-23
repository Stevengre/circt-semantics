"""生成可复核报告，并校验假设、重放和回归关联。"""

from __future__ import annotations

import hashlib
import json
import os
import shutil
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING, Any

from .model import (
    CheckRecord,
    FollowUpResult,
    HypothesisRecord,
    RecordRef,
    RunManifest,
    StopCode,
    TraceError,
    TraceReport,
)

if TYPE_CHECKING:
    from .artifacts import RunArtifacts
    from .model import ArtifactRef, TraceNode
    from .source import SourceIndex
    from .topology import Operation, TraceTopology


def _digest(path: Path) -> str:
    """分块计算报告引用工件的 SHA-256，读取失败统一报告为工件缺失。"""
    value = hashlib.sha256()
    try:
        with path.open('rb') as stream:
            for block in iter(lambda: stream.read(64 * 1024), b''):
                value.update(block)
    except OSError as error:
        raise TraceError(StopCode.MISSING_ARTIFACT, '无法读取报告引用的工件', path=str(path)) from error
    return value.hexdigest()


def _relative(path: Path, carrier: Path) -> str:
    """将文件路径改写为相对于承载文档所在目录的 POSIX 路径。"""
    return Path(os.path.relpath(path.absolute(), carrier.absolute().parent)).as_posix()


def _resolve_record(ref: RecordRef, carrier: Path) -> Path:
    """相对承载文档定位已有记录并校验可选哈希，返回解析后的绝对路径。"""
    path = (carrier.absolute().parent / ref.path).resolve()
    if not path.is_file():
        raise TraceError(StopCode.MISSING_ARTIFACT, '报告引用的记录不存在', path=str(path))
    digest = _digest(path)
    if ref.sha256 is not None and ref.sha256 != digest:
        raise TraceError(StopCode.HASH_MISMATCH, '报告引用的记录哈希不一致', path=str(path))
    return path


def _rebase_record(ref: RecordRef, carrier: Path, destination: Path) -> RecordRef:
    """校验原承载文档中的记录引用，再为目标文档改写路径并固定当前哈希。"""
    path = _resolve_record(ref, carrier)
    return replace(ref, path=_relative(path, destination), sha256=_digest(path))


def _operation(node: TraceNode, topology: TraceTopology) -> Operation | None:
    """从报告节点引用查回拓扑操作，支持 procedure 序号及普通节点结果标识。

    过程序号无法解析或节点不存在时返回 None，保留没有可附着源码的报告节点。
    """
    if node.ref.result.startswith('procedure:'):
        try:
            return topology.procedures[int(node.ref.result.split(':', 1)[1])]
        except (IndexError, ValueError):
            return None
    target = topology.nodes.get(node.ref.result)
    return target.operation if target is not None else None


def attach_sources(report: TraceReport, topology: TraceTopology, sources: SourceIndex) -> TraceReport:
    """把同一执行 IR 的位置附到报告节点，并汇入源码绑定的降级原因。

    先校验拓扑与报告的运行身份；无法回查操作的节点保持原样，不把定位精度升级为根因证明。
    """
    if topology.run_id != report.run_id:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '源码拓扑与报告属于不同运行')
    nodes = []
    for node in report.nodes:
        operation = _operation(node, topology)
        nodes.append(replace(node, locations=sources.for_operation(operation)) if operation is not None else node)
    limitations = list(report.limitations)
    limitations.extend(issue.message for issue in sources.issues if issue.message not in limitations)
    return replace(report, nodes=tuple(nodes), limitations=tuple(limitations))


def render_summary(report: TraceReport) -> str:
    """仅从结构化报告渲染中文 Markdown 摘要，覆盖检查、证据、停止边界和后续结果。"""
    target = report.request.target
    observation = report.request.observation
    lines = [
        '# 动态错误追踪报告',
        '',
        f'- 报告 ID：`{report.report_id}`',
        f'- 运行 ID：`{report.run_id}`',
        f'- 目标：`{target.kind}` `{target.name or target.target_id}`',
        (
            f'- 观测：phase=`{observation.phase}`，event={observation.event_index}，'
            f'evaluation={observation.evaluation}，state=`{observation.state_id}`'
        ),
        (
            f'- 状态：execution=`{report.status.execution}`，design_check=`{report.status.design_check}`，'
            f'reference_comparison=`{report.status.reference_comparison}`，'
            f'metadata_integrity=`{report.status.metadata_integrity}`，query=`{report.status.query}`'
        ),
        '',
        '## 检查依据',
        '',
    ]
    if report.check is None:
        lines.append('- 未绑定检查；本报告只解释实际值，不判定设计正确性。')
    else:
        check = report.check
        lines.extend(
            (
                f'- 检查 ID：`{check.id}`',
                f'- 类型：`{check.kind}`；来源：`{check.source.kind}`；生成方式：`{check.source.generation_method}`',
                f'- expected：`{check.expected.to_dict() if check.expected else None}`',
                f'- actual：`{check.actual.to_dict() if check.actual else None}`',
                f'- predicate：`{check.predicate}`；结果：`{check.predicate_result}`',
            )
        )
    lines.extend(('', '## 执行证据', ''))
    for node in report.nodes:
        value = node.value.to_dict() if node.value is not None else None
        position = node.observation.to_dict() if node.observation is not None else None
        locations = [location.to_dict() for location in node.locations]
        lines.append(
            f'- `{node.id}`：`{node.ref.view}` `{node.ref.result}` = `{value}`；'
            f'operation=`{node.operation_name}`；position=`{position}`；'
            f'facts=`{json.dumps(node.facts, ensure_ascii=False, sort_keys=True)}`；'
            f'locations=`{json.dumps(locations, ensure_ascii=False, sort_keys=True)}`'
        )
    if report.edges:
        lines.extend(('', '## 关系', ''))
        lines.extend(f'- `{edge.source}` --`{edge.kind}:{edge.label}`--> `{edge.target}`' for edge in report.edges)
    lines.extend(('', '## 停止边界', ''))
    if report.frontier:
        lines.extend(
            f'- `{item.reason.code.value}`：{item.reason.message}；'
            f'details=`{json.dumps(item.reason.details, ensure_ascii=False, sort_keys=True)}`'
            for item in report.frontier
        )
    else:
        lines.append('- 查询在声明范围内完成。')
    lines.extend(('', '## 范围与成本', ''))
    lines.append(f'- scope：`{json.dumps(report.scope, ensure_ascii=False, sort_keys=True)}`')
    lines.extend(f'- 限制：{item}' for item in report.limitations)
    lines.append(f'- cost：`{json.dumps(report.cost.to_dict(), ensure_ascii=False, sort_keys=True)}`')
    if report.hypotheses:
        lines.extend(('', '## 假设', ''))
        lines.extend(
            f'- `{item.id}`：{item.text}；oracle_status=`{item.oracle_status}`；nodes=`{list(item.node_ids)}`'
            for item in report.hypotheses
        )
    if report.follow_up_results:
        lines.extend(('', '## 后续结果', ''))
        lines.extend(
            f'- `{item.id}`：relation=`{item.relation}`；outcome=`{item.outcome}`；'
            f'hypothesis=`{item.hypothesis_id}`'
            for item in report.follow_up_results
        )
    return '\n'.join(lines) + '\n'


def _artifact_for_report(ref: ArtifactRef, path: Path, destination: Path) -> ArtifactRef:
    """保留工件身份与元数据，只把已解析本地路径改写为相对于报告的引用。"""
    return replace(ref, path=_relative(path, destination))


def _rebase_report(
    report: TraceReport,
    destination: Path,
    *,
    run: RunArtifacts | None,
    source_index: SourceIndex | None,
    check_carrier: Path | None,
    source_carrier: Path | None = None,
) -> TraceReport:
    """把报告中有依据的记录、工件及源码路径改写到新的承载文件。

    提供运行时据已验证工件重建引用；复制已有报告时用 source_carrier 解析检查、假设和
    后续结果中的相对记录引用。既无运行也无原承载文件时原样返回，避免猜测路径基准。
    """
    # link 复用现有报告时没有打开运行，所有记录路径以原报告为基准逐层迁移。
    if run is None:
        if source_carrier is None:
            return report
        run_ref = _rebase_record(report.run, source_carrier, destination) if report.run is not None else None
        check = report.check
        if check is not None and check.source.record is not None:
            check = replace(
                check,
                source=replace(
                    check.source,
                    record=_rebase_record(check.source.record, check_carrier or source_carrier, destination),
                ),
            )
        hypotheses = tuple(
            replace(item, report=_rebase_record(item.report, source_carrier, destination)) for item in report.hypotheses
        )
        outcomes = tuple(
            replace(
                item,
                run=_rebase_record(item.run, source_carrier, destination) if item.run else None,
                check=_rebase_record(item.check, source_carrier, destination) if item.check else None,
                report=_rebase_record(item.report, source_carrier, destination) if item.report else None,
                observations=tuple(_rebase_record(ref, source_carrier, destination) for ref in item.observations),
            )
            for item in report.follow_up_results
        )
        return replace(
            report,
            run=run_ref,
            check=check,
            hypotheses=hypotheses,
            follow_up_results=outcomes,
        )
    if run.manifest.run_id != report.run_id:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '报告与运行身份不一致')
    run_ref = RecordRef(_relative(run.path, destination), report.run_id, run.manifest_sha256)
    paths: dict[str, Path] = {}
    artifacts = []
    for ref in report.artifacts:
        path = run.resolve(ref)
        paths[ref.sha256] = path
        artifacts.append(_artifact_for_report(ref, path, destination))
    nodes = []
    for node in report.nodes:
        # 只重定位能对应到已解析工件的证据，其他引用保持其原有身份和描述。
        evidence = tuple(
            (
                RecordRef(
                    _relative(paths[item.sha256], destination),
                    item.id,
                    item.sha256,
                )
                if item.sha256 in paths
                else item
            )
            for item in node.evidence
        )
        locations = []
        for location in node.locations:
            source = location.source
            if source is not None and source_index is not None and source.sha256 in source_index.artifact_paths:
                source = _artifact_for_report(source, source_index.artifact_paths[source.sha256], destination)
            locations.append(replace(location, source=source))
        nodes.append(replace(node, evidence=evidence, locations=tuple(locations)))
    check = report.check
    if check is not None and check.source.record is not None:
        check = replace(
            check,
            source=replace(
                check.source,
                record=_rebase_record(check.source.record, check_carrier or run.path, destination),
            ),
        )
    return replace(report, run=run_ref, check=check, artifacts=tuple(artifacts), nodes=tuple(nodes))


def _copy_file(path: Path, output: Path, role: str, declared_path: str) -> dict[str, Any]:
    """按内容哈希组织证据副本，核对复制结果并返回重定位条目。

    已有目标文件可复用但必须哈希一致；条目保留原声明路径，供移动后的运行显式重定位。
    """
    digest = _digest(path)
    target = output / 'evidence' / digest[:16] / path.name
    target.parent.mkdir(parents=True, exist_ok=True)
    if not target.exists():
        shutil.copyfile(path, target)
    if _digest(target) != digest:
        raise TraceError(StopCode.HASH_MISMATCH, '复制证据后哈希不一致', path=str(path))
    return {
        'role': role,
        'declared_path': declared_path,
        'copied_path': _relative(target, output / 'relocations.json'),
        'sha256': digest,
        'size_bytes': path.stat().st_size,
    }


def _copy_evidence(
    report: TraceReport, run: RunArtifacts, output: Path, source_index: SourceIndex | None
) -> dict[str, Any]:
    """复制本报告引用的证据、原 manifest 和 state index，并生成重定位文档。

    按哈希与声明路径去重，额外纳入检查来源和已验证源码工件；未读取的状态仅列为外部依赖。
    原始文件字节与其中的引用不重写，搬迁后的解析由显式重定位映射完成。
    """
    entries = [_copy_file(run.path, output, 'run_manifest', report.run.path if report.run else run.path.name)]
    if run.manifest.state_index is not None:
        entries.append(
            _copy_file(
                run.resolve(run.manifest.state_index),
                output,
                'state_index',
                run.manifest.state_index.path,
            )
        )
    copied = {(entry['sha256'], entry['declared_path']) for entry in entries}
    for ref in report.artifacts:
        path = (output / 'report.json').parent / ref.path
        path = path.resolve()
        key = (ref.sha256, ref.path)
        if key not in copied:
            entries.append(_copy_file(path, output, ref.role, ref.path))
            copied.add(key)
    if report.check is not None and report.check.source.record is not None:
        check_ref = report.check.source.record
        path = _resolve_record(check_ref, output / 'report.json')
        key = (_digest(path), check_ref.path)
        if key not in copied:
            entries.append(_copy_file(path, output, 'check_source', check_ref.path))
            copied.add(key)
    if source_index is not None:
        for digest, path in source_index.artifact_paths.items():
            key = (digest, _relative(path, output / 'report.json'))
            if key not in copied:
                entries.append(_copy_file(path, output, 'source_binding', key[1]))
                copied.add(key)
    # 复制范围由报告实际读取证据决定，其余索引状态显式列为外部依赖。
    indexed = {
        entry.artifact
        for entry in run.states.values()
        if entry.artifact is not None and entry.artifact in run.manifest.artifacts
    }
    included = {ref.sha256 for ref in report.artifacts}
    external = [
        {
            'role': run.manifest.artifacts[key].role,
            'declared_path': run.manifest.artifacts[key].path,
            'sha256': run.manifest.artifacts[key].sha256,
            'reason': '未被本报告读取，未复制',
        }
        for key in sorted(indexed)
        if run.manifest.artifacts[key].sha256 not in included
    ]
    return {
        'schema_version': 1,
        'kind': 'trace_relocations',
        'run_id': report.run_id,
        'entries': entries,
        'external': external,
        'scope': '只复制报告实际引用的工件、原 manifest 和原 state index；不重写原始字节',
    }


def write_report(
    report: TraceReport,
    output: Path | str,
    *,
    run: RunArtifacts | None = None,
    topology: TraceTopology | None = None,
    source_index: SourceIndex | None = None,
    check_carrier: Path | None = None,
    source_carrier: Path | None = None,
    copy_evidence: bool = False,
) -> TraceReport:
    """在全新目录写出结构化报告、请求、中文摘要和引用清单，按需复制证据。

    写入前统一附着源码和重定位引用；已有输出目录拒绝覆盖，任一步失败都会删除新建目录，
    避免留下看似完整的部分报告。成功返回与 report.json 内容一致的报告对象。
    """
    output = Path(output).absolute()
    if output.exists():
        raise TraceError(StopCode.INVALID_INPUT, '报告输出目录必须是新路径', path=str(output))
    output.mkdir(parents=True)
    destination = output / 'report.json'
    try:
        if source_index is not None:
            if topology is None:
                raise TraceError(StopCode.INVALID_INPUT, '附着源码需要同一运行的拓扑')
            report = attach_sources(report, topology, source_index)
        report = _rebase_report(
            report,
            destination,
            run=run,
            source_index=source_index,
            check_carrier=check_carrier,
            source_carrier=source_carrier,
        )
        destination.write_text(report.to_json(), encoding='utf-8')
        (output / 'request.json').write_text(report.request.to_json(), encoding='utf-8')
        (output / 'summary.md').write_text(render_summary(report), encoding='utf-8')
        references = {
            'schema_version': 1,
            'kind': 'trace_report_references',
            'run_id': report.run_id,
            'run': report.run.to_dict() if report.run else None,
            'artifacts': [item.to_dict() for item in report.artifacts],
            'limitations': list(report.limitations),
        }
        (output / 'references.json').write_text(
            json.dumps(references, ensure_ascii=False, indent=2) + '\n', encoding='utf-8'
        )
        if copy_evidence:
            if run is None:
                raise TraceError(StopCode.INVALID_INPUT, 'copy-evidence 需要已打开的运行工件')
            relocations = _copy_evidence(report, run, output, source_index)
            (output / 'relocations.json').write_text(
                json.dumps(relocations, ensure_ascii=False, indent=2) + '\n', encoding='utf-8'
            )
        return report
    except BaseException:
        shutil.rmtree(output, ignore_errors=True)
        raise


def _load_reference(ref: RecordRef, carrier: Path, model: Any) -> Any:
    """校验引用文件后按指定模型加载记录，并核对可选运行、检查或报告 ID。"""
    path = _resolve_record(ref, carrier)
    value = model.from_json(path.read_text(encoding='utf-8'))
    identity = value.run_id if model is RunManifest else value.id if model is CheckRecord else value.report_id
    if ref.id is not None and ref.id != identity:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '引用 ID 与记录内容不一致', path=str(path))
    return value


def _artifact_hash(manifest: RunManifest, role: str) -> str | None:
    """仅当 manifest 中某角色恰好对应一个工件时返回其哈希，否则返回 None。"""
    values = [item.sha256 for item in manifest.artifacts.values() if item.role == role]
    return values[0] if len(values) == 1 else None


def _validate_replay(original: RunManifest, current: RunManifest) -> dict[str, Any]:
    """核对两次运行的 IR、输入、端口布局、初始化和采样契约，返回重放兼容性依据。

    IR 与输入必须各有唯一哈希且一致；任一比较项不符便拒绝 replay 关联。
    """
    original_ir, current_ir = _artifact_hash(original, 'execution_ir'), _artifact_hash(current, 'execution_ir')
    original_inputs, current_inputs = _artifact_hash(original, 'inputs'), _artifact_hash(current, 'inputs')
    same = {
        'execution_ir': original_ir is not None and original_ir == current_ir,
        'inputs': original_inputs is not None and original_inputs == current_inputs,
        'top_module': original.top_module == current.top_module,
        'ports': original.ports == current.ports,
        'parameters': original.parameters == current.parameters,
        'initialization': original.initialization == current.initialization,
        'sampling_contract': all(
            original.protocol.get(key) == current.protocol.get(key)
            for key in ('evaluations_per_input', 'sampling_phase', 'timescale')
        ),
    }
    if not all(same.values()):
        raise TraceError(StopCode.IDENTITY_MISMATCH, 'replay 运行的执行 IR、输入、布局或采样契约不同', **same)
    return {'status': 'compatible', **same}


def link_report(
    report_path: Path | str,
    output: Path | str,
    *,
    hypothesis_path: Path | str | None = None,
    outcome_path: Path | str | None = None,
) -> TraceReport:
    """校验假设或后续结果并写出新关联报告，所有相对引用按各自承载文件解析。

    假设须引用原报告的已有节点且 ID 唯一；已执行结果核对 run/check/report 的共同运行身份，
    replay 还需验证原运行与新运行的执行契约兼容。原报告保持只读，新引用统一重定位。
    """
    report_path = Path(report_path).absolute()
    if hypothesis_path is None and outcome_path is None:
        raise TraceError(StopCode.INVALID_INPUT, 'link 至少需要 hypothesis 或 outcome')
    report = TraceReport.from_json(report_path.read_text(encoding='utf-8'))
    hypotheses = list(report.hypotheses)
    outcomes = list(report.follow_up_results)
    if hypothesis_path is not None:
        carrier = Path(hypothesis_path).absolute()
        hypothesis = HypothesisRecord.from_json(carrier.read_text(encoding='utf-8'))
        source_report = _load_reference(hypothesis.report, carrier, TraceReport)
        if source_report.report_id != report.report_id:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '假设引用的不是待链接报告')
        if not set(hypothesis.node_ids) <= {node.id for node in report.nodes}:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '假设引用了报告中不存在的节点')
        if any(item.id == hypothesis.id for item in hypotheses):
            raise TraceError(StopCode.DUPLICATE_IDENTITY, '假设 ID 已存在')
        hypotheses.append(replace(hypothesis, report=_rebase_record(hypothesis.report, carrier, report_path)))
    if outcome_path is not None:
        carrier = Path(outcome_path).absolute()
        outcome = FollowUpResult.from_json(carrier.read_text(encoding='utf-8'))
        if outcome.hypothesis_id is not None and outcome.hypothesis_id not in {item.id for item in hypotheses}:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '后续结果引用了未知假设')
        if any(item.id == outcome.id for item in outcomes):
            raise TraceError(StopCode.DUPLICATE_IDENTITY, '后续结果 ID 已存在')
        comparison = outcome.comparison_scope
        if outcome.outcome != 'not_run':
            assert outcome.run is not None and outcome.check is not None and outcome.report is not None
            current_run = _load_reference(outcome.run, carrier, RunManifest)
            current_check = _load_reference(outcome.check, carrier, CheckRecord)
            current_report = _load_reference(outcome.report, carrier, TraceReport)
            if current_check.run_id != current_run.run_id or current_report.run_id != current_run.run_id:
                raise TraceError(StopCode.IDENTITY_MISMATCH, '后续 run/check/report 身份不一致')
            # 同属一次运行是结果关联的前提；replay 还要求与原运行具备相同执行条件。
            if outcome.relation == 'replay':
                if report.run is None:
                    raise TraceError(StopCode.IDENTITY_MISMATCH, '原报告缺少运行引用，不能核验 replay')
                original_run = _load_reference(report.run, report_path, RunManifest)
                comparison = _validate_replay(original_run, current_run)
        outcomes.append(
            replace(
                outcome,
                run=_rebase_record(outcome.run, carrier, report_path) if outcome.run else None,
                check=_rebase_record(outcome.check, carrier, report_path) if outcome.check else None,
                report=_rebase_record(outcome.report, carrier, report_path) if outcome.report else None,
                observations=tuple(_rebase_record(ref, carrier, report_path) for ref in outcome.observations),
                comparison_scope=comparison,
            )
        )
    linked = replace(report, hypotheses=tuple(hypotheses), follow_up_results=tuple(outcomes))
    return write_report(linked, output, source_carrier=report_path)
