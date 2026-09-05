from __future__ import annotations

import os
import sys

import pytest

from tests.integration.arc_test import ROCKET_CASES, get_case, main, missing_case_files, run_case

DEFAULT_ROCKET_VARIANT = 'v1.6-two-edge'


def test_rocket2() -> None:
    if os.environ.get('KCIRCT_RUN_ARC_TESTS') != '1':
        pytest.skip('Rocket 长周期测试需设置 KCIRCT_RUN_ARC_TESTS=1，或使用 python -m 直接运行。')
    variant = os.environ.get('KCIRCT_ROCKET_VARIANT', DEFAULT_ROCKET_VARIANT)
    case = get_case('rocket', variant)
    missing = missing_case_files(case, compare=False)
    if missing:
        pytest.skip(f'缺少 Rocket 输入子仓库资源：{missing}')
    run_case(case, compare=False)


if __name__ == '__main__':
    raise SystemExit(main(sys.argv[1:], project='rocket'))


__all__ = ['DEFAULT_ROCKET_VARIANT', 'ROCKET_CASES', 'test_rocket2']
