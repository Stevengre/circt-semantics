from kirct.kimulator.model import *
from resource.circt_modules.adder.expected.adder import adder_model


def test_nested_model_eval() -> None:
    # todo
    pass


def test_model_eval_two_output() -> None:
    # todo: update result with multiple outputs
    pass


def test_model_eval_twice() -> None:
    # todo:
    # todo: update result
    # todo: run multiple times
    # Given
    adder_model.io_a = 2
    adder_model.io_b = 6
    # When
    adder_model.eval()
    # Then
    assert adder_model.io_out == 8
    # When
    adder_model.context.time_inc(1)
    adder_model.io_a = 1
    adder_model.io_b = 3
    adder_model.eval()
    # Then
    assert adder_model.io_out == 4


def test_simultaneous_model_modification() -> None:
    # Given
    kimulator_context: KimulatorContext = KimulatorContext()
    kimulator_context.signals = {
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
    }
    kimulator_model: KimulatorModel = KimulatorModel(module_name='Adder',
                                                     source_file='',
                                                     signals={},
                                                     context=kimulator_context)
    for signal in kimulator_context.signals.values():
        kimulator_model.signals[signal.name] = signal

    # When
    kimulator_model.io_a = 1
    kimulator_model.io_b = 2

    # Then
    assert kimulator_context.signals['io_a'].signal_value == 1
    assert kimulator_context.signals['io_b'].signal_value == 2

    del kimulator_model.context
