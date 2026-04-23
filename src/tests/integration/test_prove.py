from __future__ import annotations

import time
from pathlib import Path
from typing import TYPE_CHECKING

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

TEST_DIRS = [dir for dir in (DATA_PATH / 'verification_test').iterdir() if dir.is_dir()]
TEST_ID_DIRS = [dir.name for dir in TEST_DIRS]

ADDER_KORE: Final = DATA_PATH / 'verification_test' / 'adder-modules' / 'simulated.1.kore.prestate'
ADDER_KINNER_JSON: Final = DATA_PATH / 'verification_test' / 'adder-modules' / 'Kinner.json'
SPEC_DIR: Final = DATA_PATH / 'verification_test' / 'adder-modules'
PROVE_DIR: Final = DATA_PATH / 'verification_test' / 'adder-modules' / 'prove_dir'
SPEC_TESTS: Final = list(SPEC_DIR.glob('*.k'))
K_FILES: Final = Path('/home/zjh/proj/cym-circt-semantics/src/kcirct/kdist/circt_semantics')
haskell_dir: Final = kdist.get('circt-semantics.haskell')
llvm_lib_dir: Final = kdist.get('circt-semantics.llvm-lib')
BUG_REPORT: Final = DATA_PATH / 'verification_test' / 'adder-modules' / 'bug_report'
START_KORE: Final = DATA_PATH / 'verification_test' / 'adder-modules' / 'start.kore'
TARGET_KORE: Final = DATA_PATH / 'verification_test' / 'adder-modules' / 'target.kore'

TEST_BUG_REPORT: Final = DATA_PATH / 'verification_test' / 'test-new' / 'bug_report'
TEST_START_KORE: Final = DATA_PATH / 'verification_test' / 'test-new' / 'start.kore'
TEST_TARGET_KORE: Final = DATA_PATH / 'verification_test' / 'test-new' / 'target.kore'
TEST_PROVE_DIR: Final = DATA_PATH / 'verification_test' / 'test-new' / 'prove_dir'



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


def test_build_struct_in_py(start_kore_file: Path, target_kore_file: Path) -> None:
    k_definition = kdist.get('circt-semantics.haskell')
    kprint = KPrint(k_definition)
    with open(start_kore_file, 'r') as f:
        kore_text = f.read()
    start_kore = KoreParser(kore_text).pattern()
    with open(target_kore_file, 'r') as f:
        kore_text = f.read()
    target_kore = KoreParser(kore_text).pattern()
    start_kast = kprint.kore_to_kast(start_kore)
    target_kast = kprint.kore_to_kast(target_kore)

    target_map_pattern = KApply(
        '_Map_',
        [
            KApply(
                '_|->_',
                [
                    KToken('"Foo/%0"', 'String'),
                    KApply('bits(_,_)_BITS-SYNTAX_Bits_BitsValue_Int', [KVariable('Z1', sort=INT), KToken('8', 'Int')]),
                ],
            ),
            KApply(
                '_Map_',
                [
                    KApply(
                        '_|->_',
                        [
                            KToken(r'"Foo/%arg1"', 'String'),
                            KApply(
                                'bits(_,_)_BITS-SYNTAX_Bits_BitsValue_Int',
                                [KVariable('Y1', sort=INT), KToken('8', 'Int')],
                            ),
                        ],
                    ),
                    # KApply('_Map_', [
                    KApply(
                        '_|->_',
                        [
                            KToken(r'"Foo/%arg0"', 'String'),
                            KApply(
                                'bits(_,_)_BITS-SYNTAX_Bits_BitsValue_Int',
                                [KVariable('X1', sort=INT), KToken('8', 'Int')],
                            ),
                        ],
                    ),
                    # KVariable('_', 'Map')
                    # KApply('.Map', [])
                    # ])
                ],
            ),
        ],
    )

    target_kast = set_cell(target_kast, 'SIGNALS_CELL', target_map_pattern)

    target_map_pattern = KApply(
        '_Map_',
        [
            KApply(
                '_|->_',
                [
                    KToken('"Foo/%0"', 'String'),
                    KApply('bits(_,_)_BITS-SYNTAX_Bits_BitsValue_Int', [KToken('20', 'Int'), KToken('8', 'Int')]),
                ],
            ),
            KApply(
                '_Map_',
                [
                    KApply(
                        '_|->_',
                        [
                            KToken(r'"Foo/%arg1"', 'String'),
                            KApply(
                                'bits(_,_)_BITS-SYNTAX_Bits_BitsValue_Int', [KToken('28', 'Int'), KToken('8', 'Int')]
                            ),
                        ],
                    ),
                    # KApply('_Map_', [
                    KApply(
                        '_|->_',
                        [
                            KToken(r'"Foo/%arg0"', 'String'),
                            KApply(
                                'bits(_,_)_BITS-SYNTAX_Bits_BitsValue_Int', [KToken('248', 'Int'), KToken('8', 'Int')]
                            ),
                        ],
                    ),
                    # KVariable('_', 'Map')
                    # KApply('.Map', [])
                    # ])
                ],
            ),
        ],
    )

    target_kast = set_cell(target_kast, 'HISTORY_CELL', target_map_pattern)
    start_kast = set_cell(start_kast, 'SIGNALS_CELL', target_map_pattern)

    target_cterm = CTerm.from_kast(target_kast)

    # 构建 Bits 值
    bits1 = KApply('bits(_,_)_BITS-SYNTAX_Bits_BitsValue_Int', [KVariable('X0', sort=INT), KToken('8', 'Int')])

    bits2 = KApply('bits(_,_)_BITS-SYNTAX_Bits_BitsValue_Int', [KVariable('Y0', sort=INT), KToken('8', 'Int')])

    # 构建 List
    list_items = KApply(
        '_List_', [KApply('ListItem', [bits1]), KApply('_List_', [KApply('ListItem', [bits2]), KApply('.List', [])])]
    )

    # 构建 KSequence
    cmd_content = KSequence([KToken('"CIRCT#SIMULATE"', 'String'), list_items])

    start_kast = set_cell(start_kast, 'CMD_CELL', cmd_content)
    start_cterm = CTerm.from_kast(start_kast)

    init_subst = CSubst(
        constraints=[
            mlEqualsTrue(ge_constraint(KVariable('X0', sort=INT), 0)),
            mlEqualsTrue(l_constraint(KVariable('X0', sort=INT), 256)),
            mlEqualsTrue(ge_constraint(KVariable('Y0', sort=INT), 0)),
            mlEqualsTrue(l_constraint(KVariable('Y0', sort=INT), 256)),
        ]
    )
    final_subst = CSubst(
        constraints=[
            mlEqualsTrue(equals(KVariable('X1', sort=INT), KVariable('X0', sort=INT))),
            mlEqualsTrue(equals(KVariable('Y1', sort=INT), KVariable('Y0', sort=INT))),
            mlEqualsTrue(
                equals(
                    KVariable('Z1', sort=INT),
                    KApply(
                        '_modInt_',
                        KApply('_+Int_', KVariable('X0', sort=INT), KVariable('Y0', sort=INT)),
                        intToken(256),
                    ),
                )
            ),
        ]
    )
    symtools = SymTools.default(proof_dir=TEST_PROVE_DIR)
    start_time = time.time()
    kclaim = cterm_build_claim('test1', init_subst(start_cterm), final_subst(target_cterm))
    # print(symtools.bug_report)
    proof = symtools.prove_with_kclaim(
        kclaim=kclaim[0],
        max_depth=1000,
    )
    end_time = time.time()
    print('runtime:' + str(end_time - start_time))
    proof_show_file = TEST_PROVE_DIR.parent / 'test-proof.txt'
    proof_show_lines = symtools.proof_show.show(proof, nodes=[node.id for node in proof.kcfg.nodes])
    proof_show_file.write_text('\n'.join(proof_show_lines))
    print(proof.status)


def rods() -> None:
    init_subst = CSubst(
        constraints=[
            mlEqualsTrue(equals(KVariable('CLKH', sort=INT), 0)),
            mlEqualsTrue(equals(KVariable('CLK0', sort=INT), 1)),
            mlEqualsTrue(ge_constraint(KVariable('RESET0', sort=INT), 0)),
            mlEqualsTrue(le_constraint(KVariable('RESET0', sort=INT), 2)),
        ]
    )
    final_subst = CSubst(
        constraints=[
            mlEqualsTrue(
                KApply(
                    '_andBool_',
                    equals(
                        KVariable('REG1', sort=INT),
                        KApply(
                            '_modInt_',
                            KApply('_+Int_', KVariable('REGH', sort=INT), intToken(1)),
                            intToken(256),
                        ),
                    ),
                    equals(KVariable('RESET0', sort=INT), intToken(0)),
                )
            ),
            mlEqualsTrue(
                KApply(
                    '_andBool_',
                    equals(
                        KVariable('REG1', sort=INT),
                        intToken(0),
                    ),
                    equals(KVariable('RESET0', sort=INT), intToken(1)),
                )
            ),
        ]
    )

def test_read_kore_to_kinner(start_kore_file: Path, target_kore_file: Path, out_file: Path) -> None:
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

    init_subst = CSubst(
        constraints=[
            mlEqualsTrue(ge_constraint(KVariable('X0', sort=INT), 0)),
            mlEqualsTrue(l_constraint(KVariable('X0', sort=INT), 256)),
            mlEqualsTrue(ge_constraint(KVariable('Y0', sort=INT), 0)),
            mlEqualsTrue(l_constraint(KVariable('Y0', sort=INT), 256)),
        ]
    )
    final_subst = CSubst(
        constraints=[
            mlEqualsTrue(equals(KVariable('X1', sort=INT), KVariable('X0', sort=INT))),
            mlEqualsTrue(equals(KVariable('Y1', sort=INT), KVariable('Y0', sort=INT))),
            mlEqualsTrue(
                equals(
                    KVariable('Z1', sort=INT),
                    KApply(
                        '_modInt_',
                        KApply('_+Int_', KVariable('X0', sort=INT), KVariable('Y0', sort=INT)),
                        intToken(256),
                    ),
                )
            ),
        ]
    )
    # 给起始状态和目标状态中的变量绑定约束

    symtools = SymTools.default(proof_dir=PROVE_DIR)
    start_time = time.time()
    kclaim = cterm_build_claim('test1', init_subst(start_cterm), final_subst(target_cterm))
    # 创建claim
    proof = symtools.prove_with_kclaim(
        kclaim=kclaim[0],
        max_depth=1000,
    )
    # 进行验证证明
    end_time = time.time()
    print('runtime:' + str(end_time - start_time))
    proof_show_file = SPEC_DIR / 'adder-proof.txt'
    proof_show_lines = symtools.proof_show.show(proof, nodes=[node.id for node in proof.kcfg.nodes])
    proof_show_file.write_text('\n'.join(proof_show_lines))
    print(proof.status)


if __name__ == '__main__':
    test_read_kore_to_kinner(START_KORE, TARGET_KORE, ADDER_KINNER_JSON)
    # test_build_struct_in_py(TEST_START_KORE, TEST_TARGET_KORE)
