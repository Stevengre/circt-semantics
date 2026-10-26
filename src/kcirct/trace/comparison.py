"""显式合同约束的双运行解释；名称、值相等和时间邻近都不构成隐式映射。"""

from __future__ import annotations

import hashlib
import json
import os
from dataclasses import dataclass, field, fields
from pathlib import Path
from typing import TYPE_CHECKING, Any, Literal, cast

from .kore import bit_vector
from .model import (  # noqa: TC001 -- JsonModel 在运行时解析这些字段类型。
    ArtifactRef,
    BitVector,
    Budget,
    JsonModel,
    QueryRequest,
    RecordRef,
    StopCode,
    Target,
    TraceError,
    TraceReport,
    _digest,
    _nonempty,
)
from .semantics import bind_semantics, bounded_width, memory_contents, memory_dimensions, register_initial
from .topology import TraceTopology

if TYPE_CHECKING:
    from . import TraceRun
    from .artifacts import RunArtifacts
    from .model import CheckRecord, TraceEdge, TraceNode
    from .semantics import SemanticsProfile
    from .topology import TargetBinding


@dataclass(frozen=True)
class PairSide(JsonModel):
    """固定一侧运行与设计；参数是绑定这些字节的显式声明，不冒充自动证明。"""

    run_id: str
    manifest_sha256: str
    execution_ir_sha256: str
    parameters: dict[str, str | int | bool]

    def _validate(self) -> None:
        """拒绝缺失身份和用 unknown 状态代替显式参数合同。"""
        _nonempty(self.run_id, 'run_id')
        _digest(self.manifest_sha256, 'manifest_sha256')
        _digest(self.execution_ir_sha256, 'execution_ir_sha256')
        if 'status' in self.parameters and self.parameters['status'] == 'unknown':
            raise TraceError(StopCode.INVALID_INPUT, '参数合同不能以 status=unknown 代替参数值')


@dataclass(frozen=True)
class InputPair(JsonModel):
    """显式输入名称映射及调用者声明的时钟、复位角色。"""

    id: str
    left: str
    right: str
    role: Literal['data', 'clock', 'reset'] = 'data'
    active_value: int | None = None

    def _validate(self) -> None:
        """要求复位有效电平明确，普通数据和时钟不携带复位声明。"""
        for name in ('id', 'left', 'right'):
            _nonempty(getattr(self, name), name)
        if self.role == 'reset' and self.active_value not in (0, 1):
            raise TraceError(StopCode.INVALID_INPUT, 'reset 输入必须声明 active_value=0 或 1')
        if self.role != 'reset' and self.active_value is not None:
            raise TraceError(StopCode.INVALID_INPUT, '只有 reset 输入可声明 active_value')


@dataclass(frozen=True)
class TargetPair(JsonModel):
    """一对明确目标，包含实例、位宽和地址的运行内解析须另行核验。"""

    id: str
    left: Target
    right: Target

    def _validate(self) -> None:
        """映射两端保持目标种类；位切片不作为跨运行基础身份。"""
        _nonempty(self.id, 'id')
        if self.left.kind != self.right.kind:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '映射目标种类不同', mapping=self.id)
        if self.left.bit_range is not None or self.right.bit_range is not None:
            raise TraceError(StopCode.INVALID_INPUT, '基础目标映射须覆盖完整位宽；查询仍可指定同一位切片')


@dataclass(frozen=True)
class PairContract(JsonModel):
    """首版只比较同一已核验 profile，要求全部架构存储显式重绑定。"""

    id: str
    left: PairSide
    right: PairSide
    inputs: tuple[InputPair, ...]
    initial_state: tuple[TargetPair, ...]
    initial_state_coverage: Literal['all_storage']
    semantics_source_sha256: str
    definition_sha256: str
    evaluations_per_input: int
    timescale: str
    sampling_phase: Literal['dump'] = 'dump'

    def _validate(self) -> None:
        """拒绝不相容参数、重复输入与不明确的采样合同。"""
        _nonempty(self.id, 'id')
        _digest(self.semantics_source_sha256, 'semantics_source_sha256')
        _digest(self.definition_sha256, 'definition_sha256')
        if self.left.parameters != self.right.parameters:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '两侧显式参数合同不同')
        if self.evaluations_per_input <= 0 or not self.timescale:
            raise TraceError(StopCode.INVALID_INPUT, '必须声明有效的求值次数和时间单位')
        if not self.inputs:
            raise TraceError(StopCode.INVALID_INPUT, '输入映射不能为空')
        for key in ('id', 'left', 'right'):
            values = [getattr(item, key) for item in self.inputs]
            if len(set(values)) != len(values):
                raise TraceError(StopCode.DUPLICATE_IDENTITY, '输入映射必须一对一', field=key)
        if sum(item.role == 'clock' for item in self.inputs) > 1:
            raise TraceError(StopCode.UNSUPPORTED_CLOCK, '双运行首版不接受多时钟合同')
        if len({item.id for item in self.initial_state}) != len(self.initial_state):
            raise TraceError(StopCode.DUPLICATE_IDENTITY, '初态映射 ID 重复')
        if any(item.left.kind not in {'register', 'memory_cell'} for item in self.initial_state):
            raise TraceError(StopCode.INVALID_INPUT, '初态映射只接受 register 或明确地址的 memory_cell')


@dataclass(frozen=True)
class PairRequest(JsonModel):
    """两侧查询具有各自预算；合同核验另有独立、明确的每侧预算。"""

    left: QueryRequest
    right: QueryRequest | None = None
    mappings: tuple[TargetPair, ...] = ()
    validation_budget: Budget = field(default_factory=Budget)

    def _validate(self) -> None:
        """拒绝单侧入口携带虚构映射，以及不同窗口的双侧比较。"""
        if self.right is None and self.mappings:
            raise TraceError(StopCode.INVALID_INPUT, '单运行请求不能携带双运行映射')
        if self.right is not None:
            if not self.mappings:
                raise TraceError(StopCode.INVALID_INPUT, '双运行请求需要显式目标映射')
            if self.left.window != self.right.window:
                raise TraceError(StopCode.IDENTITY_MISMATCH, '两侧查询窗口不同')
        if len({item.id for item in self.mappings}) != len(self.mappings):
            raise TraceError(StopCode.DUPLICATE_IDENTITY, '目标映射 ID 重复')


@dataclass(frozen=True)
class NodePair(JsonModel):
    """以显式映射和完整执行坐标对齐的两个原始证据节点。"""

    mapping: str
    left: str
    right: str
    coordinate: dict[str, Any]


DifferenceKind = Literal['value', 'control_selection', 'update', 'dependency', 'static_candidate']


@dataclass(frozen=True)
class PairDifference(JsonModel):
    """局部观察差异，不是唯一根因或正确修复证明。"""

    kind: DifferenceKind
    pair: NodePair
    details: dict[str, Any]


@dataclass(frozen=True)
class PairReport(JsonModel):
    """保留完整单侧报告、未匹配项和显式假设，分别报告差异及比较完整性。"""

    id: str
    mode: Literal['paired', 'single_run']
    comparison_status: Literal['not_run', 'matched', 'different', 'partial']
    comparability: Literal['not_applicable', 'conditional', 'partial']
    left_run: RecordRef
    left: TraceReport
    right_run: RecordRef | None = None
    right: TraceReport | None = None
    contract: PairContract | None = None
    contract_sha256: str | None = None
    assumptions_verified: bool = False
    verified: dict[str, Any] = field(default_factory=dict)
    node_pairs: tuple[NodePair, ...] = ()
    common_edges: tuple[dict[str, Any], ...] = ()
    differences: tuple[PairDifference, ...] = ()
    first_observed_divergence: tuple[PairDifference, ...] = ()
    unmatched: tuple[dict[str, Any], ...] = ()
    limitations: tuple[str, ...] = ()
    evidence_carriers: dict[str, RecordRef] = field(default_factory=dict)

    def _validate(self) -> None:
        """单侧报告不能夹带虚构比较结论，双侧报告必须绑定实际合同和运行。"""
        _nonempty(self.id, 'id')
        _digest(self.contract_sha256, 'contract_sha256')
        if self.left_run.id != self.left.run_id:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '左侧报告与运行引用不一致')
        if self.left.run is not None and self.left_run.sha256 != self.left.run.sha256:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '左侧运行 manifest 在查询后改变')
        if self.assumptions_verified:
            raise TraceError(StopCode.INVALID_INPUT, '首版尚不自动证明参数和控制角色假设')
        if self.mode == 'single_run':
            if self.comparison_status != 'not_run' or self.comparability != 'not_applicable':
                raise TraceError(StopCode.INVALID_INPUT, '单运行不能声称执行了比较')
            if self.right is not None or self.right_run is not None or self.contract is not None or self.differences:
                raise TraceError(StopCode.INVALID_INPUT, '单运行含无效的参考工件或差异')
        elif self.right is None or self.right_run is None or self.contract is None:
            raise TraceError(StopCode.INVALID_INPUT, '双运行缺少参考报告、运行引用或合同')
        elif self.right_run.id != self.right.run_id:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '右侧报告与运行引用不一致')
        elif self.right.run is not None and self.right_run.sha256 != self.right.run.sha256:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '右侧运行 manifest 在查询后改变')
        else:
            if self.comparison_status == 'not_run' or self.comparability == 'not_applicable':
                raise TraceError(StopCode.INVALID_INPUT, '双运行报告不能标为单侧状态')
            for reference, side in ((self.left_run, self.contract.left), (self.right_run, self.contract.right)):
                if (reference.id, reference.sha256) != (side.run_id, side.manifest_sha256):
                    raise TraceError(StopCode.IDENTITY_MISMATCH, '报告运行引用与合同比较身份不同')
            if self.contract_sha256 != hashlib.sha256(_canonical(self.contract.to_dict()).encode()).hexdigest():
                raise TraceError(StopCode.HASH_MISMATCH, '报告合同内容与摘要不同')
            if self.comparison_status == 'matched' and (
                self.differences or self.unmatched or self.left.frontier or self.right.frontier
            ):
                raise TraceError(StopCode.INVALID_INPUT, '存在差异或未完成边界时不能声称完整匹配')
            if self.comparison_status == 'different' and not self.differences:
                raise TraceError(StopCode.INVALID_INPUT, '差异结论缺少具体观察证据')
            left_nodes = {node.id for node in self.left.nodes}
            right_nodes = {node.id for node in self.right.nodes}
            if any(pair.left not in left_nodes or pair.right not in right_nodes for pair in self.node_pairs):
                raise TraceError(StopCode.IDENTITY_MISMATCH, '映射必须引用所保存的两侧节点')


def _canonical(value: Any) -> str:
    """输出稳定 JSON，供摘要和与显示顺序无关的证据排序使用。"""
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(',', ':'), allow_nan=False)


def _portable(value: Any) -> Any:
    """身份摘要忽略引用文件的物理位置，保留其 ID、角色、大小和哈希。"""
    if isinstance(value, (ArtifactRef, RecordRef)):
        return {key: _portable(item) for key, item in value.to_dict().items() if key != 'path'}
    if isinstance(value, JsonModel):
        return {item.name: _portable(getattr(value, item.name)) for item in fields(value)}
    if isinstance(value, (tuple, list)):
        return [_portable(item) for item in value]
    if isinstance(value, dict):
        return {key: _portable(item) for key, item in value.items()}
    return value


def normalized_evidence(report: TraceReport) -> dict[str, Any]:
    """规范化同一运行的语义证据；排除报告 UUID、成本、显示顺序和物理文件位置。

    请求预算仍在原报告保存，但不影响等价语义窗口的摘要。审计工件按内容身份
    比较，路径搬迁不改变该身份。调用方须先校验原工件，摘要本身不是校验器。
    """
    request = _portable(report.request)
    request.pop('budget')
    scope = dict(report.scope)
    if isinstance(scope.get('audit'), dict):
        audit = dict(scope['audit'])
        audit['artifacts'] = sorted(audit.get('artifacts', {}).values())
        audit['history_edges'] = sorted(audit.get('history_edges', []))
        scope['audit'] = audit
    if isinstance(scope.get('memory_writes'), list):
        scope['memory_writes'] = sorted(scope['memory_writes'], key=_canonical)
    return {
        'schema_version': 1,
        'run_id': report.run_id,
        'run': _portable(report.run),
        'request': request,
        'status': _portable(report.status),
        'check': _portable(report.check),
        'nodes': sorted((_portable(item) for item in report.nodes), key=_canonical),
        'edges': sorted((_portable(item) for item in report.edges), key=_canonical),
        'frontier': sorted((_portable(item) for item in report.frontier), key=_canonical),
        'artifacts': sorted((_portable(item) for item in report.artifacts), key=_canonical),
        'scope': scope,
        'limitations': sorted(report.limitations),
    }


def evidence_sha256(report: TraceReport) -> str:
    """计算规范化语义证据的 SHA-256，供查询会话保存和重放核对。"""
    return hashlib.sha256(_canonical(normalized_evidence(report)).encode()).hexdigest()


def _role(run: RunArtifacts, role: str) -> ArtifactRef:
    """要求关键角色唯一并核验实际字节，不从文件名猜测输入或设计。"""
    refs = [ref for ref in run.manifest.artifacts.values() if ref.role == role]
    if len(refs) != 1:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '双运行需要唯一的关键工件', role=role, count=len(refs))
    run.resolve(refs[0])
    return refs[0]


def _side(run: RunArtifacts, side: PairSide, contract: PairContract, profile: SemanticsProfile) -> None:
    """核验一侧工件、同 profile 和采样约定，不把 unknown 初态作为证据。"""
    if (run.manifest.run_id, run.manifest_sha256) != (side.run_id, side.manifest_sha256):
        raise TraceError(StopCode.IDENTITY_MISMATCH, '运行与双运行合同身份不同')
    if _role(run, 'execution_ir').sha256 != side.execution_ir_sha256:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '执行 IR 与双运行合同不同')
    if profile.binding != 'source_and_definition_verified' or (
        profile.source_sha256,
        profile.definition_sha256,
    ) != (contract.semantics_source_sha256, contract.definition_sha256):
        raise TraceError(StopCode.UNSUPPORTED_SEMANTICS, '双运行只接受合同指定且源码和编译定义均已核验的同一 profile')
    expected = {
        'evaluations_per_input': contract.evaluations_per_input,
        'timescale': contract.timescale,
        'sampling_phase': contract.sampling_phase,
    }
    if any(run.manifest.protocol.get(key) != value for key, value in expected.items()):
        raise TraceError(StopCode.IDENTITY_MISMATCH, '运行采样约定与双运行合同不同')
    recorded = run.manifest.parameters.get('values')
    if recorded is not None and recorded != side.parameters:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '运行记录的参数值与显式合同不同')


def _input_values(run: RunArtifacts, contract: PairContract, side: Literal['left', 'right']) -> list[Any]:
    """验证完整输入事件并按显式端口映射规范化，不依赖 JSON 字段顺序。"""
    from .artifacts import _json

    reference = _role(run, 'inputs')
    path = run.resolve(reference)
    document = _json(run._text(path, run.reader.budget.max_state_bytes))
    if (
        not isinstance(document, dict)
        or set(document) != {'schema_version', 'timescale', 'events'}
        or type(document['schema_version']) is not int
        or document['schema_version'] != 1
        or document['timescale'] != contract.timescale
        or not isinstance(document['events'], list)
        or not document['events']
    ):
        raise TraceError(StopCode.INVALID_INPUT, '双运行需要明确的 schema_version=1 输入事件文件')
    ports = {port.name: port.width for port in run.manifest.ports if port.direction == 'input'}
    mapping = {getattr(item, side): item for item in contract.inputs}
    if set(ports) != set(mapping):
        raise TraceError(StopCode.IDENTITY_MISMATCH, '输入映射未恰好覆盖全部顶层输入端口', side=side)
    for name, item in mapping.items():
        if item.role != 'data' and ports[name] != 1:
            raise TraceError(StopCode.UNSUPPORTED_CLOCK, '时钟和复位角色必须对应一位输入', port=name)
    events = []
    previous = -1
    for event in document['events']:
        run._deadline()
        if (
            not isinstance(event, dict)
            or set(event) != {'time', 'inputs'}
            or type(event['time']) is not int
            or event['time'] <= previous
            or not isinstance(event['inputs'], dict)
            or set(event['inputs']) != set(ports)
        ):
            raise TraceError(StopCode.INVALID_INPUT, '输入事件须完整且时间严格递增')
        values = {}
        for name, width in ports.items():
            value = event['inputs'][name]
            if type(value) is not int or not 0 <= value < 1 << bounded_width(width):
                raise TraceError(StopCode.INVALID_INPUT, '输入值不在声明位宽范围内', port=name)
            values[mapping[name].id] = {'width': width, 'value': value}
        previous = event['time']
        events.append({'time': previous, 'inputs': values})
    run.resolve(reference)
    return events


def _endpoint(binding: TargetBinding) -> tuple[str, str | None]:
    """得到真实信号或写口身份；memory_cell 地址作为身份的一部分。"""
    if binding.kind == 'memory_write_port':
        return f'procedure:{binding.procedure_index}', None
    if binding.signal_id is None:
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '映射目标没有可核验的信号身份')
    return binding.signal_id, binding.address


def _bindings(
    mappings: tuple[TargetPair, ...], left: TraceTopology, right: TraceTopology
) -> tuple[dict[tuple[str, str | None], str], dict[tuple[str, str | None], str]]:
    """两侧独立解析并核对实例/类型/位宽；拒绝别名掩盖的一对多映射。"""
    result: tuple[dict[tuple[str, str | None], str], dict[tuple[str, str | None], str]] = ({}, {})
    for item in mappings:
        first, second = left.resolve(item.left), right.resolve(item.right)
        if first.width is None or first.width != second.width or first.shape != second.shape:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '映射目标位宽或存储形状不同', mapping=item.id)
        for index, binding in enumerate((first, second)):
            endpoint = _endpoint(binding)
            if endpoint in result[index]:
                raise TraceError(StopCode.DUPLICATE_IDENTITY, '不同映射解析到同一真实目标', mapping=item.id)
            result[index][endpoint] = item.id
    return result


def _initial_values(
    run: RunArtifacts,
    topology: TraceTopology,
    mappings: dict[tuple[str, str | None], str],
    profile: SemanticsProfile,
) -> dict[str, Any]:
    """核验全部架构存储覆盖和实际 setup 值，缺项只使用绑定 profile 的显式初值规则。"""
    state = run.read_state(run.setup_id)
    storage = {node.signal_id: node for node in topology.nodes.values() if node.storage_kind is not None}
    if any(node.storage_kind == 'memory_cell' and (node.shape or {}).get('depth', 0) <= 0 for node in storage.values()):
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '初态覆盖需要明确的 memory 深度')
    expected_count = sum(
        (node.shape or {}).get('depth', 0) if node.storage_kind == 'memory_cell' else 1 for node in storage.values()
    )
    if len(mappings) != expected_count:
        raise TraceError(
            StopCode.IDENTITY_MISMATCH,
            '初态映射没有覆盖全部架构存储',
            mapped=len(mappings),
            required=expected_count,
        )
    result = {}
    memories: dict[str, dict[int, BitVector]] = {}
    for (signal, address), logical in mappings.items():
        run._deadline()
        node = storage.get(signal)
        if node is None or node.unsupported:
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, '初态映射不是受支持的架构存储', target=signal)
        if node.storage_kind == 'register':
            if node.operation is None or address is not None:
                raise TraceError(StopCode.IDENTITY_MISMATCH, '寄存器初态映射形状错误')
            initial, origin = register_initial(node.operation, profile)
            value = bit_vector(state.signals[signal]) if signal in state.signals else initial
            origin = 'saved_setup' if signal in state.signals else origin
            if value.width != node.width:
                raise TraceError(StopCode.INCONSISTENT_EVIDENCE, '寄存器初态值位宽与声明不同')
        elif node.storage_kind == 'memory_cell' and address is not None:
            if signal not in memories:
                writers = [
                    op for op in topology.procedures if op.name == 'seq.firmem.write_port' and op.operands[0] == signal
                ]
                if len(writers) != 1:
                    raise TraceError(StopCode.UNSUPPORTED_SHAPE, '初态比较只支持单写口 memory')
                dimensions = memory_dimensions(node, writers[0])
                memories[signal] = memory_contents(state.signals.get(signal), dimensions)
            value = memories[signal].get(int(address), BitVector.from_int(0, (node.shape or {})['width']))
            if not 0 <= int(address) < (node.shape or {})['depth']:
                raise TraceError(StopCode.INVALID_INPUT, '初态 memory 地址越界')
            origin = 'saved_setup' if int(address) in memories[signal] else 'bound_empty_memory_default_zero'
        else:
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, '初态映射缺少完整存储地址')
        result[logical] = {
            'value': value.to_dict(),
            'origin': origin,
            'state_id': run.setup_id,
            'content_sha256': state.uncompressed_sha256,
        }
    return result


def _validate_pair(
    left: RunArtifacts,
    right: RunArtifacts,
    contract: PairContract,
    request: PairRequest,
    left_profile: SemanticsProfile,
    right_profile: SemanticsProfile,
) -> tuple[dict[str, Any], tuple[dict[tuple[str, str | None], str], dict[tuple[str, str | None], str]]]:
    """核验合同并返回可审查依据；公开入口独立绑定 profile，不接受调用者选择解释器。"""
    _side(left, contract.left, contract, left_profile)
    _side(right, contract.right, contract, right_profile)
    first_inputs, second_inputs = _input_values(left, contract, 'left'), _input_values(right, contract, 'right')
    if first_inputs != second_inputs:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '两侧实际输入事件、时间或位宽不同')
    first_topology, second_topology = TraceTopology.from_run(left), TraceTopology.from_run(right)
    initial_maps = _bindings(contract.initial_state, first_topology, second_topology)
    initials = (
        _initial_values(left, first_topology, initial_maps[0], left_profile),
        _initial_values(right, second_topology, initial_maps[1], right_profile),
    )
    if any(initials[0][key]['value'] != initials[1][key]['value'] for key in initials[0]):
        raise TraceError(StopCode.IDENTITY_MISMATCH, '映射架构存储的实际 setup 初值不同')
    if contract.initial_state and not any(item.role == 'clock' for item in contract.inputs):
        raise TraceError(StopCode.UNSUPPORTED_CLOCK, '含架构存储的比较必须显式声明单时钟输入')
    mappings = _bindings(request.mappings, first_topology, second_topology)
    # setup 时钟有值与缺值的 bootstrap 行为不同，不能仅比较寄存器初值。
    for item in contract.inputs:
        if item.role not in {'clock', 'reset'}:
            continue
        controls = []
        for run, topology, name in ((left, first_topology, item.left), (right, second_topology, item.right)):
            ports = [
                alias
                for alias in topology.port_aliases
                if alias.direction == 'input'
                and alias.instance_id == run.manifest.top_module
                and alias.name == f'{run.manifest.top_module}/{name}'
            ]
            if len(ports) != 1:
                raise TraceError(StopCode.IDENTITY_MISMATCH, '控制输入不能唯一绑定到 setup', port=name)
            term = run.read_state(run.setup_id).signals.get(ports[0].signal_id)
            controls.append(bit_vector(term) if term is not None else None)
        if controls[0] != controls[1]:
            raise TraceError(StopCode.IDENTITY_MISMATCH, 'setup 时钟或复位输入状态不同', input=item.id)
    clock_states = []
    for index, (run, topology) in enumerate(((left, first_topology), (right, second_topology))):
        declared_clock = next(
            (getattr(item, ('left', 'right')[index]) for item in contract.inputs if item.role == 'clock'), None
        )
        allowed = {
            alias.signal_id
            for alias in topology.port_aliases
            if alias.name == f'{run.manifest.top_module}/{declared_clock}' and alias.direction == 'input'
        }
        clocks = {
            node.operation.operands[1]
            for node in topology.nodes.values()
            if node.storage_kind == 'register' and node.operation is not None and len(node.operation.operands) >= 2
        }
        clocks.update(
            op.operands[2] for op in topology.procedures if op.name == 'seq.firmem.write_port' and len(op.operands) >= 3
        )
        actual = {}
        setup = run.read_state(run.setup_id)
        for clock in clocks:
            logical = mappings[index].get((clock, None))
            if logical is None:
                raise TraceError(StopCode.IDENTITY_MISMATCH, '架构时钟的初态也必须有显式内部映射', clock=clock)
            signal, seen = clock, set()
            while signal not in allowed:
                run._deadline()
                node = topology.nodes.get(signal)
                if signal in seen or node is None:
                    raise TraceError(StopCode.UNSUPPORTED_CLOCK, '时钟未连接到声明的单一时钟输入', clock=clock)
                seen.add(signal)
                if node.direct_source:
                    signal = node.direct_source
                elif (
                    node.operation is not None
                    and node.operation.name == 'seq.to_clock'
                    and len(node.operation.operands) == 1
                ):
                    signal = node.operation.operands[0]
                else:
                    raise TraceError(
                        StopCode.UNSUPPORTED_CLOCK, '双运行仅接受声明输入的 direct/to_clock 时钟链', clock=clock
                    )
            term = setup.signals.get(clock)
            actual[logical] = bit_vector(term).to_dict() if term is not None else None
        clock_states.append(actual)
    if clock_states[0] != clock_states[1]:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '内部时钟 setup 值或缺值 bootstrap 状态不同')
    assert request.right is not None
    roots = (first_topology.resolve(request.left.target), second_topology.resolve(request.right.target))
    if mappings[0].get(_endpoint(roots[0])) is None or mappings[0].get(_endpoint(roots[0])) != mappings[1].get(
        _endpoint(roots[1])
    ):
        raise TraceError(StopCode.IDENTITY_MISMATCH, '两个查询根没有同一显式映射')
    if request.left.target.bit_range != request.right.target.bit_range:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '两侧查询位切片不同')
    positions = []
    for run, query_request in ((left, request.left), (right, request.right)):
        entry, dump = run.locate(query_request.observation)
        positions.append((entry.phase, entry.event_index, entry.evaluation, dump is not None))
    if positions[0] != positions[1]:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '两个查询观测的 phase/event/evaluation 不同')
    return {
        'inputs': {
            'status': 'verified',
            'events': len(first_inputs),
            'canonical_sha256': hashlib.sha256(_canonical(first_inputs).encode()).hexdigest(),
        },
        'initial_state': {'status': 'verified', 'coverage': 'all_storage', 'left': initials[0], 'right': initials[1]},
        'initial_clocks': {'status': 'verified', 'values': clock_states[0]},
        'profile': {
            'status': 'source_and_definition_verified',
            'source_sha256': left_profile.source_sha256,
            'definition_sha256': left_profile.definition_sha256,
        },
        'sampling': {'status': 'verified', 'coordinate': list(positions[0])},
        'parameters': {'status': 'declared_bound_to_execution_ir', 'values': contract.left.parameters},
        'control_roles': {
            'status': 'declared_ports_and_setup_checked',
            'inputs': [item.to_dict() for item in contract.inputs if item.role != 'data'],
        },
        'validation_cost': {'left': left.cost.to_dict(), 'right': right.cost.to_dict()},
    }, mappings


def _node_key(node: TraceNode, mapping: dict[tuple[str, str | None], str]) -> tuple[Any, ...] | None:
    """以明确映射与完整执行坐标对齐，不使用 SSA 序号或值猜测对应。"""
    logical = mapping.get((node.ref.result, node.ref.address))
    observation = node.observation
    if logical is None or observation is None:
        return None
    return (
        logical,
        observation.phase,
        observation.event_index,
        observation.evaluation,
        node.ref.view,
        node.ref.bit_range.low if node.ref.bit_range else None,
        node.ref.bit_range.high if node.ref.bit_range else None,
    )


def _compare_reports(
    left: TraceReport,
    right: TraceReport,
    mappings: tuple[dict[tuple[str, str | None], str], dict[tuple[str, str | None], str]],
) -> tuple[tuple[NodePair, ...], tuple[dict[str, Any], ...], tuple[PairDifference, ...], tuple[dict[str, Any], ...]]:
    """比较已核验单侧报告；此内部函数不代替公开入口的工件与合同核验。"""
    indexed = []
    unmatched: list[dict[str, Any]] = []
    for side, report, mapping in zip(('left', 'right'), (left, right), mappings, strict=True):
        if report.status.query in {'rejected', 'error'} or report.status.metadata_integrity == 'invalid':
            raise TraceError(StopCode.INCONSISTENT_EVIDENCE, '单侧查询拒绝或失败，不能继续双运行比较', side=side)
        nodes = {}
        for node in report.nodes:
            key = _node_key(node, mapping)
            if key is None:
                unmatched.append({'side': side, 'node_id': node.id, 'reason': 'no_explicit_mapping_or_coordinate'})
            elif key in nodes:
                raise TraceError(StopCode.DUPLICATE_IDENTITY, '同一映射及坐标命中多个节点', side=side)
            else:
                nodes[key] = node
        indexed.append(nodes)
    pairs = []
    differences = []
    common_edges = []
    keys = set(indexed[0]) | set(indexed[1])
    by_id = [{node.id: key for key, node in nodes.items()} for nodes in indexed]
    incoming: list[dict[str, list[TraceEdge]]] = [{node.id: [] for node in report.nodes} for report in (left, right)]
    for index, report in enumerate((left, right)):
        for edge in report.edges:
            incoming[index][edge.target].append(edge)
    for key in sorted(keys, key=lambda item: _canonical(item)):
        if key not in indexed[0] or key not in indexed[1]:
            index = 0 if key in indexed[0] else 1
            unmatched.append(
                {
                    'side': ('left', 'right')[index],
                    'node_id': indexed[index][key].id,
                    'reason': 'mapped_coordinate_absent_on_other_side',
                }
            )
            continue
        first, second = indexed[0][key], indexed[1][key]
        pair = NodePair(
            key[0],
            first.id,
            second.id,
            dict(zip(('phase', 'event_index', 'evaluation', 'view', 'low', 'high'), key[1:], strict=True)),
        )
        pairs.append(pair)
        if first.value is not None and second.value is not None:
            if first.value.width != second.value.width:
                raise TraceError(StopCode.IDENTITY_MISMATCH, '映射节点的实际值位宽不同', mapping=key[0])
            if first.value != second.value:
                differences.append(
                    PairDifference('value', pair, {'left': first.value.to_dict(), 'right': second.value.to_dict()})
                )
        elif (
            first.value is None
            and not first.facts.get('static_candidate')
            and not first.ref.result.startswith('procedure:')
        ) or (
            second.value is None
            and not second.facts.get('static_candidate')
            and not second.ref.result.startswith('procedure:')
        ):
            unmatched.append({'side': 'both', 'left': first.id, 'right': second.id, 'reason': 'value_not_available'})
        for kind, names in (
            ('control_selection', ('selector',)),
            ('update', ('decision', 'edge', 'bootstrap', 'address', 'enable', 'old', 'new', 'data')),
        ):
            changed = {
                name: {'left': first.facts.get(name), 'right': second.facts.get(name)}
                for name in names
                if name in first.facts and name in second.facts and first.facts[name] != second.facts[name]
            }
            if changed:
                differences.append(PairDifference(cast('DifferenceKind', kind), pair, changed))
        edge_sets = []
        for index, node in enumerate((first, second)):
            edges = set()
            for edge in incoming[index][node.id]:
                source = by_id[index].get(edge.source)
                if source is None:
                    continue
                edges.add((source, edge.kind))
            edge_sets.append(edges)
        for source, kind in sorted(edge_sets[0] & edge_sets[1], key=_canonical):
            common_edges.append({'source': list(source), 'target': list(key), 'kind': kind})
        for side, only in (('left', edge_sets[0] - edge_sets[1]), ('right', edge_sets[1] - edge_sets[0])):
            for source, kind in sorted(only, key=_canonical):
                category = (
                    'static_candidate'
                    if kind == 'static_candidate'
                    else (
                        'control_selection'
                        if kind == 'control'
                        else 'update' if kind in {'capture', 'write', 'prior_state'} else 'dependency'
                    )
                )
                differences.append(
                    PairDifference(
                        cast('DifferenceKind', category),
                        pair,
                        {'side': side, 'source_coordinate': list(source), 'edge_kind': kind},
                    )
                )
    return tuple(pairs), tuple(common_edges), tuple(differences), tuple(unmatched)


def _query_side(
    run: TraceRun,
    request: QueryRequest,
    carrier: Path | None,
    check: CheckRecord | None,
    source_binding: Path | str | None,
) -> TraceReport:
    """沿用公共检查引用加载器，禁止双运行入口跳过 CheckRecord 来源核验。"""
    from . import load_check_reference

    check_carrier = None
    if request.check is not None:
        if carrier is None:
            raise TraceError(StopCode.INVALID_INPUT, '含 check 引用的查询必须提供 request carrier')
        loaded = load_check_reference(request.check, carrier, run)
        if check is not None and check != loaded:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '传入检查与请求引用不同')
        check = loaded
        check_carrier = run.resolve_record(request.check, carrier)
    return run.query(request, check=check, check_carrier=check_carrier, source_binding=source_binding)


def _carriers(
    side: str,
    run: TraceRun,
    request: QueryRequest,
    request_carrier: Path | None,
    source_binding: Path | str | None,
    destination: Path,
) -> dict[str, RecordRef]:
    """保存嵌套原始报告各类引用的载体，避免把检查文件相对路径误作运行相对路径。"""
    result = {side + '_run': run.run_reference(destination)}
    paths = {}
    if request_carrier is not None:
        paths[side + '_request'] = request_carrier.absolute()
        if request.check is not None:
            paths[side + '_check'] = run.resolve_record(request.check, request_carrier)
    if source_binding is not None:
        paths[side + '_source_binding'] = Path(source_binding).absolute()
    for name, path in paths.items():
        if not path.is_file():
            raise TraceError(StopCode.MISSING_ARTIFACT, '引用载体文件不存在', path=str(path))
        result[name] = RecordRef(
            Path(os.path.relpath(path, destination.parent)).as_posix(),
            sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
        )
    return result


def compare_runs(
    left: TraceRun,
    request: PairRequest,
    *,
    right: TraceRun | None = None,
    contract: PairContract | None = None,
    carrier: Path | str | None = None,
    left_request_carrier: Path | None = None,
    right_request_carrier: Path | None = None,
    left_check: CheckRecord | None = None,
    right_check: CheckRecord | None = None,
    left_source_binding: Path | str | None = None,
    right_source_binding: Path | str | None = None,
) -> PairReport:
    """查询并比较两个明确可比的运行；无参考时返回诚实的单运行解释。

    carrier 是将来保存 pair JSON 的路径，默认当前目录 pair.json；顶层运行引用
    相对它解析，嵌套单侧报告的原证据由 evidence_carriers 指定各类载体。合同核验与两次
    查询分别计费，不宣称这里提供共享缓存或总体预算。参数和控制角色尚为绑定
    IR 的显式假设，因此 paired 结果始终为 conditional，而非完整初态等价证明。
    """
    destination = Path(carrier).absolute() if carrier is not None else Path.cwd() / 'pair.json'
    if right is None:
        if (
            request.right is not None
            or contract is not None
            or right_check is not None
            or right_source_binding is not None
        ):
            raise TraceError(StopCode.INVALID_INPUT, '无参考运行时不能提供参考合同、查询或工件')
        report = _query_side(left, request.left, left_request_carrier, left_check, left_source_binding)
        return PairReport(
            'single:' + report.report_id,
            'single_run',
            'not_run',
            'not_applicable',
            left.run_reference(destination),
            report,
            limitations=('没有执行双运行比较；expected 输出不代表正常内部执行。',),
            evidence_carriers=_carriers(
                'left', left, request.left, left_request_carrier, left_source_binding, destination
            ),
        )
    if request.right is None or contract is None:
        raise TraceError(StopCode.INVALID_INPUT, '参考运行需要对应查询和显式合同')
    with left._open(request.validation_budget) as first, right._open(request.validation_budget) as second:
        verified, mappings = _validate_pair(
            first, second, contract, request, bind_semantics(first), bind_semantics(second)
        )
    reports = (
        _query_side(left, request.left, left_request_carrier, left_check, left_source_binding),
        _query_side(right, request.right, right_request_carrier, right_check, right_source_binding),
    )
    pairs, common, differences, unmatched = _compare_reports(*reports, mappings)
    partial = bool(unmatched) or any(report.status.query != 'complete' for report in reports)

    def position(item: PairDifference) -> tuple[int, int]:
        return (
            item.pair.coordinate['event_index'] if item.pair.coordinate['event_index'] is not None else -1,
            item.pair.coordinate['evaluation'] or 0,
        )

    earliest = min((position(item) for item in differences), default=None)
    return PairReport(
        contract.id,
        'paired',
        'partial' if partial else 'different' if differences else 'matched',
        'partial' if partial else 'conditional',
        left.run_reference(destination),
        reports[0],
        right.run_reference(destination),
        reports[1],
        contract,
        hashlib.sha256(_canonical(contract.to_dict()).encode()).hexdigest(),
        False,
        verified,
        pairs,
        common,
        differences,
        tuple(item for item in differences if position(item) == earliest),
        unmatched,
        (
            '参数值和时钟/复位角色是绑定执行 IR 的调用者合同；尚未自动证明声明与 RTL 参数化/复位语义一致。',
            '比较范围仅为声明目标、窗口及两侧实际展开的依赖；首次已观测分叉不是唯一根因。',
            '未映射节点、缺失历史和不支持构造保持 partial；静态候选不是实际数据来源。',
        ),
        evidence_carriers=dict(
            _carriers('left', left, request.left, left_request_carrier, left_source_binding, destination),
            **_carriers('right', right, request.right, right_request_carrier, right_source_binding, destination),
        ),
    )


__all__ = [
    'InputPair',
    'NodePair',
    'PairContract',
    'PairDifference',
    'PairReport',
    'PairRequest',
    'PairSide',
    'TargetPair',
    'compare_runs',
    'evidence_sha256',
    'normalized_evidence',
]
