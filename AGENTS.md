# Repository Guidelines

## 项目定位与整体架构

`circt-semantics`（Python 包名为 `kcirct`）的目标，是为 CIRCT/MLIR 硬件中间表示提供一套基于 **K Framework** 的形式语义，并在此基础上暴露可编程、可测试的仿真与 assertion 验证接口。仓库可以分成两条主线来理解：

1. **K 语义定义**：位于 `src/kcirct/kdist/circt_semantics/`，这里保存 CIRCT 相关的 K 定义、方言语义和配置文件，是形式化语义本体。
2. **Python 侧工具链**：位于 `src/kcirct/`，负责调用 `kdist` / `kompile` / `krun` / `pyk` proof 能力，把语义定义包装成 CLI、API、Kimulator 仿真工作流和 `sv.assert` 验证工作流。

如果你是助手或新加入的开发者，建议按“入口层 → Python API → K 语义 → 测试资源”这个顺序阅读。

## 项目结构与模块组织

### 根目录

- `README.md`：项目背景、依赖、基础构建和测试说明。
- `Makefile`：开发入口，常用构建、检查、测试命令基本都在这里。
- `pyproject.toml`：Python 包配置、开发依赖、格式化/类型检查/测试配置。
- `scripts/`：独立工具脚本，目前可见 `diffvcd.py`、`drop.py` 等辅助脚本。
- `deps/`：外部依赖版本记录。
- `dist/`：构建产物目录。

### `src/kcirct/`

这是 Python 主包。

- `__main__.py`：CLI 入口，当前明确暴露了 `kcirct generate`、`kcirct verify`（别名 `validate`）等命令。命令分发遵循 `command -> exec_<command>` 约定。
- `api.py`：核心编排层。`KCIRCT` 类负责：
  - 定位 `kdist` 编译后的定义目录；
  - 调用 `kast` 生成 parser；
  - 调用 `kompile` / `krun` / 相关 K 工具；
  - 读写中间 Kore / parser / working data；
  - 暴露 `verify_assertions_fast`、`prove_assertions` 等 assertion 验证 API。
- `_prove.py`：`sv.assert` 验证与证明编排层。具体执行验证会走 compile / preprocess / setup / simulate pipeline 并扫描 assertion error；符号验证会构造 APR proof，通过 Haskell 后端和 `KCFGExplore` 推进证明。
- `kdist/plugin.py`：把仓库中的 K 语义注册为 `kdist` target，例如 `circt-semantics.llvm`、`circt-semantics.llvm-library`、`circt-semantics.haskell`。LLVM 后端主要服务 concrete execution，Haskell 后端主要服务 symbolic execution / proof。
- `kimulator/`：Python 侧仿真抽象层。
  - `context.py`：运行上下文、信号状态、时间推进与 trace 管理。
  - `model.py`：`KimulatorModel`，负责 compile / eval 等模型生命周期。
  - `generator.py`：从 generic MLIR 和 `state.json` 生成 Python model glue code。
  - `vcd.py`：VCD 输出与比较逻辑。
- `err_trace.py`：错误追踪和差异路径分析相关能力。
- `lib/`：较独立的库代码，例如 `diffvcd.py`。
- `workingdir/`、`tmp/`：运行期产生的工作目录与中间文件缓存位置。

### `src/kcirct/kdist/circt_semantics/`

这是语义核心区域。关键文件包括：

- `circt-core.k`、`main.k`：K 语义主入口。
- `mlir/`、`circt/`、`hardware/`：MLIR/CIRCT/硬件层公共定义与配置。
- `hardware/int-normalization.md`：`Int` 层局部归一化规则，例如 `xorInt`、`&Int`、`|Int`、加减零和 mask 化简。新增规则应保持“单向收缩”，不要在这里直接加入交换律或结合律，避免 rewrite loop。
- `dialects/comb/`、`dialects/hw/`、`dialects/seq/`、`dialects/sv/`：各方言的语法与语义规则。

这里的 `.md` 文件并不是普通说明文档，它们是语义定义的重要组成部分，修改时要把它们视作“源码”。

### `src/tests/`

- `unit/`：无需完整 kompile 的轻量测试。
- `integration/`：需要语义定义可用，覆盖 API、Kimulator、语义运行等主流程。
- `resources/`：测试输入与基准输出，非常关键。里面包含大量 `.mlir`、`.generic.mlir`、`.kore`、`state.json`、`test_data.json`、VCD 以及 expected 结果；`resources/verify/` 下放 assertion 验证样例。

尤其 `src/tests/resources/operation/` 下按 `comb/hw/seq/sv` 分类，基本就是仓库支持能力的“样例总表”。遇到某个 op 或方言不理解时，优先从这里反向定位。

## 构建、测试与开发命令

优先使用 `Makefile`，不要自己手拼命令。

- `make poetry-install`：安装 Python 依赖。
- `make circt-semantics`：通过 `poetry run kdist --verbose build` 构建 K 定义。
- `make build`：构建 Python 包。
- `make kcirct`：同时完成 Python 包与语义定义构建。
- `make test-unit`：运行单元测试。
- `make test-integration`：运行集成测试，通常要求先有 `circt-semantics`。
- `make test-all`：并行运行全部测试。
- `make profile`：运行 profiling 测试。
- `make check`：统一执行 flake8 / mypy / autoflake / isort / black 检查。
- `make format`：执行 autoflake、isort、black 自动格式化。
- `make check-dependencies`：检查 firtool、verilator、iverilog、K 等外部工具版本。

常用 CLI 示例：

```bash
poetry run kcirct verify \
  src/tests/resources/verify/assert_true/assert_true.generic.mlir \
  --top-module AssertTrue \
  --inputs 1:8 \
  --backend llvm
```

```bash
poetry run kcirct verify \
  src/tests/resources/verify/assert_true/assert_true.generic.mlir \
  --top-module AssertTrue \
  --symbolic \
  --symbolic-input-widths 8 \
  --max-depth 50 \
  --max-iterations 3
```

`verify` 的默认工作目录是输入文件旁的 `.kcirct/<stem>.<top-module>.assertions/`，可用 `--work-dir` 覆盖；符号证明目录默认是该工作目录下的 `proof/`，可用 `--proof-dir` 覆盖。

常见本地开发顺序：

```bash
make poetry-install
make circt-semantics
make test-unit
make test-integration
```

## 编码风格与命名约定

仓库的 Python 风格以 `pyproject.toml` 为准：

- `black` 行宽 `120`；
- `isort` 使用 `black` profile；
- `mypy` 开启 `disallow_untyped_defs = true`；
- `flake8`、`pep8-naming`、`pydocstyle`、`autoflake` 都已接入。

建议遵守以下约定：

- Python 使用 4 空格缩进。
- 模块/文件名使用小写加下划线，如 `err_trace.py`。
- 测试文件命名为 `test_*.py`。
- 新增方言或操作语义时，目录组织尽量对齐现有 `dialects/<dialect>/` 与 `src/tests/resources/operation/<dialect>/`。
- 新增 CLI 子命令时，在 `create_arg_parser()` 中注册子命令，并提供同名 `exec_<command>` 函数；需要兼容别名时在 `_normalize_command()` 中集中处理。
- 新增 assertion 验证能力时，优先把 orchestration 放在 `_prove.py`，再通过 `KCIRCT` 方法和 `kcirct verify` CLI 暴露，避免把证明细节塞进 `__main__.py`。
- 不要随意改动 `workingdir/`、`tmp/` 的运行期行为，除非你清楚其对 parser / 中间文件生命周期的影响。

## 测试指南

开发语义或仿真逻辑时，优先补 `src/tests/integration/` 和 `src/tests/resources/`。这个仓库大量测试是“输入 MLIR + 预期输出工件”的风格，因此新增能力通常要同步补：

- 对应输入样例；
- `test_data.json`；
- 必要的 expected Kore / VCD / pretty 输出。

如果只是改 Python 包装逻辑，可先跑：

```bash
make test-unit
```

如果修改 `kcirct verify`、`_prove.py` 或 assertion 相关 API，至少跑：

```bash
make test-unit
```

并重点关注 `src/tests/unit/test_verify.py`。涉及真实 K 后端、Haskell proof、`CirctSemantics.is_terminal` 或 K 规则时，还需要先构建语义定义再跑相关集成路径。

如果修改了 K 语义定义，尤其是验证相关规则，建议按下面顺序刷新 Python 包和 K compiled target：

```bash
make kcirct
make circt-semantics
poetry run kdist build
```

如果 `kompile` / `krun` 已由 Nix 安装但当前 shell 找不到，先临时补 PATH：

```bash
export PATH="$HOME/.nix-profile/bin:$PATH"
```

完成后再跑验证相关集成测试，例如：

```bash
poetry run pytest -q src/tests/integration/test_verify_symbolic.py
```

如果涉及语义、仿真、K 运行或 op 行为，至少跑：

```bash
make circt-semantics
make test-integration
```

## 提交约定

从近期历史看，commit message 以**简短功能描述/修复描述**为主，中英文均有，常见形式包括：

- `fix api`
- `fix firreg & firmem`
- `构建了assert的具体验证和符号执行验证`
- `format`
- `实现ErrorTrace以及对seq的时序和mask的修正`
- `SV Dialect重构完成，kompile通过，尚未进行validation`

因此更适合沿用“**直接说明改动内容**”的风格，而不是强制套用 Conventional Commits。若变更范围明确，建议在标题中点出方言、模块或问题名，例如 `fix seq firmem mask handling`、`完善 ErrorTrace 路径分析`。

## Agent 使用建议

- 先读 `README.md`、`Makefile`、`pyproject.toml`，再进入 `src/kcirct/`。
- 想理解功能覆盖范围时，优先查看 `src/tests/resources/operation/`。
- 想定位语义实现时，从测试资源反查到 `src/kcirct/kdist/circt_semantics/dialects/...`。
- 想补验证用代数化简时，优先区分层级：`Int` 表达式恒等式放在 `hardware/int-normalization.md`，`Bits` 宽度和 X/Z 相关行为放在 `hardware/bits.md`，方言 op 形状相关规则放在对应 `dialects/...`。
- 想定位 `kcirct verify` 行为时，按 `__main__.py -> api.py -> _prove.py -> kdist/circt_semantics/main.py` 阅读；具体执行关注 `verify_assertions_fast`，符号证明关注 `prove_assertions` 和 `assertion_apr_proof`。
- 调试 assertion 验证时，先查看工作目录中的 `pgm.kore`、`preprocessed.kore`、`setup.kore`、`simulated.<n>.kore` 或 `proof/` 数据，再判断是 pipeline、输入宽度、后端 target 还是 K 规则问题。
- 想定位运行问题时，先区分是：**外部依赖缺失**、**kdist/kompile 失败**、**Python 包装层问题**，还是**K 语义本身不符合预期**。
- 修改语义后，不要只看 Python 测试是否通过，还要关注生成的 Kore / VCD / expected 工件是否一致。
