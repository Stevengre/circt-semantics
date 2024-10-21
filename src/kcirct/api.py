"""Python Interface for the CIRCT Semantics.

It does not include:
2. `kimulator` and its subcommands.
"""

from __future__ import annotations

import resource
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

from pyk.kore.parser import KoreParser
from pyk.kore.prelude import DV, SORT_K_ITEM, App, SortApp, dv, inj, kseq, top_cell_initializer
from pyk.ktool.kprint import KPrint

from kcirct.kdist.circt_semantics.main import cell_symbol, cmd, phase_symbol

if TYPE_CHECKING:
    pass

    from pyk.kore.syntax import Pattern


API_DIR = Path(__file__).parent
WORKING_DIR = API_DIR / 'workingdir'
DATA_DIR = API_DIR / 'tmp'
SEMANTICS_PATH = API_DIR / 'kdist' / 'circt_semantics' / 'circt-core.k'
PARSER_DIR = WORKING_DIR / 'parsers'
TOP_LEVEL_PARSER = PARSER_DIR / 'parser_TopLevel_MAIN-SYNTAX'
KOMPILE_DIR = WORKING_DIR / 'kompiled'
OPT_KOMPILE_DIR = WORKING_DIR / 'opt-kompiled'

sys.setrecursionlimit(2000000000)

soft, hard = resource.getrlimit(resource.RLIMIT_STACK)
resource.setrlimit(resource.RLIMIT_STACK, (128 * 1024 * 1024, hard))

class KCIRCT:
    working_dir: Path
    data_dir: Path
    definition_dir: Path
    _kprint: KPrint | None
    _use_opt: bool
    # TODO: 在语义确定没问题之后，将左右的Kore Parser和top_down从pipeline中删除

    def __init__(self, use_opt: bool = False) -> None:
        print('Initializing KCIRCT...')
        self.working_dir = WORKING_DIR
        print(f'Working directory: {self.working_dir}')
        self.working_dir.mkdir(parents=True, exist_ok=True)

        self.data_dir = DATA_DIR
        print(f'Data directory: {self.data_dir}')
        self.data_dir.mkdir(parents=True, exist_ok=True)
        print(f'Parser directory: {PARSER_DIR}')
        PARSER_DIR.mkdir(parents=True, exist_ok=True)
        self._use_opt = use_opt
        self.definition_dir = OPT_KOMPILE_DIR if use_opt else KOMPILE_DIR
        self._kprint = KPrint(definition_dir=self.definition_dir)

    def ensure_env(self):
        if self.definition_dir.exists():
            print('Kompiled directory exists.')
            print('If you want to re-kompile, please delete the existing directory.')
            print(f'Kompiled directory: {self.definition_dir}')
        else:
            print('Kompiling...')
            KCIRCT.kompile(use_opt=self._use_opt)
            print(f'Kompiled: {self.definition_dir}')

        if not TOP_LEVEL_PARSER.exists():
            print('Generating TopLevelParser...')
            self.generate_parser(sort='TopLevel', parser=TOP_LEVEL_PARSER)
            print(f'Generated: {TOP_LEVEL_PARSER}')
        else:
            print(f'TopLevelParser exists: {TOP_LEVEL_PARSER}')
            print('If you want to re-generate, please delete the existing file.')

    @dataclass
    class Result:
        stdout: str
        execution_time: float

    @staticmethod
    def run(command: list[str]) -> KCIRCT.Result:
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(f'Running command: {" ".join(command)}')
        start_time = time.time()
        stdout, stderr = process.communicate()
        end_time = time.time()
        time_cost = end_time - start_time
        if process.returncode != 0:
            print(f'Execution time: {time_cost} seconds')
            raise RuntimeError(stderr.decode('utf-8'))
        # print(f'Command succeeded: {stdout.decode('utf-8')}')
        print(f'Execution time: {time_cost} seconds')
        return KCIRCT.Result(stdout.decode('utf-8'), time_cost)

    @staticmethod
    def kompile(use_opt: bool = False) -> None:
        if use_opt:
            KCIRCT.run(['kompile', str(SEMANTICS_PATH), '-o', str(OPT_KOMPILE_DIR), '-O3', '-ccopt', '-g'])
        else:
            KCIRCT.run(['kompile', str(SEMANTICS_PATH), '-o', str(KOMPILE_DIR)])
        return
    
    @staticmethod
    def kompile_manual(k_file: Path, output_file: Path, command: list[str]) -> None:
        KCIRCT.run(
            [
                'kompile',
                str(k_file),
                *command,
                '-o',
                str(output_file),
            ]
        )
    
    def set_definition_dir(self, definition_dir: Path) -> None:
        self.definition_dir = definition_dir
    
    def krun_manual(self, input_file: Path, command: list[str]) -> None:
        KCIRCT.run(
            [
                'krun',
                str(input_file),
                '--definition',
                str(self.definition_dir),
                *command,
            ]
        )
    def generate_parser(self, sort: str, parser: Path) -> None:
        KCIRCT.run(
            [
                'kast',
                str(parser),
                '--gen-parser',
                '--bison-stack-max-depth',
                '1000000000',
                '--sort',
                sort,
                '--definition',
                str(self.definition_dir),
            ]
        )
        return

    def compile_expression(self, expression: str, sort: str) -> Pattern:
        """Translate a string expression in the CIRCT semantics to Kore."""
        parser_path = PARSER_DIR / (sort + 'Parser')
        if not parser_path.exists():
            self.generate_parser(sort=sort, parser=parser_path)

        expression_file = self.data_dir / f"expression.{sort}.kore"
        with open(expression_file, 'w') as file:
            file.write(expression)
        result = KCIRCT.run([str(parser_path), str(expression_file)])
        expression_file.unlink()
        return KoreParser(result.stdout).pattern()

    def krun_cmd(self, input_file: Path, depth: int | None = None) -> list[str]:
        """Generate the krun command."""
        cmd = [
            'krun',
            str(input_file),
            '--definition',
            str(self.definition_dir),
            '--output',
            'kore',
            '--parser',
            'cat',
            '--term',
            '--no-expand-macros',
        ]
        if depth:
            cmd += ['--depth', str(depth)]
        return cmd

    @staticmethod
    def read_kore(file: Path) -> Pattern:
        """Parse Kore from a file."""
        with open(file, 'r') as f:
            # print(f.read())
            return KoreParser(f.read()).pattern()

    def compile_fast(self, file: Path, output_file: Path) -> None:
        result = KCIRCT.run([str(TOP_LEVEL_PARSER), str(file)])
        with open(output_file, 'w') as f:
            f.write(result.stdout)

    def compile(self, file: Path, output_file: Path | None = None) -> Pattern:
        """Step 1: Translate Generic MLIR to Kore."""
        result = KCIRCT.run([str(TOP_LEVEL_PARSER), str(file)])
        if output_file is not None:
            with open(output_file, 'w') as f:
                f.write(result.stdout)
        # TODO: KoreParser 太太太太慢了，而且是递归的
        return KoreParser(result.stdout).pattern()

    def _init_state_pattern(self, complied_pattern: Pattern, top_module: str, inputs: list[tuple[int, int]]) -> Pattern:
        return top_cell_initializer(
            {
                '$PGM': inj(SortApp('SortTopLevel'), SORT_K_ITEM, complied_pattern),
                '$Entry': inj(SortApp('SortString'), SORT_K_ITEM, dv(top_module)),
                '$Input': inj(SortApp('SortList'), SORT_K_ITEM, self.kore_input(inputs)),
            }
        )

    def init_state(
        self, compiled_pgm: Path, initial_state: Path, top_module: str, inputs: list[tuple[int, int]]
    ) -> None:
        """Step 2: Initialize the state with the initial state."""
        complied_pattern = KCIRCT.read_kore(compiled_pgm)
        state_initializer = self._init_state_pattern(complied_pattern, top_module, inputs)
        state_initializer_path = compiled_pgm.parent / f"{compiled_pgm.name}.init.kore"
        with open(state_initializer_path, 'w') as file:
            state_initializer.write(file)
        self.krun_fast(input_file=state_initializer_path, output_file=initial_state, depth=1)

    def krun_fast(self, input_file: Path, output_file: Path, depth: int | None = None) -> None:
        """Step 3: Run state with an optional depth."""
        result = KCIRCT.run(self.krun_cmd(input_file, depth=depth))
        with open(output_file, 'w') as f:
            f.write(result.stdout)
        return

    def krun(self, pattern: Pattern, depth: int | None = None, check: bool = True) -> Pattern:
        """Run the CIRCT Semantics pipeline on Kore."""

        # write pattern to file
        current_time = time.strftime("%Y%m%d%H%M%S")
        input_path = self.data_dir / f"tmp{current_time}.{depth}.source.kore"
        input_path.parent.mkdir(parents=True, exist_ok=True)
        with open(input_path, 'w') as file:
            pattern.write(file)

        # run krun
        output_path = self.data_dir / f"tmp{current_time}.{depth}.target.kore"
        self.krun_fast(input_file=input_path, output_file=output_path, depth=depth)

        return KCIRCT.read_kore(output_path)

    def pretty(self, state: Pattern) -> str:
        """Pretty print Kore."""
        assert self._kprint is not None, 'KPrint is not initialized'
        return self._kprint.kore_to_pretty(state)

    def write_pretty(self, kore_path: Path, pretty_path: Path) -> None:
        """Write the pretty print of Kore to a file."""
        kore = KCIRCT.read_kore(kore_path)
        with open(pretty_path, 'w') as file:
            file.write(self.pretty(kore))
        # wrong command
        # KCIRCT.run(
        #     [
        #         'kast',
        #         str(kore_path),
        #         '-i',
        #         'kore',
        #         '-o',
        #         'program',
        #         '-d',
        #         str(self.definition_dir),
        #         '--output-file',
        #         str(pretty_path),
        #     ]
        # )
        return

    def run_first_simulate(self, pgm: Pattern, top_module: str, inputs: list[tuple[int, int]]) -> Pattern:
        """Run the first simulate step on Kore.

        This is a batch step of the preprocess, setup, and initialize steps.
        """
        # TODO: Before performance evaluation, we need to use bits_list to avoid parse, or just generate a bison parser for List

        return self.krun(self._init_state_pattern(pgm, top_module, inputs))

    def run_simulate(self, state: Pattern, inputs: list[tuple[int, int]]) -> Pattern:
        """Run the simulate step on Kore.

        This is the fourth step in the CIRCT Semantics pipeline.
        phase = "simulate"
        """

        def _rewrite(pattern: Pattern) -> Pattern:
            if isinstance(pattern, App) and pattern.symbol == cell_symbol('cmd'):
                return pattern.let_patterns([kseq([cmd('always')])])
            if isinstance(pattern, App) and pattern.symbol == cell_symbol('input'):
                return pattern.let_patterns([self.kore_input(inputs)])
            return pattern

        return self.krun(state.top_down(_rewrite))

    def read_ports(self, state: Pattern) -> dict[str, tuple[int, int]]:
        """Read the outputs from the Kore pattern."""
        # cid.port_name -> (port_value, port_size)
        ports: dict[str, tuple[int, int]] = {}
        matched_ckts: list[dict[str, Pattern]] = []

        def _find_ckt(pattern: Pattern) -> Pattern:

            if isinstance(pattern, App) and pattern.symbol == cell_symbol('ckt'):
                ps: dict[str, Pattern] = {}

                def _find_ckt_cid(pattern: Pattern) -> Pattern:
                    if isinstance(pattern, App) and pattern.symbol == cell_symbol('cid'):
                        ps['cid'] = pattern
                        return pattern
                    return pattern

                def _find_in_ports(pattern: Pattern) -> Pattern:
                    if isinstance(pattern, App) and pattern.symbol == cell_symbol('in-ports'):
                        ps['in-ports'] = pattern
                        return pattern
                    return pattern

                def _find_out_names(pattern: Pattern) -> Pattern:
                    if isinstance(pattern, App) and pattern.symbol == cell_symbol('out-names'):
                        ps['out-names'] = pattern
                        return pattern
                    return pattern

                def _find_out_ports(pattern: Pattern) -> Pattern:
                    if isinstance(pattern, App) and pattern.symbol == cell_symbol('out-ports'):
                        ps['out-ports'] = pattern
                        return pattern
                    return pattern

                pattern.top_down(_find_ckt_cid).top_down(_find_in_ports).top_down(_find_out_names).top_down(
                    _find_out_ports
                )
                matched_ckts.append(ps)
                return pattern
            return pattern

        # find all ckt patterns
        state.top_down(_find_ckt)

        # desugar
        names: list[str] = []
        values_sizes: list[int] = []

        def _find_names(pattern: Pattern) -> Pattern:
            if isinstance(pattern, DV) and pattern.sort == SortApp('SortBareId'):
                names.append(str(pattern.value.value))
            return pattern

        def _find_values(pattern: Pattern) -> Pattern:
            if isinstance(pattern, DV) and pattern.sort == SortApp('SortInt'):
                values_sizes.append(int(pattern.value.value))
            return pattern

        for ckt in matched_ckts:
            cid = ckt['cid'].args[0].value.value

            ckt['in-ports'].top_down(_find_names).top_down(_find_values)
            while names:
                name = names.pop(0)
                value = values_sizes.pop(0)
                ports[f'{cid}/{name}'] = (value, values_sizes.pop(0))
            ckt['out-ports'].top_down(_find_values)
            ckt['out-names'].top_down(_find_names)
            while names:
                name = names.pop(0)
                value = values_sizes.pop(0)
                ports[f'{cid}/{name}'] = (value, values_sizes.pop(0))

        return ports

    def run_preprocess_fast(self, pgm: Path, output_file: Path) -> None:
        """Run the preprocess step on Kore.

        This is the first step in the CIRCT Semantics pipeline.
        Use the MLIR static semantics in `circt-semantics/mlir`.
        phase = "preprocess" | "canonicalized"
        """

        def _print_correct_pattern(_pgm: Path, _output_file: Path) -> None:
            """When failed, print the correct pattern to the output file. Then update the template."""
            with open(_output_file, 'w') as file:
                pgm_pattern = KCIRCT.read_kore(_pgm)
                init_pattern = top_cell_initializer({'$PGM': inj(SortApp('SortTopLevel'), SORT_K_ITEM, pgm_pattern)})
                init_pattern.write(file)

        _print_correct_pattern(pgm, output_file)

        template = """LblinitGeneratedTopCell{}(\left-assoc{}(Lbl'Unds'Map'Unds'{}(Lbl'UndsPipe'-'-GT-Unds'{}(inj{SortKConfigVar{}, SortKItem{}}(\dv{SortKConfigVar{}}("$PGM")), inj{SortTopLevel{}, SortKItem{}}({pgm})))))"""
        temp_file = output_file.parent / (output_file.name + '.prestate')
        with open(pgm, 'r') as file:
            pgm_pattern = file.read()
            init_pattern = template.replace('{pgm}', pgm_pattern)
            with open(temp_file, 'w') as file:
                file.write(init_pattern)
        self.krun_fast(input_file=temp_file, output_file=output_file)
        return

    def _kore_replace(self, input_file: Path, match_str: str, replace_str: str) -> str:
        """Replace the match string with the replace string in the input file."""
        with open(input_file, 'r') as file:
            input_str = file.read()
        if match_str in input_str:
            return input_str.replace(match_str, replace_str, 1)
        else:
            raise ValueError(
                f"Input file: {input_file} does not finished preprocess. \n\
                        Please check the pretty print of the input file: {input_file.parent / (input_file.name + '.pretty')}"
            )

    def _kore_str_replace(self, input_str: str, match_str: str, replace_str: str) -> str:
        """Replace the match string with the replace string in the input string."""
        if match_str in input_str:
            return input_str.replace(match_str, replace_str, 1)
        else:
            raise ValueError(
                f"Input string does not finished preprocess. \n\
                        Please check the pretty print of the input string."
            )

    def run_setup_fast(self, input_file: Path, output_file: Path, top_module: str) -> None:
        """Run the setup step on Kore.

        This is the second step in the CIRCT Semantics pipeline.
        phase = "toStimulate" | "build"
        """

        match = """(kseq{}(inj{SortPhaseControl{}, SortKItem{}}(Lbl'Hash'phaseStop'Unds'MLIR-CONF'Unds'PhaseControl{}()),kseq{}(inj{SortPhaseControl{}, SortKItem{}}(Lbl'Hash'toStimulate'Unds'MLIR-CONF'Unds'PhaseControl{}()),dotk{}())))"""
        rewrite = """(kseq{}(inj{SortPhaseControl{}, SortKItem{}}(Lbl'Hash'toStimulate'Unds'MLIR-CONF'Unds'PhaseControl{}()),dotk{}()))"""

        match_entry = """Lbl'-LT-'entry'-GT-'{}(\dv{SortString{}}("")"""
        rewrite_entry = """Lbl'-LT-'entry'-GT-'{}(\dv{SortString{}}("{top_module}")"""
        rewrite_entry = rewrite_entry.replace("{top_module}", top_module)

        rewritten_file = output_file.parent / (output_file.name + '.prestate')
        rewritten_pattern = self._kore_replace(input_file, match, rewrite)
        rewritten_pattern = self._kore_str_replace(rewritten_pattern, match_entry, rewrite_entry)
        with open(rewritten_file, 'w') as file:
            file.write(rewritten_pattern)
        self.krun_fast(input_file=rewritten_file, output_file=output_file)
        return

    def run_initialize_fast(self, input_file: Path, output_file: Path) -> None:
        """Run the initialize step on Kore.

        This is the third step in the CIRCT Semantics pipeline.
        phase = "initialize"
        """
        match_1 = """Lbl'-LT-'cmd'-GT-'{}(kseq{}(inj{SortCmdCIRCT{}, SortKItem{}}(Lbl'Hash'end'Unds'COMMON-SYNTAX'Unds'CmdCIRCT{}()),"""
        rewrite_1 = """Lbl'-LT-'cmd'-GT-'{}("""
        match_2 = """,dotk{}())))),Lbl'-LT-'entry'-GT-'"""
        rewrite_2 = """,dotk{}()))),Lbl'-LT-'entry'-GT-'"""

        rewritten_file = output_file.parent / (output_file.name + '.prestate')
        rewritten_pattern = self._kore_replace(input_file, match_1, rewrite_1)
        rewritten_pattern = self._kore_str_replace(rewritten_pattern, match_2, rewrite_2)
        with open(rewritten_file, 'w') as file:
            file.write(rewritten_pattern)
        self.krun_fast(input_file=rewritten_file, output_file=output_file)
        return

    def _rewrite_cell(self, input_str: str, start_cell: str, end_cell: str, rewrite_str: str) -> str:
        """Rewrite the cell in the input string."""
        # 定义要删除的标签
        start_label = f"Lbl'-LT-'{start_cell}'-GT-'"
        end_label = f"Lbl'-LT-'{end_cell}'-GT-'"

        # 找到开始和结束标签的位置
        start_index = input_str.find(start_label)
        end_index = input_str.find(end_label)

        # 检查标签是否存在
        if start_index != -1 and end_index != -1:
            # 计算结束标签的结束位置
            end_index += len(end_label)

            # 构建新的字符串
            modified_string = (
                input_str[: start_index + len(start_label)]  # 保留开始标签
                + rewrite_str  # 插入新的字符串
                + input_str[end_index - len(end_label) :]  # 保留结束标签后的内容
            )
            return modified_string
        else:
            return input_str  # 如果标签不存在，返回原始字符串

    def run_simulate_fast(self, input_file: Path, output_file: Path, inputs: list[tuple[int, int]], depth: int | None = None) -> None:
        """Run the simulate step on Kore.

        This is the fourth step in the CIRCT Semantics pipeline.
        phase = "simulate"
        """

        rewrite = """{}(kseq{}(inj{SortCmdCIRCT{}, SortKItem{}}(Lbl'Hash'always'Unds'COMMON-SYNTAX'Unds'CmdCIRCT{}()),dotk{}())),"""

        with open(input_file, 'r') as file:
            input_str = file.read()
        rewritten_pattern = self._rewrite_cell(input_str, 'cmd', 'entry', rewrite)

        input_pattern = self.kore_input(inputs)
        input_pattern_file = output_file.parent / (output_file.name + '.input_pattern')
        with open(input_pattern_file, 'w') as file:
            input_pattern.write(file)
        with open(input_pattern_file, 'r') as file:
            input_pattern_str = file.read()

        rewritten_pattern = self._rewrite_cell(rewritten_pattern, 'input', 'clock', "{}(" + input_pattern_str + "),")
        rewritten_file = output_file.parent / (output_file.name + '.prestate')
        with open(rewritten_file, 'w') as file:
            file.write(rewritten_pattern)

        self.krun_fast(input_file=rewritten_file, output_file=output_file, depth=depth)
        return

    # -------------------------------------------------------------------------------------------------
    # Backup APIs
    # -------------------------------------------------------------------------------------------------

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

    def kore_input(self, inputs: list[tuple[int, int]]) -> Pattern:
        def _bits_list(inputs: list[tuple[int, int]]) -> Pattern:
            res = ''
            for input in inputs:
                res += f'ListItem(bits({input[0]}, {input[1]}) : i{input[1]}) '
            return res

        return self.compile_expression(expression=f'ListItem({_bits_list(inputs)})', sort='List')

    # APIs for VCD

    # def generate_vcd_vars(self, ports: dict[str, list[tuple[int, int]]]) -> dict[str, tuple[str, int]]:
    #     """Generate VCD variables from the port list."""
    #     res: dict[str, tuple[str, int]] = {}
    #     # name -> (value, size)
    #     # translate to
    #     # name -> (abbrev, size)
    #     for name, info in ports.items():
    #         res[name] = (Abbrev.gen(), info[1])
    #     return res

    # Getters and Setters for Attributes

    # @property
    # def kdist_target(self) -> str:
    #     return self._kdist_target

    # @kdist_target.setter
    # def kdist_target(self, kdist_target: str) -> None:
    #     self._kdist_target = kdist_target
    #     self._krun = KRun(definition_dir=self.definition_dir)
    #     self._kprint = KPrint(definition_dir=self.definition_dir)

    # @property
    # def definition_dir(self) -> Path:
    #     return Path(kdist.get(self.kdist_target))
