"""Python Specification for the CIRCT semantics."""

from __future__ import annotations

from typing import TYPE_CHECKING

from pyk.kcfg.semantics import DefaultSemantics
from pyk.kore.prelude import LBL_LIST, LBL_LIST_ITEM, SORT_K_ITEM, dv, inj
from pyk.kore.syntax import DV, App, SortApp, String

if TYPE_CHECKING:
    from pyk.kore.syntax import Pattern


# TODO: implement
class CirctSemantics(DefaultSemantics): ...


def cell_symbol(cell_id: str) -> str:
    return f"Lbl'-LT-'{cell_id}'-GT-'"  # noqa: E501


def phase_symbol(phase: str) -> str:
    # TODO: refactor this to make it more readable as a K Definition
    # something like: ksymbol("#{phase} MLIR-CONF PhaseControl")?
    return f"Lbl'Hash'{phase}'Unds'MLIR-CONF'Unds'PhaseControl"  # noqa: E501


def cmd_symbol(cmd: str) -> str:
    return f"Lbl'Hash'{cmd}'Unds'COMMON-SYNTAX'Unds'CmdCIRCT"  # noqa: E501


def cmd(cmd: str) -> Pattern:
    return inj(SortApp('SortCmdCIRCT'), SORT_K_ITEM, App(cmd_symbol(cmd)))


def bits(value: int, size: int) -> Pattern:
    # TODO: really hard to understand and maintain. optimize later.
    # TODO: Generate Symbols automatically
    k_type_dv = DV(SortApp('SortSignlessIntegerType'), String(f'i{size}'))
    k_type = inj(SortApp('SortSignlessIntegerType'), SortApp('SortType'), k_type_dv)
    bits_value = inj(SortApp('SortInt'), SortApp('SortBitsValue'), dv(value))
    bits = App(
        symbol="Lblbits'LParUndsCommUndsRParUnds'BITS'Unds'Bits'Unds'BitsValue'Unds'Int", args=(bits_value, dv(size))
    )
    return App("Lbl'UndsColnUndsUnds'STDVALUE-SYNTAX'Unds'StdValue'Unds'Bits'Unds'Type", args=(bits, k_type))


def bits_list(values: list[tuple[int, int]]) -> Pattern:
    args = [inj(SortApp('SortStdValue'), SortApp('SortKItem'), bits(value, size)) for value, size in values]
    return App(LBL_LIST_ITEM, args=(App(LBL_LIST, args=(App(LBL_LIST_ITEM, args=(arg,)) for arg in args)),))
