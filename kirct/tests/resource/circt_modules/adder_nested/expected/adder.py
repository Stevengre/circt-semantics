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
i0_io_a_signal = Signal(name='io_a',
                        abbrev=")",
                        mlir_gen_name='i0/io_a',
                        is_input=False,
                        num_bits=8,
                        signal_type='wire',
                        signal_value=0)
i0_i0_io_a_signal = Signal(name='io_a',
                           abbrev="+",
                           mlir_gen_name='i0/i0/io_a',
                           is_input=False,
                           num_bits=8,
                           signal_type='wire',
                           signal_value=0)
i0_i0_res_signal = Signal(name='res',
                          abbrev="-",
                          mlir_gen_name='i0/i0/res',
                          is_input=False,
                          num_bits=8,
                          signal_type='wire',
                          signal_value=0)
i0_i1_io_a_signal = Signal(name='io_a',
                           abbrev="/",
                           mlir_gen_name='i0/i1/io_a',
                           is_input=False,
                           num_bits=8,
                           signal_type='wire',
                           signal_value=0)
i0_i1_res_signal = Signal(name='res',
                          abbrev=";",
                          mlir_gen_name='i0/i1/res',
                          is_input=False,
                          num_bits=8,
                          signal_type='wire',
                          signal_value=0)
i0_res2_signal = Signal(name='res2',
                        abbrev="=",
                        mlir_gen_name='i0/res2',
                        is_input=False,
                        num_bits=8,
                        signal_type='wire',
                        signal_value=0)
i2_io_a_signal = Signal(name='io_a',
                        abbrev="?",
                        mlir_gen_name='i2/io_a',
                        is_input=False,
                        num_bits=8,
                        signal_type='wire',
                        signal_value=0)
i2_res_signal = Signal(name='res',
                       abbrev="A",
                       mlir_gen_name='i2/res',
                       is_input=False,
                       num_bits=8,
                       signal_type='wire',
                       signal_value=0)


kimulator_context: KimulatorContext = KimulatorContext()
kimulator_context.trace_ever_on(True)
kimulator_context.signals['io_a'] = io_a_signal
kimulator_context.signals['res_out2'] = res_out2_signal
kimulator_context.signals['res_out1'] = res_out1_signal
kimulator_context.signals['i0/io_a'] = i0_io_a_signal
kimulator_context.signals['i0/i0/io_a'] = i0_i0_io_a_signal
kimulator_context.signals['i0/i0/res'] = i0_i0_res_signal
kimulator_context.signals['i0/i1/io_a'] = i0_i1_io_a_signal
kimulator_context.signals['i0/i1/res'] = i0_i1_res_signal
kimulator_context.signals['i0/res2'] = i0_res2_signal
kimulator_context.signals['i2/io_a'] = i2_io_a_signal
kimulator_context.signals['i2/res'] = i2_res_signal


i2_model: KimulatorModel = KimulatorModel(module_name='',
                                          source_file=generic_mlir_path,
                                          signals={'io_a': i2_io_a_signal,
                                                   'res': i2_res_signal,
                                                   },
                                          children={},
                                          context=kimulator_context)
i0_i1_model: KimulatorModel = KimulatorModel(module_name='',
                                             source_file=generic_mlir_path,
                                             signals={'io_a': i0_i1_io_a_signal,
                                                      'res': i0_i1_res_signal,
                                                      },
                                             children={},
                                             context=kimulator_context)
i0_i0_model: KimulatorModel = KimulatorModel(module_name='',
                                             source_file=generic_mlir_path,
                                             signals={'io_a': i0_i0_io_a_signal,
                                                      'res': i0_i0_res_signal,
                                                      },
                                             children={},
                                             context=kimulator_context)
i0_model: KimulatorModel = KimulatorModel(module_name='',
                                          source_file=generic_mlir_path,
                                          signals={'io_a': i0_io_a_signal,
                                                   'res2': i0_res2_signal,
                                                   },
                                          children={'i0': i0_i0_model,
                                                    'i1': i0_i1_model,
                                                    },
                                          context=kimulator_context)
adder_model: KimulatorModel = KimulatorModel(module_name='Adder',
                                             source_file=generic_mlir_path,
                                             signals={'io_a': io_a_signal,
                                                      'res_out2': res_out2_signal,
                                                      'res_out1': res_out1_signal,
                                                      },
                                             children={'i0': i0_model,
                                                       'i2': i2_model,
                                                       },
                                             context=kimulator_context)

