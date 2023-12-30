from .context import KimulatorContext, Signal
from pyk.ktool.krun import _krun, KRunOutput
from pathlib import Path
from pyk.kore.parser import KoreParser
from typing import Final
from enum import Enum
from tempfile import NamedTemporaryFile
from ..kutils import k_symbol, get_cell, CellType
from pyk.kore.syntax import *
from pyk.konvert import _kore_to_kast
from pyk.ktool.kprint import _kast, KAstInput, KAstOutput
from pyk.kore.tools import kore_print, PrintOutput
from pyk.kore.prelude import *
from pyk.cterm import CTerm
from pyk.kast.manip import cell_label_to_var_name, flatten_label

# todo: make them easy to configure
# Change the following codes when something in the semantics changed.
# - result_cell and codes below <- cell storing the results

CONTROL_TEMPLATE: Final = """circtTest @{module_name}({inputs})"""
KORE_CONTROL_TO_REPLACE = """App(symbol="Lbl'-LT-'circt-control'-GT-'", sorts=(), args=(App(symbol='dotk', sorts=(), args=()),))"""
KORE_K_TO_REPLACE = """App(symbol="Lbl'-LT-'k'-GT-'", sorts=(), args=(App(symbol='kseq', sorts=(), args=(App(symbol='inj', sorts=(SortApp(name='SortCtrl', sorts=()), SortApp(name='SortKItem', sorts=())), args=(App(symbol="Lbldone'Unds'CTRL'Unds'Ctrl", sorts=(), args=()),)), App(symbol='dotk', sorts=(), args=()))),))"""
KORE_K_EXPECTED = """App(symbol="Lbl'-LT-'k'-GT-'", sorts=(), args=(App(symbol='kseq', sorts=(), args=(App(symbol='inj', sorts=(SortApp(name='SortCtrl', sorts=()), SortApp(name='SortKItem', sorts=())), args=(App(symbol="Lblcirct'Unds'CTRL'Unds'Ctrl", sorts=(), args=()),)), App(symbol='dotk', sorts=(), args=()))),))"""


class KimulatorModel:
    module_name: str
    source_file: str
    signals: dict[str, Signal] = {}  # name -> Signal
    # todo: allow children
    children = {}  # instance_name -> KimulatorModel
    context: KimulatorContext | None

    def __init__(self,
                 module_name: str = '',
                 source_file: str = '',
                 signals=None,
                 children=None,
                 context: KimulatorContext = None):
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
        args = []
        for signal in self.signals.values():
            if signal.is_input:
                args.append(str(signal.signal_value))
        ctrl = CONTROL_TEMPLATE.format(module_name=self.module_name, inputs=", ".join(args))

        if self.context.state is None:
            proc_res = _krun(input_file=Path(self.source_file),
                             definition_dir=self.context.krun.definition_dir,
                             output=KRunOutput.KORE,
                             cmap={'Control': ctrl},
                             # depth=1,
                             check=True)
            self.context.state = KoreParser(proc_res.stdout).pattern()
        else:
            # todo: optimize this
            # obtain the kore presentation of control
            ctrl_kore = self.context.kprint._expression_kast(ctrl,
                                                             input=KAstInput.PROGRAM,
                                                             output=KAstOutput.KORE,
                                                             sort='Control').stdout
            ctrl_kore = KoreParser(ctrl_kore).pattern()
            expected_ctrl_cell = App(symbol="Lbl'-LT-'circt-control'-GT-'",
                                     sorts=(),
                                     args=(kseq([inj(SortApp('SortControl'), SortApp('SortKItem'), ctrl_kore)]),))

            empty_ctrl_cell = eval(KORE_CONTROL_TO_REPLACE)

            def replace_ctrl(term: Pattern) -> Pattern:
                if term == empty_ctrl_cell:
                    return expected_ctrl_cell
                return term
            state = self.context.state.bottom_up(replace_ctrl)

            k_replace = eval(KORE_K_TO_REPLACE)
            k_expected = eval(KORE_K_EXPECTED)

            def replace_k(term: Pattern) -> Pattern:
                if term == k_replace:
                    return k_expected
                return term
            state = state.bottom_up(replace_k)

            self.context.state = self.context.krun.run_pattern(pattern=state)
        # ------
        # find circt-output cell
        # ------
        # help: observe the result
        # kore_print(pattern=self.context.kprint.kast_to_kore(r_cell), definition_dir=self.context.krun.definition_dir, output='pretty')
        state_cterm = CTerm.from_kast(self.context.kprint.kore_to_kast(self.context.state))
        r_cell = state_cterm.cells[cell_label_to_var_name('<result>')]
        r_curr = flatten_label('_List_', r_cell)[-1]
        r_curr = flatten_label('ListItem', r_curr)[-1]
        r_vals = flatten_label('_List_', r_curr)
        for r_val in r_vals:
            r_flat_li = flatten_label('ListItem', r_val)[0]
            r_flat_re = flatten_label('result(_,_)_CIRCT-SYNTAX-CORE_Result_BareId_TypeValue', r_flat_li)
            key = r_flat_re[0].token
            v = int(flatten_label('TV(_,_)_CIRCT-SYNTAX-CORE_TypeValue_Type_Value', r_flat_re[1])[1].token)
            self.context.signals[key].signal_value = v
