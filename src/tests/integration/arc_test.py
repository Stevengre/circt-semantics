from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Any, Sequence

from kcirct.api import KCIRCT
from kcirct.vcd import KVCD
from tests.resources import DATA_PATH

ARC_TEST_ROOT = DATA_PATH / 'kcirct-arc-test'
MLIR_ROOT = ARC_TEST_ROOT / 'mlir'
DEFAULT_INPUT_ROOT = ARC_TEST_ROOT / 'inputs'
DIFFVCD = DATA_PATH.parents[2] / 'scripts' / 'diffvcd.py'

EMPTY_SETUP_CELL = "Lbl'-LT-'setup'-GT-'{}(dotk{}())"


class InputProtocol(str, Enum):
    FLAT = 'flat'
    EVENTS = 'events'


@dataclass(frozen=True)
class ArcTestCase:
    key: str
    project: str
    mlir_name: str
    input_name: str
    input_key: str
    top_module: str
    protocol: InputProtocol
    simulation_calls_per_input: int
    inputs_per_cycle: int = 1
    reference_vcd_name: str | None = None
    k_vcd_top: str | None = None
    reference_vcd_top: str | None = None
    memory_dump: bool = False
    initial_vcd_sample: bool = False
    initial_vcd_skip_missing: bool = False
    sample_start: int = 0
    sample_stride: int = 1
    sample_time_from_input_index: bool = False
    progress_interval: int = 1
    compare_after: int | None = None
    compare_before_input_count: bool = False
    vcd_ignore_patterns: tuple[str, ...] = ()
    assert_setup_finished: bool = False

    @property
    def mlir_dir(self) -> Path:
        return MLIR_ROOT / self.project

    @property
    def mlir_file(self) -> Path:
        return self.mlir_dir / self.mlir_name

    @property
    def input_dir(self) -> Path:
        configured_root = os.environ.get('KCIRCT_ARC_INPUT_ROOT')
        input_root = Path(configured_root).expanduser() if configured_root else DEFAULT_INPUT_ROOT
        return input_root / self.project

    @property
    def input_file(self) -> Path:
        return self.input_dir / self.input_name

    @property
    def reference_vcd(self) -> Path | None:
        if self.reference_vcd_name is None:
            return None
        return self.input_dir / self.reference_vcd_name

    @property
    def work_dir(self) -> Path:
        return self.mlir_dir / '.work' / self.key


@dataclass(frozen=True)
class ArcTestResult:
    cycles: int
    input_evaluations: int
    simulation_calls: int
    vcd_samples: int
    last_vcd_time: int | None
    simulation_runtime: float
    output_vcd: Path


BOOM_CASE = ArcTestCase(
    key='boom',
    project='boom',
    mlir_name='boom-drop.mlir',
    input_name='test_data.json',
    input_key='inputs',
    top_module='BoomSystem',
    protocol=InputProtocol.FLAT,
    simulation_calls_per_input=1,
    inputs_per_cycle=2,
    reference_vcd_name='boom-arcs.vcd',
    k_vcd_top='BoomSystem.BoomSystem',
    reference_vcd_top='BoomSystem',
    memory_dump=True,
    initial_vcd_sample=True,
    initial_vcd_skip_missing=True,
    sample_time_from_input_index=True,
    progress_interval=100,
    compare_after=201,
    compare_before_input_count=True,
    assert_setup_finished=True,
)

RISCINATOR_CASE = ArcTestCase(
    key='riscinator',
    project='riscinator',
    mlir_name='riscinator-drop.mlir',
    input_name='test_data.json',
    input_key='inputs',
    top_module='Core',
    protocol=InputProtocol.FLAT,
    simulation_calls_per_input=2,
    reference_vcd_name='riscinator-itype.vcd',
    k_vcd_top='Core.Core',
    reference_vcd_top='TOP.Core',
    memory_dump=True,
    sample_start=2,
    sample_stride=4,
    vcd_ignore_patterns=(
        r'^\.rf\.regs_ext\.(R[01]|W0)_(addr|data|en)(\[[0-9]+:[0-9]+\])?$',
        r'^\.writeback\.io_ctrl_wb_en$',
    ),
)

ROCKET_CASES = {
    'master': ArcTestCase(
        key='rocket-master',
        project='rocket',
        mlir_name='rocket-small-master-drop.mlir',
        input_name='input_twoedge.json',
        input_key='inin',
        top_module='RocketSystem',
        protocol=InputProtocol.EVENTS,
        simulation_calls_per_input=2,
    ),
    'v1.4': ArcTestCase(
        key='rocket-v1.4',
        project='rocket',
        mlir_name='rocket-small-1.4-drop.mlir',
        input_name='input_1.4twoedge.json',
        input_key='inin',
        top_module='RocketSystem',
        protocol=InputProtocol.EVENTS,
        simulation_calls_per_input=2,
    ),
    'v1.6': ArcTestCase(
        key='rocket-v1.6',
        project='rocket',
        mlir_name='rocket-small-1.6-drop.mlir',
        input_name='input_v1.6.json',
        input_key='inin',
        top_module='RocketSystem',
        protocol=InputProtocol.EVENTS,
        simulation_calls_per_input=1,
    ),
    'v1.6-main': ArcTestCase(
        key='rocket-v1.6-main',
        project='rocket',
        mlir_name='rocket-small-1.6-drop.mlir',
        input_name='input_v1.6start.json',
        input_key='inin',
        top_module='RocketSystem',
        protocol=InputProtocol.EVENTS,
        simulation_calls_per_input=1,
    ),
    'v1.6-two-edge': ArcTestCase(
        key='rocket-v1.6-two-edge',
        project='rocket',
        mlir_name='rocket-small-1.6-drop.mlir',
        input_name='inputv1.6_2edge.json',
        input_key='inin',
        top_module='RocketSystem',
        protocol=InputProtocol.EVENTS,
        simulation_calls_per_input=2,
    ),
}


def get_case(project: str, variant: str | None = None) -> ArcTestCase:
    if project == 'boom':
        if variant is not None:
            raise ValueError('Boom 不支持 variant。')
        return BOOM_CASE
    if project == 'riscinator':
        if variant is not None:
            raise ValueError('Riscinator 不支持 variant。')
        return RISCINATOR_CASE
    if project == 'rocket':
        selected_variant = variant or 'v1.6-two-edge'
        try:
            return ROCKET_CASES[selected_variant]
        except KeyError as err:
            choices = ', '.join(sorted(ROCKET_CASES))
            raise ValueError(f'未知 Rocket variant：{selected_variant}；可选值：{choices}') from err
    raise ValueError(f'未知测试项目：{project}')


def missing_case_files(case: ArcTestCase, compare: bool = True) -> list[Path]:
    required = [case.mlir_file, case.input_file]
    if compare and case.reference_vcd is not None:
        required.append(case.reference_vcd)
    return [path for path in required if not path.is_file()]


def _require_case_files(case: ArcTestCase, compare: bool) -> None:
    missing = missing_case_files(case, compare=compare)
    if not missing:
        return
    missing_text = '\n'.join(f'  - {path}' for path in missing)
    raise FileNotFoundError(
        '缺少 K-CIRCT / Arcilator 对照测试资源：\n'
        f'{missing_text}\n'
        '请在 src/tests/resources/kcirct-arc-test/inputs 挂载新的独立输入子仓库，或通过 '
        'KCIRCT_ARC_INPUT_ROOT 指定具有相同项目布局的输入目录。'
    )


def _read_json_items(case: ArcTestCase) -> list[Any]:
    with case.input_file.open('r', encoding='utf-8') as input_stream:
        document = json.load(input_stream)
    items = document.get(case.input_key)
    if not isinstance(items, list):
        raise ValueError(f'{case.input_file} 缺少列表字段 {case.input_key!r}。')
    return items


def _file_contains(path: Path, expected: str) -> bool:
    expected_bytes = expected.encode()
    overlap = len(expected_bytes) - 1
    previous = b''
    with path.open('rb') as input_stream:
        while chunk := input_stream.read(1024 * 1024):
            candidate = previous + chunk
            if expected_bytes in candidate:
                return True
            previous = candidate[-overlap:] if overlap > 0 else b''
    return False


def _generate_top_state_json(case: ArcTestCase) -> Path:
    all_state_json = case.work_dir / 'state-all.json'
    top_state_json = case.work_dir / 'state.json'
    subprocess.run(
        [
            'arcilator',
            str(case.mlir_file),
            f'--state-file={all_state_json}',
            '--observe-ports',
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    modules = json.loads(all_state_json.read_text(encoding='utf-8'))
    top_modules = [module for module in modules if module.get('name') == case.top_module]
    if len(top_modules) != 1:
        raise RuntimeError(f'期望 state JSON 中恰好有一个 {case.top_module}，实际为 {len(top_modules)} 个。')
    top_state_json.write_text(json.dumps(top_modules), encoding='utf-8')
    return top_state_json


def _prepare_pipeline(case: ArcTestCase) -> tuple[KCIRCT, Path, tuple[float, float, float]]:
    case.work_dir.mkdir(parents=True, exist_ok=True)
    kcirct = KCIRCT()
    kcirct.ensure_env()

    pgm_file = case.work_dir / 'pgm.kore'
    preprocessed_file = case.work_dir / 'preprocessed.kore'
    setup_file = case.work_dir / 'setup.kore'

    pipeline_start = time.perf_counter()
    kcirct.compile_fast(case.mlir_file, pgm_file)
    compile_end = time.perf_counter()
    kcirct.run_preprocess_fast(pgm_file, preprocessed_file)
    preprocess_end = time.perf_counter()
    kcirct.run_setup_fast(preprocessed_file, setup_file, case.top_module)
    setup_end = time.perf_counter()

    timings = (
        compile_end - pipeline_start,
        preprocess_end - compile_end,
        setup_end - preprocess_end,
    )
    print(f'compile_runtime:{timings[0]}', flush=True)
    print(f'preprocess_runtime:{timings[1]}', flush=True)
    print(f'setup_runtime:{timings[2]}', flush=True)

    if case.assert_setup_finished and not _file_contains(setup_file, EMPTY_SETUP_CELL):
        raise RuntimeError(f'{case.top_module} setup 未完成；生成状态中的 <setup> 仍非空。')
    return kcirct, setup_file, timings


def _open_vcd(case: ArcTestCase) -> KVCD:
    output_vcd = case.work_dir / 'kcirct.vcd'
    if output_vcd.exists():
        output_vcd.unlink()
    return KVCD(
        vcd_path=output_vcd,
        mlir_path=case.mlir_file,
        state_json_path=_generate_top_state_json(case),
        memory_dump=case.memory_dump,
    )


def _print_result(result: ArcTestResult) -> None:
    print(f'cycles:{result.cycles}')
    print(f'input_evaluations:{result.input_evaluations}')
    print(f'simulation_calls:{result.simulation_calls}')
    print(f'vcd_samples:{result.vcd_samples}')
    print(f'runtime_per_simulation_step:{result.simulation_runtime / result.simulation_calls}')
    print(f'runtime_per_cicle:{result.simulation_runtime / result.cycles}')
    if result.vcd_samples:
        print(f'runtime_per_vcd_tick:{result.simulation_runtime / result.vcd_samples}')
    print(f'runtime_total:{result.simulation_runtime}')


def _run_flat_case(
    case: ArcTestCase,
    kcirct: KCIRCT,
    setup_file: Path,
    items: list[Any],
    cycles: int | None,
) -> ArcTestResult:
    if cycles is not None:
        required_items = cycles * case.inputs_per_cycle
        if len(items) < required_items:
            raise ValueError(f'{case.input_file} 只有 {len(items)} 条输入，需要 {required_items} 条。')
        items = items[:required_items]
    if len(items) % case.inputs_per_cycle != 0:
        raise ValueError(f'输入数量 {len(items)} 不能被每周期输入数 {case.inputs_per_cycle} 整除。')

    state_files = [case.work_dir / 'simulated.0.kore', case.work_dir / 'simulated.1.kore']
    shutil.copyfile(setup_file, state_files[0])
    current_state = 0
    simulation_runtime = 0.0
    simulation_calls = 0
    vcd_samples = 0
    last_vcd_time: int | None = None
    vcd = _open_vcd(case)

    try:
        if case.initial_vcd_sample:
            vcd.time = 0
            vcd.dump(kcirct.read_ports_fast(state_files[current_state], skip_missing=case.initial_vcd_skip_missing))
            vcd_samples += 1
            last_vcd_time = vcd.time

        for input_index, input_data in enumerate(items):
            step_start = time.perf_counter()
            for _ in range(case.simulation_calls_per_input):
                kcirct.run_simulate_fast(
                    state_files[current_state],
                    state_files[current_state ^ 1],
                    input_data,
                )
                current_state ^= 1
                simulation_calls += 1
            simulation_runtime += time.perf_counter() - step_start

            should_sample = (
                input_index >= case.sample_start and (input_index - case.sample_start) % case.sample_stride == 0
            )
            if should_sample:
                vcd.time = input_index + 1 if case.sample_time_from_input_index else vcd_samples
                vcd.dump(kcirct.read_ports_fast(state_files[current_state]))
                vcd_samples += 1
                last_vcd_time = vcd.time
                if case.progress_interval > 0 and vcd.time % case.progress_interval == 0:
                    print(f'vcd_dump:{vcd.time}', flush=True)
    finally:
        vcd.close()

    result = ArcTestResult(
        cycles=len(items) // case.inputs_per_cycle,
        input_evaluations=len(items),
        simulation_calls=simulation_calls,
        vcd_samples=vcd_samples,
        last_vcd_time=last_vcd_time,
        simulation_runtime=simulation_runtime,
        output_vcd=case.work_dir / 'kcirct.vcd',
    )
    _print_result(result)
    return result


def _run_event_case(
    case: ArcTestCase,
    kcirct: KCIRCT,
    setup_file: Path,
    events: list[Any],
    cycles: int | None,
) -> ArcTestResult:
    state_files = [case.work_dir / 'simulated.0.kore', case.work_dir / 'simulated.1.kore']
    shutil.copyfile(setup_file, state_files[0])
    current_state = 0
    simulation_runtime = 0.0
    simulation_calls = 0
    input_evaluations = 0
    vcd_samples = 0
    last_vcd_time: int | None = None
    vcd = _open_vcd(case)

    try:
        for event in events:
            if not isinstance(event, dict):
                raise ValueError(f'{case.input_file} 中的 event 必须是对象：{event!r}')
            if 'input' in event:
                if cycles is not None and input_evaluations >= cycles:
                    break
                step_start = time.perf_counter()
                for _ in range(case.simulation_calls_per_input):
                    kcirct.run_simulate_fast(
                        state_files[current_state],
                        state_files[current_state ^ 1],
                        event['input'],
                    )
                    current_state ^= 1
                    simulation_calls += 1
                simulation_runtime += time.perf_counter() - step_start
                input_evaluations += 1
            elif 'vcd_dump' in event:
                vcd.time = int(event['vcd_dump'])
                vcd.dump(kcirct.read_ports_fast(state_files[current_state]))
                vcd_samples += 1
                last_vcd_time = vcd.time
                print(f'vcd_dump:{vcd.time}', flush=True)
            else:
                raise ValueError(f'{case.input_file} 中的 event 缺少 input 或 vcd_dump：{event!r}')
    finally:
        vcd.close()

    if input_evaluations == 0:
        raise ValueError(f'{case.input_file} 没有可执行的 input event。')
    result = ArcTestResult(
        cycles=input_evaluations,
        input_evaluations=input_evaluations,
        simulation_calls=simulation_calls,
        vcd_samples=vcd_samples,
        last_vcd_time=last_vcd_time,
        simulation_runtime=simulation_runtime,
        output_vcd=case.work_dir / 'kcirct.vcd',
    )
    _print_result(result)
    return result


def _compare_vcd(case: ArcTestCase, result: ArcTestResult, compare_after: int | None) -> None:
    reference_vcd = case.reference_vcd
    if reference_vcd is None:
        print('vcd_compare:skipped(no reference VCD configured)')
        return
    if result.vcd_samples == 0 or result.last_vcd_time is None:
        raise RuntimeError('生成的 K-CIRCT VCD 没有采样点，拒绝把空比较当作通过。')
    if compare_after is not None and compare_after > result.last_vcd_time:
        raise RuntimeError(
            f'diffvcd 起点 {compare_after} 晚于 K-CIRCT VCD 最后采样时间 '
            f'{result.last_vcd_time}，拒绝执行空窗口比较。'
        )

    command = [str(DIFFVCD), str(result.output_vcd), str(reference_vcd)]
    if case.k_vcd_top is not None:
        command.extend(['--top1', case.k_vcd_top])
    if case.reference_vcd_top is not None:
        command.extend(['--top2', case.reference_vcd_top])
    if case.compare_before_input_count:
        command.extend(['--before', str(result.input_evaluations)])
    if compare_after is not None:
        command.extend(['--after', str(compare_after)])
    for pattern in case.vcd_ignore_patterns:
        command.extend(['--ignore', pattern])
    command.append('--verbose')

    completed = subprocess.run(command, capture_output=True, text=True)
    print(completed.stdout, end='')
    print(completed.stderr, end='')
    if completed.returncode != 0:
        raise RuntimeError(f'diffvcd 返回值为 {completed.returncode}')
    print('vcd_compare:passed')


def run_case(
    case: ArcTestCase,
    *,
    cycles: int | None = None,
    compare: bool = True,
    compare_after: int | None = None,
) -> ArcTestResult:
    if cycles is not None and cycles <= 0:
        raise ValueError(f'cycles 必须为正整数，实际为 {cycles}。')
    if compare_after is not None and compare_after < 0:
        raise ValueError(f'compare_after 必须为非负整数，实际为 {compare_after}。')
    _require_case_files(case, compare=compare)
    items = _read_json_items(case)
    if not items:
        raise ValueError(f'{case.input_file} 的 {case.input_key!r} 列表为空。')
    print(f'case:{case.key}')
    print(f'mlir:{case.mlir_file}')
    print(f'input:{case.input_file}')
    print(f'work_dir:{case.work_dir}')

    kcirct, setup_file, _ = _prepare_pipeline(case)
    if case.protocol is InputProtocol.FLAT:
        result = _run_flat_case(case, kcirct, setup_file, items, cycles)
    else:
        result = _run_event_case(case, kcirct, setup_file, items, cycles)

    if compare:
        selected_after = case.compare_after if compare_after is None else compare_after
        _compare_vcd(case, result, selected_after)
    return result


def run_named_case(
    project: str,
    *,
    variant: str | None = None,
    cycles: int | None = None,
    compare: bool = True,
    compare_after: int | None = None,
) -> ArcTestResult:
    return run_case(
        get_case(project, variant),
        cycles=cycles,
        compare=compare,
        compare_after=compare_after,
    )


def _argument_parser(project: str | None = None) -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description='运行统一的 K-CIRCT / Arcilator 对照测试。')
    if project is None:
        parser.add_argument('project', choices=('riscinator', 'boom', 'rocket'))
    if project is None or project == 'rocket':
        parser.add_argument('--variant', choices=tuple(sorted(ROCKET_CASES)), help='Rocket 配置，默认 v1.6-two-edge。')
    else:
        parser.set_defaults(variant=None)
    cycles_help = '限制测试周期数。'
    if project is None:
        cycles_help += ' Rocket 按 input event 计数；Boom 未指定时使用 KCIRCT_BOOM_CYCLES 或 1000。'
    elif project == 'boom':
        cycles_help += ' 默认使用 KCIRCT_BOOM_CYCLES 或 1000。'
    elif project == 'rocket':
        cycles_help += ' 每个 input event 计一个周期；two-edge 配置每周期调用两次 simulate。'
    parser.add_argument('--cycles', type=int, help=cycles_help)
    if project is None or project == 'boom':
        parser.add_argument('--compare-after', type=int, help='传给 diffvcd --after；Boom 默认使用 201。')
    else:
        parser.set_defaults(compare_after=None)
    parser.add_argument('--no-compare', action='store_true', help='只生成 K-CIRCT VCD，不运行 diffvcd。')
    parser.add_argument('--input-root', type=Path, help='覆盖 inputs 子仓库路径。')
    return parser


def main(argv: Sequence[str] | None = None, *, project: str | None = None) -> int:
    parser = _argument_parser(project)
    args = parser.parse_args(argv)
    selected_project = project or args.project
    if selected_project != 'rocket' and args.variant is not None:
        parser.error('--variant 仅适用于 Rocket。')
    if selected_project != 'boom' and args.compare_after is not None:
        parser.error('--compare-after 仅适用于 Boom。')
    if args.input_root is not None:
        os.environ['KCIRCT_ARC_INPUT_ROOT'] = str(args.input_root)

    cycles = args.cycles
    if selected_project == 'boom' and cycles is None:
        cycles = int(os.environ.get('KCIRCT_BOOM_CYCLES', '1000'))
    compare_after = args.compare_after
    if selected_project == 'boom' and compare_after is None:
        compare_after = int(os.environ.get('KCIRCT_BOOM_VCD_AFTER', '201'))

    try:
        run_named_case(
            selected_project,
            variant=args.variant,
            cycles=cycles,
            compare=not args.no_compare,
            compare_after=compare_after,
        )
    except FileNotFoundError as err:
        print(err, file=sys.stderr)
        return 2
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
