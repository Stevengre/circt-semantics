"""Command Line Interface for KCIRCT.

It includes:
1. `kcirct`
2. `kdist`
3. `kimulator` and its subcommands.
"""

from __future__ import annotations

import logging
from argparse import ArgumentParser
from pathlib import Path
from typing import TYPE_CHECKING, Any, Final

from .api import KCIRCT
from .utils import file_path

if TYPE_CHECKING:
    from argparse import Namespace

_LOGGER: Final = logging.getLogger(__name__)
_LOG_FORMAT: Final = '%(levelname)s %(asctime)s %(name)s - %(message)s'


def _add_shared_args(shared_args: ArgumentParser) -> None:
    shared_args.add_argument('--verbose', '-v', default=False, action='store_true', help='Enable verbose output')
    shared_args.add_argument('--debug', '-d', default=False, action='store_true', help='Enable debug output')


def _add_simulate_args(parser: ArgumentParser) -> None:
    parser.add_argument('input', nargs='?', type=Path, help='待仿真的 Generic MLIR 文件')
    parser.add_argument('--describe', action='store_true', help='以 JSON 输出当前安装、源码和 K 工具链身份后退出')
    parser.add_argument('--top-module', help='顶层 hw.module 名称')
    parser.add_argument('--inputs', type=Path, help='按名称指定全部输入的 JSON 事件文件')
    parser.add_argument('--output', type=Path, help='输出 VCD 文件，拒绝覆盖已有文件')
    parser.add_argument('--work-dir', type=Path, help='新的工作目录，用于保存结果、命令和失败证据')
    parser.add_argument('--evaluations-per-input', type=int, default=2, help='每个输入事件的连续求值次数，默认 2')
    parser.add_argument('--definition-dir', type=Path, help='已编译的 LLVM 定义目录，默认使用 kdist target')
    parser.add_argument('--parser', type=Path, help='可复用的 TopLevel parser，默认在工作目录生成')
    parser.add_argument('--timeout', type=float, default=120, help='每次外部命令的超时秒数，默认 120')
    parser.add_argument('--keep-states', action='store_true', help='用 gzip 保存每一次求值的 Kore 状态及索引')


def _add_verify_args(verify_parser: ArgumentParser) -> None:
    verify_parser.add_argument(
        'input',
        type=file_path,
        help='Input Generic MLIR file or verification artifact.',
    )
    verify_parser.add_argument(
        '--top-module',
        dest='top_module',
        type=str,
        default='main',
        help='Top module or entry symbol used by the verification workflow.',
    )
    verify_parser.add_argument(
        '--entry-point',
        dest='entry_point',
        type=str,
        default=None,
        help='Optional named entry point for validation or proof tasks.',
    )
    verify_parser.add_argument('--proof-dir', metavar='DIR', help='Proof directory')
    verify_parser.add_argument('--haskell-target', metavar='TARGET', help='Haskell target to use')
    verify_parser.add_argument('--llvm-lib-target', metavar='TARGET', help='LLVM lib target to use')
    verify_parser.add_argument('--llvm-target', metavar='TARGET', help='LLVM target to use')
    verify_parser.add_argument('--bug-report', metavar='PATH', help='Path to optional bug report')
    verify_parser.add_argument(
        '--backend',
        dest='backend',
        choices=('haskell', 'llvm'),
        default='haskell',
        help='Backend label kept for compatibility with future verification workflows.',
    )
    verify_parser.add_argument(
        '--max-depth',
        metavar='DEPTH',
        type=int,
        help='Maximum K rewrite steps to take on a single KCFG edge before creating a new node',
    )
    verify_parser.add_argument(
        '--depth',
        dest='depth',
        type=int,
        default=None,
        help='Compatibility depth argument reserved for future verification execution.',
    )
    verify_parser.add_argument(
        '--max-iterations', metavar='ITERATIONS', type=int, help='Max number of proof iterations to take'
    )
    verify_parser.add_argument(
        '--reload', action='store_true', help='Discard any existing proof progress and restart from scratch'
    )
    verify_parser.add_argument(
        '--fail-fast',
        dest='fail_fast',
        action='store_true',
        help='Halt execution early if the proof is failing',
    )
    verify_parser.add_argument(
        '--maintenance-rate',
        dest='maintenance_rate',
        type=int,
        default=1,
        metavar='RATE',
        help='Number of iterations between proof maintenance writing to disk. Default: 1',
    )
    verify_parser.add_argument(
        '--break-on-calls',
        dest='break_on_calls',
        action='store_true',
        help='Break on all function and intrinsic calls',
    )
    verify_parser.add_argument(
        '--break-on-function-calls',
        dest='break_on_function_calls',
        action='store_true',
        help='Break on function calls not intrinsics',
    )
    verify_parser.add_argument(
        '--break-on-intrinsic-calls',
        dest='break_on_intrinsic_calls',
        action='store_true',
        help='Break on intrinsic calls not other functions',
    )
    verify_parser.add_argument(
        '--break-on-thunk', dest='break_on_thunk', action='store_true', help='Break on thunk evaluation'
    )
    verify_parser.add_argument(
        '--terminate-on-thunk',
        dest='terminate_on_thunk',
        action='store_true',
        help='Terminate proof when reaching a thunk',
    )
    verify_parser.add_argument(
        '--break-every-statement',
        dest='break_every_statement',
        action='store_true',
        help='Break on every statement execution',
    )
    verify_parser.add_argument(
        '--break-on-terminator-goto',
        dest='break_on_terminator_goto',
        action='store_true',
        help='Break on Goto terminator',
    )
    verify_parser.add_argument(
        '--break-on-terminator-switch-int',
        dest='break_on_terminator_switch_int',
        action='store_true',
        help='Break on SwitchInt terminator',
    )
    verify_parser.add_argument(
        '--break-on-terminator-return',
        dest='break_on_terminator_return',
        action='store_true',
        help='Break on Return terminator',
    )
    verify_parser.add_argument(
        '--break-on-terminator-call',
        dest='break_on_terminator_call',
        action='store_true',
        help='Break on Call terminator',
    )
    verify_parser.add_argument(
        '--break-on-terminator-assert',
        dest='break_on_terminator_assert',
        action='store_true',
        help='Break on Assert terminator',
    )
    verify_parser.add_argument(
        '--break-on-terminator-drop',
        dest='break_on_terminator_drop',
        action='store_true',
        help='Break on Drop terminator',
    )
    verify_parser.add_argument(
        '--break-on-terminator-unreachable',
        dest='break_on_terminator_unreachable',
        action='store_true',
        help='Break on Unreachable terminator',
    )
    verify_parser.add_argument(
        '--break-every-terminator',
        dest='break_every_terminator',
        action='store_true',
        help='Break on every terminator execution',
    )
    verify_parser.add_argument(
        '--break-every-step',
        dest='break_every_step',
        action='store_true',
        help='Break on every execution step',
    )
    verify_parser.add_argument(
        '--break-on-function',
        dest='break_on_function',
        action='append',
        default=None,
        help='Break when calling a function or intrinsic whose name contains this string repeatable',
    )
    verify_parser.add_argument(
        '--start-symbol',
        '--start-symbols',
        dest='start_symbols',
        type=str,
        metavar='SYMBOL',
        action='append',
        default=None,
        help='Symbol names to verify repeatable and comma-separated allowed',
    )
    verify_parser.add_argument(
        '--add-module',
        type=str,
        metavar='MODULE',
        help='K module to include. Formats: FILE.k:MODULE or FILE.md:MODULE or FILE.json.',
    )
    verify_parser.add_argument(
        '--max-workers', metavar='N', type=int, help='Maximum number of workers for parallel exploration'
    )
    verify_parser.add_argument(
        '--save-smir',
        action='store_true',
        help='Compatibility flag reserved for future intermediate artifact preservation.',
    )
    verify_parser.add_argument(
        '--smir',
        action='store_true',
        help='Compatibility flag reserved for future alternate verification inputs.',
    )
    verify_parser.add_argument(
        '--inputs',
        dest='input_steps',
        action='append',
        default=None,
        metavar='VALUES',
        help='Concrete input step as comma-separated value:width pairs, e.g. 1:8,2:8. Repeat for cycles.',
    )
    verify_parser.add_argument(
        '--work-dir',
        dest='work_dir',
        type=str,
        default=None,
        help='Directory for intermediate verification artifacts.',
    )
    verify_parser.add_argument(
        '--symbolic',
        dest='symbolic',
        action='store_true',
        help='Run APR/KCFG symbolic assertion proof instead of concrete trace checking.',
    )
    verify_parser.add_argument(
        '--symbolic-input-widths',
        dest='symbolic_input_widths',
        type=str,
        default=None,
        metavar='WIDTHS',
        help='Comma-separated input bit widths for symbolic proof, e.g. 8,8.',
    )
    verify_parser.add_argument(
        '--dump-debug-artifacts',
        dest='dump_debug_artifacts',
        action='store_true',
        help='Export readable debug artifacts for symbolic verification runs.',
    )
    verify_parser.add_argument(
        '--debug-artifact-dir',
        dest='debug_artifact_dir',
        type=str,
        default=None,
        metavar='DIR',
        help='Optional output directory for exported debug artifacts.',
    )
    verify_parser.add_argument(
        '--show-branch-constraints',
        dest='show_branch_constraints',
        action='store_true',
        help='Print proof branch nodes and per-branch added constraints for symbolic verification.',
    )


def create_arg_parser() -> ArgumentParser:
    """Create argument parser for kcirct."""

    shared_args = ArgumentParser(add_help=False)
    _add_shared_args(shared_args)

    parser = ArgumentParser(prog='kcirct', description='K-CIRCT command line tool')
    command_parser = parser.add_subparsers(dest='command', required=True, help='Command to run')

    generate_parser = command_parser.add_parser(
        'generate', help='Generate a Python module for Kimulator', parents=[shared_args]
    )
    generate_parser.add_argument(
        'input',
        type=file_path,
        help='Input Generic MLIR file. You can use circt-opt --mlir-print-op-generic to get one.',
    )
    generate_parser.add_argument(
        '--output',
        dest='output',
        type=str,
        default='none',
        help='Output file name. If not specified, output to stdout.',
        required=False,
    )

    simulate_parser = command_parser.add_parser('simulate', help='从 MLIR 和输入事件生成 VCD', parents=[shared_args])
    _add_simulate_args(simulate_parser)

    pretty_parser = command_parser.add_parser(
        'pretty', help='Convert a Kore file to readable K syntax', parents=[shared_args]
    )
    pretty_parser.add_argument(
        'input',
        type=file_path,
        help='Input Kore file.',
    )
    pretty_parser.add_argument(
        '--output',
        '-o',
        dest='output',
        type=Path,
        default=None,
        help='Output file. Defaults to INPUT.pretty.',
    )

    verify_parser = command_parser.add_parser(
        'verify',
        aliases=['validate'],
        help='Entry for verification workflows',
        parents=[shared_args],
    )
    _add_verify_args(verify_parser)

    return parser


def exec_generate(input: str, output: str = 'none', **kwargs: Any) -> None: ...


def exec_simulate(**kwargs: Any) -> None:
    import json

    from ._simulate import describe_simulator, simulate

    if kwargs.get('describe'):
        print(json.dumps(describe_simulator(), ensure_ascii=False, indent=2))
        return
    required = ('input', 'top_module', 'inputs', 'output', 'work_dir')
    missing = [name.replace('_', '-') for name in required if kwargs.get(name) is None]
    if missing:
        raise SystemExit(f'simulate 缺少必需参数：{", ".join(missing)}；用 --help 查看用法')
    try:
        result = simulate(
            Path(kwargs['input']),
            top_module=kwargs['top_module'],
            inputs_file=Path(kwargs['inputs']),
            output=Path(kwargs['output']),
            work_dir=Path(kwargs['work_dir']),
            evaluations_per_input=kwargs.get('evaluations_per_input', 2),
            definition_dir=kwargs.get('definition_dir'),
            parser=kwargs.get('parser'),
            timeout=kwargs.get('timeout', 120),
            keep_states=kwargs.get('keep_states', False),
        )
    except OSError as error:
        raise SystemExit(f'simulate 无法建立独立工作目录：{error}') from error
    print(json.dumps(result, ensure_ascii=False, indent=2))
    if result['status'] != 'pass':
        raise SystemExit(1)


def exec_pretty(input: str | Path, output: str | Path | None = None, **kwargs: Any) -> None:
    input_path = Path(input)
    output_path = Path(output) if output is not None else input_path.with_name(f'{input_path.name}.pretty')

    kcirct = KCIRCT()
    kcirct.write_pretty(input_path, output_path)
    print(output_path)


def _parse_input_steps(raw_steps: list[str] | None) -> list[list[tuple[int, int]]]:
    if raw_steps is None:
        return [[]]

    steps: list[list[tuple[int, int]]] = []
    for raw_step in raw_steps:
        step: list[tuple[int, int]] = []
        raw_step = raw_step.strip()
        if raw_step:
            for raw_item in raw_step.split(','):
                value, width = raw_item.split(':', 1)
                step.append((int(value, 0), int(width, 0)))
        steps.append(step)
    return steps


def _parse_symbolic_widths(raw_widths: str | None, input_steps: list[list[tuple[int, int]]]) -> list[int]:
    if raw_widths:
        return [int(width, 0) for width in raw_widths.split(',') if width.strip()]
    if input_steps and input_steps[0]:
        return [width for _value, width in input_steps[0]]
    raise ValueError('Symbolic proof needs --symbolic-input-widths, or --inputs with value:width pairs.')


def exec_verify(**kwargs: Any) -> None:
    input_file = Path(kwargs['input'])
    input_steps = _parse_input_steps(kwargs.get('input_steps'))
    work_dir = Path(kwargs['work_dir']) if kwargs.get('work_dir') else None
    kcirct = KCIRCT()

    if kwargs.get('symbolic'):
        symbolic_result = kcirct.prove_assertions(
            input_file,
            top_module=kwargs['top_module'],
            symbolic_widths=_parse_symbolic_widths(kwargs.get('symbolic_input_widths'), input_steps),
            proof_dir=Path(kwargs['proof_dir']) if kwargs.get('proof_dir') else None,
            work_dir=work_dir,
            haskell_target=Path(kwargs['haskell_target']) if kwargs.get('haskell_target') else None,
            llvm_lib_target=Path(kwargs['llvm_lib_target']) if kwargs.get('llvm_lib_target') else None,
            max_depth=kwargs.get('max_depth'),
            max_iterations=kwargs.get('max_iterations'),
            fail_fast=kwargs.get('fail_fast', False),
            maintenance_rate=kwargs.get('maintenance_rate', 1),
            reload=kwargs.get('reload', False),
        )

        print(f'input: {symbolic_result.input_file}')
        print(f'top-module: {symbolic_result.top_module}')
        print(f'work-dir: {symbolic_result.work_dir}')
        print(f'setup-state: {symbolic_result.setup_state}')
        print(f'symbolic-widths: {symbolic_result.symbolic_widths}')
        print(f'elapsed-seconds: {getattr(symbolic_result, "elapsed_seconds", 0.0):.3f}')
        print(f'proof-id: {symbolic_result.proof.id}')
        print(f'passed: {symbolic_result.proof.passed}')
        print(f'failed: {symbolic_result.proof.failed}')
        print(f'note: {symbolic_result.note}')
        if kwargs.get('show_branch_constraints'):
            print('branch-constraints:')
            print(kcirct.summarize_assertion_branches(symbolic_result), end='')
        if kwargs.get('dump_debug_artifacts'):
            debug_output_dir = Path(kwargs['debug_artifact_dir']) if kwargs.get('debug_artifact_dir') else None
            debug_artifacts = kcirct.dump_assertion_debug_artifacts(
                symbolic_result,
                output_dir=debug_output_dir,
                state_files=[symbolic_result.setup_state],
            )
            print(f'debug-artifacts: {debug_artifacts.output_dir}')

        if not symbolic_result.proof.passed:
            raise SystemExit(1)
        return

    concrete_result = kcirct.verify_assertions_fast(
        input_file,
        top_module=kwargs['top_module'],
        input_steps=input_steps,
        work_dir=work_dir,
        depth=kwargs.get('depth') or kwargs.get('max_depth'),
    )

    print(f'input: {concrete_result.input_file}')
    print(f'top-module: {concrete_result.top_module}')
    print(f'work-dir: {concrete_result.work_dir}')
    print(f'assertions-present: {concrete_result.checked_assertions}')
    print(f'elapsed-seconds: {getattr(concrete_result, "elapsed_seconds", 0.0):.3f}')
    print(f'passed: {concrete_result.passed}')
    if concrete_result.errors:
        print('assertion-errors:')
        for error in concrete_result.errors:
            print(f'  - {error}')
    print(f'note: {concrete_result.note}')

    if not concrete_result.passed:
        raise SystemExit(1)


def _loglevel(args: Namespace) -> int:
    if args.debug:
        return logging.DEBUG

    if args.verbose:
        return logging.INFO

    return logging.WARNING


def _normalize_command(command: str) -> str:
    normalized = command.lower().replace('-', '_')
    if normalized == 'validate':
        return 'verify'
    return normalized


def main() -> None:
    parser = create_arg_parser()
    args = parser.parse_args()
    logging.basicConfig(level=_loglevel(args), format=_LOG_FORMAT)

    command = _normalize_command(args.command)
    executor_name = 'exec_' + command
    if executor_name not in globals():
        raise AssertionError(f'Unimplemented command: {args.command}')

    execute = globals()[executor_name]
    execute(**vars(args))


if __name__ == '__main__':
    main()
