"""CLI 四个动作与公共 Python 门面共享同一离线实现和退出码。"""

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

import pytest

from kcirct.trace import TraceRun
from kcirct.trace.model import (
    FollowUpResult,
    Observation,
    QueryRequest,
    RecordRef,
    StopCode,
    Target,
    TraceError,
    TraceReport,
)

from .test_trace_artifacts import _bundle
from .test_trace_checks import _csv, _map
from .test_trace_query import small_run


def _run(*arguments: object) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, '-m', 'kcirct', *(str(argument) for argument in arguments)],
        text=True,
        capture_output=True,
        check=False,
    )


def _sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _relative(path: Path, carrier: Path) -> str:
    return Path(os.path.relpath(path, carrier.parent)).as_posix()


def test_trace_help_lists_four_noninteractive_actions() -> None:
    result = _run('trace', '--help')
    assert result.returncode == 0
    assert '{query,targets,checks,link}' in result.stdout
    assert 'input(' not in result.stdout


def test_targets_cli_matches_public_python_facade(tmp_path: Path) -> None:
    manifest = small_run(tmp_path / 'run')
    output = tmp_path / 'targets.json'
    result = _run('trace', 'targets', '--run', manifest, '--output', output)
    assert result.returncode == 0, result.stderr
    document = json.loads(output.read_text())
    public = TraceRun.open(manifest)
    assert document['schema_version'] == 1
    assert document['kind'] == 'trace_targets'
    assert document['run_id'] == public.run_id
    assert document['targets'] == list(public.list_targets())


def test_query_partial_exit_code_and_report_match_python_facade(tmp_path: Path) -> None:
    manifest = small_run(tmp_path / 'run')
    request_path = tmp_path / 'request.json'
    request = QueryRequest(
        Target('signal', name='Demo/result'),
        Observation('post_eval', state_id='state1', evaluation=1),
    )
    request_path.write_text(request.to_json())
    result = _run(
        'trace',
        'query',
        '--run',
        manifest,
        '--request',
        request_path,
        '--output',
        tmp_path / 'cli-report',
    )
    assert result.returncode == 3, result.stderr
    cli_report = TraceReport.from_json((tmp_path / 'cli-report/report.json').read_text())
    python_report = TraceRun.open(manifest).query(request, output=tmp_path / 'python-report')
    assert cli_report.status == python_report.status
    assert cli_report.request == python_report.request
    assert cli_report.run_id == python_report.run_id
    assert cli_report.frontier[0].reason.code == StopCode.UNSUPPORTED_SEMANTICS


def test_checks_bundle_can_feed_query_without_private_api(tmp_path: Path) -> None:
    manifest, _, _ = _bundle(tmp_path / 'run')
    expected = _csv(tmp_path)
    observations = tmp_path / 'observations.json'
    observations.write_text(_map().to_json())
    bundle = tmp_path / 'checks.json'
    result = _run(
        'trace',
        'checks',
        '--run',
        manifest,
        '--format',
        'csv',
        '--expected',
        expected,
        '--observations',
        observations,
        '--output',
        bundle,
    )
    assert result.returncode == 0, result.stderr
    document = json.loads(bundle.read_text())
    assert document['kind'] == 'trace_checks' and len(document['checks']) == 1
    check_id = document['checks'][0]['id']
    request_path = tmp_path / 'request.json'
    request_path.write_text(
        QueryRequest(
            Target('signal', name='Demo/result'),
            Observation('post_eval', event_index=1, evaluation=1),
            check=RecordRef(_relative(bundle, request_path), check_id, _sha(bundle)),
        ).to_json()
    )
    query = _run(
        'trace',
        'query',
        '--run',
        manifest,
        '--request',
        request_path,
        '--output',
        tmp_path / 'checked-report',
    )
    assert query.returncode == 3, query.stderr
    report = TraceReport.from_json((tmp_path / 'checked-report/report.json').read_text())
    assert report.status.design_check == 'failed'
    assert report.check is not None and report.check.id == check_id


def test_link_cli_and_error_exit_codes(tmp_path: Path) -> None:
    manifest = small_run(tmp_path / 'run')
    request = tmp_path / 'request.json'
    request.write_text(
        QueryRequest(
            Target('signal', name='Demo/result'),
            Observation('post_eval', state_id='state1', evaluation=1),
        ).to_json()
    )
    report_dir = tmp_path / 'report'
    assert _run('trace', 'query', '--run', manifest, '--request', request, '--output', report_dir).returncode == 3
    outcome = tmp_path / 'outcome.json'
    outcome.write_text(FollowUpResult('todo', 'follow_up').to_json())
    linked = _run(
        'trace',
        'link',
        '--report',
        report_dir / 'report.json',
        '--outcome',
        outcome,
        '--output',
        tmp_path / 'linked',
    )
    assert linked.returncode == 0, linked.stderr
    assert TraceReport.from_json((tmp_path / 'linked/report.json').read_text()).follow_up_results[0].id == 'todo'
    duplicate = _run('trace', 'targets', '--run', manifest, '--output', tmp_path / 'linked/report.json')
    assert duplicate.returncode == 2


def test_facade_refuses_manifest_changed_after_open(tmp_path: Path) -> None:
    manifest = small_run(tmp_path / 'run')
    trace = TraceRun.open(manifest)
    manifest.write_text(manifest.read_text() + '\n')
    with pytest.raises(TraceError) as error:
        trace.list_targets()
    assert error.value.code == StopCode.IDENTITY_MISMATCH
