"""核对离线 trace 格式保真性，以及失败、未知和资源边界契约。"""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, Any

import pytest

from kcirct.trace.model import (
    ArtifactRef,
    BitRange,
    BitVector,
    Budget,
    CheckRecord,
    CheckSource,
    CompletionEvidence,
    DumpIndexEntry,
    FollowUpResult,
    Frontier,
    HypothesisRecord,
    Observation,
    ObservationMap,
    PortSpec,
    QueryCost,
    QueryRequest,
    QueryWindow,
    RecordRef,
    RunManifest,
    SourceBinding,
    SourceLocation,
    StateIndexEntry,
    StatusAxes,
    StopCode,
    StopReason,
    Target,
    TraceEdge,
    TraceError,
    TraceNode,
    TraceReport,
    ValueRef,
)

if TYPE_CHECKING:
    from collections.abc import Callable

    from kcirct.trace.model import JsonModel

SHA = 'abcd' * 16
OBSERVATION = Observation(phase='dump', event_index=8, time=80, time_unit='ns', sample=4)
TARGET = Target(kind='signal', name='top/out')
REQUEST = QueryRequest(target=TARGET, observation=OBSERVATION)
REFERENCE = RecordRef(path='../run/trace-run.json', id='run-a', sha256=SHA)


def artifact(role: str = 'execution_ir', path: str = 'design.generic.mlir') -> ArtifactRef:
    return ArtifactRef(role=role, path=path, sha256=SHA, size_bytes=256)


def mismatch() -> CheckRecord:
    return CheckRecord(
        id='first-output-mismatch',
        run_id='run-a',
        kind='value_mismatch',
        targets=(TARGET,),
        observation=OBSERVATION,
        source=CheckSource(kind='csv', record=RecordRef(path='expected.csv', sha256=SHA)),
        expected=BitVector(width=4, value='1'),
        actual=BitVector(width=4, value='0'),
    )


def value_ref(view: Any = 'observed') -> ValueRef:
    return ValueRef('run-a', 'eval-16', 'top/inst', 'op-9', '%9', view, bit_range=BitRange(0, 3))


def test_all_public_documents_round_trip() -> None:
    ir = artifact()
    raw = artifact('state', 'states/eval-16.kore.gz')
    state = StateIndexEntry(
        'eval-16',
        'post_eval',
        predecessor='eval-15',
        event_index=8,
        evaluation=2,
        time=80,
        time_unit='ns',
        artifact='state-16',
        content_sha256=SHA,
        retention='retained',
        completion=CompletionEvidence(status='completed'),
    )
    manifest = RunManifest(
        'run-a',
        'top',
        artifacts={'ir': ir, 'state-16': raw},
        ports=(PortSpec('out', 'output', 4, aliases=('top/out',)),),
        protocol={'evaluations_per_event': 2, 'initialization': 'unknown'},
        identities={'compiler': {'status': 'unknown'}, 'source_sha256': SHA},
        parameters={'COUNT': '4'},
        commands=(('kcirct', 'simulate', 'design.generic.mlir'),),
        state_index=artifact('state_index', 'trace-states.jsonl'),
        state_coverage={'first_event': 0, 'last_event': 8},
        completion=state.completion,
    )
    dump = DumpIndexEntry('dump-8', state.state_id, 8, 2, 80, 'ns', values={'out': BitVector(4, '0')})
    mapping = ObservationMap(
        'run-a',
        (OBSERVATION,),
        manifest.ports,
        {'sample_phase': 'dump', 'time_unit': 'ns'},
        columns={'out': 'out'},
        comparison_masks={'out': BitVector(4, '15')},
    )
    source = SourceBinding('run-a', ir, artifact('debug_ir', 'debug.mlir'), sources=(artifact('rtl', 'rtl/top.v'),))
    node = TraceNode(
        'n0',
        value_ref(),
        value=BitVector(4, '0'),
        type='i4',
        locations=(SourceLocation('declaration', source=source.sources[0], line=70),),
        facts={'held': False, 'prior_value': '0', 'unrecorded': None},
    )
    parent = replace(node, id='n1', ref=value_ref('prior'))
    hypothesis = HypothesisRecord(
        'h1',
        REFERENCE,
        '检查是否沿用历史状态',
        ('n0',),
        change_stimulus=('改变合法前置输入',),
        observation_points=(TARGET,),
    )
    outcome = FollowUpResult('new-test', 'follow_up', hypothesis_id='h1')
    report = TraceReport(
        'report-1',
        'run-a',
        REQUEST,
        status=StatusAxes(execution='completed', design_check='failed', metadata_integrity='valid', query='partial'),
        check=mismatch(),
        nodes=(node, parent),
        edges=(TraceEdge('n1', 'n0', 'prior_state'),),
        frontier=(Frontier(StopReason(StopCode.WINDOW_BOUNDARY, '已到查询窗口'), node_id='n1'),),
        cost=QueryCost(elapsed_seconds=0.25, nodes=2, states_read=1, read_bytes=256, peak_cache_bytes=256),
        hypotheses=(hypothesis,),
        follow_up_results=(outcome,),
    )
    documents: tuple[JsonModel, ...] = (
        manifest,
        state,
        dump,
        mapping,
        mismatch(),
        REQUEST,
        value_ref(),
        source,
        report,
        hypothesis,
        outcome,
    )
    for document in documents:
        assert type(document).from_json(document.to_json()) == document
        assert type(document).from_dict(document.to_dict()) == document


def test_large_bit_vectors_keep_string_and_exact_bit_pattern() -> None:
    expected = (1 << 257) - 17
    vector = BitVector.from_int(expected, width=257)
    assert vector.to_dict()['value'] == str(expected)
    assert BitVector.from_json(vector.to_json()).unsigned == expected
    assert BitVector(257, '0').unsigned == 0


@pytest.mark.parametrize('value', [0, False, -1, '01', '-1', '1.0', '0x1', 'x', 'z', '16'])
def test_reject_invalid_or_oversized_bit_vectors(value: Any) -> None:
    with pytest.raises(TraceError):
        BitVector(width=4, value=value)


def test_design_example_and_defaults() -> None:
    query = QueryRequest.from_dict(
        {
            'schema_version': 1,
            'target': {'kind': 'signal', 'name': 'axis_switch/m_axis_tvalid'},
            'observation': {'event_index': 8, 'phase': 'dump'},
            'check': {'path': 'checks.json', 'id': 'first-valid-mismatch'},
            'window': {'first_event': 0, 'last_event': 8},
            'budget': {'max_nodes': 10000, 'max_states': 1024, 'max_seconds': 60},
        }
    )
    assert query.budget == Budget()
    assert query.budget.max_state_bytes == 67_108_864
    assert query.budget.max_read_bytes == 2_147_483_648
    assert query.budget.max_cache_bytes == 134_217_728
    assert query.budget.max_ast_nodes == 2_000_000
    assert query.budget.max_ast_depth == 4096
    assert REQUEST.window == QueryWindow()
    assert RunManifest('r', 'top').identities == {'status': 'unknown'}


@pytest.mark.parametrize('version', [2, 0, '1', True, None])
def test_unknown_or_invalid_schema_is_rejected(version: Any) -> None:
    document = REQUEST.to_dict()
    document['schema_version'] = version
    with pytest.raises(TraceError) as error:
        QueryRequest.from_dict(document)
    assert error.value.code == StopCode.UNSUPPORTED_SCHEMA


def test_missing_version_unknown_field_duplicate_key_and_nonfinite_are_rejected() -> None:
    with pytest.raises(TraceError, match='缺少 schema_version'):
        QueryRequest.from_dict({})
    with pytest.raises(TraceError, match='未知字段'):
        QueryRequest.from_dict({**REQUEST.to_dict(), 'rewrite_depth': 8})
    with pytest.raises(TraceError, match='重复字段'):
        Budget.from_json('{"schema_version":1,"max_nodes":1,"max_nodes":2}')
    with pytest.raises(TraceError, match='非有限数'):
        Budget.from_json('{"schema_version":1,"max_seconds":NaN}')
    with pytest.raises(TraceError) as error:
        QueryRequest.from_dict({**REQUEST.to_dict(), 'budget': {'schema_version': 2}})
    assert error.value.code == StopCode.UNSUPPORTED_SCHEMA


@pytest.mark.parametrize(
    'field',
    [
        'max_nodes',
        'max_states',
        'max_seconds',
        'max_state_bytes',
        'max_read_bytes',
        'max_cache_bytes',
        'max_ast_nodes',
        'max_ast_depth',
    ],
)
@pytest.mark.parametrize('value', [0, -1, False, '1', float('inf')])
def test_budget_values_are_explicit_and_positive(field: str, value: Any) -> None:
    with pytest.raises(TraceError) as error:
        Budget.from_dict({'schema_version': 1, field: value})
    assert error.value.code == StopCode.INVALID_BUDGET


def test_check_kinds_preserve_failure_meaning_without_fabricating_expected() -> None:
    failure = CheckRecord(
        'p1',
        'run-a',
        'property_failure',
        (TARGET,),
        OBSERVATION,
        predicate='frame_len > 1',
        predicate_interpretation='violation',
        predicate_result=True,
        actual=BitVector(16, '3'),
    )
    assert failure.expected is None
    assert failure.source.generation_method == 'unknown'
    assert CheckRecord.from_json(failure.to_json()) == failure
    requirement = replace(
        failure, predicate='frame_len <= 1', predicate_interpretation='requirement', predicate_result=False
    )
    assert requirement.to_dict()['predicate_result'] is False
    pure = CheckRecord('s1', 'run-a', 'suspicious_observation', (TARGET,), OBSERVATION, actual=BitVector(4, '0'))
    assert pure.expected is None
    with pytest.raises(TraceError):
        replace(failure, expected=BitVector(16, '1'))
    with pytest.raises(TraceError):
        replace(pure, predicate_result=False)
    with pytest.raises(TraceError):
        replace(mismatch(), actual=BitVector(4, '1'))
    with pytest.raises(TraceError):
        replace(mismatch(), comparison_mask=BitVector(4, '0'))


def test_views_and_status_axes_are_distinct_and_zero_is_data() -> None:
    assert len({value_ref(view) for view in ('observed', 'operand', 'committed', 'prior')}) == 4
    with pytest.raises(TraceError):
        value_ref('dump')
    status = StatusAxes(execution='completed', design_check='failed', metadata_integrity='invalid', query='rejected')
    assert status.reference_comparison == 'not_run'
    assert StatusAxes.from_json(status.to_json()) == status
    for name, value in [('design_check', False), ('execution', 0), ('metadata_integrity', 'passed')]:
        with pytest.raises(TraceError):
            StatusAxes.from_dict({'schema_version': 1, name: value})


def test_setup_post_eval_dump_and_retention_do_not_mix() -> None:
    setup = StateIndexEntry('setup', 'setup')
    assert setup.event_index is None
    assert setup.completion.status == 'not_checked'
    transient = StateIndexEntry('e0v1', 'post_eval', event_index=0, evaluation=1, content_sha256=SHA)
    assert transient.artifact is None
    assert transient.content_sha256 == SHA
    invalid_constructors: tuple[Callable[[], Any], ...] = (
        lambda: replace(setup, event_index=0),
        lambda: replace(setup, retention='retained'),
        lambda: replace(transient, artifact='rolling-state'),
        lambda: replace(transient, evaluation=0),
        lambda: replace(transient, content_sha256='bad'),
        lambda: Observation('post_eval', event_index=0),
        lambda: Observation('dump', event_index=False),
        lambda: Observation('dump', time=0),
        lambda: Observation('post_eval', event_index=0, evaluation=1, dump_id='d0'),
    )
    for constructor in invalid_constructors:
        with pytest.raises(TraceError):
            constructor()


def test_artifact_hash_compression_and_source_roles() -> None:
    packed = replace(artifact('state', 'states/0.kore.gz'), compression='gzip', uncompressed_sha256=SHA)
    assert packed.to_dict()['uncompressed_sha256'] == SHA
    with pytest.raises(TraceError):
        replace(packed, uncompressed_sha256=None)
    with pytest.raises(TraceError):
        replace(packed, sha256='no digest')
    with pytest.raises(TraceError):
        replace(packed, path='/old/absolute/path')
    with pytest.raises(TraceError):
        SourceBinding('r', artifact('rtl'))
    with pytest.raises(TraceError):
        SourceLocation('exact', line=10)
    with pytest.raises(TraceError) as error:
        RunManifest('r', 'top', artifacts={'a': artifact(), 'b': artifact()})
    assert error.value.code == StopCode.DUPLICATE_IDENTITY


def test_follow_up_replay_regression_require_new_evidence() -> None:
    for relation in ('follow_up', 'replay', 'regression'):
        outcome = FollowUpResult.from_dict({'schema_version': 1, 'id': 'f1', 'relation': relation})
        assert outcome.outcome == 'not_run'
        with pytest.raises(TraceError):
            replace(outcome, outcome='supports')
        supported = replace(
            outcome,
            outcome='supports',
            run=REFERENCE,
            check=REFERENCE,
            report=REFERENCE,
            submitted_by='test-adapter',
            observations=(REFERENCE,),
        )
        assert FollowUpResult.from_json(supported.to_json()) == supported
    with pytest.raises(TraceError):
        FollowUpResult.from_dict({'schema_version': 1, 'id': 'f1', 'relation': 'supports'})
    with pytest.raises(TraceError):
        HypothesisRecord('h1', REFERENCE, '假设', ('n0',), oracle_status='provided')


def test_report_does_not_label_unchecked_observation_as_design_failure() -> None:
    with pytest.raises(TraceError):
        TraceReport('r1', 'run-a', REQUEST, status=StatusAxes(design_check='failed'))
    with pytest.raises(TraceError) as error:
        TraceReport('r1', 'run-b', REQUEST, check=mismatch())
    assert error.value.code == StopCode.IDENTITY_MISMATCH


def test_stable_stop_codes_survive_serialization() -> None:
    for code in StopCode:
        reason = StopReason(code, '已到明确边界', {'read_bytes': 0, 'verified': False, 'missing': None})
        assert StopReason.from_json(reason.to_json()) == reason
        assert reason.to_dict()['code'] == code.value
    error = TraceError(StopCode.HISTORY_GAP, '缺少中间状态', state_id='e3v1')
    assert error.code == 'history_gap'
    assert error.details == {'state_id': 'e3v1'}
