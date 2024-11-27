from __future__ import annotations

import timeit
from pathlib import Path
from typing import TYPE_CHECKING, List

import pytest,subprocess

from kcirct.api import KCIRCT
from kcirct.vcd import KVCD

from ..resources.operation import (
    DATA_PATH,
    COMB_DIRS,
    COMB_MLIR_GNERIC_FILES,
    COMB_EXPECTED_TOP_MODULES,
    COMB_INPUTS,
    COMB_TEST_IDS,
    DIRS,
    TEST_IDS,
    MLIR_FILES,
    MLIR_GNERIC_FILES,
    EXPECTED_TOP_MODULES,
    INPUTS,
)

if TYPE_CHECKING:
    from pathlib import Path


@pytest.mark.parametrize(
    'mlir_file, top_module, inputs',
    zip(COMB_MLIR_GNERIC_FILES, COMB_EXPECTED_TOP_MODULES, COMB_INPUTS, strict=True),
    ids=COMB_TEST_IDS,
)
def test_evaluate_demo(mlir_file: Path, top_module: str, inputs: List[List[tuple[int, int]]]) -> None:

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
    vcd = KVCD(vcd_path=mlir_file.parent / f'test.vcd', mlir_path=mlir_file)
    vcd.time = 0
    
    if len(inputs) == 0:
        input = None
        kcirct.krun_fast(mlir_file.parent / 'setup.kore',mlir_file.parent / f'simulated.{vcd.time&1}.kore')
        vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))
        print(str(vcd.time)+str(mlir_file))
    else:
        input = inputs[0]
        kcirct.run_simulate_fast(mlir_file.parent / 'setup.kore', mlir_file.parent / f'simulated.{vcd.time&1}.kore', input)
        vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))
        for input in inputs[1:]:
            vcd.time += 1
            kcirct.run_simulate_fast(
                mlir_file.parent / f'simulated.{(vcd.time-1)&1}.kore', mlir_file.parent / f'simulated.{vcd.time&1}.kore', input
            )
            print(str(vcd.time)+str(mlir_file))
            vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{vcd.time&1}.kore'))



def test_diffvcd(test_path: Path)->None:
    #我要通过subprocess调用./diffvcd.py test_path/trace_vtor.vcd test_path/test.vcd并想知道它的返回值是不是0
    return


def test_entry()->None:
    nowtest = 'sv'
    for i,dir in enumerate(DIRS[nowtest]):
        # if dir.name not in ['parity','icmp'] :
        if dir.name == 'error':
            test_evaluate_demo(MLIR_GNERIC_FILES[nowtest][i],EXPECTED_TOP_MODULES[nowtest][i],
                                INPUTS[nowtest][i])


def test_diffvcd(now: Path | None = None) -> None:
    test_path = Path('/home/zjh/proj/cym-circt-semantics/src/tests/resources/operation/')
    now = 'comb/mods'
    test_path = test_path / now
    # 构建完整的命令
    vcd_file1 = test_path / 'test.vcd'
    vcd_file2 = test_path / 'trace_vtor.vcd'
    command = ['./scripts/diffvcd.py', str(vcd_file1), str(vcd_file2)]
    
    # 运行命令并捕获返回值
    result = subprocess.run(command, capture_output=True, text=True)
    
    # 检查返回值是否为0
    if result.returncode == 0:
        print("diffvcd 成功，返回值为0")
    else:
        print(f"diffvcd 失败，返回值为 {result.returncode}")
        print(f"标准输出: {result.stdout}")
        print(f"标准错误: {result.stderr}")

if __name__ == '__main__':
    nowtest = 'comb'
    for i,dir in enumerate(DIRS[nowtest]):
        # if dir.name not in ['parity','icmp'] :
        if dir.name == 'shrs':
            test_evaluate_demo(MLIR_GNERIC_FILES[nowtest][i],EXPECTED_TOP_MODULES[nowtest][i],
                                INPUTS[nowtest][i])