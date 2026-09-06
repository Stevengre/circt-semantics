"""通过文件和命令行驱动 Kimulator，保存可复查的仿真工件。"""

from __future__ import annotations

import gzip
import hashlib
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import time
from dataclasses import asdict, dataclass
from functools import partial
from importlib.metadata import version
from pathlib import Path
from typing import TYPE_CHECKING, Any

from pyk.kdist import kdist

from .api import KCIRCT
from .vcd import KVCD

if TYPE_CHECKING:
    from collections.abc import Callable

_IDENTIFIER = r'[A-Za-z_][A-Za-z0-9_.$-]*'


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def _json(path: Path, value: Any) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def _tool(name: str) -> str:
    configured = os.environ.get('K_BIN') if name in {'krun', 'kast', 'kompile'} else None
    sibling = Path(sys.executable).absolute().parent / name
    executable: str | None
    if configured:
        executable = str(Path(configured).expanduser() / name)
    elif name == 'kdist' and sibling.is_file() and os.access(sibling, os.X_OK):
        executable = str(sibling)
    else:
        executable = shutil.which(name)
    if executable is None or not Path(executable).is_file() or not os.access(executable, os.X_OK):
        raise FileNotFoundError(f'找不到可执行工具 {name}，请通过 PATH 或 K_BIN 配置 K 工具链')
    return str(Path(executable).absolute())


def describe_simulator() -> dict[str, Any]:
    """公开当前安装身份，外部调用方无需导入 Python 实现。"""
    package = Path(__file__).resolve().parent
    tools: dict[str, Any] = {}
    for name in ('krun', 'kast', 'kompile', 'kdist'):
        try:
            executable = _tool(name)
            item: dict[str, Any] = {'path': executable}
            if name != 'kdist':
                process = subprocess.run([executable, '--version'], capture_output=True, text=True, timeout=10)
                item['version'] = (process.stdout + process.stderr).strip()
                item['returncode'] = process.returncode
            tools[name] = item
        except (OSError, subprocess.TimeoutExpired) as error:
            tools[name] = {'path': None, 'error': str(error)}
    semantics = package / 'kdist' / 'circt_semantics'
    return {
        'schema_version': 1,
        'package_version': version('kcirct'),
        'kframework_version': version('kframework'),
        'python_executable': sys.executable,
        'source_root': str(package.parent.parent),
        'package_dir': str(package),
        'api_sha256': _sha256(package / 'api.py'),
        'simulator_sha256': _sha256(Path(__file__)),
        'kdist_plugin_sha256': _sha256(package / 'kdist' / 'plugin.py'),
        'semantics_hashes': {
            str(path.relative_to(semantics)): _sha256(path)
            for path in sorted(semantics.rglob('*'))
            if path.is_file() and path.suffix in {'.k', '.md'}
        },
        'tools': tools,
    }


@dataclass(frozen=True)
class Port:
    name: str
    width: int


def _balanced_end(text: str, start: int, opening: str, closing: str) -> int:
    """找到分隔符末尾，跳过字符串及 MLIR 注释。"""
    depth, index = 0, start
    while index < len(text):
        if text.startswith('//', index):
            index = text.find('\n', index)
            if index == -1:
                break
        elif text.startswith('/*', index):
            end = text.find('*/', index + 2)
            if end == -1:
                break
            index = end + 2
            continue
        elif text[index] == '"':
            index += 1
            while index < len(text) and text[index] != '"':
                index += 2 if text[index] == '\\' else 1
        elif text[index] == opening:
            depth += 1
        elif text[index] == closing:
            depth -= 1
            if depth == 0:
                return index + 1
        index += 1
    raise ValueError(f'Generic MLIR 在位置 {start} 缺少匹配的 {closing}')


def read_port_schema(mlir: Path, top_module: str) -> tuple[list[Port], list[Port]]:
    """读取 generic hw.module 的 module_type，保留真实端口顺序。"""
    if re.fullmatch(_IDENTIFIER, top_module) is None:
        raise ValueError('顶层模块名必须是普通 MLIR 标识符')
    text = mlir.read_text(encoding='utf-8')
    matches: list[str] = []
    for operation in re.finditer(r'"hw\.module"\s*\(', text):
        cursor = _balanced_end(text, operation.end() - 1, '(', ')')
        attributes: list[str] = []
        cursor += len(text[cursor:]) - len(text[cursor:].lstrip())
        if text.startswith('<{', cursor):
            end = _balanced_end(text, cursor + 1, '{', '}')
            attributes.append(text[cursor + 1 : end])
            if text[end : end + 1] != '>':
                raise ValueError('Generic hw.module 的 properties 缺少 >')
            cursor = end + 1
        cursor += len(text[cursor:]) - len(text[cursor:].lstrip())
        if text[cursor : cursor + 1] == '(':
            cursor = _balanced_end(text, cursor, '(', ')')
        cursor += len(text[cursor:]) - len(text[cursor:].lstrip())
        if text[cursor : cursor + 1] == '{':
            end = _balanced_end(text, cursor, '{', '}')
            attributes.append(text[cursor:end])
        attribute_text = ' '.join(attributes)
        symbol = re.search(r'\bsym_name\s*=\s*"([^"\\]+)"', attribute_text)
        if symbol is not None and symbol.group(1) == top_module:
            matches.append(attribute_text)
    if len(matches) != 1:
        raise ValueError(f'需要唯一的 generic hw.module {top_module}，实际找到 {len(matches)} 个')
    module_type = re.search(r'\bmodule_type\s*=\s*!hw\.modty\s*<', matches[0])
    if module_type is None:
        raise ValueError(f'{top_module} 缺少 module_type = !hw.modty<...>')
    start = module_type.end() - 1
    end = _balanced_end(matches[0], start, '<', '>')
    inputs: list[Port] = []
    outputs: list[Port] = []
    names: set[str] = set()
    for item in matches[0][start + 1 : end - 1].split(','):
        port = re.fullmatch(rf'\s*(input|output)\s+({_IDENTIFIER}|"{_IDENTIFIER}")\s*:\s*i([1-9]\d*)\s*', item)
        if port is None:
            raise ValueError(f'暂仅支持顶层 input/output iN 整数端口，不支持：{item.strip()}')
        direction, name, width = port.groups()
        name = name.strip('"')
        if name in names:
            raise ValueError(f'重复的顶层端口名：{name}')
        names.add(name)
        (inputs if direction == 'input' else outputs).append(Port(name, int(width)))
    if not inputs:
        raise ValueError('仿真至少需要一个顶层输入端口')
    return inputs, outputs


def read_events(path: Path, inputs: list[Port]) -> tuple[str, list[dict[str, Any]]]:
    """校验完整、按名称给定的输入事件；拒绝隐式保持及截断。"""

    def unique_keys(items: list[tuple[str, Any]]) -> dict[str, Any]:
        result: dict[str, Any] = {}
        for key, value in items:
            if key in result:
                raise ValueError(f'输入 JSON 含重复字段：{key}')
            result[key] = value
        return result

    document = json.loads(path.read_text(encoding='utf-8'), object_pairs_hook=unique_keys)
    if not isinstance(document, dict) or type(document.get('schema_version')) is not int:
        raise ValueError('输入 JSON 必须包含整数 schema_version: 1')
    if document['schema_version'] != 1 or set(document) != {'schema_version', 'timescale', 'events'}:
        raise ValueError('输入 JSON 仅允许 schema_version: 1、timescale 和 events 三个字段')
    timescale = document['timescale']
    if not isinstance(timescale, str) or re.fullmatch(r'(1|10|100)(s|ms|us|ns|ps|fs)', timescale) is None:
        raise ValueError('timescale 应为 1ns、10ps 等有效 VCD 时间单位')
    events = document['events']
    if not isinstance(events, list) or not events:
        raise ValueError('events 必须是非空事件数组')
    previous = -1
    expected = {port.name for port in inputs}
    for index, event in enumerate(events):
        if not isinstance(event, dict) or set(event) != {'time', 'inputs'}:
            raise ValueError(f'事件 {index} 仅允许 time 和 inputs 两个字段')
        timestamp = event['time']
        if type(timestamp) is not int or timestamp <= previous:
            raise ValueError(f'事件 {index} 的 time 必须是非负、严格递增的整数')
        previous = timestamp
        values = event['inputs']
        if not isinstance(values, dict) or set(values) != expected:
            actual = set(values) if isinstance(values, dict) else set()
            raise ValueError(
                f'事件 {index} 输入不完整：缺少 {sorted(expected - actual)}，未知 {sorted(actual - expected)}'
            )
        for port in inputs:
            value = values[port.name]
            if type(value) is not int or not 0 <= value < 1 << port.width:
                raise ValueError(f'事件 {index} 的 {port.name} 必须是 [0, 2^{port.width}) 内的整数位模式，不能是 bool')
    return timescale, events


class CommandExecutor:
    """隔离子进程、限制单次命令时间并保留 stdout/stderr。"""

    def __init__(self, work_dir: Path, timeout: float) -> None:
        self.work_dir = work_dir
        self.timeout = timeout
        self.sequence = 0

    def run(self, command: list[str], output: Path | None = None) -> None:
        sequence = self.sequence
        self.sequence += 1
        output = output or self.work_dir / f'command-{sequence:04d}.stdout'
        stderr = self.work_dir / f'command-{sequence:04d}.stderr'
        record: dict[str, Any] = {
            'sequence': sequence,
            'argv': command,
            'cwd': str(self.work_dir),
            'stdout': str(output),
            'stderr': str(stderr),
            'timeout_s': self.timeout,
        }
        start = time.perf_counter()
        try:
            with output.open('wb') as stdout_stream, stderr.open('wb') as stderr_stream:
                process = subprocess.Popen(
                    command, cwd=self.work_dir, stdout=stdout_stream, stderr=stderr_stream, start_new_session=True
                )
                try:
                    process.wait(timeout=self.timeout)
                except (subprocess.TimeoutExpired, KeyboardInterrupt):
                    os.killpg(process.pid, signal.SIGKILL)
                    process.wait()
                    raise
            record['returncode'] = process.returncode
            if process.returncode != 0:
                raise RuntimeError(f'命令执行失败（{process.returncode}）：{command[0]}\n{stderr.read_text()[-8000:]}')
            record['status'] = 'pass'
        except BaseException as error:
            record['status'] = 'timeout' if isinstance(error, subprocess.TimeoutExpired) else 'execution_error'
            record['error'] = str(error)
            raise
        finally:
            record['elapsed_s'] = time.perf_counter() - start
            if output.is_file():
                record['stdout_sha256'] = _sha256(output)
            if stderr.is_file():
                record['stderr_sha256'] = _sha256(stderr)
            with (self.work_dir / 'commands.jsonl').open('a', encoding='utf-8') as stream:
                stream.write(json.dumps(record, ensure_ascii=False) + '\n')


class SimulatorKCIRCT(KCIRCT):
    """复用 KCIRCT 状态转换，只将命令与工件生命周期绑定到本次运行。"""

    def __init__(self, work_dir: Path, definition_dir: Path, parser: Path, executor: CommandExecutor) -> None:
        self.working_dir = work_dir
        self.data_dir = work_dir
        self.parser_dir = parser.parent
        self.definition_dir = definition_dir
        self._kprint = None
        self.parser = parser
        self.executor = executor
        self.krun_executable = _tool('krun')

    def compile_fast(self, file: Path, output_file: Path) -> None:
        self.executor.run([str(self.parser), str(file)], output_file)

    def krun_fast(self, input_file: Path, output_file: Path, depth: int | None = None) -> None:
        command = self.krun_cmd(input_file, depth)
        command[0] = self.krun_executable
        self.executor.run(command, output_file)


def _check_finished(state: Path) -> None:
    text = state.read_text(encoding='utf-8')
    pending = [name for name in ('prog', 'setup', 'cmd') if f"Lbl'-LT-'{name}'-GT-'{{}}(dotk{{}}())" not in text]
    if pending or "Lbl'-LT-'current-info'-GT-'" in text or "Lbl'-LT-'current'-GT-'" in text:
        raise RuntimeError(f'状态尚有待执行内容：{state.name}，未清空 {pending}')


def _read_top_ports(
    kcirct: KCIRCT, state: Path, top: str, inputs: list[Port], outputs: list[Port]
) -> dict[str, tuple[int, int]]:
    # 内部未初始化寄存器可以不进入顶层 VCD；所有声明的顶层端口必须实际有值。
    available = kcirct.read_ports_fast(state, skip_missing=True)
    ports = {}
    for port in inputs + outputs:
        name = f'{top}/{port.name}'
        if name not in available:
            raise ValueError(f'必需的顶层端口缺少采样值：{name}')
        value, width = available[name]
        if width != port.width or type(value) is not int or not 0 <= value < 1 << width:
            raise ValueError(f'顶层端口位宽或值不合法：{name}={value}:{width}，预期 i{port.width}')
        ports[name] = value, width
    return ports


def simulate(
    input_file: Path,
    *,
    top_module: str,
    inputs_file: Path,
    output: Path,
    work_dir: Path,
    evaluations_per_input: int = 2,
    definition_dir: Path | None = None,
    parser: Path | None = None,
    timeout: float = 120,
    keep_states: bool = False,
) -> dict[str, Any]:
    """按输入事件重复求值后写入 VCD；失败也返回并保存结构化结果。"""
    input_file, inputs_file, output, work_dir = (
        path.expanduser().absolute() for path in (input_file, inputs_file, output, work_dir)
    )
    # 不复用旧工作目录，避免一次失败覆盖上次证据。
    work_dir.mkdir(parents=True, exist_ok=False)
    start = time.perf_counter()
    result: dict[str, Any] = {
        'schema_version': 1,
        'package_version': version('kcirct'),
        'kframework_version': version('kframework'),
        'api_sha256': _sha256(Path(__file__).parent / 'api.py'),
        'simulator_sha256': _sha256(Path(__file__)),
        'status': 'execution_error',
        'stage': 'validation',
        'top_module': top_module,
        'input_file': str(input_file),
        'inputs_file': str(inputs_file),
        'vcd_path': str(output),
        'work_dir': str(work_dir),
        'evaluations_per_input': evaluations_per_input,
        'events_completed': 0,
        'simulation_calls': 0,
        'simulation_calls_attempted': 0,
        'timings': dict.fromkeys(('compile', 'preprocess', 'setup', 'execution', 'read_ports', 'state_export'), 0.0),
        'error': None,
    }
    vcd: KVCD | None = None
    current_state: Path | None = None
    archive_index: list[dict[str, Any]] = []

    def timed(name: str, operation: Callable[[], Any]) -> Any:
        section_start = time.perf_counter()
        try:
            return operation()
        finally:
            result['timings'][name] += time.perf_counter() - section_start

    try:
        if type(evaluations_per_input) is not int or evaluations_per_input < 1:
            raise ValueError('evaluations-per-input 必须是正整数；统一时序协议使用 2')
        if not timeout > 0 or timeout == float('inf'):
            raise ValueError('timeout 必须是有限正数（秒）')
        if output.exists() or output.is_symlink():
            raise FileExistsError(f'拒绝覆盖已有 VCD：{output}')
        if output.suffix.lower() != '.vcd':
            raise ValueError('输出文件必须使用 .vcd 后缀，以免与工作目录的 JSON/Kore 工件冲突')
        design = work_dir / 'design.generic.mlir'
        stimulus = work_dir / 'inputs.json'
        shutil.copyfile(input_file, design)
        shutil.copyfile(inputs_file, stimulus)
        result['input_sha256'] = _sha256(design)
        result['inputs_sha256'] = _sha256(stimulus)
        input_ports, output_ports = read_port_schema(design, top_module)
        result['ports'] = {
            'inputs': [asdict(port) for port in input_ports],
            'outputs': [asdict(port) for port in output_ports],
        }
        timescale, events = read_events(stimulus, input_ports)
        result['timescale'] = timescale
        result['events_total'] = len(events)
        result['stage'] = 'environment'
        definition_dir = (definition_dir or kdist.get('circt-semantics.llvm')).expanduser().resolve()
        for filename in ('definition.kore', 'compiled.bin', 'backend.txt', 'interpreter'):
            if not (definition_dir / filename).is_file():
                raise FileNotFoundError(f'LLVM 语义定义缺少 {filename}：{definition_dir}')
        if (definition_dir / 'backend.txt').read_text().strip() != 'llvm':
            raise ValueError(f'需要 LLVM concrete 定义：{definition_dir}')
        result['definition_dir'] = str(definition_dir)
        result['definition_sha256'] = _sha256(definition_dir / 'definition.kore')
        executor = CommandExecutor(work_dir, timeout)
        if parser is None:
            parser = work_dir / 'parser'
            executor.run(
                [
                    _tool('kast'),
                    str(parser),
                    '--gen-parser',
                    '--bison-stack-max-depth',
                    '1000000000',
                    '--sort',
                    'TopLevel',
                    '--definition',
                    str(definition_dir),
                ]
            )
        parser = parser.expanduser().resolve()
        if not parser.is_file() or not os.access(parser, os.X_OK):
            raise FileNotFoundError(f'parser 不存在或不可执行：{parser}')
        result['parser'] = str(parser)
        result['parser_sha256'] = _sha256(parser)
        kcirct = SimulatorKCIRCT(work_dir, definition_dir, parser, executor)
        compiled, preprocessed, setup = (
            work_dir / filename for filename in ('pgm.kore', 'preprocessed.kore', 'setup.kore')
        )
        for name, action in (
            ('compile', lambda: kcirct.compile_fast(design, compiled)),
            ('preprocess', lambda: kcirct.run_preprocess_fast(compiled, preprocessed)),
            ('setup', lambda: kcirct.run_setup_fast(preprocessed, setup, top_module)),
        ):
            result['stage'] = name
            timed(name, action)
        current_state = setup
        _check_finished(current_state)
        state_json = work_dir / 'state.json'
        _json(
            state_json,
            [
                {
                    'name': top_module,
                    'states': [
                        {'name': port.name, 'numBits': port.width, 'type': direction}
                        for direction, ports in (('input', input_ports), ('output', output_ports))
                        for port in ports
                    ],
                }
            ],
        )
        output.parent.mkdir(parents=True, exist_ok=True)
        with output.open('x'):
            pass
        vcd = KVCD(output, design, state_json_path=state_json, time_scale=timescale)
        result['stage'] = 'execution'
        states = [work_dir / 'simulated.0.kore', work_dir / 'simulated.1.kore']
        if keep_states:
            (work_dir / 'states').mkdir()
        for event_index, event in enumerate(events):
            values = [(event['inputs'][port.name], port.width) for port in input_ports]
            result['event_index'] = event_index
            result['event_time'] = event['time']
            for evaluation in range(1, evaluations_per_input + 1):
                result['stage'] = 'execution'
                result['evaluation'] = evaluation
                result['simulation_calls_attempted'] += 1
                target: Path = states[int(result['simulation_calls']) % 2]
                assert current_state is not None
                timed('execution', partial(kcirct.run_simulate_fast, current_state, target, values))
                current_state = target
                result['simulation_calls'] += 1
                if keep_states:
                    archive_start = time.perf_counter()
                    archive = work_dir / 'states' / f'event-{event_index:04d}.eval-{evaluation}.kore.gz'
                    with target.open('rb') as source, gzip.open(archive, 'wb') as destination:
                        shutil.copyfileobj(source, destination)
                    archive_index.append(
                        {
                            'event_index': event_index,
                            'evaluation': evaluation,
                            'time': event['time'],
                            'path': str(archive.relative_to(work_dir)),
                            'source_path': str(target),
                            'sha256_uncompressed': _sha256(target),
                        }
                    )
                    _json(work_dir / 'states.json', archive_index)
                    result['timings']['state_export'] += time.perf_counter() - archive_start
                _check_finished(target)
            result['stage'] = 'read_ports'
            assert current_state is not None
            ports = timed(
                'read_ports', partial(_read_top_ports, kcirct, current_state, top_module, input_ports, output_ports)
            )
            for port in input_ports:
                if ports[f'{top_module}/{port.name}'][0] != event['inputs'][port.name]:
                    raise ValueError(f'输入端口采样值与激励不一致：{port.name}')
            vcd.time = event['time']
            vcd.dump(ports)
            result['events_completed'] += 1
        result['status'] = 'pass'
        result['stage'] = 'complete'
    except (Exception, KeyboardInterrupt, SystemExit) as error:
        result['status'] = 'timeout' if isinstance(error, subprocess.TimeoutExpired) else 'execution_error'
        result['error'] = f'{type(error).__name__}: {error}'
        (work_dir / 'error.txt').write_text(result['error'] + '\n', encoding='utf-8')
    finally:
        if vcd is not None:
            vcd.close()
            result['vcd_sha256'] = _sha256(output)
        if current_state is not None and current_state.is_file():
            last_state = work_dir / 'last-state.kore'
            shutil.copyfile(current_state, last_state)
            result['last_state'] = str(last_state)
            result['last_state_sha256'] = _sha256(last_state)
        result['timings']['total'] = time.perf_counter() - start
        _json(work_dir / 'result.json', result)
    return result
