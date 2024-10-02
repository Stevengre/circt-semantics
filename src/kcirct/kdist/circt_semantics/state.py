"""Python Bindings for the State in the CIRCT Semantics. circt/conf.k"""

from __future__ import annotations

from dataclasses import dataclass
from functools import cached_property
from typing import final, Mapping

from pyk.kore.prelude import SORT_K_ITEM, SortApp, inj, top_cell_initializer
from pyk.kore.syntax import Pattern



@final
@dataclass(frozen=True)
class KCIRCTState(Pattern):
    # TODO: lift this to the pyk
    # TODO: Provide a new module for semantics
    """State for the CIRCT Semantics."""

    @staticmethod
    def initialize(pgm: Pattern) -> KCIRCTState:
        """Initialize the state."""
        return top_cell_initializer({'$PGM': inj(SortApp('SortTopLevel'), SORT_K_ITEM, pgm)})

    @cached_property
    def cells(self) -> Mapping[str, Pattern]:
        """Get the cells in the state."""
        ...

    def cell(self, cell_id: str) -> Pattern:
        """Get the cell with the given cell id."""
        ...

    def set_cell(self, cell_id: str, cell: Pattern) -> KCIRCTState:
        """Set the cell with the given cell id."""
        ...

    def match_and_rewrite(
        self, match_config: Mapping[str, Pattern], rewrite_config: Mapping[str, Pattern]
    ) -> tuple[bool, Pattern]:
        """Check if the pattern is a match and rewrite it."""
        ...
