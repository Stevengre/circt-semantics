from __future__ import annotations

import time
from pathlib import Path
from typing import TYPE_CHECKING
from kcirct.api import KCIRCT

from pyk.cterm import CSubst, CTerm, CTermSymbolic, cterm_build_claim
from pyk.kast.inner import KApply, KSequence, KToken, KVariable
from pyk.kast.manip import set_cell
from pyk.kast.prelude.kint import INT, intToken
from pyk.kast.prelude.ml import mlEqualsTrue
from pyk.kcfg import KCFGExplore
from pyk.kdist import kdist
from pyk.kore.parser import KoreParser
from pyk.ktool.kprint import KPrint

from kcirct.symtool import SymTools

if TYPE_CHECKING:
    from collections.abc import Iterator
    from pyk.kast.inner import KInner

    from typing import Final


from ..resources import DATA_PATH

IFU_KINNER_JSON: Final = DATA_PATH / 'XH_ifu_predecode' / 'Kinner.json'
SPEC_DIR: Final = DATA_PATH / 'XH_ifu_predecode'
PROVE_DIR: Final = DATA_PATH / 'XH_ifu_predecode'/ 'prove_dir'

SPEC_TESTS: Final = list(SPEC_DIR.glob('*.k'))
K_FILES: Final = Path('/home/zjh/proj/cym-circt-semantics/src/kcirct/kdist/circt_semantics')
haskell_dir: Final = kdist.get('circt-semantics.haskell')
llvm_lib_dir: Final = kdist.get('circt-semantics.llvm-lib')
BUG_REPORT: Final = DATA_PATH / 'XH_ifu_predecode' / 'bug_report'
START_KORE: Final = DATA_PATH / 'XH_ifu_predecode' / 'start.kore'
TARGET_KORE: Final = DATA_PATH / 'XH_ifu_predecode' / 'target.kore'
MLIR_FILE: Final = DATA_PATH / 'XH_ifu_predecode' / 'predecode.generic.mlir'
TOP_MODULE: Final = 'PreDecode'



def explore(self, *, id: str) -> Iterator[KCFGExplore]:
    from pyk.kore.rpc import BoosterServer, KoreClient

    with BoosterServer( 
        {
            'kompiled_dir': haskell_dir,
            'llvm_kompiled_dir': llvm_lib_dir,
            'module_name': '',
        }
    ) as server:
        with KoreClient('localhost', server.port, bug_report=self.bug_report, bug_report_id=id) as client:
            cterm_symbolic = CTermSymbolic(
                kore_client=client,
                definition=self.kprove.definition,
            )
            yield KCFGExplore(
                id=id,
                cterm_symbolic=cterm_symbolic,
            )


def ge_constraint(v: KInner, b: int) -> KInner:
    return KApply('_<=Int_', intToken(b), v)


def g_constraint(v: KInner, b: int) -> KInner:
    return KApply('_<Int_', intToken(b), v)


def equals(v1: KInner, v2: KInner) -> KInner:
    return KApply('_==Int_', v1, v2)


def le_constraint(v: KInner, b: int) -> KInner:
    return KApply('_>=Int_', intToken(b), v)


def l_constraint(v: KInner, b: int) -> KInner:
    return KApply('_<Int_', v, intToken(b))

def test_start_from_mlir(mlir_file: Path, top_module: str) -> None:
    kcirct = KCIRCT()
    kcirct.ensure_env()
    # KCIRCT Parsing: from mlir to kore
    kcirct.compile_fast(mlir_file, mlir_file.parent / 'pgm.kore')
    # KCIRCT Preprocessing
    kcirct.run_preprocess_fast(mlir_file.parent / 'pgm.kore', mlir_file.parent / 'preprocessed.kore')
    # KCIRCT Hardware Setup & Initialization
    kcirct.run_setup_fast(mlir_file.parent / 'preprocessed.kore', mlir_file.parent / 'setup.kore', top_module)

def test_read_kore_to_kinner(start_kore_file: Path, target_kore_file: Path) -> None:
    k_definition = kdist.get('circt-semantics.haskell')

    kprint = KPrint(k_definition)
    # 这里省略了使用仿真预处理阶段生成kore文件的过程
    with open(start_kore_file, 'r') as f:
        kore_text = f.read()

    start_kore = KoreParser(kore_text).pattern()

    with open(target_kore_file, 'r') as f:
        kore_text = f.read()
    target_kore = KoreParser(kore_text).pattern()
    kinner = kprint.kore_to_kast(start_kore)
    start_cterm = CTerm.from_kast(kinner)
    kinner = kprint.kore_to_kast(target_kore)
    target_cterm = CTerm.from_kast(kinner)
    # 读入程序的起始状态和目标状态

        # 一些小 helper，避免重复写字符串
    def X(i: int) -> KVariable:
        return KVariable(f'X{i}', sort=INT)

    def Y(i: int) -> KVariable:
        return KVariable(f'Y{i}', sort=INT)

    def Z(i: int) -> KVariable:
        return KVariable(f'io_out_instr_{i}', sort=INT)


    # ---------- init_subst: Y0..Y16 都在 [0,65535] ----------
    init_constraints: list[KInner] = []
    for i in range(17):  # Y0 ~ Y16
        yi = Y(i)
        init_constraints.append(
            mlEqualsTrue(ge_constraint(yi, 0))
        )
        init_constraints.append(
            mlEqualsTrue(l_constraint(yi, 65535))
        )

    init_subst = CSubst(
        constraints=init_constraints
    )


    # ---------- final_subst ----------

    final_constraints: list[KInner] = []

    # 1) Y0..Y16 = X0..X16
    for i in range(17):
        final_constraints.append(
            mlEqualsTrue(
                equals(Y(i), X(i))
            )
        )

    # 2) Z0..Z15 = ((Y{i+1} << 16) + Y{i}) mod 2^32
    MOD_32 = intToken(2 ** 32)   # 4294967296

    for i in range(16):  # Z0..Z15
        final_constraints.append(
            mlEqualsTrue(
                equals(
                    Z(i),
                    KApply('_modInt_',  
                        KApply('_+Int_',
                            KApply('_<<Int_',
                                Y(i + 1),
                                intToken(16),
                            ),
                            Y(i),
                        ),
                        MOD_32,
                    ),
                )
            )
        )

    final_subst = CSubst(
        constraints=final_constraints
    )
    # 给起始状态和目标状态中的变量绑定约束

    symtools = SymTools.default(proof_dir=PROVE_DIR)
    print("11111111111")
    start_time = time.time()
    kclaim = cterm_build_claim('test1', init_subst(start_cterm), final_subst(target_cterm))
    # 创建claim
    proof = symtools.prove_with_kclaim(
        kclaim=kclaim[0],
        max_depth=1,
    )
    # 进行验证证明
    end_time = time.time()
    print('runtime:' + str(end_time - start_time))
    proof_show_file = SPEC_DIR / 'predecode-proof.txt'
    proof_show_lines = symtools.proof_show.show(proof, nodes=[node.id for node in proof.kcfg.nodes])
    proof_show_file.write_text('\n'.join(proof_show_lines))
    print(proof.status)


def test_print_pretty(mlir_file: Path) -> None:
    kcirct = KCIRCT()
    file_name = 'setup.kore'
    pretty_name = file_name + '.pretty'
    kcirct.write_pretty(mlir_file.parent / file_name, mlir_file.parent / pretty_name)

if __name__ == '__main__':
    # test_start_from_mlir(MLIR_FILE, TOP_MODULE)
    # test_print_pretty(MLIR_FILE)
    test_read_kore_to_kinner(START_KORE, TARGET_KORE)
    
