import time

from kcirct.api import KCIRCT
from ..resources import DATA_PATH

MLIR_FILE = DATA_PATH / 'rocket-small' / 'rocket-small-drop.mlir'
TOP_MODULE = 'RocketSystem'
INPUTS = inputs = [
    [
        (1, 1),
        (1, 1),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 7),
        (0, 32),
        (0, 2),
        (0, 11),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 4),
        (0, 2),
        (0, 1),
        (0, 1),
        (0, 4),
        (0, 64),
        (0, 2),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 4),
        (0, 2),
        (0, 1),
        (0, 1),
        (0, 4),
        (0, 64),
        (0, 2),
        (0, 1),
    ],
    [
        (0, 1),
        (1, 1),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 7),
        (0, 32),
        (0, 2),
        (0, 11),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 4),
        (0, 2),
        (0, 1),
        (0, 1),
        (0, 4),
        (0, 64),
        (0, 2),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 1),
        (0, 4),
        (0, 2),
        (0, 1),
        (0, 1),
        (0, 4),
        (0, 64),
        (0, 2),
        (0, 1),
    ],
]

def measure_time(func, output_message: str):
    """测量函数运行时间并打印消息。"""
    start_time = time.time()
    result = func()
    end_time = time.time()
    time_cost = end_time - start_time
    print(f'{output_message}: {time_cost * 1000} ms')
    return result

def test_small():
    kcirct = KCIRCT(use_opt=True)
    kcirct.ensure_env()
    # measure_time(
    #     lambda: kcirct.compile_fast(MLIR_FILE, MLIR_FILE.parent / 'pgm.kore'),
    #     'KCIRCT Parse Time'
    # )
    # measure_time(
    #     lambda: kcirct.run_preprocess_fast(MLIR_FILE.parent / 'pgm.kore', MLIR_FILE.parent / 'preprocessed.kore'),
    #     'KCIRCT Preprocess Time'
    # )
    # measure_time(
    #     lambda: kcirct.run_setup_fast(MLIR_FILE.parent / 'preprocessed.kore', MLIR_FILE.parent / 'setup.kore', TOP_MODULE),
    #     'KCIRCT Setup Time'
    # )
    measure_time(
        lambda: kcirct.run_initialize_fast(MLIR_FILE.parent / 'setup.kore', MLIR_FILE.parent / 'initialized.kore'),
        'KCIRCT Initialize Time'
    )
    measure_time(
        lambda: kcirct.run_simulate_fast(MLIR_FILE.parent / 'initialized.kore', MLIR_FILE.parent / 'simulated.0.kore', INPUTS[0]),
        'KCIRCT Simulate Time'
    )
    measure_time(
        lambda: kcirct.write_pretty(MLIR_FILE.parent / 'simulated.0.kore', MLIR_FILE.parent / 'simulated.0.pretty'),
        'KCIRCT Write Pretty Time'
    )


def test_pretty() -> None:
    kore_file = DATA_PATH / 'rocket-small' / 'setup.kore'
    pretty_file = kore_file.parent / f'{kore_file.name}.pretty'
    kcirct = KCIRCT(use_opt=False)
    kcirct.ensure_env()
    kcirct.write_pretty(kore_file, pretty_file)
    print('Finished pretty printing: ' + str(pretty_file))

