"""组件契约的配置、实例隔离和独立 checker 边界；合成拓扑不冒充真实 K 验证。"""

from __future__ import annotations

import hashlib
import json
import runpy
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from pyk.kore.prelude import list_pattern, map_pattern
from pyk.kore.syntax import App

from kcirct.trace import TraceRun
from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.contracts import (
    BindingReport,
    ComponentBinding,
    ComponentContract,
    ContractHandshake,
    ContractPort,
    ContractProfile,
    ContractTarget,
    InitialState,
    ParameterRule,
    _initial,
    _layout,
    _parameters,
    bind_component,
    contract_sha256,
)
from kcirct.trace.kore import KoreReader
from kcirct.trace.model import ArtifactRef, BitVector, StopCode, Target, TraceError
from kcirct.trace.topology import TraceTopology

from .test_trace_query import PROFILE, artifact, small_run
from .test_trace_register import register_run
from .test_trace_topology import _cell, _changed, _instance, _operation, _value

if TYPE_CHECKING:
    from collections.abc import Callable
    from typing import Any


def _contract(*, parameterized: bool = False) -> ComponentContract:
    """构造明确模板；测试 profile 哈希只是占位，公共绑定应拒绝未核验运行。"""
    width = 'WIDTH' if parameterized else 8
    return ComponentContract(
        'add-one',
        '1',
        (ContractPort('data', 'input', width), ContractPort('result', 'output', width)),
        (ContractTarget('output', 'signal', width, port='result'),),
        (ParameterRule('WIDTH', 8, 16, (8, 16)),) if parameterized else (),
        (),
        (ContractProfile('1' * 64, '2' * 64),),
        '3' * 64,
        'add_one/v1',
        'result=data+1',
        'combinational',
        2,
        '1ns',
    )


def _binding(contract: ComponentContract, instance: str = 'Demo/left') -> ComponentBinding:
    """配置夹具不声明任何 checker 执行或真实 definition 验证。"""
    return ComponentBinding(
        'binding',
        contract_sha256(contract),
        'run',
        '4' * 64,
        '5' * 64,
        '2' * 64,
        instance,
        'AddOne',
        {'data': 'input', 'result': 'result'},
        {'output': 'result'},
        {'WIDTH': 8} if contract.parameters else {},
        ArtifactRef('checker', 'checker.py', '3' * 64, 0),
        {},
        'unit-test',
        'fixture-v1',
        'synthetic-fixture',
    )


def _two_instances(tmp_path: Path) -> TraceTopology:
    """独立构造两个同模块实例，所有名字保持对应的层次路径。"""
    eight = _value('i8', 'SignlessIntegerType')
    connections = {'Demo/%x': _value('Demo/left/%out'), 'Demo/%y': _value('Demo/right/%out')}
    for instance, parent in (('left', 'a'), ('right', 'b')):
        prefix = 'Demo/' + instance
        connections[prefix + '/%in'] = _value('Demo/%' + parent)
        connections[prefix + '/%one'] = _operation('hw.constant', (), eight)
        connections[prefix + '/%out'] = _operation('comb.add', (prefix + '/%in', prefix + '/%one'), eight)
    instances = (
        _instance('Demo', 'Wrapper', (('a', 'Demo/%a'), ('b', 'Demo/%b')), (('x', 'Demo/%x'), ('y', 'Demo/%y'))),
        _instance('Demo/left', 'AddOne', (('input', 'Demo/left/%in'),), (('result', 'Demo/left/%out'),)),
        _instance('Demo/right', 'AddOne', (('input', 'Demo/right/%in'),), (('result', 'Demo/right/%out'),)),
    )
    group = App(
        "Lbl'Unds'HwInstanceCellMap'Unds'",
        args=(instances[0], App("Lbl'Unds'HwInstanceCellMap'Unds'", args=instances[1:])),
    )
    setup = _changed(
        tmp_path,
        {
            'connection': map_pattern(*((_value(signal), value) for signal, value in connections.items())),
            'register': map_pattern(),
            'register-proc': map_pattern(),
            'procedures': list_pattern(),
            'hw-instances': _cell('hw-instances', group, _cell('hw-setup-inst', list_pattern())),
        },
    )
    with KoreReader() as reader:
        return TraceTopology.from_state('run', reader.read(setup))


def test_templates_and_bindings_roundtrip_without_execution_claims() -> None:
    """严格格式往返保留所有字段，绑定本身没有 checker pass 字段。"""
    contract = _contract()
    binding = _binding(contract)
    assert ComponentContract.from_json(contract.to_json()) == contract
    assert ComponentBinding.from_json(binding.to_json()) == binding
    document = binding.to_dict()
    document['checker_status'] = 'passed'
    with pytest.raises(TraceError):
        ComponentBinding.from_dict(document)


def test_same_module_instances_remain_separate(tmp_path: Path) -> None:
    """相同模块和端口名在两个显式实例上得到不同 target_id 与真实信号。"""
    topology = _two_instances(tmp_path)
    contract = _contract()
    left_ports, left_targets, left = _layout(topology, contract, _binding(contract))
    right_ports, right_targets, right = _layout(topology, contract, _binding(contract, 'Demo/right'))
    assert left['output'].signal_id == 'Demo/left/%out'
    assert right['output'].signal_id == 'Demo/right/%out'
    assert left_targets['output'] != right_targets['output']
    assert left_ports['data'] != right_ports['data']


@pytest.mark.parametrize(
    'change',
    [
        {'instance': 'left'},
        {'instance': 'Demo/missing'},
        {'module_symbol': 'Other'},
        {'ports': {'data': 'missing', 'result': 'result'}},
        {'ports': {'result': 'result'}},
        {'targets': {'output': '%one'}},
    ],
)
def test_wrong_instance_module_port_and_target_are_rejected(tmp_path: Path, change: dict[str, Any]) -> None:
    """不会补猜省略的层次、缺端口或与语义输出不符的内部对象。"""
    topology = _two_instances(tmp_path)
    contract = _contract()
    with pytest.raises(TraceError):
        _layout(topology, contract, replace(_binding(contract), **change))


def test_cross_instance_relative_mapping_is_rejected() -> None:
    """组件内名称不能通过路径穿越指向邻居实例。"""
    contract = _contract()
    with pytest.raises(TraceError):
        replace(_binding(contract), targets={'output': '../right/result'})


def test_parameter_bounds_and_width_are_independent_checks(tmp_path: Path) -> None:
    """合法参数值也须与实际端口宽度相容，不能只验证配置字典。"""
    topology = _two_instances(tmp_path)
    contract = _contract(parameterized=True)
    binding = _binding(contract)
    _parameters(contract, binding)
    _layout(topology, contract, binding)
    wide = replace(binding, parameters={'WIDTH': 16})
    _parameters(contract, wide)
    with pytest.raises(TraceError) as caught:
        _layout(topology, contract, wide)
    assert caught.value.code == StopCode.IDENTITY_MISMATCH
    for values in ({}, {'WIDTH': 9}, {'WIDTH': 8, 'EXTRA': 1}):
        with pytest.raises(TraceError):
            _parameters(contract, replace(binding, parameters=values))


def test_required_clock_and_reset_shape_are_explicit() -> None:
    """单时钟合同不能缺时钟，reset 有效电平和一位输入形状不可省略。"""
    with pytest.raises(TraceError):
        replace(_contract(), clocking='single_clock')
    with pytest.raises(TraceError):
        ContractPort('reset', 'input', 1, 'reset')
    with pytest.raises(TraceError):
        ContractPort('clk', 'input', 8, 'clock')


def test_handshake_guards_bind_declared_ports_without_dropping_data() -> None:
    """握手必须指向实际端口，不能用不存在/多位状态限定值检查。"""
    base = _contract()
    contract = replace(
        base,
        ports=(*base.ports, ContractPort('ready', 'output', 1, 'status')),
        handshakes=(ContractHandshake('result_valid', ('result',), 'ready'),),
    )
    assert ComponentContract.from_json(contract.to_json()) == contract
    for change in ({'qualifier': 'missing'}, {'qualifier': 'data'}, {'data_ports': ('missing',)}):
        with pytest.raises(TraceError):
            replace(contract, handshakes=(replace(contract.handshakes[0], **change),))
    with pytest.raises(TraceError):
        replace(contract, handshakes=(*contract.handshakes, ContractHandshake('duplicate', ('result',), 'ready', 0)))
    # 没有握手的早期 v1 模板仍使用同一规范身份。
    document = base.to_dict()
    document.pop('handshakes')
    expected = hashlib.sha256(
        json.dumps(document, sort_keys=True, separators=(',', ':'), ensure_ascii=False).encode()
    ).hexdigest()
    assert contract_sha256(base) == expected


def test_initialization_uses_actual_setup_not_unknown_manifest(tmp_path: Path) -> None:
    """已保存寄存器初值必须满足模板；manifest 初始化缺省 unknown 不能替代实际核验。"""
    path = register_run(tmp_path, [{'a': 7, 'c': 1, 'r': 7}], setup={'r': 5, 'c': 0})
    contract = replace(
        _contract(),
        targets=(ContractTarget('state', 'register', 8),),
        ports=(ContractPort('clk', 'input', 1, 'clock'),),
        clocking='single_clock',
        initialization=(InitialState('state', BitVector.from_int(5, 8)),),
    )
    binding = replace(_binding(contract), instance='Demo')
    with RunArtifacts.open(path) as run:
        topology = TraceTopology.from_run(run)
        targets = {'state': topology.resolve(Target('register', name='Demo/%r'))}
        values = _initial(run, topology, contract, binding, targets, PROFILE)
        assert values['state']['value']['value'] == '5'
        with pytest.raises(TraceError):
            _initial(run, topology, replace(contract, initialization=()), binding, targets, PROFILE)
        with pytest.raises(TraceError):
            _initial(
                run,
                topology,
                replace(contract, initialization=(InitialState('state', BitVector.from_int(0, 8)),)),
                binding,
                targets,
                PROFILE,
            )


def test_public_binding_rejects_unverified_synthetic_run(tmp_path: Path) -> None:
    """合成快照不能借契约绕过运行/profile 内容身份核验。"""
    from kcirct.trace.model import RunManifest

    path = small_run(tmp_path)
    design = tmp_path / 'synthetic-ir.txt'
    design.write_text('identity fixture, not executable\n')
    manifest = RunManifest.from_json(path.read_text())
    execution = artifact(design, tmp_path, 'execution_ir')
    path.write_text(replace(manifest, artifacts=dict(manifest.artifacts, execution=execution)).to_json())
    run = TraceRun.open(path)
    contract = _contract()
    binding = replace(
        _binding(contract), run_id=run.run_id, manifest_sha256=run.manifest_sha256, execution_ir_sha256=execution.sha256
    )
    with pytest.raises(TraceError) as caught:
        bind_component(run, contract, binding, carrier=tmp_path / 'binding.json')
    assert caught.value.code == StopCode.UNSUPPORTED_SEMANTICS


def test_binding_hash_changes_when_instance_or_checker_changes() -> None:
    """新实例或 checker 内容产生新绑定身份，旧检查结果不可沿用。"""
    contract = _contract()
    first = _binding(contract)
    assert contract_sha256(first) != contract_sha256(replace(first, instance='Demo/right'))
    assert contract_sha256(first) != contract_sha256(replace(first, checker=replace(first.checker, sha256='0' * 64)))


def test_binding_report_cannot_claim_checker_pass() -> None:
    """成功解析配置仍必须等待本次独立 checker 执行。"""
    report = BindingReport('binding', 'run', '1' * 64, '2' * 64, 'ready', {}, {}, {}, {}, ())
    document = report.to_dict()
    document['checker_status'] = 'passed'
    with pytest.raises(TraceError):
        BindingReport.from_dict(document)


def _checker() -> dict[str, Any]:
    path = Path(__file__).parents[1] / 'resources/trace/contracts-v2/checker.py'
    return runpy.run_path(str(path))


def _sample(**values: int) -> dict[str, Any]:
    return {
        'observation': {'event_index': 0},
        'values': {name: BitVector.from_int(value, 8).to_dict() for name, value in values.items()},
    }


def test_independent_checker_wraparound_and_controlled_failure() -> None:
    """独立参考明确检查模加、失败和非空输入，不调用被测 trace 解释函数。"""
    checker: Callable[..., dict[str, Any]] = _checker()['check']
    document = {
        'run_id': 'run',
        'manifest_sha256': '1' * 64,
        'binding_sha256': '2' * 64,
        'checker_sha256': '3' * 64,
        'checker_interface': 'add_one/v1',
        'samples': [_sample(data=255, result=0), _sample(data=5, result=6)],
    }
    assert checker(document)['verdict'] == 'pass'
    document['samples'] = [_sample(data=5, result=7)]
    result = checker(document)
    assert result['verdict'] == 'fail' and result['violations'][0]['expected'] == 6
    document['samples'] = []
    with pytest.raises(ValueError):
        checker(document)


def test_independent_register_checker_respects_edges_and_reset_priority() -> None:
    """手工冻结输入表区分无沿 reset 与有沿 reset、保持和选择来源。"""
    expected: Callable[..., list[int]] = _checker()['expected_values']
    samples = [
        _sample(clk=0, reset=0, sel=1, a=4, b=9),
        _sample(clk=1, reset=0, sel=1, a=4, b=9),
        _sample(clk=1, reset=1, sel=0, a=4, b=9),
        _sample(clk=0, reset=1, sel=0, a=4, b=9),
        _sample(clk=1, reset=1, sel=0, a=4, b=9),
        _sample(clk=0, reset=0, sel=0, a=4, b=9),
        _sample(clk=1, reset=0, sel=0, a=4, b=9),
    ]
    assert expected('register_mux/v1', samples) == [7, 4, 4, 4, 0, 0, 9]
