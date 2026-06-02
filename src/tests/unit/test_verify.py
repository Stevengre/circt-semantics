from __future__ import annotations

from pathlib import Path

import pytest

from kcirct.__main__ import _parse_input_steps, _parse_symbolic_widths
from kcirct.api import KCIRCT


VERIFY_ASSERT_TRUE = Path('src/tests/resources/verify/assert_true/assert_true.generic.mlir')


class DummyKCIRCT(KCIRCT):
    def __init__(self, data_dir: Path, *, fail: bool = False) -> None:
        self.data_dir = data_dir
        self.fail = fail
        self.calls: list[str] = []

    def ensure_env(self) -> None:
        self.calls.append('ensure_env')

    def compile_fast(self, file: Path, output_file: Path) -> None:
        self.calls.append('compile_fast')
        output_file.write_text(file.read_text())

    def run_preprocess_fast(self, pgm: Path, output_file: Path) -> None:
        self.calls.append('run_preprocess_fast')
        output_file.write_text(pgm.read_text())

    def run_setup_fast(self, input_file: Path, output_file: Path, top_module: str) -> None:
        self.calls.append(f'run_setup_fast:{top_module}')
        output_file.write_text(input_file.read_text())

    def run_simulate_fast(
        self, input_file: Path, output_file: Path, inputs: list[tuple[int, int]], depth: int | None = None
    ) -> None:
        self.calls.append(f'run_simulate_fast:{inputs}:{depth}')
        if self.fail:
            output_file.write_text('LblassertionError{}("\\dv{SortString{}}("overflow_assert")")')
        else:
            output_file.write_text('no assertion failure')


def test_parse_input_steps() -> None:
    assert _parse_input_steps(None) == [[]]
    assert _parse_input_steps(['1:8,0xff:8', '']) == [[(1, 8), (255, 8)], []]


def test_parse_symbolic_widths() -> None:
    assert _parse_symbolic_widths('8,16', [[]]) == [8, 16]
    assert _parse_symbolic_widths(None, [[(0, 4), (1, 8)]]) == [4, 8]


def test_default_assertion_artifact_dir() -> None:
    assert KCIRCT.default_assertion_artifact_dir(Path('/tmp/test/foo.generic.mlir'), 'Foo') == Path(
        '/tmp/test/.kcirct/foo.generic.Foo.assertions'
    )


def test_find_assertion_errors(tmp_path: Path) -> None:
    state = tmp_path / 'state.kore'
    state.write_text('... ASSERT: overflow_assert ...')

    assert KCIRCT.find_assertion_errors(state) == ['overflow_assert']


@pytest.mark.parametrize('fail', [False, True])
def test_verify_assertions_fast_pipeline(tmp_path: Path, fail: bool) -> None:
    mlir = tmp_path / 'assert.generic.mlir'
    mlir.write_text('"sv.assert"(%0) {defer = 0 : i32, label = "overflow_assert"} : (i1) -> ()')
    kcirct = DummyKCIRCT(tmp_path, fail=fail)

    result = kcirct.verify_assertions_fast(
        mlir,
        top_module='Foo',
        input_steps=[[(1, 8), (2, 8)]],
        work_dir=tmp_path / 'proof',
        depth=10,
    )

    assert result.passed is (not fail)
    assert result.checked_assertions
    assert result.state_files == [tmp_path / 'proof' / 'simulated.0.kore']
    assert kcirct.calls == [
        'ensure_env',
        'compile_fast',
        'run_preprocess_fast',
        'run_setup_fast:Foo',
        'run_simulate_fast:[(1, 8), (2, 8)]:10',
    ]


def test_assertion_apr_proof_from_setup_state(tmp_path: Path) -> None:
    pytest.importorskip('pyk')
    kcirct = KCIRCT()
    setup_state = kcirct._setup_state_for_assert_proof(VERIFY_ASSERT_TRUE, 'AssertTrue', tmp_path / 'proof')

    proof = kcirct.assertion_apr_proof(
        setup_state,
        proof_id='unit.assertions',
        symbolic_widths=[8],
    )

    init = proof.kcfg.node(proof.init).cterm
    target = proof.kcfg.node(proof.target).cterm
    assert 'INPUT0' in str(init.config)
    assert str(target.cell('CMD_CELL')) == 'KSequence(items=())'
