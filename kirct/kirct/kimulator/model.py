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
from pyk.cterm import CTerm
from pyk.kast.manip import cell_label_to_var_name, flatten_label

# todo: make them easy to configure
# Change the following codes when something in the semantics changed.
# - result_cell and codes below <- cell storing the results

CONTROL_TEMPLATE: Final = """circtTest @{module_name}({inputs})"""
KORE_CONTROL_TEMPLATE: Final = """App(symbol="Lbl'-LT-'circt-control'-GT-'", sorts=(), args=(App(symbol='kseq', sorts=(), args=(App(symbol='inj', sorts=(SortApp(name='SortControl', sorts=()), SortApp(name='SortKItem', sorts=())), args=(App(symbol="LblcirctTest-hw'Stop'module'UndsLParUndsRParUnds'CIRCT'Unds'Control'Unds'SymbolRefId'Unds'Values", sorts=(), args=(DV(sort=SortApp(name='SortSymbolRefId', sorts=()), value=String(value='@{module_name}')), {inputs})),)), App(symbol='dotk', sorts=(), args=()))),))"""
KORE_INPUTS_TEMPLATE: Final = """App(symbol="Lbl'UndsCommUndsUnds'CIRCT-SYNTAX-CORE'Unds'Values'Unds'Value'Unds'Values", sorts=(), args=(App(symbol='inj', sorts=(SortApp(name='SortInt', sorts=()), SortApp(name='SortValue', sorts=())), args=(DV(sort=SortApp(name='SortInt', sorts=()), value=String(value='{input}')),)), {inputs}))"""
KORE_INPUT_STOP: Final = """App(symbol="Lbl'Stop'List'LBraQuotUndsCommUndsUnds'CIRCT-SYNTAX-CORE'Unds'Values'Unds'Value'Unds'Values'QuotRBraUnds'Values", sorts=(), args=())"""
KORE_CONTROL_TO_REPLACE = """App(symbol="Lbl'-LT-'circt-control'-GT-'", sorts=(), args=(App(symbol='dotk', sorts=(), args=()),))"""


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
                             check=True)
            self.context.state = KoreParser(proc_res.stdout).pattern()
        else:
            # todo: optimize this
            # obtain the kore presentation of control
            ctrl_kore = self.context.kprint._expression_kast(ctrl,
                                                             input=KAstInput.PROGRAM,
                                                             output=KAstOutput.KORE,
                                                             sort='Control').stdout
            empty_ctrl_cell = eval(KORE_CONTROL_TO_REPLACE)
            # todo: optimize this
            # put control into context.state
            # # construct control
            index = len(args) - 1
            inputs = KORE_INPUT_STOP
            while index >= 0:
                inputs = KORE_INPUTS_TEMPLATE.format(input=args[index], inputs=inputs)
                index -= 1
            control_temp0 = KORE_CONTROL_TEMPLATE.format(module_name=self.module_name, inputs=inputs)
            # control_temp1 = _kast(definition_dir=self.context.krun.definition_dir,
            #                       input=KAstInput.PROGRAM,
            #                       output=KAstOutput.KORE,
            #                       expression='circtTest @Adder(0,0,1,2)',
            #                       sort='Control'
            #                       ).stdout
            # control_pattern = eval(control)
            # todo: frozen App is not convenient to use
            # # update circt-control cell
            state_text = str(self.context.state)
            state_text = state_text.replace(KORE_CONTROL_TO_REPLACE, ctrl_kore, 1)
            self.context.state = self.context.krun.run_pattern(pattern=eval(state_text))
            print()
            # todo: 没有执行，怀疑是语义的问题。通过85-95行基本排除run_pattern导致的问题，大概率是语义的问题。
            # with NamedTemporaryFile(mode='w') as f:
            #     eval(state_text).write(f)
            #     f.write('\n')
            #     f.flush()
            #     proc_res = _krun(input_file=Path(f.name),
            #                      definition_dir=self.context.krun.definition_dir,
            #                      output=KRunOutput.KORE,
            #                      term=True,
            #                      parser='cat',
            #                      check=True)
            #     self.context.state = KoreParser(proc_res.stdout).pattern()
            # circt_control = get_cell(self.context.state, [
            #     ('circt', CellType.NORMAL),
            #     ('circt-control', CellType.NORMAL)])
            # circt_control.args = target_control.args

            # simple_control = CONTROL_TEMPLATE.format(module_name=self.module_name, inputs=", ".join(args))
            # proc_res_0 = _krun(input_file=Path(self.source_file),
            #                    definition_dir=self.context.krun.definition_dir,
            #                    output=KRunOutput.KORE,
            #                    cmap={'Control': simple_control},
            #                    depth=0,
            #                    check=True)
            # proc_res = _krun(input_file=Path(self.source_file),
            #                  definition_dir=self.context.krun.definition_dir,
            #                  output=KRunOutput.KORE,
            #                  cmap={'Control': simple_control},
            #                  check=True)
        # find circt-output cell
        state_cterm = CTerm.from_kast(self.context.kprint.kore_to_kast(self.context.state))
        result_cell = state_cterm.cells[cell_label_to_var_name('<result>')]
        result_values = flatten_label('_|->_', flatten_label('ListItem', result_cell)[-1])
        kv_result = result_cell
        # setup outputs for context
        # kore_print(pattern=kast_output,
        #            definition_dir=self.context.krun.definition_dir,
        #            output=PrintOutput.KORE)
        # for kv in kast_output['args']:
        #     key = kv['args'][0]['token']
        #     value = int(kv['args'][1]['args'][1]['token'])
        #     # todo: remove this binding from %0 to io_out
        #     if key == '%0':
        #         key = 'io_out'
        #     self.context.signals[key].signal_value = value
