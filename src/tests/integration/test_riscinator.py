from __future__ import annotations

import os
import sys

import pytest

from tests.integration.arc_test import RISCINATOR_CASE, main, missing_case_files, run_case


def test_riscinator() -> None:
    if os.environ.get('KCIRCT_RUN_ARC_TESTS') != '1':
        pytest.skip('Riscinator 对照测试需设置 KCIRCT_RUN_ARC_TESTS=1，或使用 python -m 直接运行。')
    missing = missing_case_files(RISCINATOR_CASE)
    if missing:
        pytest.skip(f'缺少 Riscinator 输入子仓库资源：{missing}')
    run_case(RISCINATOR_CASE)


if __name__ == '__main__':
    raise SystemExit(main(sys.argv[1:], project='riscinator'))
