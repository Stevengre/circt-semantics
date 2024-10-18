"""
Validate the semantics of the K-CIRCT.
"""

from pathlib import Path

from kcirct.api import KCIRCT

NOW_PATH = Path(__file__).parent
TEST_PATH = NOW_PATH.parent.parent / 'kcirct' / 'kdist' / 'circt_semantics'

def test_syntax() -> None:

    print(TEST_PATH)
    kcirct = KCIRCT()
    kcirct.run(
        [
            'kompile',
            str(TEST_PATH / 'test-syntax.k'),
            '--gen-bison-parser',
            '--bison-stack-max-depth',
            '1000000000',
            '-o',
            str(TEST_PATH / 'test-syntax-kompiled/'),
        ]
    )

    kcirct.run(
        [
            'krun',
            str(TEST_PATH / 'rocket-small-drop.mlir'),
            '--definition',
            str(TEST_PATH / 'test-syntax-kompiled'),
            '--depth',
            '0',
            '-o',
            'kore',
            '--output-file',
            str(TEST_PATH / 'test-syntax.kore'),
        ]
    )
