from __future__ import annotations

__all__ = ['KIRCT']

import json
import logging
import subprocess
from dataclasses import dataclass
from functools import cached_property
from pathlib import Path
from subprocess import CalledProcessError
from tempfile import NamedTemporaryFile
from typing import TYPE_CHECKING, Any, Iterable, Optional, Union, final

from .utils import check_dir_path, check_file_path
from pyk.cterm import CTerm
from pyk.kast.inner import KApply, KInner, KSequence, KVariable
# from pyk.kast.manip import anti_unify_with_constraints
from pyk.kcfg.explore import KCFGExplore
from pyk.kcfg.kcfg import KCFG
from pyk.kcfg.show import KCFGShow
from pyk.kcfg.tui import KCFGViewer
from pyk.ktool.kprint import KAstInput, KAstOutput, _kast, gen_glr_parser # , paren
from pyk.ktool.kprove import KProve
from pyk.ktool.krun import KRun, KRunOutput, _krun
from pyk.prelude.kbool import BOOL, notBool
from pyk.prelude.ml import mlEqualsTrue
from pyk.proof.equality import EqualityProof, EqualityProver
from pyk.proof.proof import Proof
from pyk.proof.reachability import APRBMCProof, APRBMCProver, APRProof, APRProver
# from pyk.proof.utils import read_proof
from pyk.utils import shorten_hashes


if TYPE_CHECKING:
    from subprocess import CompletedProcess
    from typing import Final

    from pyk.ktool.kprint import SymbolTable

_LOGGER: Final = logging.getLogger(__name__)

@final
@dataclass(frozen=True)
class KIRCT:
    llvm_dir: Path
    haskell_dir: Path
    # mlir_parser: str
    # proof_dir: Path

# 想办法支持完整的四个后端：llvm、haskell、haskell-booster、maude
    
    def __init__(self, llvm_dir: Union[str, Path], haskell_dir: Union[str, Path]):
        llvm_dir = Path(llvm_dir)
        check_dir_path(llvm_dir)

        # mlir_parser = 'kparse --definition ' + str(llvm_dir)
        # TODO: Try to use the pre-generated parser
        # imp_parser = llvm_dir / 'parser_TopLevel_MLIR-SYNTAX'
        # if not imp_parser.is_file():
        #     imp_parser = gen_glr_parser(imp_parser, definition_dir=llvm_dir, module='MLIR-SYNTAX', sort='TopLevel')

        haskell_dir = Path(haskell_dir)
        check_dir_path(haskell_dir)

        # proof_dir = Path('.') / '.kimp' / 'ag_proofs'
        # proof_dir.mkdir(exist_ok=True, parents=True)

        object.__setattr__(self, 'llvm_dir', llvm_dir)
        object.__setattr__(self, 'haskell_dir', haskell_dir)
        # object.__setattr__(self, 'mlir_parser', mlir_parser)
        # object.__setattr__(self, 'proof_dir', proof_dir)
    
    def parse(self, program_file:Union[str, Path], *, 
              input: KAstInput, 
              output: KAstOutput, 
              temp_file: Optional[Union[str, Path]] = None,
              ) -> CompletedProcess:
        def __parse(program_file: Path) -> CompletedProcess:
            try:
                proc_res = _kast(
                    definition_dir=self.llvm_dir,
                    file=program_file,
                    input=input,
                    output=output,
                    sort='TopLevel',
                )
            except CalledProcessError as err:
                raise ValueError("Couldn't parse program") from err
            return proc_res

        def __preprocess_and_parse(program_file: Path, temp_file: Path) -> CompletedProcess:
            temp_file.write_text(program_file.read_text())
            return __parse(temp_file)

        program_file = Path(program_file)
        check_file_path(program_file)

        if temp_file is None:
            with NamedTemporaryFile(mode='w') as f:
                temp_file = Path(f.name)
                return __preprocess_and_parse(program_file, temp_file)

        temp_file = Path(temp_file)
        return __preprocess_and_parse(program_file, temp_file)
        

