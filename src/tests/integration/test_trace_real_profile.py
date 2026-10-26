"""真实 K 状态上的独立值、选边和时序预期；候选核验不修改生产允许列表。"""

from __future__ import annotations

import hashlib
import json
import os
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from kcirct._simulate import simulate
from kcirct.trace import TraceRun
from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.model import Budget, Observation, QueryRequest, QueryWindow, StopCode, Target
from kcirct.trace.query import _Query
from kcirct.trace.semantics import SemanticsProfile
from kcirct.trace.topology import TraceTopology

if TYPE_CHECKING:
    from kcirct.trace.model import TraceReport

RESOURCE = Path(__file__).parents[1] / 'resources/trace/profile-v2'
SOURCE_SHA = '2a82d12ea2e894e400629d3c6c7b3210fc4b68717f21a3dcf672f0a8b52a8db3'
CANDIDATE_SHA = 'bbe16518aa6f44ad80eb002f9efd10ddaf1c3d86f717af208b85b33e66a6a1e8'


def run_design(root: Path, name: str, top: str, inputs: list[dict[str, int]]) -> Path:
    """用显式环境中的真实 K 定义运行固定输入；缺环境时明确 skip。"""
    definition = os.getenv('KCIRCT_TRACE_DEFINITION_DIR')
    parser = os.getenv('KCIRCT_TRACE_PARSER')
    if not definition or not parser:
        pytest.skip('需要显式真实 K definition 与 parser；skip 不是验收通过')
    input_path = root / 'inputs.json'
    input_path.write_text(
        json.dumps(
            {
                'schema_version': 1,
                'timescale': '1ns',
                'events': [{'time': index, 'inputs': values} for index, values in enumerate(inputs)],
            }
        )
    )
    result = simulate(
        RESOURCE / f'{name}.generic.mlir',
        top_module=top,
        inputs_file=input_path,
        work_dir=root / 'run',
        output=root / 'output.vcd',
        definition_dir=Path(definition),
        parser=Path(parser),
        keep_states=True,
    )
    (root / 'simulation-result.json').write_text(json.dumps(result, indent=2, default=str))
    assert result['status'] == 'pass', result
    assert result['events_completed'] == len(inputs)
    assert result['simulation_calls'] == 2 * len(inputs)
    return root / 'run/trace-run.json'


def query(
    path: Path,
    target: Target,
    event: int,
    evaluation: int = 1,
    *,
    window: QueryWindow | None = None,
    budget: Budget | None = None,
    status: str = 'complete',
) -> TraceReport:
    """正常模式用公开入口；资格检查模式只在测试内显式使用固定候选身份。"""
    request = QueryRequest(
        target,
        Observation('post_eval', event_index=event, evaluation=evaluation),
        window=window or QueryWindow(),
        budget=budget or Budget(),
    )
    if os.getenv('KCIRCT_TRACE_QUALIFY_CANDIDATE') != CANDIDATE_SHA:
        report = TraceRun.open(path).query(request)
    else:
        # 该开关仅属于测试程序，不是生产绕过路径。逐份核验全部源码和 definition 原字节。
        with RunArtifacts.open(path, budget=request.budget) as run:
            hashes = run.manifest.identities['semantics_hashes']
            digest = hashlib.sha256(json.dumps(hashes, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
            assert digest == SOURCE_SHA
            for name, expected in hashes.items():
                artifact = run.verify_artifact('semantics/' + name)
                assert hashlib.sha256(artifact.read_bytes()).hexdigest() == expected
            definition = run.verify_artifact('definition/definition.kore')
            assert hashlib.sha256(definition.read_bytes()).hexdigest() == CANDIDATE_SHA
            topology = TraceTopology.from_run(run)
            profile = SemanticsProfile(SOURCE_SHA, CANDIDATE_SHA, True, 'candidate_qualification_only')
            report = _Query(run, request, topology, profile).execute(topology.resolve(target))
    output = path.parent.parent / 'reports'
    output.mkdir(exist_ok=True)
    key = hashlib.sha256(request.to_json().encode()).hexdigest()[:16]
    (output / f'{key}.json').write_text(report.to_json())
    assert report.status.query == status, report.to_json()
    return report


def incoming(report: TraceReport, result: str, kind: str, state_id: str | None = None) -> set[str]:
    """读取报告中给定目标的直接边，不调用被测解释器生成预期。"""
    nodes = {node.id: node for node in report.nodes}
    return {
        nodes[edge.source].ref.result
        for edge in report.edges
        if edge.kind == kind
        and nodes[edge.target].ref.result == result
        and (state_id is None or nodes[edge.target].ref.state_id == state_id)
    }


def test_real_comb_values_and_mux_selected_edges(tmp_path: Path) -> None:
    """独立整数公式检查真实值；相同数据值仍须按 selector 区分来源。"""
    inputs = [
        {'a': 255, 'b': 1, 'sel': 0},
        {'a': 128, 'b': 7, 'sel': 1},
        {'a': 3, 'b': 3, 'sel': 0},
        {'a': 3, 'b': 3, 'sel': 1},
        {'a': 0, 'b': 8, 'sel': 1},
    ]
    path = run_design(tmp_path, 'comb', 'ProfileComb', inputs)
    for event, values in enumerate(inputs):
        a, b, sel = values['a'], values['b'], values['sel']
        expected = {
            'sum': (a + b) & 255,
            'bits_and': a & b,
            'bits_or': a | b,
            'bits_xor': a ^ b,
            'left': (a << b) & 255,
            'right': a >> b,
            'joined': (a << 8) | b,
            'slice': (a >> 3) & 15,
            'equal': int(a == b),
            'selected': a if sel else b,
        }
        for output, value in expected.items():
            report = query(path, Target('signal', name='ProfileComb/' + output), event, 2)
            assert report.nodes[0].value is not None
            assert report.nodes[0].value.unsigned == value
            internal = {'bits_and': 'and', 'bits_or': 'or', 'bits_xor': 'xor'}.get(output, output)
            assert report.nodes[0].ref.result == f'ProfileComb/%{internal}'
            if output != 'selected':
                assert incoming(report, f'ProfileComb/%{internal}', 'data') == (
                    {'ProfileComb/%a'} if output == 'slice' else {'ProfileComb/%a', 'ProfileComb/%b'}
                )
                assert incoming(report, f'ProfileComb/%{internal}', 'control') == set()
            if output == 'selected':
                assert incoming(report, 'ProfileComb/%selected', 'control') == {'ProfileComb/%sel'}
                assert incoming(report, 'ProfileComb/%selected', 'data') == {
                    'ProfileComb/%a' if sel else 'ProfileComb/%b'
                }
                assert incoming(report, 'ProfileComb/%selected', 'static_candidate') == {
                    'ProfileComb/%b' if sel else 'ProfileComb/%a'
                }


def test_real_register_event_table_and_same_value_capture(tmp_path: Path) -> None:
    """固定事件表区分 preset、无沿保持、同值捕获、同步 reset 与两次求值。"""
    rows = [
        (0, 0, 1, 9, 2, 7, 'no_edge_hold'),
        (1, 0, 1, 9, 2, 9, 'capture_next'),
        (0, 0, 0, 5, 9, 9, 'no_edge_hold'),
        (1, 0, 0, 5, 9, 9, 'capture_next'),
        (0, 1, 1, 6, 4, 9, 'no_edge_hold'),
        (1, 1, 1, 6, 4, 0, 'capture_reset'),
        (0, 0, 1, 3, 4, 0, 'no_edge_hold'),
        (1, 0, 1, 3, 4, 3, 'capture_next'),
    ]
    inputs = [dict(zip(('clk', 'reset', 'sel', 'a', 'b'), row[:5], strict=True)) for row in rows]
    path = run_design(tmp_path, 'register', 'ProfileRegister', inputs)
    old = 7
    for event, row in enumerate(rows):
        report = query(path, Target('register', name='ProfileRegister/q'), event)
        root = report.nodes[0]
        assert root.value is not None and root.value.unsigned == row[5]
        assert root.facts['decision'] == row[6]
        assert root.facts['old']['value'] == str(old)
        sid = f'event-{event}.eval-1'
        if row[6] == 'capture_next':
            assert incoming(report, 'ProfileRegister/%q', 'capture', sid) == {'ProfileRegister/%next'}
        elif row[6] == 'capture_reset':
            assert incoming(report, 'ProfileRegister/%q', 'capture', sid) == {'ProfileRegister/%zero'}
        else:
            assert incoming(report, 'ProfileRegister/%q', 'capture', sid) == set()
        assert 'ProfileRegister/%clock' in incoming(report, 'ProfileRegister/%q', 'control', sid)
        assert incoming(report, 'ProfileRegister/%clock', 'data', sid) == {'ProfileRegister/%clk'}
        second = query(path, Target('register', name='ProfileRegister/q'), event, 2)
        assert second.nodes[0].facts['decision'] == 'no_edge_hold'
        assert second.nodes[0].value is not None and second.nodes[0].value.unsigned == row[5]
        predecessors = [
            node
            for node in second.nodes
            if node.ref.result == 'ProfileRegister/%q' and node.ref.view == 'committed' and node.ref.state_id == sid
        ]
        assert predecessors, '第二次求值必须追到同事件的第一次求值，不能跳到上一输入事件'
        old = row[5]


def test_real_memory_scoreboard_same_value_disabled_other_address(tmp_path: Path) -> None:
    """独立写事件表覆盖同值写、disabled、其他地址写与地址边界。"""
    rows = [
        (0, 0, 2, 0),
        (1, 1, 2, 17),
        (0, 0, 2, 0),
        (1, 1, 2, 17),
        (0, 0, 2, 0),
        (1, 0, 2, 99),
        (0, 0, 2, 0),
        (1, 1, 3, 42),
        (0, 0, 2, 0),
        (1, 1, 0, 5),
        (0, 0, 2, 0),
    ]
    reads = [1, 2, 3, 2, 0, 2, 3, 3, 1, 0, 2]
    inputs = [
        {'clk': clk, 'enable': enable, 'address': address, 'data': data, 'read_address': read_address}
        for (clk, enable, address, data), read_address in zip(rows, reads, strict=True)
    ]
    path = run_design(tmp_path, 'memory', 'ProfileMemory', inputs)
    scoreboard = [0, 0, 0, 0]
    last_write: dict[int, int] = {}
    for event, (clk, enable, address, data) in enumerate(rows):
        if clk and enable:
            scoreboard[address] = data
            last_write[address] = event
        for cell in (0, 2, 3):
            report = query(path, Target('memory_cell', name='ProfileMemory/memory', address=str(cell)), event)
            assert report.nodes[0].value is not None and report.nodes[0].value.unsigned == scoreboard[cell]
            nodes = {node.id: node for node in report.nodes}
            updates = [
                nodes[edge.source]
                for edge in report.edges
                if edge.kind == 'write'
                and nodes[edge.target].ref.result == 'ProfileMemory/%mem'
                and nodes[edge.target].ref.address == str(cell)
            ]
            if cell in last_write:
                assert updates
                assert updates[0].ref.state_id == f'event-{last_write[cell]}.eval-1'
                write = updates[0]
                assert incoming(report, write.ref.result, 'control', write.ref.state_id) == {
                    'ProfileMemory/%clock',
                    'ProfileMemory/%enable',
                }
                assert incoming(report, write.ref.result, 'data', write.ref.state_id) == {
                    'ProfileMemory/%address',
                    'ProfileMemory/%data',
                }
            else:
                assert not updates
        if clk and enable and reads[event] == address:
            ambiguous = query(path, Target('signal', name='ProfileMemory/result'), event, status='partial')
            assert any(item.reason.code == StopCode.UNSUPPORTED_MEMORY_ORDER for item in ambiguous.frontier)
        # 同次同址读写只验证明确拒绝；第二次求值无新时钟沿，RL0读已提交scoreboard。
        read = query(path, Target('signal', name='ProfileMemory/result'), event, 2)
        assert read.nodes[0].value is not None and read.nodes[0].value.unsigned == scoreboard[reads[event]]
        assert incoming(read, 'ProfileMemory/%read', 'data') == {'ProfileMemory/%read_address', 'ProfileMemory/%mem'}


def test_real_multiply_and_replicate_integer_values_and_data_edges(tmp_path: Path) -> None:
    """64位模乘及比特复制的独立整数/字符串预期，所有实际输入仍保留数据边。"""
    mask = (1 << 64) - 1
    inputs = [
        {'a': 0, 'b': mask, 'bit': 0, 'nibble': 0},
        {'a': mask, 'b': mask, 'bit': 1, 'nibble': 15},
        {'a': 1 << 63, 'b': 2, 'bit': 0, 'nibble': 8},
        {'a': 0x123456789ABCDEF0, 'b': 0x100000001, 'bit': 1, 'nibble': 5},
        {'a': 1, 'b': 1, 'bit': 1, 'nibble': 1},
    ]
    path = run_design(tmp_path, 'arithmetic', 'ProfileArithmetic', inputs)
    for event, values in enumerate(inputs):
        expected = {
            'product': (values['a'] * values['b']) & mask,
            'triple': (values['a'] * values['b'] * 3) & mask,
            'extended': mask if values['bit'] else 0,
            'tiled': int(f"{values['nibble']:04b}" * 4, 2),
        }
        for name, value in expected.items():
            report = query(path, Target('signal', name='ProfileArithmetic/' + name), event, 2)
            assert report.nodes[0].value is not None and report.nodes[0].value.unsigned == value
            sources = {
                'product': {'a', 'b'},
                'triple': {'a', 'b', 'three'},
                'extended': {'bit'},
                'tiled': {'nibble'},
            }[name]
            assert incoming(report, 'ProfileArithmetic/%' + name, 'data') == {
                'ProfileArithmetic/%' + source for source in sources
            }
            assert not incoming(report, 'ProfileArithmetic/%' + name, 'control')


def test_real_history_and_node_budget_preserve_partial_frontier(tmp_path: Path) -> None:
    """真实状态查询的窗口和资源边界不能误作初态或返回完整解释。"""
    inputs = [{'clk': clk, 'reset': 0, 'sel': 1, 'a': 9, 'b': 2} for clk in (0, 1, 0, 1)]
    path = run_design(tmp_path, 'register', 'ProfileRegister', inputs)
    target = Target('register', name='ProfileRegister/q')
    window = query(path, target, 3, window=QueryWindow(3, 3), status='partial')
    assert any(item.reason.code == StopCode.WINDOW_BOUNDARY for item in window.frontier)
    limited = query(path, target, 3, budget=Budget(max_nodes=1), status='partial')
    assert any(item.reason.code == StopCode.NODE_BUDGET for item in limited.frontier)


def test_real_mux_oracle_rejects_missing_control_and_wrong_selected_source(tmp_path: Path) -> None:
    """在真实同值MUX报告上植入错误夹具，确认值吻合不能掩盖缺控制或选边错误。"""
    path = run_design(tmp_path, 'comb', 'ProfileComb', [{'a': 3, 'b': 3, 'sel': 1}])
    report = query(path, Target('signal', name='ProfileComb/selected'), 0, 2)

    def verify(observed: TraceReport) -> None:
        """独立预期由刺激selector=1决定，不通过待测解释器重算。"""
        assert incoming(observed, 'ProfileComb/%selected', 'control') == {'ProfileComb/%sel'}
        assert incoming(observed, 'ProfileComb/%selected', 'data') == {'ProfileComb/%a'}
        assert incoming(observed, 'ProfileComb/%selected', 'static_candidate') == {'ProfileComb/%b'}

    verify(report)
    no_control = replace(report, edges=tuple(edge for edge in report.edges if edge.kind != 'control'))
    with pytest.raises(AssertionError):
        verify(no_control)
    wrong_source = replace(
        report,
        edges=tuple(
            (
                replace(edge, kind='static_candidate' if edge.kind == 'data' else 'data')
                if edge.kind in {'data', 'static_candidate'}
                else edge
            )
            for edge in report.edges
        ),
    )
    with pytest.raises(AssertionError):
        verify(wrong_source)
