# 动态 Error-trace 使用指南

`kcirct trace` 对 `kcirct simulate` 保存的真实运行工件做离线、只读查询。它解释某个
观测值在本次执行中的数据、控制和状态来源，不负责替测试平台定义正确行为。

开始追踪前必须先固定检查依据，例如 CSV/参考模型、性质/断言或 scoreboard。
完整 golden RTL 是可选输入，但正确性依据不可省略；没有检查时仍可解释实际值，
报告的 `design_check` 会保持 `not_run`。同样，查询成功不表示 DUT 检查通过，
精确源码位置也不证明该位置是唯一根因。

## 运行环境

先核对实际组件、K 工具、definition 和 parser 身份：

```bash
export LC_ALL=C
export LANG=C
export K_BIN=/path/to/k/bin
kcirct simulate --describe
```

K 7.1.323 的版本文本包含构建日期，locale 会改变月份/星期文本并使严格身份检查
失败。因此复现实验时必须同时设置 `LC_ALL=C LANG=C`，不能把 locale 差异当作定义
不一致，也不能通过重新构建来掩盖差异。

所有 `--output` 和 `--work-dir` 必须指向尚不存在的路径。下面命令采用已经执行过的
D13 定向流程参数形态；调用者应为新运行换一个输出目录。

```bash
KIMULATOR=services/circt-semantics/.venv/bin/kcirct
DEFINITION=services/kcirct-exp/.build/external-defects/kdist/circt-semantics/llvm
PARSER=services/kcirct-exp/.build/external-defects/parser

"$KIMULATOR" simulate \
  services/kcirct-exp/external-defects/designs/axis-frame-len-d13/mlir/d13/buggy/design.generic.mlir \
  --top-module axis_frame_len \
  --inputs services/kcirct-exp/external-defects/designs/axis-frame-len-d13/testbench/targeted.events.json \
  --output services/kcirct-exp/external-defects/.runs/manual-d13/buggy.vcd \
  --work-dir services/kcirct-exp/external-defects/.runs/manual-d13/work \
  --evaluations-per-input 2 \
  --definition-dir "$DEFINITION" \
  --parser "$PARSER" \
  --timeout 120 \
  --keep-states
```

`--keep-states` 为每次 evaluation 保存独立 gzip 状态并生成
`trace-run.json`/`trace-states.jsonl`。关闭该开关时普通 VCD 行为不变，但历史查询只
能使用实际保留的 setup/末态；工具会返回 `not_retained` 或 `history_gap`，不会把
滚动 `simulated.0/1.kore` 冒充历史归档。

## 完整 CLI 流程

以下四个动作都通过公开、非交互 CLI 执行，并与公共 Python 门面共用实现。

### 1. 列出 targets

```bash
kcirct trace targets \
  --run RUN/trace-run.json \
  --output WORK/targets.json
```

输出包含运行绑定的 `signal`、`register`、`memory_cell` 和
`memory_write_port`。先按端口或层次名称查询；遇到别名歧义时从候选项选择
`target_id`，不需要预先手填根因 SSA。

### 2. 导入 checks

CSV/VCD 检查必须同时提供 `ObservationMap`，显式把 sample 或 VCD 时间映射到
`event/evaluation/phase`。D8 当前验收实际使用了以下公开入口：

```bash
kcirct trace checks \
  --run RUN/trace-run.json \
  --format csv \
  --expected external-defects/designs/axis-switch-d8/testbench/tb.csv \
  --observations WORK/observation-map.json \
  --output WORK/checks.json
```

生成的 `trace_checks` 包保存运行、预期文件和映射文件的 SHA-256。CSV/VCD 没有差异
时 `checks` 为空；这只说明指定比较没有发现差异。性质或 scoreboard 失败由测试侧
按同一 `CheckRecord` schema 提交，保留原谓词、前提和来源，不执行任意谓词文本，
也不强行补造精确 expected。纯观测查询则令请求中的 `check` 为 `null`。

### 3. 查询

实际 D13 历史请求可参考
[request.json](../../kcirct-exp/external-defects/evidence/trace/20260907-history-verify-03/d13/main-input/request.json)。
最小请求结构如下：

```json
{
  "schema_version": 1,
  "target": {
    "schema_version": 1,
    "kind": "signal",
    "name": "axis_frame_len/frame_len",
    "target_id": null,
    "address": null,
    "bit_range": null
  },
  "observation": {
    "schema_version": 1,
    "phase": "post_eval",
    "event_index": 10,
    "evaluation": 1,
    "time": null,
    "time_unit": null,
    "sample": null,
    "state_id": null,
    "dump_id": null
  },
  "check": null,
  "window": {"schema_version": 1, "first_event": 0, "last_event": 10},
  "budget": {
    "schema_version": 1,
    "max_nodes": 10000,
    "max_states": 1024,
    "max_seconds": 60,
    "max_state_bytes": 67108864,
    "max_read_bytes": 2147483648,
    "max_cache_bytes": 134217728,
    "max_ast_nodes": 2000000,
    "max_ast_depth": 4096
  }
}
```

执行查询：

```bash
kcirct trace query \
  --run RUN/trace-run.json \
  --request WORK/request.json \
  --source-binding WORK/source-binding.json \
  --output WORK/report
```

`report.json` 是事实主记录，`summary.md` 由同一模型生成。使用
`--copy-evidence` 时还会复制本报告实际读取的材料并生成
`relocations.json`；搬迁后用 `--relocations` 打开。旧 simulate v1 的
`result.json` 必须通过 `--normalization-output` 一次性规范化到新目录。

### 4. 关联假设和后续结果

```bash
kcirct trace link \
  --report WORK/report/report.json \
  --hypothesis WORK/hypothesis.json \
  --output WORK/hypothesis-linked

kcirct trace link \
  --report WORK/hypothesis-linked/report.json \
  --outcome WORK/outcome.json \
  --output WORK/final
```

`HypothesisRecord` 关联报告节点、已观察条件、设计要求和待验证条件；
`FollowUpResult` 关联新 run/check/report，并使用 `supports`、`refutes`、
`inconclusive` 或 `not_run`。关联只验证身份和证据一致性，不自动证明根因。

## 值视图与时序

每个节点的 `view` 表示值来自哪个时序视角：

| view | 含义 |
| --- | --- |
| `observed` | dump 或指定 post-eval 位置实际可见的端口/信号 |
| `operand` | 当前操作按绑定语义实际读取的值 |
| `committed` | 本次 evaluation 结束后寄存器或存储中的状态 |
| `prior` | 当前状态 `<history>` 中保存的旧状态 |

`event`、`evaluation`、`dump` 不能互换。当前实验每个 event 执行两次 evaluation，
第二次后才 dump；寄存器准备、提交和端口可见位置必须从状态关系恢复，不能套用
`event +/- 1`。

寄存器报告会区分 `no_edge_hold`、`capture_next`、`capture_reset`、bootstrap 和
初始化，并给出旧值、next、时钟、复位及真实前驱。存储查询先选择
`memory_write_port` 查看 edge/enable/address/data，再以
`memory_cell` 和十进制字符串 `address` 查询提交后的值及窗口内最近同地址有效写。
禁用写和其他地址写不会成为该单元的写来源。

## 状态轴、预算和退出码

报告分别记录：

- `execution`：仿真是否完成。
- `design_check`：外部检查是否通过；可与查询成功同时为 `failed`。
- `reference_comparison`：与参考执行是否匹配。
- `metadata_integrity`：本次读取范围内的内部证据是否可信。
- `query`：查询是 `complete`、`partial`、`rejected` 还是 `error`。

默认预算是 10,000 节点、1,024 个状态、60 秒、单状态 64 MiB、累计读取 2 GiB、
缓存 128 MiB、单状态 2,000,000 个 AST 节点和深度 4,096。达到窗口或预算时报告
保留 frontier 并返回 partial；扩大预算前应先确认范围确实必要。

| 退出码 | 含义 |
| ---: | --- |
| 0 | 请求在声明范围内完成；不代表 `design_check=passed` |
| 2 | 输入、schema 或参数错误 |
| 3 | 预算、缺材料、历史窗口或不支持形状导致 partial |
| 4 | 身份、哈希、终态或元数据完整性拒绝 |
| 5 | 工具内部错误 |

## Python 门面

CLI 与下列公共 API 共用同一实现：

```python
from pathlib import Path

from kcirct.trace import TraceRun
from kcirct.trace.model import QueryRequest

run = TraceRun.open(Path("RUN/trace-run.json"))
targets = run.list_targets()
request = QueryRequest.from_json(Path("WORK/request.json").read_text())
report = run.query(request, output=Path("WORK/report"))
```

`TraceRun` 固定规范化 manifest 路径、`run_id` 和 manifest SHA-256；每次操作使用独立
读取预算。路径重定位只在内容哈希一致时生效。

## 支持范围和 provenance

当前动态解释覆盖三例所需的整数 `hw`/`comb` 形状、`seq.to_clock`、
`seq.firreg`，以及单写口、整字写、`readLatency=0`、`writeLatency=1` 的独立
`seq.firmem` 读写口。多写口冲突、合并读写口、动态部分掩码、其他读延迟、无法确定
顺序的同次同址读写、多时钟、四态值和任意 HDL/testbench 集成不在已验证范围。

历史 D13/D8/D4 的语义源码已按逐文件哈希恢复，但原 compiled definition 字节缺失。
因此历史报告可以约束离线解释器与源码来源，不能声称原 compiled definition 已重新
核验。源码映射的 `exact`、`declaration`、`fused` 等精度只说明定位证据强度；
即使是 `exact` 也不构成唯一根因证明。

实验侧完整流程和 A1-A15 证据入口见
[ERROR_TRACE_WORKFLOW.md](../../kcirct-exp/external-defects/ERROR_TRACE_WORKFLOW.md)。
