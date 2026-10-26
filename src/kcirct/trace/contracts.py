"""组件契约模板和本次运行绑定；配置复用不复用旧运行的检查结论。"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, Any, Literal

from .kore import bit_vector
from .model import (  # noqa: TC001 -- JsonModel 运行时解析字段类型。
    ArtifactRef,
    BitVector,
    Budget,
    JsonModel,
    Observation,
    QueryRequest,
    QueryWindow,
    StopCode,
    Target,
    TraceError,
    _digest,
    _nonempty,
)
from .semantics import bind_semantics, bounded_width, memory_contents, memory_dimensions, register_initial
from .source import bind_sources
from .topology import TraceTopology, integer_type_width

if TYPE_CHECKING:
    from . import TraceRun
    from .artifacts import RunArtifacts
    from .model import CheckRecord, TraceReport
    from .semantics import SemanticsProfile
    from .source import SourceIndex
    from .topology import TargetBinding


def _relative_name(value: str, name: str) -> None:
    """绑定名称是相对单个实例的直接名字，不接受路径穿越或跨实例定位。"""
    _nonempty(value, name)
    if '/' in value or value in {'.', '..'} or '\\' in value:
        raise TraceError(StopCode.INVALID_INPUT, '组件相对名称不能包含实例路径', field=name, value=value)


def contract_sha256(value: JsonModel) -> str:
    """按完整规范 JSON 固定模板或绑定，不依赖 JSON 排版。"""
    document = value.to_dict()
    # 新增可选的空握手声明不改变早期 v1 无握手模板的规范身份。
    if isinstance(value, ComponentContract) and not value.handshakes:
        document.pop('handshakes', None)
    return hashlib.sha256(
        json.dumps(document, sort_keys=True, separators=(',', ':'), ensure_ascii=False).encode()
    ).hexdigest()


@dataclass(frozen=True)
class ParameterRule(JsonModel):
    """首版参数为整数；范围与离散集合都在绑定时核验。"""

    name: str
    minimum: int
    maximum: int
    allowed: tuple[int, ...] = ()

    def _validate(self) -> None:
        _relative_name(self.name, 'parameter')
        if self.minimum > self.maximum or any(not self.minimum <= value <= self.maximum for value in self.allowed):
            raise TraceError(StopCode.INVALID_INPUT, '参数范围或允许集合无效', parameter=self.name)


@dataclass(frozen=True)
class ContractPort(JsonModel):
    """相对语义端口；width 可以是固定整数或已声明整数参数名。"""

    name: str
    direction: Literal['input', 'output']
    width: int | str
    role: Literal['data', 'clock', 'reset', 'status'] = 'data'
    active_value: int | None = None

    def _validate(self) -> None:
        _relative_name(self.name, 'port')
        if isinstance(self.width, int):
            bounded_width(self.width)
        else:
            _relative_name(self.width, 'width parameter')
        if self.role in {'clock', 'reset'} and (self.direction != 'input' or self.width != 1):
            raise TraceError(StopCode.INVALID_INPUT, '时钟/复位必须为一位输入')
        if self.role == 'reset' and self.active_value not in (0, 1):
            raise TraceError(StopCode.INVALID_INPUT, '复位须明确有效电平')
        if self.role != 'reset' and self.active_value is not None:
            raise TraceError(StopCode.INVALID_INPUT, '只有复位端口声明 active_value')


@dataclass(frozen=True)
class ContractTarget(JsonModel):
    """模板中的相对查询入口，必要时绑定某个语义端口。"""

    name: str
    kind: Literal['signal', 'register', 'memory_cell']
    width: int | str
    address: str | None = None
    port: str | None = None

    def _validate(self) -> None:
        _relative_name(self.name, 'target')
        Target(self.kind, name=self.name, address=self.address)
        if isinstance(self.width, int):
            bounded_width(self.width)
        else:
            _relative_name(self.width, 'width parameter')
        if self.port is not None:
            _relative_name(self.port, 'target port')


@dataclass(frozen=True)
class InitialState(JsonModel):
    """已登记目标在 setup 的预期值；未知初态不能填成空对象。"""

    target: str
    expected: BitVector


@dataclass(frozen=True)
class ContractProfile(JsonModel):
    """一个明确允许的源码/编译定义内容对，不按软件版本号猜测兼容性。"""

    semantics_source_sha256: str
    definition_sha256: str

    def _validate(self) -> None:
        _digest(self.semantics_source_sha256, 'semantics_source_sha256')
        _digest(self.definition_sha256, 'definition_sha256')


@dataclass(frozen=True)
class ContractHandshake(JsonModel):
    """声明哪些端口的数据只在一位限定信号有效时进入性质检查。"""

    name: str
    data_ports: tuple[str, ...]
    qualifier: str
    active_value: int = 1

    def _validate(self) -> None:
        _relative_name(self.name, 'handshake')
        _relative_name(self.qualifier, 'handshake qualifier')
        for name in self.data_ports:
            _relative_name(name, 'handshake data')
        if not self.data_ports or len(set(self.data_ports)) != len(self.data_ports):
            raise TraceError(StopCode.INVALID_INPUT, '握手须列出非空且不重复的数据端口')
        if self.qualifier in self.data_ports or self.active_value not in (0, 1):
            raise TraceError(StopCode.INVALID_INPUT, '握手限定信号或有效电平不合法')


@dataclass(frozen=True)
class ComponentContract(JsonModel):
    """可复用模板；独立检查器内容固定，运行与具体实例不属于模板。"""

    id: str
    version: str
    ports: tuple[ContractPort, ...]
    targets: tuple[ContractTarget, ...]
    parameters: tuple[ParameterRule, ...]
    initialization: tuple[InitialState, ...]
    profiles: tuple[ContractProfile, ...]
    checker_sha256: str
    checker_interface: str
    property_description: str
    clocking: Literal['combinational', 'single_clock']
    evaluations_per_input: int
    timescale: str
    sampling_phase: Literal['dump'] = 'dump'
    initial_state_coverage: Literal['all_component_storage'] = 'all_component_storage'
    source_required: bool = False
    source_mapping_required: bool = False
    handshakes: tuple[ContractHandshake, ...] = ()

    def _validate(self) -> None:
        for name in ('id', 'version', 'checker_interface', 'property_description', 'timescale'):
            _nonempty(getattr(self, name), name)
        _digest(self.checker_sha256, 'checker_sha256')
        if not self.ports or not self.targets or not self.profiles or self.evaluations_per_input <= 0:
            raise TraceError(StopCode.INVALID_INPUT, '契约需要明确接口、查询、profile 和采样协议')
        for group in (self.ports, self.targets, self.parameters):
            if len({item.name for item in group}) != len(group):
                raise TraceError(StopCode.DUPLICATE_IDENTITY, '契约中语义名称重复')
        ports = {port.name: port for port in self.ports}
        targets = {target.name: target for target in self.targets}
        parameters = {parameter.name for parameter in self.parameters}
        widths: tuple[ContractPort | ContractTarget, ...] = (*self.ports, *self.targets)
        if any(isinstance(item.width, str) and item.width not in parameters for item in widths):
            raise TraceError(StopCode.INVALID_INPUT, '位宽引用未声明参数')
        if any(target.port is not None and target.port not in ports for target in self.targets):
            raise TraceError(StopCode.INVALID_INPUT, '查询入口引用未声明语义端口')
        if len({item.target for item in self.initialization}) != len(self.initialization):
            raise TraceError(StopCode.DUPLICATE_IDENTITY, '初态目标重复')
        if any(
            item.target not in targets or targets[item.target].kind not in {'register', 'memory_cell'}
            for item in self.initialization
        ):
            raise TraceError(StopCode.INVALID_INPUT, '初态必须指向明确的寄存器或 memory cell 查询入口')
        clocks = sum(port.role == 'clock' for port in self.ports)
        if clocks != (1 if self.clocking == 'single_clock' else 0):
            raise TraceError(StopCode.UNSUPPORTED_CLOCK, '契约时钟模式与端口声明不一致')
        if len({rule.name for rule in self.handshakes}) != len(self.handshakes):
            raise TraceError(StopCode.DUPLICATE_IDENTITY, '握手名称重复')
        qualified: set[str] = set()
        for rule in self.handshakes:
            if rule.qualifier not in ports or ports[rule.qualifier].width != 1:
                raise TraceError(StopCode.INVALID_INPUT, '握手限定信号必须是声明的一位端口')
            if any(name not in ports or name in qualified for name in rule.data_ports):
                raise TraceError(StopCode.INVALID_INPUT, '握手数据端口缺失或存在多个相冲突的限定声明')
            qualified.update(rule.data_ports)


@dataclass(frozen=True)
class ComponentBinding(JsonModel):
    """本次运行的显式重绑定；每次版本、层次或实例变化都产生新绑定。"""

    id: str
    contract_sha256: str
    run_id: str
    manifest_sha256: str
    execution_ir_sha256: str
    definition_sha256: str
    instance: str
    module_symbol: str
    ports: dict[str, str]
    targets: dict[str, str]
    parameters: dict[str, int]
    checker: ArtifactRef
    toolchain: dict[str, str]
    project: str
    version: str
    upstream_family: str
    sources: tuple[ArtifactRef, ...] = ()
    source_binding: ArtifactRef | None = None

    def _validate(self) -> None:
        for name in ('id', 'run_id', 'instance', 'module_symbol', 'project', 'version', 'upstream_family'):
            _nonempty(getattr(self, name), name)
        if self.instance.startswith('/') or any(part in {'', '.', '..'} for part in self.instance.split('/')):
            raise TraceError(StopCode.INVALID_INPUT, '实例必须是完整且规范的运行内路径')
        for name in ('contract_sha256', 'manifest_sha256', 'execution_ir_sha256', 'definition_sha256'):
            _digest(getattr(self, name), name)
        for group in (self.ports, self.targets):
            for key, value in group.items():
                _relative_name(key, 'logical name')
                _relative_name(value, 'bound relative name')
        if len(set(self.ports.values())) != len(self.ports):
            raise TraceError(StopCode.DUPLICATE_IDENTITY, '语义端口不能重绑定到同一实际端口')
        for value in self.toolchain.values():
            _digest(value, 'toolchain hash')
        if self.checker.role != 'checker' or self.checker.compression != 'none':
            raise TraceError(StopCode.INVALID_INPUT, 'checker 必须是未压缩、明确绑定的 checker 工件')
        if any(source.role not in {'source', 'rtl'} for source in self.sources):
            raise TraceError(StopCode.INVALID_INPUT, 'sources 必须标为 source 或 rtl')
        if self.source_binding is not None and self.source_binding.role != 'source_binding':
            raise TraceError(StopCode.INVALID_INPUT, 'source_binding 工件角色错误')


@dataclass(frozen=True)
class BindingReport(JsonModel):
    """身份/接口核验结果；checker_status 不会从绑定成功推断为 passed。"""

    binding_id: str
    run_id: str
    contract_sha256: str
    binding_sha256: str
    status: Literal['ready', 'partial']
    ports: dict[str, Target]
    targets: dict[str, Target]
    initial_values: dict[str, Any]
    evidence: dict[str, Any]
    limitations: tuple[str, ...]
    checker_status: Literal['not_run'] = 'not_run'
    kind: Literal['component_binding_report'] = 'component_binding_report'


def _width(value: int | str, parameters: dict[str, int]) -> int:
    return bounded_width(value if isinstance(value, int) else parameters[value])


def _parameters(contract: ComponentContract, binding: ComponentBinding) -> None:
    """检查声明的参数范围；不把它写成任意 lowered IR 的参数值证明。"""
    if set(binding.parameters) != {rule.name for rule in contract.parameters}:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '参数声明不完整或含额外参数')
    for rule in contract.parameters:
        value = binding.parameters[rule.name]
        if not rule.minimum <= value <= rule.maximum or (rule.allowed and value not in rule.allowed):
            raise TraceError(StopCode.IDENTITY_MISMATCH, '参数值不在契约允许范围', parameter=rule.name, value=value)


def _layout(
    topology: TraceTopology, contract: ComponentContract, binding: ComponentBinding
) -> tuple[dict[str, Target], dict[str, Target], dict[str, TargetBinding]]:
    """只在明确实例内解析端口与目标，所有用户名称先限定层次再交给原拓扑解析器。"""
    instance = topology.instances.get(binding.instance)
    if instance is None or instance.module != binding.module_symbol:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '具体实例或模块身份不存在/不匹配')
    if set(binding.ports) != {port.name for port in contract.ports} or set(binding.targets) != {
        target.name for target in contract.targets
    }:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '端口或查询重绑定必须覆盖模板且不能有额外字段')
    actual = {
        name: (direction, signal, integer_type_width(typ))
        for direction, ports in (('input', instance.inputs), ('output', instance.outputs))
        for name, signal, typ in ports
    }
    if set(binding.ports.values()) != set(actual):
        raise TraceError(StopCode.IDENTITY_MISMATCH, '接口模板没有精确覆盖该实例的全部端口')
    ports = {}
    for requirement in contract.ports:
        name = binding.ports[requirement.name]
        direction, signal, width = actual[name]
        if direction != requirement.direction or width != _width(requirement.width, binding.parameters):
            raise TraceError(StopCode.IDENTITY_MISMATCH, '端口方向或位宽不匹配', port=requirement.name)
        resolved = topology.resolve(Target('signal', name=f'{binding.instance}/{name}'))
        if resolved.signal_id != signal:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '端口别名解析到其他信号')
        ports[requirement.name] = Target('signal', target_id=resolved.target_id)
    targets = {}
    resolved_targets = {}
    for target_requirement in contract.targets:
        name = f'{binding.instance}/{binding.targets[target_requirement.name]}'
        resolved = topology.resolve(Target(target_requirement.kind, name=name, address=target_requirement.address))
        if resolved.instance_id != binding.instance and not (resolved.instance_id or '').startswith(
            binding.instance + '/'
        ):
            raise TraceError(StopCode.IDENTITY_MISMATCH, '查询入口解析到绑定组件之外', target=target_requirement.name)
        if resolved.width != _width(target_requirement.width, binding.parameters):
            raise TraceError(StopCode.IDENTITY_MISMATCH, '查询目标位宽不匹配', target=target_requirement.name)
        if target_requirement.port is not None:
            port = topology.resolve(ports[target_requirement.port])
            if resolved.signal_id != port.signal_id:
                raise TraceError(
                    StopCode.IDENTITY_MISMATCH, '查询目标未绑定声明的语义端口', target=target_requirement.name
                )
        targets[target_requirement.name] = Target(
            target_requirement.kind, target_id=resolved.target_id, address=target_requirement.address
        )
        resolved_targets[target_requirement.name] = resolved
    return ports, targets, resolved_targets


def _initial(
    run: RunArtifacts,
    topology: TraceTopology,
    contract: ComponentContract,
    binding: ComponentBinding,
    targets: dict[str, TargetBinding],
    profile: SemanticsProfile,
) -> dict[str, Any]:
    """只覆盖本组件的全部架构存储，其他实例的初态不能替代本实例。"""
    storage = {
        node.signal_id: node
        for node in topology.nodes.values()
        if node.storage_kind is not None
        and (node.instance_id == binding.instance or (node.instance_id or '').startswith(binding.instance + '/'))
    }
    if any(node.storage_kind == 'memory_cell' and (node.shape or {}).get('depth', 0) <= 0 for node in storage.values()):
        raise TraceError(StopCode.UNSUPPORTED_INITIALIZATION, '组件 memory 初态覆盖需要明确深度')
    required = sum(
        (node.shape or {}).get('depth', 0) if node.storage_kind == 'memory_cell' else 1 for node in storage.values()
    )
    supplied = {(targets[item.target].signal_id, targets[item.target].address) for item in contract.initialization}
    if len(supplied) != len(contract.initialization) or len(supplied) != required:
        raise TraceError(
            StopCode.IDENTITY_MISMATCH, '初态要求未精确覆盖全部组件架构存储', required=required, supplied=len(supplied)
        )
    if contract.clocking == 'combinational' and storage:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '组合契约不能包含架构存储')
    setup = run.read_state(run.setup_id)
    result = {}
    memories = {}
    for item in contract.initialization:
        target = targets[item.target]
        node = storage.get(target.signal_id or '')
        if node is None or node.unsupported or node.operation is None:
            raise TraceError(StopCode.UNSUPPORTED_INITIALIZATION, '组件初态目标不受支持')
        if node.storage_kind == 'register':
            default, origin = register_initial(node.operation, profile)
            value = bit_vector(setup.signals[node.signal_id]) if node.signal_id in setup.signals else default
            origin = 'saved_setup' if node.signal_id in setup.signals else origin
        else:
            if node.signal_id not in memories:
                writers = [
                    op
                    for op in topology.procedures
                    if op.name == 'seq.firmem.write_port' and op.operands[0] == node.signal_id
                ]
                if len(writers) != 1:
                    raise TraceError(StopCode.UNSUPPORTED_SHAPE, '组件初始化只接受单写口 memory')
                memories[node.signal_id] = memory_contents(
                    setup.signals.get(node.signal_id), memory_dimensions(node, writers[0])
                )
            assert target.address is not None
            address = int(target.address)
            value = memories[node.signal_id].get(address, BitVector.from_int(0, (node.shape or {})['width']))
            origin = 'saved_setup' if address in memories[node.signal_id] else 'bound_empty_memory_default_zero'
        if value != item.expected:
            raise TraceError(
                StopCode.IDENTITY_MISMATCH,
                '组件实际 setup 初态不满足契约',
                target=item.target,
                actual=value.to_dict(),
                expected=item.expected.to_dict(),
            )
        result[item.target] = {
            'value': value.to_dict(),
            'origin': origin,
            'state_id': run.setup_id,
            'content_sha256': setup.uncompressed_sha256,
        }
    return result


def _identity(
    run: RunArtifacts, contract: ComponentContract, binding: ComponentBinding, carrier: Path
) -> tuple[SemanticsProfile, dict[str, Any], SourceIndex | None]:
    """逐项核验本次运行、checker、源码、工具链与 profile 的固定内容身份。"""
    if binding.contract_sha256 != contract_sha256(contract):
        raise TraceError(StopCode.HASH_MISMATCH, '绑定引用的契约模板哈希不同')
    if (binding.run_id, binding.manifest_sha256) != (run.manifest.run_id, run.manifest_sha256):
        raise TraceError(StopCode.IDENTITY_MISMATCH, '绑定不属于当前运行 manifest')
    recorded_parameters = run.manifest.parameters.get('values')
    if recorded_parameters is not None and recorded_parameters != binding.parameters:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '运行记录的参数值与绑定冲突')
    execution = [ref for ref in run.manifest.artifacts.values() if ref.role == 'execution_ir']
    if len(execution) != 1 or execution[0].sha256 != binding.execution_ir_sha256:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '绑定的执行 IR 身份不同')
    run.resolve(execution[0])
    profile = bind_semantics(run)
    if profile.binding != 'source_and_definition_verified' or not any(
        (item.semantics_source_sha256, item.definition_sha256) == (profile.source_sha256, profile.definition_sha256)
        for item in contract.profiles
    ):
        raise TraceError(StopCode.UNSUPPORTED_SEMANTICS, '运行 profile 不属于契约已核验内容集合')
    if profile.definition_sha256 != binding.definition_sha256:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '绑定的 definition 身份不同')
    protocol = {
        'evaluations_per_input': contract.evaluations_per_input,
        'timescale': contract.timescale,
        'sampling_phase': contract.sampling_phase,
    }
    if any(run.manifest.protocol.get(key) != value for key, value in protocol.items()):
        raise TraceError(StopCode.IDENTITY_MISMATCH, '采样合同不匹配')
    if binding.checker.sha256 != contract.checker_sha256:
        raise TraceError(StopCode.HASH_MISMATCH, '检查器内容与契约版本不一致')
    run.resolve(binding.checker, carrier=carrier)
    tools = {
        key: ref
        for key, ref in run.manifest.artifacts.items()
        if ref.role in {'execution_tool', 'parser', 'python_executable'}
    }
    if {key: ref.sha256 for key, ref in tools.items()} != binding.toolchain or not {
        'parser',
        'python_executable',
        'execution_tool',
    } <= {ref.role for ref in tools.values()}:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '工具链内容身份缺失或与绑定不同')
    for ref in tools.values():
        run.resolve(ref)
    if contract.source_required and not binding.sources:
        raise TraceError(StopCode.MISSING_ARTIFACT, '契约要求明确的源文件身份')
    for ref in binding.sources:
        run.resolve(ref, carrier=carrier)
    source = {'status': 'not_provided', 'precision': 'unknown'}
    source_index = None
    if contract.source_mapping_required and binding.source_binding is None:
        raise TraceError(StopCode.MISSING_ARTIFACT, '契约要求明确的源码映射绑定')
    if binding.source_binding is not None:
        path = run.resolve(binding.source_binding, carrier=carrier)
        index = bind_sources(run, path)
        if index.issues or index.source_errors:
            raise TraceError(
                StopCode.SOURCE_MISMATCH,
                '已提供源码绑定未通过核验',
                issues=[item.to_dict() for item in index.issues],
                source_errors=index.source_errors,
            )
        if contract.source_mapping_required and index.precision != 'exact':
            raise TraceError(
                StopCode.SOURCE_MISMATCH, '契约要求源码映射；仅 IR 定位不满足该要求', precision=index.precision
            )
        source = {'status': 'verified', 'precision': index.precision}
        source_index = index
    evidence = {
        'source_mapping': source,
        'profile': {
            'source_sha256': profile.source_sha256,
            'definition_sha256': profile.definition_sha256,
            'binding': profile.binding,
        },
        'checker': binding.checker.to_dict(),
        'toolchain': binding.toolchain,
        'sources': [ref.to_dict() for ref in binding.sources],
        'sampling': protocol,
    }
    return profile, evidence, source_index


class BoundComponent:
    """可脚本化的本次绑定；每次采样/查询重新核验，绝不携带上次 checker pass。"""

    def __init__(
        self,
        run: TraceRun,
        contract: ComponentContract,
        binding: ComponentBinding,
        carrier: Path,
        report: BindingReport,
    ) -> None:
        self.run, self.contract, self.binding, self.carrier, self.report = run, contract, binding, carrier, report

    def refresh(self, *, budget: Budget | None = None) -> BoundComponent:
        """对当前工件重新执行身份与适用性核验。"""
        return bind_component(self.run, self.contract, self.binding, carrier=self.carrier, budget=budget)

    def _sampling(self, observation: Observation) -> None:
        if observation.phase != self.contract.sampling_phase:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '组件观测相位与模板采样合同不同')

    def query_request(
        self, target: str, observation: Observation, *, window: QueryWindow | None = None, budget: Budget | None = None
    ) -> QueryRequest:
        """把模板查询名转成绑定该 run/实例的 target_id，不进行全局同名查找。"""
        self._sampling(observation)
        if target not in self.report.targets:
            raise TraceError(StopCode.INVALID_INPUT, '未知组件查询入口', target=target)
        return QueryRequest(
            self.report.targets[target], observation, window=window or QueryWindow(), budget=budget or Budget()
        )

    def query(
        self,
        target: str,
        observation: Observation,
        *,
        window: QueryWindow | None = None,
        budget: Budget | None = None,
        check: CheckRecord | None = None,
        check_carrier: Path | None = None,
    ) -> TraceReport:
        """重新核验绑定后调用原单运行查询；检查结论由本次独立 CheckRecord 提供。"""
        self._sampling(observation)
        current = self.refresh(budget=budget)
        if check is not None:
            self._sampling(check.observation)
            required = {
                'checker_sha256': self.contract.checker_sha256,
                'binding_sha256': current.report.binding_sha256,
            }
            if any(check.source.identity.get(key) != value for key, value in required.items()):
                raise TraceError(StopCode.IDENTITY_MISMATCH, 'CheckRecord 没有绑定本次组件与 checker 内容身份')
        source = None
        if self.binding.source_binding is not None:
            with self.run._open(budget) as artifacts:
                source = artifacts.resolve(self.binding.source_binding, carrier=self.carrier)
        return self.run.query(
            current.query_request(target, observation, window=window, budget=budget),
            check=check,
            check_carrier=check_carrier,
            source_binding=source,
        )

    def samples(self, observations: tuple[Observation, ...], *, budget: Budget | None = None) -> dict[str, Any]:
        """导出当前实例端口的真实观测给独立 checker；这里只采样，不判定性质通过。"""
        from .checks import observed_value

        for observation in observations:
            self._sampling(observation)
        current = self.refresh(budget=budget)
        samples = []
        with self.run._open(budget) as run:
            topology = TraceTopology.from_run(run)
            for observation in observations:
                entry, dump = run.locate(observation)
                values = {
                    name: observed_value(run, topology, target, observation).to_dict()
                    for name, target in current.report.ports.items()
                }
                samples.append(
                    {
                        'observation': Observation(
                            'dump' if dump else entry.phase,
                            event_index=entry.event_index,
                            evaluation=entry.evaluation,
                            state_id=entry.state_id,
                            dump_id=dump.dump_id if dump else None,
                        ).to_dict(),
                        'values': values,
                    }
                )
        return {
            'schema_version': 1,
            'kind': 'component_checker_input',
            'run_id': self.run.run_id,
            'manifest_sha256': self.run.manifest_sha256,
            'contract_sha256': current.report.contract_sha256,
            'binding_sha256': current.report.binding_sha256,
            'checker_sha256': self.contract.checker_sha256,
            'checker_interface': self.contract.checker_interface,
            'handshakes': [rule.to_dict() for rule in self.contract.handshakes],
            'instance': self.binding.instance,
            'checker_status': 'not_run',
            'samples': samples,
        }


def bind_component(
    run: TraceRun,
    contract: ComponentContract,
    binding: ComponentBinding,
    *,
    carrier: Path | str,
    budget: Budget | None = None,
) -> BoundComponent:
    """在明确版本、实例、工件和合同下绑定组件；返回适用性而非设计正确性结论。"""
    carrier = Path(carrier).absolute()
    _parameters(contract, binding)
    with run._open(budget) as artifacts:
        profile, evidence, source_index = _identity(artifacts, contract, binding, carrier)
        topology = TraceTopology.from_run(artifacts)
        ports, targets, resolved = _layout(topology, contract, binding)
        if contract.source_mapping_required:
            assert source_index is not None
            locations = {}
            for name, target in resolved.items():
                node = topology.nodes.get(target.signal_id or '')
                seen = set()
                while node is not None and node.direct_source and node.signal_id not in seen:
                    seen.add(node.signal_id)
                    node = topology.nodes.get(node.direct_source)
                if node is None or node.operation is None:
                    raise TraceError(StopCode.SOURCE_MISMATCH, '查询入口缺少可绑定源码的操作', target=name)
                found = source_index.for_operation(node.operation)
                if not found or any(location.precision not in {'exact', 'declaration', 'fused'} for location in found):
                    raise TraceError(StopCode.SOURCE_MISMATCH, '查询入口缺少契约要求的源码位置', target=name)
                locations[name] = [location.to_dict() for location in found]
            evidence['target_locations'] = locations
        initial = _initial(artifacts, topology, contract, binding, resolved, profile)
        limitations = [
            '绑定成功不表示性质通过；checker 必须在本次运行/实例上重新执行。',
            '项目、版本和上游谱系是来源声明，配置机制不自行证明来源独立性。',
        ]
        if contract.parameters:
            limitations.append('参数已核对合法范围及接口/查询位宽；尚未自动证明任意 lowered IR 内部参数化语义。')
        if contract.clocking == 'single_clock':
            limitations.append('时钟/复位角色与端口形状已核验；完整时序性质须由独立 checker 和受支持查询验证。')
        if contract.handshakes:
            limitations.append('握手限定信号及数据端口形状已核验；协议时序与数据有效性由本次独立 checker 检查。')
        evidence['handshakes'] = {
            'status': 'declared_interface' if contract.handshakes else 'not_applicable',
            'rules': [rule.to_dict() for rule in contract.handshakes],
        }
        evidence['parameters'] = {
            'status': 'interface_constraints_only' if contract.parameters else 'explicit_empty_contract',
            'values': binding.parameters,
        }
        evidence['control_roles'] = {
            'status': 'declared_interface' if contract.clocking == 'single_clock' else 'not_applicable'
        }
        evidence['source_relation'] = {
            'status': 'source_mapping_verified' if binding.source_binding else 'declared_source_bytes_bound_to_run'
        }
        evidence['cost'] = artifacts.cost.to_dict()
        evidence['run'] = run.run_reference(carrier).to_dict()
        evidence['binding_carrier'] = str(carrier)
        report = BindingReport(
            binding.id,
            run.run_id,
            contract_sha256(contract),
            contract_sha256(binding),
            'partial' if contract.parameters or contract.handshakes or contract.clocking == 'single_clock' else 'ready',
            ports,
            targets,
            initial,
            evidence,
            tuple(limitations),
        )
    return BoundComponent(run, contract, binding, carrier, report)


__all__ = [
    'BindingReport',
    'BoundComponent',
    'ComponentBinding',
    'ComponentContract',
    'ContractPort',
    'ContractHandshake',
    'ContractProfile',
    'ContractTarget',
    'InitialState',
    'ParameterRule',
    'bind_component',
    'contract_sha256',
]
