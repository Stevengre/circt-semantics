from resource.circt_modules.adder_nested.expected.adder import adder_model
from kirct.kimulator.vcd import *
from pathlib import Path


def test_model_nested_eval() -> None:
    # Given
    # todo: the ports' name cannot be something like 'in', since the krun will return an error.
    adder_model.signals['io_a'].signal_value = 6
    tfp = KimulatorVCD(adder_model, 99)
    tfp.open(str(Path('.').joinpath("test.vcd")))
    # When
    adder_model.eval()
    # Then
    assert adder_model.res_out2 == 8
    assert adder_model.res_out1 == 9
    # When: run second time
    adder_model.context.time_inc(1)
    adder_model.io_a = 5
    adder_model.eval()
    tfp.dump(0)
    tfp.close()
    # Then
    assert adder_model.res_out2 == 7
    assert adder_model.res_out1 == 8
    assert adder_model.children['i0'].signals['io_a'].signal_value == 5
    assert adder_model.children['i0'].signals['res2'].signal_value == 7
    assert adder_model.children['i0'].children['i0'].signals['io_a'].signal_value == 5
    assert adder_model.children['i0'].children['i0'].signals['res'].signal_value == 6
    assert adder_model.children['i0'].children['i1'].signals['io_a'].signal_value == 6
    assert adder_model.children['i0'].children['i1'].signals['res'].signal_value == 7
    assert adder_model.children['i2'].signals['io_a'].signal_value == 7
    assert adder_model.children['i2'].signals['res'].signal_value == 8


