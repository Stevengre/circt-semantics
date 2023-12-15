from resource.circt_modules.adder.adder import kimulator_context, adder_model
from ..resource import DATA_PATH
from kirct.kimulator.generator import Generator



def test_generate_simulation_header() -> None:
    # todo: add expected and assertion
    Generator(DATA_PATH.joinpath("adder.mlir")).generate()


def test_adder_eval() -> None:
    # Given
    adder_model.io_a = 2
    adder_model.io_b = 6
    adder_model.eval()
    assert adder_model.io_out == 8
    kimulator_context.time_inc(1)
    assert kimulator_context.time() == 1
    adder_model.io_a = 1
    adder_model.io_b = 3
    adder_model.eval()
    assert adder_model.io_out == 4


