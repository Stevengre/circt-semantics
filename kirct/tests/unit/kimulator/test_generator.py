from kirct.kimulator.generator import *
from resource import DATA_PATH
import os
import shutil


def test_generate_nested_header() -> None:
    # todo
    pass


def test_generate_simple_header() -> None:
    # Given
    generated_dir = DATA_PATH.joinpath("circt_modules", "adder", "adder")
    if os.path.exists(generated_dir):
        shutil.rmtree(generated_dir)
    assert not os.path.exists(generated_dir)
    generator = Generator(DATA_PATH.joinpath("circt_modules", "adder", "adder.mlir"))
    expected_dir = DATA_PATH.joinpath("circt_modules", "adder", "expected")
    # When
    generator.generate()
    # Then
    assert os.path.exists(generated_dir)
    with open(generated_dir.joinpath("adder.generic.mlir"), "r") as f:
        assert f.read() == open(expected_dir.joinpath("adder.generic.mlir"), "r").read()
    with open(generated_dir.joinpath("state.json"), "r") as f:
        assert f.read() == open(expected_dir.joinpath("state.json"), "r").read()
    with (open(generated_dir.joinpath("adder.py"), "r") as file1, open(expected_dir.joinpath("adder.py"), "r") as file2):
        for current_line_number, (line1, line2) in enumerate(zip(file1, file2), start=1):
            if current_line_number != 5 and line1 != line2:
                assert False
    shutil.rmtree(generated_dir)

