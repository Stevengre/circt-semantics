def test_model_eval_simple() -> None:
    # Given
    from ..resources.modules.adder.expected.adder import adder_model

    assert adder_model.context is not None

    adder_model.compile()

    adder_model.io_a = 6
    adder_model.io_b = 2

    # When
    adder_model.eval()

    # Then
    assert adder_model.res_add == 8
    assert adder_model.res_sub == 4
    # assert len(adder_model.context._changed_signal) == 4
    # temp_changed = copy.deepcopy(adder_model.context._changed_signal)
    # assert adder_model.context._changed_signal_history == {}

    # When: run second time
    adder_model.context.time_inc(1)
    adder_model.io_a = 5
    adder_model.io_b = 1
    adder_model.eval()

    # Then
    assert adder_model.res_add == 6
    assert adder_model.res_sub == 4
    # for s0, s1 in zip(_changed_signal_history[0], temp_changed, strict=True):
    #     assert s0.signal_value == s1.signal_value
    # assert len(_changed_signal) == 3
