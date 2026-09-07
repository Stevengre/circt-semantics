"""以显式快照和独立 Map 预期核对单写口、读取顺序与连续同址历史。"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass, field
from typing import TYPE_CHECKING

import pytest
from pyk.kore.prelude import list_pattern, map_pattern
from pyk.kore.syntax import App

from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.model import BitVector, Budget, Observation, QueryRequest, QueryWindow, StopCode, Target
from kcirct.trace.query import _Query
from kcirct.trace.topology import TraceTopology

from .test_trace_query import PROFILE, bits, item, op, publish, state_text
from .test_trace_topology import _types

if TYPE_CHECKING:
    from pathlib import Path
    from typing import Any

    from pyk.kore.syntax import Pattern

    from kcirct.trace.model import TraceNode, TraceReport


@dataclass(frozen=True)
class Snapshot:
    """全部信号和提交 Map 由用例显式给定，不通过待测解释器求值。"""

    memory: dict[int, int] = field(default_factory=dict)
    clock: int = 0
    enable: int = 1
    address: int = 0
    data: int = 0
    read_address: int = 0
    read_enable: int = 1
    read_value: int = 0
    register_value: int = 0
    mask: int = 1


def register_declaration(tag: int, width: int, read_latency: int, write_latency: int, name: str) -> Pattern:
    result = App(
        "Lbl'Stop'List'LBraQuotUndsCommUndsUnds'BUILTIN-SYNTAX'Unds'AttributeValueList"
        "'Unds'AttributeValue'Unds'AttributeValueList'QuotRBraUnds'AttributeValueList"
    )
    for value in reversed(
        (
            item(str(tag), 'Int'),
            item(str(width), 'Int'),
            item(str(read_latency), 'Int'),
            item(str(write_latency), 'Int'),
            item(name),
        )
    ):
        result = App(
            "Lbl'UndsCommUndsUnds'BUILTIN-SYNTAX'Unds'AttributeValueList'Unds'AttributeValue'Unds'AttributeValueList",
            args=(value, result),
        )
    return result


def memory_operation(
    name: str,
    operands: tuple[str, ...],
    input_types: tuple[Pattern, ...],
    output_types: tuple[Pattern, ...],
    **attributes: int,
) -> Pattern:
    template = op(name, operands, (), **attributes)
    assert isinstance(template, App)
    function_type = App(
        "Lbl'LParUndsRPar'-'-GT-LParUndsRParUnds'MLIR-SYNTAX'Unds'StdFT'Unds'Types'Unds'Types",
        args=(_types(*input_types), _types(*output_types)),
    )
    return App(template.symbol, args=(*template.args[:3], function_type))


def memory_run(
    root: Path,
    steps: list[Snapshot],
    *,
    setup: Snapshot | None = None,
    width: int = 8,
    depth: int = 8,
    address_width: int | None = None,
    type_mask: int | None = 1,
    mask_operand: bool = False,
    mask_width: int = 1,
    writers: int = 1,
    write_latency: int = 1,
    read_latency: int = 0,
    read_operands: int = 3,
    registered_address: bool = False,
    combined_port: bool = False,
    evaluations: int = 1,
) -> Path:
    address_width = address_width or max(1, (depth - 1).bit_length())
    dimensions = (item(str(depth), 'Int'), item(str(width), 'Int'))
    mem_type = App(
        (
            "Lbl'Bang'seq'Stop'firmem'-LT-Unds'x'Unds-GT-Unds'SEQ-SYNTAX'Unds'SeqFirmemType'Unds'Int'Unds'Int"
            if type_mask is None
            else "Lbl'Bang'seq'Stop'firmem'-LT-Unds'x'UndsComm'mask'Unds-GT-Unds'SEQ-SYNTAX'Unds'SeqFirmemType'Unds'Int'Unds'Int'Unds'Int"
        ),
        args=dimensions if type_mask is None else (*dimensions, item(str(type_mask), 'Int')),
    )
    integer = item(f'i{width}', 'SignlessIntegerType')
    address_type = item(f'i{address_width}', 'SignlessIntegerType')
    one_bit = item('i1', 'SignlessIntegerType')
    mask_type = item(f'i{mask_width}', 'SignlessIntegerType')
    write_address = 'Demo/%wraddr' if registered_address else 'Demo/%addr'
    write_args: tuple[str, ...] = ('Demo/%mem', write_address, 'Demo/%clk', 'Demo/%enable', 'Demo/%data')
    write_types: tuple[Pattern, ...] = (mem_type, address_type, one_bit, one_bit, integer)
    if mask_operand:
        write_args += ('Demo/%mask',)
        write_types += (mask_type,)
    read_args: tuple[str, ...] = ('Demo/%mem', 'Demo/%read_addr', 'Demo/%clk')
    read_types: tuple[Pattern, ...] = (mem_type, address_type, one_bit)
    if read_operands == 4:
        read_args += ('Demo/%read_enable',)
        read_types += (one_bit,)
    read = memory_operation('seq.firmem.read_port', read_args, read_types, (integer,))
    connections = {
        'Demo/%mem': memory_operation(
            'seq.firmem', (), (), (mem_type,), readLatency=read_latency, writeLatency=write_latency
        ),
        'Demo/%clk': op('seq.to_clock', ('Demo/%clock',), (1,), 1),
        'Demo/%read': read,
        'Demo/%out': item('Demo/%read'),
    }
    registers = {'Demo/%mem': register_declaration(1, 0, read_latency, write_latency, 'store')}
    if registered_address:
        connections['Demo/%wraddr'] = op('seq.firreg', ('Demo/%addr', 'Demo/%clk'), (address_width, 1), address_width)
        registers['Demo/%wraddr'] = register_declaration(0, address_width, 0, 0, 'write_address')
    port_name = 'seq.firmem.read_write_port' if combined_port else 'seq.firmem.write_port'
    procedures = tuple(memory_operation(port_name, write_args, write_types, ()) for _ in range(writers))
    inputs = {
        'clock': one_bit,
        'enable': one_bit,
        'addr': address_type,
        'data': integer,
        'read_addr': address_type,
        'read_enable': one_bit,
        'mask': mask_type,
    }
    metadata = {
        'connection': map_pattern(*((item(name), value) for name, value in connections.items())),
        'register': map_pattern(*((item(name), value) for name, value in registers.items())),
        'register-proc': map_pattern(),
        'procedures': list_pattern(*procedures),
        'top-ins': list_pattern(*(item('Demo/%' + name) for name in inputs)),
        'hw-inputs': list_pattern(*(item(name, 'BareId') for name in inputs)),
        'hw-inports': list_pattern(*(item('Demo/%' + name) for name in inputs)),
        'hw-in-types': list_pattern(*inputs.values()),
        'hw-outports': list_pattern(item('Demo/%out'), item('Demo/%out')),
        'hw-out-types': list_pattern(integer, integer),
    }

    def cells(snapshot: Snapshot | None) -> Pattern:
        if snapshot is None:
            return map_pattern()
        values = {
            'clock': bits(snapshot.clock, 1),
            'clk': bits(snapshot.clock, 1),
            'enable': bits(snapshot.enable, 1),
            'addr': bits(snapshot.address, address_width),
            'data': bits(snapshot.data, width),
            'read_addr': bits(snapshot.read_address, address_width),
            'read_enable': bits(snapshot.read_enable, 1),
            'mask': bits(snapshot.mask, mask_width),
            'read': bits(snapshot.read_value, width),
            'out': bits(snapshot.read_value, width),
            'mem': map_pattern(
                *((bits(address, address_width), bits(value, width)) for address, value in snapshot.memory.items())
            ),
        }
        if registered_address:
            values['wraddr'] = bits(snapshot.register_value, address_width)
        return map_pattern(*((item('Demo/%' + name), value) for name, value in values.items()))

    previous = setup
    texts = []
    for current in [setup, *steps]:
        texts.append(state_text(dict(metadata, signals=cells(current), history=cells(previous))))
        previous = current
    return publish(root, texts, evaluations=evaluations)


def execute(
    path: Path,
    index: int = 1,
    *,
    target: Target | None = None,
    window: QueryWindow | None = None,
    budget: Budget | None = None,
) -> TraceReport:
    request = QueryRequest(
        target or Target('memory_cell', name='Demo/store', address='2'),
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
        return _Query(run, request, topology, PROFILE).execute(topology.resolve(request.target))


def write_nodes(report: TraceReport) -> list[TraceNode]:
    return [node for node in report.nodes if node.ref.result.startswith('procedure:')]


def frontier_codes(report: TraceReport) -> set[StopCode]:
    return {item.reason.code for item in report.frontier}


@pytest.mark.parametrize(('depth', 'width', 'address', 'data'), [(8, 8, 2, 17), (5, 13, 4, 4097), (64, 10, 51, 1023)])
def test_dimensions_and_addresses_come_from_declared_shape(
    tmp_path: Path, depth: int, width: int, address: int, data: int
) -> None:
    path = memory_run(
        tmp_path, [Snapshot(memory={address: data}, clock=1, address=address, data=data)], width=width, depth=depth
    )
    report = execute(path, target=Target('memory_cell', name='Demo/store', address=str(address)))
    assert report.status.query == 'complete'
    assert report.nodes[0].value == BitVector.from_int(data, width)
    assert report.nodes[0].facts['decision'] == 'memory_write'
    assert report.nodes[0].facts['written_address'] == str(address)
    assert any(edge.kind == 'write' for edge in report.edges)
    assert report.status.design_check == 'not_run'


@pytest.mark.parametrize(('type_mask', 'mask_operand'), [(None, False), (1, False), (1, True)])
def test_type_mask_does_not_create_a_dynamic_operand(tmp_path: Path, type_mask: int | None, mask_operand: bool) -> None:
    path = memory_run(
        tmp_path, [Snapshot(memory={2: 9}, clock=1, address=2, data=9)], type_mask=type_mask, mask_operand=mask_operand
    )
    report = execute(path, target=Target('memory_write_port', name='procedure:0'))
    assert report.status.query == 'complete'
    root = report.nodes[0]
    assert root.ref.result == root.ref.operation == 'procedure:0'
    assert root.value is None
    assert root.facts['decision'] == 'write'
    assert root.facts['bootstrap'] is True
    assert len(root.facts['native_operand_ids']) == (6 if mask_operand else 5)
    assert root.facts['native_operand_ids'][0] == root.facts['memory_id'] == 'Demo/%mem'
    expected_operands = ['Demo/%addr', 'Demo/%clk', 'Demo/%enable', 'Demo/%data']
    if mask_operand:
        expected_operands.append('Demo/%mask')
    assert [operand['result'] for operand in root.facts['scalar_operands']] == expected_operands
    assert root.facts['native_operand_ids'][1:] == expected_operands
    assert root.facts['memory_map_view'] == 'pre_commit_signals_verified_against_history'
    assert not any(edge.kind == 'write' for edge in report.edges)


def test_same_value_write_still_has_write_source(tmp_path: Path) -> None:
    path = memory_run(tmp_path, [Snapshot(memory={2: 9}, clock=1, address=2, data=9)], setup=Snapshot(memory={2: 9}))
    report = execute(path)
    assert report.status.query == 'complete'
    assert report.nodes[0].facts['decision'] == 'memory_write'
    port = write_nodes(report)[0]
    assert port.facts['old'] == port.facts['new'] == BitVector(8, '9').to_dict()
    assert any(edge.kind == 'write' for edge in report.edges)


@pytest.mark.parametrize(('clock', 'enable', 'decision'), [(1, 0, 'disabled'), (0, 1, 'no_edge')])
def test_disabled_and_no_edge_do_not_produce_write_edges(
    tmp_path: Path, clock: int, enable: int, decision: str
) -> None:
    path = memory_run(tmp_path, [Snapshot(clock=clock, enable=enable, address=2, data=9)])
    port = execute(path, target=Target('memory_write_port', name='procedure:0'))
    assert port.status.query == 'complete'
    assert port.nodes[0].facts['decision'] == decision
    assert not any(edge.kind == 'write' for edge in port.edges)
    cell = execute(path)
    assert cell.status.query == 'complete'
    assert cell.nodes[0].value == BitVector(8, '0')
    assert not any(edge.kind == 'write' for edge in cell.edges)
    assert any(node.facts.get('saved_value') is False for node in cell.nodes)


@pytest.mark.parametrize('disabled', [False, True])
def test_latest_same_address_write_skips_disabled_and_other_address(tmp_path: Path, disabled: bool) -> None:
    final = Snapshot(
        memory={2: 9} if disabled else {2: 9, 1: 6},
        clock=1,
        enable=0 if disabled else 1,
        address=2 if disabled else 1,
        data=6,
    )
    path = memory_run(tmp_path, [Snapshot(memory={2: 9}, clock=1, address=2, data=9), Snapshot(memory={2: 9}), final])
    report = execute(path, 3)
    assert report.status.query == 'complete'
    assert report.nodes[0].facts['decision'] == 'memory_hold'
    nodes = {node.id: node for node in report.nodes}
    writes = [nodes[edge.source] for edge in report.edges if edge.kind == 'write']
    assert writes and all(node.ref.state_id == 'state1' for node in writes)
    assert report.scope['audit']['history_edges']


def test_consecutive_same_address_writes_keep_last_commit_and_previous_query(tmp_path: Path) -> None:
    path = memory_run(
        tmp_path,
        [
            Snapshot(memory={2: 7}, clock=1, address=2, data=7),
            Snapshot(memory={2: 7}),
            Snapshot(memory={2: 11}, clock=1, address=2, data=11),
        ],
    )
    latest = execute(path, 3)
    previous = execute(path, 2)
    assert latest.status.query == previous.status.query == 'complete'
    assert latest.nodes[0].value == BitVector(8, '11')
    assert previous.nodes[0].value == BitVector(8, '7')
    assert write_nodes(latest)[0].ref.state_id == 'state3'
    assert any(
        node.ref.state_id == 'state1' and node.facts.get('decision') == 'write' for node in write_nodes(previous)
    )


@pytest.mark.parametrize(('mode', 'code'), [('gap', StopCode.HISTORY_GAP), ('window', StopCode.WINDOW_BOUNDARY)])
def test_history_stops_before_unavailable_predecessor(tmp_path: Path, mode: str, code: StopCode) -> None:
    path = memory_run(tmp_path, [Snapshot(memory={2: 7}, clock=1, address=2, data=7), Snapshot(memory={2: 7})])
    if mode == 'gap':
        (tmp_path / 'state1.kore').unlink()
    report = execute(path, 2, window=QueryWindow(first_event=1) if mode == 'window' else None)
    assert report.status.query == 'partial'
    assert code in frontier_codes(report)
    assert not any(edge.kind == 'write' for edge in report.edges)


def test_write_address_reads_prior_firreg_value_not_new_commit(tmp_path: Path) -> None:
    path = memory_run(
        tmp_path,
        [Snapshot(memory={1: 42}, clock=1, address=3, register_value=3, data=42)],
        setup=Snapshot(register_value=1),
        registered_address=True,
    )
    port = execute(path, target=Target('memory_write_port', name='procedure:0'))
    old_cell = execute(path, target=Target('memory_cell', name='Demo/store', address='1'))
    new_cell = execute(path, target=Target('memory_cell', name='Demo/store', address='3'))
    committed_address = execute(path, target=Target('register', name='Demo/write_address'))
    assert (
        port.status.query
        == old_cell.status.query
        == new_cell.status.query
        == committed_address.status.query
        == 'complete'
    )
    assert port.nodes[0].facts['address'] == BitVector(3, '1').to_dict()
    assert committed_address.nodes[0].value == BitVector(3, '3')
    assert old_cell.nodes[0].value == BitVector(8, '42')
    assert new_cell.nodes[0].value == BitVector(8, '0')
    assert any(
        node.ref.result == 'Demo/%wraddr' and node.ref.view == 'operand' and node.value == BitVector(3, '1')
        for node in port.nodes
    )
    assert not any(edge.kind == 'write' for edge in new_cell.edges)


@pytest.mark.parametrize('operands', [3, 4])
def test_rl0_read_without_same_address_write_follows_proven_history(tmp_path: Path, operands: int) -> None:
    path = memory_run(
        tmp_path,
        [Snapshot(memory={2: 7, 1: 9}, clock=1, address=1, data=9, read_address=2, read_value=7)],
        setup=Snapshot(memory={2: 7}),
        read_operands=operands,
    )
    report = execute(path, target=Target('signal', name='Demo/result'))
    assert report.status.query == 'complete'
    assert report.nodes[0].value == BitVector(8, '7')
    assert any(
        node.ref.result == 'Demo/%mem' and node.ref.address == '2' and node.ref.view == 'prior' for node in report.nodes
    )


@pytest.mark.parametrize(('old', 'new'), [(7, 9), (9, 9)])
def test_same_eval_same_address_read_write_is_ambiguous_even_for_same_value(tmp_path: Path, old: int, new: int) -> None:
    path = memory_run(
        tmp_path,
        [Snapshot(memory={2: new}, clock=1, address=2, data=new, read_address=2, read_value=new)],
        setup=Snapshot(memory={2: old}),
    )
    read = execute(path, target=Target('signal', name='Demo/result'))
    cell = execute(path)
    assert read.status.query == 'partial'
    assert StopCode.UNSUPPORTED_MEMORY_ORDER in frontier_codes(read)
    assert cell.status.query == 'complete'
    assert cell.nodes[0].facts['decision'] == 'memory_write'


def test_disabled_read_returns_saved_zero_without_claiming_memory_source(tmp_path: Path) -> None:
    path = memory_run(
        tmp_path,
        [Snapshot(memory={2: 9}, clock=1, address=2, data=9, read_address=2, read_enable=0, read_value=0)],
        read_operands=4,
    )
    report = execute(path, target=Target('signal', name='Demo/result'))
    assert report.status.query == 'complete'
    assert report.nodes[0].value == BitVector(8, '0')
    assert not any(node.ref.result == 'Demo/%mem' for node in report.nodes)


@pytest.mark.parametrize(
    'options',
    [
        {'writers': 2},
        {'write_latency': 2},
        {'read_latency': 1},
        {'mask_operand': True, 'mask_width': 2, 'type_mask': 2},
        {'combined_port': True},
    ],
)
def test_unsupported_memory_shapes_stop_explicitly(tmp_path: Path, options: dict[str, Any]) -> None:
    path = memory_run(tmp_path, [Snapshot(memory={2: 9}, clock=1, address=2, data=9)], **options)
    report = execute(path)
    assert report.status.query == 'partial'
    assert StopCode.UNSUPPORTED_SHAPE in frontier_codes(report)


def test_dynamic_mask_must_be_full_word(tmp_path: Path) -> None:
    path = memory_run(tmp_path, [Snapshot(clock=1, address=2, data=9, mask=0)], mask_operand=True)
    report = execute(path)
    assert report.status.query == 'partial'
    assert StopCode.UNSUPPORTED_SHAPE in frontier_codes(report)


def test_saved_memory_commit_mismatch_is_rejected(tmp_path: Path) -> None:
    path = memory_run(tmp_path, [Snapshot(memory={2: 8}, clock=1, address=2, data=9)])
    report = execute(path)
    assert report.status.query == 'rejected'
    assert report.nodes[0].value == BitVector(8, '8')
    assert StopCode.INCONSISTENT_EVIDENCE in frontier_codes(report)


def test_memory_history_counts_actual_states_under_budget(tmp_path: Path) -> None:
    path = memory_run(tmp_path, [Snapshot(memory={2: 7})] * 4, setup=Snapshot(memory={2: 7}))
    report = execute(path, 4, budget=Budget(max_states=3))
    assert report.status.query == 'partial'
    assert StopCode.STATE_BUDGET in frontier_codes(report)


def test_derived_write_records_bind_every_source_state_hash(tmp_path: Path) -> None:
    path = memory_run(tmp_path, [Snapshot(memory={2: 7}, clock=1, address=2, data=7), Snapshot(memory={2: 7})])
    report = execute(path, 2)
    assert report.status.query == 'complete'
    records = report.scope['memory_writes']
    assert {record['state_id'] for record in records} == {'state1', 'state2'}
    for record in records:
        expected_hash = hashlib.sha256((tmp_path / (record['state_id'] + '.kore')).read_bytes()).hexdigest()
        assert record['source_sha256'] == expected_hash
        assert record['memory_id'] == 'Demo/%mem'


def test_write_cache_does_not_retain_full_memory_maps(tmp_path: Path) -> None:
    memory = {address: address for address in range(8)}
    path = memory_run(tmp_path, [Snapshot(memory=memory)], setup=Snapshot(memory=memory))
    request = QueryRequest(
        Target('memory_cell', name='Demo/store', address='2'),
        Observation('post_eval', state_id='state1', evaluation=1),
    )
    with RunArtifacts.open(path) as run:
        topology = TraceTopology.from_run(run)
        engine = _Query(run, request, topology, PROFILE)
        report = engine.execute(topology.resolve(request.target))
        assert report.status.query == 'complete'
        assert engine.memory_writes
        assert all(not hasattr(write.decision, 'expected') for write in engine.memory_writes.values())


def test_cached_history_never_hides_changed_source_bytes(tmp_path: Path) -> None:
    path = memory_run(tmp_path, [Snapshot(memory={2: 7}, clock=1, address=2, data=7), Snapshot(memory={2: 7})])
    request = QueryRequest(
        Target('memory_cell', name='Demo/store', address='2'),
        Observation('post_eval', state_id='state2', evaluation=1),
    )
    with RunArtifacts.open(path) as run:
        topology = TraceTopology.from_run(run)
        binding = topology.resolve(request.target)
        first = _Query(run, request, topology, PROFILE).execute(binding)
        assert first.status.query == 'complete'
        source = tmp_path / 'state1.kore'
        source.write_bytes(source.read_bytes() + b'\n')
        second = _Query(run, request, topology, PROFILE).execute(binding)
        assert second.status.query == 'rejected'
        assert StopCode.HASH_MISMATCH in frontier_codes(second)
