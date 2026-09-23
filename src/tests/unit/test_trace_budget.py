"""超限与失去响应的解析不能绕过查询预算。"""

from __future__ import annotations

import gzip
import multiprocessing
import sys
import time
from pathlib import Path
from typing import Any

import pytest

from kcirct.trace import kore
from kcirct.trace.kore import KoreReader, lexical_precheck
from kcirct.trace.model import Budget, Frontier, StopCode, StopReason, TraceError

FIXTURE = Path(__file__).parents[1] / 'resources/trace/unit/minimal-state.kore'


def test_gzip_bomb_stops_during_chunk_read(tmp_path: Path) -> None:
    """验证高压缩比工件在分块解压时触发单状态字节预算，并准确记录越界读取量。"""
    path = tmp_path / 'bomb.kore.gz'
    path.write_bytes(gzip.compress(b' ' * 2_000_000, mtime=0))
    with KoreReader(Budget(max_state_bytes=8000)) as reader, pytest.raises(TraceError) as caught:
        reader.read(path)
    assert caught.value.code == StopCode.STATE_BYTES_BUDGET
    assert caught.value.details['read_bytes'] == reader.read_bytes == 8001


def test_cumulative_read_budget_charges_failed_attempts() -> None:
    """验证哈希失败的读取仍计入累计预算，耗尽后再次读取不再消耗字节。"""
    size = FIXTURE.stat().st_size
    with KoreReader(Budget(max_read_bytes=size + 10)) as reader:
        with pytest.raises(TraceError) as first:
            reader.read(FIXTURE, artifact_sha256='0' * 64)
        assert first.value.code == StopCode.HASH_MISMATCH
        with pytest.raises(TraceError) as second:
            reader.read(FIXTURE)
        assert second.value.code == StopCode.READ_BYTES_BUDGET
        assert second.value.details['read_bytes'] == 11
        assert reader.read_bytes == size + 11
        with pytest.raises(TraceError) as third:
            reader.read(FIXTURE)
        assert third.value.details['read_bytes'] == 0


def test_state_attempt_budget_includes_errors() -> None:
    """验证失败的读取尝试同样占用状态次数预算，不能通过重试绕过限制。"""
    with KoreReader(Budget(max_states=1)) as reader:
        with pytest.raises(TraceError):
            reader.read(FIXTURE, artifact_sha256='0' * 64)
        with pytest.raises(TraceError) as caught:
            reader.read(FIXTURE)
        assert caught.value.code == StopCode.STATE_BUDGET


def test_lexer_ignores_string_brackets_and_escaped_quotes() -> None:
    """验证词法深度检查忽略字符串内部的括号和转义引号。"""
    text = r'\dv{SortString{}}("(({{\"quoted\"}}))")'
    _, depth = lexical_precheck(text, Budget(max_ast_depth=2))
    assert depth == 2


def test_depth_limit_before_ast_creation(tmp_path: Path) -> None:
    """验证过深的 KORE 在构造 AST 前被拒绝，并报告首次超限的深度。"""
    path = tmp_path / 'deep.kore'
    path.write_text('F{}(' * 2000 + 'Z{}()' + ')' * 2000)
    with KoreReader(Budget(max_ast_depth=30)) as reader, pytest.raises(TraceError) as caught:
        reader.read(path)
    assert caught.value.code == StopCode.AST_DEPTH_BUDGET
    assert caught.value.details['ast_depth'] == 31


def test_node_limit_before_ast_creation() -> None:
    """验证节点数预算在 AST 创建前生效并返回对应停止码。"""
    with KoreReader(Budget(max_ast_nodes=20)) as reader, pytest.raises(TraceError) as caught:
        reader.read(FIXTURE)
    assert caught.value.code == StopCode.AST_NODES_BUDGET


def test_allowed_deep_term_returns_without_recursive_serialization(tmp_path: Path) -> None:
    """验证预算内的深层 term 可完整传回主进程，且无需修改 Python 递归上限。"""
    depth = 1200
    path = tmp_path / 'allowed-deep.kore'
    nested = 'LblNest{}(' * depth + 'dotk{}()' + ')' * depth
    path.write_text(
        FIXTURE.read_text().replace("Lbl'-LT-'prog'-GT-'{}(dotk{}())", "Lbl'-LT-'prog'-GT-'{}(" + nested + ')', 1)
    )
    recursion_limit = sys.getrecursionlimit()
    with KoreReader(Budget(max_ast_depth=1300)) as reader:
        state = reader.read(path)
    term = state.cells['prog']
    for _ in range(depth):
        assert term.symbol == 'LblNest'
        (term,) = term.args
    assert term.symbol == 'dotk'
    assert state.completion.status == 'incomplete'
    assert sys.getrecursionlimit() == recursion_limit


def _stuck_worker(connection: Any, budget: Any, counter: Any) -> None:
    """模拟已接收请求并读取部分字节后卡住的独立解析进程，用于验证超时清理。"""
    connection.recv()
    counter.value = 123
    time.sleep(20)


def test_worker_is_terminated_and_existing_frontier_is_preserved(monkeypatch: pytest.MonkeyPatch) -> None:
    # spawn 的目标函数可独立导入；模拟解析器不再返回，而非只测开始前预算检查。
    """验证卡住的解析进程被及时终止，保留已读字节和原有停止点且不遗留子进程。"""
    monkeypatch.setattr(kore, '_worker', _stuck_worker)
    frontier = [Frontier(reason=StopReason(code=StopCode.MISSING_VALUE, message='已有停止点'))]
    original = tuple(frontier)
    started = time.monotonic()
    with KoreReader(Budget(max_seconds=2)) as reader:
        with pytest.raises(TraceError) as caught:
            reader.read(FIXTURE)
        assert caught.value.code == StopCode.TIME_BUDGET
        assert reader.read_bytes == 123
        assert caught.value.details['read_bytes'] == 123
        assert reader._process is None
        frontier.append(Frontier(reason=StopReason(code=caught.value.code, message=caught.value.message)))
    assert time.monotonic() - started < 4
    assert tuple(frontier[:-1]) == original
    assert not [child for child in multiprocessing.active_children() if child.name.startswith('SpawnProcess')]


def test_deadline_is_from_query_start() -> None:
    """验证传入已过期的查询截止时间时，读取器在启动进程或读字节前立即停止。"""
    reader = KoreReader(Budget(max_seconds=60), deadline=time.monotonic() - 1)
    with pytest.raises(TraceError) as caught:
        reader.read(FIXTURE)
    assert caught.value.code == StopCode.TIME_BUDGET
    assert reader.states_read == reader.read_bytes == 0
    assert reader._process is None


def test_worker_reused_until_close() -> None:
    """验证连续读取复用解析子进程，并在关闭读取器时释放该进程。"""
    reader = KoreReader()
    reader.read(FIXTURE)
    first = reader._process
    reader.read(FIXTURE)
    assert reader._process is first
    reader.close()
    assert reader._process is None


def test_single_large_value_stops_before_large_ipc_receive(tmp_path: Path) -> None:
    """验证单值超过 IPC 帧上限时显式停止，避免主进程接收无界消息。"""
    path = tmp_path / 'large-value.kore'
    text = FIXTURE.read_text().replace('"DemoMod"', '"' + 'x' * (kore._IPC_BYTES * 2) + '"')
    path.write_text(text)
    with KoreReader() as reader, pytest.raises(TraceError) as caught:
        reader.read(path)
    assert caught.value.code == StopCode.UNSUPPORTED_VALUE
    assert caught.value.details['max_ipc_bytes'] == kore._IPC_BYTES
    assert caught.value.details['ipc_bytes'] > kore._IPC_BYTES
    assert reader.read_bytes == len(text.encode())


def test_many_large_values_are_split_into_bounded_frames(tmp_path: Path) -> None:
    """验证多个大值可拆成受限 IPC 帧传输，并完整恢复未完成的程序单元。"""
    values = [r'\dv{SortString{}}("' + str(index) + 'x' * 2048 + '")' for index in range(128)]
    contents = 'LblPending{}(' + ','.join(values) + ')'
    path = tmp_path / 'large-batch.kore'
    path.write_text(
        FIXTURE.read_text().replace("Lbl'-LT-'prog'-GT-'{}(dotk{}())", "Lbl'-LT-'prog'-GT-'{}(" + contents + ')', 1)
    )
    with KoreReader() as reader:
        state = reader.read(path)
    assert len(state.cells['prog'].args) == 128
    assert state.completion.status == 'incomplete'
