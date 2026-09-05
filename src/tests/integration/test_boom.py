from __future__ import annotations

import os
import sys

import pytest

from tests.integration.arc_test import BOOM_CASE, main, missing_case_files, run_case


def test_boom_1k_cycles() -> None:
    if os.environ.get('KCIRCT_RUN_ARC_TESTS') != '1':
        pytest.skip('Boom 长周期测试需设置 KCIRCT_RUN_ARC_TESTS=1，或使用 python -m 直接运行。')
    missing = missing_case_files(BOOM_CASE)
    if missing:
        pytest.skip(f'缺少 Boom 输入子仓库资源：{missing}')
    run_case(
        BOOM_CASE,
        cycles=int(os.environ.get('KCIRCT_BOOM_CYCLES', '1000')),
        compare_after=int(os.environ.get('KCIRCT_BOOM_VCD_AFTER', '201')),
    )


if __name__ == '__main__':
    raise SystemExit(main(sys.argv[1:], project='boom'))
