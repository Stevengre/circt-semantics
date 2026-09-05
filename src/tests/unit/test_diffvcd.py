from __future__ import annotations

import subprocess
import sys
from pathlib import Path

from tests.integration.arc_test import DIFFVCD


def _write_vcd(path: Path, transitions: list[tuple[int, str]], end_time: int = 20) -> None:
    changes = '\n'.join(f'#{time}\n{value}!' for time, value in transitions)
    path.write_text(
        '$timescale 1ns $end\n'
        '$scope module TOP $end\n'
        '$var wire 1 ! signal $end\n'
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


def test_after_compares_value_already_stable_at_boundary(tmp_path: Path) -> None:
    first = tmp_path / 'first.vcd'
    second = tmp_path / 'second.vcd'
    _write_vcd(first, [(0, '0'), (10, '1')])
    _write_vcd(second, [(0, '0')])

    result = _run_diff(first, second, '--after', '20')

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
