"""外部仿真接口的输入协议、双执行采样和失败证据回归测试。"""

from __future__ import annotations

import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

import pytest
from vcdvcd import VCDVCD

import kcirct.__main__ as main_module
import kcirct._simulate as simulator
from kcirct.trace.model import DumpIndexEntry, RunManifest, StateIndexEntry

_PORTS = 'input clk : i1, input a : i8, output q : i8'
_IDLE = ''.join(f"Lbl'-LT-'{name}'-GT-'{{}}(dotk{{}}())" for name in ('prog', 'setup', 'cmd'))


def _design(tmp_path: Path, ports: str = _PORTS, *, old_syntax: bool = False) -> Path:
    path = tmp_path / 'design.generic.mlir'
    attributes = f'module_type = !hw.modty<{ports}>, sym_name = "Demo"'
    text = (
        f'"hw.module"() ({{ ^bb0: "hw.output"() : () -> () }}) {{{attributes}}} : () -> ()'
        if old_syntax
        else f'"hw.module"() <{{{attributes}}}> ({{ ^bb0: "hw.output"() : () -> () }}) : () -> ()'
    )
    path.write_text(f'"builtin.module"() ({{\n{text}\n}}) : () -> ()')
    return path


def _stimulus(tmp_path: Path, events: Any = None) -> Path:
    path = tmp_path / 'events.json'
    if events is None:
        events = [{'time': 0, 'inputs': {'a': 7, 'clk': 0}}, {'time': 5, 'inputs': {'a': 19, 'clk': 1}}]
    path.write_text(json.dumps({'schema_version': 1, 'timescale': '1ns', 'events': events}))
    return path


@pytest.mark.parametrize('old_syntax', [False, True])
def test_port_order_comes_from_module_type(tmp_path: Path, old_syntax: bool) -> None:
    inputs, outputs = simulator.read_port_schema(_design(tmp_path, old_syntax=old_syntax), 'Demo')
    assert inputs == [simulator.Port('clk', 1), simulator.Port('a', 8)]
    assert outputs == [simulator.Port('q', 8)]


@pytest.mark.parametrize(
    'ports',
    ['input clk : !seq.clock, output q : i1', 'inout a : i1', 'input a : i1, output a : i1', 'output q : i1'],
)
def test_unsupported_or_ambiguous_ports_fail(tmp_path: Path, ports: str) -> None:
    with pytest.raises(ValueError):
        simulator.read_port_schema(_design(tmp_path, ports), 'Demo')


@pytest.mark.parametrize(
    'events',
    [
        [],
        [{'time': 0, 'inputs': {'a': 0}}],
        [{'time': 0, 'inputs': {'a': 0, 'clk': 0, 'unknown': 0}}],
        [{'time': 0, 'inputs': {'a': 256, 'clk': 0}}],
        [{'time': 0, 'inputs': {'a': -1, 'clk': 0}}],
        [{'time': 0, 'inputs': {'a': True, 'clk': 0}}],
        [{'time': 0, 'inputs': {'a': 1.0, 'clk': 0}}],
        [{'time': True, 'inputs': {'a': 1, 'clk': 0}}],
        [{'time': -1, 'inputs': {'a': 1, 'clk': 0}}],
        [{'time': 0, 'inputs': {'a': 1, 'clk': 0}}, {'time': 0, 'inputs': {'a': 2, 'clk': 1}}],
    ],
)
def test_invalid_events_fail_before_execution(tmp_path: Path, events: Any) -> None:
    with pytest.raises(ValueError):
        simulator.read_events(_stimulus(tmp_path, events), [simulator.Port('clk', 1), simulator.Port('a', 8)])


def test_duplicate_json_names_fail(tmp_path: Path) -> None:
    path = tmp_path / 'events.json'
    path.write_text('{"schema_version":1,"timescale":"1ns","events":[],"events":[]}')
    with pytest.raises(ValueError, match='重复字段'):
        simulator.read_events(path, [simulator.Port('a', 1)])


def _fake_backend(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, *, missing_output: bool = False, timeout_at: int | None = None
) -> tuple[Path, Path, list[tuple[int, list[tuple[int, int]]]]]:
    definition = tmp_path / 'definition'
    definition.mkdir()
    for name in ('definition.kore', 'compiled.bin', 'interpreter'):
        (definition / name).write_text('fake definition')
    (definition / 'backend.txt').write_text('llvm')
    parser = tmp_path / 'parser'
    parser.write_text('#!/bin/sh\nexit 0\n')
    parser.chmod(0o755)
    calls: list[tuple[int, list[tuple[int, int]]]] = []

    class FakeKCIRCT:
        def __init__(self, *_args: Any) -> None:
            pass

        def compile_fast(self, _input: Path, output: Path) -> None:
            output.write_text('compiled')

        def run_preprocess_fast(self, _input: Path, output: Path) -> None:
            output.write_text('preprocessed')

        def run_setup_fast(self, _input: Path, output: Path, _top: str) -> None:
            output.write_text(_IDLE + '\n' + json.dumps({'counter': 0}))

        def run_simulate_fast(self, input_file: Path, output_file: Path, inputs: list[tuple[int, int]]) -> None:
            state = json.loads(input_file.read_text().splitlines()[-1])
            counter = state['counter'] + 1
            calls.append((state['counter'], list(inputs)))
            if timeout_at == counter:
                raise subprocess.TimeoutExpired(['krun', str(input_file)], 0.01)
            output_file.write_text(_IDLE + '\n' + json.dumps({'counter': counter, 'values': inputs}))

        def read_ports_fast(self, state: Path, skip_missing: bool = False) -> dict[str, tuple[int, int]]:
            assert skip_missing
            data = json.loads(state.read_text().splitlines()[-1])
            ports = {'Demo/clk': tuple(data['values'][0]), 'Demo/a': tuple(data['values'][1])}
            if not missing_output:
                ports['Demo/q'] = (data['values'][1][0] if data['counter'] % 2 == 0 else 255, 8)
            return ports

    monkeypatch.setattr(simulator, 'SimulatorKCIRCT', FakeKCIRCT)
    return definition, parser, calls


def test_each_event_is_evaluated_twice_then_dumped_once(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    definition, parser, calls = _fake_backend(tmp_path, monkeypatch)
    work = tmp_path / 'run'
    result = simulator.simulate(
        _design(tmp_path),
        top_module='Demo',
        inputs_file=_stimulus(tmp_path),
        output=tmp_path / 'wave.vcd',
        work_dir=work,
        definition_dir=definition,
        parser=parser,
        keep_states=True,
    )
    assert result['status'] == 'pass', result
    assert calls == [(0, [(0, 1), (7, 8)]), (1, [(0, 1), (7, 8)]), (2, [(1, 1), (19, 8)]), (3, [(1, 1), (19, 8)])]
    assert result['events_completed'] == 2
    assert result['simulation_calls'] == 4
    vcd = VCDVCD(str(tmp_path / 'wave.vcd'))
    assert set(vcd.signals) == {'Demo.clk', 'Demo.a[7:0]', 'Demo.q[7:0]'}
    assert vcd['Demo.q[7:0]'].tv == [(0, '00000111'), (5, '00010011')]
    index = json.loads((work / 'states.json').read_text())
    assert [(entry['event_index'], entry['evaluation'], entry['time']) for entry in index] == [
        (0, 1, 0),
        (0, 2, 0),
        (1, 1, 5),
        (1, 2, 5),
    ]
    for entry in index:
        assert (
            hashlib.sha256(gzip.decompress((work / entry['path']).read_bytes())).hexdigest()
            == entry['sha256_uncompressed']
        )


def test_missing_required_output_fails_instead_of_silently_skipping(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    definition, parser, _ = _fake_backend(tmp_path, monkeypatch, missing_output=True)
    result = simulator.simulate(
        _design(tmp_path),
        top_module='Demo',
        inputs_file=_stimulus(tmp_path),
        output=tmp_path / 'wave.vcd',
        work_dir=tmp_path / 'run',
        definition_dir=definition,
        parser=parser,
    )
    assert result['status'] == 'execution_error'
    assert result['stage'] == 'read_ports'
    assert 'Demo/q' in result['error']
    assert result['simulation_calls'] == 2
    assert result['events_completed'] == 0


def test_timeout_preserves_last_completed_evaluation_and_inputs(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    definition, parser, _ = _fake_backend(tmp_path, monkeypatch, timeout_at=2)
    stimulus = _stimulus(tmp_path)
    result = simulator.simulate(
        _design(tmp_path),
        top_module='Demo',
        inputs_file=stimulus,
        output=tmp_path / 'wave.vcd',
        work_dir=tmp_path / 'run',
        definition_dir=definition,
        parser=parser,
        keep_states=True,
    )
    assert result['status'] == 'timeout'
    assert result['events_completed'] == 0
    assert result['simulation_calls'] == 1
    assert result['simulation_calls_attempted'] == 2
    assert Path(result['last_state']).is_file()
    assert json.loads(Path(result['last_state']).read_text().splitlines()[-1])['counter'] == 1
    assert (tmp_path / 'run' / 'inputs.json').read_bytes() == stimulus.read_bytes()
    assert json.loads((tmp_path / 'run' / 'result.json').read_text()) == result


def test_command_timeout_keeps_stdout_stderr_and_record(tmp_path: Path) -> None:
    executor = simulator.CommandExecutor(tmp_path, 1)
    with pytest.raises(subprocess.TimeoutExpired):
        executor.run(['/bin/sh', '-c', "printf 'started\\n'; sleep 10"])
    record = json.loads((tmp_path / 'commands.jsonl').read_text())
    assert record['status'] == 'timeout'
    assert record['elapsed_s'] < 5
    assert Path(record['stdout']).read_text() == 'started\n'
    assert Path(record['stderr']).is_file()


def test_invalid_input_leaves_result_and_existing_vcd_unchanged(tmp_path: Path) -> None:
    output = tmp_path / 'wave.vcd'
    output.write_text('existing evidence')
    result = simulator.simulate(
        _design(tmp_path), top_module='Demo', inputs_file=_stimulus(tmp_path), output=output, work_dir=tmp_path / 'run'
    )
    assert result['status'] == 'execution_error'
    assert result['stage'] == 'validation'
    assert output.read_text() == 'existing evidence'
    assert (tmp_path / 'run' / 'result.json').exists()


def test_existing_work_directory_is_not_reused(tmp_path: Path) -> None:
    with pytest.raises(FileExistsError):
        simulator.simulate(
            _design(tmp_path),
            top_module='Demo',
            inputs_file=_stimulus(tmp_path),
            output=tmp_path / 'wave.vcd',
            work_dir=tmp_path,
        )


def test_describe_does_not_require_simulation_arguments(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    args = main_module.create_arg_parser().parse_args(['simulate', '--describe'])
    monkeypatch.setattr(simulator, 'describe_simulator', lambda: {'schema_version': 1, 'package_version': 'test'})
    main_module.exec_simulate(**vars(args))
    assert json.loads(capsys.readouterr().out) == {'schema_version': 1, 'package_version': 'test'}


def test_cli_rejects_invalid_events_with_nonzero_exit_and_evidence(tmp_path: Path) -> None:
    design, inputs = _design(tmp_path), _stimulus(tmp_path, [])
    process = subprocess.run(
        [
            sys.executable,
            '-m',
            'kcirct',
            'simulate',
            str(design),
            '--top-module',
            'Demo',
            '--inputs',
            str(inputs),
            '--output',
            str(tmp_path / 'wave.vcd'),
            '--work-dir',
            str(tmp_path / 'run'),
        ],
        capture_output=True,
        text=True,
        timeout=10,
    )
    assert process.returncode == 1
    assert json.loads(process.stdout)['stage'] == 'validation'
    assert '非空事件数组' in (tmp_path / 'run' / 'error.txt').read_text()


def _trace_index(work: Path) -> tuple[RunManifest, list[StateIndexEntry], list[DumpIndexEntry]]:
    manifest = RunManifest.from_json((work / 'trace-run.json').read_text())
    assert manifest.state_index is not None
    index = work / manifest.state_index.path
    assert hashlib.sha256(index.read_bytes()).hexdigest() == manifest.state_index.sha256
    entries = [json.loads(line) for line in index.read_text().splitlines()]
    states = [StateIndexEntry.from_dict(entry) for entry in entries if entry['phase'] != 'dump']
    dumps = [DumpIndexEntry.from_dict(entry) for entry in entries if entry['phase'] == 'dump']
    for artifact in manifest.artifacts.values():
        path = work / artifact.path
        assert path.stat().st_size == artifact.size_bytes
        assert hashlib.sha256(path.read_bytes()).hexdigest() == artifact.sha256
        if artifact.compression == 'gzip':
            raw = gzip.decompress(path.read_bytes())
            assert hashlib.sha256(raw).hexdigest() == artifact.uncompressed_sha256
            assert len(raw) == artifact.uncompressed_size_bytes
    return manifest, states, dumps


@pytest.mark.parametrize('keep_states', [False, True])
def test_trace_index_binds_real_state_positions_and_retention(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, keep_states: bool
) -> None:
    definition, parser, calls = _fake_backend(tmp_path, monkeypatch)
    work = tmp_path / 'run'
    result = simulator.simulate(
        _design(tmp_path),
        top_module='Demo',
        inputs_file=_stimulus(tmp_path),
        output=tmp_path / 'wave.vcd',
        work_dir=work,
        definition_dir=definition,
        parser=parser,
        keep_states=keep_states,
    )
    assert result['status'] == 'pass'
    manifest, states, dumps = _trace_index(work)
    assert manifest.run_id == result['run_id']
    assert manifest.completion.status == 'completed'
    assert manifest.identities['semantics_binding']['status'] == 'unverified'
    assert len(calls) == 4
    assert [state.state_id for state in states] == [
        'setup',
        'event-0.eval-1',
        'event-0.eval-2',
        'event-1.eval-1',
        'event-1.eval-2',
    ]
    assert [state.predecessor for state in states] == [None] + [state.state_id for state in states[:-1]]
    assert all(state.completion.status == 'completed' for state in states)
    assert [(dump.state_id, dump.evaluation, dump.time) for dump in dumps] == [
        ('event-0.eval-2', 2, 0),
        ('event-1.eval-2', 2, 5),
    ]
    assert [dump.values['Demo/q'].unsigned for dump in dumps] == [7, 19]
    assert all(state.content_sha256 is not None for state in states)
    assert all('simulated.' not in ref.path for ref in manifest.artifacts.values())
    if keep_states:
        assert all(state.retention == 'retained' for state in states)
    else:
        assert [state.retention for state in states] == ['retained'] + ['not_retained'] * 3 + ['retained']
        assert all(state.artifact is None for state in states[1:-1])
        assert states[-1].artifact is not None
        assert manifest.artifacts[states[-1].artifact].path == 'last-state.kore'


def test_failed_terminal_check_is_archived_without_completion(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    definition, parser, _ = _fake_backend(tmp_path, monkeypatch)
    original = simulator._check_finished

    def unfinished(state: Path) -> None:
        if state.name.startswith('simulated.'):
            raise RuntimeError('保留未清空的 current cell')
        original(state)

    monkeypatch.setattr(simulator, '_check_finished', unfinished)
    work = tmp_path / 'run'
    result = simulator.simulate(
        _design(tmp_path),
        top_module='Demo',
        inputs_file=_stimulus(tmp_path),
        output=tmp_path / 'wave.vcd',
        work_dir=work,
        definition_dir=definition,
        parser=parser,
        keep_states=True,
    )
    assert result['status'] == 'execution_error'
    manifest, states, dumps = _trace_index(work)
    assert manifest.completion.status == 'incomplete'
    assert manifest.state_coverage['calls_completed'] == 0
    assert manifest.state_coverage['calls_returned'] == 1
    assert states[-1].artifact is not None
    assert states[-1].completion.status == 'incomplete'
    assert not dumps


@pytest.mark.parametrize('keep_states', [False, True])
def test_timeout_binds_last_state_to_previous_successful_evaluation(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, keep_states: bool
) -> None:
    definition, parser, _ = _fake_backend(tmp_path, monkeypatch, timeout_at=2)
    work = tmp_path / 'run'
    result = simulator.simulate(
        _design(tmp_path),
        top_module='Demo',
        inputs_file=_stimulus(tmp_path),
        output=tmp_path / 'wave.vcd',
        work_dir=work,
        definition_dir=definition,
        parser=parser,
        keep_states=keep_states,
    )
    assert result['status'] == 'timeout'
    manifest, states, dumps = _trace_index(work)
    assert states[-1].state_id == 'event-0.eval-2'
    assert states[-1].completion.status == 'not_checked'
    assert states[-1].retention == 'missing'
    assert states[-2].state_id == 'event-0.eval-1'
    assert states[-2].artifact is not None
    assert manifest.artifacts[states[-2].artifact].path == (
        'states/event-0000.eval-1.kore.gz' if keep_states else 'last-state.kore'
    )
    assert manifest.state_coverage['status'] == 'partial'
    assert manifest.state_coverage['evaluations']['missing'] == 1
    assert manifest.state_coverage['calls_completed'] == 1
    assert not dumps


def test_run_identity_is_unique_and_capture_does_not_change_evaluation_calls(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    definition, parser, calls = _fake_backend(tmp_path, monkeypatch)
    design, stimulus = _design(tmp_path), _stimulus(tmp_path)
    results = [
        simulator.simulate(
            design,
            top_module='Demo',
            inputs_file=stimulus,
            output=tmp_path / f'wave-{index}.vcd',
            work_dir=tmp_path / f'run-{index}',
            definition_dir=definition,
            parser=parser,
            keep_states=keep,
        )
        for index, keep in enumerate((False, True))
    ]
    assert all(result['status'] == 'pass' for result in results)
    assert results[0]['run_id'] != results[1]['run_id']
    assert calls[:4] == calls[4:]
    assert results[0]['last_state_sha256'] == results[1]['last_state_sha256']
    # VCD 的生成日期不是仿真行为；比较完整采样序列。
    waves = [VCDVCD(str(tmp_path / f'wave-{index}.vcd')) for index in range(2)]
    assert waves[0].signals == waves[1].signals
    assert all(waves[0][name].tv == waves[1][name].tv for name in waves[0].signals)


def test_interrupted_manifest_publication_never_publishes_false_completion(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    definition, parser, _ = _fake_backend(tmp_path, monkeypatch)
    atomic = simulator._atomic_text

    def interrupted(path: Path, text: str) -> None:
        if path.name == 'trace-run.json' and json.loads(text)['completion']['status'] == 'completed':
            raise OSError('模拟原子发布前中断')
        atomic(path, text)

    monkeypatch.setattr(simulator, '_atomic_text', interrupted)
    work = tmp_path / 'run'
    result = simulator.simulate(
        _design(tmp_path),
        top_module='Demo',
        inputs_file=_stimulus(tmp_path),
        output=tmp_path / 'wave.vcd',
        work_dir=work,
        definition_dir=definition,
        parser=parser,
    )
    assert result['status'] == 'execution_error'
    assert result['stage'] == 'trace_export'
    manifest = RunManifest.from_json((work / 'trace-run.json').read_text())
    assert manifest.completion.status != 'completed'
    assert manifest.state_index is not None
    assert hashlib.sha256((work / manifest.state_index.path).read_bytes()).hexdigest() != manifest.state_index.sha256


def test_default_capture_publishes_index_with_linear_total_bytes(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    definition, parser, _ = _fake_backend(tmp_path, monkeypatch)
    atomic = simulator._atomic_text
    published: list[int] = []

    def record(path: Path, text: str) -> None:
        if path.name == 'trace-states.jsonl':
            published.append(len(text.encode()))
        atomic(path, text)

    monkeypatch.setattr(simulator, '_atomic_text', record)
    events = [{'time': index, 'inputs': {'clk': index % 2, 'a': index}} for index in range(32)]
    work = tmp_path / 'run'
    result = simulator.simulate(
        _design(tmp_path),
        top_module='Demo',
        inputs_file=_stimulus(tmp_path, events),
        output=tmp_path / 'wave.vcd',
        work_dir=work,
        definition_dir=definition,
        parser=parser,
    )
    assert result['status'] == 'pass'
    # 多次求值不能反复重写完整历史，使默认采集成本变成事件数的平方。
    assert sum(published) <= 2 * (work / 'trace-states.jsonl').stat().st_size
