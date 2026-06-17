from __future__ import annotations

import os
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from pyk.kdist._kdist import kdist

from kcirct.api import KCIRCT

if TYPE_CHECKING:
    from kcirct._prove import AssertProofResult

VERIFY_DATA_PATH = Path(__file__).parent.parent / 'resources' / 'verify'


@dataclass(frozen=True)
class VerifyExample:
    case_dir: str
    top_module: str
    symbolic_widths: list[int]
    initial_depth: int
    initial_iterations: int
    retry_depth: int
    retry_iterations: int
    expected_pass: bool
    expected_failed: bool
    xfail_reason: str | None = None


def _ensure_symbolic_verify_env() -> None:
    krun_path = shutil.which('krun')
    if krun_path is None:
        nix_krun = Path.home() / '.nix-profile' / 'bin' / 'krun'
        if nix_krun.exists():
            os.environ['PATH'] = f'{nix_krun.parent}:{os.environ.get("PATH", "")}'
            krun_path = str(nix_krun)

    if krun_path is None:
        pytest.skip('krun is required for symbolic verification integration tests')

    try:
        kdist.get('circt-semantics.haskell')
    except Exception as err:
        pytest.skip(f'circt-semantics.haskell target is not built: {err}')


def _proof_debug_summary(result: AssertProofResult) -> str:
    return KCIRCT.summarize_assert_proof(result)


def _prove_with_retry(example: VerifyExample, work_dir: Path, proof_dir: Path) -> tuple[Path, AssertProofResult]:
    input_file = VERIFY_DATA_PATH / example.case_dir / f'{example.case_dir}.generic.mlir'
    kcirct = KCIRCT()

    result = kcirct.prove_assertions(
        input_file,
        top_module=example.top_module,
        symbolic_widths=example.symbolic_widths,
        work_dir=work_dir,
        proof_dir=proof_dir,
        max_depth=example.initial_depth,
        max_iterations=example.initial_iterations,
    )

    if not result.proof.passed and not result.proof.failed:
        retry_work_dir = work_dir.parent / f'{example.case_dir}_retry'
        retry_proof_dir = retry_work_dir / 'proof'
        result = kcirct.prove_assertions(
            input_file,
            top_module=example.top_module,
            symbolic_widths=example.symbolic_widths,
            work_dir=retry_work_dir,
            proof_dir=retry_proof_dir,
            max_depth=example.retry_depth,
            max_iterations=example.retry_iterations,
        )

    return input_file, result


@pytest.mark.parametrize(
    'example',
    [
        pytest.param(VerifyExample('assert_true', 'AssertTrue', [8], 40, 3, 80, 5, True, False), id='assert_true'),
        pytest.param(
            VerifyExample('assert_eq_self', 'AssertEqSelf', [8], 40, 3, 80, 5, True, False), id='assert_eq_self'
        ),
        pytest.param(
            VerifyExample(
                'assert_add_zero_identity',
                'AssertAddZeroIdentity',
                [8],
                60,
                4,
                120,
                8,
                True,
                False,
                'Known symbolic limitation: add-with-zero identity still reaches a failing proof leaf',
            ),
            id='assert_add_zero_identity',
        ),
        pytest.param(
            VerifyExample(
                'assert_xor_self_zero',
                'AssertXorSelfZero',
                [8],
                60,
                4,
                120,
                8,
                True,
                False,
                'Known symbolic limitation: xor-self-zero identity still reaches a failing proof leaf',
            ),
            id='assert_xor_self_zero',
        ),
        pytest.param(
            VerifyExample(
                'assert_mux_same_branch',
                'AssertMuxSameBranch',
                [1, 8],
                80,
                4,
                140,
                8,
                True,
                False,
                'Known symbolic limitation: mux-same-branch identity still reaches a failing proof leaf',
            ),
            id='assert_mux_same_branch',
        ),
        pytest.param(
            VerifyExample('assert_eq_commutative', 'AssertEqCommutative', [8, 8], 80, 4, 140, 8, True, False),
            id='assert_eq_commutative',
        ),
        pytest.param(
            VerifyExample('assert_no_signed_overflow', 'AssertNoSignedOverflow', [8, 8], 80, 5, 200, 10, False, True),
            id='assert_no_signed_overflow',
        ),
    ],
)
def test_prove_assertions_examples(tmp_path: Path, example: VerifyExample) -> None:
    _ensure_symbolic_verify_env()

    work_dir = tmp_path / example.case_dir
    proof_dir = work_dir / 'proof'

    input_file, result = _prove_with_retry(example, work_dir, proof_dir)
    assert result.input_file == input_file
    assert result.top_module == example.top_module
    assert result.symbolic_widths == example.symbolic_widths
    assert result.setup_state.exists()
    assert result.proof.id == f'{input_file.stem}.{example.top_module}.assertions'
    assert result.proof.passed or result.proof.failed, _proof_debug_summary(result)
    if example.xfail_reason and result.proof.failed:
        pytest.xfail(f'{example.xfail_reason}: {_proof_debug_summary(result)}')
    assert result.proof.passed is example.expected_pass, _proof_debug_summary(result)
    assert result.proof.failed is example.expected_failed, _proof_debug_summary(result)
