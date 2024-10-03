from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from pathlib import Path


def assert_files_equal(path1: Path, path2: Path, ignore_lines: list[str] | None = None) -> None:
    if ignore_lines is None:
        ignore_lines = []
    with open(path1, 'r') as file1, open(path2, 'r') as file2:
        lines1 = file1.readlines()
        lines2 = file2.readlines()
        for line in ignore_lines:
            lines1 = [line for line in lines1 if line != line]
            lines2 = [line for line in lines2 if line != line]
        if lines1 != lines2:
            diff = [f'- {line}' for line in lines1 if line not in lines2] + [
                f'+ {line}' for line in lines2 if line not in lines1
            ]
            diff_output = '\n'.join(diff)
        else:
            diff_output = ''
        assert lines1 == lines2, f'Files are not equal:\n{diff_output}'
