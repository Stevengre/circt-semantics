from __future__ import annotations

import logging
from argparse import ArgumentParser
from typing import TYPE_CHECKING, Any, Final

from .utils import file_path

if TYPE_CHECKING:
    from argparse import Namespace

_LOGGER: Final = logging.getLogger(__name__)
_LOG_FORMAT: Final = '%(levelname)s %(asctime)s %(name)s - %(message)s'


def create_arg_parser() -> ArgumentParser:
    """Create argument parser for kcirct."""

    # Shared arguments for all commands
    shared_args = ArgumentParser(add_help=False)
    shared_args.add_argument('--verbose', '-v', default=False, action='store_true', help='Enable verbose output')
    shared_args.add_argument('--debug', '-d', default=False, action='store_true', help='Enable debug output')

    # Top-level parser
    parser = ArgumentParser(prog='kcirct', description='K-CIRCT command line tool')
    command_parser = parser.add_subparsers(dest='command', required=True, help='Command to run')

    # Generate Python Module for Kimulator
    generate_parser = command_parser.add_parser(
        'generate', help='Generate a Python module for Kimulator', parents=[shared_args]
    )
    generate_parser.add_argument(
        'input',
        type=file_path,
        help='Input Generic MLIR file. You can use `circt-opt --mlir-print-op-generic` to get one.',
    )
    generate_parser.add_argument(
        '--output',
        dest='output',
        type=str,
        default='none',
        help='Output file name. If not specified, output to stdout.',
        required=False,
    )
    return parser


def exec_generate(input: str, output: str = 'none', **kwargs: Any) -> None: ...


def _loglevel(args: Namespace) -> int:
    if args.debug:
        return logging.DEBUG

    if args.verbose:
        return logging.INFO

    return logging.WARNING


def main() -> None:
    parser = create_arg_parser()
    args = parser.parse_args()
    logging.basicConfig(level=_loglevel(args), format=_LOG_FORMAT)

    executor_name = 'exec_' + args.command.lower().replace('-', '_')
    if executor_name not in globals():
        raise AssertionError(f'Unimplemented command: {args.command}')

    execute = globals()[executor_name]
    execute(**vars(args))


if __name__ == '__main__':
    main()
