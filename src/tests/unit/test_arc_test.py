from pathlib import Path
from typing import Any

import pytest

from kcirct.api import KCIRCT
from tests.integration import arc_test
from tests.integration.arc_test import (
    ARC_TEST_ROOT,
    BOOM_CASE,
    DEFAULT_INPUT_ROOT,
    RISCINATOR_CASE,
    ROCKET_CASES,
    ArcTestResult,
    _compare_vcd,
    _run_event_case,
    get_case,
)
from tests.resources import DATA_PATH


def test_cases_use_consolidated_resource_root() -> None:
    cases = [BOOM_CASE, RISCINATOR_CASE, *ROCKET_CASES.values()]
    for case in cases:
        assert case.mlir_file.is_relative_to(ARC_TEST_ROOT / 'mlir')
        assert case.work_dir.is_relative_to(case.mlir_dir / '.work')


def test_input_root_does_not_reuse_existing_arc_test_submodule() -> None:
    assert DEFAULT_INPUT_ROOT == DATA_PATH / 'kcirct-arc-test' / 'inputs'
    assert DEFAULT_INPUT_ROOT != DATA_PATH / 'arc-test'


def test_default_rocket_case_uses_repository_mlir() -> None:
    case = get_case('rocket')
    assert case == ROCKET_CASES['v1.6-two-edge']
    assert case.mlir_file == ARC_TEST_ROOT / 'mlir' / 'rocket' / 'rocket-small-1.6-drop.mlir'
    assert case.mlir_file != Path('/data/cym/rocket/rocket-small-1.6-drop.mlir')


def test_project_specific_protocol_configuration() -> None:
    assert BOOM_CASE.compare_after == 201
    assert RISCINATOR_CASE.vcd_ignore_patterns == (
        r'^\.rf\.regs_ext\.(R[01]|W0)_(addr|data|en)(\[[0-9]+:[0-9]+\])?$',
        r'^\.writeback\.io_ctrl_wb_en$',
    )
    assert ROCKET_CASES['master'].simulation_calls_per_input == 2
    assert ROCKET_CASES['v1.4'].simulation_calls_per_input == 2
    assert ROCKET_CASES['v1.6'].simulation_calls_per_input == 1
    assert ROCKET_CASES['v1.6-main'].simulation_calls_per_input == 1
    assert ROCKET_CASES['v1.6-two-edge'].simulation_calls_per_input == 2


def test_compare_rejects_vcd_without_samples() -> None:
    result = ArcTestResult(
        cycles=1,
        input_evaluations=1,
        simulation_calls=2,
        vcd_samples=0,
        last_vcd_time=None,
        simulation_runtime=1.0,
        output_vcd=Path('unused.vcd'),
    )

    with pytest.raises(RuntimeError, match='没有采样点'):
        _compare_vcd(RISCINATOR_CASE, result, compare_after=None)


def test_compare_rejects_after_beyond_last_sample() -> None:
    result = ArcTestResult(
        cycles=1,
        input_evaluations=2,
        simulation_calls=2,
        vcd_samples=3,
        last_vcd_time=2,
        simulation_runtime=1.0,
        output_vcd=Path('unused.vcd'),
    )

    with pytest.raises(RuntimeError, match='空窗口'):
        _compare_vcd(BOOM_CASE, result, compare_after=20)


def _fake_event_runner(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, *, missing_after_simulation: bool = False
) -> tuple[KCIRCT, Path, list[tuple[Any, ...]]]:
    monkeypatch.setattr(arc_test, 'MLIR_ROOT', tmp_path)
    get_case('rocket').work_dir.mkdir(parents=True)
    setup_file = tmp_path / 'setup.kore'
    setup_file.write_text('0')
    calls: list[tuple[Any, ...]] = []

    def simulate(input_file: Path, output_file: Path, input_data: Any) -> None:
        step = int(input_file.read_text())
        calls.append(('simulate', step, input_data))
        output_file.write_text(str(step + 1))

    def read_ports(state_file: Path, skip_missing: bool = False) -> dict[str, tuple[int, int]]:
        step = int(state_file.read_text())
        calls.append(('read', step, skip_missing))
        if step == 0 or missing_after_simulation:
            if not skip_missing:
                raise KeyError('RocketSystem/clock')
            return {}
        return {'RocketSystem/clock': (1, 1)}

    class FakeVCD:
        time = 0

        def dump(self, ports: dict[str, tuple[int, int]]) -> None:
            calls.append(('dump', self.time, ports))

        def close(self) -> None:
            calls.append(('close',))

    kcirct = object.__new__(KCIRCT)
    monkeypatch.setattr(kcirct, 'run_simulate_fast', simulate)
    monkeypatch.setattr(kcirct, 'read_ports_fast', read_ports)
    monkeypatch.setattr(arc_test, '_open_vcd', lambda _case: FakeVCD())
    return kcirct, setup_file, calls


def test_rocket_initial_dump_skips_missing_then_samples_after_two_simulations(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    kcirct, setup_file, calls = _fake_event_runner(tmp_path, monkeypatch)
    input_data = [[0, 1], [1, 1]]
    events = [{'vcd_dump': 0}, {'input': input_data}, {'vcd_dump': 1}]

    result = _run_event_case(get_case('rocket'), kcirct, setup_file, events, cycles=None)

    assert calls == [
        ('read', 0, True),
        ('dump', 0, {}),
        ('simulate', 0, input_data),
        ('simulate', 1, input_data),
        ('read', 2, False),
        ('dump', 1, {'RocketSystem/clock': (1, 1)}),
        ('close',),
    ]
    assert (result.cycles, result.input_evaluations, result.simulation_calls) == (1, 1, 2)
    assert (result.vcd_samples, result.last_vcd_time) == (2, 1)


def test_rocket_missing_signal_after_simulation_still_fails_and_closes_vcd(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    kcirct, setup_file, calls = _fake_event_runner(tmp_path, monkeypatch, missing_after_simulation=True)
    input_data = [[0, 1], [1, 1]]
    events = [{'vcd_dump': 0}, {'input': input_data}, {'vcd_dump': 1}]

    with pytest.raises(KeyError, match='RocketSystem/clock'):
        _run_event_case(get_case('rocket'), kcirct, setup_file, events, cycles=None)

    assert calls == [
        ('read', 0, True),
        ('dump', 0, {}),
        ('simulate', 0, input_data),
        ('simulate', 1, input_data),
        ('read', 2, False),
        ('close',),
    ]
