"""调查会话命令；每次进程重放都计入累计成本，动作成功与图完成分别报告。"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING, Any

from . import TraceRun, load_relocations
from .model import Budget, QueryRequest, StopCode, TraceError
from .session import InvestigationSession, SessionBudget

if TYPE_CHECKING:
    from argparse import ArgumentParser


def add_session_args(parser: ArgumentParser) -> None:
    """每个动作只接受相关参数；发起者由调用者显式标注。"""
    actions = parser.add_subparsers(dest='session_action', required=True)
    for action in ('create', 'query', 'expand', 'select', 'revisit', 'locate', 'replay'):
        child = actions.add_parser(action)
        child.add_argument('--session', type=Path, required=True)
        child.add_argument('--actor', required=True, help='如 human:alice、agent:codex、tool:batch；不推断人工耗时')
        child.add_argument('--output', type=Path, required=True, help='必须尚不存在的动作结果 JSON')
        child.add_argument('--relocations', type=Path)
        if action == 'create':
            child.add_argument('--run', type=Path, required=True)
            child.add_argument('--session-budget', type=Path, help='SessionBudget JSON；固定累计预算')
        else:
            child.add_argument('--budget', type=Path, help='Budget JSON；恢复和动作各自上限，另受会话累计上限约束')
        if action in ('create', 'query'):
            child.add_argument('--request', type=Path, required=True)
        if action in ('expand', 'select', 'locate'):
            child.add_argument('--node', required=True)
            child.add_argument('--query-id')
        if action == 'revisit':
            child.add_argument('--query-id', required=True)
        if action == 'expand':
            child.add_argument('--branch', choices=('all', 'data', 'control', 'history'), default='all')
        if action == 'locate':
            child.add_argument('--source-binding', type=Path)


def execute_session(arguments: dict[str, Any]) -> dict[str, Any]:
    """执行一个持久化动作，先拒绝覆盖输出；缺失/篡改的会话由核心 API 拒绝。"""
    output = Path(arguments['output']).absolute()
    if output.exists():
        raise TraceError(StopCode.INVALID_INPUT, '拒绝覆盖已有会话动作结果', path=str(output))
    actor = arguments['actor']
    action = arguments['session_action']
    request_path = arguments.get('request')
    request = QueryRequest.from_json(Path(request_path).read_text()) if request_path is not None else None
    budget_path = arguments.get('budget')
    budget = Budget.from_json(Path(budget_path).read_text()) if budget_path is not None else Budget()
    relocations_path = arguments.get('relocations')
    relocations = load_relocations(relocations_path) if relocations_path is not None else {}
    if action == 'create':
        assert request is not None
        session_budget_path = arguments.get('session_budget')
        session_budget = (
            SessionBudget.from_json(Path(session_budget_path).read_text()) if session_budget_path is not None else None
        )
        opened = InvestigationSession.create(
            TraceRun.open(arguments['run'], relocations=relocations),
            request,
            arguments['session'],
            actor=actor,
            budget=session_budget,
            check_carrier=request_path,
        )
    else:
        opened = InvestigationSession.resume(arguments['session'], actor=actor, budget=budget, relocations=relocations)
    with opened as session:
        location = None
        if action == 'query':
            assert request is not None
            session.query(request, actor=actor, budget=budget, check_carrier=request_path)
        elif action in ('expand', 'select', 'locate'):
            options: dict[str, Any] = {'actor': actor, 'budget': budget, 'query_id': arguments.get('query_id')}
            if action == 'expand':
                session.expand(arguments['node'], branch=arguments['branch'], **options)
            elif action == 'select':
                session.select(arguments['node'], **options)
            else:
                location = session.locate(arguments['node'], source_binding=arguments.get('source_binding'), **options)
        elif action == 'revisit':
            session.revisit(arguments['query_id'], actor=actor, budget=budget)
        report = session.report()
        document = {
            'schema_version': 1,
            'kind': 'trace_session_action',
            'action': action,
            'action_status': 'pass',
            'actor': actor,
            'selected_query': session.selected,
            'cost': session.cost,
            'location': location,
            'report': report.to_dict(),
        }
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('x', encoding='utf-8') as stream:
        json.dump(document, stream, ensure_ascii=False, indent=2)
        stream.write('\n')
    return document
