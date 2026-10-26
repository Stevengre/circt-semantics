"""CLI 跨进程持久化动作与失败隔离，不把局部动作成功写成查询完成。"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

from kcirct.trace.model import Observation, QueryRequest, Target

from .test_trace_cli import _run
from .test_trace_query import small_run

if TYPE_CHECKING:
    from pathlib import Path


def test_session_cli_rejects_unknown_profile_and_preserves_failed_action(tmp_path: Path) -> None:
    """未知合成 profile 不获支持，失败动作保留，不产生成功输出。"""
    run = small_run(tmp_path / 'run')
    request = tmp_path / 'request.json'
    request.write_text(
        QueryRequest(
            Target('signal', name='Demo/result'), Observation('post_eval', state_id='state1', evaluation=1)
        ).to_json()
    )
    session = tmp_path / 'session.json'
    output = tmp_path / 'create.json'
    created = _run(
        'trace',
        'session',
        'create',
        '--run',
        run,
        '--request',
        request,
        '--session',
        session,
        '--actor',
        'agent:test',
        '--output',
        output,
    )
    assert created.returncode == 3, created.stderr
    assert 'unsupported_semantics' in created.stderr
    assert not output.exists()
    document = json.loads(session.read_text())
    assert any(item.get('status') == 'error' for item in document['journal'])
    replay_output = tmp_path / 'replay.json'
    replay_output.write_text('existing artifact\n')
    arguments = (
        'trace',
        'session',
        'replay',
        '--session',
        session,
        '--actor',
        'tool:test',
        '--output',
        replay_output,
    )
    before = session.read_bytes()
    rejected = _run(*arguments)
    assert rejected.returncode == 2
    assert session.read_bytes() == before
    assert replay_output.read_text() == 'existing artifact\n'


def test_session_cli_requires_explicit_actor_and_operation_arguments(tmp_path: Path) -> None:
    """未声明操作者或缺少节点的命令在读取、创建会话前失败。"""
    session = tmp_path / 'absent.json'
    result = _run('trace', 'session', 'expand', '--session', session, '--output', tmp_path / 'out.json')
    assert result.returncode == 2
    assert not session.exists()
