"""采集只归档已有编译来源记录，不从安装包倒填构建关联。"""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from kcirct._simulate import _TraceCapture
from kcirct.kdist.build_record import BUILD_RECORD_NAME

if TYPE_CHECKING:
    from pathlib import Path


@pytest.mark.parametrize('has_record', [False, True])
def test_capture_preserves_existing_build_record(tmp_path: Path, has_record: bool) -> None:
    """没有记录时保持缺失，有记录时保存原字节，后续构建不改变采集副本。"""
    work = tmp_path / 'run'
    work.mkdir()
    definition = tmp_path / 'definition'
    definition.mkdir()
    for name in ('definition.kore', 'compiled.bin', 'backend.txt', 'interpreter'):
        (definition / name).write_text('test output')
    for name in ('design.generic.mlir', 'inputs.json', 'parser'):
        (work / name).write_text('test input')
    if has_record:
        (definition / BUILD_RECORD_NAME).write_text('{"original": "build-time bytes"}')
    capture = _TraceCapture(work, 'Demo', False, 2)
    capture.configure(
        {
            'ports': {'inputs': [], 'outputs': []},
            'timescale': '1ns',
            'evaluations_per_input': 2,
            'events_total': 0,
            'package_version': 'test',
            'kframework_version': 'test',
        },
        definition,
        work / 'parser',
    )
    key = 'definition/' + BUILD_RECORD_NAME
    assert (key in capture.artifacts) == has_record
    if has_record:
        (definition / BUILD_RECORD_NAME).unlink()
        ref = capture.artifacts[key]
        assert ref.role == 'build_record'
        assert (work / ref.path).read_text() == '{"original": "build-time bytes"}'
