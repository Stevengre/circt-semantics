from __future__ import annotations

from pathlib import Path
from typing import Final

from .context import KimulatorContext, Signal  # noqa

# if TYPE_CHECKING:
#     pass


# todo: make them easy to configure
# Change the following codes when something in the semantics changed.
# - result_cell and codes below <- cell storing the results

CONTROL_TEMPLATE: Final = """circtTest @{module_name}({inputs})"""
KORE_CONTROL_TO_REPLACE = (
    """App(symbol="Lbl'-LT-'circt-control'-GT-'", sorts=(), args=(App(symbol='dotk', sorts=(), args=()),))"""
)
KORE_K_TO_REPLACE = """App(symbol="Lbl'-LT-'k'-GT-'", sorts=(), args=(App(symbol='kseq', sorts=(), args=(App(symbol='inj', sorts=(SortApp(name='SortCtrl', sorts=()), SortApp(name='SortKItem', sorts=())), args=(App(symbol="Lbldone'Unds'CTRL'Unds'Ctrl", sorts=(), args=()),)), App(symbol='dotk', sorts=(), args=()))),))"""
KORE_K_EXPECTED = """App(symbol="Lbl'-LT-'k'-GT-'", sorts=(), args=(App(symbol='kseq', sorts=(), args=(App(symbol='inj', sorts=(SortApp(name='SortCtrl', sorts=()), SortApp(name='SortKItem', sorts=())), args=(App(symbol="Lblcirct'Unds'CTRL'Unds'Ctrl", sorts=(), args=()),)), App(symbol='dotk', sorts=(), args=()))),))"""


class KimulatorModel:
    module_name: str
    source_file: str
    signals: dict[str, Signal] = {}  # name -> Signal
    prev_signals: dict[str, Signal] = {}
    # todo: allow children
    children: dict[str, KimulatorModel] = {}  # instance_name -> KimulatorModel
    context: KimulatorContext | None

    def __init__(
        self,
        module_name: str = '',
        source_file: str = '',
        signals: dict[str, Signal] | None = None,
        children: dict[str, KimulatorModel] | None = None,
        context: KimulatorContext | None = None,
    ):
        if signals is None:
            signals = {}
        if children is None:
            children = {}
        self.module_name = module_name
        self.source_file = source_file
        self.signals = signals
        self.children = children
        self.prev_signals = {}
        self.context = context
        return

    def __getattr__(self, name: str) -> int | AttributeError:
        if name in self.signals:
            return self.signals[name].signal_value
        else:
            raise AttributeError(f"'{type(self).__name__}' object has no attribute '{name}'")

    def __setattr__(self, name: str, value: int) -> None:
        if name in self.signals:
            self.signals[name].signal_value = value
        else:
            super().__setattr__(name, value)

    def get_signal(self, signal: str) -> Signal:
        return self.signals[signal]

    def compile(self) -> None:
        assert self.context is not None
        compiled = self.context.kcirct.compile(Path(self.source_file))
        preprocessed = self.context.kcirct.run_preprocess(compiled)
        setup = self.context.kcirct.run_setup(preprocessed, self.module_name)
        initialized = self.context.kcirct.run_initialize(setup)
        self.context.state = initialized

    def eval(self) -> None:
        assert self.context is not None
        # simulate
        args = []
        for signal in self.signals.values():
            if signal.is_input:
                args.append((signal.signal_value, signal.num_bits))
        assert self.context.state is not None
        self.context.state = self.context.kcirct.run_simulate(self.context.state, args)
        # read outputs
        outputs = self.context.kcirct.read_outputs(self.context.state)
        index = 0
        for signal in self.signals.values():
            if not signal.is_input:
                output_value = outputs[index]
                signal.signal_value = output_value[0]
                index += 1
