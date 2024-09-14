import logging
import subprocess
from pathlib import Path
from typing import Final

_LOGGER: Final = logging.getLogger(__name__)
_LOG_FORMAT: Final = '%(levelname)s %(asctime)s %(name)s - %(message)s'


def kbuild_definition_dir(target: str) -> Path:
    proc_result = subprocess.run(
        ['poetry', 'run', 'kbuild', 'which', target],
        capture_output=True,
    )
    if proc_result.returncode:
        _LOGGER.critical(
            f'Could not find kbuild definition for target {target}. Run kbuild kompile {target}, or specify --definition-dir.'
        )
        exit(proc_result.returncode)
    else:
        return Path(proc_result.stdout.splitlines()[0].decode())


def check_dir_path(path: Path) -> None:
    path = path.resolve()
    if not path.exists():
        raise ValueError(f'Directory does not exist: {path}')
    if not path.is_dir():
        raise ValueError(f'Path is not a directory: {path}')


def dir_path(s: str | Path) -> Path:
    path = Path(s)
    check_dir_path(path)
    return path


def check_file_path(path: Path) -> None:
    path = path.resolve()
    if not path.exists():
        raise ValueError(f'File does not exist: {path}')
    if not path.is_file():
        raise ValueError(f'Path is not a file: {path}')


def file_path(s: str) -> Path:
    path = Path(s)
    check_file_path(path)
    return path
