"""端口别名读取的回归测试，无需编译或运行 K 定义。"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from pyk.kore.prelude import SORT_K_ITEM, dv, inj, list_pattern, map_pattern
from pyk.kore.syntax import DV, App, SortApp, String

from kcirct.api import KCIRCT
from kcirct.kdist.circt_semantics.main import cell_symbol

if TYPE_CHECKING:
    from pyk.kore.syntax import Pattern


def _item(value: str | int) -> Pattern:
    token = dv(value)
    return inj(token.sort, SORT_K_ITEM, token)


def _names(names: tuple[str, ...], sort_name: str) -> Pattern:
    sort = SortApp(sort_name)
    return list_pattern(*(inj(sort, SORT_K_ITEM, DV(sort, String(name))) for name in names))


def _state_file(
    tmp_path: Path,
    *,
    inputs: tuple[tuple[str, str], ...] = (),
    outputs: tuple[tuple[str, str], ...] = (),
    signals: dict[str, tuple[int, int]] | None = None,
    memory: tuple[str, str] | None = None,
) -> Path:
    """构造读取函数所需的 Kore cell，省略无关的执行配置。"""
    register = map_pattern()
    if memory is not None:
        signal, name = memory
        attributes: Pattern = App(
            "Lbl'Stop'List'LBraQuotUndsCommUndsUnds'BUILTIN-SYNTAX'Unds'AttributeValueList"
            "'Unds'AttributeValue'Unds'AttributeValueList'QuotRBraUnds'AttributeValueList"
        )
        attribute_values: tuple[int | str, ...] = (1, 0, 0, 0, name)
        for value in reversed(attribute_values):
            token = dv(value)
            attributes = App(
                "Lbl'UndsCommUndsUnds'BUILTIN-SYNTAX'Unds'AttributeValueList'Unds'AttributeValue'Unds'AttributeValueList",
                args=(inj(token.sort, SortApp('SortAttributeValue'), token), attributes),
            )
        register = map_pattern((_item(signal), inj(SortApp('SortAttributeValueList'), SORT_K_ITEM, attributes)))

    signal_values = []
    for signal, (value, width) in (signals or {}).items():
        bits = App(
            "Lblbits'LParUndsCommUndsRParUnds'BITS-SYNTAX'Unds'Bits'Unds'BitsValue'Unds'Int",
            args=(inj(SortApp('SortInt'), SortApp('SortBitsValue'), dv(value)), dv(width)),
        )
        signal_values.append((_item(signal), inj(SortApp('SortBits'), SORT_K_ITEM, bits)))

    cells = {
        'hw-inputs': _names(tuple(name for name, _ in inputs), 'SortBareId'),
        'hw-inports': _names(tuple(signal for _, signal in inputs), 'SortString'),
        'hw-in-types': list_pattern(),
        'hw-outputs': _names(tuple(name for name, _ in outputs), 'SortBareId'),
        'hw-outports': _names(tuple(signal for _, signal in outputs), 'SortString'),
        'hw-out-types': list_pattern(),
        'register': register,
        'register-proc': map_pattern(),
        'signals': map_pattern(*signal_values),
        'history': map_pattern(),
    }
    path = tmp_path / 'state.kore'
    path.write_text('\n'.join(App(cell_symbol(name), args=(value,)).text for name, value in cells.items()))
    return path


def test_read_ports_preserves_shared_constant_outputs(tmp_path: Path) -> None:
    # D12 中 ready 和 keep 共享常量 %3；旧实现只保留最后一个输出名。
    state = _state_file(
        tmp_path,
        outputs=(('s_axis_tready', 'axis_fifo/%3'), ('m_axis_tkeep', 'axis_fifo/%3')),
        signals={'axis_fifo/%3': (1, 1)},
    )
    kcirct = object.__new__(KCIRCT)

    assert kcirct.read_ports_fast(state) == {'axis_fifo/s_axis_tready': (1, 1), 'axis_fifo/m_axis_tkeep': (1, 1)}
    assert kcirct.read_signal_port_aliases(state) == {
        'axis_fifo/%3': ['axis_fifo/s_axis_tready', 'axis_fifo/m_axis_tkeep']
    }


def test_read_ports_preserves_input_output_aliases(tmp_path: Path) -> None:
    state = _state_file(
        tmp_path,
        inputs=(('data_in', 'top/child/%arg0'),),
        outputs=(('data_out', 'top/child/%arg0'),),
        signals={'top/child/%arg0': (37, 8)},
    )

    assert object.__new__(KCIRCT).read_ports_fast(state) == {
        'top/child/data_in': (37, 8),
        'top/child/data_out': (37, 8),
    }


def test_read_ports_expands_each_memory_alias(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    state = _state_file(tmp_path, outputs=(('storage', 'top/%mem'),), memory=('top/%mem', 'mem'))
    kcirct = object.__new__(KCIRCT)
    # 内存值解析是独立逻辑；这里保留真实端口与 register 别名读取。
    monkeypatch.setattr(kcirct, 'read_signals', lambda _path: {'top/%mem': {(0, 2): (5, 8), (3, 2): (9, 8)}})

    assert kcirct.read_ports_fast(state) == {
        'top/storage/Memory[0]': (5, 8),
        'top/storage/Memory[3]': (9, 8),
        'top/mem_ext/Memory[0]': (5, 8),
        'top/mem_ext/Memory[3]': (9, 8),
    }


@pytest.mark.parametrize('skip_missing', [False, True])
def test_read_ports_missing_signal_policy(tmp_path: Path, skip_missing: bool) -> None:
    state = _state_file(
        tmp_path,
        inputs=(('clk', 'top/%clk'),),
        outputs=(('first', 'top/%missing'), ('second', 'top/%missing')),
        signals={'top/%clk': (0, 1)},
    )
    kcirct = object.__new__(KCIRCT)

    if skip_missing:
        assert kcirct.read_ports_fast(state, skip_missing=True) == {'top/clk': (0, 1)}
    else:
        with pytest.raises(KeyError, match='top/%missing'):
            kcirct.read_ports_fast(state)


def test_legacy_mapping_keeps_last_alias(tmp_path: Path) -> None:
    state = _state_file(
        tmp_path,
        inputs=(('data_in', 'top/%arg0'),),
        outputs=(('first', 'top/%arg0'), ('second', 'top/%arg0'), ('storage', 'top/%mem')),
        memory=('top/%mem', 'mem'),
    )

    assert KCIRCT.read_signal_port_mapping(state) == {'top/%arg0': 'top/second', 'top/%mem': 'top/mem_ext'}
