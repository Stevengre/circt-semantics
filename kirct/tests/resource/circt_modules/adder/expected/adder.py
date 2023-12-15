
from pathlib import Path
from kirct.kimulator.model import KimulatorModel, KimulatorContext, Signal
import os

generic_mlir_path: str = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'adder.generic.mlir')
kimulator_context: KimulatorContext = KimulatorContext()
kimulator_context.trace_ever_on(True)

kimulator_context.signals = {
    'i0': Signal(name='i0', 
                 abbrev=kimulator_context.gen_abbrev(), 
                 mlir_gen_name='i0', 
                 is_input=True, 
                 signal_type='input', 
                 signal_value=0),
    'i1': Signal(name='i1', 
                 abbrev=kimulator_context.gen_abbrev(), 
                 mlir_gen_name='i1', 
                 is_input=True, 
                 signal_type='input', 
                 signal_value=0),
    'res_add': Signal(name='res_add', 
                      abbrev=kimulator_context.gen_abbrev(), 
                      mlir_gen_name='res_add', 
                      is_input=False, 
                      signal_type='output', 
                      signal_value=0),
    'res_sub': Signal(name='res_sub', 
                      abbrev=kimulator_context.gen_abbrev(), 
                      mlir_gen_name='res_sub', 
                      is_input=False, 
                      signal_type='output', 
                      signal_value=0),
}

adder_model: KimulatorModel = KimulatorModel(module_name='Adder', source_file=generic_mlir_path, signals={}, context=kimulator_context)

for signal in kimulator_context.signals.values():
    adder_model.signals[signal.name] = signal
