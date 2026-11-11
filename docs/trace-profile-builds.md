# 构建身份与 Trace 绑定

## 当前构建流程

Trace 的有限解释器仍只接受已审阅的语义源码集合。新构建不再要求把每台机器的
`definition.kore` 摘要逐个写入 Python 白名单，而由 `kdist` 在编译成功后生成
`kcirct-build.json`，记录：

- 实际构建依赖目录中的 `.k` / `.md` 源码文件集合及各文件 SHA-256；
- K 版本、后端、主文件、主模块、语法模块及传给编译器的其他配置；
- 编译产物的 SHA-256。当前 Trace 支持的 LLVM 配置要求
  `definition.kore`、`compiled.bin`、`backend.txt` 和 `interpreter` 四项。

构建前后会检查源码身份一致；构建失败或过程中源码改变时不能发布有效记录。
记录逻辑参与 kdist 缓存身份，使旧缓存重新构建。正常开发命令仍是：

```bash
poetry run kdist --verbose build --jobs 1 circt-semantics.llvm
```

仿真将构建记录保存为运行工件 `definition/kcirct-build.json`。离线绑定时必须核对
记录版本、受支持的 K 版本和编译配置、源码集合以及运行中的实际产物身份。
未知源码、缺记录的未知定义、过期记录、源码与产物不匹配或显式声明冲突仍拒绝。
只给 manifest 写入 `verified` 状态不能绕过这些检查。

原始 definition 摘要仍保留在运行和查询报告中，双运行合同仍要求匹配实际构建身份。
两份不同路径下的构建可以各自通过来源记录绑定，但不因此宣称它们逐字等价，
也不会自动合并为同一双运行身份。这里只移除了机器专属编译摘要作为新构建准入名单
的要求，没有扩大已审阅的源码或解释器支持范围。

这份记录是**受信任本地构建流程的来源记录**，不是签名证明。它检测记录之间及
记录与文件内容的不一致，不证明编译器没有缺陷，也不防止攻击者协同改写源码声明、
构建记录和全部运行工件。对来源不可信的第三方工件，需要另行建立签名发布或独立
可复现构建验证，不能把一个自称有效的 JSON 当作供应链认证。

CI 要求新构建提供记录，并将记录随测试报告归档。真实 profile 测试统一走公开
`TraceRun`；另有回归测试移除历史 definition 登记项，确认新记录能完成实际查询，
且 MUX 的值、控制边与所选数据边符合独立预期。完整测试结果以对应 CI 日志为准。

## 历史精确构建兼容：2026-10-26

没有新构建记录的旧运行仍只接受原来登记的精确源码/定义对；下面保留旧资格核验
的证据和限制，不把历史缓存校验改称为干净构建验证。

2026-10-26 本轮使用 K 7.1.323、语义源码摘要
`2a82d12ea2e894e400629d3c6c7b3210fc4b68717f21a3dcf672f0a8b52a8db3`。
本机 LLVM definition 原字节摘要为
`bbe16518aa6f44ad80eb002f9efd10ddaf1c3d86f717af208b85b33e66a6a1e8`。

原登记 `08ac54e3…` 继续有效，不替换历史身份，也不宣称两份定义逐字等价。
当前 definition 含绝对构建路径；未恢复旧 definition 原字节，不能将差异只归于路径。
当时的额外编译登记是精确的 `(source SHA256, definition SHA256)` 对，不接受任意同源码重编译。
源码各文件、编译定义、运行工件仍逐一核验；缺源码、错定义、声明冲突或篡改仍拒绝。

### 当时的证据

实验仓 campaign 为 `external-defects/evidence/revision-r1/20261026-m0-01/`。

- `runs/real-k-smoke-01/`：真实仿真完成 5 个事件、10 次求值；原公开查询明确拒绝新身份。
- `runs/kdist-llvm-check-01/`：当前 K 7.1.323 对 `circt-semantics.llvm` 的构建缓存校验成功；不是本次强制重新编译。
- `runs/candidate-profile-01/`：独立组合公式与 MUX 控制/实际数据/未选静态边，以及寄存器固定事件表通过；内存测试最初因请求地址类型错误失败，记录保留。
- `runs/candidate-profile-memory-02/`：真实 K 接受但分析器拒绝附加 `depth/width` 属性的形状，明确 `unsupported_initialization`；未扩大属性范围。
- `runs/candidate-profile-memory-03/`：去掉测试设计中冗余属性、采用既有支持形状后，独立 memory scoreboard 与最近有效同址写时序通过，含同值写、disabled、他址写及边界地址。

当时的候选核验阶段只在测试内使用显式 `SemanticsProfile`，所有原始源码/definition 哈希均检查；没有在生产入口开放用户指定任意 profile。登记后还必须从公开 `TraceRun` 重跑这些测试和原 smoke。公开重跑状态以 campaign 原始日志为准。

### 当时核验的范围

本次微测试包含整数 `hw.constant`、`seq.to_clock`、add/and/or/xor/shl/shru/concat/extract、icmp(eq)、MUX、preset/同步 reset/保持/同值捕获、双 evaluation 前驱，以及 RL0/WL1 单整字写口 memory。
整数位宽、属性形状、其他 icmp 谓词、层次连接、读写歧义和全部拒绝路径仍须按 A1 覆盖矩阵逐项登记；这些测试不等于所有已实现构造或 A1 全部通过。
测试预期不调用解释器的计算函数，直接使用独立整数公式、固定寄存器事件表和写入 scoreboard。
