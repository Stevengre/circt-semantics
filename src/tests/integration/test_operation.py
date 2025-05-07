from __future__ import annotations

import subprocess
import time
from pathlib import Path
from typing import List

import pytest

from kcirct.api import KCIRCT
from kcirct.vcd import KVCD

from ..resources import DATA_PATH
from ..resources.operation import (
    DIALECT_OPERATIONS,
    DIRS,
    EXPECTED_TOP_MODULES,
    INPUTS,
    MLIR_GNERIC_FILES,
)

TEST_MLIR_GNERIC_FILES = []
TEST_EXPECTED_TOP_MODULES = []
TEST_INPUT = []

for dialect, operations in DIALECT_OPERATIONS.items():
    for i, dir in enumerate(DIRS[dialect]):
        print(f'{dialect}.{dir.name}')
        if dir.name in operations:
            TEST_MLIR_GNERIC_FILES.append(MLIR_GNERIC_FILES[dialect][i])
            TEST_EXPECTED_TOP_MODULES.append(EXPECTED_TOP_MODULES[dialect][i])
            TEST_INPUT.append(INPUTS[dialect][i])


@pytest.mark.parametrize(
    'mlir_file, top_module, inputs',
    zip(TEST_MLIR_GNERIC_FILES, TEST_EXPECTED_TOP_MODULES, TEST_INPUT, strict=True),
    ids=[str(p) for p in TEST_MLIR_GNERIC_FILES],
)
def test_evaluate_operation(mlir_file: Path, top_module: str, inputs: List[List[tuple[int, int]]]) -> None:

    kcirct = KCIRCT()
    # kcirct.write_pretty(mlir_file.parent / f'simulated.0.kore', mlir_file.parent / f'simulated.0.kore.pretty')

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

    if len(inputs) == 0:
        input = None
        start_time = time.time()
        kcirct.krun_fast(mlir_file.parent / 'setup.kore', mlir_file.parent / f'simulated.{vcd.time&1}.kore')
        end_time = time.time()
        vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))
        print(str(vcd.time) + str(mlir_file))
        print('runtime:' + str(end_time - start_time))
    else:
        input = inputs[0]
        start_time = time.time()
        kcirct.run_simulate_fast(
            mlir_file.parent / 'setup.kore', mlir_file.parent / f'simulated.{vcd.time&1}.kore', input
        )
        end_time = time.time()
        tot_time = end_time - start_time
        vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))
        for input in inputs[1:]:
            vcd.time += 1
            start_time = time.time()
            kcirct.run_simulate_fast(
                mlir_file.parent / f'simulated.{(vcd.time-1)&1}.kore',
                mlir_file.parent / f'simulated.{vcd.time&1}.kore',
                input,
            )
            end_time = time.time()
            tot_time += end_time - start_time
            # print(str(vcd.time) + str(mlir_file))
            # if vcd.time %2 == 1:
            vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))
            # if vcd.time ==11:
            # return
        print('runtime:' + str((end_time - start_time) / len(inputs)))
    diffvcd(mlir_file.parent)


def test_print_pretty(mlir_file: Path, top_module: str, inputs: List[List[tuple[int, int]]]) -> None:
    kcirct = KCIRCT()
    file_name = 'setup.kore'
    pretty_name = file_name + '.pretty'
    kcirct.write_pretty(mlir_file.parent / file_name, mlir_file.parent / pretty_name)


def test_pretty() -> None:
    nowtest = 'hw'
    for i, dir in enumerate(DIRS[nowtest]):
        # if dir.name not in ['parity','icmp'] :
        if dir.name == 'instance':
            test_print_pretty(MLIR_GNERIC_FILES[nowtest][i], EXPECTED_TOP_MODULES[nowtest][i], INPUTS[nowtest][i])


def test_entry() -> None:
    nowtest = 'comb'
    for i, dir in enumerate(DIRS[nowtest]):
        # if dir.name not in ['parity','icmp'] :
        if dir.name == 'mux':
            test_evaluate_operation(MLIR_GNERIC_FILES[nowtest][i], EXPECTED_TOP_MODULES[nowtest][i], INPUTS[nowtest][i])


def test_diffvcd() -> None:
    now = DATA_PATH / Path('operation/seq/firmem_rwl')
    diffvcd(now)


def diffvcd(test_path: Path) -> None:
    # 构建完整的命令
    vcd_file1 = test_path / 'test.vcd'
    vcd_file2 = test_path / 'trace_vtor.vcd'
    command = ['./scripts/diffvcd.py', str(vcd_file1), str(vcd_file2)]

    # 运行命令并捕获返回值
    result = subprocess.run(command, capture_output=True, text=True)

    # 检查返回值是否为0
    if result.returncode == 0:
        print('diffvcd 成功，返回值为0')
    else:
        print(f'diffvcd 失败，返回值为 {result.returncode}')
        print(f'标准输出: {result.stdout}')
        print(f'标准错误: {result.stderr}')
        pytest.fail(f'diffvcd 失败: {result.stdout}\n 标准错误: {result.stderr}')


if __name__ == '__main__':
    mode = 1
    if mode == 1:
        nowtest = 'comb'
        for i, dir in enumerate(DIRS[nowtest]):
            # if dir.name not in ['parity','icmp'] :
            if dir.name == 'add':
                test_evaluate_operation(
                    MLIR_GNERIC_FILES[nowtest][i], EXPECTED_TOP_MODULES[nowtest][i], INPUTS[nowtest][i]
                )
    elif mode == 0:
        for dialect, operations in DIALECT_OPERATIONS.items():
            for i, dir in enumerate(DIRS[dialect]):
                print(f'{dialect}.{dir.name}')
                if dir.name in operations:
                    test_evaluate_operation(
                        MLIR_GNERIC_FILES[dialect][i], EXPECTED_TOP_MODULES[dialect][i], INPUTS[dialect][i]
                    )
