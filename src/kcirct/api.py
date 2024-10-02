"""Python Interface for the CIRCT Semantics.

It does not include:
2. `kimulator` and its subcommands.
"""

from __future__ import annotations

from pathlib import Path
from typing import Iterable

from pyk.kdist import KDist, kdist, target_ids
from pyk.kore.parser import KoreParser
from pyk.kore.syntax import Pattern
from pyk.ktool.kprint import _kast
from pyk.ktool.krun import KRun
import pyk.testing

from kcirct.utils import check_file_path


class KCIRCT:
    # Tools
    _krun: KRun | None
    # Attributes
    _kdist_target: str

    def __init__(self, kdist_target: str = 'circt-semantics.llvm') -> None:
        self._kdist_target = kdist_target
        self._krun = KRun(definition_dir=self.definition_dir)

    # Tools

    def build(self, target_ids: Iterable[str] = target_ids(), verbose: bool = True, clean: bool = True) -> None:
        """Build the CIRCT Semantics."""
        kdist.build(target_ids=target_ids, verbose=verbose, clean=clean)

    def compile(self, file: Path) -> Pattern:
        """Translate Generic MLIR to Kore."""
        result = _kast(
            definition_dir=self.definition_dir,
            input='program',
            output='kore',
            file=file,
        )
        if result.returncode != 0:
            raise RuntimeError(result.stderr)
        return KoreParser(result.stdout).pattern()
    
    def run(self, file: Path) -> None:
        """Run the CIRCT Semantics pipeline on Kore."""
        ...
    
    def run_preprocess(self, file: Path) -> None:
        """Run the preprocess step on Kore. 
        
        This is the first step in the CIRCT Semantics pipeline.
        Use the MLIR static semantics in `circt-semantics/mlir`.
        phase = "preprocess" | "canonicalized"
        """
        ...
    
    def run_setup(self, file: Path) -> None:
        """Run the hardware setup step on Kore.
        
        This is the second step in the CIRCT Semantics pipeline.
        Use the hardware setup in `circt-semantics/circt` and `circt-semantics/dialects`.
        phase = "setup"
        """
        ...
        
    def run_initialize(self, file: Path) -> None:
        """Run the initialize step on Kore.
        
        This is the third step in the CIRCT Semantics pipeline.
        phase = "initialize"
        """
        ...
    
    def run_simulate(self, file: Path) -> None:
        """Run the simulate step on Kore.
        
        This is the fourth step in the CIRCT Semantics pipeline.
        phase = "simulate"
        """
        ...

    # Getters and Setters for Attributes

    @property
    def kdist_target(self) -> str:
        return self._kdist_target

    @kdist_target.setter
    def kdist_target(self, kdist_target: str) -> None:
        self._kdist_target = kdist_target
        self._krun = KRun(definition_dir=self.definition_dir)

    @property
    def definition_dir(self) -> str:
        return kdist.get(self.kdist_target)
