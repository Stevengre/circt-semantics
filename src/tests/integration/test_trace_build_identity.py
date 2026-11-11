"""真实新构建通过来源记录绑定，不依赖开发机器的编译定义白名单。"""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path

import pytest

from kcirct.trace import TraceRun, semantics
from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.model import Observation, QueryRequest, Target
from kcirct.trace.semantics import bind_semantics

from .test_trace_real_profile import incoming, run_design


def test_real_build_record_binds_without_historical_definition_hash(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """排除所有历史定义身份后，真实构建记录仍支持公开查询及独立 MUX 选边断言。"""
    definition = os.getenv('KCIRCT_TRACE_DEFINITION_DIR')
    parser = os.getenv('KCIRCT_TRACE_PARSER')
    if not definition or not parser:
        pytest.skip('需要显式真实 K definition 与 parser；skip 不是验收通过')
    build_record = Path(definition) / 'kcirct-build.json'
    assert build_record.is_file(), '真实构建身份回归需要重新运行 kdist 生成构建记录'
    path = run_design(tmp_path, 'comb', 'ProfileComb', [{'a': 7, 'b': 3, 'sel': 1}])
    # 只移除历史构建的捷径；源码允许集合、构建记录及生产绑定逻辑保持原样。
    monkeypatch.setattr(
        semantics, '_PROFILES', {source: ('0' * 64, preset) for source, (_, preset) in semantics._PROFILES.items()}
    )
    monkeypatch.setattr(semantics, '_ADDITIONAL_BUILDS', {})
    with RunArtifacts.open(path) as run:
        record_path = run.verify_artifact('definition/kcirct-build.json')
        record = json.loads(record_path.read_text())
        assert record == json.loads(build_record.read_text())
        assert record['semantics_hashes'] == run.manifest.identities['semantics_hashes']
        for name, expected in record['artifacts'].items():
            artifact = run.verify_artifact('definition/' + name)
            assert hashlib.sha256(artifact.read_bytes()).hexdigest() == expected
        definition_sha256 = record['artifacts']['definition.kore']
        assert bind_semantics(run).definition_sha256 == definition_sha256
    report = TraceRun.open(path).query(
        QueryRequest(
            Target('signal', name='ProfileComb/selected'), Observation('post_eval', event_index=0, evaluation=2)
        )
    )
    assert report.status.query == 'complete', report.to_json()
    assert report.scope['definition_sha256'] == definition_sha256
    assert report.nodes[0].value is not None and report.nodes[0].value.unsigned == 7
    assert incoming(report, 'ProfileComb/%selected', 'control') == {'ProfileComb/%sel'}
    assert incoming(report, 'ProfileComb/%selected', 'data') == {'ProfileComb/%a'}
    assert incoming(report, 'ProfileComb/%selected', 'static_candidate') == {'ProfileComb/%b'}
