"""公开仿真保存的真实状态可以由 TraceRun 直接查询。"""

from __future__ import annotations

import json
import os
from pathlib import Path

import pytest

from kcirct._simulate import simulate
from kcirct.trace import TraceRun
from kcirct.trace.model import Observation, QueryRequest, Target

_RESOURCE = Path(__file__).parents[1] / 'resources/trace/simulation'


def _runtime() -> tuple[Path, Path]:
    definition = os.getenv('KCIRCT_TRACE_DEFINITION_DIR')
    parser = os.getenv('KCIRCT_TRACE_PARSER')
    if definition is None or parser is None:
        pytest.skip('真实 trace 仿真需要显式 KCIRCT_TRACE_DEFINITION_DIR 和 KCIRCT_TRACE_PARSER')
    return Path(definition), Path(parser)


def test_real_simulation_dump_traces_back_to_first_evaluation_commit(tmp_path: Path) -> None:
    definition, parser = _runtime()
    work = tmp_path / 'simulation'
    result = simulate(
        _RESOURCE / 'design.generic.mlir',
        top_module='TraceSimulation',
        inputs_file=_RESOURCE / 'inputs.json',
        output=tmp_path / 'trace.vcd',
        work_dir=work,
        definition_dir=definition,
        parser=parser,
        keep_states=True,
    )
    assert result['status'] == 'pass', result
    assert result['events_completed'] == 5
    assert result['simulation_calls'] == 10

    expected = json.loads((_RESOURCE / 'expected.json').read_text())
    report = TraceRun.open(work / 'trace-run.json').query(
        QueryRequest(
            Target('signal', name=expected['target']),
            Observation(
                expected['observation']['phase'],
                event_index=expected['observation']['event_index'],
            ),
        )
    )
    assert report.status.query == 'complete'
    root = report.nodes[0]
    assert root.observation is not None and root.observation.evaluation == expected['observation']['evaluation']
    assert root.value is not None
    assert (root.value.unsigned, root.value.width) == (expected['value']['value'], expected['value']['width'])
    commits = [
        node
        for node in report.nodes
        if node.ref.state_id == expected['commit']['state_id']
        and node.facts.get('decision') == expected['commit']['decision']
    ]
    assert commits
    assert commits[0].facts['old']['value'] == str(expected['commit']['old'])
    assert commits[0].facts['next']['value'] == str(expected['commit']['next'])

    entries = [json.loads(line) for line in (work / 'trace-states.jsonl').read_text().splitlines()]
    retained = [item for item in entries if item.get('phase') == 'post_eval']
    dumps = [item for item in entries if item.get('phase') == 'dump']
    assert [(item['event_index'], item['evaluation']) for item in retained] == [
        (event, evaluation) for event in range(5) for evaluation in (1, 2)
    ]
    assert [(item['event_index'], item['evaluation']) for item in dumps] == [(event, 2) for event in range(5)]
