"""小型独立状态验证来源边、保存值校验、停止边界与请求隔离。"""

from __future__ import annotations

import hashlib
import importlib
import json
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from pyk.kore.parser import KoreParser
from pyk.kore.prelude import SORT_K_ITEM, inj, list_pattern, map_pattern
from pyk.kore.syntax import DV, App, SortApp, String

from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.kore import BITS
from kcirct.trace.model import (
    ArtifactRef,
    BitRange,
    BitVector,
    Budget,
    CheckRecord,
    CheckSource,
    CompletionEvidence,
    Observation,
    QueryRequest,
    QueryWindow,
    RunManifest,
    StateIndexEntry,
    StopCode,
    Target,
    TraceError,
)
from kcirct.trace.query import _Query, query
from kcirct.trace.semantics import SemanticsProfile, bind_semantics
from kcirct.trace.topology import TraceTopology

if TYPE_CHECKING:
    from pyk.kore.syntax import Pattern

    from kcirct.trace.model import TraceReport

FIXTURE = Path(__file__).parents[1] / 'resources/trace/unit/minimal-state.kore'
# 只用于测试非公共执行器。公开 query 对这些未绑定定义必须拒绝解释。
PROFILE = SemanticsProfile('synthetic-test-rules', 'synthetic-test-definition', False, 'unit_test_only')


def item(value: str, sort: str = 'String') -> Pattern:
    """将指定 sort 的域值注入 KItem，构造独立 KORE 夹具需要的原子项。"""
    source = SortApp('Sort' + sort)
    return inj(source, SORT_K_ITEM, DV(source, String(value)))


def bits(value: int, width: int = 8) -> Pattern:
    """按值与位宽构造原生 Bits term，保存用例给定的精确整数值。"""
    return App(BITS, args=(DV(SortApp('SortInt'), String(str(value))), DV(SortApp('SortInt'), String(str(width)))))


def types(*widths: int) -> Pattern:
    """将给定整数位宽按输入顺序编码为 StdFT 使用的 Types 链表。"""
    result = App(
        "Lbl'Stop'List'LBraQuotUndsCommUndsUnds'MLIR-SYNTAX'Unds'Types'Unds'Type'Unds'Types'QuotRBraUnds'Types"
    )
    for width in reversed(widths):
        result = App(
            "Lbl'UndsCommUndsUnds'MLIR-SYNTAX'Unds'Types'Unds'Type'Unds'Types",
            args=(item(f'i{width}', 'SignlessIntegerType'), result),
        )
    return result


def op(name: str, operands: tuple[str, ...], widths: tuple[int, ...], output: int = 8, **attributes: int) -> Pattern:
    """构造带字符串操作数、整数属性和单整数返回类型的 StdOp 夹具。"""
    return App(
        "Lbl'UndsLParUndsRParLBraUndsRBraColnUndsUnds'MLIR-HELPER-SYNTAX'Unds'StdOp'Unds'String'Unds'List'Unds'Map'Unds'StdFT",
        args=(
            item(name),
            list_pattern(*(item(signal) for signal in operands)),
            map_pattern(*((item(key), item(str(value), 'Int')) for key, value in attributes.items())),
            App(
                "Lbl'LParUndsRPar'-'-GT-LParUndsRParUnds'MLIR-SYNTAX'Unds'StdFT'Unds'Types'Unds'Types",
                args=(types(*widths), types(output)),
            ),
        ),
    )


def state_text(replacements: dict[str, Pattern]) -> str:
    """替换最小状态夹具中指定 cell 的内容，保留其他配置并序列化为 KORE。"""
    root = KoreParser(FIXTURE.read_text()).pattern()

    def change(node: Pattern) -> Pattern:
        """在自底向上遍历中替换命中的 cell 内容，同时保留该 cell 的原始标签。"""
        if isinstance(node, App):
            for name, value in replacements.items():
                if node.symbol == "Lbl'-LT-'" + name + "'-GT-'":
                    return App(node.symbol, args=(value,))
        return node

    return root.bottom_up(change).text


def artifact(path: Path, root: Path, role: str = 'state') -> ArtifactRef:
    """依据实际文件字节构造相对路径、角色、哈希和长度齐备的工件引用。"""
    return ArtifactRef(
        role, path.relative_to(root).as_posix(), hashlib.sha256(path.read_bytes()).hexdigest(), path.stat().st_size
    )


def publish(root: Path, texts: list[str], *, run_id: str = 'small-run', evaluations: int = 1) -> Path:
    """将 setup 和后续状态写成可读取运行，建立连续前驱、求值位置、哈希及 manifest。"""
    root.mkdir(exist_ok=True)
    artifacts = {}
    entries: list[StateIndexEntry] = []
    for index, text in enumerate(texts):
        name = 'setup' if index == 0 else f'state{index}'
        path = root / f'{name}.kore'
        path.write_text(text)
        artifacts[name] = artifact(path, root)
        entries.append(
            StateIndexEntry(
                name,
                'setup' if index == 0 else 'post_eval',
                predecessor=entries[-1].state_id if entries else None,
                event_index=(index - 1) // evaluations if index else None,
                evaluation=(index - 1) % evaluations + 1 if index else None,
                artifact=name,
                content_sha256=artifacts[name].sha256,
                retention='retained',
                completion=CompletionEvidence('completed'),
            )
        )
    index_path = root / 'trace-states.jsonl'
    index_path.write_text(''.join(json.dumps(entry.to_dict()) + '\n' for entry in entries))
    manifest = RunManifest(
        run_id,
        'Demo',
        artifacts=artifacts,
        state_index=artifact(index_path, root, 'state_index'),
        protocol={'evaluations_per_input': evaluations},
    )
    path = root / 'trace-run.json'
    path.write_text(manifest.to_json())
    return path


def small_run(
    root: Path,
    *,
    selector: int = 1,
    other: int = 99,
    wrong: bool = False,
    missing: bool = False,
    cycle: bool = False,
    unknown: bool = False,
) -> Path:
    """构造 mux 加输出别名的小运行，可独立注入错值、缺值、环和未知操作。"""
    selected = 7 if selector else other
    signals = {
        'Demo/%a': bits(7),
        'Demo/%select': bits(selector, 1),
        'Demo/%other': bits(other),
        'Demo/%mux': bits(selected),
        'Demo/%r': bits(123 if wrong else selected),
    }
    if missing:
        del signals['Demo/%r']
    connections = {
        'Demo/%r': item('Demo/%mux'),
        'Demo/%mux': (
            item('Demo/%r')
            if cycle
            else op('future.op' if unknown else 'comb.mux', ('Demo/%select', 'Demo/%a', 'Demo/%other'), (1, 8, 8))
        ),
        'Demo/%select': op('hw.constant', (), (), 1, value=selector),
        'Demo/%other': op('hw.constant', (), (), value=other),
    }
    replacements = {
        'connection': map_pattern(*((item(name), value) for name, value in connections.items())),
        'register': map_pattern(),
        'register-proc': map_pattern(),
        'procedures': list_pattern(),
        'signals': map_pattern(*((item(name), value) for name, value in signals.items())),
        'history': map_pattern(*((item(name), value) for name, value in signals.items())),
    }
    return publish(root, [state_text(replacements), state_text(replacements)])


def execute(
    path: Path, *, budget: Budget | None = None, target: str = 'Demo/result', window: QueryWindow | None = None
) -> TraceReport:
    """用合成测试规则执行首个求值状态的信号查询，透传预算与事件窗口。"""
    request = QueryRequest(
        Target('signal', name=target),
        Observation('post_eval', state_id='state1', evaluation=1),
        budget=budget or Budget(),
        window=window or QueryWindow(),
    )
    with RunArtifacts.open(path, budget=request.budget) as run:
        topology = TraceTopology.from_run(run)
        return _Query(run, request, topology, PROFILE).execute(topology.resolve(request.target))


def test_saved_values_actual_mux_and_candidate_edges(tmp_path: Path) -> None:
    """验证来源图区分别名、控制、选中数据及未展开候选，并保留保存值和核验工件。"""
    report = execute(small_run(tmp_path))
    assert report.status.query == 'complete'
    assert report.status.design_check == 'not_run'
    nodes = {node.id: node for node in report.nodes}
    assert report.nodes[0].value is not None and report.nodes[0].value.unsigned == 7
    assert {edge.kind for edge in report.edges} == {'alias', 'control', 'data', 'static_candidate'}
    candidate = next(nodes[edge.source] for edge in report.edges if edge.kind == 'static_candidate')
    assert candidate.ref.result == 'Demo/%other'
    assert candidate.value is None and candidate.facts == {'static_candidate': True}
    assert not any(edge.target == candidate.id for edge in report.edges)
    assert report.scope['semantics_binding'] == 'unit_test_only'
    assert report.artifacts


def test_selector_and_unused_input_variants_are_independent(tmp_path: Path) -> None:
    """验证未选输入变化不影响结果，selector 切换影响结果，重复查询也不互相污染。"""
    first = execute(small_run(tmp_path / 'first', other=17))
    second = execute(small_run(tmp_path / 'second', other=28))
    changed = execute(small_run(tmp_path / 'changed', selector=0, other=28))
    assert first.nodes[0].value == second.nodes[0].value
    assert changed.nodes[0].value is not None and changed.nodes[0].value.unsigned == 28
    assert all(report.status.query == 'complete' for report in (first, second, changed))
    again = execute(tmp_path / 'first/trace-run.json')
    assert first.nodes == again.nodes and first.edges == again.edges


@pytest.mark.parametrize(
    ('options', 'code', 'status'),
    [
        ({'wrong': True}, StopCode.INCONSISTENT_EVIDENCE, 'rejected'),
        ({'missing': True}, StopCode.MISSING_VALUE, 'partial'),
        ({'cycle': True}, StopCode.CYCLE, 'partial'),
        ({'unknown': True}, StopCode.UNSUPPORTED_OPERATION, 'partial'),
    ],
)
def test_saved_missing_mismatch_cycle_and_unknown(
    tmp_path: Path, options: dict[str, bool], code: StopCode, status: str
) -> None:
    """验证错值、缺值、依赖环和未知操作各自生成准确的查询状态及停止码。"""
    report = execute(small_run(tmp_path, **options))
    assert report.status.query == status
    assert code in {item.reason.code for item in report.frontier}
    if options.get('wrong'):
        assert report.nodes[0].value is not None and report.nodes[0].value.unsigned == 123


def test_node_and_state_budgets_keep_frontier(tmp_path: Path) -> None:
    """验证节点或状态预算耗尽后保留已有图和明确停止边界。"""
    path = small_run(tmp_path)
    report = execute(path, budget=Budget(max_nodes=2))
    assert report.status.query == 'partial'
    assert len(report.nodes) == 2
    assert StopCode.NODE_BUDGET in {item.reason.code for item in report.frontier}
    state_limited = execute(path, budget=Budget(max_states=1))
    assert StopCode.STATE_BUDGET in {item.reason.code for item in state_limited.frontier}


def test_window_does_not_explain_outside_observation(tmp_path: Path) -> None:
    """验证观测位置位于请求窗口外时直接留下窗口停止原因。"""
    report = execute(small_run(tmp_path), window=QueryWindow(first_event=1))
    assert report.status.query == 'partial'
    assert report.frontier[0].reason.code == StopCode.WINDOW_BOUNDARY


def test_public_query_does_not_trust_same_operation_names(tmp_path: Path) -> None:
    """验证公开查询拒绝没有源码身份绑定的合成规则，即使操作名称已知。"""
    path = small_run(tmp_path)
    request = QueryRequest(
        Target('signal', name='Demo/result'), Observation('post_eval', state_id='state1', evaluation=1)
    )
    with RunArtifacts.open(path) as run:
        report = query(run, request)
    assert report.status.query == 'partial'
    assert not report.nodes
    assert report.frontier[0].reason.code == StopCode.UNSUPPORTED_SEMANTICS


def test_query_does_not_change_original_artifacts(tmp_path: Path) -> None:
    """验证执行查询前后所有原始运行文件的内容哈希保持一致。"""
    path = small_run(tmp_path)
    before = {file.name: hashlib.sha256(file.read_bytes()).hexdigest() for file in tmp_path.iterdir()}
    execute(path)
    assert before == {file.name: hashlib.sha256(file.read_bytes()).hexdigest() for file in tmp_path.iterdir()}


def test_deadline_keeps_explicit_reason(tmp_path: Path) -> None:
    """验证执行器截止时间已过时仍通过报告返回明确的超时停止码。"""
    path = small_run(tmp_path)
    request = QueryRequest(
        Target('signal', name='Demo/result'), Observation('post_eval', state_id='state1', evaluation=1)
    )
    with RunArtifacts.open(path) as run:
        topology = TraceTopology.from_run(run)
        engine = _Query(run, request, topology, PROFILE)
        engine.deadline = 0
        report = engine.execute(topology.resolve(request.target))
    assert report.frontier[0].reason.code == StopCode.TIME_BUDGET


def test_source_identity_cannot_be_asserted_by_status_field(tmp_path: Path) -> None:
    """验证 manifest 自称 verified 不能替代语义源码与编译定义的实际身份核验。"""
    path = small_run(tmp_path)
    manifest = RunManifest.from_json(path.read_text())
    path.write_text(replace(manifest, identities={'semantics_binding': {'status': 'verified'}}).to_json())
    request = QueryRequest(
        Target('signal', name='Demo/result'), Observation('post_eval', state_id='state1', evaluation=1)
    )
    with RunArtifacts.open(path) as run:
        assert query(run, request).frontier[0].reason.code == StopCode.UNSUPPORTED_SEMANTICS


def test_bit_range_keeps_full_value_source(tmp_path: Path) -> None:
    """验证切片根节点返回正确位值，并继续连接到同一信号的完整值来源。"""
    path = small_run(tmp_path)
    request = QueryRequest(
        Target('signal', name='Demo/result', bit_range=BitRange(1, 3)),
        Observation('post_eval', state_id='state1', evaluation=1),
    )
    with RunArtifacts.open(path) as run:
        topology = TraceTopology.from_run(run)
        report = _Query(run, request, topology, PROFILE).execute(topology.resolve(request.target))
    assert report.status.query == 'complete'
    assert report.nodes[0].value == BitVector.from_int(3, 3)
    assert report.nodes[0].ref.bit_range == BitRange(1, 3)
    assert any(node.ref.result == 'Demo/%r' and node.ref.bit_range is None for node in report.nodes)


def test_normalized_check_matches_short_observation_and_alias(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """验证检查和查询使用不同位置写法及目标别名时，规范化后仍能绑定同一观察。"""
    path = small_run(tmp_path)
    query_module = importlib.import_module('kcirct.trace.query')
    monkeypatch.setattr(query_module, 'bind_semantics', lambda run: PROFILE)
    check = CheckRecord(
        'failure',
        'small-run',
        'value_mismatch',
        (Target('signal', name='Demo/result'),),
        Observation('post_eval', event_index=0, evaluation=1),
        CheckSource('csv'),
        expected=BitVector.from_int(2, 8),
        actual=BitVector.from_int(7, 8),
    )
    request = QueryRequest(Target('signal', name='Demo/%r'), Observation('post_eval', state_id='state1', evaluation=1))
    with RunArtifacts.open(path) as run:
        report = query(run, request, check=check)
    assert report.status.query == 'complete'
    assert report.status.design_check == 'failed'
    assert report.status.reference_comparison == 'not_run'


def _test_profile_bundle(path: Path, monkeypatch: pytest.MonkeyPatch, *, legacy: bool = False) -> None:
    """构造受测试替换规则表认可的源码与定义工件；legacy 模式额外写入伪造历史构建记录。"""
    source, definition = path.parent / 'rules.md', path.parent / 'definition.kore'
    source.write_text('independent test rule identity')
    definition.write_text('independent test definition identity')
    source_ref = artifact(source, path.parent, 'semantics_source')
    definition_ref = artifact(definition, path.parent, 'compiled_definition')
    hashes = {'rules.md': source_ref.sha256}
    digest = hashlib.sha256(json.dumps(hashes, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
    monkeypatch.setattr('kcirct.trace.semantics._PROFILES', {digest: (definition_ref.sha256, not legacy)})
    manifest = RunManifest.from_json(path.read_text())
    artifacts = dict(manifest.artifacts, **{'semantics/rules.md': source_ref})
    if not legacy:
        artifacts['definition/definition.kore'] = definition_ref
    else:
        for key in ('legacy_versions', 'legacy_prepared'):
            forged = path.parent / (key + '.json')
            forged.write_text(json.dumps({'semantics_hashes': hashes, 'definition_sha256': definition_ref.sha256}))
            artifacts[key] = artifact(forged, path.parent, key)
    path.write_text(replace(manifest, artifacts=artifacts, identities={'semantics_hashes': hashes}).to_json())


def test_profile_requires_actual_source_and_compiled_bytes(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """验证真实源码及定义可绑定解释器，源码内容随后变化会触发哈希冲突。"""
    path = small_run(tmp_path)
    _test_profile_bundle(path, monkeypatch)
    with RunArtifacts.open(path) as run:
        assert bind_semantics(run).binding == 'source_and_definition_verified'
    (tmp_path / 'rules.md').write_text('modified rule')
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as caught:
        bind_semantics(run)
    assert caught.value.code == StopCode.HASH_MISMATCH


def test_forged_original_build_records_are_not_provenance(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """验证内容看似一致的伪造历史构建记录不能替代受认可的原始来源记录。"""
    path = small_run(tmp_path)
    _test_profile_bundle(path, monkeypatch, legacy=True)
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as caught:
        bind_semantics(run)
    assert caught.value.code == StopCode.UNSUPPORTED_SEMANTICS
