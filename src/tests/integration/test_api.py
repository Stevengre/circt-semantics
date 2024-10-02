from pathlib import Path

import pytest

from kcirct.api import KCIRCT

from ..resources import MODULES_EXPECTED_GENERIC_MLIR_FILES, MODULES_EXPECTED_TOP_MODULES, MODULES_TEST_IDS


@pytest.mark.parametrize(
    'mlir_file, top_module',
    zip(MODULES_EXPECTED_GENERIC_MLIR_FILES, MODULES_EXPECTED_TOP_MODULES),
    ids=MODULES_TEST_IDS,
)
def test_apis(mlir_file: Path, top_module: str) -> None:
    # Given
    kcirct = KCIRCT()

    # When
    compiled = kcirct.compile(mlir_file)
    preprocessed = kcirct.run_preprocess(compiled)
    setup = kcirct.run_setup(preprocessed, top_module)
    initialized = kcirct.run_initialize(setup)
    simulate_once = kcirct.run_simulate(initialized, [(8,8), (2,8)])
    print(simulate_once)

    # Then: no error
