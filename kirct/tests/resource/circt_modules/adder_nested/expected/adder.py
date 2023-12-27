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
res_out2_signal = Signal(name='res_out2',
                         abbrev="%",
                         mlir_gen_name='res_out2',
                         is_input=False,
                         num_bits=8,
                         signal_type='wire',
                         signal_value=0)
res_out1_signal = Signal(name='res_out1',
                         abbrev="'",
                         mlir_gen_name='res_out1',
                         is_input=False,
                         num_bits=8,
                         signal_type='wire',
                         signal_value=0)
i3_io_a_signal = Signal(name='io_a',
                        abbrev=")",
                        mlir_gen_name='i3/io_a',
                        is_input=False,
                        num_bits=8,
                        signal_type='wire',
                        signal_value=0)
i3_i0_io_a_signal = Signal(name='io_a',
                           abbrev="+",
                           mlir_gen_name='i3/i0/io_a',
                           is_input=False,
                           num_bits=8,
                           signal_type='wire',
                           signal_value=0)
i3_i0_res_signal = Signal(name='res',
                          abbrev="-",
                          mlir_gen_name='i3/i0/res',
                          is_input=False,
                          num_bits=8,
                          signal_type='wire',
                          signal_value=0)
i3_i1_io_a_signal = Signal(name='io_a',
                           abbrev="/",
                           mlir_gen_name='i3/i1/io_a',
                           is_input=False,
                           num_bits=8,
                           signal_type='wire',
                           signal_value=0)
i3_i1_res_signal = Signal(name='res',
                          abbrev=";",
                          mlir_gen_name='i3/i1/res',
                          is_input=False,
                          num_bits=8,
                          signal_type='wire',
                          signal_value=0)
i3_res2_signal = Signal(name='res2',
                        abbrev="=",
                        mlir_gen_name='i3/res2',
                        is_input=False,
                        num_bits=8,
                        signal_type='wire',
                        signal_value=0)
i4_io_a_signal = Signal(name='io_a',
                        abbrev="?",
                        mlir_gen_name='i4/io_a',
                        is_input=False,
                        num_bits=8,
                        signal_type='wire',
                        signal_value=0)
i4_res_signal = Signal(name='res',
                       abbrev="A",
                       mlir_gen_name='i4/res',
                       is_input=False,
                       num_bits=8,
                       signal_type='wire',
                       signal_value=0)


kimulator_context: KimulatorContext = KimulatorContext()
kimulator_context.trace_ever_on(True)
kimulator_context.signals['io_a'] = io_a_signal
kimulator_context.signals['res_out2'] = res_out2_signal
kimulator_context.signals['res_out1'] = res_out1_signal
kimulator_context.signals['i3/io_a'] = i3_io_a_signal
kimulator_context.signals['i3/i0/io_a'] = i3_i0_io_a_signal
kimulator_context.signals['i3/i0/res'] = i3_i0_res_signal
kimulator_context.signals['i3/i1/io_a'] = i3_i1_io_a_signal
kimulator_context.signals['i3/i1/res'] = i3_i1_res_signal
kimulator_context.signals['i3/res2'] = i3_res2_signal
kimulator_context.signals['i4/io_a'] = i4_io_a_signal
kimulator_context.signals['i4/res'] = i4_res_signal


i4_model: KimulatorModel = KimulatorModel(module_name='',
                                          source_file=generic_mlir_path,
                                          signals={'io_a': i4_io_a_signal,
                                                   'res': i4_res_signal,
                                                   },
                                          children={},
                                          context=kimulator_context)
i1_model: KimulatorModel = KimulatorModel(module_name='',
                                          source_file=generic_mlir_path,
                                          signals={'io_a': i3_i1_io_a_signal,
                                                   'res': i3_i1_res_signal,
                                                   },
                                          children={},
                                          context=kimulator_context)
i0_model: KimulatorModel = KimulatorModel(module_name='',
                                          source_file=generic_mlir_path,
                                          signals={'io_a': i3_i0_io_a_signal,
                                                   'res': i3_i0_res_signal,
                                                   },
                                          children={},
                                          context=kimulator_context)
i3_model: KimulatorModel = KimulatorModel(module_name='',
                                          source_file=generic_mlir_path,
                                          signals={'io_a': i3_io_a_signal,
                                                   'res2': i3_res2_signal,
                                                   },
                                          children={},
                                          context=kimulator_context)
adder_model: KimulatorModel = KimulatorModel(module_name='Adder',
                                             source_file=generic_mlir_path,
                                             signals={'io_a': io_a_signal,
                                                      'res_out2': res_out2_signal,
                                                      'res_out1': res_out1_signal,
                                                      },
                                             children={},
                                             context=kimulator_context)

