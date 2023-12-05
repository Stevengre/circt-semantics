from .context import KimulatorContext, Signal
from pyk.ktool.krun import _krun, KRunOutput
from pathlib import Path
from pyk.kore.parser import KoreParser
from typing import Final

CONTROL_TEMPLATE: Final = """circtTest-hw.module @{module_name}({inputs})"""


class KimulatorModel:
    module_name: str
    source_file: str
    signals: dict[str, Signal] = {}  # name -> Signal
    # todo: allow children
    context: KimulatorContext | None

    def __init__(self,
                 module_name: str = '',
                 source_file: str = '',
                 signals=None,
                 context: KimulatorContext = None):
        if signals is None:
            signals = {}
        self.module_name = module_name
        self.source_file = source_file
        self.signals = signals
        self.prev_signals = {}
        self.context = context
        return

    def __getattr__(self, name: str):
        if name in self.signals:
            return self.signals[name].signal_value
        else:
            raise AttributeError(f"'{type(self).__name__}' object has no attribute '{name}'")

    def __setattr__(self, name: str, value: int):
        if name in self.signals:
            self.signals[name].signal_value = value
        else:
            super().__setattr__(name, value)

    def get_signal(self, signal: str) -> Signal:
        return self.signals[signal]

    def eval(self):
        # krun --definition /Users/steven/Desktop/Projects/circt-semantics/kirct/kdist/v6.1.7-0-g6c5492b3df/llvm
        # /Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/adder.generic.mlir
        # -cControl="circtTest-hw.module @Adder(0, 0, 2, 6)"
        inputs = ""
        for signal in self.signals.values():
            if signal.is_input:
                inputs += str(signal.signal_value) + ", "
        inputs = inputs[:-2]
        control = CONTROL_TEMPLATE.format(module_name=self.module_name, inputs=inputs)
        proc_res = _krun(input_file=Path(self.source_file),
                         definition_dir=self.context.krun.definition_dir,
                         output=KRunOutput.PRETTY,
                         cmap={'Control': control},
                         check=True)
        print(proc_res.stdout)
        # self.context.state = KoreParser(proc_res.stdout).pattern()
        pass
        # if self.context.state is None:
        #
        #     pass
        # else:
        #     pass
        # self.context.krun.run()


