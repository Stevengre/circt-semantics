"""双运行原型的独立边界测试；合成快照不冒充真实 K 或已核验 profile。"""

from __future__ import annotations

import hashlib
import json
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from kcirct.trace import TraceRun
from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.comparison import (
    InputPair,
    PairContract,
    PairReport,
    PairRequest,
    PairSide,
    TargetPair,
    _bindings,
    _compare_reports,
    _initial_values,
    _input_values,
    _side,
    compare_runs,
    evidence_sha256,
    normalized_evidence,
)
from kcirct.trace.model import (
    Budget,
    CheckRecord,
    CheckSource,
    Observation,
    PortSpec,
    QueryRequest,
    QueryWindow,
    RecordRef,
    RunManifest,
    StatusAxes,
    StopCode,
    Target,
    TraceError,
)
from kcirct.trace.semantics import SemanticsProfile
from kcirct.trace.topology import TraceTopology

from .test_trace_memory import Snapshot
from .test_trace_memory import execute as memory_query
from .test_trace_memory import memory_run
from .test_trace_query import PROFILE, artifact, execute, publish, small_run
from .test_trace_register import execute as register_query
from .test_trace_register import register_run

if TYPE_CHECKING:
    from kcirct.trace.model import TraceReport


def _request() -> QueryRequest:
    """固定测试观察位置，避免按时间邻近自动选择状态。"""
    return QueryRequest(Target('signal', name='Demo/result'), Observation('post_eval', event_index=0, evaluation=1))


def _contract(left: Path, right: Path) -> PairContract:
    """仅供合同子校验使用的声明；这些合成工件没有可接受的真实语义绑定。"""
    sides = []
    for path in (left, right):
        manifest = RunManifest.from_json(path.read_text())
        sides.append(PairSide(manifest.run_id, hashlib.sha256(path.read_bytes()).hexdigest(), '1' * 64, {}))
    return PairContract(
        'synthetic-contract-not-k-evidence',
        sides[0],
        sides[1],
        inputs=(InputPair('a', 'a', 'a'),),
        initial_state=(),
        initial_state_coverage='all_storage',
        semantics_source_sha256='2' * 64,
        definition_sha256='3' * 64,
        evaluations_per_input=1,
        timescale='1ns',
    )


def _maps(
    left: TraceReport, right: TraceReport
) -> tuple[dict[tuple[str, str | None], str], dict[tuple[str, str | None], str]]:
    """测试夹具显式采用同名映射；生产实现没有同名自动匹配入口。"""
    return tuple(  # type: ignore[return-value]
        {(node.ref.result, node.ref.address): node.ref.result + ':' + str(node.ref.address) for node in report.nodes}
        for report in (left, right)
    )


def test_identical_graphs_have_no_difference_and_preserve_control(tmp_path: Path) -> None:
    """相同证据没有分叉，控制边及未选静态候选仍保留。"""
    first = execute(small_run(tmp_path / 'left'))
    second = execute(small_run(tmp_path / 'right'))
    pairs, common, differences, unmatched = _compare_reports(first, second, _maps(first, second))
    assert len(pairs) == len(first.nodes)
    assert not differences and not unmatched
    assert {edge['kind'] for edge in common} == {'alias', 'data', 'control', 'static_candidate'}


def test_explicit_renaming_does_not_use_ssa_ordinals(tmp_path: Path) -> None:
    """真实快照中的名称变化通过显式映射对齐，图等价且不按编号猜测。"""
    path = small_run(tmp_path / 'left')
    names = {'%a': '%input_47', '%select': '%select_81', '%other': '%other_12', '%mux': '%mux_5', '%r': '%out_99'}
    texts = []
    for source in ('setup.kore', 'state1.kore'):
        text = (path.parent / source).read_text()
        for before, after in names.items():
            text = text.replace(before + '"', after + '"')
        texts.append(text)
    renamed = publish(tmp_path / 'right', texts, run_id='renamed')
    first, second = execute(path), execute(renamed)
    left_map: dict[tuple[str, str | None], str] = {(f'Demo/{before}', None): before for before in names}
    right_map: dict[tuple[str, str | None], str] = {(f'Demo/{after}', None): before for before, after in names.items()}
    pairs, _, differences, unmatched = _compare_reports(first, second, (left_map, right_map))
    assert len(pairs) == len(first.nodes)
    assert not differences and not unmatched
    _, _, _, no_mapping = _compare_reports(first, second, (left_map, {}))
    assert no_mapping


def test_equal_values_with_different_selected_input_remain_different(tmp_path: Path) -> None:
    """MUX 两个输入同值时，输出相等不能掩盖实际选边和控制差异。"""
    first = execute(small_run(tmp_path / 'left', selector=1, other=7))
    second = execute(small_run(tmp_path / 'right', selector=0, other=7))
    assert first.nodes[0].value == second.nodes[0].value
    _, _, differences, _ = _compare_reports(first, second, _maps(first, second))
    assert any(item.kind == 'control_selection' for item in differences)
    assert any(item.kind == 'dependency' and item.details.get('edge_kind') == 'data' for item in differences)
    assert not any(item.kind == 'value' and item.pair.left == first.nodes[0].id for item in differences)


def test_same_value_capture_is_not_hold(tmp_path: Path) -> None:
    """纯差异层保留同值 capture 与 hold 差异；此测试不声称两组刺激满足公共输入合同。"""
    first = register_query(register_run(tmp_path / 'capture', [{'a': 0, 'c': 1, 'r': 0}]))
    second = register_query(register_run(tmp_path / 'hold', [{'a': 0, 'c': 0, 'r': 0}]))
    assert first.nodes[0].value == second.nodes[0].value
    _, _, differences, _ = _compare_reports(first, second, _maps(first, second))
    assert any(item.kind == 'update' and 'decision' in item.details for item in differences)
    assert any(item.kind == 'update' and item.details.get('edge_kind') == 'capture' for item in differences)


def test_same_value_write_remains_a_write(tmp_path: Path) -> None:
    """同值有效写与禁写的差异不能被数值相等消除。"""
    initial = Snapshot(memory={2: 9})
    first = memory_query(
        memory_run(tmp_path / 'write', [Snapshot(memory={2: 9}, clock=1, address=2, data=9)], setup=initial)
    )
    second = memory_query(
        memory_run(
            tmp_path / 'disabled', [Snapshot(memory={2: 9}, clock=1, address=2, data=9, enable=0)], setup=initial
        )
    )
    assert first.nodes[0].value == second.nodes[0].value
    _, _, differences, _ = _compare_reports(first, second, _maps(first, second))
    assert any(item.kind == 'update' and item.details.get('edge_kind') == 'write' for item in differences)


def test_evaluation_and_view_are_not_merged(tmp_path: Path) -> None:
    """同一事件中的多个 eval 和 prior/committed 坐标独立，不能因同值折叠。"""
    path = register_run(tmp_path, [{'a': 8, 'c': 1, 'r': 8}, {'a': 8, 'c': 1, 'r': 8}], evaluations=2)
    report = register_query(path, 2)
    pairs, _, differences, unmatched = _compare_reports(report, report, _maps(report, report))
    assert not differences and not unmatched
    assert {pair.coordinate['evaluation'] for pair in pairs} >= {1, 2}
    assert {'prior', 'committed'} <= {pair.coordinate['view'] for pair in pairs}


def test_missing_mapping_is_unmatched_not_guessed(tmp_path: Path) -> None:
    """一个未登记的内部信号保留未匹配，即使值与对侧相同。"""
    first = execute(small_run(tmp_path))
    left_map, right_map = _maps(first, first)
    del right_map[('Demo/%mux', None)]
    _, _, _, unmatched = _compare_reports(first, first, (left_map, right_map))
    assert any(item.get('reason') == 'no_explicit_mapping_or_coordinate' for item in unmatched)


def test_corrupt_side_cannot_be_compared_as_partial(tmp_path: Path) -> None:
    """保存值与重算冲突必须拒绝，不能用局部报告继续比较。"""
    first = execute(small_run(tmp_path / 'good'))
    second = execute(small_run(tmp_path / 'bad', wrong=True))
    with pytest.raises(TraceError) as caught:
        _compare_reports(first, second, _maps(first, second))
    assert caught.value.code == StopCode.INCONSISTENT_EVIDENCE


def test_partial_side_keeps_original_frontier(tmp_path: Path) -> None:
    """受限窗口的原 frontier 不会被差异层清除。"""
    path = register_run(tmp_path, [{'a': 8, 'c': 1, 'r': 8}, {'a': 8, 'c': 1, 'r': 8}])
    full = register_query(path, 2)
    partial = register_query(path, 2, window=QueryWindow(first_event=1))
    frontier = partial.frontier
    _, _, _, unmatched = _compare_reports(full, partial, _maps(full, partial))
    assert unmatched and partial.frontier == frontier
    assert StopCode.WINDOW_BOUNDARY in {item.reason.code for item in frontier}


def test_pair_schema_rejects_parameter_conflict_and_unknown(tmp_path: Path) -> None:
    """显式参数不一致或 unknown 不能作为相容合同。"""
    path = small_run(tmp_path)
    contract = _contract(path, path)
    with pytest.raises(TraceError) as conflict:
        replace(contract, right=replace(contract.right, parameters={'WIDTH': 12}))
    assert conflict.value.code == StopCode.IDENTITY_MISMATCH
    with pytest.raises(TraceError):
        replace(contract.left, parameters={'status': 'unknown'})
    with pytest.raises(TraceError):
        replace(contract, inputs=(InputPair('a', 'a', 'a'), InputPair('b', 'a', 'b')))
    assert PairContract.from_json(contract.to_json()) == contract


def test_resolved_alias_collision_is_rejected(tmp_path: Path) -> None:
    """不同名字若解析到同一真实信号，也构成非法一对多映射。"""
    path = small_run(tmp_path)
    with RunArtifacts.open(path) as run:
        topology = TraceTopology.from_run(run)
        mappings = (
            TargetPair('first', Target('signal', name='Demo/result'), Target('signal', name='Demo/result')),
            TargetPair('second', Target('signal', name='Demo/%r'), Target('signal', name='Demo/%r')),
        )
        with pytest.raises(TraceError) as caught:
            _bindings(mappings, topology, topology)
    assert caught.value.code == StopCode.DUPLICATE_IDENTITY


def test_full_initial_register_coverage_and_values_are_checked(tmp_path: Path) -> None:
    """遗漏寄存器拒绝，初态比较读取独立夹具保存值。"""
    path = register_run(tmp_path, [{'a': 7, 'c': 1, 'r': 7}], setup={'r': 5, 'c': 0})
    with RunArtifacts.open(path) as run:
        topology = TraceTopology.from_run(run)
        with pytest.raises(TraceError) as caught:
            _initial_values(run, topology, {}, PROFILE)
        assert caught.value.code == StopCode.IDENTITY_MISMATCH
        values = _initial_values(run, topology, {('Demo/%r', None): 'register'}, PROFILE)
    assert values['register']['value']['value'] == '5'
    assert values['register']['origin'] == 'saved_setup'


def test_memory_initial_coverage_requires_every_address(tmp_path: Path) -> None:
    """查询单个 cell 不足以证明整块 memory 初态相容。"""
    path = memory_run(tmp_path, [Snapshot(memory={2: 9})], setup=Snapshot(memory={2: 9}), depth=4)
    with RunArtifacts.open(path) as run:
        topology = TraceTopology.from_run(run)
        with pytest.raises(TraceError):
            _initial_values(run, topology, {('Demo/%mem', '2'): 'cell2'}, PROFILE)
        values = _initial_values(
            run, topology, {('Demo/%mem', str(index)): f'cell{index}' for index in range(4)}, PROFILE
        )
    assert [values[f'cell{index}']['value']['value'] for index in range(4)] == ['0', '0', '9', '0']


def test_input_values_are_compared_and_tampering_is_rejected(tmp_path: Path) -> None:
    """输入读取核验原始字节，并保持实际事件、值与位宽供跨侧逐项比较。"""
    path = small_run(tmp_path)
    inputs = path.parent / 'inputs.json'
    inputs.write_text(
        json.dumps({'schema_version': 1, 'timescale': '1ns', 'events': [{'time': 0, 'inputs': {'a': 7}}]})
    )
    manifest = RunManifest.from_json(path.read_text())
    path.write_text(
        replace(
            manifest,
            artifacts=dict(manifest.artifacts, inputs=artifact(inputs, path.parent, 'inputs')),
            ports=(PortSpec('a', 'input', 8),),
        ).to_json()
    )
    contract = _contract(path, path)
    with RunArtifacts.open(path) as run:
        events = _input_values(run, contract, 'left')
        assert events == [{'time': 0, 'inputs': {'a': {'width': 8, 'value': 7}}}]
        inputs.write_text(inputs.read_text().replace('7', '8'))
        with pytest.raises(TraceError) as caught:
            _input_values(run, contract, 'left')
        assert caught.value.code == StopCode.HASH_MISMATCH


def test_public_pair_rejects_synthetic_profile(tmp_path: Path) -> None:
    """公共入口不能因合成快照查询成功就接受未核验的 profile。"""
    path = small_run(tmp_path)
    run = TraceRun.open(path)
    request = _request()
    contract = _contract(path, path)
    pair_request = PairRequest(request, request, (TargetPair('output', request.target, request.target),))
    with pytest.raises(TraceError) as caught:
        compare_runs(run, pair_request, right=run, contract=contract)
    assert caught.value.code == StopCode.UNSUPPORTED_SEMANTICS


def test_profile_gate_rejects_legacy_record_only_binding(tmp_path: Path) -> None:
    """缺编译定义原字节的历史 profile 不能升级为双运行完整核验。"""
    path = small_run(tmp_path)
    design = path.parent / 'design.mlir'
    design.write_text('synthetic IR identity fixture, not executable\n')
    manifest = RunManifest.from_json(path.read_text())
    ref = artifact(design, path.parent, 'execution_ir')
    path.write_text(replace(manifest, artifacts=dict(manifest.artifacts, execution_ir=ref)).to_json())
    contract = _contract(path, path)
    side = replace(contract.left, execution_ir_sha256=ref.sha256)
    legacy = SemanticsProfile(
        contract.semantics_source_sha256, contract.definition_sha256, False, 'source_verified_definition_recorded'
    )
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as caught:
        _side(run, side, contract, legacy)
    assert caught.value.code == StopCode.UNSUPPORTED_SEMANTICS


def test_no_reference_returns_real_single_run_query(tmp_path: Path) -> None:
    """无参考时保留原单侧 partial 结果，不生成正常内部状态或比较成功计数。"""
    run = TraceRun.open(small_run(tmp_path))
    result = compare_runs(run, PairRequest(_request()))
    assert result.mode == 'single_run' and result.comparison_status == 'not_run'
    assert result.right is None and not result.differences
    assert result.left.status.query == 'partial'
    assert result.left.frontier[0].reason.code == StopCode.UNSUPPORTED_SEMANTICS
    assert PairReport.from_json(result.to_json()) == result


def test_normalization_preserves_semantics_but_ignores_display_and_cost(tmp_path: Path) -> None:
    """顺序、报告 UUID、预算和物理位置不影响证据摘要，控制边变化必须改变摘要。"""
    report = execute(small_run(tmp_path))
    shuffled = replace(
        report,
        report_id='new-display-id',
        nodes=tuple(reversed(report.nodes)),
        edges=tuple(reversed(report.edges)),
        request=replace(report.request, budget=Budget(max_seconds=120)),
        cost=replace(report.cost, elapsed_seconds=999),
        run=replace(report.run, path='../moved/trace-run.json') if report.run else None,
    )
    assert normalized_evidence(report) == normalized_evidence(shuffled)
    changed = replace(report, edges=tuple(edge for edge in report.edges if edge.kind != 'control'))
    assert evidence_sha256(report) != evidence_sha256(changed)


def test_check_source_keeps_its_own_carrier(tmp_path: Path) -> None:
    """运行、请求和检查文件位于不同目录时，报告保存原来源的正确载体及哈希。"""
    run = TraceRun.open(small_run(tmp_path / 'run'))
    checks = tmp_path / 'checks'
    checks.mkdir()
    source = checks / 'source.txt'
    source.write_text('independent suspicious observation fixture\n')
    request = _request()
    check = CheckRecord(
        'observation',
        run.run_id,
        'suspicious_observation',
        (request.target,),
        request.observation,
        source=CheckSource(
            'manual', record=RecordRef(source.name, sha256=hashlib.sha256(source.read_bytes()).hexdigest())
        ),
    )
    check_path = checks / 'check.json'
    check_path.write_text(check.to_json())
    request = replace(
        request, check=RecordRef('checks/check.json', check.id, hashlib.sha256(check_path.read_bytes()).hexdigest())
    )
    request_path = tmp_path / 'request.json'
    request_path.write_text(request.to_json())
    destination = tmp_path / 'saved/pair.json'
    result = compare_runs(run, PairRequest(request), carrier=destination, left_request_carrier=request_path)
    carrier = (destination.parent / result.evidence_carriers['left_check'].path).resolve()
    assert carrier == check_path
    assert result.left.check is not None and result.left.check.source.record is not None
    assert (carrier.parent / result.left.check.source.record.path).resolve() == source
    assert PairReport.from_json(result.to_json()) == result


def test_query_window_conflict_and_fake_single_comparison_are_rejected(tmp_path: Path) -> None:
    """窗口不一致拒绝，保存模型不允许单侧结果宣称匹配参考。"""
    request = _request()
    with pytest.raises(TraceError):
        PairRequest(
            request,
            replace(request, window=QueryWindow(first_event=1)),
            (TargetPair('out', request.target, request.target),),
        )
    report = compare_runs(TraceRun.open(small_run(tmp_path)), PairRequest(request))
    with pytest.raises(TraceError):
        replace(report, comparison_status='matched')


def test_ambiguous_coordinate_in_report_is_rejected(tmp_path: Path) -> None:
    """即使手工报告通过基本模型校验，重复映射坐标也不能任意选择一个值。"""
    first = execute(small_run(tmp_path))
    duplicate = replace(first.nodes[0], id='duplicate-node')
    corrupted = replace(first, nodes=(*first.nodes, duplicate), status=StatusAxes(query='complete'))
    with pytest.raises(TraceError) as caught:
        _compare_reports(first, corrupted, _maps(first, corrupted))
    assert caught.value.code == StopCode.DUPLICATE_IDENTITY
