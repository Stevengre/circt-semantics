# CI 构建与测试

CI 配置位于 `workflows/Test PR.yml`，容器环境由
`actions/setup-kcirct-env/action.yml` 和 `workflows/Dockerfile` 提供。
向 `main` 或 `feat/**` 推送会自动触发验证；面向 `main` 的 PR 和手动触发也保留。
Python 使用 3.12，Poetry 使用 2.4.1，以读取当前 `poetry.lock` 的 2.1 格式。
K 版本读取 `deps/k_release`，并须与 `pyproject.toml` 中的 `kframework`
一致；当前均为 7.1.323。K 容器使用 Ubuntu Noble 发行版及其匹配的 LLVM，
CIRCT 使用 1.71.0。容器将 checkout 挂载到 `/workspace`，使用与 runner 匹配的
UID/GID 执行，生成的报告直接保存在 checkout 中。

代码质量检查由 `scripts/check-quality.sh` 执行，保留 flake8、mypy、autoflake、
isort 和 black 的失败状态。autoflake 增加 `--ignore-pass-after-docstring`，允许
预留方法的 docstring 后保留 `pass`；其余规则保持有效。格式检查仅枚举本仓库的
Python 文件（本地也包含未跟踪的新文件），避免检查已初始化的外部子模块。
不调用会直接改写源码的 `make pyupgrade`。

容器内执行：

```bash
make build
bash .github/scripts/run-integration.sh
```

集成脚本仅构建一次 `circt-semantics.llvm`，从当前安装查询定义目录和
`TOP_LEVEL_PARSER`，生成并检查 parser，再导出 `KCIRCT_TRACE_DEFINITION_DIR`
和 `KCIRCT_TRACE_PARSER`。测试不依赖开发者机器上的绝对路径。

脚本按以下顺序执行，任一阶段失败都会停止并保留其非零退出码：

1. `test_operation.py::test_make_env` 检查 parser 环境，同时运行
   `test_verify.py::test_assertion_apr_proof_from_setup_state`。该用例虽位于 unit
   目录，实际需要 K 和已构建的 LLVM 定义；普通 Python job 缺少 K 时会跳过它，
   容器阶段补齐其执行。
2. `test_evaluate_operation` 生成各 operation 的 VCD。
3. `test_diffvcd_operatrion` 与已归档的参考 VCD 比较。
4. `test_error_trace.py` 和当前 checkout 的 `test_trace_*.py` 检查旧查询兼容及真实 K trace。

各阶段的 JUnit 报告写入 `.ci-results/`。工作流另外执行代码质量检查和单元测试。
operation 的生成和比较分阶段执行；每个阶段可使用两个 pytest worker。
不直接执行整个 `src/tests/integration`：其中还包含依赖手工状态、未参数化的
演示辅助函数以及独立的大规模实验入口。

本流程覆盖 LLVM 具体执行。Haskell 符号证明及 LLVM library 不在本次集成范围内；
若启用符号测试，需要先构建对应 target 并检查其后端环境。ARC 的 Boom、Rocket、
Riscinator 长运行也未启用，不应将其未运行解读为通过。

以上测试使用仓库已跟踪的输入和参考 VCD，无需初始化 ARC 子模块，也不重新生成
Verilator/Icarus 参考结果。以后启用 ARC 时，需在 CI 中把 `.gitmodules` 的 SSH
地址（包括个人别名 `cym.github.com`）映射为 runner 可访问的 HTTPS 地址，初始化
所需子模块，并显式设置 `KCIRCT_RUN_ARC_TESTS=1`。重新生成参考结果时还须安装
匹配的仿真器和构建依赖，不能把现有的波形比较当作参考生成验证。
