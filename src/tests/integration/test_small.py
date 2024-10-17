import filecmp
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


def test_step_run() -> None:
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
    # measure_time(
    #     lambda: kcirct.run_initialize_fast(MLIR_FILE.parent / 'setup.kore', MLIR_FILE.parent / 'initialized.kore'),
    #     'KCIRCT Initialize Time'
    # )
    # measure_time(
    #     lambda: kcirct.run_simulate_fast(MLIR_FILE.parent / 'initialized.kore', MLIR_FILE.parent / 'simulated.0.kore.1000', INPUTS[0], depth=1000),
    #     'KCIRCT Simulate Time'
    # )
    kore_name = 'simulated.0.kore'
    current_depth = 107000
    depth_path = 1000
    input_kore = MLIR_FILE.parent / f'simulated.0.kore.{current_depth}'
    while True:
        current_depth += depth_path
        output_kore = input_kore.parent / f'{kore_name}.{current_depth}'
        print(f'continue run to {current_depth}')
        kcirct.krun_fast(input_file=input_kore, output_file=output_kore, depth=depth_path)
        if filecmp.cmp(input_kore, output_kore, shallow=False):
            print(f'find stuck at {current_depth}, but it might be a correct result')
            kcirct.write_pretty(output_kore, input_kore.parent / f'{kore_name}.{current_depth}.pretty')
            print(f'pretty file generated!!!!')
            break
        input_kore = output_kore


def test_small():
    kcirct = KCIRCT(use_opt=True)
    kcirct.ensure_env()
    measure_time(
        lambda: kcirct.compile_fast(MLIR_FILE, MLIR_FILE.parent / 'pgm.kore'),
        'KCIRCT Parse Time'
    )
    measure_time(
        lambda: kcirct.run_preprocess_fast(MLIR_FILE.parent / 'pgm.kore', MLIR_FILE.parent / 'preprocessed.kore'),
        'KCIRCT Preprocess Time'
    )
    measure_time(
        lambda: kcirct.run_setup_fast(MLIR_FILE.parent / 'preprocessed.kore', MLIR_FILE.parent / 'setup.kore', TOP_MODULE),
        'KCIRCT Setup Time'
    )
    measure_time(
        lambda: kcirct.run_initialize_fast(MLIR_FILE.parent / 'setup.kore', MLIR_FILE.parent / 'initialized.kore'),
        'KCIRCT Initialize Time'
    )
    measure_time(
        lambda: kcirct.run_simulate_fast(MLIR_FILE.parent / 'initialized.kore', MLIR_FILE.parent / 'simulated.0.opt.kore', INPUTS[0]),
        'KCIRCT Simulate Time'
    )
    measure_time(
        lambda: kcirct.write_pretty(MLIR_FILE.parent / 'simulated.0.opt.kore', MLIR_FILE.parent / 'simulated.0.opt.pretty'),
        'KCIRCT Write Pretty Time'
    )


def test_pretty() -> None:
    kore_file = DATA_PATH / 'rocket-small' / 'simulated.0.kore.106000'
    pretty_file = kore_file.parent / f'{kore_file.name}.pretty'
    kcirct = KCIRCT(use_opt=False)
    kcirct.ensure_env()
    kcirct.write_pretty(kore_file, pretty_file)
    print('Finished pretty printing: ' + str(pretty_file))
    

def test_check_pretty() -> None:
    pretty_file = DATA_PATH / 'rocket-small' / 'simulated.0.kore.107000.pretty'
    print()
    with open(pretty_file, 'r') as file:
        # 读取每一行
        flag = False
        for line in file:
            if flag:
                # 将头尾的空白都去掉
                line = line.strip()
                # 如果字符开头为#ArgRef 或 % 则跳过，否则打印出来
                # if not line.startswith('#ArgRef') and not line.startswith('%'):
                if not line.startswith('.K'):
                    print(line)
                flag = False
            if '<k>' in line:
                flag = True

