# 已核验的额外编译身份

2026-10-26 本轮使用 K 7.1.323、语义源码摘要
`2a82d12ea2e894e400629d3c6c7b3210fc4b68717f21a3dcf672f0a8b52a8db3`。
本机 LLVM definition 原字节摘要为
`bbe16518aa6f44ad80eb002f9efd10ddaf1c3d86f717af208b85b33e66a6a1e8`。

原登记 `08ac54e3…` 继续有效，不替换历史身份，也不宣称两份定义逐字等价。
当前 definition 含绝对构建路径；未恢复旧 definition 原字节，不能将差异只归于路径。
额外编译登记是精确的 `(source SHA256, definition SHA256)` 对，不接受任意同源码重编译。
源码各文件、编译定义、运行工件仍逐一核验；缺源码、错定义、声明冲突或篡改仍拒绝。

## 本次证据

实验仓 campaign 为 `external-defects/evidence/revision-r1/20261026-m0-01/`。

- `runs/real-k-smoke-01/`：真实仿真完成 5 个事件、10 次求值；原公开查询明确拒绝新身份。
- `runs/kdist-llvm-check-01/`：当前 K 7.1.323 对 `circt-semantics.llvm` 的构建缓存校验成功；不是本次强制重新编译。
- `runs/candidate-profile-01/`：独立组合公式与 MUX 控制/实际数据/未选静态边，以及寄存器固定事件表通过；内存测试最初因请求地址类型错误失败，记录保留。
- `runs/candidate-profile-memory-02/`：真实 K 接受但分析器拒绝附加 `depth/width` 属性的形状，明确 `unsupported_initialization`；未扩大属性范围。
- `runs/candidate-profile-memory-03/`：去掉测试设计中冗余属性、采用既有支持形状后，独立 memory scoreboard 与最近有效同址写时序通过，含同值写、disabled、他址写及边界地址。

候选核验阶段只在测试内使用显式 `SemanticsProfile`，所有原始源码/definition 哈希均检查；没有在生产入口开放用户指定任意 profile。登记后还必须从公开 `TraceRun` 重跑这些测试和原 smoke。公开重跑状态以 campaign 原始日志为准。

## 能支持的范围

本次微测试包含整数 `hw.constant`、`seq.to_clock`、add/and/or/xor/shl/shru/concat/extract、icmp(eq)、MUX、preset/同步 reset/保持/同值捕获、双 evaluation 前驱，以及 RL0/WL1 单整字写口 memory。
整数位宽、属性形状、其他 icmp 谓词、层次连接、读写歧义和全部拒绝路径仍须按 A1 覆盖矩阵逐项登记；这些测试不等于所有已实现构造或 A1 全部通过。
测试预期不调用解释器的计算函数，直接使用独立整数公式、固定寄存器事件表和写入 scoreboard。
