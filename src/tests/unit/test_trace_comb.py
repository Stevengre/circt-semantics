"""以独立整数期望核对限定规则，不从查询器生成期望。"""

from __future__ import annotations

from dataclasses import replace

import pytest

from kcirct.trace.kore import Term, _Node
from kcirct.trace.model import BitVector, StopCode, TraceError
from kcirct.trace.semantics import evaluate_comb
from kcirct.trace.topology import Operation


def _dv(value: str, sort: str) -> Term:
    """构造指定 sort 的最小 Term 域值，供组合规则测试独立声明类型和属性。"""
    return Term((_Node('DV', '', (f'Sort{sort}{{}}',), value, ()),), 0)


def operation(name: str, widths: tuple[int, ...], output: int, **attributes: int) -> Operation:
    """按整数位宽和属性构造合成 Operation，避免依赖拓扑解析器生成待测输入。"""
    return Operation(
        name,
        tuple(f'%{index}' for index in range(len(widths))),
        (),
        {key: _dv(str(value), 'Int') for key, value in attributes.items()},
        None,
        tuple(_dv(f'i{width}', 'SignlessIntegerType') for width in widths),
        (_dv(f'i{output}', 'SignlessIntegerType'),),
        _dv('test', 'String'),
    )


@pytest.mark.parametrize(
    ('name', 'values', 'widths', 'output', 'attributes', 'expected'),
    [
        ('hw.constant', (), (), 8, {'value': -1}, 255),
        ('seq.to_clock', (1,), (1,), 1, {}, 1),
        ('comb.add', (255, 2, 8), (8, 8, 8), 8, {}, 9),
        ('comb.add', (255, 1), (8, 8), 16, {}, 0),
        ('comb.add', (256, 255, 1), (16, 8, 8), 16, {}, 256),
        ('comb.and', (0b1101, 0b1011), (4, 4), 4, {}, 9),
        ('comb.or', (0b0101, 0b1000), (4, 4), 4, {}, 13),
        ('comb.xor', (0b1101, 0b1011), (4, 4), 4, {}, 6),
        ('comb.concat', (10, 3, 1), (4, 2, 1), 7, {}, 87),
        ('comb.concat', (10, 3, 1), (4, 2, 1), 4, {}, 7),
        ('comb.extract', (0b110110,), (6,), 3, {'lowBit': 2}, 5),
        ('comb.extract', (12,), (8,), 3, {'lowBit': 10000000000000000000}, 0),
        ('comb.shru', (240, 2), (8, 8), 8, {}, 60),
        ('comb.shru', (240, 255), (8, 8), 8, {}, 0),
        ('comb.shl', (127, 1), (8, 8), 8, {}, 254),
        ('comb.shl', (127, 7), (8, 4), 8, {}, 128),
        ('comb.shl', (1, 1), (8, 1), 8, {}, 8),
        ('comb.shl', (127, 255), (8, 8), 8, {}, 0),
    ],
)
def test_independent_bit_operations(
    name: str, values: tuple[int, ...], widths: tuple[int, ...], output: int, attributes: dict[str, int], expected: int
) -> None:
    """用手写整数期望核对各组合操作，覆盖中间截断、拼接和移位边界。"""
    result = evaluate_comb(
        operation(name, widths, output, **attributes),
        tuple(BitVector.from_int(value, width) for value, width in zip(values, widths, strict=True)),
    )
    assert result.value == BitVector.from_int(expected, output)


@pytest.mark.parametrize('selector', [0, 1])
def test_mux_actual_sources_and_unselected_candidate(selector: int) -> None:
    """验证 mux 只选择一路数据，把 selector 标成控制、另一数据端标成静态候选。"""
    op = operation('comb.mux', (1, 8, 8), 8)
    result = evaluate_comb(op, (BitVector.from_int(selector, 1), BitVector.from_int(19, 8), BitVector.from_int(43, 8)))
    assert result.value.unsigned == (19 if selector else 43)
    assert result.controls == (0,)
    assert result.data == ((1,) if selector else (2,))
    assert result.candidates == ((2,) if selector else (1,))


@pytest.mark.parametrize(
    ('predicate', 'less', 'equal', 'greater'),
    [
        (0, 0, 1, 0),
        (1, 1, 0, 1),
        (2, 1, 0, 1),
        (3, 1, 0, 0),
        (4, 0, 0, 1),
        (5, 0, 1, 1),
        (6, 1, 0, 0),
        (7, 1, 1, 0),
        (8, 0, 0, 1),
        (9, 0, 1, 1),
        (10, 0, 1, 0),
        (11, 1, 0, 1),
    ],
)
def test_bound_k_predicates(predicate: int, less: int, equal: int, greater: int) -> None:
    """用小于、等于和大于三类输入核对已绑定 K 规则的全部数字比较谓词。"""
    op = operation('comb.icmp', (8, 8), 1, predicate=predicate)
    actual = [
        evaluate_comb(op, (BitVector.from_int(first, 8), BitVector.from_int(second, 8))).value.unsigned
        for first, second in ((2, 128), (128, 128), (128, 2))
    ]
    assert actual == [less, equal, greater]


def test_large_value_remains_exact() -> None:
    """验证 256 位加法结果以精确十进制字符串保存，不丢失大整数精度。"""
    op = operation('comb.add', (256, 256), 256)
    result = evaluate_comb(op, (BitVector.from_int(2**255 + 9, 256), BitVector.from_int(5, 256)))
    assert result.value.value == str(2**255 + 14)


@pytest.mark.parametrize(
    'op',
    [
        operation('comb.mul', (8, 8), 8),
        operation('comb.add', (), 8),
        operation('comb.mux', (8, 8, 8), 8),
        operation('seq.to_clock', (8,), 1),
        operation('comb.extract', (8,), 8, lowBit=-1),
        operation('comb.icmp', (8, 8), 1, predicate=99),
        operation('hw.constant', (), 10**20, value=1),
        replace(operation('hw.constant', (), 8, value=1), unsupported='unknown packed shape'),
    ],
)
def test_unknown_or_resource_excess_shapes_stop(op: Operation) -> None:
    """验证未知操作、非法形状和过大位宽均返回明确的不支持原因。"""
    values = tuple(BitVector.from_int(0, int(typ.value[1:])) for typ in op.input_types if typ.value)
    with pytest.raises(TraceError) as caught:
        evaluate_comb(op, values)
    assert caught.value.code in {StopCode.UNSUPPORTED_OPERATION, StopCode.UNSUPPORTED_SHAPE, StopCode.UNSUPPORTED_VALUE}
