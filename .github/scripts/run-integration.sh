#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$repo_root"
results_dir="$repo_root/.ci-results"
mkdir -p "$results_dir"

# Python 依赖由工作流预先安装；具体执行只需 LLVM target。
poetry run kdist --verbose build --jobs 1 circt-semantics.llvm

# 从当前安装读取路径，避免依赖宿主机或旧容器的绝对路径。
KCIRCT_TRACE_DEFINITION_DIR=$(poetry run kdist which circt-semantics.llvm)
KCIRCT_TRACE_PARSER=$(poetry run python -c 'from kcirct.api import TOP_LEVEL_PARSER; print(TOP_LEVEL_PARSER)')
poetry run python -c 'from kcirct.api import KCIRCT; KCIRCT().ensure_env()'
if [[ ! -d "$KCIRCT_TRACE_DEFINITION_DIR" || ! -x "$KCIRCT_TRACE_PARSER" ]]; then
    printf '%s\n' 'CI 构建未提供可用的 LLVM 定义和可执行 parser。' >&2
    exit 1
fi
export KCIRCT_TRACE_DEFINITION_DIR KCIRCT_TRACE_PARSER

# operation 比较依赖前一阶段生成的 VCD，三个阶段必须顺序执行。
poetry run pytest -q --maxfail=1 \
    --junitxml "$results_dir/parser.xml" \
    src/tests/integration/test_operation.py::test_make_env \
    src/tests/unit/test_verify.py::test_assertion_apr_proof_from_setup_state
poetry run pytest -q --maxfail=1 --durations=10 --numprocesses=2 --dist=worksteal \
    --junitxml "$results_dir/operations.xml" \
    src/tests/integration/test_operation.py::test_evaluate_operation
poetry run pytest -q --maxfail=1 --numprocesses=2 --dist=worksteal \
    --junitxml "$results_dir/operation-comparison.xml" \
    src/tests/integration/test_operation.py::test_diffvcd_operatrion

# 使用当前 checkout 中实际存在的 trace 测试；显式环境使真实 K 测试执行。
trace_tests=(src/tests/integration/test_trace_*.py)
poetry run pytest -q --maxfail=1 --durations=10 --numprocesses=2 --dist=worksteal \
    --junitxml "$results_dir/trace.xml" \
    src/tests/integration/test_error_trace.py "${trace_tests[@]}"
