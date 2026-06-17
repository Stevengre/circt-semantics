from __future__ import annotations

import shutil
from pathlib import Path
from types import SimpleNamespace
from typing import Any, cast

import pytest

import kcirct.__main__ as main_module
from kcirct._prove import clear_assertion_proof_data
from kcirct.api import KCIRCT
from kcirct.verify_debug import dump_assertion_debug_artifacts, summarize_assert_proof, summarize_assertion_branches

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
        _ = input_file
        self.calls.append(f'run_simulate_fast:{inputs}:{depth}')
        if self.fail:
            output_file.write_text('LblassertionError{}("\\dv{SortString{}}("overflow_assert")")')
        else:
            output_file.write_text('no assertion failure')


def test_parse_input_steps() -> None:
    assert main_module._parse_input_steps(None) == [[]]
    assert main_module._parse_input_steps(['1:8,0xff:8', '']) == [[(1, 8), (255, 8)], []]


def test_parse_symbolic_widths() -> None:
    assert main_module._parse_symbolic_widths('8,16', [[]]) == [8, 16]
    assert main_module._parse_symbolic_widths(None, [[(0, 4), (1, 8)]]) == [4, 8]


def test_verify_parser_debug_artifact_args() -> None:
    parser = main_module.create_arg_parser()

    args = parser.parse_args(
        [
            'verify',
            'src/tests/resources/verify/assert_true/assert_true.generic.mlir',
            '--symbolic',
            '--dump-debug-artifacts',
            '--debug-artifact-dir',
            '/tmp/kcirct-debug',
            '--show-branch-constraints',
        ]
    )

    assert args.dump_debug_artifacts is True
    assert args.debug_artifact_dir == '/tmp/kcirct-debug'
    assert args.show_branch_constraints is True


def test_default_assertion_artifact_dir() -> None:
    assert KCIRCT.default_assertion_artifact_dir(Path('/tmp/test/foo.generic.mlir'), 'Foo') == Path(
        '/tmp/test/.kcirct/foo.generic.Foo.assertions'
    )


def test_find_assertion_errors(tmp_path: Path) -> None:
    state = tmp_path / 'state.kore'
    state.write_text('... ASSERT: overflow_assert ...')

    assert KCIRCT.find_assertion_errors(state) == ['overflow_assert']


def test_clear_assertion_proof_data(tmp_path: Path) -> None:
    proof_dir = tmp_path / 'proof'
    proof_data_dir = proof_dir / 'unit.assertions'
    proof_data_dir.mkdir(parents=True)
    (proof_data_dir / 'proof.json').write_text('{}')

    assert clear_assertion_proof_data('unit.assertions', proof_dir) is True
    assert not proof_data_dir.exists()
    assert clear_assertion_proof_data('unit.assertions', proof_dir) is False


def test_summarize_assert_proof() -> None:
    result = SimpleNamespace(
        proof=SimpleNamespace(
            id='assert_no_signed_overflow.AssertNoSignedOverflow.assertions',
            one_line_summary='1 failing leaf',
            pending=[SimpleNamespace(id=3)],
            failing=[SimpleNamespace(id=9)],
        ),
        input_file=Path('/tmp/assert_no_signed_overflow.generic.mlir'),
        top_module='AssertNoSignedOverflow',
        work_dir=Path('/tmp/proof'),
        setup_state=Path('/tmp/proof/setup.kore'),
        symbolic_widths=[8, 8],
        note='debug note',
    )

    summary = summarize_assert_proof(cast('Any', result))

    assert 'proof_id=assert_no_signed_overflow.AssertNoSignedOverflow.assertions' in summary
    assert 'top_module=AssertNoSignedOverflow' in summary
    assert 'symbolic_widths=[8, 8]' in summary
    assert 'pending=[3]' in summary
    assert 'failing=[9]' in summary


def test_summarize_assertion_branches(tmp_path: Path) -> None:
    proof_root = tmp_path / 'work' / 'proof' / 'unit.assertions' / 'kcfg'
    nodes_dir = proof_root / 'nodes'
    nodes_dir.mkdir(parents=True)
    (proof_root / 'kcfg.json').write_text(
        '{"nodes":[3,4,5],"edges":[],"ndbranches":[{"source":3,"targets":[4,5],"rules":[]}],"vacuous":[],"stuck":[]}'
    )
    (nodes_dir / '3.json').write_text(
        '{"id":3,"cterm":{"constraints":[{"node":"KApply","label":{"node":"KLabel","name":"#Equals","params":[]},'
        '"args":[{"node":"KToken","token":"true","sort":{"node":"KSort","name":"Bool","params":[]}},'
        '{"node":"KApply","label":{"node":"KLabel","name":"_<=Int_","params":[]},'
        '"args":[{"node":"KToken","token":"0","sort":{"node":"KSort","name":"Int","params":[]}},'
        '{"node":"KVariable","name":"INPUT0","sort":{"node":"KSort","name":"Int","params":[]}}],"arity":2,"variable":false}],'
        '"arity":2,"variable":false}]},"attrs":[]}'
    )
    (nodes_dir / '4.json').write_text(
        '{"id":4,"cterm":{"constraints":['
        '{"node":"KApply","label":{"node":"KLabel","name":"#Equals","params":[]},"args":'
        '[{"node":"KToken","token":"true","sort":{"node":"KSort","name":"Bool","params":[]}},'
        '{"node":"KApply","label":{"node":"KLabel","name":"_<=Int_","params":[]},"args":'
        '[{"node":"KToken","token":"0","sort":{"node":"KSort","name":"Int","params":[]}},'
        '{"node":"KVariable","name":"INPUT0","sort":{"node":"KSort","name":"Int","params":[]}}],"arity":2,"variable":false}],"arity":2,"variable":false},'
        '{"node":"KApply","label":{"node":"KLabel","name":"#Not","params":[]},"args":'
        '[{"node":"KVariable","name":"BRANCH4","sort":{"node":"KSort","name":"Bool","params":[]}}],"arity":1,"variable":false}'
        ']},"attrs":[]}'
    )
    (nodes_dir / '5.json').write_text(
        '{"id":5,"cterm":{"constraints":['
        '{"node":"KApply","label":{"node":"KLabel","name":"#Equals","params":[]},"args":'
        '[{"node":"KToken","token":"true","sort":{"node":"KSort","name":"Bool","params":[]}},'
        '{"node":"KApply","label":{"node":"KLabel","name":"_<=Int_","params":[]},"args":'
        '[{"node":"KToken","token":"0","sort":{"node":"KSort","name":"Int","params":[]}},'
        '{"node":"KVariable","name":"INPUT0","sort":{"node":"KSort","name":"Int","params":[]}}],"arity":2,"variable":false}],"arity":2,"variable":false},'
        '{"node":"KApply","label":{"node":"KLabel","name":"#Equals","params":[]},"args":'
        '[{"node":"KVariable","name":"COND5","sort":{"node":"KSort","name":"Bool","params":[]}},'
        '{"node":"KToken","token":"true","sort":{"node":"KSort","name":"Bool","params":[]}}],"arity":2,"variable":false}'
        ']},"attrs":[]}'
    )
    result = SimpleNamespace(
        proof=SimpleNamespace(id='unit.assertions'),
        work_dir=tmp_path / 'work',
    )

    summary = summarize_assertion_branches(cast('Any', result))

    assert 'Branch 3 -> [4, 5]' in summary
    assert 'target 4: 2 constraints (1 new vs source)' in summary
    assert 'target 5: 2 constraints (1 new vs source)' in summary
    assert 'not (BRANCH4)' in summary
    assert 'COND5 == true' in summary


def test_dump_assertion_debug_artifacts(tmp_path: Path) -> None:
    class PrettyKCIRCT:
        def write_pretty(self, kore_path: Path, pretty_path: Path) -> None:
            pretty_path.write_text(f'PRETTY {kore_path.name}')

    setup_state = tmp_path / 'setup.kore'
    setup_state.write_text('setup')
    simulated_state = tmp_path / 'simulated.0.kore'
    simulated_state.write_text('state')
    proof_root = tmp_path / 'work' / 'proof' / 'unit.assertions' / 'kcfg'
    nodes_dir = proof_root / 'nodes'
    nodes_dir.mkdir(parents=True)
    (proof_root / 'kcfg.json').write_text(
        '{"nodes":[3,4],"edges":[],"ndbranches":[{"source":3,"targets":[4],"rules":[]}],"vacuous":[],"stuck":[]}'
    )
    (nodes_dir / '3.json').write_text('{"id":3,"cterm":{"constraints":[]},"attrs":[]}')
    (nodes_dir / '4.json').write_text(
        '{"id":4,"cterm":{"constraints":[{"node":"KVariable","name":"BRANCH","sort":{"node":"KSort","name":"Bool","params":[]}}]},"attrs":[]}'
    )
    result = SimpleNamespace(
        proof=SimpleNamespace(
            id='unit.assertions',
            one_line_summary='proof summary',
            pending=[],
            failing=[SimpleNamespace(id=1)],
        ),
        input_file=tmp_path / 'assert.generic.mlir',
        top_module='Foo',
        work_dir=tmp_path / 'work',
        setup_state=setup_state,
        symbolic_widths=[8],
        note='assert note',
    )

    artifacts = dump_assertion_debug_artifacts(
        cast('Any', PrettyKCIRCT()),
        cast('Any', result),
        state_files=[simulated_state],
    )

    assert artifacts.output_dir == tmp_path / 'work' / 'debug'
    assert artifacts.summary_file.read_text() == (
        'proof_id=unit.assertions; '
        f'input_file={tmp_path / "assert.generic.mlir"}; '
        'top_module=Foo; '
        'symbolic_widths=[8]; '
        f'work_dir={tmp_path / "work"}; '
        f'setup_state={setup_state}; '
        'proof summary; '
        'pending=[]; '
        'failing=[1]\n'
        'assert note\n'
    )
    assert artifacts.branch_summary_file == tmp_path / 'work' / 'debug' / 'proof-branches.txt'
    assert artifacts.branch_summary_file is not None
    assert artifacts.branch_summary_file.read_text() == (
        'Branch 3 -> [4]\n' '  target 4: 1 constraints (1 new vs source)\n' '    + BRANCH\n'
    )
    assert artifacts.setup_pretty_file is not None
    assert artifacts.setup_pretty_file.read_text() == 'PRETTY setup.kore'
    assert artifacts.state_pretty_files == [tmp_path / 'work' / 'debug' / 'simulated.0.kore.pretty']
    assert artifacts.state_pretty_files[0].read_text() == 'PRETTY simulated.0.kore'


def test_exec_verify_symbolic_dump_debug_artifacts(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    debug_dir = tmp_path / 'debug-output'
    setup_state = tmp_path / 'setup.kore'
    setup_state.write_text('setup')
    symbolic_result = SimpleNamespace(
        input_file=tmp_path / 'assert.generic.mlir',
        top_module='Foo',
        work_dir=tmp_path / 'work',
        setup_state=setup_state,
        symbolic_widths=[8, 8],
        note='assert note',
        proof=SimpleNamespace(
            id='unit.assertions',
            passed=False,
            failed=True,
            one_line_summary='1 failing leaf',
            pending=[],
            failing=[SimpleNamespace(id=10)],
        ),
    )

    class DummyVerifyCLI:
        def prove_assertions(self, *args: Any, **kwargs: Any) -> Any:
            assert kwargs['reload'] is True
            return symbolic_result

        def dump_assertion_debug_artifacts(
            self, result: Any, *, output_dir: Path | None = None, state_files: list[Path] | None = None
        ) -> Any:
            assert result is symbolic_result
            assert output_dir == debug_dir
            assert state_files == [setup_state]
            return SimpleNamespace(
                output_dir=debug_dir,
                summary_file=debug_dir / 'proof-summary.txt',
                branch_summary_file=debug_dir / 'proof-branches.txt',
                setup_pretty_file=debug_dir / 'setup.pretty',
                state_pretty_files=[debug_dir / 'setup.kore.pretty'],
            )

        def summarize_assert_proof(self, result: Any) -> str:
            assert result is symbolic_result
            return 'proof summary'

        def summarize_assertion_branches(self, result: Any, *, max_constraints_per_target: int = 3) -> str:
            assert result is symbolic_result
            assert max_constraints_per_target == 3
            return 'Branch 3 -> [4, 5]\n  target 4: 5 constraints (1 new vs source)\n'

    monkeypatch.setattr(main_module, 'KCIRCT', lambda: DummyVerifyCLI())

    with pytest.raises(SystemExit, match='1'):
        main_module.exec_verify(
            input=str(tmp_path / 'assert.generic.mlir'),
            top_module='Foo',
            input_steps=None,
            work_dir=str(tmp_path / 'work'),
            symbolic=True,
            symbolic_input_widths='8,8',
            proof_dir=None,
            haskell_target=None,
            llvm_lib_target=None,
            max_depth=80,
            max_iterations=5,
            fail_fast=False,
            maintenance_rate=1,
            reload=True,
            dump_debug_artifacts=True,
            debug_artifact_dir=str(debug_dir),
            show_branch_constraints=True,
        )

    stdout = capsys.readouterr().out
    assert f'debug-dir: {debug_dir}' in stdout
    assert f'debug-summary-file: {debug_dir / "proof-summary.txt"}' in stdout
    assert f'debug-branch-summary-file: {debug_dir / "proof-branches.txt"}' in stdout
    assert f'debug-setup-pretty: {debug_dir / "setup.pretty"}' in stdout
    assert f'  - {debug_dir / "setup.kore.pretty"}' in stdout
    assert 'debug-summary: proof summary' in stdout
    assert 'branch-constraints:' in stdout
    assert 'Branch 3 -> [4, 5]' in stdout


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
    if shutil.which('krun') is None:
        pytest.skip('krun is required to build the setup state')
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
