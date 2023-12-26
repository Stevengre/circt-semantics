from pathlib import Path
from kirct.kimulator.model import KimulatorModel, KimulatorContext, Signal

generic_mlir_path: str = '/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder/adder/adder.generic.mlir'

io_a = Signal(name='io_a',
              abbrev='"',
              mlir_gen_name='io_a',
              is_input=True,
              num_bits=8,
              signal_type='wire',
              signal_value=0)
io_b = Signal(name='io_b',
              abbrev='#',
              mlir_gen_name='io_b',
              is_input=True,
              num_bits=8,
              signal_type='wire',
              signal_value=0)
res_add = Signal(name='res_add',
                 abbrev='$',
                 mlir_gen_name='res_add',
                 is_input=False,
                 num_bits=8,
                 signal_type='wire',
                 signal_value=0)
res_sub = Signal(name='res_sub',
                 abbrev='%',
                 mlir_gen_name='res_sub',
                 is_input=False,
                 num_bits=8,
                 signal_type='wire',
                 signal_value=0)


kimulator_context: KimulatorContext = KimulatorContext()
kimulator_context.trace_ever_on(True)
kimulator_context.signals['io_a'] = io_a
kimulator_context.signals['io_b'] = io_b
kimulator_context.signals['res_add'] = res_add
kimulator_context.signals['res_sub'] = res_sub


adder_model: KimulatorModel = KimulatorModel(module_name='Adder',
                                             source_file=generic_mlir_path,
                                             signals={'io_a': io_a,
                                                      'io_b': io_b,
                                                      'res_add': res_add,
                                                      'res_sub': res_sub,
                                                      },
                                             children={},
                                             context=kimulator_context)

