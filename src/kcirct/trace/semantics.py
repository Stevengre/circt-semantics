"""有限的、绑定规则内容的离线解释器；不执行 K，也不修补保存值。"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from functools import reduce
from operator import and_, or_, xor
from typing import TYPE_CHECKING

from .kore import bit_vector, map_items, scalar, unwrap
from .model import BitVector, StopCode, TraceError
from .topology import attribute_value, integer_type_width, memory_shape

if TYPE_CHECKING:
    from .artifacts import RunArtifacts
    from .kore import Term
    from .topology import Operation, TopologyNode


# 内容身份来自本组件实施时逐项核对的规则与编译工件，不是设计名或事件号。
# 新规则集必须重新审阅；仅同名操作不能选择此解释器。
_PROFILES = {
    '2a82d12ea2e894e400629d3c6c7b3210fc4b68717f21a3dcf672f0a8b52a8db3': (
        '08ac54e383967aa9aa7ba218cd0148e2b4d3f19dea67ddab33f120d661854e2b',
        True,
    ),
    '76482f9b54d1292aba05fd0489ffbd161d185b122cec6463362c3bc80a43c01d': (
        'dde1d534d8221c9520a9204bf8b4972d7f413cec24cd1d7f55252b55fee81260',
        False,
    ),
}


@dataclass(frozen=True)
class SemanticsProfile:
    source_sha256: str
    definition_sha256: str
    preset_supported: bool
    binding: str
    limitations: tuple[str, ...] = ()


def bind_semantics(run: RunArtifacts) -> SemanticsProfile:
    """同时核对源码内容、规则集身份与原始构建关联，未知来源明确止步。"""
    hashes = run.manifest.identities.get('semantics_hashes')
    if (
        not isinstance(hashes, dict)
        or not hashes
        or any(not isinstance(key, str) or not isinstance(value, str) for key, value in hashes.items())
    ):
        raise TraceError(StopCode.UNSUPPORTED_SEMANTICS, '运行缺少可核验的语义源码身份')
    digest = hashlib.sha256(json.dumps(hashes, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
    if digest not in _PROFILES:
        raise TraceError(StopCode.UNSUPPORTED_SEMANTICS, '规则内容不在已审阅的有限解释范围', source_sha256=digest)
    definition, preset = _PROFILES[digest]
    declared = run.manifest.identities.get('semantics_binding', {})
    if isinstance(declared, dict) and declared.get('definition_sha256') not in (None, definition):
        raise TraceError(StopCode.IDENTITY_MISMATCH, '显式声明的编译定义与绑定规则冲突')
    for name, expected in hashes.items():
        key = 'semantics/' + name
        ref = run.manifest.artifacts.get(key)
        if ref is None or ref.role != 'semantics_source' or ref.sha256 != expected:
            raise TraceError(StopCode.UNSUPPORTED_SEMANTICS, '缺少已绑定规则的原始字节', source=name)
        run.verify_artifact(key)
    ref = run.manifest.artifacts.get('definition/definition.kore')
    if ref is not None:
        if ref.sha256 != definition:
            raise TraceError(StopCode.UNSUPPORTED_SEMANTICS, '编译定义与已审阅规则身份不匹配')
        run.verify_artifact('definition/definition.kore')
        return SemanticsProfile(digest, definition, preset, 'source_and_definition_verified')
    # 早期运行只留下原构建清单。只接受两份独立原记录的一致关联，并明确字节缺口。
    if preset:
        raise TraceError(StopCode.UNSUPPORTED_SEMANTICS, '当前运行缺少编译定义，不能从安装包推断规则来源')
    originals = {
        'legacy_versions': 'ef13d7ea7fe43b55a62f7039083d553755dbfcfc077b5303b8c4bcc76c25bd45',
        'legacy_prepared': '6eaa5dfcd0334fc348c2de6969c0bba12d7ef43b58a7cb6201fa6c2f3fe9f198',
    }
    for key, original_sha256 in originals.items():
        artifact = run.manifest.artifacts.get(key)
        if artifact is None or artifact.sha256 != original_sha256:
            raise TraceError(StopCode.UNSUPPORTED_SEMANTICS, '历史规则缺少原始构建关联记录', artifact=key)
        path = run.verify_artifact(key)
        try:
            record = json.loads(run._text(path, run.reader.budget.max_state_bytes))
        except (ValueError, OSError) as error:
            raise TraceError(StopCode.UNSUPPORTED_SEMANTICS, '历史构建关联记录无效') from error
        if not isinstance(record, dict) or record.get('semantics_hashes') != hashes:
            raise TraceError(StopCode.UNSUPPORTED_SEMANTICS, '历史源码记录与实际绑定内容不同', artifact=key)
        if key == 'legacy_prepared' and record.get('definition_sha256') != definition:
            raise TraceError(StopCode.UNSUPPORTED_SEMANTICS, '历史定义身份不在已审阅范围')
    return SemanticsProfile(
        digest,
        definition,
        preset,
        'source_verified_definition_recorded',
        ('历史 compiled definition 原字节缺失；解释绑定已核验源码和原构建记录，未声称编译工件已核验。',),
    )


def attribute_int(op: Operation, name: str, *, allow_bool: bool = False) -> int:
    if name not in op.attributes:
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '操作缺少整数属性', operation=op.name, attribute=name)
    try:
        raw = unwrap(op.attributes[name])
        if allow_bool and raw.sorts == ('SortBool{}',):
            boolean = scalar(raw, ('SortBool{}',))
            if boolean not in ('true', 'false'):
                raise ValueError('布尔属性必须为 true 或 false')
            return int(boolean == 'true')
        return int(scalar(attribute_value(op.attributes[name]), ('SortInt{}',)))
    except (TraceError, ValueError) as error:
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '操作属性不是受支持整数', attribute=name) from error


def bounded_width(width: int | None) -> int:
    # 限制解释器本地大整数分配；读取器的字节预算不能约束随后构造的 1 << width。
    if width is None or not 0 < width <= 1_048_576:
        raise TraceError(StopCode.UNSUPPORTED_VALUE, '解释位宽超出有限资源范围', width=width)
    return width


def cast_value(value: int, width: int) -> BitVector:
    bounded_width(width)
    return BitVector.from_int(value % (1 << width), width)


def bound_attribute_bits(op: Operation, name: str, width: int) -> BitVector:
    """忠实于 ToInt/StdBits；负的整位宽倍数产生越宽值，不能悄悄修成零。"""
    modulus = 1 << bounded_width(width)
    number = attribute_int(op, name, allow_bool=True)
    value = modulus - ((-number) & (modulus - 1)) if number < 0 else number & (modulus - 1)
    if value >= modulus:
        raise TraceError(StopCode.UNSUPPORTED_VALUE, 'StdBits 的结果越出声明位宽', attribute=name, width=width)
    return BitVector.from_int(value, width)


def register_width(op: Operation) -> int:
    """首轮只解释整数、同步、二或四操作数的原生 firreg。"""
    if op.name != 'seq.firreg' or op.unsupported or len(op.result_types) != 1 or len(op.operands) not in (2, 4):
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '寄存器必须是二或四操作数的 seq.firreg')
    if 'isAsync' in op.attributes:
        raise TraceError(StopCode.UNSUPPORTED_INITIALIZATION, '异步复位寄存器不在已验证范围')
    result = unwrap(op.result_types[0])
    if result.sorts != ('SortSignlessIntegerType{}',):
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '寄存器仅支持 signless integer 类型')
    width = bounded_width(integer_type_width(result))
    expected = (width, 1) if len(op.operands) == 2 else (width, 1, 1, width)
    if tuple(integer_type_width(typ) for typ in op.input_types) != expected:
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '寄存器 Next、Clk 或同步复位类型不匹配')
    return width


def register_initial(op: Operation, profile: SemanticsProfile) -> tuple[BitVector, str]:
    """历史缺值时按已绑定规则给出读取初值，并保留其非快照来源。"""
    width = register_width(op)
    if 'preset' in op.attributes:
        if not profile.preset_supported:
            raise TraceError(StopCode.UNSUPPORTED_INITIALIZATION, '该历史规则绑定未验证显式 preset 初始化')
        return bound_attribute_bits(op, 'preset', width), 'explicit_preset'
    return cast_value(0, width), 'bound_two_state_default_zero'


@dataclass(frozen=True)
class RegisterDecision:
    value: BitVector
    decision: str
    selected: int | None
    bootstrap: bool
    edge: bool


def evaluate_posedge(current: BitVector, prior: BitVector | None) -> tuple[bool, bool]:
    """返回 edge、bootstrap；None 专指缺失 history 项，不是保存的四态值。"""
    if current.width != 1 or prior is not None and prior.width != 1:
        raise TraceError(StopCode.UNSUPPORTED_CLOCK, '当前和历史时钟必须为一位值')
    edge = current.unsigned == 1 and (prior is None or prior.unsigned == 0)
    return edge, edge and prior is None


def evaluate_register(
    op: Operation, values: tuple[BitVector, ...], old: BitVector, prior_clock: BitVector | None
) -> RegisterDecision:
    """使用原始 ClkId 对应的 history；缺值按 checkEdge 的 #x 分支解释。"""
    width = register_width(op)
    if (
        old.width != width
        or len(values) != len(op.operands)
        or tuple(value.width for value in values) != tuple(integer_type_width(typ) for typ in op.input_types)
    ):
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '寄存器保存值与原生操作数位宽不符')
    edge, bootstrap = evaluate_posedge(values[1], prior_clock)
    if not edge:
        return RegisterDecision(old, 'no_edge_hold', None, bootstrap, False)
    reset = len(values) == 4 and values[2].unsigned != 0
    selected = 3 if reset else 0
    return RegisterDecision(values[selected], 'capture_reset' if reset else 'capture_next', selected, bootstrap, True)


def memory_dimensions(node: TopologyNode, writer: Operation) -> tuple[int, int, int]:
    """限定已核验的单写口整字存储；mask 类型不补造动态 mask 参数。"""
    shape, declaration = node.shape or {}, node.operation
    if (
        node.storage_kind != 'memory_cell'
        or node.unsupported
        or declaration is None
        or declaration.name != 'seq.firmem'
        or declaration.operands
        or len(declaration.result_types) != 1
        or shape.get('read_latency') != 0
        or shape.get('write_latency') != 1
        or shape.get('mask', 1) != 1
        or shape.get('depth', 0) <= 0
    ):
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '存储仅支持 RL0/WL1、单写口、整字的 seq.firmem')
    if set(declaration.attributes) - {'name', 'readLatency', 'writeLatency', 'ruw', 'wuw'}:
        raise TraceError(StopCode.UNSUPPORTED_INITIALIZATION, '存储声明含未核验的初始化或扩展属性')
    depth, width = shape['depth'], bounded_width(shape.get('width'))
    address_width = bounded_width(max(1, (depth - 1).bit_length()))
    if writer.name != 'seq.firmem.write_port' or writer.unsupported or len(writer.operands) not in (5, 6):
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '写口必须具有 mem/address/clock/enable/data 及可选全字掩码')
    if writer.result_types or len(writer.input_types) != len(writer.operands):
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '写口的结果或输入类型不受支持')
    declared = memory_shape(writer.input_types[0])
    if declared is None or any(declared.get(key, 1) != shape.get(key, 1) for key in ('depth', 'width', 'mask')):
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '写口与存储声明类型不一致')
    expected = (address_width, 1, 1, width) + ((1,) if len(writer.operands) == 6 else ())
    if tuple(integer_type_width(typ) for typ in writer.input_types[1:]) != expected:
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '写口地址、时钟、使能、数据或掩码位宽不受支持')
    return depth, width, address_width


def memory_contents(term: Term | None, dimensions: tuple[int, int, int]) -> dict[int, BitVector]:
    """保留真实条目；缺项默认值由调用者显式标注，不补造存储快照。"""
    depth, width, address_width = dimensions
    result: dict[int, BitVector] = {}
    if term is None:
        return result
    for address, value in map_items(term):
        key, data = bit_vector(address), bit_vector(value)
        if key.width != address_width or key.unsigned >= depth or data.width != width:
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, '存储 Map 的地址或数据类型不符合声明')
        if key.unsigned in result:
            raise TraceError(StopCode.INCONSISTENT_EVIDENCE, '存储 Map 存在重复地址')
        result[key.unsigned] = data
    return result


@dataclass(frozen=True)
class MemoryDecision:
    decision: str
    edge: bool
    bootstrap: bool
    address: BitVector
    data: BitVector
    old: BitVector
    new: BitVector


def evaluate_memory_write(
    dimensions: tuple[int, int, int],
    values: tuple[BitVector, ...],
    before: dict[int, BitVector],
    prior_clock: BitVector | None,
) -> MemoryDecision:
    depth, width, address_width = dimensions
    expected_widths = (address_width, 1, 1, width) + ((1,) if len(values) == 5 else ())
    if len(values) not in (4, 5) or tuple(value.width for value in values) != expected_widths:
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '实际写实参与声明不一致')
    address, clock, enable, data = values[:4]
    if address.unsigned >= depth:
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '写地址超出声明深度')
    if len(values) == 5 and values[4].unsigned != 1:
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '动态部分或全零掩码不在整字写支持范围')
    edge, bootstrap = evaluate_posedge(clock, prior_clock)
    decision = 'no_edge' if not edge else 'disabled' if not enable.unsigned else 'write'
    old = before.get(address.unsigned, BitVector.from_int(0, width))
    return MemoryDecision(decision, edge, bootstrap, address, data, old, data if decision == 'write' else old)


@dataclass(frozen=True)
class Evaluation:
    value: BitVector
    data: tuple[int, ...]
    controls: tuple[int, ...] = ()
    candidates: tuple[int, ...] = ()
    facts: dict[str, str | int | bool] | None = None


def evaluate_comb(op: Operation, values: tuple[BitVector, ...]) -> Evaluation:
    """按所绑定 K 规则重算整数形状；调用方必须与实际保存值核对。"""
    if op.unsupported or len(op.result_types) != 1 or len(values) != len(op.operands):
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '组合操作形状不受支持', operation=op.name)
    width = bounded_width(integer_type_width(op.result_types[0]))
    if len(op.input_types) != len(values) or any(
        integer_type_width(typ) != value.width for typ, value in zip(op.input_types, values, strict=True)
    ):
        raise TraceError(StopCode.UNSUPPORTED_SHAPE, '组合操作数与类型位宽不符', operation=op.name)
    name, integers = op.name, tuple(value.unsigned for value in values)
    data = tuple(range(len(values)))
    controls: tuple[int, ...] = ()
    candidates: tuple[int, ...] = ()
    facts: dict[str, str | int | bool] = {}
    if name == 'hw.constant' and not values:
        result = bound_attribute_bits(op, 'value', width).unsigned
    elif name == 'seq.to_clock' and len(values) == 1 and values[0].width == width == 1:
        result = integers[0]
    elif name in {'comb.add', 'comb.and', 'comb.or', 'comb.xor'} and values:
        if name == 'comb.add':
            total = values[-1]
            for value in reversed(values[:-1]):
                total = cast_value(value.unsigned + total.unsigned, max(value.width, total.width))
            result = total.unsigned
        else:
            function = {'comb.and': and_, 'comb.or': or_, 'comb.xor': xor}[name]
            result = reduce(function, integers)
    elif name == 'comb.mux' and len(values) == 3:
        if values[0].width != 1 or values[1].width != width or values[2].width != width:
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, 'mux 仅支持 i1 selector 和相同整数数据位宽')
        selected = 1 if integers[0] else 2
        result, data, controls, candidates = integers[selected], (selected,), (0,), (3 - selected,)
        facts = {'selector': integers[0], 'selected_operand': selected}
    elif name == 'comb.concat' and values:
        result = 0
        for value in values:
            bounded_width(value.width)
            result = ((result << value.width) | value.unsigned) % (1 << width)
    elif name == 'comb.extract' and len(values) == 1:
        low = attribute_int(op, 'lowBit')
        if low < 0:
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, 'extract lowBit 必须非负')
        result = 0 if low >= values[0].width else integers[0] >> low
        facts = {'low_bit': low}
    elif name in {'comb.shl', 'comb.shru'} and len(values) == 2:
        shift = integers[1]
        # BitsShl 对最高位为 1 的 RHS 使用 X2 + 2^W2；不要改成通用 HDL 规则。
        if name == 'comb.shl' and shift.bit_length() == values[1].width:
            shift += 1 << bounded_width(values[1].width)
        result = (
            0
            if shift >= values[0].width
            else (
                (integers[0] << shift) % (1 << bounded_width(values[0].width))
                if name == 'comb.shl'
                else integers[0] >> shift
            )
        )
        facts = {'effective_shift': shift}
    elif name == 'comb.icmp' and len(values) == 2 and width == 1:
        pred = attribute_int(op, 'predicate')
        first, second = integers
        predicates = {
            0: first == second,
            1: first != second,
            2: first != second,
            3: first < second,
            4: first > second,
            5: first >= second,
            6: first < second,
            7: first <= second,
            8: first > second,
            9: first >= second,
            10: first == second,
            11: first != second,
        }
        if pred not in predicates or (pred in (10, 11) and values[0].width != values[1].width):
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, 'icmp predicate 或操作数位宽不受支持')
        result, facts = int(predicates[pred]), {'predicate': pred}
    else:
        raise TraceError(StopCode.UNSUPPORTED_OPERATION, '操作不在已实现的有限组合解释范围', operation=name)
    return Evaluation(cast_value(result, width), data, controls, candidates, facts)
