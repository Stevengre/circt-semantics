"""调查动作真正逐层执行、预算和恢复边界；合成状态仅测试 Python 编排。"""

from __future__ import annotations

import json
import shutil
import time
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from kcirct.trace import TraceRun
from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.comparison import normalized_evidence
from kcirct.trace.model import (
    BitVector,
    Budget,
    CheckRecord,
    CheckSource,
    Observation,
    QueryRequest,
    QueryWindow,
    RecordRef,
    RunManifest,
    SourceBinding,
    StopCode,
    Target,
    TraceError,
)
from kcirct.trace.query import _Query
from kcirct.trace.session import InvestigationSession, SessionBudget
from kcirct.trace.topology import TraceTopology

from .test_trace_memory import Snapshot, memory_run
from .test_trace_query import PROFILE, artifact, small_run
from .test_trace_register import register_run

if TYPE_CHECKING:
    from kcirct.trace.model import TraceReport


@pytest.fixture
def synthetic_profile(monkeypatch: pytest.MonkeyPatch) -> None:
    """只替换测试中的 profile 绑定，生产入口仍拒绝未绑定的合成状态。"""
    monkeypatch.setattr('kcirct.trace.session.bind_semantics', lambda _run: PROFILE)


def _request() -> QueryRequest:
    """固定完整状态身份，避免按最近时刻选择。"""
    return QueryRequest(Target('signal', name='Demo/result'), Observation('post_eval', state_id='state1', evaluation=1))


def _direct(path: Path, request: QueryRequest) -> TraceReport:
    """以同样请求运行原始完整查询，提供独立于会话调度的等价参照。"""
    with RunArtifacts.open(path, budget=request.budget) as run:
        topology = TraceTopology.from_run(run)
        return _Query(run, request, topology, PROFILE).execute(topology.resolve(request.target))


def _finish(session: InvestigationSession) -> TraceReport:
    """仅沿已返回 pending 逐层请求，不窥视内部完整图。"""
    for _ in range(200):
        report = session.report()
        pending = [item.node_id for item in report.frontier if item.reason.code == StopCode.PENDING_EXPANSION]
        if not pending:
            return report
        assert pending[0] is not None
        session.expand(pending[0], actor='test')
    raise AssertionError('pending 没有收敛')


@pytest.mark.usefixtures('synthetic_profile')
def test_real_incremental_branch_selection_and_complete_equivalence(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """初始不调用展开；一次动作只调用一次局部规则，未选控制仍明确 pending。"""
    path = small_run(tmp_path / 'run')
    calls: list[str] = []
    original = _Query._expand

    def count(engine: _Query, identity: str):  # type: ignore[no-untyped-def]
        calls.append(identity)
        return original(engine, identity)

    monkeypatch.setattr(_Query, '_expand', count)
    with InvestigationSession.create(
        TraceRun.open(path), _request(), tmp_path / 'session.json', actor='analyst'
    ) as session:
        root = session.report().nodes[0].id
        assert calls == [] and len(session.report().nodes) == 1
        assert session.report().status.query == 'partial'
        first = session.expand(root, actor='analyst')
        assert calls == [root] and len(first.nodes) == 2
        mux = next(node.id for node in first.nodes if node.ref.result == 'Demo/%mux')
        data = session.expand(mux, actor='analyst', branch='data')
        assert calls == [root, mux]
        assert not any(edge.kind == 'control' for edge in data.edges)
        assert mux in [item.node_id for item in data.frontier]
        control = session.expand(mux, actor='analyst', branch='control')
        assert calls == [root, mux]
        assert any(edge.kind == 'control' for edge in control.edges)
        complete = _finish(session)
        assert complete.status.query == 'complete'
        assert normalized_evidence(complete) == normalized_evidence(_direct(path, _request()))


@pytest.mark.usefixtures('synthetic_profile')
@pytest.mark.parametrize('kind', ['same_value_register', 'history', 'same_value_memory', 'unsupported', 'cycle'])
def test_temporal_and_stopped_evidence_matches_direct(tmp_path: Path, kind: str) -> None:
    """控制、同值采样/写入、历史与不支持边界均不能被逐层调度省略。"""
    request = _request()
    if kind == 'same_value_register':
        path = register_run(tmp_path / 'run', [{'a': 0, 'c': 1, 'r': 0}])
        request = replace(request, target=Target('register', name='Demo/count'))
    elif kind == 'history':
        path = register_run(tmp_path / 'run', [{'a': 7, 'c': 1, 'r': 7}, {'a': 9, 'c': 0, 'r': 7}])
        request = replace(
            request,
            target=Target('register', name='Demo/count'),
            observation=Observation('post_eval', state_id='state2', evaluation=1),
        )
    elif kind == 'same_value_memory':
        path = memory_run(tmp_path / 'run', [Snapshot(memory={1: 0}, clock=1, address=1, data=0)])
        request = replace(request, target=Target('memory_cell', name='Demo/store', address='1'))
    else:
        path = small_run(tmp_path / 'run', unknown=kind == 'unsupported', cycle=kind == 'cycle')
    with InvestigationSession.create(TraceRun.open(path), request, tmp_path / 'session.json', actor='test') as session:
        complete = _finish(session)
        assert normalized_evidence(complete) == normalized_evidence(_direct(path, request))
        if kind == 'same_value_register':
            assert any(edge.kind == 'capture' for edge in complete.edges)
        if kind == 'same_value_memory':
            assert any(edge.kind == 'write' for edge in complete.edges)
        if kind == 'history':
            assert any(edge.kind == 'prior_state' for edge in complete.edges)


@pytest.mark.usefixtures('synthetic_profile')
def test_multiple_queries_windows_selection_revisit_and_resume(tmp_path: Path) -> None:
    """不同窗口留作独立查询，恢复重放所有查询和最后选择，同时计入恢复成本。"""
    path = small_run(tmp_path / 'run')
    journal = tmp_path / 'session.json'
    with InvestigationSession.create(TraceRun.open(path), _request(), journal, actor='first') as session:
        original = _finish(session)
        second = session.query(replace(_request(), window=QueryWindow(first_event=0)), actor='second')
        session.select(session.report().nodes[0].id, actor='second')
        revisited = session.revisit('q1', actor='first')
        assert normalized_evidence(original) == normalized_evidence(revisited)
        before = session.cost
    with InvestigationSession.resume(journal, actor='replay') as resumed:
        assert set(resumed.queries) == {'q1', second}
        assert resumed.selected == 'q1'
        assert normalized_evidence(original) == normalized_evidence(resumed.report())
        assert resumed.cost['read_bytes'] > before['read_bytes']
        assert resumed.cost['elapsed_seconds'] > before['elapsed_seconds']
        assert resumed.report(second).status.query == 'partial'


@pytest.mark.usefixtures('synthetic_profile')
def test_relocated_session_and_tampered_state(tmp_path: Path) -> None:
    """目录搬迁使用相对引用重放；原状态篡改不能由旧图缓存掩盖。"""
    original = tmp_path / 'original'
    original.mkdir()
    path = small_run(original / 'run')
    with InvestigationSession.create(
        TraceRun.open(path), _request(), original / 'session.json', actor='test'
    ) as session:
        full = _finish(session)
    moved = tmp_path / 'moved'
    shutil.move(str(original), moved)
    with InvestigationSession.resume(moved / 'session.json', actor='moved') as session:
        assert normalized_evidence(session.report()) == normalized_evidence(full)
    state = moved / 'run/state1.kore'
    state.write_text(state.read_text() + '\n')
    with pytest.raises(TraceError, match='哈希|大小'):
        InvestigationSession.resume(moved / 'session.json', actor='tamper')
    document = json.loads((moved / 'session.json').read_text())
    assert document['journal'][-1]['status'] == 'error'


@pytest.mark.usefixtures('synthetic_profile')
def test_tampered_journal_is_rejected(tmp_path: Path) -> None:
    """修改动作请求或演员后不重算哈希会在读取任何状态前拒绝。"""
    journal = tmp_path / 'session.json'
    with InvestigationSession.create(TraceRun.open(small_run(tmp_path / 'run')), _request(), journal, actor='test'):
        pass
    document = json.loads(journal.read_text())
    document['journal'][0]['actor'] = 'forged'
    journal.write_text(json.dumps(document))
    with pytest.raises(TraceError) as caught:
        InvestigationSession.resume(journal, actor='test')
    assert caught.value.code == StopCode.HASH_MISMATCH


@pytest.mark.usefixtures('synthetic_profile')
def test_failed_action_cost_and_read_budget_are_not_reset(tmp_path: Path) -> None:
    """新增查询读取失败仍记录消耗；累计预算耗尽不能换动作重试绕过。"""
    journal = tmp_path / 'session.json'
    path = small_run(tmp_path / 'run')
    with InvestigationSession.create(TraceRun.open(path), _request(), journal, actor='test') as session:
        before = session.cost
        with pytest.raises(TraceError) as caught:
            session.query(_request(), actor='test', budget=Budget(max_read_bytes=10))
        assert caught.value.code == StopCode.READ_BYTES_BUDGET
        assert session.cost['read_bytes'] > before['read_bytes']
        assert session.cost['queries'] == 2 and set(session.queries) == {'q1'}
        assert session.document['journal'][-1]['status'] == 'error'
        assert session.document['journal'][-1]['cost']['read_bytes'] > 0
        session.budget = replace(session.budget, max_read_bytes=int(session.cost['read_bytes']))
        with pytest.raises(TraceError) as exhausted:
            session.select(session.report().nodes[0].id, actor='test')
        assert exhausted.value.code == StopCode.INVALID_BUDGET


@pytest.mark.usefixtures('synthetic_profile')
def test_interrupted_intent_reserves_budget_and_restores_previous_commit(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """进程级中断不写成功回执；恢复只重放提交动作并保守收取中断预算。"""
    journal = tmp_path / 'session.json'
    with InvestigationSession.create(
        TraceRun.open(small_run(tmp_path / 'run')), _request(), journal, actor='test'
    ) as session:
        original = session.report()
        before = session.cost
        with monkeypatch.context() as patch:

            def interrupt(*_args: object) -> None:
                raise KeyboardInterrupt()

            patch.setattr(session, '_apply', interrupt)
            with pytest.raises(KeyboardInterrupt):
                session.expand(
                    original.nodes[0].id, actor='interrupt', budget=Budget(max_seconds=1, max_read_bytes=1000)
                )
        assert session.cost['read_bytes'] == before['read_bytes'] + 1000
        assert session.cost['elapsed_seconds'] == before['elapsed_seconds'] + 1
    with InvestigationSession.resume(journal, actor='recovery') as resumed:
        assert normalized_evidence(resumed.report()) == normalized_evidence(original)
        assert resumed.cost['read_bytes'] > before['read_bytes'] + 1000


@pytest.mark.usefixtures('synthetic_profile')
def test_check_record_actual_is_revalidated_not_trusted(tmp_path: Path) -> None:
    """检查入口通过原始加载器和 normalize_check，不能抄入会话中的伪造实际值。"""
    path = small_run(tmp_path / 'run')
    request = _request()
    check = CheckRecord(
        'bad',
        'small-run',
        'value_mismatch',
        (request.target,),
        request.observation,
        CheckSource('manual'),
        expected=BitVector(8, '9'),
        actual=BitVector(8, '8'),
    )
    check_path = tmp_path / 'check.json'
    check_path.write_text(check.to_json())
    request = replace(request, check=RecordRef('check.json', 'bad'))
    with pytest.raises(TraceError) as caught:
        InvestigationSession.create(TraceRun.open(path), request, tmp_path / 'session.json', actor='test')
    assert caught.value.code == StopCode.OBSERVATION_MISMATCH


def test_production_rejects_unbound_synthetic_profile(tmp_path: Path) -> None:
    """不启用测试替换的公共会话拒绝未核验 profile。"""
    with pytest.raises(TraceError) as caught:
        InvestigationSession.create(
            TraceRun.open(small_run(tmp_path / 'run')), _request(), tmp_path / 'session.json', actor='test'
        )
    assert caught.value.code == StopCode.UNSUPPORTED_SEMANTICS


@pytest.mark.usefixtures('synthetic_profile')
def test_time_failure_rolls_back_graph_and_charges_elapsed(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """耗时失败保留原图，已花费时间计费，不能把动作误记为完成。"""
    path = small_run(tmp_path / 'run')
    with InvestigationSession.create(
        TraceRun.open(path), _request(), tmp_path / 'session.json', actor='test'
    ) as session:
        initial = session.report()
        original = _Query._expand

        def slow(engine: _Query, node: str):  # type: ignore[no-untyped-def]
            time.sleep(0.02)
            return original(engine, node)

        monkeypatch.setattr(_Query, '_expand', slow)
        with pytest.raises(TraceError) as caught:
            session.expand(initial.nodes[0].id, actor='test', budget=Budget(max_seconds=0.01))
        assert caught.value.code == StopCode.TIME_BUDGET
        assert normalized_evidence(session.report()) == normalized_evidence(initial)
        receipt = session.document['journal'][-1]
        assert receipt['status'] == 'error' and receipt['cost']['elapsed_seconds'] >= 0.01


@pytest.mark.usefixtures('synthetic_profile')
def test_live_revisit_revalidates_state_and_resume_respects_combined_budget(tmp_path: Path) -> None:
    """纯重访也重验状态，恢复多个查询不能给每个查询重复分配动作读取预算。"""
    path = small_run(tmp_path / 'run')
    journal = tmp_path / 'session.json'
    with InvestigationSession.create(TraceRun.open(path), _request(), journal, actor='test') as session:
        session.query(_request(), actor='test')
        (path.parent / 'state1.kore').write_text('changed')
        with pytest.raises(TraceError) as caught:
            session.revisit('q1', actor='test')
        assert caught.value.code == StopCode.HASH_MISMATCH
    # Restore original fixture bytes; the failed revisit remains charged.
    small_run(path.parent)
    with pytest.raises(TraceError) as caught:
        InvestigationSession.resume(journal, actor='test', budget=Budget(max_read_bytes=100))
    assert caught.value.code == StopCode.READ_BYTES_BUDGET
    assert json.loads(journal.read_text())['journal'][-1]['cost']['read_bytes'] > 0


@pytest.mark.usefixtures('synthetic_profile')
def test_missing_source_precision_and_locate_budget(tmp_path: Path) -> None:
    """缺失源码保留 source_missing；定位读取有成本，且不污染值图的规范化证据。"""
    path = small_run(tmp_path / 'run')
    execution = """"builtin.module"() ({
 "hw.module"() <{sym_name = "DemoMod"}> ({
 ^bb0(%a: i8):
  %select = "hw.constant"() <{value = 1 : i1}> : () -> i1
  %other = "hw.constant"() <{value = 99 : i8}> : () -> i8
  %mux = "comb.mux"(%select, %a, %other) : (i1, i8, i8) -> i8
  "hw.output"(%mux) : (i8) -> ()
 }) : () -> ()
}) : () -> ()
"""
    execution_path = path.parent / 'execution.mlir'
    debug = tmp_path / 'debug.mlir'
    rtl = tmp_path / 'rtl.v'
    execution_path.write_text(execution)
    debug.write_text(execution.replace('-> i8\n', '-> i8 loc("rtl.v":2:1)\n'))
    rtl.write_text('module Demo;\nassign out = sel ? a : b;\nendmodule\n')
    manifest = RunManifest.from_json(path.read_text())
    path.write_text(
        replace(
            manifest,
            artifacts={**manifest.artifacts, 'execution_ir': artifact(execution_path, path.parent, 'execution_ir')},
        ).to_json()
    )
    binding = SourceBinding(
        manifest.run_id,
        artifact(execution_path, tmp_path, 'execution_ir'),
        artifact(debug, tmp_path, 'debug_ir'),
        sources=(artifact(rtl, tmp_path, 'rtl'),),
    )
    binding_path = tmp_path / 'binding.json'
    binding_path.write_text(binding.to_json())
    rtl.unlink()
    with InvestigationSession.create(
        TraceRun.open(path), _request(), tmp_path / 'session.json', actor='test'
    ) as session:
        first = session.expand(session.report().nodes[0].id, actor='test')
        mux = next(node.id for node in first.nodes if node.ref.result == 'Demo/%mux')
        before = normalized_evidence(session.report())
        located = session.locate(mux, actor='test', source_binding=binding_path)
        assert located['locations'][0]['precision'] == 'source_missing'
        assert normalized_evidence(session.report()) == before
        assert session.document['journal'][-1]['cost']['verification_bytes'] > 0
        with pytest.raises(TraceError) as caught:
            session.locate(mux, actor='test', source_binding=binding_path, budget=Budget(max_read_bytes=10))
        assert caught.value.code == StopCode.READ_BYTES_BUDGET
        complete = _finish(session)
        assert normalized_evidence(complete) == normalized_evidence(_direct(path, _request()))


@pytest.mark.usefixtures('synthetic_profile')
def test_single_writer_action_limit_and_idle_cost(tmp_path: Path) -> None:
    """禁止并发重写同一日志；动作额度不能靠查询重访绕过，空闲时间不算执行。"""
    path = small_run(tmp_path / 'run')
    journal = tmp_path / 'session.json'
    with InvestigationSession.create(
        TraceRun.open(path), _request(), journal, actor='test', budget=SessionBudget(max_actions=2)
    ) as session:
        initial = session.report()
        time.sleep(0.01)
        assert session.report().cost.elapsed_seconds == initial.cost.elapsed_seconds
        with pytest.raises(TraceError) as caught:
            InvestigationSession.resume(journal, actor='other-writer')
        assert caught.value.code == StopCode.INVALID_INPUT
        session.revisit('q1', actor='test')
        with pytest.raises(TraceError) as caught:
            session.revisit('q1', actor='test')
        assert caught.value.code == StopCode.INVALID_BUDGET
        assert session.cost['actions'] == 2


@pytest.mark.usefixtures('synthetic_profile')
def test_query_node_limit_and_failed_expansion_rollback(tmp_path: Path) -> None:
    """请求原有节点总额在逐层动作中仍生效，失败展开不会提交半条依赖。"""
    path = small_run(tmp_path / 'run')
    request = replace(_request(), budget=Budget(max_nodes=1))
    with InvestigationSession.create(TraceRun.open(path), request, tmp_path / 'session.json', actor='test') as session:
        initial = session.report()
        with pytest.raises(TraceError) as caught:
            session.expand(initial.nodes[0].id, actor='test')
        assert caught.value.code == StopCode.NODE_BUDGET
        assert normalized_evidence(session.report()) == normalized_evidence(initial)
        assert session.document['journal'][-1]['cost']['verification_bytes'] > 0


@pytest.mark.usefixtures('synthetic_profile')
def test_exact_state_budget_does_not_charge_cache_hits(tmp_path: Path) -> None:
    """恰好两个解码状态的预算允许后续缓存核验，不把哈希扫描当成第三次解码。"""
    path = small_run(tmp_path / 'run')
    request = replace(_request(), budget=Budget(max_states=2))
    with InvestigationSession.create(TraceRun.open(path), request, tmp_path / 'session.json', actor='test') as session:
        complete = _finish(session)
        assert complete.status.query == 'complete'
        assert normalized_evidence(complete) == normalized_evidence(_direct(path, request))
