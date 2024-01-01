from pathlib import Path
from kirct.kimulator.model import KimulatorModel, KimulatorContext, Signal
import os

generic_mlir_path: str = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'adder.generic.mlir')

io_a_signal = Signal(name='io_a',
                     abbrev="#",
                     mlir_gen_name='io_a',
                     is_input=True,
                     num_bits=8,
                     signal_type='wire',
                     signal_value=0)
io_b_signal = Signal(name='io_b',
                     abbrev="%",
                     mlir_gen_name='io_b',
                     is_input=True,
                     num_bits=8,
                     signal_type='wire',
                     signal_value=0)
res_add_signal = Signal(name='res_add',
                        abbrev="'",
                        mlir_gen_name='res_add',
                        is_input=False,
                        num_bits=8,
                        signal_type='wire',
                        signal_value=0)
res_sub_signal = Signal(name='res_sub',
                        abbrev=")",
                        mlir_gen_name='res_sub',
                        is_input=False,
                        num_bits=8,
                        signal_type='wire',
                        signal_value=0)


kimulator_context: KimulatorContext = KimulatorContext()
kimulator_context.trace_ever_on(True)
kimulator_context.signals['io_a'] = io_a_signal
kimulator_context.signals['io_b'] = io_b_signal
kimulator_context.signals['res_add'] = res_add_signal
kimulator_context.signals['res_sub'] = res_sub_signal


adder_model: KimulatorModel = KimulatorModel(module_name='Adder',
                                             source_file=generic_mlir_path,
                                             signals={'io_a': io_a_signal,
                                                      'io_b': io_b_signal,
                                                      'res_add': res_add_signal,
                                                      'res_sub': res_sub_signal,
                                                      },
                                             children={},
                                             context=kimulator_context)

