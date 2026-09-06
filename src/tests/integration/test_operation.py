from __future__ import annotations

import json
import re
import subprocess
import sys
import time
from decimal import Decimal
from pathlib import Path
from typing import List

import pytest
from vcdvcd import VCDVCD

from kcirct.api import KCIRCT
from kcirct.vcd import KVCD

from ..resources import DATA_PATH
from ..resources.operation import (
    DIALECT_OPERATIONS,
    DIRS,
    EXPECTED_TOP_MODULES,
    INPUTS,
    MLIR_GNERIC_FILES,
    OPERATION_EVALUATIONS_PER_INPUT_2,
    OPERATION_ONLY_CHECK_DOWN_EDGE,
)

TEST_MLIR_GNERIC_FILES = []
TEST_EXPECTED_TOP_MODULES = []
TEST_INPUT = []
REPLAY_POSEDGE = []

for dialect, operations in DIALECT_OPERATIONS.items():
    for i, dir in enumerate(DIRS[dialect]):
        print(f'{dialect}.{dir.name}')
        if dir.name in operations:
            TEST_MLIR_GNERIC_FILES.append(MLIR_GNERIC_FILES[dialect][i])
            TEST_EXPECTED_TOP_MODULES.append(EXPECTED_TOP_MODULES[dialect][i])
            TEST_INPUT.append(INPUTS[dialect][i])
            if dir.name in OPERATION_ONLY_CHECK_DOWN_EDGE:
                REPLAY_POSEDGE.append(True)
            else:
                REPLAY_POSEDGE.append(False)


def test_make_env() -> None:
    kcirct = KCIRCT()
    kcirct.ensure_env()


def required_port_manifest(test_path: Path) -> dict:
    manifest = json.loads((test_path / 'ports.json').read_text())
    generic_files = list(test_path.glob('*.generic.mlir'))
    assert len(generic_files) == 1, '端口清单案例必须有唯一 generic MLIR'
    module_types = re.findall(r'\bmodule_type\s*=\s*!hw.modty<([^>]*)>', generic_files[0].read_text())
    assert len(module_types) == 1, '端口清单案例必须声明唯一顶层模块'
    actual_ports = []
    for declaration in module_types[0].split(','):
        match = re.fullmatch(r'\s*(input|output)\s+([A-Za-z_]\w*)\s*:\s*i([1-9][0-9]*)\s*', declaration)
        assert match, f'端口清单案例要求顶层正位宽整数端口：{declaration}'
        direction, name, width = match.groups()
        actual_ports.append((direction, name, int(width)))
    expected_ports = [
        (direction, port['name'], port['width'])
        for direction in ('input', 'output')
        for port in manifest[direction + 's']
    ]
    assert actual_ports == expected_ports, 'ports.json 必须完整匹配 generic MLIR 的端口方向、顺序、名称与位宽'
    return manifest


@pytest.mark.parametrize(
    'mlir_file, top_module, inputs, replay_posedge',
    zip(TEST_MLIR_GNERIC_FILES, TEST_EXPECTED_TOP_MODULES, TEST_INPUT, REPLAY_POSEDGE, strict=True),
    ids=[str(p) for p in TEST_MLIR_GNERIC_FILES],
)
def test_evaluate_operation(
    mlir_file: Path, top_module: str, inputs: List[List[tuple[int, int]]], replay_posedge: bool
) -> None:

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

    vcd_path = mlir_file.parent / 'test.vcd'
    if vcd_path.exists():
        vcd_path.unlink()
    strict_ports = (mlir_file.parent / 'ports.json').is_file()
    repeat_every_input = mlir_file.parent.name in OPERATION_EVALUATIONS_PER_INPUT_2
    state_json_path = None
    required_ports = {}
    if strict_ports:
        # 顶层端口清单直接用于 VCD 声明，避免 arcilator 对数组反馈的转换限制。
        # 每次 dump 仍要求 K 返回全部真实端口及正确位宽，清单不提供任何期望值。
        manifest = required_port_manifest(mlir_file.parent)
        states = []
        for direction in ('input', 'output'):
            for port in manifest[direction + 's']:
                states.append({'name': port['name'], 'numBits': port['width'], 'type': direction})
                required_ports[f"{top_module}/{port['name']}"] = port['width']
        state_json_path = mlir_file.parent / 'state.json'
        state_json_path.write_text(json.dumps([{'name': top_module, 'states': states}], indent=2) + '\n')
    vcd = KVCD(
        vcd_path=vcd_path,
        mlir_path=mlir_file,
        state_json_path=state_json_path,
        time_scale='1ns' if strict_ports else '1s',
    )

    def dump_ports(state_path: Path) -> None:
        ports = kcirct.read_ports_fast(state_path)
        if strict_ports:
            for name, width in required_ports.items():
                assert name in ports, f'K 状态缺少必要端口 {name}'
                assert ports[name][1] == width, f'K 端口 {name} 位宽错误'
            ports = {name: ports[name] for name in required_ports}
        vcd.dump(ports)

    vcd.time = 0
    rounds = 0
    if len(inputs) == 0:
        input = None
        start_time = time.time()
        kcirct.krun_fast(mlir_file.parent / 'setup.kore', mlir_file.parent / f'simulated.{rounds&1}.kore')
        end_time = time.time()
        dump_ports(mlir_file.parent / f'simulated.{rounds&1}.kore')
        rounds += 1
        print(str(vcd.time) + str(mlir_file))
        print('runtime:' + str(end_time - start_time))
    else:
        input = inputs[0]
        start_time = time.time()
        kcirct.run_simulate_fast(
            mlir_file.parent / 'setup.kore', mlir_file.parent / f'simulated.{rounds&1}.kore', input
        )
        end_time = time.time()
        rounds += 1
        tot_time = end_time - start_time

        if repeat_every_input or (replay_posedge and vcd.time % 2 == 0):
            kcirct.run_simulate_fast(
                mlir_file.parent / f'simulated.{(rounds-1)&1}.kore',
                mlir_file.parent / f'simulated.{rounds&1}.kore',
                input,
            )
            rounds += 1
        dump_ports(mlir_file.parent / f'simulated.{(rounds-1)&1}.kore')

        for input in inputs[1:]:
            vcd.time += 1
            start_time = time.time()
            kcirct.run_simulate_fast(
                mlir_file.parent / f'simulated.{(rounds-1)&1}.kore',
                mlir_file.parent / f'simulated.{rounds&1}.kore',
                input,
            )
            rounds += 1
            if repeat_every_input or (replay_posedge and vcd.time % 2 == 0):
                kcirct.run_simulate_fast(
                    mlir_file.parent / f'simulated.{(rounds-1)&1}.kore',
                    mlir_file.parent / f'simulated.{rounds&1}.kore',
                    input,
                )
                rounds += 1
            end_time = time.time()
            tot_time += end_time - start_time
            # print(str(vcd.time) + str(mlir_file))
            dump_ports(mlir_file.parent / f'simulated.{(rounds-1)&1}.kore')
        print('runtime:' + str((end_time - start_time) / len(inputs)))

    # 确保后续 diffvcd 读取到完整波形，而不是尚未刷新的缓冲内容。
    vcd.close()


@pytest.mark.parametrize(
    'mlir_file',
    TEST_MLIR_GNERIC_FILES,
    ids=[str(p) for p in TEST_MLIR_GNERIC_FILES],
)
def test_diffvcd_operatrion(mlir_file: Path) -> None:
    diffvcd(mlir_file.parent)


def test_print_pretty(mlir_file: Path) -> None:
    kcirct = KCIRCT()
    file_name = 'simulated.0.kore'
    pretty_name = file_name + '.pretty'
    kcirct.write_pretty(mlir_file.parent / file_name, mlir_file.parent / pretty_name)


def test_pretty() -> None:
    nowtest = 'sv'
    for i, dir in enumerate(DIRS[nowtest]):
        # if dir.name not in ['parity','icmp'] :
        if dir.name == 'assert':
            test_print_pretty(MLIR_GNERIC_FILES[nowtest][i])


def test_entry() -> None:
    nowtest = 'comb'
    for i, dir in enumerate(DIRS[nowtest]):
        # if dir.name not in ['parity','icmp'] :
        if dir.name == 'mux':
            test_evaluate_operation(
                MLIR_GNERIC_FILES[nowtest][i], EXPECTED_TOP_MODULES[nowtest][i], INPUTS[nowtest][i], False
            )


def test_diffvcd() -> None:
    now = DATA_PATH / Path('operation/seq/firmem_rwl')
    diffvcd(now)


def diffvcd(test_path: Path) -> None:
    # 构建完整的命令
    vcd_file1 = test_path / 'test.vcd'
    vcd_file2 = test_path / 'trace_vtor.vcd'
    command = ['./scripts/diffvcd.py', str(vcd_file1), str(vcd_file2), '--ignore-missing-signals']

    ports_file = test_path / 'ports.json'
    if ports_file.is_file():
        # 明确枚举全部端口，防止只比较两份 VCD 的信号交集而误报成功。
        manifest = required_port_manifest(test_path)
        ports = manifest['inputs'] + manifest['outputs']
        event_count = len(json.loads((test_path / 'test_data.json').read_text())['inputs'])
        assert event_count > 0, '输入事件不能为空'
        references = [
            f"Foo.{port['name']}" + (f"[{port['width'] - 1}:0]" if port['width'] > 1 else '') for port in ports
        ]
        for vcd_file in (vcd_file1, vcd_file2):
            waveform = VCDVCD(str(vcd_file))
            assert waveform.timescale['timescale'] == Decimal('1e-9'), f'{vcd_file}: 必须使用 1ns'
            assert waveform.begintime == 0 and waveform.endtime == event_count - 1, f'{vcd_file}: 时间窗口不完整'
            for port, reference in zip(ports, references, strict=True):
                assert reference in waveform.signals, f'{vcd_file}: 缺少必要端口 {reference}'
                signal = waveform[reference]
                assert int(signal.size) == port['width'], f'{vcd_file}: {reference} 位宽错误'
                assert signal.tv and signal.tv[0][0] == 0, f'{vcd_file}: {reference} 没有初始采样'
                for timestamp in range(event_count):
                    value = signal[timestamp]
                    assert (
                        value and set(value) <= {'0', '1'} and len(value) <= port['width']
                    ), f'{vcd_file}: {reference} 在事件 {timestamp} 未定义或位宽错误'
        command = [
            sys.executable,
            './scripts/diffvcd.py',
            str(vcd_file1),
            str(vcd_file2),
            '--filter',
            '^(?:' + '|'.join(re.escape(reference) for reference in references) + ')$',
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
        pytest.fail(f'diffvcd 失败: {result.stdout}\n 标准错误: {result.stderr}')


if __name__ == '__main__':
    mode = 1
    if mode == 1:
        nowtest = 'sv'
        for i, dir in enumerate(DIRS[nowtest]):
            # if dir.name not in ['parity','icmp'] :
            if dir.name == 'assert':
                test_evaluate_operation(
                    MLIR_GNERIC_FILES[nowtest][i], EXPECTED_TOP_MODULES[nowtest][i], INPUTS[nowtest][i], False
                )
    elif mode == 0:
        for dialect, operations in DIALECT_OPERATIONS.items():
            for i, dir in enumerate(DIRS[dialect]):
                print(f'{dialect}.{dir.name}')
                if dir.name in operations:
                    test_evaluate_operation(
                        MLIR_GNERIC_FILES[dialect][i], EXPECTED_TOP_MODULES[dialect][i], INPUTS[dialect][i], False
                    )
