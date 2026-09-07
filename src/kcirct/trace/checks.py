"""从明确采样映射导入检查；预期来源和实际运行证据分别保留。"""

from __future__ import annotations

import csv
import hashlib
import io
import os
import re
import time
from bisect import bisect_right
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING

from vcdvcd import VCDVCD

from .artifacts import exact_time
from .kore import bit_vector, map_items
from .model import (
    ArtifactRef,
    BitVector,
    CheckRecord,
    CheckSource,
    RecordRef,
    StopCode,
    Target,
    TraceError,
)

if TYPE_CHECKING:
    from .artifacts import RunArtifacts
    from .model import Observation, ObservationMap
    from .topology import TraceTopology


def _deadline(run: RunArtifacts) -> None:
    if time.monotonic() >= run.reader.deadline:
        raise TraceError(StopCode.TIME_BUDGET, '检查导入达到查询截止时间')


def _slice(vector: BitVector, target: Target) -> BitVector:
    if target.bit_range is None:
        return vector
    interval = target.bit_range
    if interval.high >= vector.width:
        raise TraceError(StopCode.INVALID_INPUT, '目标位范围超出实际位宽')
    width = interval.high - interval.low + 1
    return BitVector.from_int((vector.unsigned >> interval.low) & ((1 << width) - 1), width)


def observed_value(run: RunArtifacts, topology: TraceTopology, target: Target, observation: Observation) -> BitVector:
    """读取指定位置的保存值，同时核对该信号所有已保存 dump 别名。"""
    _deadline(run)
    if topology.run_id != run.manifest.run_id:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '检查使用的拓扑属于另一运行')
    binding = topology.resolve(target)
    if binding.kind == 'memory_write_port' or binding.signal_id is None:
        raise TraceError(StopCode.UNSUPPORTED_VALUE, '写口不是单个已保存的观测值')
    entry, dump = run.locate(observation)
    state = run.read_state(entry.state_id)
    value = state.signals.get(binding.signal_id)
    if value is None:
        raise TraceError(StopCode.MISSING_VALUE, '绑定状态中缺少观测信号', signal_id=binding.signal_id)
    if binding.kind == 'memory_cell':
        values = [
            item for address, item in map_items(value) if bit_vector(address).unsigned == int(target.address or '0')
        ]
        if len(values) != 1:
            raise TraceError(StopCode.MISSING_VALUE, '绑定状态中没有唯一的目标地址', address=target.address)
        vector = bit_vector(values[0])
    else:
        vector = bit_vector(value)
    if binding.width is not None and binding.width != vector.width:
        raise TraceError(StopCode.OBSERVATION_MISMATCH, '观测值位宽与目标类型不一致', target_id=binding.target_id)
    if dump is not None and binding.kind != 'memory_cell':
        for alias in binding.aliases:
            if alias in dump.values and dump.values[alias] != vector:
                raise TraceError(
                    StopCode.OBSERVATION_MISMATCH,
                    'dump 值与其绑定状态中的端口值不一致',
                    alias=alias,
                    dump_id=dump.dump_id,
                )
    return _slice(vector, target)


def _normalized_observation(run: RunArtifacts, observation: Observation) -> Observation:
    entry, dump = run.locate(observation)
    return replace(
        observation,
        event_index=entry.event_index,
        evaluation=entry.evaluation,
        time=entry.time,
        time_unit=entry.time_unit,
        state_id=entry.state_id,
        dump_id=dump.dump_id if dump is not None else None,
    )


def normalize_check(
    run: RunArtifacts, topology: TraceTopology, record: CheckRecord, *, carrier: Path | None = None
) -> CheckRecord:
    """校验测试侧记录；性质文本只保留，不作为脚本或新的 oracle 执行。"""
    if record.run_id != run.manifest.run_id:
        raise TraceError(StopCode.IDENTITY_MISMATCH, '检查记录属于另一运行')
    actuals = [observed_value(run, topology, target, record.observation) for target in record.targets]
    if record.actual is not None and record.actual != actuals[0]:
        raise TraceError(
            StopCode.OBSERVATION_MISMATCH,
            '检查报告中的 actual 与本次真实观测不一致',
            check_id=record.id,
            recorded=record.actual.to_dict(),
            observed=actuals[0].to_dict(),
        )
    source = record.source
    if source.record is not None:
        original = source.record
        base = carrier or run.path
        path = Path(os.path.abspath(base.absolute().parent / original.path))
        if not path.is_file():
            replacement = run.relocations.get(original.path) or run.relocations.get(str(path))
            if replacement is not None:
                path = replacement
            else:
                prefixes = [
                    (Path(key), value)
                    for key, value in run.relocations.items()
                    if Path(key).is_absolute() and path.is_relative_to(Path(key))
                ]
                if prefixes:
                    old, new = max(prefixes, key=lambda pair: len(pair[0].parts))
                    path = new / path.relative_to(old)
        if not path.is_file():
            raise TraceError(StopCode.MISSING_ARTIFACT, '检查来源的原始记录缺失', path=str(path))
        digest = _file_digest(run, path)
        if original.sha256 is not None and original.sha256 != digest:
            raise TraceError(StopCode.HASH_MISMATCH, '检查来源哈希不一致', path=str(path))
        run.resolve(ArtifactRef('check_source', original.path, digest, path.stat().st_size), carrier=base)
        source = replace(source, record=replace(original, sha256=digest))
    return replace(
        record, actual=actuals[0], observation=_normalized_observation(run, record.observation), source=source
    )


def _file_digest(run: RunArtifacts, path: Path) -> str:
    digest = hashlib.sha256()
    try:
        with path.open('rb') as stream:
            while True:
                _deadline(run)
                block = stream.read(64 * 1024)
                if not block:
                    break
                digest.update(block)
    except OSError as error:
        raise TraceError(StopCode.MISSING_ARTIFACT, '无法读取检查来源', path=str(path)) from error
    return digest.hexdigest()


def _expected_text(run: RunArtifacts, path: Path) -> tuple[str, str]:
    _deadline(run)
    try:
        with path.open('rb') as stream:
            data = stream.read(run.reader.budget.max_state_bytes + 1)
    except OSError as error:
        raise TraceError(StopCode.MISSING_ARTIFACT, '无法读取预期工件', path=str(path)) from error
    if len(data) > run.reader.budget.max_state_bytes:
        raise TraceError(StopCode.STATE_BYTES_BUDGET, '预期工件超过单文件读取上限')
    try:
        return data.decode('utf-8'), hashlib.sha256(data).hexdigest()
    except UnicodeDecodeError as error:
        raise TraceError(StopCode.INVALID_INPUT, '预期工件不是 UTF-8 文本') from error


def _validate_map(run: RunArtifacts, topology: TraceTopology, observations: ObservationMap, format: str) -> None:
    if observations.run_id != run.manifest.run_id:
        raise TraceError(StopCode.IDENTITY_MISMATCH, 'ObservationMap 属于另一运行')
    names = [signal.name for signal in observations.signals]
    if not names or len(names) != len(set(names)):
        raise TraceError(StopCode.INVALID_INPUT, 'ObservationMap 必须声明非空、名称唯一的信号集合')
    if set(observations.columns) != set(names):
        raise TraceError(StopCode.INVALID_INPUT, 'columns 必须明确映射每个观测信号')
    if set(observations.comparison_masks) - set(names):
        raise TraceError(StopCode.INVALID_INPUT, '比较掩码引用了未声明信号')
    for signal in observations.signals:
        binding = topology.resolve(Target('signal', name=signal.name))
        if binding.width is None:
            raise TraceError(StopCode.UNSUPPORTED_VALUE, '观测信号的类型位宽未知', signal=signal.name)
        if binding.width != signal.width:
            raise TraceError(StopCode.INVALID_INPUT, 'ObservationMap 位宽与运行声明冲突', signal=signal.name)
        directions = {
            alias.direction
            for alias in topology.port_aliases
            if alias.signal_id == binding.signal_id
            and signal.name in {alias.name, alias.name.replace('/', '.'), alias.name.rsplit('/', 1)[-1]}
        }
        if directions and signal.direction not in directions:
            raise TraceError(StopCode.INVALID_INPUT, 'ObservationMap 端口方向与运行声明冲突', signal=signal.name)
        mask = observations.comparison_masks.get(signal.name)
        if mask is not None and mask.width != signal.width:
            raise TraceError(StopCode.INVALID_INPUT, '比较掩码位宽与运行声明冲突', signal=signal.name)
    contract = observations.sampling_contract
    if format == 'csv' and (
        contract.get('sample_index') != 'zero_based_data_row'
        or contract.get('value_format') not in {'decimal', 'binary', 'hex'}
        or contract.get('missing_values') != 'reject'
    ):
        raise TraceError(
            StopCode.INVALID_INPUT,
            'CSV 必须声明 sample_index=zero_based_data_row、value_format 和 missing_values=reject',
        )
    positions: set[tuple[str, str | None]] = set()
    samples: set[int] = set()
    times: set[int] = set()
    for observation in observations.entries:
        _deadline(run)
        entry, dump = run.locate(observation)
        position = (entry.state_id, dump.dump_id if dump else None)
        if position in positions:
            raise TraceError(StopCode.AMBIGUOUS_OBSERVATION, 'ObservationMap 重复映射同一运行观测')
        positions.add(position)
        if format == 'csv':
            if observation.sample is None or observation.sample in samples:
                raise TraceError(StopCode.AMBIGUOUS_OBSERVATION, 'CSV 每条映射必须声明唯一 sample')
            samples.add(observation.sample)
        else:
            if observation.time is None or observation.time_unit is None:
                raise TraceError(StopCode.INVALID_INPUT, 'VCD 映射必须明确物理时间和单位')
            physical = exact_time(observation.time, observation.time_unit)
            if physical in times:
                raise TraceError(StopCode.AMBIGUOUS_OBSERVATION, 'VCD 同一物理时间不能映射到多个运行状态')
            times.add(physical)
    if not observations.entries:
        raise TraceError(StopCode.INVALID_INPUT, 'ObservationMap 没有采样映射')


def _csv_values(run: RunArtifacts, text: str, observations: ObservationMap) -> dict[tuple[int, str], BitVector]:
    rows = csv.reader(io.StringIO(text), skipinitialspace=True)
    first = next(rows, None)
    if first is None:
        raise TraceError(StopCode.INVALID_INPUT, '预期 CSV 为空')
    header = [column.strip() for column in first]
    if any(not column for column in header) or len(set(header)) != len(header):
        raise TraceError(StopCode.INVALID_INPUT, 'CSV 表头含空列名或重复列名')
    missing = set(observations.columns.values()) - set(header)
    if missing:
        raise TraceError(StopCode.INVALID_INPUT, 'CSV 缺少声明输出列', columns=sorted(missing))
    radix, pattern = {
        'decimal': (10, r'[0-9]+'),
        'binary': (2, r'[01]+'),
        'hex': (16, r'[0-9a-fA-F]+'),
    }[observations.sampling_contract['value_format']]
    result: dict[tuple[int, str], BitVector] = {}
    requested = {observation.sample for observation in observations.entries}
    seen: set[int] = set()
    for sample, row in enumerate(rows):
        _deadline(run)
        if len(row) != len(header):
            raise TraceError(StopCode.INVALID_INPUT, 'CSV 数据行的列数与表头不一致')
        if sample not in requested:
            continue
        seen.add(sample)
        for signal in observations.signals:
            token = row[header.index(observations.columns[signal.name])].strip()
            if re.fullmatch(pattern, token) is None:
                raise TraceError(StopCode.UNSUPPORTED_VALUE, 'CSV 预期不是已声明格式的二态整数', value=token)
            result[sample, signal.name] = BitVector.from_int(int(token, radix), signal.width)
    if requested - seen:
        raise TraceError(StopCode.INVALID_INPUT, 'sample 超过 CSV 数据行范围', samples=list(requested - seen))
    return result


def _vcd_values(text: str, observations: ObservationMap) -> dict[tuple[int, str], BitVector]:
    try:
        waveform = VCDVCD(vcd_string=text, signals=list(observations.columns.values()))
        magnitude = str(waveform.timescale['magnitude'])
        unit = magnitude + waveform.timescale['unit']
        tick_fs = exact_time(1, unit)
    except Exception as error:
        raise TraceError(StopCode.INVALID_INPUT, '无法读取明确整数时间单位的 VCD', error=str(error)) from error
    result: dict[tuple[int, str], BitVector] = {}
    for index, observation in enumerate(observations.entries):
        assert observation.time is not None and observation.time_unit is not None
        physical = exact_time(observation.time, observation.time_unit)
        if physical % tick_fs:
            raise TraceError(StopCode.INVALID_INPUT, '观测时刻不落在预期 VCD 的整数时间刻度上')
        tick = physical // tick_fs
        if tick > waveform.endtime:
            raise TraceError(StopCode.MISSING_VALUE, '观测超出预期 VCD 保存的时间范围')
        for signal in observations.signals:
            reference = observations.columns[signal.name]
            if reference not in waveform.signals:
                raise TraceError(StopCode.INVALID_INPUT, 'VCD 缺少明确指定的完整信号名称', signal=reference)
            data = waveform[reference]
            if int(data.size) != signal.width:
                raise TraceError(StopCode.INVALID_INPUT, 'VCD 与运行的信号位宽冲突', signal=reference)
            changes = data.tv
            if any(left[0] >= right[0] for left, right in zip(changes, changes[1:], strict=False)):
                raise TraceError(StopCode.AMBIGUOUS_OBSERVATION, 'VCD 同一信号的变更时刻重复或不递增', signal=reference)
            cursor = bisect_right([change[0] for change in changes], tick) - 1
            if cursor < 0:
                raise TraceError(StopCode.MISSING_VALUE, 'VCD 在指定时刻尚无已定义值', signal=reference)
            token = changes[cursor][1]
            if re.fullmatch('[01]+', token) is None or len(token) > signal.width:
                raise TraceError(StopCode.UNSUPPORTED_VALUE, 'VCD 包含不受支持的 X/Z 或非二态值', signal=reference)
            result[index, signal.name] = BitVector.from_int(int(token, 2), signal.width)
    return result


def import_checks(
    run: RunArtifacts,
    topology: TraceTopology,
    format: str,
    expected: Path | str,
    observations: ObservationMap,
    *,
    carrier: Path | None = None,
) -> tuple[CheckRecord, ...]:
    """只对显式映射的实际观测生成真实差异；没有差异时返回空集。"""
    if format not in {'csv', 'vcd'}:
        raise TraceError(StopCode.INVALID_INPUT, '检查导入格式必须是 csv 或 vcd')
    _validate_map(run, topology, observations, format)
    path = Path(expected).expanduser().absolute()
    text, digest = _expected_text(run, path)
    values = _csv_values(run, text, observations) if format == 'csv' else _vcd_values(text, observations)
    map_hash = hashlib.sha256(observations.to_json().encode()).hexdigest()
    destination = (carrier or run.path).absolute()
    reference = RecordRef(Path(os.path.relpath(path, destination.parent)).as_posix(), sha256=digest)
    generation_method = observations.sampling_contract.get('generation_method', 'unknown')
    if not isinstance(generation_method, str) or not generation_method.strip():
        raise TraceError(StopCode.INVALID_INPUT, 'generation_method 必须是说明文本或 unknown')
    results = []
    for index, observation in enumerate(observations.entries):
        _deadline(run)
        for signal in observations.signals:
            target = Target('signal', name=signal.name)
            actual = observed_value(run, topology, target, observation)
            source_index = observation.sample if format == 'csv' else index
            assert source_index is not None
            left = values[source_index, signal.name]
            mask = observations.comparison_masks.get(signal.name)
            difference = actual.unsigned ^ left.unsigned
            if not (difference if mask is None else difference & mask.unsigned):
                continue
            identity = f'{run.manifest.run_id}:{map_hash}:{digest}:{index}:{signal.name}'
            results.append(
                CheckRecord(
                    id='mismatch-' + hashlib.sha256(identity.encode()).hexdigest(),
                    run_id=run.manifest.run_id,
                    kind='value_mismatch',
                    targets=(target,),
                    observation=_normalized_observation(run, observation),
                    source=CheckSource(
                        kind='csv' if format == 'csv' else 'vcd',
                        identity={
                            'expected_sha256': digest,
                            'observation_map_sha256': map_hash,
                            'origin': observations.sampling_contract.get('source_identity', {'status': 'unknown'}),
                        },
                        configuration={
                            'column': observations.columns[signal.name],
                            'sample': observation.sample,
                            'csv_row': (
                                observation.sample + 2 if format == 'csv' and observation.sample is not None else None
                            ),
                            'sampling_contract': observations.sampling_contract,
                        },
                        record=reference,
                        generation_method=generation_method,
                    ),
                    expected=left,
                    actual=actual,
                    comparison_mask=mask,
                )
            )
    # 固定我们实际读取的内容，拒绝来源在读取期间被替换。
    if _file_digest(run, path) != digest:
        raise TraceError(StopCode.HASH_MISMATCH, '读取期间预期工件发生变化')
    run.resolve(ArtifactRef('check_source', reference.path, digest, path.stat().st_size), carrier=destination)
    return tuple(results)
