from pathlib import Path
from kirct.kimulator.model import KimulatorModel, KimulatorContext, Signal

fpath = Path(__file__).parent.joinpath('adder.generic.mlir')
kimulator_context: KimulatorContext = KimulatorContext()
kimulator_context.trace_ever_on(True)
# kimulator_context.init_pattern(fpath)

kimulator_context.signals = {
    'clock': Signal(name='clock',
                    abbrev=kimulator_context.gen_abbrev(),
                    mlir_gen_name='clock',
                    is_input=True,
                    signal_type='input',
                    signal_value=0),
    'reset': Signal(name='reset',
                    abbrev=kimulator_context.gen_abbrev(),
                    mlir_gen_name='reset',
                    is_input=True,
                    signal_type='input',
                    signal_value=0),
    'io_a': Signal(name='io_a',
                   abbrev=kimulator_context.gen_abbrev(),
                   mlir_gen_name='io_a',
                   is_input=True,
                   signal_type='input',
                   signal_value=0),
    'io_b': Signal(name='io_b',
                   abbrev=kimulator_context.gen_abbrev(),
                   mlir_gen_name='io_b',
                   is_input=True,
                   signal_type='input',
                   signal_value=0),
    'io_out': Signal(name='io_out',
                     abbrev=kimulator_context.gen_abbrev(),
                     mlir_gen_name='io_out',
                     is_input=False,
                     signal_type='output',
                     signal_value=0),
}

adder_model: KimulatorModel = KimulatorModel(module_name='Adder',
                                             source_file=str(fpath),
                                             signals={},
                                             context=kimulator_context)

for signal in kimulator_context.signals.values():
    adder_model.signals[signal.name] = signal
