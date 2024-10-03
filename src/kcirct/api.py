"""Python Interface for the CIRCT Semantics.

It does not include:
2. `kimulator` and its subcommands.
"""

from __future__ import annotations

from pathlib import Path
import time
from typing import Iterable

from pyk.kast.inner import *
from pyk.kdist import kdist, target_ids
from pyk.konvert import *
from pyk.kore.parser import KoreParser
from pyk.kore.prelude import *
from pyk.kore.syntax import *
from pyk.kore.syntax import Pattern
from pyk.ktool.kprint import KPrint, _kast
from pyk.ktool.krun import KRun

from kcirct.kdist.circt_semantics.state import KCIRCTState
from kcirct.kdist.circt_semantics.main import *

class KCIRCT:
    # Tools
    _krun: KRun | None
    _kprint: KPrint | None
    # Attributes
    _kdist_target: str

    def __init__(self, kdist_target: str = 'circt-semantics.llvm') -> None:
        self._kdist_target = kdist_target
        self._krun = KRun(definition_dir=self.definition_dir)
        self._kprint = KPrint(definition_dir=self.definition_dir)

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

    def compile_expression(self, expression: str, sort: str) -> Pattern:
        """Translate a string expression in the CIRCT semantics to Kore."""
        result = _kast(
            # file=self.definition_dir / (sort + 'parser'),
            definition_dir=self.definition_dir,
            input='program',
            output='kore',
            expression=expression,
            sort=sort,
            # gen_glr_parser=True,
        )
        if result.returncode != 0:
            raise RuntimeError(result.stderr)
        return KoreParser(result.stdout).pattern()

    def run(self, pattern: Pattern, depth: int | None = None, check: bool = False) -> Pattern:
        """Run the CIRCT Semantics pipeline on Kore."""
        return self._krun.run_pattern(pattern, depth=depth, check=check)

    def run_preprocess(self, pgm: Pattern) -> Pattern:
        """Run the preprocess step on Kore.

        This is the first step in the CIRCT Semantics pipeline.
        Use the MLIR static semantics in `circt-semantics/mlir`.
        phase = "preprocess" | "canonicalized"
        """
        return self.run(KCIRCTState.initialize(pgm))

    def run_setup(self, state: Pattern, top_module: str) -> Pattern:
        """Run the hardware setup step on Kore.

        This is the second step in the CIRCT Semantics pipeline.
        Use the hardware setup in `circt-semantics/circt` and `circt-semantics/dialects`.
        phase = "toStimulate" | "build"
        """
        # x = self.compile_expression(expression="#toStimulate", sort="PhaseControl")
        def _rewrite(pattern: Pattern) -> Pattern:
            if isinstance(pattern, App) and pattern.symbol == cell_symbol('phase'):
                return pattern.let_patterns([App(phase_symbol("toStimulate"))])
            if isinstance(pattern, App) and pattern.symbol == cell_symbol('entry'):
                return pattern.let_patterns([dv(top_module)])
            return pattern
        # res = self.run(state.top_down(_rewrite), depth=28, check=True)
        # rewritten = state.top_down(_rewrite)
        # res = self.run(rewritten)
        # print(self.pretty(res))
        return self.run(state.top_down(_rewrite))

    def run_initialize(self, state: Pattern) -> Pattern:
        """Run the initialize step on Kore.

        This is the third step in the CIRCT Semantics pipeline.
        phase = "initialize"
        """
        def _rewrite(pattern: Pattern) -> Pattern:
            if isinstance(pattern, App) and pattern.symbol == cell_symbol('cmd'):
                return pattern.let_patterns([kseq([cmd("bootstrap"), cmd("initial")])])
            return pattern
        return self.run(state.top_down(_rewrite))

    def run_simulate(self, state: Pattern, inputs: list[tuple[int, int]]) -> Pattern:
        """Run the simulate step on Kore.

        This is the fourth step in the CIRCT Semantics pipeline.
        phase = "simulate"
        """
        # count time cost
        # time_start = time.time()
        # term = ''
        # for input in inputs:
        #     term += f'ListItem(bits({input[0]}, {input[1]}) : i{input[1]}) '
        # term = self.compile_expression(expression=term, sort='List')
        # time_compile = time.time()
        # compile_time = time_compile - time_start
        # print(f'compile time: {compile_time}')
        # x = bits_list(inputs)
        # time_list = time.time()
        # list_time = time_list - time_compile
        # print(f'list pattern time: {list_time}')
        # print(f'compare time: {list_time - compile_time}')
        def _rewrite(pattern: Pattern) -> Pattern:
            if isinstance(pattern, App) and pattern.symbol == cell_symbol('cmd'):
                return pattern.let_patterns([kseq([cmd("initial"), cmd("always")])])
            if isinstance(pattern, App) and pattern.symbol == cell_symbol('input'):
                return pattern.let_patterns([bits_list(inputs)])
            return pattern
        return self.run(state.top_down(_rewrite))

    def pretty(self, state: Pattern) -> str:
        """Pretty print Kore."""
        return self._kprint.kore_to_pretty(state)
    
    def read_outputs(self, state: Pattern) -> dict[str, Mapping[str, int]]:
        """Read the outputs from the Kore pattern."""
        ...

    # Getters and Setters for Attributes

    @property
    def kdist_target(self) -> str:
        return self._kdist_target

    @kdist_target.setter
    def kdist_target(self, kdist_target: str) -> None:
        self._kdist_target = kdist_target
        self._krun = KRun(definition_dir=self.definition_dir)
        self._kprint = KPrint(definition_dir=self.definition_dir)

    @property
    def definition_dir(self) -> str:
        return kdist.get(self.kdist_target)
