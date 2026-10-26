"""解析缓存只跳过已核验字节的重复解析；身份、预算与证据不随命中放松。"""

from __future__ import annotations

import json
from dataclasses import replace
from pathlib import Path

import pytest

from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.comparison import normalized_evidence
from kcirct.trace.model import Budget, RunManifest, StopCode, TraceError
from kcirct.trace.parse_cache import ParsedStateCache

from .test_trace_memory import Snapshot
from .test_trace_memory import execute as memory_query
from .test_trace_memory import memory_run
from .test_trace_query import execute, small_run
from .test_trace_register import execute as register_query
from .test_trace_register import register_run


def test_repeated_query_avoids_parse_but_revalidates_raw_bytes(tmp_path: Path) -> None:
    """warm 命中解析次数为零，但读取计费和完整语义证据与关闭缓存时一致。"""
    path = small_run(tmp_path)
    baseline = execute(path)
    cache = ParsedStateCache()
    with cache.activate():
        cold = execute(path)
        first = cache.statistics()
        warm = execute(path)
        second = cache.statistics()
    assert normalized_evidence(baseline) == normalized_evidence(cold) == normalized_evidence(warm)
    assert first['parse_calls'] > 0
    assert second['parse_calls'] == first['parse_calls']
    assert second['hits'] > first['hits']
    assert second['read_bytes'] == 2 * first['read_bytes']
    assert warm.cost.read_bytes == cold.cost.read_bytes == baseline.cost.read_bytes
    assert second['load_seconds'] > first['load_seconds']


@pytest.mark.parametrize('change', ['manifest', 'profile', 'analyzer'])
def test_namespace_identity_change_forces_cold_parse(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, change: str
) -> None:
    """相同状态字节在 manifest、profile 声明或分析器版本改变后不能复用旧条目。"""
    path = small_run(tmp_path)
    cache = ParsedStateCache()
    with cache.activate():
        execute(path)
        before = cache.statistics()
        if change == 'analyzer':
            monkeypatch.setattr('kcirct.trace.parse_cache.analyzer_identity', lambda: '0' * 64)
        else:
            manifest = RunManifest.from_json(path.read_text())
            if change == 'manifest':
                manifest = replace(manifest, parameters={'configuration': 2})
            else:
                manifest = replace(manifest, identities={'profile': 'changed-test-profile'})
            path.write_text(manifest.to_json())
        execute(path)
        after = cache.statistics()
    assert after['parse_calls'] == 2 * before['parse_calls']
    assert after['hits'] == 0


def test_original_state_tampering_is_rejected_before_cache_use(tmp_path: Path) -> None:
    """篡改同一路径的原始状态不会被保留的解析视图掩盖。"""
    path = small_run(tmp_path)
    cache = ParsedStateCache()
    with cache.activate():
        execute(path)
        state = path.parent / 'state1.kore'
        state.write_text(state.read_text() + '\n')
        report = execute(path)
    assert report.status.query == 'rejected'
    assert any(frontier.reason.code == StopCode.HASH_MISMATCH for frontier in report.frontier)


@pytest.mark.parametrize(
    ('budget', 'code'),
    [
        (Budget(max_read_bytes=10), StopCode.READ_BYTES_BUDGET),
        (Budget(max_state_bytes=10), StopCode.STATE_BYTES_BUDGET),
        (Budget(max_ast_nodes=1), StopCode.AST_NODES_BUDGET),
        (Budget(max_ast_depth=1), StopCode.AST_DEPTH_BUDGET),
    ],
)
def test_warm_cache_obeys_current_read_and_ast_budgets(tmp_path: Path, budget: Budget, code: StopCode) -> None:
    """较低读取或词法预算不能因 warm 命中而绕过，失败读取仍如实计费。"""
    path = small_run(tmp_path)
    cache = ParsedStateCache()
    with cache.activate():
        execute(path)
        before = cache.statistics()
        with pytest.raises(TraceError) as caught:
            execute(path, budget=budget)
        after = cache.statistics()
    assert caught.value.code == code
    if code != StopCode.STATE_BYTES_BUDGET:  # 小到 manifest 都无法读取时不进入状态 worker。
        assert after['failed_reads'] > before['failed_reads']
        assert after['read_bytes'] > before['read_bytes']


def test_small_cache_never_retains_oversize_views(tmp_path: Path) -> None:
    """保留内存不足时退回普通解析，不把未保留条目记作命中。"""
    path = small_run(tmp_path)
    cache = ParsedStateCache(max_bytes=1)
    with cache.activate():
        execute(path)
        execute(path)
    stats = cache.statistics()
    assert stats['hits'] == 0 and stats['oversize_bypasses'] > 0
    assert stats['retained_bytes'] == stats['peak_bytes'] == 0


def test_lower_request_cache_limit_evicts_existing_views(tmp_path: Path) -> None:
    """请求降低 max_cache_bytes 时不能沿用此前较大预算下保留的状态。"""
    path = small_run(tmp_path)
    cache = ParsedStateCache()
    with cache.activate():
        execute(path)
        assert cache.bytes > 0
        report = execute(path, budget=Budget(max_cache_bytes=1))
    assert report.status.query == 'complete'
    assert cache.bytes == 0 and cache.statistics()['evictions'] > 0


def test_caller_dictionary_mutation_cannot_poison_cache(tmp_path: Path) -> None:
    """可变 cells/fingerprints/完成信息只属于当前查询，不污染后续返回值。"""
    path = small_run(tmp_path)
    cache = ParsedStateCache()
    with cache.activate():
        with RunArtifacts.open(path) as first:
            state = first.read_state(first.setup_id)
            fingerprint = dict(state.fingerprints)
            state.cells.clear()
            state.fingerprints.clear()
            state.completion.details['tampered'] = True
        with RunArtifacts.open(path) as second:
            state = second.read_state(second.setup_id)
            assert state.cells and state.fingerprints == fingerprint
            assert 'tampered' not in state.completion.details


def test_same_value_capture_control_and_history_survive_cache(tmp_path: Path) -> None:
    """同值采样和后续保持链在启用缓存后保留全部控制和真实前驱。"""
    path = register_run(tmp_path, [{'a': 0, 'c': 1, 'r': 0}, {'a': 9, 'c': 0, 'r': 0}])
    baseline = register_query(path, index=2)
    cache = ParsedStateCache()
    with cache.activate():
        register_query(path, index=2)
        warm = register_query(path, index=2)
    assert normalized_evidence(warm) == normalized_evidence(baseline)
    assert {'capture', 'control', 'prior_state'} <= {edge.kind for edge in warm.edges}
    assert cache.statistics()['hits'] > 0


def test_activation_is_scoped_and_statistics_are_json(tmp_path: Path) -> None:
    """退出作用域即关闭自动复用，计数可独立保存而不污染报告 scope。"""
    path = small_run(tmp_path)
    cache = ParsedStateCache()
    with cache.activate():
        execute(path)
    before = cache.statistics()
    execute(path)
    assert cache.statistics() == before
    assert json.loads(json.dumps(before)) == before


def test_same_value_memory_write_survives_warm_parse_cache(tmp_path: Path) -> None:
    """内存同值写的写口、控制与旧值历史在 warm 缓存后仍保留。"""
    from kcirct.trace.model import Target

    path = memory_run(tmp_path, [Snapshot(memory={1: 0}, clock=1, address=1, data=0)])
    target = Target('memory_cell', name='Demo/store', address='1')
    baseline = memory_query(path, target=target)
    cache = ParsedStateCache()
    with cache.activate():
        memory_query(path, target=target)
        warm = memory_query(path, target=target)
    assert normalized_evidence(warm) == normalized_evidence(baseline)
    assert {'write', 'control', 'prior_state'} <= {edge.kind for edge in warm.edges}


def test_warm_cache_does_not_bypass_expired_deadline(tmp_path: Path) -> None:
    """命中候选仍经过 reader 截止时间检查，不能把过期请求报告为成功。"""
    path = small_run(tmp_path)
    cache = ParsedStateCache()
    with cache.activate():
        execute(path)
        with RunArtifacts.open(path) as run:
            run.reader.deadline = 0
            before = cache.statistics()
            with pytest.raises(TraceError) as caught:
                run.read_state(run.setup_id)
            assert caught.value.code == StopCode.TIME_BUDGET
            assert cache.statistics()['hits'] == before['hits']
