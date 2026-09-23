"""检查入口必须使用真实采样映射和独立预期，不能以解释结果制造 oracle。"""

from __future__ import annotations

import hashlib
from dataclasses import replace
from pathlib import Path
from typing import Any

import pytest

from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.checks import import_checks, normalize_check, observed_value
from kcirct.trace.model import (
    BitRange,
    BitVector,
    CheckRecord,
    CheckSource,
    DumpIndexEntry,
    Observation,
    ObservationMap,
    PortSpec,
    RecordRef,
    StopCode,
    Target,
    TraceError,
)
from kcirct.trace.topology import TraceTopology

from .test_trace_artifacts import _bundle, _publish

SIGNAL = 'Demo/result'
CSV_CONTRACT = {'sample_index': 'zero_based_data_row', 'value_format': 'decimal', 'missing_values': 'reject'}


def _map(*, reverse_events: bool = True, vcd: bool = False) -> ObservationMap:
    """构造两条显式观测映射，可选择逆事件顺序的 CSV 采样或带物理时间的 VCD dump 采样。"""
    entries = (
        (
            Observation('post_eval', event_index=1, evaluation=1, sample=0),
            Observation('post_eval', event_index=0, evaluation=2, sample=1),
        )
        if reverse_events
        else (
            Observation('dump', event_index=0, time=0, time_unit='ns', sample=0),
            Observation('dump', event_index=1, time=5, time_unit='ns', sample=1),
        )
    )
    return ObservationMap(
        'run-a',
        entries,
        (PortSpec(SIGNAL, 'output', 8),),
        sampling_contract={} if vcd else CSV_CONTRACT,
        columns={SIGNAL: 'ref.result[7:0]' if vcd else 'answer'},
    )


def _csv(tmp_path: Path, text: str = 'answer,ignored\n1,9\n2,9\n') -> Path:
    """写入带表头的独立 CSV 预期夹具，并返回其路径。"""
    path = tmp_path / 'expected.csv'
    path.write_text(text)
    return path


def _vcd(tmp_path: Path, first: str = '10', second: str = '1', *, width: int = 8) -> Path:
    """生成以 ps 为单位的两次信号变更，允许替换值和位宽以测试 VCD 边界。"""
    path = tmp_path / 'expected.vcd'
    path.write_text(
        '$timescale 1ps $end\n$scope module ref $end\n'
        f'$var wire {width} ! result [7:0] $end\n$upscope $end\n$enddefinitions $end\n'
        f'#0\nb{first} !\n#5000\nb{second} !\n#10000\n'
    )
    return path


def test_csv_mapping_does_not_assume_twice_the_sample_and_preserves_origin(tmp_path: Path) -> None:
    """验证 CSV 依照显式映射命中真实状态，并保留行号、来源哈希和未知生成方式。"""
    path, _, _ = _bundle(tmp_path / 'run')
    expected = _csv(tmp_path)
    carrier = tmp_path / 'reports' / 'checks.json'
    with RunArtifacts.open(path) as run:
        topology = TraceTopology.from_run(run)
        checks = import_checks(run, topology, 'csv', expected, _map(), carrier=carrier)
        assert len(checks) == 1
        check = checks[0]
        assert (check.observation.sample, check.observation.event_index, check.observation.evaluation) == (0, 1, 1)
        assert (check.expected, check.actual) == (BitVector(8, '1'), BitVector(8, '3'))
        assert check.observation.state_id == 'e1v1'
        assert check.source.generation_method == 'unknown'
        assert check.source.identity['origin']['status'] == 'unknown'
        assert check.source.configuration['csv_row'] == 2
        assert check.source.configuration['column'] == 'answer'
        assert check.source.record is not None and check.source.record.path == '../expected.csv'
        assert check.source.record.sha256 == hashlib.sha256(expected.read_bytes()).hexdigest()
        assert normalize_check(run, topology, check, carrier=carrier) == check


def test_no_csv_difference_produces_empty_check_set(tmp_path: Path) -> None:
    """验证所有映射观测与 CSV 预期一致时不生成差异检查。"""
    path, _, _ = _bundle(tmp_path / 'run')
    expected = _csv(tmp_path, 'answer\n3\n2\n')
    with RunArtifacts.open(path) as run:
        assert import_checks(run, TraceTopology.from_run(run), 'csv', expected, _map()) == ()


@pytest.mark.parametrize('token', ['', 'x', 'z', '-', '-1', '1.0', '0x1', '256'])
def test_csv_rejects_unknown_missing_wrong_radix_and_oversized_values(tmp_path: Path, token: str) -> None:
    """验证十进制 CSV 拒绝缺值、X/Z、负数、错误进制、非整数及超过位宽的值。"""
    path, _, _ = _bundle(tmp_path / 'run')
    expected = _csv(tmp_path, f'answer,other\n{token},0\n2,0\n')
    with RunArtifacts.open(path) as run, pytest.raises(TraceError):
        import_checks(run, TraceTopology.from_run(run), 'csv', expected, _map())


@pytest.mark.parametrize(
    'kind',
    [
        'missing_contract',
        'wrong_width',
        'duplicate_sample',
        'duplicate_position',
        'wrong_direction',
        'bad_mask',
        'no_columns',
    ],
)
def test_ambiguous_or_incomplete_observation_contract_is_rejected(tmp_path: Path, kind: str) -> None:
    """验证采样契约缺项、重复采样、信号声明冲突和错误掩码均被拒绝。"""
    path, _, _ = _bundle(tmp_path / 'run')
    expected = _csv(tmp_path)
    mapping = _map()
    if kind == 'missing_contract':
        mapping = replace(mapping, sampling_contract={})
    elif kind == 'wrong_width':
        mapping = replace(mapping, signals=(PortSpec(SIGNAL, 'output', 1),))
    elif kind == 'duplicate_sample':
        mapping = replace(mapping, entries=(mapping.entries[0], replace(mapping.entries[1], sample=0)))
    elif kind == 'duplicate_position':
        mapping = replace(mapping, entries=(mapping.entries[0], replace(mapping.entries[0], sample=1)))
    elif kind == 'wrong_direction':
        mapping = replace(mapping, signals=(PortSpec(SIGNAL, 'input', 8),))
    elif kind == 'bad_mask':
        mapping = replace(mapping, comparison_masks={SIGNAL: BitVector(1, '1')})
    else:
        mapping = replace(mapping, columns={})
    with RunArtifacts.open(path) as run, pytest.raises(TraceError):
        import_checks(run, TraceTopology.from_run(run), 'csv', expected, mapping)


def test_explicit_mask_only_compares_declared_bits(tmp_path: Path) -> None:
    """验证掩码外的真实差异被忽略，只有明确声明的位参与比较。"""
    path, _, _ = _bundle(tmp_path / 'run')
    expected = _csv(tmp_path, 'answer\n1\n0\n')
    mapping = replace(_map(), comparison_masks={SIGNAL: BitVector(8, '1')})
    with RunArtifacts.open(path) as run:
        assert import_checks(run, TraceTopology.from_run(run), 'csv', expected, mapping) == ()


def test_binary_and_hex_csv_have_explicit_radix(tmp_path: Path) -> None:
    """验证按契约声明的二进制和十六进制 CSV 可与相同实际值比较通过。"""
    path, _, _ = _bundle(tmp_path / 'run')
    with RunArtifacts.open(path) as run:
        topology = TraceTopology.from_run(run)
        for radix, rows in [('binary', '11\n10\n'), ('hex', '03\n02\n')]:
            expected = _csv(tmp_path, 'answer\n' + rows)
            mapping = replace(_map(), sampling_contract={**CSV_CONTRACT, 'value_format': radix})
            assert import_checks(run, topology, 'csv', expected, mapping) == ()


def test_vcd_uses_exact_integer_units_and_only_bound_samples(tmp_path: Path) -> None:
    """验证 ns 观测精确换算为 ps tick，并仅对映射 dump 中的差异生成检查。"""
    path, _, _ = _bundle(tmp_path / 'run')
    expected = _vcd(tmp_path)
    with RunArtifacts.open(path) as run:
        checks = import_checks(run, TraceTopology.from_run(run), 'vcd', expected, _map(reverse_events=False, vcd=True))
        assert len(checks) == 1
        assert checks[0].observation.event_index == 1 and checks[0].observation.evaluation == 2
        assert checks[0].expected == BitVector(8, '1') and checks[0].actual == BitVector(8, '4')
        assert checks[0].source.kind == 'vcd'


@pytest.mark.parametrize('fault', ['x', 'z', 'wrong_width', 'absent_signal', 'duplicate_time', 'no_time'])
def test_vcd_unknown_values_and_ambiguous_mapping_are_not_coerced(tmp_path: Path, fault: str) -> None:
    """验证 VCD 的 X/Z、位宽或信号冲突，以及缺失或重复时间映射均明确失败。"""
    path, _, _ = _bundle(tmp_path / 'run')
    expected = _vcd(tmp_path, first=fault if fault in ('x', 'z') else '10', width=4 if fault == 'wrong_width' else 8)
    mapping = _map(reverse_events=False, vcd=True)
    if fault == 'absent_signal':
        mapping = replace(mapping, columns={SIGNAL: 'ref.other[7:0]'})
    elif fault == 'duplicate_time':
        mapping = replace(
            mapping,
            entries=(
                Observation('post_eval', event_index=0, evaluation=1, time=0, time_unit='ns'),
                Observation('post_eval', event_index=0, evaluation=2, time=0, time_unit='ns'),
            ),
        )
    elif fault == 'no_time':
        mapping = replace(mapping, entries=(Observation('dump', event_index=0),))
    with RunArtifacts.open(path) as run, pytest.raises(TraceError):
        import_checks(run, TraceTopology.from_run(run), 'vcd', expected, mapping)


def test_property_predicate_is_preserved_without_execution_or_expected(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """验证性质文本只被保留，实际值来自保存状态，且不会执行文本或补造预期值。"""
    path, _, _ = _bundle(tmp_path / 'run')
    record = CheckRecord(
        'property-1',
        'run-a',
        'property_failure',
        (Target('signal', name=SIGNAL),),
        Observation('post_eval', event_index=1, evaluation=1),
        predicate='__import__("os").system("never execute")',
        predicate_interpretation='violation',
        predicate_result=True,
    )

    def reject_execution(*_args: Any, **_kwargs: Any) -> Any:
        """替换系统执行入口，使任何意外执行性质文本的行为立即令测试失败。"""
        pytest.fail('检查文本不允许进入执行器')

    monkeypatch.setattr('os.system', reject_execution)
    with RunArtifacts.open(path) as run:
        normalized = normalize_check(run, TraceTopology.from_run(run), record)
        assert normalized.predicate == record.predicate and normalized.expected is None
        assert normalized.actual == BitVector(8, '3') and normalized.predicate_result is True


def test_pure_observation_is_not_promoted_to_failure(tmp_path: Path) -> None:
    """验证可疑观测仅补全实际值，保留其种类且不添加失败判据。"""
    path, _, _ = _bundle(tmp_path / 'run')
    record = CheckRecord(
        'manual',
        'run-a',
        'suspicious_observation',
        (Target('signal', name=SIGNAL),),
        Observation('dump', event_index=1),
    )
    with RunArtifacts.open(path) as run:
        normalized = normalize_check(run, TraceTopology.from_run(run), record)
        assert normalized.kind == 'suspicious_observation'
        assert normalized.expected is None and normalized.predicate is None
        assert normalized.actual == BitVector(8, '4')


def test_recorded_actual_and_saved_dump_must_match_bound_state(tmp_path: Path) -> None:
    """分别篡改记录的 actual 与 dump 值，验证二者都必须匹配绑定状态。"""
    path, manifest, records = _bundle(tmp_path / 'run')
    observation = Observation('dump', event_index=1)
    record = CheckRecord(
        'manual',
        'run-a',
        'suspicious_observation',
        (Target('signal', name=SIGNAL),),
        observation,
        actual=BitVector(8, '9'),
    )
    with RunArtifacts.open(path) as run:
        with pytest.raises(TraceError) as error:
            normalize_check(run, TraceTopology.from_run(run), record)
        assert error.value.code == StopCode.OBSERVATION_MISMATCH
    dump = records[-1]
    assert isinstance(dump, DumpIndexEntry)
    records[-1] = replace(dump, values={SIGNAL: BitVector(8, '9')})
    _publish(path.parent, manifest, records)
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as error:
        observed_value(run, TraceTopology.from_run(run), Target('signal', name=SIGNAL), observation)
    assert error.value.code == StopCode.OBSERVATION_MISMATCH


def test_source_hash_and_run_identity_are_fixed(tmp_path: Path) -> None:
    """验证来源记录的哈希错误与运行 ID 不匹配分别返回明确的身份校验错误。"""
    path, _, _ = _bundle(tmp_path / 'run')
    original = tmp_path / 'property.txt'
    original.write_text('original requirement')
    record = CheckRecord(
        'manual',
        'run-a',
        'suspicious_observation',
        (Target('signal', name=SIGNAL),),
        Observation('dump', event_index=1),
        source=CheckSource(kind='manual', record=RecordRef('../property.txt', sha256='0' * 64)),
    )
    with RunArtifacts.open(path) as run:
        topology = TraceTopology.from_run(run)
        with pytest.raises(TraceError) as error:
            normalize_check(run, topology, record)
        assert error.value.code == StopCode.HASH_MISMATCH
        with pytest.raises(TraceError) as error:
            normalize_check(run, topology, replace(record, run_id='other-run'))
        assert error.value.code == StopCode.IDENTITY_MISMATCH


def test_bit_range_selects_exact_saved_bits(tmp_path: Path) -> None:
    """验证闭合位区间从保存值提取精确位宽和值，而非使用完整信号值。"""
    path, _, _ = _bundle(tmp_path / 'run')
    with RunArtifacts.open(path) as run:
        value = observed_value(
            run,
            TraceTopology.from_run(run),
            Target('signal', name=SIGNAL, bit_range=BitRange(1, 2)),
            Observation('post_eval', event_index=1, evaluation=1),
        )
        assert value == BitVector(2, '1')


def test_missing_schema_is_rejected_before_check_import() -> None:
    """验证缺少 schema_version 的观测映射在导入检查前即被模型解析器拒绝。"""
    with pytest.raises(TraceError) as error:
        ObservationMap.from_dict({'run_id': 'run-a'})
    assert error.value.code == StopCode.UNSUPPORTED_SCHEMA
