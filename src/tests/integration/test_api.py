from __future__ import annotations

import timeit
from typing import TYPE_CHECKING, List

import pytest

from kcirct.api import KCIRCT

from ..resources import (
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
def test_apis(mlir_file: Path, top_module: str, inputs: List[List[tuple[int, int]]]) -> None:
    # Given
    kcirct = KCIRCT()

    # When
    compiled = kcirct.compile(mlir_file)
    preprocessed = kcirct.run_preprocess(compiled)
    setup = kcirct.run_setup(preprocessed, top_module)
    initialized = kcirct.run_initialize(setup)
    kcirct.run_simulate(initialized, inputs[0])
    # print(simulate_once)
    # Then: no error


def test_performance_demo() -> None:
    kcirct = KCIRCT()
    mlir_file = MODULES_EXPECTED_GENERIC_MLIR_FILES[0]
    timer = timeit.Timer(lambda: kcirct.compile(mlir_file))
    execution_time = timer.timeit(number=1)
    print(f'Execution time: {execution_time} seconds')
