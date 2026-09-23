"""用已有静态图验证旧查询兼容；不运行 K，也不改写 resources。

原交互脚本引用的 simulated.0.kore 未归档，故这里仅验证保存的静态事实。
真实 Kore 建图与新动态门面的联合验收由独立集成测试负责。
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from kcirct.err_trace import KErrTrace
from kcirct.trace import TraceRun
from kcirct.trace.model import ArtifactRef, CompletionEvidence, RunManifest, StateIndexEntry

_FIXTURES = Path(__file__).resolve().parents[1] / 'resources' / 'error_trace_test'


def _saved_graph() -> KErrTrace:
    """每次从只读 fixture 加载一份独立静态图，防止查询注记在测试之间残留。"""
    trace = KErrTrace()
    trace.load_from_json(_FIXTURES / 'err_trace.json')
    return trace


def test_saved_static_graph_round_trip(tmp_path: Path) -> None:
    """验证既有静态图的节点属性和连接可无损另存，原始 fixture 的内容保持不变。"""
    original = _FIXTURES / 'err_trace.json'
    before = hashlib.sha256(original.read_bytes()).hexdigest()
    trace = _saved_graph()
    copied = tmp_path / 'graph.json'
    trace.save_to_json(copied)

    assert len(trace.node_map) == 30
    assert len(trace.edge_map) == 114
    assert trace.node_map['Foo/%20'].is_firreg
    assert trace.node_map['Foo/%21'].is_firmem
    assert trace.node_map['Foo/i0/%0'].is_constant
    assert json.loads(copied.read_text()) == json.loads(original.read_text())
    assert hashlib.sha256(original.read_bytes()).hexdigest() == before


def test_saved_hierarchical_query_matches_legacy_output(tmp_path: Path) -> None:
    """验证层次化 K 名称查询仍输出既有节点顺序、深度和常量标记。"""
    trace = _saved_graph()
    output = tmp_path / 'hierarchy.txt'
    trace.search_path_kname('Foo/i0/%arg0', output)

    assert output.read_bytes() == (_FIXTURES / 'test1k.output').read_bytes()
    assert output.read_text().splitlines() == [
        'Foo/i0/%arg0 size: 4',
        'depth:0   Foo/i0/%arg0',
        'is constant :depth:1   Foo/i0/%0',
        'depth:1   Foo/%arg1',
        'depth:2   Foo/%arg2',
    ]


def test_saved_vcd_alias_query_matches_k_query(tmp_path: Path) -> None:
    """验证 VCD 层次名称经别名映射后得到与旧 K 名称查询相同的输出。"""
    trace = _saved_graph()
    # 此别名来自 fixture 中 AddOne 的 io_a 参数与 Foo/i0 实例。
    trace.signal_port_mapping['Foo/i0/io_a'] = 'Foo/i0/%arg0'
    output = tmp_path / 'vcd-name.txt'
    trace.search_path_vcdname('Foo.i0.io_a', output)

    assert output.read_bytes() == (_FIXTURES / 'test1vcd.output').read_bytes()


def test_saved_difference_list_runs_without_input_or_overwriting_outputs(tmp_path: Path) -> None:
    """按保存的差异列表逐项查询，验证无需交互输入且各项结果写入独立文件。"""
    trace = _saved_graph()
    trace.differenes.extend((_FIXTURES / 'differencesnameK.txt').read_text().splitlines())
    assert trace.differenes == ['Foo/i0/%arg0', 'Foo/%8']
    outputs = []
    for index, target in enumerate(trace.differenes):
        output = tmp_path / f'difference-{index}.txt'
        trace.search_path_kname(target, output)
        outputs.append(output)

    assert outputs[0].read_text().startswith('Foo/i0/%arg0 size: 4\nis defferenes : \n')
    assert outputs[1].read_bytes() == (_FIXTURES / 'testlistk.output').read_bytes()


def test_saved_memory_read_keeps_legacy_static_stop(tmp_path: Path) -> None:
    """验证旧读端口查询在存储节点停止，不把静态依赖扩展成实际写入历史。"""
    trace = _saved_graph()
    output = tmp_path / 'memory.txt'
    trace.search_path_kname('Foo/%22', output)

    assert output.read_text().splitlines() == [
        'Foo/%22 size: 4',
        'depth:0   Foo/%22',
        'is firmem :depth:1   Foo/%21',
        'is constant :depth:1   Foo/%2',
        'depth:1   Foo/%arg0',
    ]
    # 静态查询在存储处停止，不伪装成已解释某次实际写入。
    assert 'Foo/%10' not in output.read_text()


def test_real_kore_graph_and_public_target_queries_do_not_pollute_each_other(tmp_path: Path) -> None:
    """从已归档 Kore 建旧图并交错调用新门面，验证动态目标枚举不改变旧图查询结果。"""
    legacy_source = _FIXTURES.parent / 'modules' / 'adder' / 'expected' / 'setup.kore'
    graph = tmp_path / 'graph.json'
    legacy = KErrTrace()
    legacy.build_grapth(legacy_source, graph)
    assert (len(legacy.node_map), len(legacy.edge_map)) == (4, 12)

    source = _FIXTURES.parent / 'trace' / 'unit' / 'minimal-state.kore'
    run_dir = tmp_path / 'run'
    run_dir.mkdir()
    setup = run_dir / 'setup.kore'
    setup.write_bytes(source.read_bytes())
    setup_ref = ArtifactRef('state', setup.name, hashlib.sha256(setup.read_bytes()).hexdigest(), setup.stat().st_size)
    state = StateIndexEntry(
        'setup',
        'setup',
        artifact='setup',
        content_sha256=setup_ref.sha256,
        retention='retained',
        completion=CompletionEvidence('completed'),
    )
    index = run_dir / 'trace-states.jsonl'
    index.write_text(json.dumps(state.to_dict()) + '\n')
    index_ref = ArtifactRef(
        'state_index',
        index.name,
        hashlib.sha256(index.read_bytes()).hexdigest(),
        index.stat().st_size,
    )
    manifest = run_dir / 'trace-run.json'
    manifest.write_text(RunManifest('real-trace-setup', 'Demo', {'setup': setup_ref}, state_index=index_ref).to_json())

    before = tmp_path / 'before.txt'
    after = tmp_path / 'after.txt'
    legacy.search_path_kname('Adder/%0', before)
    targets = TraceRun.open(manifest).list_targets()
    legacy.search_path_kname('Adder/%0', after)
    assert before.read_bytes() == after.read_bytes()
    assert any('Demo/result' in target['aliases'] for target in targets)
    assert json.loads(graph.read_text())['nodes']['Adder/%0']['is_constant'] is False
