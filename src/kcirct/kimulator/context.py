from __future__ import annotations

import copy
import logging
import shutil
from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING, Final

from pyk.ktool.kprint import KPrint
from pyk.ktool.krun import KRun

from ..utils import kbuild_definition_dir

if TYPE_CHECKING:
    from pyk.kore.syntax import Pattern


_LOGGER: Final = logging.getLogger(__name__)
_changed_signal_history = {}
_changed_signal = []


class Signal:
    name: str
    abbrev: str
    mlir_gen_name: str
    is_input: bool
    num_bits: int
    signal_type: str
    _signal_value: int

    _SIGNAL_TYPE: Final = {'input', 'output', 'register', 'memory', 'wire'}

    def __init__(
        self,
        name: str = '',
        abbrev: str = '',
        mlir_gen_name: str = '',
        is_input: bool = False,
        num_bits: int = 1,
        signal_type: str = 'wire',
        signal_value: int = 0,
    ):
        self.name = name
        self.abbrev = abbrev
        self.mlir_gen_name = mlir_gen_name
        self.is_input = is_input
        self.num_bits = num_bits
        self.signal_type = signal_type
        self._signal_value = signal_value
        return

    @property
    def signal_value(self) -> int:
        return self._signal_value

    @signal_value.setter
    def signal_value(self, value: int) -> None:
        if value != self._signal_value:
            self._signal_value = value
            _changed_signal.append(copy.copy(self))


class Abbrev:
    _rest: int = 0

    @classmethod
    def gen(cls) -> str:
        cls._rest += 1
        t: int = cls._rest
        abbrev = ''
        while t != 0:
            c = (t % 84) + 33
            if c >= ord('0'):
                c += 10
            abbrev += chr(int(c))
            t //= 84
        return abbrev


class KimulatorContext:
    trace_on: bool
    sim_time: int
    krun: KRun
    kprint: KPrint
    history_dir: Path  # filename(sim_time.json): mlir_gen_name -> Signal
    state: Pattern | None
    signals: dict[str, Signal]  # mlir_gen_name -> Signal
    _rest: int = 0

    def __init__(self) -> None:
        self.trace_on = False
        self.sim_time = 0
        use_dir = Path(__file__).parent.joinpath('temp', datetime.now().strftime('%Y%m%d%H%M%S%f') + '_krun_temp_dir')
        history_dir = Path(__file__).parent.joinpath('temp', datetime.now().strftime('%Y%m%d%H%M%S%f') + '_history')

        use_dir.mkdir(parents=True, exist_ok=True)
        history_dir.mkdir(parents=True, exist_ok=True)
        self.krun = KRun(definition_dir=kbuild_definition_dir('llvm'), use_directory=use_dir)
        self.kprint = KPrint(definition_dir=kbuild_definition_dir('llvm'), use_directory=use_dir)
        self.history_dir = history_dir
        self.state = None
        self.signals = {}
        return

    def __enter__(self) -> KimulatorContext:
        return self

    def __exit__(self, exc_type, exc_value, traceback) -> None:  # type: ignore
        # 在退出时，删除 history_dir
        shutil.rmtree(self.krun.use_directory, ignore_errors=True)  # type: ignore
        shutil.rmtree(self.history_dir, ignore_errors=True)  # type: ignore

    def __del__(self) -> None:
        # 在删除时，删除 history_dir
        shutil.rmtree(self.krun.use_directory, ignore_errors=True)  # type: ignore
        shutil.rmtree(self.history_dir, ignore_errors=True)  # type: ignore

    def trace_ever_on(self, trace_ever_on: bool) -> None:
        self.trace_on = trace_ever_on
        return

    def time(self) -> int:
        return self.sim_time

    def time_inc(self, time_inc: int) -> None:
        _changed_signal_history[self.sim_time] = copy.deepcopy(_changed_signal)
        _changed_signal.clear()
        self.sim_time += time_inc
        return
