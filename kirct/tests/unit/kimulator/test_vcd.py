from kirct.kimulator.vcd import *
from resource.circt_modules.adder.expected.adder import adder_model
from resource import DATA_PATH
import shutil
import os
from pyk.utils import ensure_dir_path


def test_vcd() -> None:
    # Given
    generated_dir = DATA_PATH.joinpath("circt_modules", "adder", "vcd")
    expected = DATA_PATH.joinpath("circt_modules", "adder", "expected", "test.vcd")
    if os.path.exists(generated_dir):
        shutil.rmtree(generated_dir)
    ensure_dir_path(generated_dir)
    tfp = KimulatorVCD(adder_model, 99)
    tfp.open(generated_dir.joinpath("test.vcd"))
    # When
    adder_model.io_a = 6
    adder_model.io_b = 2
    adder_model.eval()
    tfp.dump(0)
    tfp.close()
    # Then
    res = diff(expected, generated_dir.joinpath("test.vcd"), 'Adder', 'Adder')
    assert res.stdout == ''
    assert res.stderr == ''
    shutil.rmtree(generated_dir)
