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
    """在检查导入的循环和文件读取边界检查共享截止时间，超时立即停止。"""
    if time.monotonic() >= run.reader.deadline:
        raise TraceError(StopCode.TIME_BUDGET, '检查导入达到查询截止时间')


def _slice(vector: BitVector, target: Target) -> BitVector:
    """按目标的闭合位区间截取已保存值；无区间时保留原值，超出位宽则拒绝。"""
    if target.bit_range is None:
        return vector
    interval = target.bit_range
    if interval.high >= vector.width:
        raise TraceError(StopCode.INVALID_INPUT, '目标位范围超出实际位宽')
    width = interval.high - interval.low + 1
    return BitVector.from_int((vector.unsigned >> interval.low) & ((1 << width) - 1), width)


def observed_value(run: RunArtifacts, topology: TraceTopology, target: Target, observation: Observation) -> BitVector:
    """读取目标在指定观测位置的实际保存值，并按需截取位区间。

    首先固定运行与状态身份；存储单元按地址唯一取值，普通信号核对已保存的 dump 别名。
    写口、缺值、位宽冲突及 dump 与状态不一致均明确报错，不推算替代实际值。
    """
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
    # dump 只是已保存状态的另一种表示；任何同信号别名冲突都不能作为有效观测。
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
    """将观测选择条件解析到唯一状态和可选 dump，补全运行实际保存的位置字段。"""
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
    """校验检查的运行身份、实际值与来源文件，返回绑定真实观测后的记录。

    来源相对 carrier（缺省为运行 manifest）解析；缺失时尝试显式文件或最长目录前缀重定位。
    性质文本仅作为来源描述保留，不执行为脚本，也不据此生成新的预期值。
    """
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
                # 目录整体搬迁时优先采用最长匹配前缀，避免较宽泛映射遮蔽具体路径。
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
    """受查询截止时间约束地分块计算来源文件哈希，读取失败报告工件缺失。"""
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
    """在单文件字节上限内读取预期工件，返回 UTF-8 文本及对应原始字节哈希。"""
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
    """校验观测映射的信号声明、比较掩码和格式特有的采样契约。

    每个运行位置只能映射一次；CSV 使用唯一数据行号，VCD 使用带单位的唯一物理时刻。
    信号名、列映射、位宽和方向必须与实际拓扑一致，空映射或歧义均拒绝。
    """
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
    # 运行位置和外部采样编号分别去重，防止两端任意一端出现多义映射。
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
    """按已校验的列映射和整数进制读取 CSV，只为指定数据行返回信号值。

    所有行必须与表头列数一致；被采样行拒绝空值、未知值及越界整数，缺少请求行也报错。
    """
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
    """按明确物理时间读取 VCD 的最近一次已定义值，返回映射序号与信号对应的二态向量。

    时刻必须落在整数 tick 且不超过保存范围；完整信号名、位宽及变更时间序列均需匹配。
    尚未定义的值、重复变更时刻及 X/Z 不进行补齐或猜测。
    """
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
            # VCD 变更值持续有效到下一次变更；取不晚于观测 tick 的最后一项。
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
    """比较显式采样位置上的实际值与独立预期，仅为掩码内的真实差异生成检查记录。

    检查 ID 由运行、映射和预期文件身份确定；记录保留来源列、采样位置及生成方式。
    返回前重新核对预期文件哈希，拒绝读取期间被替换的来源；无差异时返回空元组。
    """
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
            # 稳定 ID 绑定来源字节和映射身份，保证重新导入时能够逐条复核检查包。
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
