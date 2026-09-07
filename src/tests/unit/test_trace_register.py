"""独立保存值覆盖原生寄存器读取、提交条件、初始化和真实历史边界。"""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from pyk.kore.prelude import list_pattern, map_pattern
from pyk.kore.syntax import App

from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.kore import Term, _Node
from kcirct.trace.model import BitVector, Budget, Observation, QueryRequest, QueryWindow, StopCode, Target, TraceError
from kcirct.trace.query import _Query
from kcirct.trace.semantics import evaluate_comb, evaluate_posedge
from kcirct.trace.topology import TraceTopology

from .test_trace_comb import operation
from .test_trace_query import PROFILE, bits, item, op, publish, state_text

if TYPE_CHECKING:
    from pathlib import Path

    from pyk.kore.syntax import Pattern

    from kcirct.trace.model import TraceReport


def register_run(
    root: Path,
    steps: list[dict[str, int]],
    *,
    setup: dict[str, int] | None = None,
    reset: bool = False,
    feedback: bool = False,
    preset: int | None = None,
    asynchronous: bool = False,
    generated_clock: bool = False,
    boolean_next: bool | None = None,
    evaluations: int = 1,
) -> Path:
    attrs = {'preset': preset} if preset is not None else {}
    if asynchronous:
        attrs['isAsync'] = 1
    operands = ('Demo/%next', 'Demo/%clk', 'Demo/%reset', 'Demo/%rv') if reset else ('Demo/%next', 'Demo/%clk')
    widths = (8, 1, 1, 8) if reset else (8, 1)
    connections = {
        'Demo/%r': op('seq.firreg', operands, widths, **attrs),
        'Demo/%next': (
            op('comb.mux', ('Demo/%enable', 'Demo/%a', 'Demo/%r'), (1, 8, 8)) if feedback else item('Demo/%a')
        ),
        'Demo/%out': item('Demo/%r'),
        'Demo/%clk': op('comb.xor' if generated_clock else 'seq.to_clock', ('Demo/%c',), (1,), 1),
        'Demo/%rv': op('hw.constant', (), (), value=6),
    }
    if boolean_next is not None:
        constant = op('hw.constant', (), (), value=0)
        assert isinstance(constant, App)
        connections['Demo/%next'] = App(
            constant.symbol,
            args=(
                *constant.args[:2],
                map_pattern((item('value'), item(str(boolean_next).lower(), 'Bool'))),
                constant.args[3],
            ),
        )
    inputs = ('a', 'c', 'reset', 'enable')
    metadata = {
        'connection': map_pattern(*((item(name), value) for name, value in connections.items())),
        'register-proc': map_pattern(),
        'procedures': list_pattern(),
        'top-ins': list_pattern(*(item('Demo/%' + name) for name in inputs)),
        'hw-inputs': list_pattern(*(item(name, 'BareId') for name in inputs)),
        'hw-inports': list_pattern(*(item('Demo/%' + name) for name in inputs)),
        'hw-in-types': list_pattern(*(item('i8' if name == 'a' else 'i1', 'SignlessIntegerType') for name in inputs)),
        'hw-outports': list_pattern(item('Demo/%out'), item('Demo/%out')),
    }

    def expanded(values: dict[str, int]) -> dict[str, int]:
        if not values:
            return {}
        result = {'a': 0, 'c': 0, 'reset': 0, 'enable': 1, 'rv': 6}
        result.update(values)
        result.setdefault('clk', result['c'])
        result.setdefault('next', result['a'])
        return result

    previous = expanded(setup or {})
    texts = []
    for index, current in enumerate([previous] + [expanded(step) for step in steps]):
        current = dict(current)
        if index and 'out' not in current:
            current['out'] = previous.get('r', preset if preset is not None else 0)

        def values_cell(values: dict[str, int]) -> Pattern:
            return map_pattern(
                *(
                    (item('Demo/%' + name), bits(value, 1 if name in ('c', 'clk', 'reset', 'enable') else 8))
                    for name, value in values.items()
                )
            )

        texts.append(state_text(dict(metadata, signals=values_cell(current), history=values_cell(previous))))
        previous = current
    return publish(root, texts, evaluations=evaluations)


def execute(
    path: Path,
    index: int = 1,
    *,
    target: Target | None = None,
    window: QueryWindow | None = None,
    budget: Budget | None = None,
    preset_supported: bool = False,
) -> TraceReport:
    request = QueryRequest(
        target or Target('register', name='Demo/count'),
        Observation(
            'post_eval',
            state_id=f'state{index}',
            evaluation=json.loads((path.parent / 'trace-states.jsonl').read_text().splitlines()[index])['evaluation'],
        ),
        window=window or QueryWindow(),
        budget=budget or Budget(),
    )
    with RunArtifacts.open(path, budget=request.budget) as run:
        topology = TraceTopology.from_run(run)
        return _Query(run, request, topology, replace(PROFILE, preset_supported=preset_supported)).execute(
            topology.resolve(request.target)
        )


def decisions(report: TraceReport) -> list[str]:
    return [str(node.facts['decision']) for node in report.nodes if 'decision' in node.facts]


@pytest.mark.parametrize(
    ('steps', 'decision', 'bootstrap'),
    [
        ([{'a': 9, 'c': 0, 'r': 0}], 'no_edge_hold', False),
        ([{'a': 9, 'c': 1, 'r': 9}], 'capture_next', True),
        ([{'a': 0, 'c': 1, 'r': 0}], 'capture_next', True),
    ],
)
def test_initial_hold_bootstrap_and_same_value_capture(
    tmp_path: Path, steps: list[dict[str, int]], decision: str, bootstrap: bool
) -> None:
    report = execute(register_run(tmp_path, steps))
    assert report.status.query == 'complete'
    assert report.nodes[0].facts['decision'] == decision
    assert report.nodes[0].facts['bootstrap'] is bootstrap
    assert report.nodes[0].facts['prior_clock'] is None
    assert report.nodes[0].facts['old'] == BitVector(8, '0').to_dict()
    assert 'enable' not in report.nodes[0].facts
    if decision == 'no_edge_hold':
        initial = next(node for node in report.nodes if node.facts.get('origin') == 'initialization_contract')
        assert initial.facts['initialization'] == 'bound_two_state_default_zero'
        assert initial.facts['saved_value'] is False
        assert not any(edge.kind == 'capture' for edge in report.edges)
    else:
        assert any(edge.kind == 'capture' for edge in report.edges)


@pytest.mark.parametrize(('reset', 'expected', 'decision'), [(0, 9, 'capture_next'), (1, 6, 'capture_reset')])
def test_sync_reset_selects_native_operand(tmp_path: Path, reset: int, expected: int, decision: str) -> None:
    report = execute(register_run(tmp_path, [{'a': 9, 'c': 1, 'reset': reset, 'r': expected}], reset=True))
    assert report.status.query == 'complete'
    assert decisions(report) == [decision]
    nodes = {node.id: node for node in report.nodes}
    captured = [nodes[edge.source].ref.result for edge in report.edges if edge.kind == 'capture']
    assert captured == ['Demo/%rv' if reset else 'Demo/%next']
    assert report.nodes[0].facts['reset'] == BitVector.from_int(reset, 1).to_dict()


def test_reset_does_not_override_no_edge_hold(tmp_path: Path) -> None:
    report = execute(register_run(tmp_path, [{'a': 9, 'c': 0, 'reset': 1, 'r': 0}], reset=True))
    assert report.status.query == 'complete'
    assert decisions(report) == ['no_edge_hold']
    assert not any(edge.kind == 'capture' for edge in report.edges)


def test_feedback_mux_is_next_logic_and_same_value_is_capture(tmp_path: Path) -> None:
    path = register_run(tmp_path, [{'a': 9, 'c': 1, 'enable': 0, 'next': 0, 'r': 0}], feedback=True)
    report = execute(path)
    assert report.status.query == 'complete'
    assert decisions(report) == ['capture_next']
    mux = next(node for node in report.nodes if node.operation_name == 'comb.mux')
    assert mux.facts['selected_operand'] == 2
    assert len(report.nodes[0].facts['native_operands']) == 2
    assert report.nodes[0].facts['old'] == report.nodes[0].facts['next']


@pytest.mark.parametrize('value', [False, True])
def test_native_boolean_constant_on_capture_path(tmp_path: Path, value: bool) -> None:
    path = register_run(tmp_path, [{'a': 9, 'c': 1, 'next': int(value), 'r': int(value)}], boolean_next=value)
    report = execute(path)
    assert report.status.query == 'complete'
    assert report.nodes[0].value == BitVector.from_int(int(value), 8)


@pytest.mark.parametrize('value', [-256, -512])
def test_stdbits_out_of_width_negative_is_not_modulo_repaired(tmp_path: Path, value: int) -> None:
    with pytest.raises(TraceError) as caught:
        evaluate_comb(operation('hw.constant', (), 8, value=value), ())
    assert caught.value.code == StopCode.UNSUPPORTED_VALUE
    report = execute(register_run(tmp_path, [{'a': 0, 'c': 0, 'r': 0}], preset=value), preset_supported=True)
    assert report.status.query == 'partial'
    assert StopCode.UNSUPPORTED_VALUE in {item.reason.code for item in report.frontier}


def test_typed_boolean_has_no_bound_toint_rule() -> None:
    attribute = Term(
        (
            _Node('DV', '', ('SortBool{}',), 'true', ()),
            _Node('DV', '', ('SortSignlessIntegerType{}',), 'i8', ()),
            _Node(
                'App',
                "Lbl'UndsColnUndsUnds'BUILTIN-SYNTAX'Unds'AttributeValue'Unds'AttributeValue'Unds'Type",
                (),
                None,
                (0, 1),
            ),
        ),
        2,
    )
    with pytest.raises(TraceError) as caught:
        evaluate_comb(replace(operation('hw.constant', (), 8), attributes={'value': attribute}), ())
    assert caught.value.code == StopCode.UNSUPPORTED_SHAPE


def test_preset_old_operand_alias_and_new_committed_are_distinct(tmp_path: Path) -> None:
    path = register_run(tmp_path, [{'a': 9, 'c': 1, 'r': 9}], preset=4)
    committed = execute(path, preset_supported=True)
    observed = execute(path, target=Target('signal', name='Demo/result'), preset_supported=True)
    assert committed.status.query == observed.status.query == 'complete'
    assert committed.nodes[0].value == BitVector(8, '9')
    assert observed.nodes[0].value == BitVector(8, '4')
    assert committed.nodes[0].facts['old'] == BitVector(8, '4').to_dict()
    initial = next(node for node in observed.nodes if node.facts.get('origin') == 'initialization_contract')
    assert initial.ref.view == 'operand'
    assert initial.facts['initialization'] == 'explicit_preset'


@pytest.mark.parametrize(('preset', 'asynchronous'), [(5, False), (None, True)])
def test_unsupported_initialization_is_explicit(tmp_path: Path, preset: int | None, asynchronous: bool) -> None:
    path = register_run(tmp_path, [{'a': 9, 'c': 0, 'r': 0}], preset=preset, asynchronous=asynchronous)
    report = execute(path)
    assert report.status.query == 'partial'
    assert StopCode.UNSUPPORTED_INITIALIZATION in {item.reason.code for item in report.frontier}


def test_true_clock_id_can_disagree_with_external_input(tmp_path: Path) -> None:
    # 保存的 clk history 为 1，而当前外部输入历史为 0；不能拿 c 代替实际 ClkId。
    path = register_run(tmp_path, [{'a': 9, 'c': 1, 'r': 3}], setup={'a': 3, 'c': 0, 'clk': 1, 'r': 3})
    report = execute(path)
    assert report.status.query == 'complete'
    assert decisions(report) == ['no_edge_hold']
    assert report.nodes[0].facts['prior_clock'] == BitVector(1, '1').to_dict()


def test_hold_traces_real_predecessors_across_events_and_evaluations(tmp_path: Path) -> None:
    path = register_run(
        tmp_path,
        [{'a': 7, 'c': 1, 'r': 7}, {'a': 8, 'c': 1, 'r': 7}, {'a': 9, 'c': 0, 'r': 7}],
        evaluations=2,
    )
    report = execute(path, 3)
    assert report.status.query == 'complete'
    assert decisions(report) == ['no_edge_hold', 'no_edge_hold', 'capture_next']
    capture = next(node for node in report.nodes if node.facts.get('decision') == 'capture_next')
    assert capture.ref.state_id == 'state1'
    assert capture.observation is not None
    assert report.nodes[0].observation is not None
    assert capture.observation.event_index == 0 and capture.observation.evaluation == 1
    assert report.nodes[0].observation.event_index == 1
    assert report.scope['audit']['history_edges']


def test_preparation_follows_register_operand_view(tmp_path: Path) -> None:
    path = register_run(tmp_path, [{'a': 7, 'c': 1, 'r': 7}, {'a': 9, 'c': 0, 'r': 7}])
    report = execute(path, 2, target=Target('signal', name='Demo/result'))
    assert report.status.query == 'complete'
    assert report.nodes[0].value == BitVector(8, '7')
    assert any(node.ref.view == 'operand' and node.ref.state_id == 'state2' for node in report.nodes)
    assert any(node.ref.view == 'committed' and node.ref.state_id == 'state1' for node in report.nodes)
    assert 'capture_next' in decisions(report)


@pytest.mark.parametrize(('mode', 'code'), [('window', StopCode.WINDOW_BOUNDARY), ('gap', StopCode.HISTORY_GAP)])
def test_history_never_crosses_unavailable_predecessor(tmp_path: Path, mode: str, code: StopCode) -> None:
    path = register_run(tmp_path, [{'a': 7, 'c': 1, 'r': 7}, {'a': 9, 'c': 0, 'r': 7}])
    if mode == 'gap':
        (tmp_path / 'state1.kore').unlink()
    report = execute(path, 2, window=QueryWindow(first_event=1) if mode == 'window' else None)
    assert report.status.query == 'partial'
    assert code in {item.reason.code for item in report.frontier}
    assert 'capture_next' not in decisions(report)


def test_wrong_committed_value_rejected_without_replacement(tmp_path: Path) -> None:
    report = execute(register_run(tmp_path, [{'a': 9, 'c': 1, 'r': 8}]))
    assert report.status.query == 'rejected'
    assert report.nodes[0].value == BitVector(8, '8')
    assert StopCode.INCONSISTENT_EVIDENCE in {item.reason.code for item in report.frontier}


def test_generated_clock_outside_supported_shape(tmp_path: Path) -> None:
    report = execute(register_run(tmp_path, [{'a': 9, 'c': 1, 'r': 9}], generated_clock=True))
    assert report.status.query == 'partial'
    assert StopCode.UNSUPPORTED_CLOCK in {item.reason.code for item in report.frontier}


def test_same_content_states_still_count_as_distinct_history_positions(tmp_path: Path) -> None:
    path = register_run(tmp_path, [{'a': 0, 'c': 0, 'r': 0}] * 4, setup={'a': 0, 'c': 0, 'r': 0, 'out': 0})
    report = execute(path, 4, budget=Budget(max_states=3))
    assert report.status.query == 'partial'
    assert StopCode.STATE_BUDGET in {item.reason.code for item in report.frontier}


@pytest.mark.parametrize(
    ('current', 'prior', 'expected'),
    [
        (0, None, (False, False)),
        (1, None, (True, True)),
        (0, 0, (False, False)),
        (1, 0, (True, False)),
        (0, 1, (False, False)),
        (1, 1, (False, False)),
    ],
)
def test_bound_posedge_truth_table(current: int, prior: int | None, expected: tuple[bool, bool]) -> None:
    assert (
        evaluate_posedge(BitVector.from_int(current, 1), BitVector.from_int(prior, 1) if prior is not None else None)
        == expected
    )
