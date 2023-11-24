from .context import KimulatorContext
from typing import Final


class Signal:
    name: str
    abbrev: str
    mlir_gen_name: str
    is_input: bool
    signal_type: str
    signal_value: int

    _SIGNAL_TYPE: Final = {'input', 'output', 'register', 'memory', 'wire'}

    def __init__(self, name: str, abbrev: str, mlir_gen_name: str, is_input: bool, signal_type: str, signal_value: int):
        self.name = name
        self.abbrev = abbrev
        self.mlir_gen_name = mlir_gen_name
        self.is_input = is_input
        self.signal_type = signal_type
        self.signal_value = signal_value
        return


class KimulatorModel:
    module_name: str
    source_file: str
    signals: dict[str, Signal]
    # prev_signals: dict[int, dict[str, Signal]]
    context: KimulatorContext
    _rest: int = 0
    _sim_time: int = -1

    def __init__(self, module_name: str, source_file: str, signals: dict[str, Signal], context: Context):
        self.module_name = module_name
        self.source_file = source_file
        self.signals = signals
        self.prev_signals = {}
        self.context = context
        return

    def set(self, signal: str, value: int):
        self.signals[signal].signal_value = value
        return

    def get(self, signal: str) -> int:
        return self.signals[signal].signal_value

    def get_signal(self, signal: str) -> Signal:
        return self.signals[signal]

    def gen_abbrev(self):
        self._rest += 1
        t = self._rest
        abbrev = ""
        while t != 0:
            c = (t % 84) + 33
            if c >= ord('0'):
                c += 10
            abbrev += chr(c)
            t /= 84
        return abbrev

    def eval(self):
        if self.context.prev_pattern is None:

            pass
        else:
            pass
        self.context.krun.run()


