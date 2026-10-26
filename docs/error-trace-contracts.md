# 组件契约与本次运行重绑定

状态：M2 最小实现和真实 K 微例已实施，A5 总体验收仍为 partial；尚未用独立上游应用完成同配置机制接入与硬编码 harness 消融。公共模块是 `kcirct.trace.contracts`，不修改旧 `TraceRun.query`。

模板记录可复用接口与检查约定；绑定记录具体运行、实例和字节身份。一个模板可用于 standalone、wrapper 中的不同实例，以及具有相同接口约定的正常/受控版本。每个绑定重新核验，每个 checker 重新执行；配置复用从来不携带旧的 pass。

## 格式与接口

| 模型 | 内容 |
| --- | --- |
| `ComponentContract` | 模板 ID/版本、语义端口、查询入口、合法整数参数、完整组件初态、checker SHA/接口版本/性质说明、可接受 profile、采样、源码要求 |
| `ContractPort` | 语义名、方向、固定或参数化位宽、data/clock/reset/status 角色、reset 有效电平 |
| `ContractHandshake` | 被检查的数据端口、明确的一位有效限定端口及有效电平；协议时序由独立 checker 检查 |
| `ContractTarget` | 模板查询名、signal/register/memory_cell、位宽、明确地址；可要求它对应一个语义端口 |
| `InitialState` | 某个架构状态查询入口在 setup 的明确预期位向量 |
| `ComponentBinding` | 模板哈希、run/manifest/IR/definition 身份、完整实例路径与模块名、端口/目标重命名、参数、checker/工具链/源码哈希及来源声明 |
| `BindingReport` | 实际解析出的 run 内 target_id、初态证据、核验范围及限制；checker_status 固定为 not_run |

模板和绑定均使用现有严格 `JsonModel` 格式，公开 JSON 要求 `schema_version=1`；未知字段、重复键、错误类型与版本不能悄悄接受。

`handshakes` 为可选的结构化限定规则，例如 `ContractHandshake("result_valid", ("result",), "ready", 1)`。未声明端口、多位限定信号和同一数据端口的冲突规则均拒绝。采样仍保留原值和限定信号，checker 只在约定成立时评价数据，并另行验证握手时序和非空触发；不能把未触发的算术检查写成通过。握手协议尚非自动证明，包含规则的绑定保持 partial。为了兼容早期无握手 v1 模板，规范哈希省略空 `handshakes`；非空规则完整进入哈希。

```python
from pathlib import Path
from kcirct.trace import TraceRun
from kcirct.trace.contracts import ComponentContract, ComponentBinding, bind_component
from kcirct.trace.model import Observation

template_path = Path("component-contract.json")
binding_path = Path("integration/left-binding.json")
template = ComponentContract.from_json(template_path.read_text())
binding = ComponentBinding.from_json(binding_path.read_text())
run = TraceRun.open(Path("run/trace-run.json"))
component = bind_component(run, template, binding, carrier=binding_path)

request = component.query_request("output", Observation("dump", event_index=3))
report = component.query("output", Observation("dump", event_index=3))
checker_input = component.samples((Observation("dump", event_index=3),))
```

`query_request` 构造显式目标请求；`query` 与 `samples` 会重新执行绑定核验。`samples` 输出当前实例真实端口观测、run/manifest/contract/binding/checker 哈希与完整 event/eval/dump 坐标，供独立 checker 使用。采样不执行性质判定；没有观察样本也不能据此得到 pass。

`query` 可接收本次独立 `CheckRecord` 和其 `check_carrier`；其 `source.identity` 必须明确记录本次 `checker_sha256` 和 `binding_sha256`，随后调用原查询的检查来源核验。查询与采样观测必须符合模板的 dump 相位。`binding.checker`、`sources` 和可选 `source_binding` 的路径都相对 `carrier` 解析。运行工件仍使用 `TraceRun` 的原始 manifest 与显式重定位机制。

`budget` 是每个绑定核验阶段/查询或采样阶段的上限，尚不是所有阶段相加后的总会话预算。绑定成本保存在 `BindingReport.evidence.cost`，原查询成本仍在 `TraceReport.cost`；完整接入成本需由外层测量，不应漏掉重复核验。

## 适用性与拒绝

端口名称只在明确实例中解释。绑定名称须为直接相对名，不能用 `../right/...` 访问邻居实例，也不会按末尾同名、SSA 序号或最后一次匹配来猜测。模板必须精确覆盖该实例的全部端口，方向和位宽均核验。查询解析后检查实际所属实例和目标种类；声明端口查询时还检查它是否确实绑定该语义端口。

初态使用当前 setup 保存值和已核验 profile 的明确缺项初始化规则。模板必须覆盖本组件及其子层次中的全部架构寄存器和每个 memory 地址；初始化不完整、值不符或不支持的形状拒绝。不会把两个 `unknown` 初始化字典相等认作证明。

参数先核验名称完整性、合法范围/集合，再验证实际接口及查询位宽。但当前不能从任意 lowered IR 证明内部参数化语义，所以含参数的绑定标为 partial。时钟/reset 的接口角色和形状明确核验；尚未自动证明任意内部时钟/复位表达式遵守角色声明，因此单时钟契约的绑定也保留 partial，有限轨迹 checker 结果另记。partial 允许在明确限制下继续查询，不升级为已经证明完整契约。

profile 必须在模板列出的精确源码/definition 对中，且真实定义原字节已由原语义绑定核验；历史仅有构建关联的 profile 不升级。IR、manifest、definition、采样、checker、工具链或源码字节冲突均拒绝。checker 文件在绑定后改变，下一次采样或查询也会拒绝。

`source_required` 要求明确源文件内容身份，记录这些文件与本次 run 的声明关联，不自动证明 RTL→IR 变换。`source_mapping_required` 进一步要求现有 `SourceBinding` 成功，并要求每个查询入口能得到 exact/declaration/fused 源位置；只有 IR 定位、缺源或失配映射不满足该要求。提供的错误映射不能继续用于定位。

`project/version/upstream_family` 是显式来源记录，工具不会凭配置标签认定两个 DUT 独立。不同组件可以通过相同配置机制使用不同模板，不能把这种机制复用写成同一契约无修改地适用于任意上游。

## 已运行原型与剩余工作

专用微例在 `src/tests/resources/trace/contracts-v2/`：standalone 加一组件、同模块双实例 wrapper，以及不依赖 K 或 trace 解释器的整数参考 checker。实验仓 `external-defects/evidence/revision-r1/20261026-m0-01/contracts-prototype/` 保存脚本、原始执行、checker 命令/输出、绑定、检查记录和查询。

`real-01` 实际执行四次新 K 运行：standalone、wrapper、受控加二变体、端口和内部名字改变的版本；另外重用已保存真实寄存器运行。两个 wrapper 实例分别得到 `[4,10,0]` 与 `[17,32,1]`，查询根和 target_id 均不同。正常、改名及寄存器参考检查通过；受控加二得到 `[5,11,1]`，独立 checker 正确失败并生成本次运行的三个 CheckRecord 和完整查询。

后续 replay 使用保存的真实状态重新绑定、重新执行 checker 和查询，不冒称重新执行硬件仿真。记录了 run、端口、实例、位宽/参数、checker、definition、工具链、IR、采样、profile、缺失源码映射及绑定后 checker 篡改的拒绝；合法参数化接口仍保留 partial。

这些都是同项目受控微例，新增应用案例计数为零。A5 完成仍需要多来源应用接入、真实契约/源映射边界、实际接入操作与配置修改量、硬编码 harness 对照及独立复核。绑定成功、checker 在少量输入上通过和完整 A5 验收是三个不同结论。
