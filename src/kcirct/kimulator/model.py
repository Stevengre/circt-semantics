from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING, Final

from pyk.cterm import CTerm
from pyk.kast.manip import cell_label_to_var_name, flatten_label
from pyk.kore.parser import KoreParser
from pyk.kore.prelude import inj, kseq
from pyk.kore.syntax import App, SortApp
from pyk.ktool.kprint import KAstInput, KAstOutput
from pyk.ktool.krun import KRunOutput, _krun

from .context import KimulatorContext, Signal  # noqa

if TYPE_CHECKING:
    from pyk.kore.syntax import Pattern


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

    def eval(self) -> None:
        args = []
        for signal in self.signals.values():
            if signal.is_input:
                args.append(str(signal.signal_value))
        # 先将所有的信号中是输入信号的放在args中
        ctrl = CONTROL_TEMPLATE.format(module_name=self.module_name, inputs=', '.join(args))

        if self.context.state is None:  # type: ignore
            proc_res = _krun(
                input_file=Path(self.source_file),
                definition_dir=self.context.krun.definition_dir,  # type: ignore
                output=KRunOutput.KORE,
                cmap={'Control': ctrl},
                # depth=1,
                check=True,
            )
            self.context.state = KoreParser(proc_res.stdout).pattern()  # type: ignore
        else:
            # todo: optimize this
            # obtain the kore presentation of control
            ctrl_kore = self.context.kprint._expression_kast(  # type: ignore
                ctrl, input=KAstInput.PROGRAM, output=KAstOutput.KORE, sort='Control'
            ).stdout
            ctrl_kore = KoreParser(ctrl_kore).pattern()
            expected_ctrl_cell = App(
                symbol="Lbl'-LT-'circt-control'-GT-'",
                sorts=(),
                args=(kseq([inj(SortApp('SortControl'), SortApp('SortKItem'), ctrl_kore)]),),
            )

            empty_ctrl_cell = eval(KORE_CONTROL_TO_REPLACE)

            def replace_ctrl(term: Pattern) -> Pattern:
                if term == empty_ctrl_cell:
                    return expected_ctrl_cell
                return term

            state = self.context.state.bottom_up(replace_ctrl)  # type: ignore

            k_replace = eval(KORE_K_TO_REPLACE)
            k_expected = eval(KORE_K_EXPECTED)

            def replace_k(term: Pattern) -> Pattern:
                if term == k_replace:
                    return k_expected
                return term

            state = state.bottom_up(replace_k)

            self.context.state = self.context.krun.run_pattern(pattern=state)  # type: ignore
        # ------
        # find circt-output cell
        # ------
        # help: observe the result
        # kore_print(pattern=self.context.kprint.kast_to_kore(r_cell), definition_dir=self.context.krun.definition_dir, output='pretty')
        state_cterm = CTerm.from_kast(self.context.kprint.kore_to_kast(self.context.state))  # type: ignore
        r_cell = state_cterm.cells[cell_label_to_var_name('<result>')]
        r_curr = flatten_label('_List_', r_cell)[-1]
        r_curr = flatten_label('ListItem', r_curr)[-1]
        r_vals = flatten_label('_List_', r_curr)
        for r_val in r_vals:
            r_flat_li = flatten_label('ListItem', r_val)[0]
            r_flat_re = flatten_label('result(_,_)_CIRCT-SYNTAX-CORE_Result_BareId_TypeValue', r_flat_li)
            # 应当是有token成员的子类
            key = r_flat_re[0].token  # type: ignore
            v = int(flatten_label('TV(_,_)_CIRCT-SYNTAX-CORE_TypeValue_Type_Value', r_flat_re[1])[1].token)  # type: ignore
            self.context.signals[key].signal_value = v  # type: ignore
        # -----------------------------------------------------------
        ob_in = state_cterm.cells[cell_label_to_var_name('<ob-in>')]
        ob_in_modules = flatten_label('_Map_', ob_in)
        for ob_in_module in ob_in_modules:
            ob_in_module_temp = flatten_label('_|->_', ob_in_module)
            module_ident = str(ob_in_module_temp[0].token)[1:-1].split('/')  # type: ignore
            module = self
            for ident in module_ident:
                module = module.children[ident]
            module_inputs = flatten_label('_List_', ob_in_module_temp[1])
            input_index = 0
            for module_input in module_inputs:
                input_value = int(flatten_label('ListItem', module_input)[0].token)  # type: ignore
                module.signals[list(module.signals.keys())[input_index]].signal_value = input_value
        # -----------------------------------------------------------
        ob_out = state_cterm.cells[cell_label_to_var_name('<ob-out>')]
        ob_out_modules = flatten_label('_Map_', ob_out)
        for ob_out_module in ob_out_modules:
            ob_out_module_temp = flatten_label('_|->_', ob_out_module)
            module_ident = str(ob_out_module_temp[0].token)[1:-1].split('/')  # type: ignore
            module = self
            for ident in module_ident:
                module = module.children[ident]
            module_outputs = flatten_label('_List_', ob_out_module_temp[1])
            for module_output in module_outputs:
                output_value = flatten_label('ListItem', module_output)[0]  # type: ignore
                output_value = flatten_label('result(_,_)_CIRCT-SYNTAX-CORE_Result_BareId_TypeValue', output_value)  # type: ignore
                output_indent = output_value[0].token  # type: ignore
                output_value = int(
                    flatten_label('TV(_,_)_CIRCT-SYNTAX-CORE_TypeValue_Type_Value', output_value[1])[1].token  # type: ignore
                )
                module.signals[output_indent].signal_value = output_value  # type: ignore
