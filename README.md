# K-CIRCT: Towards a formal framework for CIRCT

CIRCT is built on top of the LLVM compiler infrastructure and is designed to support the development of hardware compiler transformations and analysis tools.

This project aims to provide a formal framework for CIRCT, which will allow us to formally reason about CIRCT transformations and CIRCT-based hardware designs.

K-CIRCT consists of 2 parts:

- `src/kproj`: An extensible and composable semantics of CIRCT in K as a rigorous foundation for CIRCT.
- `src/kirct`: A user-friendly interface for the formal semantics, called `kirct`, which allows users to utilize the semantics for simulation. It's also easy to extend `kirct` in Python to support more features. And we will support symbolic execution and verification in the future.

## Installation

### Prerequisites

- K Framework should be installed and added to the `PATH` environment variable. See [here](https://github.com/runtimeverification/k#quick-start) for installation instructions.
- CIRCT should be installed and added to the `PATH` environment variable, making `circt-opt` and `arcilator` accessible in the shell. See [here](https://github.com/llvm/circt) for installation instructions.
- `poetry` Python build tool is recommended to build the `kirct` tool. Follow the instructions [here](https://python-poetry.org/docs/#installing-with-pipx) to install `poetry`.

For testing the project, you need to install `verilator` and `iverilog` in your system.

- `verilator`: See [here](https://www.veripool.org/verilator/install/) for installation instructions.
- `iverilog`: See [here](https://github.com/steveicarus/iverilog) for installation instructions.

The recommended version for these tools are included in the Makefile. You can use the following command to check the versions:

```bash
make check-dependencies
```

If something goes wrong, you can check the dependencies of the K framework [here](https://github.com/runtimeverification/k/blob/d0d2553f1254991600a830b108d98fe9febc1f5a/install-build-deps).


### Building

To obtain `kcirct` to use the formal semantics, execute:

```
make kcirct
```

### Accessing compiled K definitions

The definitions are built with `kdist`. To build the definitions, run:

```
make circt-semantics
```

To get an exact path to the definition, use:

```
poetry run kdist which llvm # for LLVM Backend
```

Note that LLVM backend is for concrete execution, while Haskell backend is for symbolic execution and verification.

For more information about `kdist`, please use `poetry run kdist --help`.

## Usage

After building the project, you can access the `kcirct` CLI via `poetry`:

```
poetry run kcirct --help
```

### 从 MLIR 和输入事件运行 Kimulator

`kcirct simulate` 是文件输入、文件输出的独立仿真命令。用户只需提供 Generic MLIR、
顶层模块名和 JSON 激励，无需编写 Python 驱动或导入 `KCIRCT` 的内部函数。
已安装的 `kcirct` 和匹配的 LLVM 语义定义负责解析、初始化、逐事件仿真及 VCD 输出。
该命令本身不依赖 `arcilator`；从 RTL 生成 MLIR 的前端步骤由调用方独立完成。

例如，顶层 `Demo` 有 `clk: i1`、`a: i8` 两个输入时，`events.json` 可写为：

```json
{
  "schema_version": 1,
  "timescale": "1ns",
  "events": [
    {"time": 0, "inputs": {"clk": 0, "a": 7}},
    {"time": 5, "inputs": {"clk": 1, "a": 7}},
    {"time": 10, "inputs": {"clk": 0, "a": 19}},
    {"time": 15, "inputs": {"clk": 1, "a": 19}}
  ]
}
```

```bash
kcirct simulate design.generic.mlir \
  --top-module Demo \
  --inputs events.json \
  --output .runs/demo/kimulator.vcd \
  --work-dir .runs/demo/work \
  --evaluations-per-input 2 \
  --timeout 120 \
  --keep-states
```

每个事件必须给出全部输入，输入对象中的字段顺序不影响仿真：命令按顶层
`hw.module` 的 `module_type` 顺序排列输入。当前接受普通标识符命名的 `iN`
整数输入和输出；值必须是 `[0, 2^N)` 中的整数位模式，不接受 JSON 布尔值、隐式截断、
缺失字段或未知字段。时钟也作为显式输入给出；需要 `!seq.clock` 的内部逻辑可通过
`seq.to_clock` 转换 `i1` 输入。尚不接受顶层 `!seq.clock`、结构体、数组或 inout 端口。
`events` 不可为空，`time` 必须是非负且严格递增的整数，`timescale` 支持 `1ns`、
`10ps` 等 VCD 单位。

默认协议与 `integration/arc_test.py` 的双执行方式一致：固定本事件的全部输入，
从前次状态连续调用两次仿真，第二次保持同一时钟电平和同一组输入，然后才在事件的
`time` 写入一次 VCD。两次调用之间不推进时间，也不自动翻转时钟。
`--evaluations-per-input` 默认是 `2`，更改它会改变采样协议，实验报告需明确记录。
VCD 包含全部顶层输入和输出；必需端口缺少值会使仿真失败，不会被静默跳过。
对照仿真器应使用相同的事件和时间单位，随后使用 VCD 比较器检查波形。

默认从 `kdist` 获取 `circt-semantics.llvm` 定义，并在工作目录生成 TopLevel parser。
也可以通过 `--definition-dir DIR --parser PATH` 显式复用匹配版本的构建缓存。
K 工具从 `PATH` 查找，或通过 `K_BIN` 指定工具目录；源码、K 工具链、定义和 parser
必须使用匹配版本。`kcirct simulate --describe` 输出安装版本、Python 路径、API/仿真入口/
K 语义源码哈希及工具路径与版本，便于外部 runner 核实实际调用的组件。

`--work-dir` 必须是新目录，输出必须是尚不存在的 `.vcd` 文件。
命令会复制输入文件，保留 `result.json`、`commands.jsonl`、各命令的 stderr、
编译与初始化工件以及 `last-state.kore`。`result.json` 记录状态、失败阶段、完成事件数、
仿真调用次数、各阶段耗时、端口声明及输出哈希。`--timeout` 限制每一次外部命令，
超时会终止该命令的进程组；失败以非零退出码结束，同时保存 `error.txt` 和已经产生的
部分 VCD。部分 VCD 不能算作完成的仿真结果，应先检查 `result.json` 的 `status`。

使用 `--keep-states` 时，`states/` 保存每次求值后的真实 Kore gzip 文件，
`states.json` 记录其事件编号、求值次数、VCD 时间与解压后哈希。默认仅保留滚动状态及
最后成功状态，避免长时间仿真积累全部状态；命令日志中的 stdout 直接指向 Kore
工件，不另存一份大型 stdout。以上状态用于普通仿真的失败复查，并未执行 Error-trace 分析。

### Pretty-print KORE 状态

`kcirct pretty INPUT [-o OUTPUT]` 将 CIRCT semantics 生成的 KORE 状态转换为便于调试的 K pretty syntax。
未指定 `-o` 时，命令会在完整输入文件名后追加 `.pretty`，例如 `foo.kore` 输出为
`foo.kore.pretty`；指定 `-o` 可以覆盖输出路径。

```bash
poetry run kcirct pretty path/to/foo.kore
poetry run kcirct pretty path/to/foo.kore -o path/to/foo.pretty
```

该命令依赖与当前 `kcirct` 版本匹配的 compiled CIRCT semantics definition 和 K toolchain；使用前请先完成相应语义定义的构建。

Note that you need to run the following command to make `diffvcd.py` executable:

```
chmod u+x src/kcirct/lib/diffvcd.py
```

## Test

`scripts/diffvcd.py` 比较两份 VCD 共同声明的信号。可添加
`--ignore-missing-signals`，跳过任一侧仅声明、但整份波形中完全没有采样值的信号：

```bash
poetry run python scripts/diffvcd.py test.vcd trace_vtor.vcd --ignore-missing-signals
```

该开关默认关闭，operation 测试显式启用它。它不会跳过两侧均有采样值的信号，
也不会忽略真实的值差异；若所有信号都被跳过，比较仍会失败。
`--after` / `--before` 窗口内没有跳变的稳定信号仍参与比较。
使用 `--verbose` 可查看跳过的信号和缺少采样值的文件。
只在一份 VCD 中声明的信号沿用原有逻辑，不参与比较。

- src/tests/unit: Simple tests that do not require kompile
- src/tests/integration: Tests that require kompile. `make circt-semantics` is required.
- src/tests/profiling: Tests for profiling. `make circt-semantics` is required.

use this symbolic proof
```
poetry run kcirct verify \
  src/tests/resources/verify/assert_true/assert_true.generic.mlir \
  --top-module AssertTrue \
  --symbolic \
  --symbolic-input-widths 8 \
  --max-depth 50 \
  --max-iterations 3
```

use this concrete verify
```
poetry run kcirct verify \
  src/tests/resources/verify/assert_true/assert_true.generic.mlir \
  --top-module AssertTrue \
  --inputs 1:8 \
  --backend llvm
```

generator: generate generic mlir and adder.py (module of Adder)
model: MLIR module
context: all runtime context
vcd:
- class KimulatorVCD, manage vcd files, dump the result of simulation
- vcd.diff, comparing two vcd files.

## TODO

- [ ] scripts/mlir2kast.py: transform mlir to kast
- [ ] scripts/hardware-setup.py: setup hardware for continuous simulation
- [ ] scripts/hardware-run.py: run hardware
- [ ] scripts/hardware-sim.py: run simulation
- [ ] scripts/hardware-veri.py: run verification
- [ ] scripts/hardware-sym.py: run symbolic execution
- [ ] scripts/hardware-bench.py: run benchmark
- [ ] scripts/hardware-test.py: run test

K_OPTS+=-Xms64m -Xmx8192m -Xss32m

`pip3 install fire`
