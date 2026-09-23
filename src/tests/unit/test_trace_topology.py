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
    """把指定 sort 的域值注入 KItem，用于构造名称、类型和声明属性。"""
    source = SortApp('Sort' + sort)
    return inj(source, SORT_K_ITEM, DV(source, String(value)))


def _types(*values: Pattern) -> Pattern:
    """将原始类型 term 按给定顺序编码为 Types 链表，保留未知类型形状。"""
    result = App(
        "Lbl'Stop'List'LBraQuotUndsCommUndsUnds'MLIR-SYNTAX'Unds'Types'Unds'Type'Unds'Types'QuotRBraUnds'Types"
    )
    for value in reversed(values):
        result = App("Lbl'UndsCommUndsUnds'MLIR-SYNTAX'Unds'Types'Unds'Type'Unds'Types", args=(value, result))
    return result


def _operation(name: str, operands: tuple[str | Pattern, ...], output: Pattern | None = None) -> Pattern:
    """构造保留测试属性的 StdOp，可接收字符串或原始 term 实参及可选结果类型。"""
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
    """构造五项寄存器或存储声明，固定读延迟 0、写延迟 1 并保留声明名。"""
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
    """按 cell 名称包裹原始子项，用于组装层次实例配置。"""
    return App("Lbl'-LT-'" + name + "'-GT-'", args=values)


def _instance(
    name: str, module: str, inputs: tuple[tuple[str, str], ...], outputs: tuple[tuple[str, str], ...]
) -> Pattern:
    """构造具有模块名、实例路径和八位输入输出端口别名的 hw-instance。"""
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
    """修改最小配置的指定 cell 并写入 setup.kore，供拓扑解析器独立读取。"""
    root = KoreParser(FIXTURE.read_text()).pattern()
    symbols = {"Lbl'-LT-'" + name + "'-GT-'": value for name, value in replacements.items()}

    def change(node: Pattern) -> Pattern:
        """替换普通 cell 的内容；hw-instances 使用预先构造的完整 cell，避免多包一层。"""
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
    """构造父子实例、重复引用、寄存器别名和多写口存储，可附加未知操作及类型。"""
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
    """从层次夹具建立绑定 run-one 的静态目录，供各目标和候选边断言复用。"""
    with KoreReader() as reader:
        return TraceTopology.from_state('run-one', reader.read(_hierarchy(tmp_path)))


def test_shared_aliases_register_names_and_static_boundaries(topology: TraceTopology) -> None:
    """验证共享信号保留全部端口与寄存器别名，跨实例 direct 边仍作为静态候选。"""
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
    """验证重复操作数按位置保留独立边，并保留操作的实例、SSA、属性和原始类型。"""
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
    """验证短名称冲突返回全部候选，而完整点分实例名称能明确定位信号。"""
    with pytest.raises(TraceError) as caught:
        topology.resolve(Target('signal', name='result'))
    assert caught.value.code == StopCode.AMBIGUOUS_TARGET
    assert {item['signal_id'] for item in caught.value.details['candidates']} == {'Demo/%out', 'Demo/unit/%q'}
    assert topology.resolve(Target('signal', name='Demo.unit.result')).signal_id == 'Demo/unit/%q'


def test_memory_families_bind_addresses_and_actual_procedures(topology: TraceTopology) -> None:
    """验证存储目录按地址派生身份，写口仍使用真实 procedure 列表索引。"""
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
    """验证等于深度及极大地址都被声明范围检查拒绝。"""
    with pytest.raises(TraceError) as caught:
        topology.resolve(Target('memory_cell', name='store', address=address))
    assert caught.value.code == StopCode.INVALID_INPUT


def test_target_id_binds_run_kind_and_address(topology: TraceTopology, tmp_path: Path) -> None:
    """验证目标身份不能跨运行、跨类别或更换已绑定存储地址复用。"""
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
    """验证实例重命名保留模块和候选连接结构，同时改变其绑定目标身份。"""
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
    """验证未知操作与类型保留原始信息及可解析边，不妨碍其他有效目标。"""
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
    """验证最小真实夹具保留声明名、输出别名及 register-proc 原始记录。"""
    with KoreReader() as reader:
        topology = TraceTopology.from_state('run', reader.read(FIXTURE))
    assert topology.resolve(Target('register', name='count')).aliases == ('Demo/count', 'Demo/mirror', 'Demo/result')
    assert 'Demo/%read' in topology.register_proc


def test_unnamed_signal_uses_instance_module_and_local_ssa(topology: TraceTopology) -> None:
    """验证无端口别名的信号仍可按完整 SSA 路径或目标身份定位，并保留模块归属。"""
    target = topology.resolve(Target('signal', name='Demo/unit/%sum'))
    assert target.name == target.signal_id == 'Demo/unit/%sum'
    assert target.aliases == ()
    assert target.module_symbol == 'ChildModule'
    assert topology.resolve(Target('signal', target_id=target.target_id)) == target


def test_unknown_port_type_is_retained_without_losing_other_targets(tmp_path: Path) -> None:
    """验证未知端口类型只标记本目标不支持，其他寄存器目标仍可解析。"""
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
    """验证同一信号的不同端口声明位宽冲突时拒绝构造拓扑。"""
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
    """验证已过期截止时间和未完成 setup 都不能建立可信静态目录。"""
    with KoreReader() as reader:
        setup = reader.read(FIXTURE)
    with pytest.raises(TraceError) as caught:
        TraceTopology.from_state('run', setup, deadline=time.monotonic() - 1)
    assert caught.value.code == StopCode.TIME_BUDGET
    with pytest.raises(TraceError) as caught:
        TraceTopology.from_state('run', replace(setup, completion=CompletionEvidence('incomplete')))
    assert caught.value.code == StopCode.INCOMPLETE_EXECUTION


def _run(setup: DecodedState, *, top: str = 'Demo', width: int = 8) -> RunArtifacts:
    """构造提供指定 setup 的最小 RunArtifacts 替身，允许改变 manifest 顶层或端口位宽。"""
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
    """验证从运行建立拓扑会核对 manifest 顶层模块与端口，身份冲突时拒绝。"""
    with KoreReader() as reader:
        setup = reader.read(FIXTURE)
    assert TraceTopology.from_run(_run(setup)).top_module == 'Demo'
    for run in (_run(setup, top='Other'), _run(setup, width=7)):
        with pytest.raises(TraceError) as caught:
            TraceTopology.from_run(run)
        assert caught.value.code == StopCode.IDENTITY_MISMATCH
