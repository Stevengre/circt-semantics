from __future__ import annotations

import filecmp
import json
import shutil
import subprocess
import time
from pathlib import Path
from typing import List

from kcirct.api import KCIRCT
from kcirct.vcd import KVCD
from tests.resources import DATA_PATH

ROCKET_SMALL_MLIR_FILE_V14 = DATA_PATH / 'rocket-small' / 'rocket-small-1.4-drop.mlir'
ROCKET_SMALL_MLIR_FILE_V16 = DATA_PATH / 'rocket-small' / 'rocket-small-1.6-drop.mlir'
ROCKET_SMALL_MLIR_FILE_MASTER = DATA_PATH / 'rocket-small' / 'rocket-small-master-drop.mlir'

ROCKET_INPUT_V14 = DATA_PATH / 'rocket-small' / 'input_1.4twoedge.json'
ROCKET_INPUT_MASTER = DATA_PATH / 'rocket-small' / 'input_twoedge.json'
ROCKET_INPUT_V16 = DATA_PATH / 'rocket-small' / 'input_v1.6.json'
ROCKET_INPUT_V16_MAIN = DATA_PATH / 'rocket-small' / 'input_v1.6start.json'

PACK_MASTER = [ROCKET_SMALL_MLIR_FILE_MASTER, ROCKET_INPUT_MASTER]
PACK_V14 = [ROCKET_SMALL_MLIR_FILE_V14, ROCKET_INPUT_V14]
PACK_V16 = [ROCKET_SMALL_MLIR_FILE_V16, ROCKET_INPUT_V16]
PACK_V16_MAIN = [ROCKET_SMALL_MLIR_FILE_V16, ROCKET_INPUT_V16_MAIN]

PICK = PACK_V16


def test_diffvcd(now: Path | None = None) -> None:
    test_path = Path('/home/zjh/proj/cym-circt-semantics/src/tests/resources/rocket-small/')
    test_path = test_path
    # 构建完整的命令
    vcd_file1 = test_path / 'test.vcd'
    vcd_file2 = test_path / 'rocket-vtor.vcd'
    command = [
        './scripts/diffvcd.py',
        '--top1 RocketSystem.RocketSystem.',
        '--top2 TOP.RocketSystem.',
        '-i icache.readEnable',
        '-i icache.writeEnable',
        str(vcd_file1),
        str(vcd_file2),
    ]

    # 运行命令并捕获返回值
    result = subprocess.run(command, capture_output=True, text=True)

    # 检查返回值是否为0
    if result.returncode == 0:
        print('diffvcd 成功，返回值为0')
    else:
        print(f'diffvcd 失败，返回值为 {result.returncode}')
        print(f'标准输出: {result.stdout}')
        print(f'标准错误: {result.stderr}')


def test_print_pretty(mlir_file: Path, top_module: str, inputs: List[List[tuple[int, int]]]) -> None:
    kcirct = KCIRCT()
    file_name = 'setup1.simulated.0.kore.prestate'
    kcirct.write_pretty(mlir_file.parent / file_name, mlir_file.parent / f'{file_name}.pretty')


def test_pretty() -> None:
    test_print_pretty(PICK[0], 'RocketSystem', [])


def test_evaluate_depth(mlir_file: Path, top_module: str) -> None:

    kcirct = KCIRCT()

    kcirct.ensure_env()

    kore_name = 'setup.kore.prestate'
    current_depth = 2900
    depth_path = 10
    input_kore = mlir_file.parent / f'{kore_name}.{current_depth}'
    while True:
        current_depth += depth_path
        output_kore = input_kore.parent / f'{kore_name}.{current_depth}'
        print(f'continue run to {current_depth}')
        kcirct.krun_fast(input_file=input_kore, output_file=output_kore, depth=depth_path)
        if filecmp.cmp(input_kore, output_kore, shallow=False):
            print(f'find stuck at {current_depth}, but it might be a correct result')
            kcirct.write_pretty(output_kore, input_kore.parent / f'{kore_name}.{current_depth}.pretty')
            print('pretty file generated!!!!')
            break
        input_kore = output_kore


def test_from_setup1(mlir_file: Path, top_module: str, inputs: List) -> None:
    kcirct = KCIRCT()

    kcirct.ensure_env()
    # KCIRCT Simulation
    vcd = KVCD(vcd_path=mlir_file.parent / 'test.vcd', mlir_path=mlir_file)
    vcd.time = 0
    circle_num = 0
    tot_time = 0.0
    run_time = 0

    shutil.copy(mlir_file.parent / 'setup1.simulated.begin.kore', mlir_file.parent / f'setup1.simulated.{0}.kore')
    for input in inputs[394:]:  # 从下降沿开始 begin vcd_dump:197
        if 'vcd_dump' in input:
            vcd.time = input['vcd_dump']
            vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'setup1.simulated.{run_time}.kore'))
            print('vcd_dump:' + str(vcd.time))
            if vcd.time >= 201:  # 下降沿结束
                break
        elif 'input' in input:
            input_data = input['input']
            print(input_data)
            start_time = time.time()
            kcirct.run_simulate_fast(
                mlir_file.parent / f'setup1.simulated.{run_time}.kore',
                mlir_file.parent / f'setup1.simulated.{run_time^1}.kore',
                input_data,
            )
            end_time = time.time()
            tot_time += end_time - start_time
            run_time = run_time ^ 1
            print(str(run_time) + str(mlir_file))
            circle_num += 1
            # vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))
        print('runtime_per_cicle:' + str((tot_time) / (circle_num)))
        print('runtime_total:' + str((tot_time)))


def test_evaluate_demo(mlir_file: Path, top_module: str, inputs: List) -> None:

    kcirct = KCIRCT()

    kcirct.ensure_env()
    # KCIRCT Parsing: from mlir to kore
    kcirct.compile_fast(mlir_file, mlir_file.parent / 'pgm.kore')
    # KCIRCT Preprocessing
    kcirct.run_preprocess_fast(mlir_file.parent / 'pgm.kore', mlir_file.parent / 'preprocessed.kore')
    # KCIRCT Hardware Setup & Initialization
    kcirct.run_setup_fast(mlir_file.parent / 'preprocessed.kore', mlir_file.parent / 'setup.kore', top_module)

    # KCIRCT Simulation
    vcd = KVCD(vcd_path=mlir_file.parent / 'test_setup_0.vcd', mlir_path=mlir_file)
    vcd.time = 0
    circle_num = 0
    tot_time = 0.0
    if len(inputs) == 0:
        input = None
        start_time = time.time()
        kcirct.krun_fast(mlir_file.parent / 'setup.kore', mlir_file.parent / f'simulated.{vcd.time&1}.kore')
        end_time = time.time()
        vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))
        print(str(vcd.time) + str(mlir_file))
        print('runtime:' + str(end_time - start_time))
    else:
        run_time = 0
        shutil.copy(mlir_file.parent / 'setup.kore', mlir_file.parent / f'simulated.{0}.kore')
        # vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))
        for input in inputs[0:]:
            if 'vcd_dump' in input:
                vcd.time = input['vcd_dump']
                vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{run_time}.kore'))
                print('vcd_dump:' + str(vcd.time))
                if vcd.time >= 10:  # 结束在上升沿
                    break
            elif 'input' in input:
                input_data = input['input']
                start_time = time.time()
                kcirct.run_simulate_fast(
                    mlir_file.parent / f'simulated.{run_time}.kore',
                    mlir_file.parent / f'simulated.{run_time^1}.kore',
                    input_data,
                )
                end_time = time.time()
                tot_time += end_time - start_time
                run_time = run_time ^ 1
                print(str(run_time) + str(mlir_file))
                circle_num += 1
            # vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))
        print('runtime_per_cicle:' + str((tot_time) / (circle_num)))
        print('runtime_total:' + str((tot_time)))


def test_from_main(mlir_file: Path, top_module: str, inputs: List) -> None:

    kcirct = KCIRCT()

    kcirct.ensure_env()
    # KCIRCT Parsing: from mlir to kore
    kcirct.compile_fast(mlir_file, mlir_file.parent / 'pgm.kore')
    # KCIRCT Preprocessing
    kcirct.run_preprocess_fast(mlir_file.parent / 'pgm.kore', mlir_file.parent / 'preprocessed.kore')
    # KCIRCT Hardware Setup & Initialization
    kcirct.run_setup_fast(mlir_file.parent / 'preprocessed.kore', mlir_file.parent / 'setup.kore', top_module)

    # KCIRCT Simulation
    vcd = KVCD(vcd_path=mlir_file.parent / 'test.vcd', mlir_path=mlir_file)
    vcd.time = 0
    circle_num = 0
    tot_time = 0.0
    if len(inputs) == 0:
        input = None
        start_time = time.time()
        kcirct.krun_fast(mlir_file.parent / 'setup.kore', mlir_file.parent / f'simulated.{vcd.time&1}.kore')
        end_time = time.time()
        vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))
        print(str(vcd.time) + str(mlir_file))
        print('runtime:' + str(end_time - start_time))
    else:
        run_time = 0
        shutil.copy(mlir_file.parent / 'setup.kore', mlir_file.parent / f'simulated.{0}.kore')
        # vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))
        for input in inputs[0:]:
            if 'vcd_dump' in input:
                vcd.time = input['vcd_dump']
                vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{run_time}.kore'))
                print('vcd_dump:' + str(vcd.time))

            elif 'input' in input:
                input_data = input['input']
                start_time = time.time()
                kcirct.run_simulate_fast(
                    mlir_file.parent / f'simulated.{run_time}.kore',
                    mlir_file.parent / f'simulated.{run_time^1}.kore',
                    input_data,
                )
                end_time = time.time()
                tot_time += end_time - start_time
                run_time = run_time ^ 1
                print(str(run_time) + str(mlir_file))
                circle_num += 1
            # vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))
        print('runtime_per_cicle:' + str((tot_time) / (circle_num)))
        print('runtime_total:' + str((tot_time)))


if __name__ == '__main__':

    #     inputs = [
    #         [[1 , 1],[1 , 1],[0 , 1],[0 , 1],[0 , 1],[0 , 4],[0 , 2],[0 , 1],[0 , 1],[0 , 4],[0 , 64],[0 , 2],[0 , 1],[0 , 1],[0 , 1],[0 , 1],[0 , 4],[0 , 2],[0 , 1],[0 , 1],[0 , 4],[0 , 64],[0 , 2],[0 , 1],[0 , 1],[0 , 1],[0 , 1],[0 , 1],[0 , 7],[0 , 32], [0 , 2],[0 , 11],[0 , 1],[0 , 1],[0 , 1]],
    # [[0 , 1],[1 , 1],[0 , 1],[0 , 1],[0 , 1],[0 , 4],[0 , 2],[0 , 1],[0 , 1],[0 , 4],[0 , 64],[0 , 2],[0 , 1],[0 , 1],[0 , 1],[0 , 1],[0 , 4],[0 , 2],[0 , 1],[0 , 1],[0 , 4],[0 , 64],[0 , 2],[0 , 1],[0 , 1],[0 , 1],[0 , 1],[0 , 1],[0 , 7],[0 , 32], [0 , 2],[0 , 11],[0 , 1],[0 , 1],[0 , 1]]
    #     ]

    with open(PICK[1], 'r') as file:
        json_data = json.load(file)
    # test_evaluate_demo(PICK[0], 'RocketSystem', json_data['inin'])  # 初始化第一阶段
    # test_from_setup1(PICK[0], 'RocketSystem', json_data['inin'])  # 初始化第二阶段
    test_from_main(PICK[0], 'RocketSystem', json_data['inin'])  # 全部
    # test_evaluate_depth(PICK[1], 'RocketSystem')
