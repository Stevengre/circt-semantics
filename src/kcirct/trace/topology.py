"""保留实例边界与全部名称的候选拓扑；不把静态关系当作实际执行来源。"""

from __future__ import annotations

import hashlib
import json
import re
import time
from collections import defaultdict
from dataclasses import asdict, dataclass, replace
from typing import TYPE_CHECKING, Any

from .kore import list_items, scalar, string_map, unwrap
from .model import StopCode, TraceError

if TYPE_CHECKING:
    from .artifacts import RunArtifacts
    from .kore import DecodedState, Term
    from .model import Target

_OP = (
    "Lbl'UndsLParUndsRParLBraUndsRBraColnUndsUnds'MLIR-HELPER-SYNTAX'Unds'StdOp"
    "'Unds'String'Unds'List'Unds'Map'Unds'StdFT"
)
_FT = "Lbl'LParUndsRPar'-'-GT-LParUndsRParUnds'MLIR-SYNTAX'Unds'StdFT'Unds'Types'Unds'Types"
_TYPES = "Lbl'UndsCommUndsUnds'MLIR-SYNTAX'Unds'Types'Unds'Type'Unds'Types"
_TYPES_EMPTY = "Lbl'Stop'List'LBraQuotUndsCommUndsUnds'MLIR-SYNTAX'Unds'Types'Unds'Type'Unds'Types'QuotRBraUnds'Types"
_ATTRS = "Lbl'UndsCommUndsUnds'BUILTIN-SYNTAX'Unds'AttributeValueList'Unds'AttributeValue'Unds'AttributeValueList"
_ATTRS_EMPTY = (
    "Lbl'Stop'List'LBraQuotUndsCommUndsUnds'BUILTIN-SYNTAX'Unds'AttributeValueList"
    "'Unds'AttributeValue'Unds'AttributeValueList'QuotRBraUnds'AttributeValueList"
)
_TYPED_ATTRIBUTE = "Lbl'UndsColnUndsUnds'BUILTIN-SYNTAX'Unds'AttributeValue'Unds'AttributeValue'Unds'Type"
_MEMORY = "Lbl'Bang'seq'Stop'firmem'-LT-Unds'x'Unds-GT-Unds'SEQ-SYNTAX'Unds'SeqFirmemType'Unds'Int'Unds'Int"
_MASKED_MEMORY = (
    "Lbl'Bang'seq'Stop'firmem'-LT-Unds'x'UndsComm'mask'Unds-GT-Unds'SEQ-SYNTAX"
    "'Unds'SeqFirmemType'Unds'Int'Unds'Int'Unds'Int"
)
_CLOCK = "Lbl'Bang'seq'Stop'clock'Unds'SEQ-SYNTAX'Unds'SeqClockType"


def _shape(message: str, **details: Any) -> TraceError:
    return TraceError(StopCode.UNSUPPORTED_SHAPE, message, **details)


def _sequence(term: Term, cons: str, empty: str) -> tuple[Term, ...]:
    values = []
    current = unwrap(term)
    while current.symbol == cons and len(current.args) == 2:
        values.append(current.args[0])
        current = unwrap(current.args[1])
    if current.symbol != empty or current.args:
        raise _shape('类型或属性序列包含未知构造', symbol=current.symbol)
    return tuple(values)


def type_items(term: Term) -> tuple[Term, ...]:
    """读取 StdFT 使用的有序 Types，保留每项完整类型。"""
    return _sequence(term, _TYPES, _TYPES_EMPTY)


def attribute_value(term: Term) -> Term:
    """取已知类型标注的属性值；复合属性保持原形，不猜测其值。"""
    value = unwrap(term)
    if value.symbol == _TYPED_ATTRIBUTE and len(value.args) == 2:
        return unwrap(value.args[0])
    return value


def integer_type_width(term: Term) -> int | None:
    """已识别整数与 seq.clock 的位宽；未知类型返回 None。"""
    value = unwrap(term)
    if value.symbol == _CLOCK and not value.args:
        return 1
    if value.tag == 'DV' and value.sorts in (
        ('SortSignlessIntegerType{}',),
        ('SortSignedIntegerType{}',),
        ('SortUnsignedIntegerType{}',),
    ):
        match = re.fullmatch(r'(?:s|u)?i([1-9][0-9]*)', value.value or '')
        if match:
            try:
                return int(match[1])
            except ValueError:
                return None
    return None


def memory_shape(term: Term) -> dict[str, int] | None:
    value = unwrap(term)
    count = 3 if value.symbol == _MASKED_MEMORY else 2 if value.symbol == _MEMORY else 0
    if not count or len(value.args) != count:
        return None
    try:
        dimensions = [int(scalar(arg, ('SortInt{}',))) for arg in value.args]
    except ValueError as error:
        raise _shape('存储声明的维度不是可读取整数') from error
    if any(dimension <= 0 for dimension in dimensions):
        raise _shape('存储声明的维度必须为正整数')
    return dict(zip(('depth', 'width', 'mask'), dimensions, strict=False))


@dataclass(frozen=True)
class Operation:
    """执行配置中的原操作；procedure_index 始终是保存列表的位置。"""

    name: str | None
    operands: tuple[str, ...]
    raw_operands: tuple[Term, ...]
    attributes: dict[str, Term]
    type: Term | None
    input_types: tuple[Term, ...]
    result_types: tuple[Term, ...]
    term: Term
    result: str | None = None
    result_ssa: str | None = None
    procedure_index: int | None = None
    instance_id: str | None = None
    module_symbol: str | None = None
    unsupported: str | None = None

    @classmethod
    def from_term(cls, term: Term, *, result: str | None = None, procedure_index: int | None = None) -> Operation:
        op = unwrap(term)
        name = None
        raw: tuple[Term, ...] = ()
        operands: tuple[str, ...] = ()
        attributes: dict[str, Term] = {}
        function_type = None
        inputs: tuple[Term, ...] = ()
        outputs: tuple[Term, ...] = ()
        unsupported = None
        try:
            if op.symbol != _OP or len(op.args) != 4:
                raise _shape('操作不是受支持的 StdOp 构造', symbol=op.symbol)
            name = scalar(op.args[0], ('SortString{}',))
            raw = list_items(op.args[1])
            attributes = string_map(op.args[2])
            function_type = op.args[3]
            ft = unwrap(function_type)
            if ft.symbol != _FT or len(ft.args) != 2:
                raise _shape('操作函数类型不是受支持的 StdFT')
            inputs, outputs = type_items(ft.args[0]), type_items(ft.args[1])
            operands = tuple(scalar(arg, ('SortString{}',)) for arg in raw)
            if any(integer_type_width(typ) is None and memory_shape(typ) is None for typ in (*inputs, *outputs)):
                unsupported = '操作包含未支持的类型；保留原始类型'
        except TraceError as error:
            if error.code != StopCode.UNSUPPORTED_SHAPE:
                raise
            unsupported = error.message
        return cls(
            name,
            operands,
            raw,
            attributes,
            function_type,
            inputs,
            outputs,
            term,
            result=result,
            result_ssa=result.rsplit('/', 1)[-1] if result else None,
            procedure_index=procedure_index,
            unsupported=unsupported,
        )


@dataclass(frozen=True)
class PortAlias:
    name: str
    signal_id: str
    instance_id: str
    direction: str
    type: Term


@dataclass(frozen=True)
class TopologyNode:
    signal_id: str
    instance_id: str | None
    module_symbol: str | None
    aliases: tuple[str, ...] = ()
    operation: Operation | None = None
    direct_source: str | None = None
    register: Term | None = None
    storage_kind: str | None = None
    width: int | None = None
    shape: dict[str, int] | None = None
    unsupported: str | None = None


@dataclass(frozen=True)
class TopologyEdge:
    """source 是依赖信号，target 是结果或 procedure:N；每次引用保留一条边。"""

    source: str
    target: str
    relation: str
    operand_index: int | None = None
    operation_name: str | None = None
    source_instance: str | None = None
    target_instance: str | None = None
    kind: str = 'static_candidate'


@dataclass(frozen=True)
class TargetBinding:
    run_id: str
    target_id: str
    kind: str
    name: str
    signal_id: str | None
    aliases: tuple[str, ...]
    instance_id: str | None
    module_symbol: str | None
    width: int | None = None
    shape: dict[str, int] | None = None
    address: str | None = None
    procedure_index: int | None = None
    operation_name: str | None = None
    unsupported: str | None = None

    def to_dict(self) -> dict[str, Any]:
        result = asdict(self)
        result['aliases'] = list(self.aliases)
        result['requires_address'] = self.kind == 'memory_cell' and self.address is None
        return result


class TraceTopology:
    """一次运行 setup 的静态目录；名称查找不会折叠 direct 路径。"""

    def __init__(self, run_id: str, setup: DecodedState, *, deadline: float | None = None) -> None:
        if not run_id.strip():
            raise TraceError(StopCode.INVALID_INPUT, '拓扑必须绑定非空 run_id')
        if setup.completion.status != 'completed':
            raise TraceError(StopCode.INCOMPLETE_EXECUTION, '不能从未完成 setup 建立可信目录')
        self.run_id, self.setup_sha256, self.deadline = run_id, setup.uncompressed_sha256, deadline
        self.top_module = scalar(setup.cells['top-module'], ('SortString{}',))
        self.instances = {instance.id: instance for instance in setup.instances}
        self.port_aliases = tuple(
            PortAlias(f'{instance.id}/{name}', signal, instance.id, direction, typ)
            for instance in self.instances.values()
            for direction, ports in (('input', instance.inputs), ('output', instance.outputs))
            for name, signal, typ in ports
        )
        connections, registers = setup.connection, setup.register
        self.register_proc = setup.register_proc
        names = set(connections) | set(registers) | {port.signal_id for port in self.port_aliases}
        aliases: dict[str, set[str]] = defaultdict(set)
        widths: dict[str, set[int]] = defaultdict(set)
        unsupported_ports = set()
        for port in self.port_aliases:
            aliases[port.signal_id].add(port.name)
            width = integer_type_width(port.type)
            if width is not None:
                widths[port.signal_id].add(width)
            else:
                try:
                    if memory_shape(port.type) is None:
                        unsupported_ports.add(port.signal_id)
                except TraceError:
                    unsupported_ports.add(port.signal_id)
        operations = {}
        directs = {}
        for signal, raw in connections.items():
            self._deadline()
            value = unwrap(raw)
            if value.tag == 'DV' and value.sorts == ('SortString{}',):
                directs[signal] = scalar(value)
                names.add(directs[signal])
            else:
                operations[signal] = self._own(Operation.from_term(raw, result=signal), signal)
                names.update(operations[signal].operands)
        procedures = []
        for index, raw in enumerate(setup.procedures):
            self._deadline()
            op = Operation.from_term(raw, procedure_index=index)
            owner = op.operands[0] if op.operands else None
            procedures.append(self._own(op, owner))
            names.update(op.operands)
        self.procedures = tuple(procedures)
        self.nodes = {}
        for signal in sorted(names):
            self._deadline()
            instance_id, module = self._instance(signal)
            operation = operations.get(signal)
            unsupported = operation.unsupported if operation else None
            if signal in unsupported_ports:
                unsupported = unsupported or '端口包含未支持的类型；保留原始类型'
            storage_kind, shape, width = None, None, None
            if operation and len(operation.result_types) == 1:
                width = integer_type_width(operation.result_types[0])
                try:
                    shape = memory_shape(operation.result_types[0])
                except TraceError as error:
                    unsupported = error.message
            if signal in registers:
                try:
                    values = _sequence(registers[signal], _ATTRS, _ATTRS_EMPTY)
                    if len(values) != 5:
                        raise _shape('register 声明必须包含五项')
                    tag, reg_width, read_latency, write_latency = (
                        int(scalar(value, ('SortInt{}',))) for value in values[:4]
                    )
                    if tag not in (0, 1) or min(reg_width, read_latency, write_latency) < 0:
                        raise _shape('register 声明的类别或维度不受支持')
                    storage_kind = 'register' if tag == 0 else 'memory_cell'
                    declared_name = scalar(values[4], ('SortString{}',))
                    if declared_name and instance_id:
                        aliases[signal].add(f'{instance_id}/{declared_name}')
                    if tag == 0:
                        width = reg_width
                    else:
                        shape = dict(shape or {}, read_latency=read_latency, write_latency=write_latency)
                        width = shape.get('width')
                        if 'depth' not in shape:
                            unsupported = '存储类型形状未知；未推断深度或元素位宽'
                except (TraceError, ValueError) as error:
                    unsupported = str(error)
            declared_widths = widths.get(signal, set())
            if len(declared_widths) > 1 or (width is not None and declared_widths and width not in declared_widths):
                raise TraceError(StopCode.INCONSISTENT_EVIDENCE, '同一信号的声明位宽冲突', signal_id=signal)
            if width is None and declared_widths:
                width = next(iter(declared_widths))
            self.nodes[signal] = TopologyNode(
                signal,
                instance_id,
                module,
                tuple(sorted(aliases[signal])),
                operation,
                directs.get(signal),
                registers.get(signal),
                storage_kind,
                width,
                shape,
                unsupported,
            )
        inputs = {port.signal_id for port in self.port_aliases if port.direction == 'input'}
        outputs = {port.signal_id for port in self.port_aliases if port.direction == 'output'}
        edges = []
        self._direct_dependents: dict[str, list[str]] = defaultdict(list)
        for node in self.nodes.values():
            if node.direct_source is not None:
                source = self.nodes[node.direct_source]
                boundary = source.instance_id != node.instance_id
                relation = (
                    'instance_input'
                    if boundary and node.signal_id in inputs
                    else 'instance_output' if boundary and source.signal_id in outputs else 'direct'
                )
                edges.append(
                    TopologyEdge(
                        source.signal_id,
                        node.signal_id,
                        relation,
                        source_instance=source.instance_id,
                        target_instance=node.instance_id,
                    )
                )
                self._direct_dependents[source.signal_id].append(node.signal_id)
            if node.operation is not None:
                edges.extend(self._operand_edges(node.operation, node.signal_id))
        for op in self.procedures:
            edges.extend(self._operand_edges(op, f'procedure:{op.procedure_index}'))
        self.edges = tuple(edges)
        self._targets = self._catalog()
        self._targets_by_id = {target.target_id: target for target in self._targets}

    @classmethod
    def from_state(cls, run_id: str, setup: DecodedState, *, deadline: float | None = None) -> TraceTopology:
        return cls(run_id, setup, deadline=deadline)

    @classmethod
    def from_run(cls, run: RunArtifacts) -> TraceTopology:
        topology = cls.from_state(run.manifest.run_id, run.read_state(run.setup_id), deadline=run.reader.deadline)
        if topology.top_module != run.manifest.top_module:
            raise TraceError(StopCode.IDENTITY_MISMATCH, 'setup 与 manifest 的顶层模块不同')
        instance = topology.instances.get(topology.top_module)
        if instance is None:
            raise TraceError(StopCode.IDENTITY_MISMATCH, 'setup 缺少声明的顶层实例')
        if run.manifest.ports:
            actual = [
                (direction, name, integer_type_width(typ))
                for direction, ports in (('input', instance.inputs), ('output', instance.outputs))
                for name, _, typ in ports
            ]
            expected = [(port.direction, port.name, port.width) for port in run.manifest.ports]
            if len(actual) != len(expected) or any(
                a[:2] != e[:2] or (a[2] is not None and a[2] != e[2]) for a, e in zip(actual, expected, strict=False)
            ):
                raise TraceError(StopCode.IDENTITY_MISMATCH, 'setup 与 manifest 的端口声明不同', actual=actual)
        return topology

    def _deadline(self) -> None:
        if self.deadline is not None and time.monotonic() >= self.deadline:
            raise TraceError(StopCode.TIME_BUDGET, '拓扑读取达到查询截止时间')

    def _instance(self, signal: str | None) -> tuple[str | None, str | None]:
        if signal is None:
            return None, None
        matches = [name for name in self.instances if signal.startswith(name + '/')]
        instance_id = max(matches, key=len) if matches else None
        return instance_id, self.instances[instance_id].module if instance_id else None

    def _own(self, op: Operation, signal: str | None) -> Operation:
        instance_id, module = self._instance(signal)
        return replace(op, instance_id=instance_id, module_symbol=module)

    def _operand_edges(self, op: Operation, target: str) -> tuple[TopologyEdge, ...]:
        return tuple(
            TopologyEdge(signal, target, 'operand', index, op.name, self.nodes[signal].instance_id, op.instance_id)
            for index, signal in enumerate(op.operands)
        )

    def _storage_aliases(self, signal: str) -> tuple[str, ...]:
        pending, seen = [signal], set()
        aliases: set[str] = set()
        while pending:
            self._deadline()
            current = pending.pop()
            if current in seen:
                continue
            seen.add(current)
            aliases.update(self.nodes[current].aliases)
            pending.extend(self._direct_dependents[current])
        return tuple(sorted(aliases))

    def _id(self, kind: str, signal: str | None, procedure: int | None = None) -> str:
        identity = json.dumps([self.run_id, self.setup_sha256, kind, signal, procedure], ensure_ascii=False)
        return 'target:' + hashlib.sha256(identity.encode()).hexdigest()

    def _catalog(self) -> tuple[TargetBinding, ...]:
        result = []
        for node in self.nodes.values():
            self._deadline()
            for kind in ('signal',) + ((node.storage_kind,) if node.storage_kind else ()):
                aliases = self._storage_aliases(node.signal_id) if kind != 'signal' else node.aliases
                result.append(
                    TargetBinding(
                        self.run_id,
                        self._id(kind, node.signal_id),
                        kind,
                        aliases[0] if aliases else node.signal_id,
                        node.signal_id,
                        aliases,
                        node.instance_id,
                        node.module_symbol,
                        node.width,
                        node.shape,
                        operation_name=node.operation.name if node.operation else None,
                        unsupported=node.unsupported,
                    )
                )
        for op in self.procedures:
            if op.name != 'seq.firmem.write_port':
                continue
            signal = op.operands[0] if op.operands else None
            aliases = self._storage_aliases(signal) if signal in self.nodes else ()
            port_aliases = tuple(f'{alias}/write_port[{op.procedure_index}]' for alias in aliases)
            name = port_aliases[0] if port_aliases else f'procedure:{op.procedure_index}'
            storage = self.nodes.get(signal or '')
            result.append(
                TargetBinding(
                    self.run_id,
                    self._id('memory_write_port', signal, op.procedure_index),
                    'memory_write_port',
                    name,
                    signal,
                    port_aliases,
                    op.instance_id,
                    op.module_symbol,
                    storage.width if storage else None,
                    storage.shape if storage else None,
                    procedure_index=op.procedure_index,
                    operation_name=op.name,
                    unsupported=op.unsupported,
                )
            )
        return tuple(result)

    def list_targets(self, kind: str | None = None) -> tuple[TargetBinding, ...]:
        return tuple(target for target in self._targets if kind is None or target.kind == kind)

    def _names(self, target: TargetBinding) -> set[str]:
        names = {target.name, *target.aliases}
        if target.signal_id is not None and target.kind != 'memory_write_port':
            names.add(target.signal_id)
        if target.procedure_index is not None:
            names.add(f'procedure:{target.procedure_index}')
        return names | {name.replace('/', '.') for name in names}

    def resolve(self, request: Target) -> TargetBinding:
        """解析显式目标；歧义返回全部候选，不选择最后出现的别名。"""
        self._deadline()
        candidates = list(self.list_targets(request.kind))
        if request.target_id:
            base_id = request.target_id
            if request.kind == 'memory_cell' and '/address/' in base_id:
                base_id, recorded_address = base_id.rsplit('/address/', 1)
                if recorded_address != request.address:
                    raise TraceError(StopCode.IDENTITY_MISMATCH, '地址与 target_id 绑定位置不一致')
            candidates = [target for target in candidates if target.target_id == base_id]
            if not candidates:
                raise TraceError(StopCode.IDENTITY_MISMATCH, 'target_id 不属于当前运行或目标类别')
        if request.name:
            exact = [target for target in candidates if request.name in self._names(target)]
            if not exact:
                exact = [
                    target
                    for target in candidates
                    if any(request.name == alias.rsplit('/', 1)[-1] for alias in target.aliases)
                ]
            candidates = exact
        if not candidates:
            raise TraceError(StopCode.INVALID_INPUT, '找不到指定目标', name=request.name, kind=request.kind)
        if len(candidates) != 1:
            raise TraceError(
                StopCode.AMBIGUOUS_TARGET,
                '目标名称对应多个对象，需要选择完整名称或 target_id',
                candidates=[target.to_dict() for target in candidates],
            )
        target = candidates[0]
        if request.kind == 'memory_cell':
            assert request.address is not None
            depth = (target.shape or {}).get('depth')
            if depth is not None and (len(request.address) > len(str(depth)) or int(request.address) >= depth):
                raise TraceError(StopCode.INVALID_INPUT, '存储地址超出已声明深度', depth=depth, address=request.address)
            target = replace(
                target, target_id=target.target_id + '/address/' + request.address, address=request.address
            )
        return target
