"""假设与后续结果只链接经过身份校验的独立记录。"""

from __future__ import annotations

import hashlib
import os
from pathlib import Path
from typing import Literal

import pytest

from kcirct.trace.model import (
    ArtifactRef,
    BitVector,
    CheckRecord,
    FollowUpResult,
    HypothesisRecord,
    Observation,
    QueryRequest,
    RecordRef,
    RunManifest,
    StopCode,
    Target,
    TraceError,
    TraceNode,
    TraceReport,
    ValueRef,
)
from kcirct.trace.report import link_report


def _sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _ref(path: Path, carrier: Path, identity: str | None = None) -> RecordRef:
    return RecordRef(Path(os.path.relpath(path, carrier.parent)).as_posix(), identity, _sha(path))


def _manifest(root: Path, run_id: str, *, ir: bytes = b'same ir', inputs: bytes = b'same inputs') -> Path:
    root.mkdir()
    execution, events = root / 'design.mlir', root / 'inputs.json'
    execution.write_bytes(ir)
    events.write_bytes(inputs)
    artifacts = {
        'execution': ArtifactRef('execution_ir', execution.name, _sha(execution), execution.stat().st_size),
        'inputs': ArtifactRef('inputs', events.name, _sha(events), events.stat().st_size),
    }
    manifest = root / 'trace-run.json'
    manifest.write_text(
        RunManifest(
            run_id,
            'Demo',
            artifacts=artifacts,
            protocol={'evaluations_per_input': 2, 'sampling_phase': 'dump', 'timescale': '1ns'},
        ).to_json()
    )
    return manifest


def _report(root: Path, run: Path, report_id: str, run_id: str) -> Path:
    root.mkdir()
    target = Target('signal', name='Demo/out')
    observation = Observation('post_eval', state_id='state1', evaluation=1)
    node = TraceNode(
        'node-1',
        ValueRef(run_id, 'state1', 'Demo', 'Demo/%out', 'Demo/%out', 'observed'),
        value=BitVector(1, '1'),
    )
    report = TraceReport(
        report_id,
        run_id,
        QueryRequest(target, observation),
        run=_ref(run, root / 'report.json', run_id),
        nodes=(node,),
        scope={'design_conclusion': '查询不自动证明根因'},
    )
    path = root / 'report.json'
    path.write_text(report.to_json())
    return path


def _check(root: Path, run_id: str) -> Path:
    path = root / 'check.json'
    path.write_text(
        CheckRecord(
            'check-1',
            run_id,
            'suspicious_observation',
            (Target('signal', name='Demo/out'),),
            Observation('post_eval', state_id='state1', evaluation=1),
            actual=BitVector(1, '1'),
        ).to_json()
    )
    return path


def test_hypothesis_is_bound_to_existing_report_nodes_and_original_is_unchanged(tmp_path: Path) -> None:
    run = _manifest(tmp_path / 'run', 'run-old')
    report = _report(tmp_path / 'original', run, 'report-old', 'run-old')
    original = report.read_bytes()
    carrier = tmp_path / 'hypothesis.json'
    carrier.write_text(
        HypothesisRecord(
            'hypothesis-1',
            _ref(report, carrier, 'report-old'),
            '前一状态可能影响当前值',
            ('node-1',),
            observed_conditions=('当前值为 1',),
        ).to_json()
    )
    linked = link_report(report, tmp_path / 'linked', hypothesis_path=carrier)
    assert [item.id for item in linked.hypotheses] == ['hypothesis-1']
    assert linked.hypotheses[0].oracle_status == 'needs_oracle'
    assert report.read_bytes() == original
    assert (tmp_path / 'linked/summary.md').is_file()


def test_hypothesis_wrong_report_hash_or_unknown_node_is_rejected(tmp_path: Path) -> None:
    run = _manifest(tmp_path / 'run', 'run-old')
    report = _report(tmp_path / 'original', run, 'report-old', 'run-old')
    for name, reference, nodes, code in (
        ('hash', RecordRef('original/report.json', 'report-old', '0' * 64), ('node-1',), StopCode.HASH_MISMATCH),
        ('node', _ref(report, tmp_path / 'node.json', 'report-old'), ('missing',), StopCode.IDENTITY_MISMATCH),
    ):
        carrier = tmp_path / f'{name}.json'
        if name == 'hash':
            reference = RecordRef(Path(os.path.relpath(report, carrier.parent)).as_posix(), 'report-old', '0' * 64)
        carrier.write_text(HypothesisRecord('h-' + name, reference, '待验证假设', nodes).to_json())
        with pytest.raises(TraceError) as error:
            link_report(report, tmp_path / ('out-' + name), hypothesis_path=carrier)
        assert error.value.code == code


def test_replay_requires_same_ir_inputs_layout_and_sampling_contract(tmp_path: Path) -> None:
    original_run = _manifest(tmp_path / 'old-run', 'run-old')
    current_run = _manifest(tmp_path / 'new-run', 'run-new')
    original_report = _report(tmp_path / 'original', original_run, 'report-old', 'run-old')
    current_report = _report(tmp_path / 'current', current_run, 'report-new', 'run-new')
    check = _check(tmp_path / 'current', 'run-new')
    observation = tmp_path / 'current/observation.json'
    observation.write_text('{"actual": 1}\n')
    carrier = tmp_path / 'outcome.json'
    carrier.write_text(
        FollowUpResult(
            'replay-1',
            'replay',
            outcome='supports',
            run=_ref(current_run, carrier, 'run-new'),
            check=_ref(check, carrier, 'check-1'),
            report=_ref(current_report, carrier, 'report-new'),
            submitted_by='independent-test',
            observations=(_ref(observation, carrier),),
        ).to_json()
    )
    linked = link_report(original_report, tmp_path / 'linked', outcome_path=carrier)
    outcome = linked.follow_up_results[0]
    assert outcome.comparison_scope['status'] == 'compatible'
    assert all(
        (tmp_path / 'linked/report.json').parent.joinpath(ref.path).resolve().is_file()
        for ref in (outcome.run, outcome.check, outcome.report, *outcome.observations)
        if ref is not None
    )


def test_changed_ir_is_rejected_for_replay_but_allowed_for_regression_link(tmp_path: Path) -> None:
    original_run = _manifest(tmp_path / 'old-run', 'run-old')
    changed_run = _manifest(tmp_path / 'changed-run', 'run-new', ir=b'changed ir')
    original_report = _report(tmp_path / 'original', original_run, 'report-old', 'run-old')
    current_report = _report(tmp_path / 'current', changed_run, 'report-new', 'run-new')
    check = _check(tmp_path / 'current', 'run-new')
    observation = tmp_path / 'current/observation.json'
    observation.write_text('{"actual": 0}\n')

    def outcome(relation: Literal['replay', 'regression'], carrier: Path) -> None:
        carrier.write_text(
            FollowUpResult(
                'result-' + relation,
                relation,
                outcome='inconclusive',
                run=_ref(changed_run, carrier, 'run-new'),
                check=_ref(check, carrier, 'check-1'),
                report=_ref(current_report, carrier, 'report-new'),
                submitted_by='independent-test',
                observations=(_ref(observation, carrier),),
            ).to_json()
        )

    replay = tmp_path / 'replay.json'
    outcome('replay', replay)
    with pytest.raises(TraceError) as error:
        link_report(original_report, tmp_path / 'replay-out', outcome_path=replay)
    assert error.value.code == StopCode.IDENTITY_MISMATCH
    regression = tmp_path / 'regression.json'
    outcome('regression', regression)
    linked = link_report(original_report, tmp_path / 'regression-out', outcome_path=regression)
    assert linked.follow_up_results[0].comparison_scope == {'status': 'unknown'}
