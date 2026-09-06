# Operation 测试流程

Operation 测试使用同一份 generic MLIR 和输入数据，分别运行 K 仿真器与
Verilator，再比较两端的 VCD。

每个案例放在 `<dialect>/<operation>/`，包含：

- `<operation>.mlir` 与 `<operation>.generic.mlir`：可读版本和两端共用的测试程序。
- `<operation>__main.cpp`：读取输入、驱动 Verilator 并输出参考波形。
- `test_data.json`：输入数据，每个输入值同时记录位宽。
- `trace_vtor.vcd`：Verilator 参考波形。

需要直接声明顶层 VCD 信号的案例可增加 `ports.json`，仅记录输入、输出的名称、
方向和位宽。测试会要求它完整匹配 generic MLIR 的顶层整数端口，并检查 K 状态
确实提供全部端口值；该文件只用于波形声明，不提供期望值，也不跳过必要信号。

新增案例时，可复用相近操作的 C++ 驱动，修改模型头文件、模型类型、端口赋值和
输入/VCD 路径。默认顶层模块名为 `Foo`，C++ 输入顺序应与 MLIR 端口顺序一致。

新增案例需登记三个位置：

- `random_config.json`：输入数量、位宽、生成模式和组数。
- `test_path.json`：数据生成目录。
- `__init__.py` 的 `DIALECT_OPERATIONS`：供 `integration/test_operation.py` 自动收集。

以下以 `comb/add` 为例，命令均从服务仓库根目录执行。运行前需安装项目依赖、
CIRCT 工具、Verilator 和 jsoncpp，并确保 K 定义及 parser 与当前源码、pyk 版本匹配。
修改 K 语义后先通过 `make circt-semantics` 重新构建。

1. 编写或修改 MLIR，并同步 `.mlir` 与 `.generic.mlir`。现有 Makefile 仅在
   `.generic.mlir` 不存在时从可读 MLIR 生成，修改 `.mlir` 不会自动更新已有 generic 文件。

2. 生成输入数据。脚本按配置生成缺失的 `test_data.json`，跳过已有文件；需要重新
   生成某个案例时，先移除该案例的数据文件。

   固定种子案例可配置 `seed`、`directed_inputs` 和各输入的 `max_values`，在定向
   输入后追加可复现的随机输入；时序案例可用 `clock_pattern` 指定第一个输入的
   时钟序列。随机输入仍须满足 operation 的有效索引等约束。

   ```bash
   poetry run python src/tests/resources/operation/make_test_data.py
   ```

3. 生成 Verilator 参考波形。Makefile 将 generic MLIR 经 firtool 导出为 SV，
   编译 C++ 驱动并执行，写入案例目录下的 `trace_vtor.vcd`。输入、MLIR 或驱动
   修改后，应重新执行此步骤。

   ```bash
   make -C src/tests/resources/operation rebuild FILE_MLIR=comb/add/add.mlir
   ```

4. 运行统一的 K 仿真与 VCD 比较，将筛选路径替换为目标案例。

   ```bash
   poetry run pytest -q src/tests/integration/test_operation.py -k 'comb/add/add.generic.mlir'
   ```

   每个案例包含 `test_evaluate_operation` 和 `test_diffvcd_operatrion` 两项测试：
   前者生成 `test.vcd`，后者调用 `scripts/diffvcd.py` 与参考波形比较。
   新增输出应在两端波形中均有声明和采样值，确保实际参与比较。

## 多类型 operation 的语义开发原则

新增类型支持时，先核对所用 CIRCT 版本的 operation 定义和 verifier，再确定 K 规则的
输入类型、输出类型、位宽关系及边界条件。官方文档给出的类型范围是合法性依据，
并不等于本仓库已经实现了其中全部类型；具体支持仍需对应语义规则和 operation 测试。

不同 operation 的类型约束不能一起放宽。例如，`comb.mux` 的数据分支允许非 token
类型，而 `comb.add`、`comb.icmp` 的操作数仍是整数位向量；为 mux 增加数组支持，
不能把其他规则中的 `IntegerType` 一律替换为 `Type`。条件位、数组索引、时钟和
复位信号也应保留各自约束。参考 [Comb operation 定义](https://circt.llvm.org/docs/Dialects/Comb/)
和 [Seq operation 定义](https://circt.llvm.org/docs/Dialects/Seq/)，实现时以对应工具版本的
ODS/verifier 为准。

对于可以按位打包的数据，应区分静态类型和运行值：MLIR 的 `Type` 保留数组长度、
元素类型等信息，运行时仍使用 `Bits`。`packedWidth` 负责从已支持的静态类型计算
位宽；它应覆盖规则允许的类型集合，不能通过忽略类型或默认返回某个位宽来接受
未实现类型。类型合法性、打包布局、位宽计算及值操作应分别检查，避免一个位模式
恰好相同就被当作同一种类型。

## 一维整数数组的实现与验证边界

数组扩展的基础范围限定为一维 `!hw.array<N x iW>`，其中 `N > 0`、`W > 0`：

```text
静态类型：!hw.array<N x iW>
packedWidth(iW) = W
packedWidth(!hw.array<N x iW>) = N * W
运行值：bits(V, N * W)
元素 i 对应位段：[i * W + W - 1 : i * W]
```

数组下标 `0` 对应最低位元素；`hw.array_create` 和 `hw.array_concat` 的操作数
按高位到低位排列，最后一个操作数位于低位。通过不同元素值和首尾索引检查这一布局，
不要只用全零或相同元素。该顺序依据 [CIRCT 打包布局说明](https://circt.llvm.org/docs/Dialects/Comb/RationaleComb/#bitcasts)。

`hw.array_inject` 是纯值操作：返回替换指定元素后的新数组值，保留其余元素，
不修改原数组，也不直接写寄存器或内存。数组值是否进入寄存器，仍由下游时序
operation 的时钟、复位和使能规则决定。索引位宽、元素类型及 slice 范围应按
[HW 数组 operation 定义](https://circt.llvm.org/docs/Dialects/HW/) 校验。

上述范围是开发和验收边界，不是对所有数组 operation 的完成声明。默认验证范围为
二态值和有效索引；长度为 1 时，CIRCT verifier 允许 `i0` 或 `i1` 索引，当前使用
可解析的 `i1` 索引 `0`。零长度数组、零位宽元素、`i0` 索引、
嵌套数组、结构体和 X/Z 索引都需要独立实现与测试，不能因运行值也使用 `Bits`
就默认为已支持。类型别名已有预处理机制，但需确认解析后的类型与对应测试案例一致。
越界行为需按具体 operation 的官方语义单独处理，不能把某个参考仿真器给出的确定值
直接当作通用正确答案。

现有 `seq.firreg` 的二态默认零初始化属于测试策略，不能据此宣称已覆盖 CIRCT 的
隐式随机初值。正位宽的 `iN` 整数寄存器支持显式整数 `preset`，只在首次无历史值时使用，
后续保持、上升沿更新和同步复位不重新应用初值；负字面量按寄存器位宽解释。
开发初值相关语义时，应同时观察无时钟沿时的初值、首次反馈读取、连续高电平保持、
多个上升沿和同步复位优先级，并包含非零初值及无 `preset` 的对照。
异步复位和复合类型的显式初值仍需独立实现与验证。
当前数组寄存器含 `preset` 或 `isAsync` 属性时，会在 setup 阶段保留
`#unsupportedArrayFirreg` 标记，明确停止执行，避免套用普通同步寄存器规则。

## 输入覆盖与采样约定

多类型案例沿用上面的标准流程，不另建临时的仿真入口。测试应同时包含定向边界和
随机输入；随机范围必须满足 MLIR 的合法性约束。例如，非二次幂长度数组的索引
不能仅按索引位宽随机生成后就当作有效访问。

- 数组读取与替换覆盖首元素、尾元素、不同位置和不同元素值；替换后同时观察新数组
  和原数组，确认只改变目标元素。
- concat、slice 覆盖元素顺序、完整打包宽度及合法范围的两端；目前通过 `hw.array_get`
  将内部数组变成顶层整数输出，供现有 JSON/C++ 驱动和 VCD 工具比较。
  `hw.bitcast` 尚无 K 规则，未来支持后也需独立验证；现行流程不依赖它。
- 数组作为 mux 分支或寄存器数据时，分别覆盖分支选择、复位、保持、更新与边沿，
  并确认最终 MLIR 保留待测 operation，避免前端折叠掉待验证逻辑。

涉及时钟和寄存器时，采样协议应明确为：固定完整输入，从前次状态以同一组输入
连续执行两次，然后在该事件的时间 dump 一次 VCD。两次执行之间不翻转时钟、
不修改输入、不增加采样时刻；一次低电平执行加一次高电平执行不等价于这一约定。
Verilator 使用相同激励和时刻，在完成该事件求值后 dump。

新增采用双执行协议的时序 operation 案例，除登记 `DIALECT_OPERATIONS` 外，还需在
`__init__.py` 的 `OPERATION_EVALUATIONS_PER_INPUT_2` 中登记，让
`integration/test_operation.py` 对每个输入事件连续执行两次后采样。
`integration/arc_test.py` 使用 `simulation_calls_per_input=2` 表达同一约定。
旧的 `OPERATION_ONLY_CHECK_DOWN_EDGE` / `replay_posedge` 配置只在偶数 VCD 时间
额外执行一次；不能把这个旧配置当作每事件双执行。调整协议后，应同步驱动与激励，
再重新生成输入、Verilator 参考 VCD 和 K VCD。

VCD 比较要覆盖所有待验证输出在约定事件上的采样值。信号名称或声明形式的差异
可以明确配对处理；缺少必需输出、没有采样值或真实值不同，不能通过扩大跳过范围
来视为通过。具体命令、结果与失败证据放在测试运行工件或 MR 报告中，本 README
只保留通用开发与验证流程。

修改操作数读取或调度规则时，还应核对 setup 建立的 `connection` 在连续求值中
保持不变，并检查实际操作数的顺序与位宽。覆盖共享 SSA、不同位宽分支和多次求值；
单次输出恰好相同不足以证明连接信息没有被改写。对这类问题应保留完整失败前状态，
从同一状态重放验证修复，避免只用重新启动后的单步结果替代连续执行。

操作数读取应保留两阶段顺序：先依次完成全部依赖的求值，再依次读取值。寄存器
历史值、首次 preset 和内存 Map 仍通过原有读取规则处理，不能改成每求值一个
操作数就立即采样一个。连接表中的原参数列表按索引访问；需要使用头尾匹配的
求值或读取规则时，为当前元素建立临时单元素列表。验证应覆盖零个、一个及多个
操作数、重复 SSA、实例端口别名和寄存器反馈，并同时检查结果顺序与连接表不变性。
