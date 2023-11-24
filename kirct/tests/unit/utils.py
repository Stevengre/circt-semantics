from __future__ import annotations
from typing import Final
from pathlib import Path

TEST_DATA_DIR: Final = (Path(__file__).parent / 'test-data').resolve(strict=True)
