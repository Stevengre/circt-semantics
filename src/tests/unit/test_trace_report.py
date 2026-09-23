"""报告必须由结构化事实生成，并保持原运行工件只读。"""

from __future__ import annotations

import hashlib
import json
from dataclasses import replace
from pathlib import Path

import pytest

from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.model import (
    BitVector,
    CheckRecord,
    CheckSource,
    Observation,
    QueryRequest,
    RecordRef,
    StopCode,
    Target,
    TraceError,
    TraceReport,
)
from kcirct.trace.report import render_summary, write_report
from kcirct.trace.topology import TraceTopology

from .test_trace_query import PROFILE, _Query, small_run


def _sha(path: Path) -> str:
    """计算夹具文件的字节哈希，用于证明报告生成未修改原始工件。"""
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _report(path: Path) -> tuple[RunArtifacts, TraceTopology, TraceReport]:
    """从小型运行构造目标查询和报告，并返回仍打开的读取器供测试显式关闭。"""
    run = RunArtifacts.open(path)
    topology = TraceTopology.from_run(run)
    request = QueryRequest(
        Target('signal', name='Demo/result'),
        Observation('post_eval', state_id='state1', evaluation=1),
    )
    report = _Query(run, request, topology, PROFILE).execute(topology.resolve(request.target))
    return run, topology, report


def test_report_json_summary_and_request_share_the_same_facts(tmp_path: Path) -> None:
    """验证报告 JSON、请求与摘要来自同一组事实，且生成过程保持原运行工件字节不变。"""
    manifest = small_run(tmp_path / 'run')
    before = {path.name: _sha(path) for path in manifest.parent.iterdir()}
    run, topology, report = _report(manifest)
    try:
        written = write_report(report, tmp_path / 'report', run=run, topology=topology)
    finally:
        run.close()
    loaded = TraceReport.from_json((tmp_path / 'report/report.json').read_text())
    assert loaded == written
    assert loaded.request.to_json() == (tmp_path / 'report/request.json').read_text()
    summary = (tmp_path / 'report/summary.md').read_text()
    assert loaded.report_id in summary and loaded.run_id in summary
    assert loaded.status.query in summary
    assert loaded.nodes[0].ref.result in summary
    assert loaded.nodes[0].value is not None
    assert str(loaded.nodes[0].value.to_dict()) in summary
    assert {path.name: _sha(path) for path in manifest.parent.iterdir()} == before


def test_report_rebases_and_copies_only_verified_evidence(tmp_path: Path) -> None:
    """验证报告引用按新目录重定位，证据副本哈希正确，且 manifest 副本保留原始字节。"""
    manifest = small_run(tmp_path / 'run')
    check_dir = tmp_path / 'checks'
    check_dir.mkdir()
    expected = check_dir / 'expected.txt'
    expected.write_text('independent expected value: 8\n')
    carrier = check_dir / 'checks.json'
    carrier.write_text('{}\n')
    run, topology, report = _report(manifest)
    actual = report.nodes[0].value
    assert actual is not None
    check = CheckRecord(
        'mismatch',
        report.run_id,
        'value_mismatch',
        (report.request.target,),
        report.request.observation,
        CheckSource(
            kind='manual',
            record=RecordRef('expected.txt', sha256=_sha(expected)),
            generation_method='independent fixture',
        ),
        expected=BitVector.from_int(8, actual.width),
        actual=actual,
    )
    report = replace(report, check=check, status=replace(report.status, design_check='failed'))
    try:
        written = write_report(
            report,
            tmp_path / 'portable',
            run=run,
            topology=topology,
            check_carrier=carrier,
            copy_evidence=True,
        )
    finally:
        run.close()
    assert written.run is not None
    assert (tmp_path / 'portable/report.json').parent.joinpath(written.run.path).resolve() == manifest.resolve()
    assert written.check is not None and written.check.source.record is not None
    assert (tmp_path / 'portable/report.json').parent.joinpath(
        written.check.source.record.path
    ).resolve() == expected.resolve()
    relocations = json.loads((tmp_path / 'portable/relocations.json').read_text())
    assert relocations['schema_version'] == 1 and relocations['kind'] == 'trace_relocations'
    roles = {entry['role'] for entry in relocations['entries']}
    assert {'run_manifest', 'state_index', 'state', 'check_source'} <= roles
    for entry in relocations['entries']:
        copied = (tmp_path / 'portable' / entry['copied_path']).resolve()
        assert copied.is_file() and _sha(copied) == entry['sha256']
    manifest_copy = next(entry for entry in relocations['entries'] if entry['role'] == 'run_manifest')
    assert (tmp_path / 'portable' / manifest_copy['copied_path']).read_bytes() == manifest.read_bytes()


def test_existing_output_and_missing_check_source_are_rejected_without_partial_directory(tmp_path: Path) -> None:
    """验证已有输出被拒绝，检查来源缺失时清理新目录，避免遗留部分报告。"""
    manifest = small_run(tmp_path / 'run')
    run, topology, report = _report(manifest)
    existing = tmp_path / 'existing'
    existing.mkdir()
    with pytest.raises(TraceError) as error:
        write_report(report, existing, run=run, topology=topology)
    assert error.value.code == StopCode.INVALID_INPUT
    actual = report.nodes[0].value
    assert actual is not None
    check = CheckRecord(
        'missing',
        report.run_id,
        'value_mismatch',
        (report.request.target,),
        report.request.observation,
        CheckSource(kind='manual', record=RecordRef('missing.txt'), generation_method='fixture'),
        expected=BitVector.from_int(actual.unsigned + 1, actual.width),
        actual=actual,
    )
    broken = replace(report, check=check, status=replace(report.status, design_check='failed'))
    with pytest.raises(TraceError) as error:
        write_report(
            broken,
            tmp_path / 'broken',
            run=run,
            topology=topology,
            check_carrier=tmp_path / 'checks.json',
        )
    run.close()
    assert error.value.code == StopCode.MISSING_ARTIFACT
    assert not (tmp_path / 'broken').exists()


def test_summary_keeps_partial_boundaries_and_does_not_claim_root_cause(tmp_path: Path) -> None:
    """验证部分报告摘要保留不支持操作的停止边界，不将追踪结果宣称为根因。"""
    manifest = small_run(tmp_path / 'run', unknown=True)
    run, _, report = _report(manifest)
    run.close()
    summary = render_summary(report)
    assert report.status.query == 'partial'
    assert StopCode.UNSUPPORTED_OPERATION.value in summary
    assert '根因' not in summary
