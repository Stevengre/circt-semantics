# Rocket、Boom 与 Riscinator 测试数据

本文档按论文表格的字段、单位和三位有效数字整理三个设计的测试记录。Rocket
已于 2026-09-09 补充本机 ARC / Verilator 测量，2026-09-10 完成 K 长测及离线
波形比较。当前 Rocket 表使用1170条输入、585个硬件周期的长测数据。
Boom 与 Riscinator 沿用此前记录。
原始精度数据和统计口径列在表格之后。

## Rocket

| Metric | Value | Unit |
| --- | ---: | --- |
| Hardware Design Size (LOC) | $3.34 \times 10^4$ | Lines of Code |
| Hardware Design Size (Tokens) | $4.18 \times 10^5$ | Tokens |
| Kimulator Parsing Time | $3.11 \times 10^{-1}$ | s |
| Kore File Preprocessing Time (Kimulator) | $1.54$ | s |
| Hardware Structure Initialization Time (Kimulator) | $1.94$ | s |
| Average Simulation Time per Cycle (Kimulator) | $5.15 \times 10^1$ | s per hardware cycle |
| Average Simulation Time per Cycle (Verilator) | $1.66 \times 10^{-6}$ | s per hardware cycle |
| Average Simulation Time per Cycle (Arcilator) | $1.13 \times 10^{-5}$ | s per hardware cycle |

本次配置为 `small-v1.6` / `v1.6-two-edge`。原生仿真使用预制 MLIR 的副本，
仅去除当前 CIRCT 拒绝的三行空 `om.class` 元数据；首次 K 试跑使用原文件，
第二次按用户授权删除该空元数据，第三次又在 Rocket 的 Arcilator 命令加入
`--async-resets-as-sync`。第四次仅在首次 simulate 前的 VCD 采样允许跳过缺失
信号，后续继续严格读取；短测成功后，用户启动的1170条输入长测也成功完成，
表中准备及仿真耗时取长测记录。
ARC 和 Verilator 各 3 次完整 Dhrystone 运行，均为 412,458 个硬件周期，表中
取每周期耗时中位数；性能运行不写 JSON/VCD，构建保留 `TRACE=1`。原生驱动只累计
`model.eval()` 耗时。K 模板的 `cycles` 按 input event 计数，每条调用两次
simulate，不能直接与原生硬件周期混用。本次初始化区间每个硬件周期有2条输入，
因此表中K每硬件周期耗时为日志每输入耗时的2倍。K覆盖585个硬件周期，其中前100个
reset为1，后485个已解除reset但仍在初始化；与原生完整Dhrystone的工作负载不同，
不能据此报告全程序性能比。

输入与基准波形已保存。首次 K 试跑的解析、预处理、setup 调用返回后，
`_generate_top_state_json` 中的 `arcilator` 退出 1，完成 0 条输入 / 0 次 simulate。
用户授权删除空 OM 后再试，明确出现 `seq.firreg` 异步 reset 不支持错误，
第三次添加异步 reset 参数后，state JSON 生成通过，但在首次 `#0` VCD 读取
setup 状态时缺少内部信号，抛出 `KeyError` 后停止，仍为 0 次 simulate。
第四次按用户授权采用初始采样策略，成功完成 20 条输入、40 次 simulate 和
21 次 VCD 采样。其中初始 `#0` 是空样本，随后 20 次严格读取均成功；相关单元测试
8 项通过。默认 Rocket 未配置 reference VCD，比较被跳过，因此本次成功表示模板
回放完成，不能作为 K 与原生仿真的等价性结论。

按用户要求只用 reset 短测的总墙钟估算 12 小时运行量：
`737.8534178733826 / 20 = 36.89267089366913 s/input`。截取的运行前缀含
1,170 条输入，即 585 个硬件周期、2,340 次 simulate，估计总墙钟为
43,164.42494559288 s。前缀覆盖前 100 个 reset 硬件周期及随后 485 个初始化
周期，尚未到 Dhrystone 主循环；reset 后耗时可能变化，该估计不保证恰好 12 小时。
用户已手动执行该预算量并完成长测：累计simulate为30127.810923165976秒，
平均25.750265746295707秒/input，即51.500531492591414秒/硬件周期。启动到
仿真结束为41688秒（归档另计），未取得实际睡眠区间，不据差值推断睡眠时长。

离线VCD比较：#1–#1170的8234个共同内部信号一致；93个共同顶层端口仅reset
在#200有一处采样边界差异。#201–#1170的8327个共同信号全部一致；未忽略信号，
无共同信号缺值。单侧声明的内部信号和未执行的Dhrystone主循环不在通过范围内。
具体复制来源、命令及差异见[离线比较记录](inputs/rocket/20260910-vcd-compare/README.md)。
完整证据见 [`inputs/rocket/20260909/README.md`](inputs/rocket/20260909/README.md)。

## Riscinator

| Metric | Value | Unit |
| --- | ---: | --- |
| Hardware Design Size (LOC) | $8.26 \times 10^2$ | Lines of Code |
| Hardware Design Size (Tokens) | $1.33 \times 10^4$ | Tokens |
| Kimulator Parsing Time | $1.87 \times 10^{-2}$ | s |
| Kore File Preprocessing Time (Kimulator) | $2.67 \times 10^{-1}$ | s |
| Hardware Structure Initialization Time (Kimulator) | $2.74 \times 10^{-1}$ | s |
| Average Simulation Time per Cycle (Kimulator) | $5.41 \times 10^{-1}$ | s per cycle |
| Average Simulation Time per Cycle (Verilator) | $2.76 \times 10^{-7}$ | s per cycle |
| Average Simulation Time per Cycle (Arcilator) | $1.27 \times 10^{-7}$ | s per cycle |

## Boom

| Metric | Value | Unit |
| --- | ---: | --- |
| Hardware Design Size (LOC) | $8.90 \times 10^4$ | Lines of Code |
| Hardware Design Size (Tokens) | $1.21 \times 10^6$ | Tokens |
| Kimulator Parsing Time | $8.25 \times 10^{-1}$ | s |
| Kore File Preprocessing Time (Kimulator) | $5.28$ | s |
| Hardware Structure Initialization Time (Kimulator) | $7.98$ | s |
| Average Simulation Time per Cycle (Kimulator) | $1.28 \times 10^2$ | s per cycle |
| Average Simulation Time per Cycle (Verilator) | $8.65 \times 10^{-6}$ | s per cycle |
| Average Simulation Time per Cycle (Arcilator) | $2.23 \times 10^{-5}$ | s per cycle |

Boom 的原生仿真结果来自此前提供的记录：Verilator 为 `115,664 Hz / 8.646 μs`，
Arcilator 为 `44,897.8 Hz / 22.273 μs`。表中将每周期微秒数换算为秒，并按三位
有效数字分别写为 $8.65 \times 10^{-6}$ 和 $2.23 \times 10^{-5}$ s/cycle。

## 规模统计口径

在 `services/circt-semantics` 目录执行：

```bash
wc -l -w \
  src/tests/resources/kcirct-arc-test/mlir/boom/boom.generic.mlir \
  src/tests/resources/kcirct-arc-test/mlir/riscinator/riscinator.generic.mlir
```

原始输出为：

```text
   88978 1211604 src/tests/resources/kcirct-arc-test/mlir/boom/boom.generic.mlir
     826   13288 src/tests/resources/kcirct-arc-test/mlir/riscinator/riscinator.generic.mlir
```

这里的 LOC 是 `wc -l` 得到的物理行数；Tokens 沿用论文已有口径，是 `wc -w` 得到的
空白分隔 word 数，而不是语言模型 tokenizer 的 token 数。选择该命令的依据是：对
Rocket 原始 generic MLIR 执行 `wc -l -w` 会得到 `33129 / 414624`，与论文中的
$3.30 \times 10^4$ LOC 和 $4.14 \times 10^5$ Tokens 高度吻合。

## 耗时来源与口径

Rocket 旧论文记录（仅作历史资料，不用于本次表格）：Parsing `5.46 \times 10^{-1}` s、Kore Preprocessing
`3.10` s、Hardware Initialization `4.96` s、Kimulator `26.9` s/cycle、Verilator
`1.06 \times 10^{-5}` s/cycle、Arcilator `3.66 \times 10^{-5}` s/cycle。
本次预制文件删除空 OM 前的规模为 `33389 / 417793`，当前为 `33385 / 417778`，
按三位有效数字取整后的表格不变；与前文用于解释旧论文口径的 master 文件不同。

2026-09-09 本机记录：Parsing `0.33281945799535606` s、Preprocessing
`2.1663904170054593` s、Setup `1.7672523750006803` s；这些阶段耗时不代表
完整仿真通过。第二次删除空 OM 后，三项分别为 `0.29946620800183155`、
`1.4845690419970197`、`1.8904219579999335` s。第三次加入异步 reset 参数后为
`0.3260305000003427`、`1.2742508330047713`、`1.816880874997878` s。上述三次均在
首次 simulate 前失败，作为历史记录保留。第四次成功短测历史记录如下；当前表使用
随后长测数据（Parsing=0.3107840830052737、Preprocessing=1.5361707080010092、
Setup=1.943857083999319秒），见 `inputs/rocket/20260910-vcd-compare/result.json`：

```text
compile_runtime:0.4046015409985557
preprocess_runtime:1.437755708990153
setup_runtime:1.8412019160023192
cycles:20
input_evaluations:20
simulation_calls:40
vcd_samples:21
runtime_per_simulation_step:13.397744013575357
runtime_per_cicle:26.795488027150714
runtime_total:535.9097605430143
wall_seconds:737.8534178733826
```

纯 simulate 累计 `535.9097605430143` s，每输入 `26.795488027150714` s；
本次每硬件周期包含两条输入，故每硬件周期为 `53.59097605430143` s。
12 小时预算使用包含准备、仿真和采样开销的总墙钟，详细依据见
[`budget-12h.json`](inputs/rocket/20260909/budget-12h.json)。
Verilator 中位数 `602678 Hz / 1.6592608324843448 μs`，
Arcilator 中位数 `88299.9 Hz / 11.325041138211936 μs`。

Riscinator 数据来自 2026-09-05 已完成的 204 周期回归记录；每个周期包含两次
simulate 调用。原始记录为：

```text
compile_runtime:0.018741416999546345
preprocess_runtime:0.26671524999983376
setup_runtime:0.2739835000011226
cycles:204
simulation_calls:408
runtime_per_simulation_step:0.2704715993700833
runtime_per_cicle:0.5409431987401666
runtime_total:110.35241254299399
```

Riscinator 的 Verilator `275.63 ns/cycle` 与 Arcilator `127.39 ns/cycle` 来自此前
提供并写入复现文档的已有记录，表中分别换算为 $2.7563 \times 10^{-7}$ 和
$1.2739 \times 10^{-7}$ s/cycle 后取三位有效数字。

Boom 数据来自
`mlir/boom/.work/legacy/boom-1k.log`。文件名虽然包含 `1k`，但日志内容明确记录的是
100 周期、200 次 simulate 调用。原始记录为：

```text
compile_runtime:0.8249071249999815
preprocess_runtime:5.275730666999948
setup_runtime:7.976491792000047
cycles:100
simulation_calls:200
runtime_per_simulation_step:63.80254703462516
runtime_per_cicle:127.60509406925031
runtime_total:12760.509406925032
```

表中的 Kimulator Parsing、Kore Preprocessing 和 Hardware Initialization 分别对应
统一 runner 的 `compile_runtime`、`preprocess_runtime` 和 `setup_runtime`。
Boom 与 Riscinator 的 Kimulator 每周期时间对应日志保留的 `runtime_per_cicle`；
Rocket 表格按本次 reset 输入序列将该值乘 2，换算为每硬件周期时间。该指标只统计 simulate 调用，
不包含前三项准备耗时和 VCD 导出耗时。`compile_runtime` 实际测量
`TOP_LEVEL_PARSER` 子进程执行及结果写盘的总墙钟时间，是现有记录中与论文 Parsing
Time 最接近的字段，并非剥离 I/O 后的纯 parser CPU 时间。

Boom 的 100 周期记录只覆盖到 reset deassert 边界，可用于报告这次短样本的性能，
不能据此推断 reset 后稳态性能或功能比较通过。
