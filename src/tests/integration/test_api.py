from __future__ import annotations

import timeit
from typing import TYPE_CHECKING, List

import pytest

from kcirct.api import KCIRCT
from kcirct.vcd import KVCD

from ..resources import (
    DATA_PATH,
    MODULES_EXPECTED_GENERIC_MLIR_FILES,
    MODULES_EXPECTED_TOP_MODULES,
    MODULES_INPUTS,
    MODULES_TEST_IDS,
)

if TYPE_CHECKING:
    from pathlib import Path


@pytest.mark.parametrize(
    'mlir_file, top_module, inputs',
    zip(MODULES_EXPECTED_GENERIC_MLIR_FILES, MODULES_EXPECTED_TOP_MODULES, MODULES_INPUTS, strict=True),
    ids=MODULES_TEST_IDS,
)
def test_evaluate_demo(mlir_file: Path, top_module: str, inputs: List[List[tuple[int, int]]]) -> None:
    kcirct = KCIRCT(use_opt=True)
    kcirct.ensure_env()
    # KCIRCT Parsing: from mlir to kore
    kcirct.compile_fast(mlir_file, mlir_file.parent / 'pgm.kore')
    # # Kimulator Kore Parsing
    # kcirct.read_kore(mlir_file.parent / 'pgm.kore')
    # # KCIRCT Preprocessing
    # kcirct.run_preprocess_fast(mlir_file.parent / 'pgm.kore', mlir_file.parent / 'preprocessed.kore')
    # # # --- test the preprocessing template
    # # kcirct.krun_fast(mlir_file.parent / 'preprocessed.kore', mlir_file.parent / 'evaluated.kore')
    # kcirct.write_pretty(mlir_file.parent / 'preprocessed.kore', mlir_file.parent / 'preprocessed.pretty')
    # # KCIRCT Hardware Setup
    # kcirct.run_setup_fast(mlir_file.parent / 'preprocessed.kore', mlir_file.parent / 'setup.kore', top_module)
    # kcirct.write_pretty(mlir_file.parent / 'setup.kore', mlir_file.parent / 'setup.pretty')
    # # KCIRCT Initialization
    # kcirct.run_initialize_fast(mlir_file.parent / 'setup.kore', mlir_file.parent / 'initialized.kore')
    # kcirct.write_pretty(mlir_file.parent / 'initialized.kore', mlir_file.parent / 'initialized.pretty')
    # # KCIRCT Simulation
    # input = inputs[0]
    # time = 0
    # kcirct.run_simulate_fast(mlir_file.parent / 'initialized.kore', mlir_file.parent / f'simulated.{time}.kore', input)
    # kcirct.write_pretty(mlir_file.parent / f'simulated.{time}.kore', mlir_file.parent / f'simulated.{time}.pretty')
    # for input in inputs[1:]:
    #     time += 1
    #     kcirct.run_simulate_fast(
    #         mlir_file.parent / f'simulated.{time-1}.kore', mlir_file.parent / f'simulated.{time}.kore', input
    #     )
    #     kcirct.write_pretty(mlir_file.parent / f'simulated.{time}.kore', mlir_file.parent / f'simulated.{time}.pretty')
    # print()


@pytest.mark.parametrize(
    'mlir_file, top_module, inputs',
    zip(MODULES_EXPECTED_GENERIC_MLIR_FILES, MODULES_EXPECTED_TOP_MODULES, MODULES_INPUTS, strict=True),
    ids=MODULES_TEST_IDS,
)
def test_apis(mlir_file: Path, top_module: str, inputs: List[List[tuple[int, int]]]) -> None:
    # Given
    kcirct = KCIRCT()
    kcirct.ensure_env()
    vcd = KVCD(vcd_path=mlir_file.parent / 'test.vcd', mlir_path=mlir_file)
    compiled = kcirct.compile(mlir_file)

    # When
    simulate_once = kcirct.run_first_simulate(compiled, top_module, inputs[0])
    vcd.time = 0
    vcd.dump(kcirct.read_ports(simulate_once))
    for input in inputs[1:]:
        simulate_result = kcirct.run_simulate(simulate_once, input)
        vcd.time += 1
        vcd.dump(kcirct.read_ports(simulate_result))
    vcd.close()

    # Then: compare with expected output


@pytest.mark.parametrize(
    'mlir_file, top_module, inputs',
    zip(MODULES_EXPECTED_GENERIC_MLIR_FILES, MODULES_EXPECTED_TOP_MODULES, MODULES_INPUTS, strict=True),
    ids=MODULES_TEST_IDS,
)
def test_apis_demo(mlir_file: Path, top_module: str, inputs: List[List[tuple[int, int]]]) -> None:
    # Given
    kcirct = KCIRCT()
    vcd = KVCD(vcd_path=DATA_PATH / 'test.vcd', mlir_path=mlir_file)

    # When
    compiled = kcirct.compile(mlir_file)
    # preprocessed = kcirct.run_preprocess(compiled)
    # setup = kcirct.run_setup(preprocessed, top_module)
    # initialized = kcirct.run_initialize(setup)
    # simulate_once = kcirct.run_simulate(initialized, inputs[0])

    simulate_once = kcirct.run_first_simulate(compiled, top_module, inputs[0])
    # kcirct.read_ports(simulate_once)
    vcd.time = 0
    vcd.dump(kcirct.read_ports(simulate_once))
    # print(outputs)
    simulate_twice = kcirct.run_simulate(simulate_once, inputs[1])
    # krun adder.generic.mlir -cEntry='"Adder"' -cInput="ListItem(bits(10, 8):i8) ListItem(bits(2,8):i8)"
    # krun adder.generic.nested.mlir -cEntry='"Adder"' -cInput="ListItem(ListItem(bits(10, 8):i8))"
    # print(kcirct.pretty(simulate_once))
    kcirct.read_ports(simulate_twice)
    vcd.time += 1
    vcd.dump(kcirct.read_ports(simulate_twice))
    print()
    # print(outputs)
    # Then: no error


def test_vcd_demo() -> None:
    mlir_file = DATA_PATH / 'modules' / 'adder_nested' / 'expected' / 'adder.generic.mlir'
    # Given
    vcd = KVCD(vcd_path=DATA_PATH / 'test.vcd', mlir_path=mlir_file)
    vcd.close()
    print()


def test_performance_demo() -> None:
    kcirct = KCIRCT()
    mlir_file = MODULES_EXPECTED_GENERIC_MLIR_FILES[0]
    timer = timeit.Timer(lambda: kcirct.compile(mlir_file))
    execution_time = timer.timeit(number=1)
    print(f'Execution time: {execution_time} seconds')


def test_coverage_demo() -> None:
    kcirct = KCIRCT()
    mlir_file = MODULES_EXPECTED_GENERIC_MLIR_FILES[0]
    compiled = kcirct.compile(mlir_file)
    kcirct.run_preprocess(compiled)
    # setup = kcirct.run_setup(preprocessed, top_module)
