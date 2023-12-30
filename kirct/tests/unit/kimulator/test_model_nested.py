from resource.circt_modules.adder_nested.expected.adder import adder_model


def test_model_nested_eval() -> None:
    # Given
    # todo: the ports' name cannot be something like 'in', since the krun will return an error.
    adder_model.signals['io_a'].signal_value = 6
    # When
    adder_model.eval()
    # Then
    assert adder_model.res_out2 == 8
    assert adder_model.res_out1 == 9
    # When: run second time
    adder_model.context.time_inc(1)
    adder_model.io_a = 5
    adder_model.eval()
    # Then
    assert adder_model.res_out2 == 7
    assert adder_model.res_out1 == 8
