from pathlib import Path
import pytest
from kcirct.api import KCIRCT

from ..resources import MODULES_EXPECTED_GENERIC_MLIR_FILES, MODULES_TEST_IDS


@pytest.mark.parametrize('mlir_file', MODULES_EXPECTED_GENERIC_MLIR_FILES, ids=MODULES_TEST_IDS)
def test_compile(mlir_file: Path) -> None:
    # Given
    kcirct = KCIRCT()

    # When
    kcirct.compile(mlir_file)

    # Then: no error


