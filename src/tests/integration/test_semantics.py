"""
Validate the semantics of the K-CIRCT.
"""

from pathlib import Path

import pytest

from kcirct.api import KCIRCT

from ..resources import DATA_PATH

NOW_PATH = Path(__file__).parent
TEST_PATH = NOW_PATH.parent.parent / 'kcirct' / 'kdist' / 'circt_semantics'


@pytest.mark.parametrize(
    'test_k_file, test_mlir',
    [
        (TEST_PATH / 'test-syntax.k', TEST_PATH / 'rocket-small-drop.mlir'),
        (TEST_PATH / 'test-syntax.k', DATA_PATH / 'rocket-small-nodrop' / 'rocket-small-master.generic.mlir'),
    ],
    ids=['drop', 'no-drop'],
)
def test_syntax(test_k_file: Path, test_mlir: Path) -> None:
    kcirct = KCIRCT()
    kcirct.kompile_manual(
        test_k_file,
        TEST_PATH / 'test-syntax-kompiled/',
        ['--gen-bison-parser', '--bison-stack-max-depth', '1000000000'],
    )
    kcirct.set_definition_dir(TEST_PATH / 'test-syntax-kompiled')
    kcirct.krun_manual(test_mlir, ['--depth', '0', '-o', 'kore', '--output-file', str(TEST_PATH / 'test-syntax.kore')])
