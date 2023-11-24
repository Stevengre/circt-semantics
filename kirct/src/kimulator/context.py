from pyk.ktool.krun import KRun
from datetime import datetime
from ..utils import kbuild_definition_dir, check_file_path
from pathlib import Path
import shutil
from pyk.kore.syntax import Pattern
import logging
from typing import Final
import subprocess as sp
from pyk.kore.parser import KoreParser

_LOGGER: Final = logging.getLogger(__name__)


class KimulatorContext:
    traceOn: bool
    sim_time: int
    krun: KRun
    history_dir: Path
    prev_pattern: Pattern | None

    def __init__(self):
        self.traceOn = False
        self.sim_time = 0
        self.krun = KRun(definition_dir=kbuild_definition_dir('llvm'),
                         use_directory=Path(__file__).parent / 'temp' / datetime.now().strftime('%Y%m%d%H%M%S%f') + '_krun_temp_dir')
        self.history_dir = Path(__file__).parent / 'temp' / datetime.now().strftime('%Y%m%d%H%M%S%f') + '_history'
        self.prev_pattern = None
        return

    def __enter__(self):
        # 在创建实例时新建 history_dir
        self.history_dir.mkdir(parents=True, exist_ok=True)
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        # 在退出时删除 history_dir
        shutil.rmtree(self.history_dir, ignore_errors=True)

    def trace_ever_on(self, trace_ever_on: bool):
        self.traceOn = trace_ever_on
        return

    def time(self) -> int:
        return self.sim_time

    def time_inc(self, time_inc: int):
        self.sim_time += time_inc
        return

    def init_pattern(self, source: Path):
        if check_file_path(source):
            args = ['kast', '--definition', str(self.krun.definition_dir),
                    '--input', 'program', str(source), '--output', 'kore']
            try:
                proc_res = sp.run(
                    args,
                    capture_output=True,
                    shell=True,
                    check=True,
                )
                self.prev_pattern = KoreParser(proc_res.stdout.decode('utf-8')).pattern()
            except sp.CalledProcessError as err:
                raise RuntimeError(
                    f'Command kast exited with code {err.returncode} for: {source}', err.stdout, err.stderr
                ) from err
        else:
            _LOGGER.error(f'File does not exist: {source}')
        return
