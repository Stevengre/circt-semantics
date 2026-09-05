# Rocket、Boom 与 Riscinator 测试数据

本文档按论文表格的字段、单位和三位有效数字整理三个设计的现有测试记录。没有重新
执行仿真。Rocket 数据来自论文已有记录，尚未在当前本机复跑；Boom 与 Riscinator
采用本机现有记录。原始精度数据和统计口径列在表格之后。

## Rocket

| Metric | Value | Unit |
| --- | ---: | --- |
| Hardware Design Size (LOC) | $3.30 \times 10^4$ | Lines of Code |
| Hardware Design Size (Tokens) | $4.14 \times 10^5$ | Tokens |
| Kimulator Parsing Time | $5.46 \times 10^{-1}$ | s |
| Kore File Preprocessing Time (Kimulator) | $3.10$ | s |
| Hardware Structure Initialization Time (Kimulator) | $4.96$ | s |
| Average Simulation Time per Cycle (Kimulator) | $26.9$ | s per cycle |
| Average Simulation Time per Cycle (Verilator) | $1.06 \times 10^{-5}$ | s per cycle |
| Average Simulation Time per Cycle (Arcilator) | $3.66 \times 10^{-5}$ | s per cycle |

以上 Rocket 数值按论文中的已有结果原样录入。当前输入子仓库尚未包含 Rocket 测试输入，
因此这些耗时未经过本机统一 runner 复跑验证，不应与下方本机记录视为严格同环境测量。

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

Rocket 表格来自论文已有记录：Parsing `5.46 \times 10^{-1}` s、Kore Preprocessing
`3.10` s、Hardware Initialization `4.96` s、Kimulator `26.9` s/cycle、Verilator
`1.06 \times 10^{-5}` s/cycle、Arcilator `3.66 \times 10^{-5}` s/cycle。由于本地
尚缺 Rocket 输入文件，本次只保存这些数据及其来源状态，没有重新测量。

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
Kimulator 每周期时间对应日志保留的 `runtime_per_cicle`：只统计 simulate 调用，
不包含前三项准备耗时和 VCD 导出耗时。`compile_runtime` 实际测量
`TOP_LEVEL_PARSER` 子进程执行及结果写盘的总墙钟时间，是现有记录中与论文 Parsing
Time 最接近的字段，并非剥离 I/O 后的纯 parser CPU 时间。

Boom 的 100 周期记录只覆盖到 reset deassert 边界，可用于报告这次短样本的性能，
不能据此推断 reset 后稳态性能或功能比较通过。
