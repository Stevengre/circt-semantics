import pytest
from .utils import TEST_DATA_DIR
from typing import Final
from pathlib import Path
from kirct.kimulator.context import KimulatorContext, Signal
from kirct.kimulator.model import KimulatorModel
from pyk.kore.parser import KoreParser

INIT_PATTERN_TEST_DATA: Final = (
    (TEST_DATA_DIR.joinpath('adder.generic.mlir'), TEST_DATA_DIR.joinpath('adder.kore.expected')),
)


@pytest.mark.parametrize('file,expected', INIT_PATTERN_TEST_DATA)
def test_init_pattern(file: Path, expected: Path) -> None:
    # Given
    with KimulatorContext() as context:
        # When
        context.init_pattern(file)

        # Then
        with open(expected, 'r') as f:
            expected = KoreParser(f.read()).pattern()
            assert context.state == expected


def test_simple_model_modification() -> None:
    # Given
    model = KimulatorModel(signals={'a': Signal(name='a', signal_value=1),
                                    'b': Signal(name='b', signal_value=2)})
    # Then
    assert model.a == 1
    assert model.b == 2

    # When
    model.a = 3
    model.b = 4

    # Then
    assert model.a == 3
    assert model.b == 4


def test_model_context_identical_modification() -> None:
    # Given
    s0 = Signal(name='a', mlir_gen_name='x', signal_value=1)
    s1 = Signal(name='b', mlir_gen_name='y', signal_value=2)
    model = KimulatorModel(signals={'a': s0, 'b': s1})
    context = KimulatorContext()
    context.signals = {'x': s0, 'y': s1}

    # When
    model.a = 3

    # Then
    assert model.a == 3
    assert context.signals['x'].signal_value == 3


# def test_nested_model_modification() -> None:
#     assert False

