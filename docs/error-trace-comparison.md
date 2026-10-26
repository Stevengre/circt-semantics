# 双运行解释原型

阶段：2026-10-26 M2 最小实现，承接 M0 原型。模块为 `kcirct.trace.comparison`。本页描述已实现接口和实际验证；不表示 A2 全项验收或七例实验已完成。旧 `TraceRun.query` 接口保持原样。

## 调用入口

```python
from pathlib import Path
from kcirct.trace import TraceRun
from kcirct.trace.comparison import PairContract, PairRequest, compare_runs

left = TraceRun.open(Path("left/trace-run.json"))
right = TraceRun.open(Path("right/trace-run.json"))
contract = PairContract.from_json(Path("contract.json").read_text())
request = PairRequest.from_json(Path("pair-request.json").read_text())
destination = Path("results/pair.json")
report = compare_runs(left, request, right=right, contract=contract, carrier=destination)
destination.parent.mkdir(parents=True, exist_ok=True)
destination.write_text(report.to_json())
```

如果左右 `QueryRequest.check` 含文件引用，还须传入相应的 `left_request_carrier` / `right_request_carrier`，其值是原请求 JSON 路径。入口调用现有 `load_check_reference` 重新核验检查来源；直接传入 `left_check` / `right_check` 时沿用旧 API 的运行 manifest 相对路径约定。可选的 `left_source_binding` / `right_source_binding` 继续使用原源码绑定接口。

没有正常内部运行时，使用 `compare_runs(left, PairRequest(single_request))`。结果明确为 `mode=single_run`、`comparison_status=not_run`；单侧的 complete/partial/rejected 状态按原查询保留。仅有 expected 输出不会生成虚构的内部正常执行。

## 明确合同

所有文档使用现有严格 `JsonModel` 读取器：要求公开 JSON 的 `schema_version=1`，拒绝重复键、未知字段、不支持版本及类型不符。

| 模型 | 必需内容 |
| --- | --- |
| `PairSide` | `run_id`、manifest SHA-256、execution IR SHA-256、显式参数值字典 |
| `InputPair` | 逻辑 ID、左右完整输入端口名、data/clock/reset 角色；reset 有效电平 |
| `TargetPair` | 逻辑 ID 和两个完整 `Target`；基础映射覆盖整个位宽，不自动匹配 SSA |
| `PairContract` | 两侧身份、完整输入映射、全部架构存储初态映射、源码与 definition SHA、eval 数和采样时间单位 |
| `PairRequest` | 左右 `QueryRequest`、内部目标映射、每侧合同核验预算 |

`PairContract.initial_state_coverage` 必须为 `all_storage`。目前原型采取保守检查：setup 拓扑中的全部寄存器和每块 memory 的全部地址都必须有一对一初态映射，不能只登记失败目标。原始保存值优先；不存在的寄存器/存储初项只能使用已绑定语义的明确初始化规则，并记录其来源。还会核对 setup 时钟/复位输入、全部架构时钟的内部初始值或缺值 bootstrap 状态；内部时钟须通过 direct/to_clock 连接到声明的同一时钟输入。

两个运行只接受**相同、源码与编译定义原字节均已核验**的有限 profile。历史仅有 definition 构建关联的 profile 不升级为完整核验。每个输入端口必须映射，实际输入文件逐事件比较名称映射后的值、位宽和时间；参数声明、采样合同、查询窗口、目标类型/位宽、观测 phase/event/evaluation 有冲突则拒绝。

参数声明绑定 execution IR，但当前原型不从任意 IR 自动证明参数化值与声明相符；clock/reset 角色也不构成任意 RTL 复位语义证明。因此 `assumptions_verified=false`，范围完整的双侧结果也只标为 `comparability=conditional`。manifest 中两个 `initialization.status=unknown` 相等从来不作为初态证明。该限制是尚待补齐的验收问题，不是完整 A2 通过。

## 差异与证据

比较键为显式目标映射加 `phase/event/evaluation/view/bit_range`；memory 地址包含在映射端点中。同 timestamp 的多个 eval、prior/operand/committed 读取及同值 capture/write 不折叠。

报告包含两侧完整 `TraceReport`、对齐节点、共有边、数值差异、控制选择差异、capture/hold/write 和前驱关系差异、未匹配节点及原始 frontier。`static_candidate` 单列，不作为实际值来源。没有内部映射的节点保持 unmatched；有歧义或一对多映射必须拒绝，不能用 partial 掩盖冲突。

`comparison_status` 可为 `matched`、`different` 或 `partial`；存在未匹配项或任一侧未完成时为 partial，已发现差异仍保留。单侧证据冲突或内部错误拒绝比较。`first_observed_divergence` 只覆盖本次查询子图与窗口中最早的已观测差异，不能称为唯一根因、整个运行的首个分叉或正确修复证明。输出重新收敛也不保证窗口内所有内部节点等价；本接口不自动扫描未查询的时间点。

顶层运行引用及 `evidence_carriers` 相对调用者传入的 `carrier` 解析。嵌套报告保留原引用：状态/definition 工件相对对应运行 manifest，`request.check` 相对对应 request，检查来源相对 check 文件，源码工件相对 source-binding。每种载体都有显式路径和哈希。搬迁时须保留这些关系或使用旧接口的显式重定位，不能通过同名文件猜测。

`normalized_evidence(report)` 和 `evidence_sha256(report)` 供同一运行的调查会话重放使用。它们排除报告 UUID、耗时、请求预算、显示顺序及带身份引用的物理路径；保留值、边、完整坐标、frontier、完成状态、内容身份和语义 scope。摘要不能替代原工件核验，也不是不同运行的自动等价判定。

## 预算与目前证据

合同核验每侧使用 `PairRequest.validation_budget`，单侧查询分别使用原请求预算。当前不提供跨查询缓存或隐藏总体预算；合同、左右查询的实际消耗分别保留。没有实现 F3 收益，也不从本原型计时推断人的调试时间。

单测入口：

```sh
.venv/bin/pytest -q src/tests/unit/test_trace_comparison.py
```

单测复用原有明确标注的合成 KORE 夹具和 `unit_test_only` profile，覆盖同值不同选边、同值 capture/write、eval/view 分离、初态完整覆盖、参数/映射/输入冲突、工件篡改、单侧 fallback、来源载体和规范化摘要。公共双运行入口明确拒绝这些未绑定真实定义的合成运行，不修改白名单使其通过。

M0 真实状态验证脚本与日志在实验仓 `external-defects/evidence/revision-r1/20261026-m0-01/feature-prototype/`。`real-pairs-02` 实际执行了一个交换 MUX 数据输入的受控微设计；5 个事件中 3 个输出不同、2 个输出相同，5 个都显示实际数据来源不同。最终原型的 `real-pairs-04` 使用已验证的组合、寄存器和 memory 原工件检查相同运行对，并重放该受控运行；它没有重新执行硬件仿真。旧 memory 工件含未支持的 depth/width 扩展属性，其拒绝保留在早期日志中，不改写成成功。

M2 的 `run_a2_matrix.py` 进一步实际执行四个受控 K 运行：顶层/SSA 改名并反转独立表达式顺序、寄存器 MUX 交换、`comb.sub` 解释器不支持边界，以及真实 preset=8 的初态冲突。原始 K 运行均通过；`a2-matrix-01` 随后的实验断言误取 `Frontier.code` 而退出，保留日志。修正为 `Frontier.reason.code` 后，`a2-matrix-02` 仅重放保存工件，完成 16 项配对/单侧观察与 11 项拒绝，没有重新运行硬件仿真。

| 已运行边界 | 独立依据与结果 |
| --- | --- |
| 改名及表达式重排 | 完整显式映射得到 matched，未按 SSA 顺序匹配 |
| 寄存器历史差异 | 独立 Python 整数状态机核对 8 个事件；保持事件追到前一次 capture |
| 内部差异后输出收敛 | 同步 reset 后两侧输出均 0，仍保留 reset 前 old 状态的 update 差异 |
| 同值 capture/write | 事件表确认寄存器 9→9、memory 17→17 均为有效更新；图中 capture/write 边保留 |
| 同 timestamp 两次 eval | eval1 为 capture_next，eval2 为 no_edge_hold；分别对齐，不合并坐标 |
| 一侧缺史 | 保存真实 KORE 不改，派生保留缺口视图；完整侧 complete、缺史侧 partial/history_gap |
| 一侧解释不支持 | 真正执行 `comb.sub`，输出由整数减法核对；解释侧明确 partial/unsupported_operation |
| 冲突及无参考 | 实际输入/初态、参数、采样、profile、位宽、映射覆盖、一对多/别名歧义和 eval 冲突全部拒绝；无参考保持 single_run/not_run |

这些是功能微测试，不计入七个应用案例、不算新增真实缺陷、独立 holdout 或性能实验。调用者参数/control 假设仍不自动证明，A2 总状态为 partial。仍需独立复核、真实应用边界、同信息消融与完整成本测量。
