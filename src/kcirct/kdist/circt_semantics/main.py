"""Python Specification for the CIRCT semantics."""

from __future__ import annotations

from pyk.kcfg.semantics import DefaultSemantics
from pyk.kore.syntax import *
from pyk.kore.prelude import *

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

def bits(value: int, width: int) -> Pattern:
    return App(symbol="Lbl'UndsColnUndsUnds'STDVALUE-SYNTAX'Unds'StdValue'Unds'Bits'Unds'Type", sorts=(), args=(App(symbol="Lblbits'LParUndsCommUndsRParUnds'BITS'Unds'Bits'Unds'BitsValue'Unds'Int", sorts=(), args=(App(symbol='inj', sorts=(SortApp(name='SortInt', sorts=()), SortApp(name='SortBitsValue', sorts=())), args=(DV(sort=SortApp(name='SortInt', sorts=()), value=String(value=f'{value}')),)), DV(sort=SortApp(name='SortInt', sorts=()), value=String(value=f'{width}')))), App(symbol='inj', sorts=(SortApp(name='SortSignlessIntegerType', sorts=()), SortApp(name='SortType', sorts=())), args=(DV(sort=SortApp(name='SortSignlessIntegerType', sorts=()), value=String(value=f'i{width}')),))))