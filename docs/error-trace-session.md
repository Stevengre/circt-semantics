# 持久化逐层调查会话

`kcirct.trace.session.InvestigationSession` 以 `QueryRequest` 为入口保存多个查询、展开选择和源码定位。它复用完整查询的 `_Query.start`、`_populate`、`_expand` 与历史前驱核验。创建查询只填充根节点；`expand` 每次只执行一个已发现节点的局部规则，不先计算完整图。

```python
from kcirct.trace import TraceRun
from kcirct.trace.model import Budget, Observation, QueryRequest, Target
from kcirct.trace.session import InvestigationSession, SessionBudget

request = QueryRequest(
    Target('register', name='Top/count'),
    Observation('post_eval', event_index=3, evaluation=1),
    budget=Budget(max_seconds=300),
)
with InvestigationSession.create(
    TraceRun.open('run/trace-run.json'), request, 'investigation.json',
    actor='analyst-1',
    budget=SessionBudget(max_seconds=3600, max_queries=60, max_actions=120),
) as session:
    root = session.report().nodes[0].id
    report = session.expand(root, actor='analyst-1', branch='control')
    session.select(root, actor='analyst-1')

with InvestigationSession.resume('investigation.json', actor='analyst-2') as session:
    report = session.revisit('q1', actor='analyst-2')
```

这些上限是示例；库不硬编码某一实验的预算。每个动作均接受 `budget=Budget(...)`。`SessionBudget` 约束累计主动执行时间、读取字节、动作数和查询数。追加请求 `session.query(request, actor=...)` 返回独立 `qN`；改变窗口也使用新请求，旧图可通过 `revisit(qN)` 返回。

## 展开与证据

`expand(node, branch='all'|'data'|'control'|'history', query_id=None, actor=...)` 只提交所选类的直接依赖。data 包括数据、别名、捕获、写口和未选静态候选；control 保留控制条件；history 保留真实前驱。一个节点的局部规则已核验后会缓存其直接依赖，后续选择其他分支不用再次执行该规则。未请求的分支、尚未解释的子节点以 `pending_expansion` frontier 表示；报告仍为 `partial`。静态候选不会被伪装成已执行依赖。

全部 pending 排空后，会话不向报告加入动作、显示或会话字段。控制条件、同值寄存器采样、同值内存写入、初始化、历史缺口、不支持项和环继续由原查询规则解释。足够预算且相同请求/窗口下，`comparison.normalized_evidence` 或 `evidence_sha256` 可检查逐层报告和完整查询的证据一致性。该摘要不包括运行时间、物理引用路径和展示顺序；它不是工件校验器。

`locate(node, source_binding=..., actor=...)` 返回位置精度、绑定哈希和限制说明，使用独立工件审计，不改变值图。缺失源码保留 `source_missing` 或相应降级；没有 execution IR 会产生明确失败。定位不推断唯一根因。`select` 保存节点选择而不展开；纯选择和重访也重新核验 manifest、索引及该查询已用状态。

通过 `request.check` 进入检查时，可提供 `check_carrier` 指明引用载体。会话复用 `load_check_reference` 的原始检查包重导入和 `normalize_check` 的真实观测核验。不会把日志中保存的 `actual`、图或报告直接导入为可信值。绑定 profile 在新查询和跨进程重放时重新核验；会话内沿用已绑定的规则解释器。

## 成本与失败

动作先写入 intent，包含 actor、完整请求、请求哈希、请求预算、实际生效预算和前一记录哈希；执行后写入 receipt，包含结果/停止码、证据摘要和成本。相邻记录组成 SHA-256 链。查询预算累计计入创建、展开、定位、选择、重访和失败动作；恢复重放另计入会话总预算。切换查询不能重置会话预算。

成本分列：

| 字段 | 计量范围 |
| --- | --- |
| `state_read_bytes` | Kore reader 实际解压读取，包含失败解码 |
| `verification_bytes` | 会话 manifest JSON 读取以及工件哈希核验扫描的实际字节，包含失败扫描 |
| `read_bytes` | 上述两项之和，用于动作、查询、会话的读取上限 |
| `states_read` | 实际提交的状态解码次数，缓存命中不增加 |
| `elapsed_seconds` | 单调时钟测得的主动动作时间，包含意图落盘和执行，不包含用户思考及最终回执落盘 |

此处读取指标不是操作系统总 I/O：既有索引/源码/检查解析器在已核验文本上的二次读取不重复计入，仍受单文件大小和截止时间限制。它也不同于旧 `TraceReport.cost.read_bytes` 仅统计 Kore 解压读取的口径；比较时应分别使用 `state_read_bytes`、`verification_bytes` 和外部端到端计时。超限探测最多可能多读取一个字节，并如实记入失败消耗。

预算、哈希或身份错误使当前动作失败并回滚其图/选择/审计提交；已经读取和花费的成本不会回滚。普通局部不支持项保留为 frontier，不阻止其他分支。查询当前成本来自动作日志，不包含空闲等待。没有 receipt 的中断 intent 按完整预留预算保守收费；不能通过杀进程获得免费重试。

## 恢复、搬迁与限制

日志采用同目录临时文件、`fsync` 和原子替换；同一会话只允许一个写者。`resume` 验证头部及完整日志链，从原始工件重建每个成功动作并逐项比较结果/证据摘要，失败动作保留在账本但不重放图修改。未完成 intent 不会被标作成功。重放中发现状态变更、缺失工件或不一致即记入失败回执并停止。

相对引用支持会话和工件一起搬迁；也可传 `relocations={旧绝对路径或目录: 新路径}`。源文件、检查原始记录和编译身份必须仍可核验。日志哈希链用于发现意外损坏和未经重新绑定的修改，不提供签名或外部信任锚；重新编造整个文件及其哈希不能视为原会话身份已被认证。

本模块提供 Python 调查过程及可审计日志。图形界面、用户效率收益、命名基线的成对诊断比较和跨运行组件替换不由这些功能测试证明。真实公共 K 工件试验保存在实验仓本轮 campaign 的 `session-prototype/`；合成单测仅证明 Python 编排与边界行为。

## CLI

`kcirct trace session` 提供 `create/query/expand/select/revisit/locate/replay` 七个动作。例如：

```sh
kcirct trace session create --run run/trace-run.json --request request.json --session investigation.json --actor agent:codex --output created.json
kcirct trace session expand --session investigation.json --node NODE_ID --branch control --actor human:analyst --output expanded.json
kcirct trace session revisit --session investigation.json --query-id q1 --actor agent:codex --output revisited.json
kcirct trace session replay --session investigation.json --actor tool:replay --output replayed.json
```

从前一次动作输出中的 `report.nodes` 和 `report.frontier` 获取真实节点身份；不按展示顺序猜测。`query` 接受新的 `--request`，`locate` 可提供 `--source-binding`。创建时 `--session-budget` 固定累计上限；其他动作的 `--budget` 分别约束本次恢复和动作，两者都受累计上限约束。显式重定位文件格式与 `trace query` 一致。

每次 CLI 进程都重新执行已提交动作，因此恢复成本真实计入日志；需要同进程多步操作时使用上面的 Python API。退出码0只表示请求的动作成功，完整性仍读取输出的 `report.status.query`；初始仅一层的图通常为 partial。缺失工件、预算、身份或日志错误使用通用 trace 诊断和非零退出码。每个动作输出都要求新路径，禁止覆盖已有报告；会话日志则由核心 API 原子追加。
