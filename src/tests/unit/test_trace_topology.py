"""以独立构造的小型层次配置核对目标目录和未压缩的候选关系。"""

from __future__ import annotations

import json
import time
from dataclasses import replace
from pathlib import Path
from types import SimpleNamespace
from typing import TYPE_CHECKING, cast

import pytest
from pyk.kore.parser import KoreParser
from pyk.kore.prelude import SORT_K_ITEM, inj, list_pattern, map_pattern
from pyk.kore.syntax import DV, App, SortApp, String

from kcirct.trace.kore import KoreReader, scalar
from kcirct.trace.model import CompletionEvidence, PortSpec, StopCode, Target, TraceError
from kcirct.trace.topology import TraceTopology

if TYPE_CHECKING:
    from pyk.kore.syntax import Pattern

    from kcirct.trace.artifacts import RunArtifacts
    from kcirct.trace.kore import DecodedState

FIXTURE = Path(__file__).parents[1] / 'resources/trace/unit/minimal-state.kore'


def _value(value: str, sort: str = 'String') -> Pattern:
    source = SortApp('Sort' + sort)
    return inj(source, SORT_K_ITEM, DV(source, String(value)))


def _types(*values: Pattern) -> Pattern:
    result = App(
        "Lbl'Stop'List'LBraQuotUndsCommUndsUnds'MLIR-SYNTAX'Unds'Types'Unds'Type'Unds'Types'QuotRBraUnds'Types"
    )
    for value in reversed(values):
        result = App("Lbl'UndsCommUndsUnds'MLIR-SYNTAX'Unds'Types'Unds'Type'Unds'Types", args=(value, result))
    return result


def _operation(name: str, operands: tuple[str | Pattern, ...], output: Pattern | None = None) -> Pattern:
    return App(
        "Lbl'UndsLParUndsRParLBraUndsRBraColnUndsUnds'MLIR-HELPER-SYNTAX'Unds'StdOp"
        "'Unds'String'Unds'List'Unds'Map'Unds'StdFT",
        args=(
            _value(name),
            list_pattern(*(_value(value) if isinstance(value, str) else value for value in operands)),
            map_pattern((_value('test_attribute'), _value('kept'))),
            App(
                "Lbl'LParUndsRPar'-'-GT-LParUndsRParUnds'MLIR-SYNTAX'Unds'StdFT'Unds'Types'Unds'Types",
                args=(
                    _types(*(_value('i8', 'SignlessIntegerType') for _ in operands)),
                    _types(output) if output is not None else _types(),
                ),
            ),
        ),
    )


def _register(tag: int, width: int, name: str) -> Pattern:
    result = App(
        "Lbl'Stop'List'LBraQuotUndsCommUndsUnds'BUILTIN-SYNTAX'Unds'AttributeValueList"
        "'Unds'AttributeValue'Unds'AttributeValueList'QuotRBraUnds'AttributeValueList"
    )
    for value in reversed(
        (_value(str(tag), 'Int'), _value(str(width), 'Int'), _value('0', 'Int'), _value('1', 'Int'), _value(name))
    ):
        result = App(
            "Lbl'UndsCommUndsUnds'BUILTIN-SYNTAX'Unds'AttributeValueList'Unds'AttributeValue'Unds'AttributeValueList",
            args=(value, result),
        )
    return result


def _cell(name: str, *values: Pattern) -> Pattern:
    return App("Lbl'-LT-'" + name + "'-GT-'", args=values)


def _instance(
    name: str, module: str, inputs: tuple[tuple[str, str], ...], outputs: tuple[tuple[str, str], ...]
) -> Pattern:
    cells = [_cell('hw-id', _value(name)), _cell('hw-module', _value(module))]
    for prefix, ports in (('in', inputs), ('out', outputs)):
        cells.extend(
            (
                _cell(
                    'hw-' + ('inputs' if prefix == 'in' else 'outputs'),
                    list_pattern(*(_value(alias, 'BareId') for alias, _ in ports)),
                ),
                _cell(f'hw-{prefix}ports', list_pattern(*(_value(signal) for _, signal in ports))),
                _cell(f'hw-{prefix}-types', list_pattern(*(_value('i8', 'SignlessIntegerType') for _ in ports))),
            )
        )
    return App('LblHwInstanceCellMapItem', args=(_cell('hw-id', _value(name)), _cell('hw-instance', *cells)))


def _changed(tmp_path: Path, replacements: dict[str, Pattern]) -> Path:
    root = KoreParser(FIXTURE.read_text()).pattern()
    symbols = {"Lbl'-LT-'" + name + "'-GT-'": value for name, value in replacements.items()}

    def change(node: Pattern) -> Pattern:
        if isinstance(node, App) and node.symbol in symbols:
            return (
                symbols[node.symbol]
                if node.symbol == "Lbl'-LT-'hw-instances'-GT-'"
                else App(node.symbol, args=(symbols[node.symbol],))
            )
        return node

    path = tmp_path / 'setup.kore'
    path.write_text(root.bottom_up(change).text)
    return path


def _hierarchy(tmp_path: Path, child: str = 'unit', *, future: bool = False) -> Path:
    prefix = 'Demo/' + child
    memory = App(
        "Lbl'Bang'seq'Stop'firmem'-LT-Unds'x'UndsComm'mask'Unds-GT-Unds'SEQ-SYNTAX"
        "'Unds'SeqFirmemType'Unds'Int'Unds'Int'Unds'Int",
        args=(_value('32', 'Int'), _value('10', 'Int'), _value('1', 'Int')),
    )
    connections = {
        'Demo/%out': _value(prefix + '/%q'),
        prefix + '/%arg0': _value('Demo/%a'),
        prefix + '/%constant': _operation('hw.constant', (), _value('i8', 'SignlessIntegerType')),
        prefix + '/%q': _operation('seq.firreg', (prefix + '/%arg0',), _value('i8', 'SignlessIntegerType')),
        prefix
        + '/%sum': _operation(
            'comb.add', (prefix + '/%constant', prefix + '/%constant'), _value('i8', 'SignlessIntegerType')
        ),
        prefix + '/%mem': _operation('seq.firmem', (), memory),
    }
    if future:
        connections[prefix + '/%future'] = _operation('future.op', (_value('4', 'Int'),), App('LblFutureType'))
        connections[prefix + '/%typed'] = _operation('future.typed', (prefix + '/%arg0',), App('LblFutureType'))
        connections[prefix + '/%unknown'] = App('LblFutureOperation')
    return _changed(
        tmp_path,
        {
            'connection': map_pattern(*((_value(signal), value) for signal, value in connections.items())),
            'register': map_pattern(
                (_value(prefix + '/%q'), _register(0, 8, 'counter')),
                (_value(prefix + '/%mem'), _register(1, 0, 'store')),
            ),
            'procedures': list_pattern(
                _operation('sv.assert', (prefix + '/%sum',)),
                _operation(
                    'seq.firmem.write_port',
                    (prefix + '/%mem', prefix + '/%arg0', 'Demo/%a', prefix + '/%constant', prefix + '/%sum'),
                ),
                _operation(
                    'seq.firmem.write_port',
                    (prefix + '/%mem', prefix + '/%constant', 'Demo/%a', prefix + '/%constant', prefix + '/%arg0'),
                ),
            ),
            'hw-instances': _cell(
                'hw-instances',
                App(
                    "Lbl'Unds'HwInstanceCellMap'Unds'",
                    args=(
                        _instance(
                            'Demo', 'Top', (('input', 'Demo/%a'),), (('result', 'Demo/%out'), ('mirror', 'Demo/%out'))
                        ),
                        _instance(
                            prefix,
                            'ChildModule',
                            (('input', prefix + '/%arg0'),),
                            (
                                ('result', prefix + '/%q'),
                                ('mirror', prefix + '/%q'),
                                ('constant_a', prefix + '/%constant'),
                                ('constant_b', prefix + '/%constant'),
                            ),
                        ),
                    ),
                ),
                _cell('hw-setup-inst', list_pattern()),
            ),
        },
    )


@pytest.fixture
def topology(tmp_path: Path) -> TraceTopology:
    with KoreReader() as reader:
        return TraceTopology.from_state('run-one', reader.read(_hierarchy(tmp_path)))


def test_shared_aliases_register_names_and_static_boundaries(topology: TraceTopology) -> None:
    assert topology.nodes['Demo/unit/%constant'].aliases == ('Demo/unit/constant_a', 'Demo/unit/constant_b')
    assert topology.resolve(Target('signal', name='Demo/result')).signal_id == 'Demo/%out'
    register = topology.resolve(Target('register', name='Demo/result'))
    assert register.signal_id == 'Demo/unit/%q'
    assert set(register.aliases) == {
        'Demo/result',
        'Demo/mirror',
        'Demo/unit/result',
        'Demo/unit/mirror',
        'Demo/unit/counter',
    }
    assert register.width == 8
    assert topology.resolve(Target('register', name='counter')).target_id == register.target_id
    boundaries = {(edge.source, edge.target, edge.relation) for edge in topology.edges if edge.relation != 'operand'}
    assert boundaries == {
        ('Demo/%a', 'Demo/unit/%arg0', 'instance_input'),
        ('Demo/unit/%q', 'Demo/%out', 'instance_output'),
    }
    assert all(edge.kind == 'static_candidate' for edge in topology.edges)


def test_duplicate_operand_references_are_distinct_edges(topology: TraceTopology) -> None:
    edges = [edge for edge in topology.edges if edge.target == 'Demo/unit/%sum']
    assert [(edge.source, edge.operand_index) for edge in edges] == [
        ('Demo/unit/%constant', 0),
        ('Demo/unit/%constant', 1),
    ]
    operation = topology.nodes['Demo/unit/%sum'].operation
    assert operation is not None
    assert (operation.instance_id, operation.module_symbol, operation.result_ssa) == (
        'Demo/unit',
        'ChildModule',
        '%sum',
    )
    assert scalar(operation.attributes['test_attribute']) == 'kept'
    assert scalar(operation.result_types[0]) == 'i8'
    assert len(operation.raw_operands) == 2


def test_short_or_dotted_names_preserve_ambiguity(topology: TraceTopology) -> None:
    with pytest.raises(TraceError) as caught:
        topology.resolve(Target('signal', name='result'))
    assert caught.value.code == StopCode.AMBIGUOUS_TARGET
    assert {item['signal_id'] for item in caught.value.details['candidates']} == {'Demo/%out', 'Demo/unit/%q'}
    assert topology.resolve(Target('signal', name='Demo.unit.result')).signal_id == 'Demo/unit/%q'


def test_memory_families_bind_addresses_and_actual_procedures(topology: TraceTopology) -> None:
    (family,) = topology.list_targets('memory_cell')
    assert family.to_dict()['requires_address']
    assert family.shape == {'depth': 32, 'width': 10, 'mask': 1, 'read_latency': 0, 'write_latency': 1}
    cell = topology.resolve(Target('memory_cell', name='store', address='2'))
    assert (cell.address, cell.width, cell.signal_id) == ('2', 10, 'Demo/unit/%mem')
    assert cell.target_id == family.target_id + '/address/2'
    assert topology.resolve(Target('memory_cell', target_id=cell.target_id, address='2')) == cell
    ports = topology.list_targets('memory_write_port')
    assert [port.procedure_index for port in ports] == [1, 2]
    assert [port.name for port in ports] == ['Demo/unit/store/write_port[1]', 'Demo/unit/store/write_port[2]']
    assert ports[0].target_id != ports[1].target_id
    assert topology.resolve(Target('memory_write_port', name='procedure:2')) == ports[1]
    assert topology.procedures[1].operands[0] == 'Demo/unit/%mem'
    assert topology.procedures[1].module_symbol == 'ChildModule'
    assert json.loads(json.dumps(cell.to_dict()))['address'] == '2'


@pytest.mark.parametrize('address', ['32', '999999999999999999999999999'])
def test_memory_address_outside_shape_is_rejected(topology: TraceTopology, address: str) -> None:
    with pytest.raises(TraceError) as caught:
        topology.resolve(Target('memory_cell', name='store', address=address))
    assert caught.value.code == StopCode.INVALID_INPUT


def test_target_id_binds_run_kind_and_address(topology: TraceTopology, tmp_path: Path) -> None:
    signal = topology.resolve(Target('signal', name='Demo/result'))
    with KoreReader() as reader:
        other = TraceTopology.from_state('run-two', reader.read(_hierarchy(tmp_path)))
    requests = (
        (other, Target('signal', target_id=signal.target_id)),
        (topology, Target('register', target_id=signal.target_id)),
        (
            topology,
            Target(
                'memory_cell', target_id=topology.list_targets('memory_cell')[0].target_id + '/address/1', address='2'
            ),
        ),
    )
    for selected, request in requests:
        with pytest.raises(TraceError) as caught:
            selected.resolve(request)
        assert caught.value.code == StopCode.IDENTITY_MISMATCH


def test_renamed_instance_keeps_relations_but_changes_identity(topology: TraceTopology, tmp_path: Path) -> None:
    with KoreReader() as reader:
        renamed = TraceTopology.from_state('run-one', reader.read(_hierarchy(tmp_path, 'renamed')))
    before = topology.resolve(Target('register', name='counter'))
    after = renamed.resolve(Target('register', name='counter'))
    assert before.target_id != after.target_id
    assert before.module_symbol == after.module_symbol == 'ChildModule'
    assert [
        (
            edge.source.replace('/unit/', '/renamed/'),
            edge.target.replace('/unit/', '/renamed/'),
            edge.relation,
            edge.operand_index,
        )
        for edge in topology.edges
    ] == [(edge.source, edge.target, edge.relation, edge.operand_index) for edge in renamed.edges]


def test_unknown_operation_and_type_remain_local_boundaries(tmp_path: Path) -> None:
    with KoreReader() as reader:
        topology = TraceTopology.from_state('run', reader.read(_hierarchy(tmp_path, future=True)))
    future = topology.nodes['Demo/unit/%future'].operation
    assert future is not None and future.unsupported and len(future.raw_operands) == 1
    assert future.result_types[0].symbol == 'LblFutureType'
    unknown = topology.nodes['Demo/unit/%unknown'].operation
    assert unknown is not None and unknown.unsupported and unknown.term.symbol == 'LblFutureOperation'
    assert topology.resolve(Target('signal', name='Demo/unit/%future')).unsupported
    assert topology.resolve(Target('signal', name='Demo/unit/%typed')).unsupported
    assert topology.nodes['Demo/unit/%typed'].operation is not None
    assert any(edge.source == 'Demo/unit/%arg0' and edge.target == 'Demo/unit/%typed' for edge in topology.edges)
    assert topology.resolve(Target('register', name='counter')).width == 8


def test_original_minimal_register_retains_all_names() -> None:
    with KoreReader() as reader:
        topology = TraceTopology.from_state('run', reader.read(FIXTURE))
    assert topology.resolve(Target('register', name='count')).aliases == ('Demo/count', 'Demo/mirror', 'Demo/result')
    assert 'Demo/%read' in topology.register_proc


def test_unnamed_signal_uses_instance_module_and_local_ssa(topology: TraceTopology) -> None:
    target = topology.resolve(Target('signal', name='Demo/unit/%sum'))
    assert target.name == target.signal_id == 'Demo/unit/%sum'
    assert target.aliases == ()
    assert target.module_symbol == 'ChildModule'
    assert topology.resolve(Target('signal', target_id=target.target_id)) == target


def test_unknown_port_type_is_retained_without_losing_other_targets(tmp_path: Path) -> None:
    with KoreReader() as reader:
        topology = TraceTopology.from_state(
            'run',
            reader.read(
                _changed(
                    tmp_path,
                    {
                        'hw-in-types': list_pattern(App('LblFutureType')),
                    },
                )
            ),
        )
    target = topology.resolve(Target('signal', name='Demo/a'))
    assert target.width is None and target.unsupported
    assert topology.port_aliases[0].type.symbol == 'LblFutureType'
    assert topology.resolve(Target('register', name='count')).width == 8


def test_inconsistent_shared_port_widths_are_rejected(tmp_path: Path) -> None:
    with KoreReader() as reader:
        setup = reader.read(
            _changed(
                tmp_path,
                {
                    'hw-out-types': list_pattern(
                        _value('i8', 'SignlessIntegerType'), _value('i9', 'SignlessIntegerType')
                    ),
                },
            )
        )
    with pytest.raises(TraceError) as caught:
        TraceTopology.from_state('run', setup)
    assert caught.value.code == StopCode.INCONSISTENT_EVIDENCE


def test_deadline_and_incomplete_setup_are_rejected() -> None:
    with KoreReader() as reader:
        setup = reader.read(FIXTURE)
    with pytest.raises(TraceError) as caught:
        TraceTopology.from_state('run', setup, deadline=time.monotonic() - 1)
    assert caught.value.code == StopCode.TIME_BUDGET
    with pytest.raises(TraceError) as caught:
        TraceTopology.from_state('run', replace(setup, completion=CompletionEvidence('incomplete')))
    assert caught.value.code == StopCode.INCOMPLETE_EXECUTION


def _run(setup: DecodedState, *, top: str = 'Demo', width: int = 8) -> RunArtifacts:
    return cast(
        'RunArtifacts',
        SimpleNamespace(
            manifest=SimpleNamespace(
                run_id='run',
                top_module=top,
                ports=(PortSpec('a', 'input', width), PortSpec('result', 'output', 8), PortSpec('mirror', 'output', 8)),
            ),
            setup_id='setup',
            reader=SimpleNamespace(deadline=None),
            read_state=lambda _: setup,
        ),
    )


def test_manifest_top_module_and_ports_are_checked() -> None:
    with KoreReader() as reader:
        setup = reader.read(FIXTURE)
    assert TraceTopology.from_run(_run(setup)).top_module == 'Demo'
    for run in (_run(setup, top='Other'), _run(setup, width=7)):
        with pytest.raises(TraceError) as caught:
            TraceTopology.from_run(run)
        assert caught.value.code == StopCode.IDENTITY_MISMATCH
