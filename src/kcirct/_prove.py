from __future__ import annotations

import re
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

from pyk.cterm import CTerm, cterm_symbolic
from pyk.kast.inner import KApply, KSequence, KSort, KToken, KVariable, Subst
from pyk.kast.manip import split_config_from
from pyk.kast.prelude.collections import list_of
from pyk.kast.prelude.kint import intToken, leInt
from pyk.kast.prelude.ml import mlEqualsTrue
from pyk.kcfg import KCFG
from pyk.kcfg.explore import KCFGExplore
from pyk.kdist import kdist
from pyk.ktool.kprint import KPrint
from pyk.proof.reachability import APRProof, APRProver

from kcirct.kdist.circt_semantics.main import CirctSemantics

if TYPE_CHECKING:
    from pyk.kast.inner import KInner

    from .api import KCIRCT


BITS_LABEL = 'bits(_,_)_BITS-SYNTAX_Bits_BitsValue_Int'


@dataclass
class AssertVerificationResult:
    passed: bool
    input_file: Path
    top_module: str
    work_dir: Path
    state_files: list[Path]
    errors: list[str]
    checked_assertions: bool
    note: str


@dataclass
class AssertProofResult:
    proof: APRProof
    input_file: Path
    top_module: str
    work_dir: Path
    setup_state: Path
    symbolic_widths: list[int]
    note: str


def has_sv_assert(input_file: Path) -> bool:
    """Return whether an MLIR file contains an immediate SystemVerilog assert op."""
    text = input_file.read_text()
    return '"sv.assert"' in text or 'sv.assert ' in text


def find_assertion_errors(kore_file: Path) -> list[str]:
    """Extract assertion failures from a KORE state."""
    state = kore_file.read_text()
    if 'assertionError' not in state and 'AssertionError' not in state and 'ASSERT:' not in state:
        return []

    errors: list[str] = []
    for match in re.finditer(r'ASSERT:\s*([A-Za-z0-9_.:/-]+)', state):
        errors.append(match.group(1))
    for match in re.finditer(r'assertionError(?:\([^"]*"([^"]*)")?', state):
        errors.append(match.group(1) or 'assertionError')
    if not errors:
        errors.append('assertionError')
    return errors


def assert_semantics_note() -> str:
    return (
        'Current K rules lower sv.assert to #verifyAssert and handle concrete/symbolic Bool plus '
        'bits values that the solver can establish as 0 or 1. APR proof treats assertionError '
        'as a terminal failing leaf and proves all explored paths reach the normal target.'
    )


def default_assertion_artifact_dir(input_file: Path, top_module: str) -> Path:
    return input_file.parent / '.kcirct' / f'{input_file.stem}.{top_module}.assertions'


def clear_assertion_proof_data(proof_id: str, proof_dir: Path) -> bool:
    proof_data_dir = proof_dir / proof_id
    if not proof_data_dir.exists():
        return False
    shutil.rmtree(proof_data_dir)
    return True


def _symbolic_bits(name: str, width: int) -> KApply:
    return KApply(BITS_LABEL, (KVariable(name, KSort('Int')), intToken(width)))


def _symbolic_input_list(widths: list[int]) -> tuple[KInner, list[KApply]]:
    inputs = []
    constraints = []
    for idx, width in enumerate(widths):
        if width < 1:
            raise ValueError(f'Expected positive input width, got: {width}')
        var = KVariable(f'INPUT{idx}', KSort('Int'))
        inputs.append(_symbolic_bits(var.name, width))
        constraints.extend(
            [
                mlEqualsTrue(leInt(intToken(0), var)),
                mlEqualsTrue(leInt(var, intToken((1 << width) - 1))),
            ]
        )
    return list_of(inputs), constraints


def _simulate_cmd(input_list: KInner) -> KSequence:
    return KSequence((KToken('"CIRCT#SIMULATE"', KSort('String')), input_list))


def setup_state_for_assert_proof(kcirct: KCIRCT, input_file: Path, top_module: str, work_dir: Path) -> Path:
    work_dir.mkdir(parents=True, exist_ok=True)
    compiled = work_dir / 'pgm.kore'
    preprocessed = work_dir / 'preprocessed.kore'
    setup = work_dir / 'setup.kore'

    kcirct.ensure_env()
    kcirct.compile_fast(input_file, compiled)
    kcirct.run_preprocess_fast(compiled, preprocessed)
    kcirct.run_setup_fast(preprocessed, setup, top_module)
    return setup


def assertion_apr_proof(
    kcirct: KCIRCT,
    setup_state: Path,
    *,
    proof_id: str,
    symbolic_widths: list[int],
    proof_dir: Path | None = None,
) -> APRProof:
    assert kcirct._kprint is not None
    setup_config = kcirct._kprint.kore_to_kast(kcirct.read_kore(setup_state))
    var_config, setup_subst = split_config_from(setup_config)

    input_list, constraints = _symbolic_input_list(symbolic_widths)
    init_subst = dict(setup_subst)
    init_subst['CMD_CELL'] = _simulate_cmd(input_list)
    init = CTerm(Subst(init_subst)(var_config), constraints)

    target_subst: dict[str, KInner] = {key: KVariable(key) for key in setup_subst}
    target_subst['CMD_CELL'] = KSequence(())
    target_subst['CURRENTS_CELL'] = KApply('.CurrentInfoCellMap')
    target = CTerm(Subst(target_subst)(var_config))

    kcfg = KCFG()
    init_node = kcfg.create_node(init)
    target_node = kcfg.create_node(target)
    return APRProof(proof_id, kcfg, [], init_node.id, target_node.id, {}, proof_dir=proof_dir)


# 符号执行验证入口
def prove_assertions(
    kcirct: KCIRCT,
    input_file: Path,
    *,
    top_module: str,
    symbolic_widths: list[int],
    proof_dir: Path | None = None,
    work_dir: Path | None = None,
    haskell_target: Path | None = None,
    llvm_lib_target: Path | None = None,
    max_depth: int | None = None,
    max_iterations: int | None = None,
    fail_fast: bool = False,
    maintenance_rate: int = 1,
    reload: bool = False,
) -> AssertProofResult:
    if not symbolic_widths:
        raise ValueError('prove_assertions expects at least one symbolic input width')

    work_dir = work_dir or default_assertion_artifact_dir(input_file, top_module)
    proof_dir = proof_dir or work_dir / 'proof'
    setup_state = setup_state_for_assert_proof(kcirct, input_file, top_module, work_dir)
    proof_id = f'{input_file.stem}.{top_module}.assertions'
    if reload:
        clear_assertion_proof_data(proof_id, proof_dir)
    if APRProof.proof_data_exists(proof_id, proof_dir):
        proof = APRProof.read_proof_data(proof_dir, proof_id)
    else:
        proof = assertion_apr_proof(
            kcirct,
            setup_state,
            proof_id=proof_id,
            symbolic_widths=symbolic_widths,
            proof_dir=proof_dir,
        )

    haskell_definition_dir = haskell_target or kdist.get('circt-semantics.haskell')
    llvm_library_dir = llvm_lib_target
    try:
        llvm_library_dir = llvm_library_dir or kdist.get('circt-semantics.llvm-library')
    except Exception:
        llvm_library_dir = None

    proof_kprint = KPrint(definition_dir=haskell_definition_dir)
    with cterm_symbolic(
        proof_kprint.definition,
        haskell_definition_dir,
        llvm_definition_dir=llvm_library_dir,
        id=proof_id,
    ) as cts:
        kcfg_explore = KCFGExplore(cts, kcfg_semantics=CirctSemantics(), id=proof_id)
        prover = APRProver(kcfg_explore, execute_depth=max_depth)
        prover.advance_proof(
            proof,
            max_iterations=max_iterations,
            fail_fast=fail_fast,
            maintenance_rate=maintenance_rate,
        )

    return AssertProofResult(
        proof=proof,
        input_file=input_file,
        top_module=top_module,
        work_dir=work_dir,
        setup_state=setup_state,
        symbolic_widths=symbolic_widths,
        note=assert_semantics_note(),
    )


# 具体执行验证入口
def verify_assertions_fast(
    kcirct: KCIRCT,
    input_file: Path,
    *,
    top_module: str,
    input_steps: list[list[tuple[int, int]]] | None = None,
    work_dir: Path | None = None,
    depth: int | None = None,
) -> AssertVerificationResult:
    """Run the existing CIRCT pipeline and fail if an sv.assert reaches assertionError."""
    if input_steps is None:
        input_steps = [[]]
    if not input_steps:
        raise ValueError('verify_assertions_fast expects at least one input step')

    work_dir = work_dir or default_assertion_artifact_dir(input_file, top_module)
    work_dir.mkdir(parents=True, exist_ok=True)

    compiled = work_dir / 'pgm.kore'
    preprocessed = work_dir / 'preprocessed.kore'
    setup = work_dir / 'setup.kore'

    kcirct.ensure_env()
    kcirct.compile_fast(input_file, compiled)
    kcirct.run_preprocess_fast(compiled, preprocessed)
    kcirct.run_setup_fast(preprocessed, setup, top_module)

    state_files: list[Path] = []
    errors: list[str] = []
    current_state = setup
    for idx, inputs in enumerate(input_steps):
        next_state = work_dir / f'simulated.{idx}.kore'
        kcirct.run_simulate_fast(current_state, next_state, inputs, depth=depth)
        state_files.append(next_state)
        errors.extend(find_assertion_errors(next_state))
        current_state = next_state

    return AssertVerificationResult(
        passed=not errors,
        input_file=input_file,
        top_module=top_module,
        work_dir=work_dir,
        state_files=state_files,
        errors=errors,
        checked_assertions=has_sv_assert(input_file),
        note=assert_semantics_note(),
    )
