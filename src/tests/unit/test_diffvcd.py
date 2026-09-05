from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import pytest

from tests.integration.arc_test import DIFFVCD


def _write_vcd(
    path: Path,
    transitions: list[tuple[int, str]],
    end_time: int = 20,
    *,
    extra_signals: dict[str, list[tuple[int, str]]] | None = None,
) -> None:
    signals = {'signal': transitions, **(extra_signals or {})}
    declarations = '\n'.join(f'$var wire 1 {chr(33 + index)} {name} $end' for index, name in enumerate(signals))
    events = sorted(
        (time, chr(33 + index), value) for index, values in enumerate(signals.values()) for time, value in values
    )
    changes = '\n'.join(f'#{time}\n{value}{identifier}' for time, identifier, value in events)
    path.write_text(
        '$timescale 1ns $end\n'
        '$scope module TOP $end\n'
        f'{declarations}\n'
        '$upscope $end\n'
        '$enddefinitions $end\n'
        f'{changes}\n'
        f'#{end_time}\n',
        encoding='utf-8',
    )


def _run_diff(first: Path, second: Path, *arguments: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(DIFFVCD), str(first), str(second), *arguments],
        capture_output=True,
        text=True,
    )


@pytest.mark.parametrize('arguments', [(), ('--ignore-missing-signals',)])
def test_after_compares_value_already_stable_at_boundary(tmp_path: Path, arguments: tuple[str, ...]) -> None:
    first = tmp_path / 'first.vcd'
    second = tmp_path / 'second.vcd'
    _write_vcd(first, [(0, '0'), (10, '1')])
    _write_vcd(second, [(0, '0')])

    result = _run_diff(first, second, '--after', '20', *arguments)

    assert result.returncode == 1
    assert '20  1  0  TOP.signal' in result.stdout


def test_after_rejects_non_overlapping_time_window(tmp_path: Path) -> None:
    first = tmp_path / 'first.vcd'
    second = tmp_path / 'second.vcd'
    _write_vcd(first, [(0, '0')], end_time=2)
    _write_vcd(second, [(0, '0')], end_time=2)

    result = _run_diff(first, second, '--after', '20')

    assert result.returncode == 1
    assert 'VCD 时间窗口没有交集' in result.stderr


@pytest.mark.parametrize('reverse', [False, True])
def test_ignore_missing_signals_skips_unrecorded_signals_only_when_enabled(tmp_path: Path, reverse: bool) -> None:
    missing = tmp_path / 'missing.vcd'
    recorded = tmp_path / 'recorded.vcd'
    _write_vcd(missing, [(0, '0')], extra_signals={'missing': []})
    _write_vcd(recorded, [(0, '0')], extra_signals={'missing': [(0, '1')]})
    first, second = (recorded, missing) if reverse else (missing, recorded)

    default_result = _run_diff(first, second)
    ignored_result = _run_diff(first, second, '--ignore-missing-signals', '--verbose')

    assert default_result.returncode == 1
    assert 'TOP.missing' in default_result.stdout
    assert ignored_result.returncode == 0
    assert ignored_result.stdout == ''
    assert f'跳过信号 TOP.missing：以下文件中没有采样值：{missing}' in ignored_result.stderr


@pytest.mark.parametrize('arguments', [(), ('--ignore-missing-signals',)])
@pytest.mark.parametrize('reverse', [False, True])
def test_signals_declared_in_one_file_remain_ignored(tmp_path: Path, arguments: tuple[str, ...], reverse: bool) -> None:
    first = tmp_path / 'first.vcd'
    second = tmp_path / 'second.vcd'
    _write_vcd(first, [(0, '0')], extra_signals={'extra': [(0, '1')]})
    _write_vcd(second, [(0, '0')])
    if reverse:
        first, second = second, first

    result = _run_diff(first, second, *arguments)

    assert result.returncode == 0
    assert result.stdout == ''


def test_ignore_missing_signals_still_reports_value_differences(tmp_path: Path) -> None:
    first = tmp_path / 'first.vcd'
    second = tmp_path / 'second.vcd'
    _write_vcd(first, [(0, '0'), (10, '1')], extra_signals={'missing': []})
    _write_vcd(second, [(0, '0')], extra_signals={'missing': [(0, '1')]})

    result = _run_diff(first, second, '--ignore-missing-signals')

    assert result.returncode == 1
    assert result.stdout == '10  1  0  TOP.signal\n'


@pytest.mark.parametrize('arguments', [(), ('--before', '5')])
def test_ignore_missing_signals_preserves_late_initialization_differences(
    tmp_path: Path, arguments: tuple[str, ...]
) -> None:
    first = tmp_path / 'first.vcd'
    second = tmp_path / 'second.vcd'
    _write_vcd(first, [(10, '1')])
    _write_vcd(second, [(0, '1')])

    result = _run_diff(first, second, '--ignore-missing-signals', *arguments)

    assert result.returncode == 1
    assert result.stdout == '0  None  1  TOP.signal\n'


@pytest.mark.parametrize('second_values', [[], [(0, '1')]])
def test_ignore_missing_signals_rejects_comparison_when_all_signals_are_skipped(
    tmp_path: Path, second_values: list[tuple[int, str]]
) -> None:
    first = tmp_path / 'first.vcd'
    second = tmp_path / 'second.vcd'
    _write_vcd(first, [])
    _write_vcd(second, second_values)

    result = _run_diff(first, second, '--ignore-missing-signals')

    assert result.returncode == 1
    assert '没有可比较的信号' in result.stderr


def test_ignore_missing_signals_skips_signal_unrecorded_in_both_files(tmp_path: Path) -> None:
    first = tmp_path / 'first.vcd'
    second = tmp_path / 'second.vcd'
    for path in (first, second):
        _write_vcd(path, [(0, '1')], extra_signals={'missing': []})

    result = _run_diff(first, second, '--ignore-missing-signals', '--verbose')

    assert result.returncode == 0
    assert f'跳过信号 TOP.missing：以下文件中没有采样值：{first}, {second}' in result.stderr


def test_list_includes_common_declarations_without_samples(tmp_path: Path) -> None:
    first = tmp_path / 'first.vcd'
    second = tmp_path / 'second.vcd'
    _write_vcd(first, [], extra_signals={'extra': [(0, '1')]})
    _write_vcd(second, [(0, '1')])

    result = _run_diff(first, second, '--ignore-missing-signals', '--list')

    assert result.returncode == 0
    assert result.stdout == 'TOP.signal\n'


@pytest.mark.parametrize('reverse', [False, True])
def test_default_preserves_missing_value_and_zero_compatibility(tmp_path: Path, reverse: bool) -> None:
    first = tmp_path / 'first.vcd'
    second = tmp_path / 'second.vcd'
    _write_vcd(first, [])
    _write_vcd(second, [(0, '0')])
    if reverse:
        first, second = second, first

    result = _run_diff(first, second)

    assert result.returncode == 0
