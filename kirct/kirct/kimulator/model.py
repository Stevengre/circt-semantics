from .context import KimulatorContext, Signal
from typing import Final


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


    # def eval(self):
    #     if self.context.state is None:
    #
    #         pass
    #     else:
    #         pass
    #     self.context.krun.run()


