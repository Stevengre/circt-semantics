"""比较命令保留单侧降级、拒绝覆盖和明确的未比较状态。"""

from __future__ import annotations

from typing import TYPE_CHECKING

from kcirct.trace.comparison import PairReport, PairRequest
from kcirct.trace.model import Observation, QueryRequest, Target

from .test_trace_cli import _run
from .test_trace_query import small_run

if TYPE_CHECKING:
    from pathlib import Path


def test_compare_cli_single_fallback_and_no_overwrite(tmp_path: Path) -> None:
    """无正常参考不得编造差异；未支持profile保持partial，已有报告不覆盖。"""
    run = small_run(tmp_path / 'run')
    request = tmp_path / 'pair-request.json'
    request.write_text(
        PairRequest(
            QueryRequest(
                Target('signal', name='Demo/result'), Observation('post_eval', state_id='state1', evaluation=1)
            )
        ).to_json()
    )
    output = tmp_path / 'pair.json'
    arguments = ('trace', 'compare', '--run', run, '--request', request, '--output', output)
    process = _run(*arguments)
    assert process.returncode == 3, process.stderr
    report = PairReport.from_json(output.read_text())
    assert report.mode == 'single_run' and report.comparison_status == 'not_run'
    assert report.left.status.query == 'partial'
    assert report.right is None and not report.differences
    before = output.read_bytes()
    again = _run(*arguments)
    assert again.returncode == 2
    assert output.read_bytes() == before


def test_compare_cli_rejects_missing_reference_contract(tmp_path: Path) -> None:
    """提供第二运行却没有对应请求与合同，必须输入错误而不是自动猜测映射。"""
    run = small_run(tmp_path / 'run')
    request = tmp_path / 'pair-request.json'
    request.write_text(
        PairRequest(
            QueryRequest(
                Target('signal', name='Demo/result'), Observation('post_eval', state_id='state1', evaluation=1)
            )
        ).to_json()
    )
    output = tmp_path / 'pair.json'
    process = _run('trace', 'compare', '--run', run, '--reference-run', run, '--request', request, '--output', output)
    assert process.returncode == 2, process.stderr
    assert not output.exists()
