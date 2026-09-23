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
from dataclasses import asdict, dataclass, replace
from functools import partial
from importlib.metadata import version
from pathlib import Path
from typing import TYPE_CHECKING, Any
from uuid import uuid4

from pyk.kdist import kdist

from .api import KCIRCT
from .trace.model import (
    ArtifactRef,
    BitVector,
    CompletionEvidence,
    DumpIndexEntry,
    PortSpec,
    RunManifest,
    StateIndexEntry,
)
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


def _atomic_text(path: Path, text: str) -> None:
    """先写入同目录的 .pending 文件并 fsync，再替换目标，避免读到半份索引或清单。"""
    temporary = path.with_name(path.name + '.pending')
    with temporary.open('w', encoding='utf-8') as stream:
        stream.write(text)
        stream.flush()
        os.fsync(stream.fileno())
    temporary.replace(path)


class _TraceCapture:
    """只增加运行身份与索引；索引中不发布滚动状态的持久引用。"""

    def __init__(self, work: Path, top: str, keep_states: bool, evaluations: int) -> None:
        """为本次运行分配独立身份，初始化尚未核验的协议、状态链和工件引用。"""
        self.work = work
        self.keep_states = keep_states
        self.artifacts: dict[str, ArtifactRef] = {}
        self.states: list[StateIndexEntry | DumpIndexEntry] = []
        # current 指向最近尝试，materialized 指向最近实际产出状态的尝试；超时时二者可能不同。
        self.current: int | None = None
        self.materialized: int | None = None
        self.manifest = RunManifest(
            run_id=str(uuid4()),
            top_module=top,
            protocol={'evaluations_per_input': evaluations, 'sampling_phase': 'dump', 'status': 'not_checked'},
            state_coverage={'keep_states': keep_states, 'status': 'not_checked'},
        )

    def artifact(self, key: str, path: Path, role: str, raw: Path | None = None) -> ArtifactRef:
        """登记相对于工作目录的文件引用；提供 raw 时同时记录 gzip 归档的解压身份。"""
        ref = ArtifactRef(
            role=role,
            path=Path(os.path.relpath(path, self.work)).as_posix(),
            sha256=_sha256(path),
            size_bytes=path.stat().st_size,
            compression='gzip' if raw is not None else 'none',
            uncompressed_sha256=_sha256(raw) if raw is not None else None,
            uncompressed_size_bytes=raw.stat().st_size if raw is not None else None,
        )
        self.artifacts[key] = ref
        return ref

    def configure(self, result: dict[str, Any], definition: Path, parser: Path) -> None:
        """绑定输入、编译定义、parser 与工具身份，复制当前包源码，并发布采集清单。

        result 必须已有端口、时序和版本信息。这里只记录文件身份，不额外执行 K 命令；
        当前源码与指定编译定义的语义对应关系仍标为 unverified，留给离线适配器核验。
        """
        for key, path, role in (
            ('execution_ir', self.work / 'design.generic.mlir', 'execution_ir'),
            ('inputs', self.work / 'inputs.json', 'inputs'),
            ('parser', parser, 'parser'),
        ):
            self.artifact(key, path, role)
        for name in ('definition.kore', 'compiled.bin', 'backend.txt', 'interpreter'):
            self.artifact('definition/' + name, definition / name, 'compiled_definition')
        package = Path(__file__).resolve().parent
        sources = self.work / 'trace-identity'
        sources.mkdir()
        semantic_hashes = {}
        for path in sorted((package / 'kdist' / 'circt_semantics').rglob('*')):
            if not path.is_file() or path.suffix not in {'.k', '.md'}:
                continue
            relative = path.relative_to(package / 'kdist' / 'circt_semantics')
            destination = sources / 'semantics' / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(path, destination)
            ref = self.artifact('semantics/' + relative.as_posix(), destination, 'semantics_source')
            semantic_hashes[relative.as_posix()] = ref.sha256
        component_hashes = {}
        for path in sorted(package.rglob('*.py')):
            relative = path.relative_to(package)
            destination = sources / 'component' / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(path, destination)
            ref = self.artifact('component/' + relative.as_posix(), destination, 'component_source')
            component_hashes[relative.as_posix()] = ref.sha256
        tools = {}
        for name in ('krun', 'kast', 'kompile'):
            try:
                path = Path(_tool(name))
                ref = self.artifact('tool/' + name, path, 'execution_tool')
                tools[name] = {'path': str(path), 'sha256': ref.sha256}
            except OSError as error:
                tools[name] = {'status': 'unknown', 'reason': str(error)}
        python_ref = self.artifact('python', Path(sys.executable).resolve(), 'python_executable')
        ports = tuple(
            PortSpec(name=port['name'], direction='input', width=port['width']) for port in result['ports']['inputs']
        ) + tuple(
            PortSpec(name=port['name'], direction='output', width=port['width']) for port in result['ports']['outputs']
        )
        self.manifest = replace(
            self.manifest,
            ports=ports,
            protocol={
                'status': 'declared',
                'timescale': result['timescale'],
                'evaluations_per_input': result['evaluations_per_input'],
                'events_total': result['events_total'],
                'sampling_phase': 'dump',
                'event_order': 'input_file_order',
                'clock_constraints': '由已绑定语义与设计连接限定；未作通用多时钟认证',
            },
            identities={
                'package_version': result['package_version'],
                'kframework_version': result['kframework_version'],
                'component_hashes': component_hashes,
                'semantics_hashes': semantic_hashes,
                'semantics_binding': {
                    'status': 'unverified',
                    'source': 'installed_component',
                    'definition_sha256': self.artifacts['definition/definition.kore'].sha256,
                    'reason': '采集当前包源码身份；指定编译定义的规则来源由离线适配器另行核验',
                },
                'tools': tools,
                'python': {'version': sys.version, 'sha256': python_ref.sha256},
                'adapter': {'status': 'not_selected'},
            },
            parameters={'source': 'execution_ir', 'external_overrides': []},
            initialization={'status': 'unknown', 'source': 'execution_ir_and_definition', 'external_overrides': []},
        )
        self.publish()

    def begin(self, event: int | None = None, evaluation: int | None = None, timestamp: int | None = None) -> None:
        """在外部调用前登记一次状态尝试；event 为 None 表示 setup，否则记录事件及求值序号。

        新条目先标为 missing，并链接上一状态条目；即使调用未返回，也能保留真实的历史缺口。
        """
        predecessor = None
        if self.current is not None:
            previous = self.states[self.current]
            assert isinstance(previous, StateIndexEntry)
            predecessor = previous.state_id
        self.states.append(
            StateIndexEntry(
                state_id='setup' if event is None else f'event-{event}.eval-{evaluation}',
                phase='setup' if event is None else 'post_eval',
                predecessor=predecessor,
                event_index=event,
                evaluation=evaluation,
                time=timestamp,
                time_unit=self.manifest.protocol.get('timescale') if timestamp is not None else None,
                retention='missing',
            )
        )
        self.current = len(self.states) - 1

    def finish(self, state: Path, archive: Path | None = None) -> None:
        """把返回的 Kore 绑定到当前尝试，并检查是否到达终态；未完成的状态仍保留身份。

        setup 和显式归档可作为持久证据，滚动求值文件仅记内容哈希。终态检查失败时
        将完成状态标为 incomplete 后重新抛出，由调用方统一收尾并发布索引。
        """
        assert self.current is not None
        entry = self.states[self.current]
        assert isinstance(entry, StateIndexEntry)
        self.materialized = self.current
        artifact = None
        if archive is not None or entry.phase == 'setup':
            artifact = 'state/' + entry.state_id
            self.artifact(artifact, archive or state, 'state', state if archive is not None else None)
        entry = replace(
            entry,
            artifact=artifact,
            content_sha256=_sha256(state),
            retention='retained' if artifact is not None else 'not_retained',
        )
        self.states[self.current] = entry
        # 在 finally 一次发布索引；检查途中中断时磁盘上的 manifest 仍未完成。
        try:
            _check_finished(state)
        except BaseException:
            self.states[self.current] = replace(entry, completion=CompletionEvidence(status='incomplete'))
            raise
        self.states[self.current] = replace(
            entry,
            completion=CompletionEvidence(status='completed', details={'checker': 'simulate_terminal_cells_v1'}),
        )

    def dump(self, event: int, evaluation: int, timestamp: int, ports: dict[str, tuple[int, int]]) -> None:
        """将一次 VCD 采样绑定到当前状态；ports 的值为 (无符号值, 位宽)，采样不推进状态链。"""
        assert self.current is not None
        entry = self.states[self.current]
        assert isinstance(entry, StateIndexEntry)
        self.states.append(
            DumpIndexEntry(
                dump_id=f'dump-{event}',
                state_id=entry.state_id,
                event_index=event,
                evaluation=evaluation,
                time=timestamp,
                time_unit=self.manifest.protocol['timescale'],
                values={name: BitVector.from_int(value, width) for name, (value, width) in ports.items()},
            )
        )

    def publish(self) -> None:
        """先替换完整状态索引，再发布绑定其哈希的运行清单。

        两个文件分别原子替换；若中途失败，旧清单可能与新索引哈希不符，读取方须拒绝该组合。
        """
        index = self.work / 'trace-states.jsonl'
        _atomic_text(index, ''.join(json.dumps(item.to_dict(), ensure_ascii=False) + '\n' for item in self.states))
        index_ref = ArtifactRef(
            role='state_index', path=index.name, sha256=_sha256(index), size_bytes=index.stat().st_size
        )
        self.manifest = replace(self.manifest, artifacts=self.artifacts, state_index=index_ref)
        _atomic_text(self.work / 'trace-run.json', self.manifest.to_json())

    def close(self, result: dict[str, Any]) -> None:
        """根据最终仿真结果登记末态和日志，汇总留存覆盖率后发布运行完成状态。

        调用方先保存 result.json，有实际末态时同时保存 last-state.kore。未开启历史归档时，
        仅把实际产出的最后状态提升为 retained；失败尝试仍保留 missing，不能借用此前状态填补历史。
        """
        if self.materialized is not None:
            entry = self.states[self.materialized]
            assert isinstance(entry, StateIndexEntry)
            last = self.work / 'last-state.kore'
            # 失败调用可能只保存此前状态；使用记录的实际位置，不能按相同值猜时间。
            if last.is_file():
                content_hash = _sha256(last)
                if entry.content_sha256 != content_hash:
                    raise ValueError('last-state 内容与记录的真实状态身份不一致')
                if entry.artifact is None:
                    key = 'state/' + entry.state_id
                    self.artifact(key, last, 'state')
                    self.states[self.materialized] = replace(entry, artifact=key, retention='retained')
        for name, role in (
            ('result.json', 'execution_result'),
            ('commands.jsonl', 'commands'),
            ('states.json', 'legacy_state_index'),
            ('error.txt', 'execution_diagnostic'),
        ):
            path = self.work / name
            if path.is_file():
                self.artifact(name, path, role)
        vcd = Path(result['vcd_path'])
        if 'vcd_sha256' in result:
            self.artifact('vcd', vcd, 'waveform')
        commands = self.work / 'commands.jsonl'
        command_list = (
            tuple(tuple(json.loads(line)['argv']) for line in commands.read_text().splitlines())
            if commands.is_file()
            else ()
        )
        evaluations = [item for item in self.states if isinstance(item, StateIndexEntry) and item.phase == 'post_eval']
        coverage = {
            retention: sum(item.retention == retention for item in evaluations)
            for retention in ('retained', 'not_retained', 'missing')
        }
        self.manifest = replace(
            self.manifest,
            commands=command_list,
            completion=CompletionEvidence(status='completed' if result['status'] == 'pass' else 'incomplete'),
            state_coverage={
                'keep_states': self.keep_states,
                'status': 'retained' if evaluations and coverage['retained'] == len(evaluations) else 'partial',
                'evaluations': coverage,
                'events_completed': result['events_completed'],
                'calls_completed': sum(item.completion.status == 'completed' for item in evaluations),
                'calls_returned': result['simulation_calls'],
                'calls_attempted': result['simulation_calls_attempted'],
            },
        )
        self.publish()


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
    """依次执行输入事件，在每个事件的连续求值结束后采样一次，并保存离线追踪所需身份。

    同一事件内固定输入和时间，连续求值 evaluations_per_input 次；keep_states 决定
    是否逐次归档 Kore，但不改变求值协议。工作目录和 VCD 均要求使用新路径。
    执行阶段捕获的错误会写入结构化结果；创建工作目录等前置错误及收尾 I/O 错误仍可能抛出。
    """
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
    trace: _TraceCapture | None = None

    def timed(name: str, operation: Callable[[], Any]) -> Any:
        """执行一个阶段并累计其耗时；即使操作抛错，也把已消耗的时间计入结果。"""
        section_start = time.perf_counter()
        try:
            return operation()
        finally:
            result['timings'][name] += time.perf_counter() - section_start

    try:
        trace = _TraceCapture(work_dir, top_module, keep_states, evaluations_per_input)
        result['run_id'] = trace.manifest.run_id
        result['trace_manifest'] = 'trace-run.json'
        trace.publish()
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
        trace.configure(result, definition_dir, parser)
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
            if name == 'setup':
                trace.begin()
            timed(name, action)
        current_state = setup
        trace.finish(current_state)
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
                # 调用前建条目、返回后绑定内容，使超时尝试不会误领上一轮的状态。
                trace.begin(event_index, evaluation, event['time'])
                target: Path = states[int(result['simulation_calls']) % 2]
                assert current_state is not None
                timed('execution', partial(kcirct.run_simulate_fast, current_state, target, values))
                current_state = target
                result['simulation_calls'] += 1
                archive = None
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
                # 先归档再核验终态，失败时也留下诊断所需的真实返回状态。
                trace.finish(target, archive)
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
            trace.dump(event_index, evaluations_per_input, event['time'], ports)
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
        if trace is not None:
            try:
                trace.close(result)
            except (Exception, KeyboardInterrupt, SystemExit) as error:
                # 发布失败保留之前的不完整 manifest；不得把诊断记录失败包装成正常运行。
                result['status'] = 'execution_error'
                result['stage'] = 'trace_export'
                result['error'] = f'{type(error).__name__}: {error}'
                _json(work_dir / 'result.json', result)
    return result
