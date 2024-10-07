from __future__ import annotations

import shutil
from pathlib import Path
from typing import TYPE_CHECKING

from pyk.kbuild.utils import k_version
from pyk.kdist.api import Target
from pyk.ktool.kompile import PykBackend, kompile

if TYPE_CHECKING:
    from collections.abc import Callable, Mapping
    from typing import Any, Final


class SourceTarget(Target):
    SRC_DIR: Final = Path(__file__).parent

    def build(self, output_dir: Path, deps: dict[str, Path], args: dict[str, Any], verbose: bool) -> None:
        shutil.copytree(self.SRC_DIR / 'circt_semantics', output_dir / 'circt_semantics')

    def source(self) -> tuple[Path, ...]:
        return (self.SRC_DIR,)


class KompileTarget(Target):
    _kompile_args: Callable[[Path], Mapping[str, Any]]

    def __init__(self, kompile_args: Callable[[Path], Mapping[str, Any]]):
        self._kompile_args = kompile_args

    def build(self, output_dir: Path, deps: dict[str, Path], args: dict[str, Any], verbose: bool) -> None:
        kompile_args = self._kompile_args(deps['circt-semantics.source'])
        kompile(output_dir=output_dir, verbose=verbose, **kompile_args)

    def context(self) -> dict[str, str]:
        return {'k-version': k_version().text}

    def deps(self) -> tuple[str]:
        return ('circt-semantics.source',)


__TARGETS__: Final = {
    'source': SourceTarget(),
    'llvm': KompileTarget(
        lambda src_dir: {
            'backend': PykBackend.LLVM,
            'main_file': src_dir / 'circt_semantics/main.k',
            'main_module': 'MAIN',
            'syntax_module': 'MAIN-SYNTAX',
            # 'gen_bison_parser': True,
            # 'gen_glr_bison_parser': True,
            # 'bison-stack-max-depth': 10000000,
            # 'coverage': True,
        },
    ),
    # 'coverage': KompileTarget(
    #     lambda src_dir: {
    #         'backend': PykBackend.LLVM,
    #         'main_file': src_dir / 'circt_semantics/main.k',
    #         'main_module': 'MAIN',
    #         'syntax_module': 'MAIN-SYNTAX',
    #         'gen_glr_bison_parser': True,
    #         'coverage': True,
    #     },
    # ),
    # 'llvm': KompileTarget(
    #     lambda src_dir: {
    #         'backend': PykBackend.LLVM,
    #         'main_file': src_dir / 'circt_semantics/main.k',
    #         'main_module': 'MAIN',
    #         'syntax_module': 'MAIN-SYNTAX',
    #         'warnings_to_errors': True,
    #         'gen_glr_bison_parser': True,
    #         'opt_level': 3,
    #         'ccopts': ['-g'],
    #     },
    # ),
}
