"""Python Interface for the CIRCT Semantics.

It does not include:
2. `kimulator` and its subcommands.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from pyk.kdist import kdist
from pyk.kore.parser import KoreParser
from pyk.kore.prelude import DV, SORT_K_ITEM, App, SortApp, dv, inj, kseq, top_cell_initializer
from pyk.ktool.kprint import KPrint, _kast
from pyk.ktool.krun import KRun
import time

import subprocess
from kcirct.kdist.circt_semantics.main import bits_list, cell_symbol, cmd, phase_symbol

if TYPE_CHECKING:
    pass

    from pyk.kore.syntax import Pattern


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

    # def build(self, _target_ids: Iterable[str] | None = None, verbose: bool = True, clean: bool = True) -> None:
    #     """Build the CIRCT Semantics."""
    #     if _target_ids is None:
    #         _target_ids = target_ids()
    #     kdist.build(target_ids=_target_ids, verbose=verbose, clean=clean)

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

    def run(self, pattern: Pattern, depth: int | None = None, check: bool = True) -> Pattern:
        """Run the CIRCT Semantics pipeline on Kore."""
        current_time = time.strftime("%Y%m%d%H%M%S")
        file_path = Path(__file__).parent / f"tmp/tmp{current_time}.kore"
        file_path.parent.mkdir(parents=True, exist_ok=True)
        with open(file_path, 'w') as file:
            pattern.write(file)

        command = [
            'krun',
            str(file_path),
            '--definition', str(self.definition_dir),
            '--output', 'kore',
            '--parser', 'cat',
            '--term',
            '--no-expand-macros'
        ]

        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()

        if process.returncode != 0:
            raise RuntimeError(stderr.decode('utf-8'))

        return KoreParser(stdout.decode('utf-8')).pattern()

    def run_preprocess(self, pgm: Pattern) -> Pattern:
        """Run the preprocess step on Kore.

        This is the first step in the CIRCT Semantics pipeline.
        Use the MLIR static semantics in `circt-semantics/mlir`.
        phase = "preprocess" | "canonicalized"
        """
        # TODO: this is wrong for current semantics
        return self.run(top_cell_initializer({'$PGM': inj(SortApp('SortTopLevel'), SORT_K_ITEM, pgm)}))

    def run_setup(self, state: Pattern, top_module: str) -> Pattern:
        """Run the hardware setup step on Kore.

        This is the second step in the CIRCT Semantics pipeline.
        Use the hardware setup in `circt-semantics/circt` and `circt-semantics/dialects`.
        phase = "toStimulate" | "build"
        """

        # x = self.compile_expression(expression="#toStimulate", sort="PhaseControl")
        def _rewrite(pattern: Pattern) -> Pattern:
            if isinstance(pattern, App) and pattern.symbol == cell_symbol('phase'):
                return pattern.let_patterns([App(phase_symbol('toStimulate'))])
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
                return pattern.let_patterns([kseq([cmd('bootstrap'), cmd('initial')])])
            return pattern

        return self.run(state.top_down(_rewrite))
    
    def kore_input(self,inputs: list[tuple[int, int]]) -> Pattern:
        def _bits_list(inputs: list[tuple[int, int]]) -> Pattern:
            res = ''
            for input in inputs:
                res += f'ListItem(bits({input[0]}, {input[1]}) : i{input[1]}) '
            return res
        
        return self.compile_expression(expression=f'ListItem({_bits_list(inputs)})', sort='List')
        
    def run_first_simulate(self, pgm: Pattern, top_module: str, inputs: list[tuple[int, int]]) -> Pattern:
        """Run the first simulate step on Kore.

        This is a batch step of the preprocess, setup, and initialize steps.
        """
        # TODO: Before performance evaluation, we need to use bits_list to avoid parse, or just generate a bison parser for List
        
        return self.run(top_cell_initializer({'$PGM': inj(SortApp('SortTopLevel'), SORT_K_ITEM, pgm), 
                                              '$Entry': inj(SortApp('SortString'), SORT_K_ITEM, dv(top_module)), 
                                              '$Input': inj(SortApp('SortList'), SORT_K_ITEM, self.kore_input(inputs))}))


    # def run_first_simulate(self, pgm: Path, top_module: str, inputs: list[tuple[int, int]]) -> Pattern:
    #     """Run the first simulate step on Kore.

    #     This is a batch step of the preprocess, setup, and initialize steps.
    #     """
    #     # TODO: we use this, because the semantics does not support stop between phases
    #     # self.compile_expression(expression="ListItem(bits(8, 8): i8) ListItem(bits(2, 8): i8) ", sort="List")
        
    #     def _bits_list(inputs: list[tuple[int, int]]) -> Pattern:
    #         res = ''
    #         for input in inputs:
    #             res += f'ListItem(bits({input[0]}, {input[1]}) : i{input[1]}) '
    #         return res
            
    #     cmd_list = ['krun', str(pgm), 
    #                 '--definition', str(self.definition_dir), 
    #                 '--output', 'kore', 
    #                 '--depth', '0',
    #                f'-cEntry="{top_module}"',
    #                f'-cInput={_bits_list(inputs)}']
    #     # print(' '.join(cmd_list))
    #     # print(proc_res.stderr.decode('utf-8'))
    #     proc_res = subprocess.run(cmd_list, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    #     if proc_res.returncode != 0:
    #         raise RuntimeError(proc_res.stderr.decode('utf-8'))
        
    #     return self.run(KoreParser(proc_res.stdout.decode('utf-8')).pattern())

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
                return pattern.let_patterns([kseq([cmd('initial'), cmd('always')])])
            if isinstance(pattern, App) and pattern.symbol == cell_symbol('input'):
                return pattern.let_patterns([self.kore_input(inputs)])
            return pattern

        return self.run(state.top_down(_rewrite))

    def pretty(self, state: Pattern) -> str:
        """Pretty print Kore."""
        assert self._kprint is not None, 'KPrint is not initialized'
        return self._kprint.kore_to_pretty(state)

    def read_ports(self, state: Pattern) -> dict[str, list[tuple[int, int]]]:
        """Read the outputs from the Kore pattern."""
        
        def _find_ckt(pattern: Pattern) -> Pattern:
            if isinstance(pattern, App) and pattern.symbol == cell_symbol('ckt'):
                
                return pattern
            return pattern
        
        
        output_patterns: list[Pattern] = []

        def _find_outputs(pattern: Pattern) -> Pattern:
            if isinstance(pattern, App) and pattern.symbol == cell_symbol('out-ports'):
                output_patterns.append(pattern)
            return pattern

        state.bottom_up(_find_outputs)

        int_patterns: list[DV] = []

        def _find_list_items(pattern: Pattern) -> Pattern:
            if isinstance(pattern, DV) and pattern.sort == SortApp('SortInt'):
                int_patterns.append(pattern)
            return pattern

        output_patterns[0].bottom_up(_find_list_items)
        ints = [int(p.value.value) for p in int_patterns]
        outputs = []
        for i in range(0, len(ints), 2):
            outputs.append((ints[i], ints[i + 1]))

        return outputs

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
    def definition_dir(self) -> Path:
        return Path(kdist.get(self.kdist_target))
