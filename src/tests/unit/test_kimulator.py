import os
from pathlib import Path
from tempfile import TemporaryDirectory

import pytest

from kcirct.kimulator.context import Abbrev, KimulatorContext, Signal
from kcirct.kimulator.generator import Generator
from kcirct.kimulator.model import KimulatorModel
from kcirct.kimulator.vcd import KimulatorVCD, diff

from ..resources import DATA_PATH
from ..resources.modules.adder.expected.adder import adder_model
from ..utils import assert_files_equal


def test_context() -> None:
    # Given
    context = KimulatorContext()
    temp_dir = context.history_dir
    # Then
    assert os.path.exists(temp_dir)
    # When
    del context
    # Then
    assert not os.path.exists(temp_dir)


GENERATOR_TEST_CASES: list[tuple[str, Path, str]] = [
    ('simple', DATA_PATH / 'modules' / 'adder', 'adder.mlir'),
    ('nested', DATA_PATH / 'modules' / 'adder_nested', 'adder.mlir'),
]


@pytest.mark.parametrize(
    'test_id, path, file_name', GENERATOR_TEST_CASES, ids=[test_id for test_id, *_ in GENERATOR_TEST_CASES]
)
def test_generator(test_id: str, path: Path, file_name: str) -> None:
    with TemporaryDirectory(dir=path) as temp_dir:
        # Given
        temp_path = Path(temp_dir)
        expected_dir = path / 'expected'
        generic_name = file_name.replace('.mlir', '.generic.mlir')
        python_name = file_name.replace('.mlir', '.py')
        generator = Generator(source=path / file_name, output_dir=temp_path)

        # When
        generator.generate()

        # Then
        assert_files_equal(generator.output_dir / 'state.json', expected_dir / 'state.json')
        assert_files_equal(generator.output_dir / generic_name, expected_dir / generic_name, ignore_lines=['#loc'])
        assert_files_equal(
            generator.output_dir / python_name,
            expected_dir / python_name,
            ignore_lines=['generic_mlir_path', 'import os'],
        )


def test_model_simutanous_assignment() -> None:
    # Given
    kimulator_context: KimulatorContext = KimulatorContext()
    kimulator_context.signals = {
        'io_a': Signal(
            name='io_a', abbrev=Abbrev.gen(), mlir_gen_name='io_a', is_input=True, signal_type='input', signal_value=0
        ),
        'io_b': Signal(
            name='io_b', abbrev=Abbrev.gen(), mlir_gen_name='io_b', is_input=True, signal_type='input', signal_value=0
        ),
    }
    kimulator_model: KimulatorModel = KimulatorModel(
        module_name='Adder', source_file='', signals={}, context=kimulator_context
    )
    for signal in kimulator_context.signals.values():
        kimulator_model.signals[signal.name] = signal

    # When
    kimulator_model.io_a = 1
    kimulator_model.io_b = 2

    # Then
    assert kimulator_context.signals['io_a'].signal_value == 1
    assert kimulator_context.signals['io_b'].signal_value == 2

    del kimulator_model.context


def test_vcd() -> None:
    with TemporaryDirectory(dir=DATA_PATH / 'modules' / 'adder') as temp_dir:
        # Given
        tfp = KimulatorVCD(adder_model, 99)
        tfp.open(str(Path(temp_dir) / 'test.vcd'))

        # When
        adder_model.io_a = 6
        adder_model.io_b = 2
        adder_model.res_add = 8
        adder_model.res_sub = 4
        tfp.dump(0)
        tfp.close()

        # Then
        res = diff(
            str(DATA_PATH / 'modules' / 'adder' / 'expected' / 'test.vcd'),
            str(Path(temp_dir) / 'test.vcd'),
            'Adder',
            'Adder',
        )
        assert res.stdout == ''
        assert res.stderr == ''
