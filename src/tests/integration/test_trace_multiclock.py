"""Real K values remain visible at conservative design-wide clock boundaries."""

from __future__ import annotations

import json
import os
from pathlib import Path

import pytest

from kcirct._simulate import simulate
from kcirct.trace import TraceRun
from kcirct.trace.comparison import normalized_evidence
from kcirct.trace.model import Budget, Observation, QueryRequest, StopCode, Target
from kcirct.trace.session import InvestigationSession, SessionBudget

RESOURCE = Path(__file__).parents[1] / 'resources/trace/multiclock-v2'


def _run(root: Path, name: str, top: str, rows: list[dict[str, int]]) -> Path:
    definition = os.getenv('KCIRCT_TRACE_DEFINITION_DIR')
    parser = os.getenv('KCIRCT_TRACE_PARSER')
    if not definition or not parser:
        pytest.skip('Real K definition/parser must be explicit; skip is not acceptance.')
    root.mkdir()
    inputs = root / 'inputs.json'
    inputs.write_text(
        json.dumps(
            {
                'schema_version': 1,
                'timescale': '1ns',
                'events': [{'time': index, 'inputs': row} for index, row in enumerate(rows)],
            }
        )
    )
    result = simulate(
        RESOURCE / f'{name}.generic.mlir',
        top_module=top,
        inputs_file=inputs,
        work_dir=root / 'run',
        output=root / 'output.vcd',
        definition_dir=Path(definition),
        parser=Path(parser),
        keep_states=True,
    )
    (root / 'simulation-result.json').write_text(json.dumps(result, indent=2))
    assert result['status'] == 'pass'
    assert result['events_completed'] == len(rows)
    assert result['simulation_calls'] == 2 * len(rows)
    return root / 'run/trace-run.json'


def _independent_clocks(root: Path, name: str, top: str) -> Path:
    # Independent event oracle: A captures5 at event1, B captures9 at event2.
    rows = [
        {'ca': 0, 'cb': 0, 'da': 5, 'db': 9},
        {'ca': 1, 'cb': 0, 'da': 5, 'db': 9},
        {'ca': 0, 'cb': 1, 'da': 7, 'db': 9},
        {'ca': 0, 'cb': 0, 'da': 7, 'db': 11},
    ]
    return _run(root, name, top, rows)


@pytest.mark.parametrize(('name', 'expected'), [('only_a', 5), ('both', 14)])
def test_real_independent_clocks_are_explicit_frontier(tmp_path: Path, name: str, expected: int) -> None:
    """An unrelated second clock also lies outside the declared design-wide scope."""
    path = _independent_clocks(tmp_path / 'execution', 'two-clocks', 'TwoClockProbe')
    request = QueryRequest(
        Target('signal', name='TwoClockProbe/' + name),
        Observation('post_eval', event_index=3, evaluation=2),
        budget=Budget(max_seconds=300),
    )
    direct = TraceRun.open(path).query(request)
    (tmp_path / 'direct.json').write_text(direct.to_json())
    assert direct.status.query == 'partial'
    assert direct.nodes[0].value is not None and direct.nodes[0].value.unsigned == expected
    assert {item.reason.code for item in direct.frontier} == {StopCode.UNSUPPORTED_CLOCK}
    with InvestigationSession.create(
        TraceRun.open(path),
        request,
        tmp_path / 'session.json',
        actor='test',
        budget=SessionBudget(max_actions=120),
    ) as session:
        initial = session.report()
        assert initial.nodes[0].value is not None and initial.nodes[0].value.unsigned == expected
        incremental = session.expand(initial.nodes[0].id, actor='test', branch='all', budget=request.budget)
        (tmp_path / 'incremental.json').write_text(incremental.to_json())
        assert incremental.status.query == 'partial'
        assert {item.reason.code for item in incremental.frontier} == {StopCode.UNSUPPORTED_CLOCK}
        assert normalized_evidence(incremental) == normalized_evidence(direct)


def test_real_hierarchical_aliases_and_constant_are_one_active_clock(tmp_path: Path) -> None:
    """Two child clock names alias one top input; a constant clock adds no domain."""
    path = _run(
        tmp_path / 'execution',
        'hierarchy-one-clock',
        'SingleClockWrapper',
        [
            {'clk': 0, 'a': 5, 'b': 9},
            {'clk': 1, 'a': 5, 'b': 9},
            {'clk': 0, 'a': 7, 'b': 11},
        ],
    )
    request = QueryRequest(
        Target('signal', name='SingleClockWrapper/both'),
        Observation('post_eval', event_index=2, evaluation=2),
        budget=Budget(max_seconds=300),
    )
    direct = TraceRun.open(path).query(request)
    (tmp_path / 'direct.json').write_text(direct.to_json())
    assert direct.status.query == 'complete'
    assert direct.nodes[0].value is not None and direct.nodes[0].value.unsigned == 14
    assert not direct.frontier
    assert {node.facts['clock_id'] for node in direct.nodes if 'clock_id' in node.facts} == {
        'SingleClockWrapper/left/%clock',
        'SingleClockWrapper/right/%clock',
    }
    with InvestigationSession.create(
        TraceRun.open(path),
        request,
        tmp_path / 'session.json',
        actor='test',
        budget=SessionBudget(max_actions=120),
    ) as session:
        for _ in range(119):
            report = session.report()
            pending = [item.node_id for item in report.frontier if item.reason.code == StopCode.PENDING_EXPANSION]
            if not pending:
                break
            assert pending[0] is not None
            session.expand(pending[0], actor='test', branch='all', budget=request.budget)
        incremental = session.report()
        assert incremental.status.query == 'complete'
        assert normalized_evidence(incremental) == normalized_evidence(direct)
        (tmp_path / 'incremental.json').write_text(incremental.to_json())


def test_real_unrecognized_clock_origin_is_not_assumed_same_domain(tmp_path: Path) -> None:
    """An unrelated gated clock cannot silently collapse to a supported input clock."""
    path = _independent_clocks(tmp_path / 'execution', 'generated-clock', 'GeneratedClockProbe')
    report = TraceRun.open(path).query(
        QueryRequest(
            Target('signal', name='GeneratedClockProbe/only_a'),
            Observation('post_eval', event_index=3, evaluation=2),
            budget=Budget(max_seconds=300),
        )
    )
    (tmp_path / 'direct.json').write_text(report.to_json())
    assert report.nodes[0].value is not None and report.nodes[0].value.unsigned == 5
    assert report.status.query == 'partial'
    assert {item.reason.code for item in report.frontier} == {StopCode.UNSUPPORTED_CLOCK}
