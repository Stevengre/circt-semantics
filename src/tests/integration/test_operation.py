from __future__ import annotations

import timeit
from typing import TYPE_CHECKING, List

import pytest

from kcirct.api import KCIRCT
from kcirct.vcd import KVCD

from ..resources.operation import (
    DATA_PATH,
    COMB_MLIR_GNERIC_FILES,
    COMB_EXPECTED_TOP_MODULES,
    COMB_INPUTS,
    COMB_TEST_IDS,
)

if TYPE_CHECKING:
    from pathlib import Path


@pytest.mark.parametrize(
    'mlir_file, top_module, inputs',
    zip(COMB_MLIR_GNERIC_FILES, COMB_EXPECTED_TOP_MODULES, COMB_INPUTS, strict=True),
    ids=COMB_TEST_IDS,
)
def test_evaluate_demo(mlir_file: Path, top_module: str, inputs: List[List[tuple[int, int]]]) -> None:
    print(mlir_file)

    kcirct = KCIRCT()
    kcirct.ensure_env()
    # KCIRCT Parsing: from mlir to kore
    kcirct.compile_fast(mlir_file, mlir_file.parent / 'pgm.kore')
    # KCIRCT Preprocessing
    kcirct.run_preprocess_fast(mlir_file.parent / 'pgm.kore', mlir_file.parent / 'preprocessed.kore')
    kcirct.write_pretty(mlir_file.parent / 'preprocessed.kore', mlir_file.parent / 'preprocessed.pretty')
    # KCIRCT Hardware Setup & Initialization
    kcirct.run_setup_fast(mlir_file.parent / 'preprocessed.kore', mlir_file.parent / 'setup.kore', top_module)
    kcirct.write_pretty(mlir_file.parent / 'setup.kore', mlir_file.parent / 'setup.pretty')
    # KCIRCT Simulation
    input = inputs[0]
    vcd = KVCD(vcd_path=mlir_file.parent / f'test.vcd', mlir_path=mlir_file)
    vcd.time = 0
    kcirct.run_simulate_fast(mlir_file.parent / 'setup.kore', mlir_file.parent / f'simulated.{vcd.time}.kore', input)
    kcirct.write_pretty(mlir_file.parent / f'simulated.{vcd.time}.kore', mlir_file.parent / f'simulated.{vcd.time}.pretty')
    vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time}.kore'))
    for input in inputs[1:]:
        vcd.time += 1
        kcirct.run_simulate_fast(
            mlir_file.parent / f'simulated.{vcd.time-1}.kore', mlir_file.parent / f'simulated.{vcd.time}.kore', input
        )
        kcirct.write_pretty(mlir_file.parent / f'simulated.{vcd.time}.kore', mlir_file.parent / f'simulated.{vcd.time}.pretty')
        vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time}.kore'))

