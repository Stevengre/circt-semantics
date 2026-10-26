"""在同输入真实 K 运行上核验公开 F1 的控制差异，避免仅用内部比较夹具自证。"""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path

import pytest

from kcirct._simulate import simulate
from kcirct.trace import TraceRun
from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.comparison import InputPair, PairContract, PairRequest, PairSide, TargetPair, compare_runs
from kcirct.trace.model import Observation, QueryRequest, Target
from kcirct.trace.semantics import bind_semantics

RESOURCE = Path(__file__).parents[1] / 'resources/trace/comparison-v2'


def test_real_equal_outputs_preserve_control_selection_difference(tmp_path: Path) -> None:
    """两侧刺激及初态相同，内部条件反相；相等数据不能掩盖选边差异。"""
    definition = os.getenv('KCIRCT_TRACE_DEFINITION_DIR')
    parser = os.getenv('KCIRCT_TRACE_PARSER')
    if not definition or not parser:
        pytest.skip('需要显式真实 K definition 与 parser；skip 不是验收通过')
    inputs = tmp_path / 'inputs.json'
    inputs.write_text(
        json.dumps(
            {
                'schema_version': 1,
                'timescale': '1ns',
                'events': [
                    {'time': 0, 'inputs': {'a': 7, 'b': 7, 'sel': 0}},
                    {'time': 1, 'inputs': {'a': 9, 'b': 9, 'sel': 1}},
                ],
            }
        )
    )
    paths = []
    sides = []
    for variant in ('identity', 'inverted'):
        directory = tmp_path / variant
        result = simulate(
            RESOURCE / f'{variant}.generic.mlir',
            top_module='ControlPair',
            inputs_file=inputs,
            work_dir=directory / 'run',
            output=directory / 'output.vcd',
            definition_dir=Path(definition),
            parser=Path(parser),
            keep_states=True,
        )
        (directory / 'simulation-result.json').write_text(json.dumps(result, indent=2, default=str))
        assert result['status'] == 'pass', result
        assert result['events_completed'] == 2
        assert result['simulation_calls'] == 4
        path = directory / 'run/trace-run.json'
        paths.append(path)
        with RunArtifacts.open(path) as run:
            profile = bind_semantics(run)
            sides.append(
                PairSide(
                    run.manifest.run_id,
                    hashlib.sha256(path.read_bytes()).hexdigest(),
                    next(item.sha256 for item in run.manifest.artifacts.values() if item.role == 'execution_ir'),
                    {},
                )
            )
    contract = PairContract(
        'same-input-internal-condition-change',
        sides[0],
        sides[1],
        tuple(InputPair(name, name, name) for name in ('a', 'b', 'sel')),
        (),
        'all_storage',
        profile.source_sha256,
        profile.definition_sha256,
        2,
        '1ns',
    )
    mappings = tuple(
        TargetPair(name, Target('signal', name=f'ControlPair/%{name}'), Target('signal', name=f'ControlPair/%{name}'))
        for name in ('a', 'b', 'sel', 'polarity', 'condition', 'selected')
    )
    (tmp_path / 'contract.json').write_text(contract.to_json())
    for event, expected in enumerate((7, 9)):
        query = QueryRequest(
            Target('signal', name='ControlPair/result'),
            Observation('post_eval', event_index=event, evaluation=2),
        )
        request = PairRequest(query, query, mappings)
        (tmp_path / f'request-{event}.json').write_text(request.to_json())
        report = compare_runs(TraceRun.open(paths[0]), request, right=TraceRun.open(paths[1]), contract=contract)
        (tmp_path / f'pair-{event}.json').write_text(report.to_json())
        assert report.comparison_status == 'different'
        assert not report.unmatched
        assert not report.left.frontier
        assert report.right is not None and not report.right.frontier
        for side in (report.left, report.right):
            root = next(node for node in side.nodes if node.id == side.scope['root_node'])
            assert root.value is not None and root.value.unsigned == expected
        assert any(item.kind == 'control_selection' and item.pair.mapping == 'selected' for item in report.differences)
        assert not any(item.kind == 'value' and item.pair.mapping == 'selected' for item in report.differences)
        for index, side in enumerate((report.left, report.right)):
            nodes = {node.id: node for node in side.nodes}
            selected = 'a' if bool(event) != bool(index) else 'b'
            data_sources = {
                nodes[edge.source].ref.result
                for edge in side.edges
                if edge.kind == 'data' and nodes[edge.target].ref.result == 'ControlPair/%selected'
            }
            assert data_sources == {f'ControlPair/%{selected}'}
