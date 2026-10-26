# 有身份核验的跨查询解析缓存

本轮 D13 的三次诊断 profiling 每次都解析 23 个状态，合计 69 次中有 46 次重复。每次完整查询约 2.2 秒，其中解析/投影/结构检查约 1.5 秒，原始读取、解压与哈希约 0.01 秒。因此首个优化只复用解析后的扁平状态，保留原始读取和全部查询规则。没有实现持久 last-write 索引；现有证据尚未显示历史搜索是首要瓶颈，不应同时改两个因素后归因。

```python
from kcirct.trace import TraceRun
from kcirct.trace.parse_cache import ParsedStateCache

cache = ParsedStateCache(max_bytes=128 * 1024 * 1024)
with cache.activate():
    first = TraceRun.open('run/trace-run.json').query(request)
    second = TraceRun.open('run/trace-run.json').query(request)
print(cache.statistics())
cache.clear()
```

缓存默认关闭。`activate()` 只影响当前执行上下文中新建的 reader，退出后恢复原配置；该对象可由同一进程中的后续查询继续使用。首版不支持磁盘持久化或跨进程 warm 启动；会话 CLI 每个新进程仍是冷启动。调用方应串行使用一个缓存对象，不把该接口当作多线程共享服务。

## 身份与读取路径

namespace 包括 manifest 的内容 SHA-256、manifest 登记的 profile/运行身份、解析器及相关分析器源码 SHA-256、Python 和 kframework 版本。条目还绑定压缩工件和解压内容的两个哈希。改变 manifest、profile 声明、分析器或原始状态会使条目失配，或由原有工件身份检查拒绝。真实 profile 的源文件/definition 仍由正常查询入口重新核验，不因缓存省略。

候选命中不等于有效命中。可终止 worker 仍打开原始状态、在当前预算内解压、对同一批字节核验两层哈希。成功后只跳过 `_decode` 的 Kore parse、投影和结构指纹计算，返回先前同字节生成的视图；每个查询仍执行 metadata、completion、真实历史连续性、保存值、控制选择和写入规则核验。未核验哈希的裸 `KoreReader.read()` 不启用缓存。

缓存只共享不可变 arena；`cells`、`fingerprints` 和完成信息中的可变字典分别复制。内容来自本进程可信解析 worker，不读取持久 pickle。既有 worker 的内部有界 IPC 沿用原协议安全边界，磁盘工件不会作为 pickle 反序列化。

## 预算与观测

warm 命中仍计一次原状态读取和全部实际解压字节，读取错误和超时仍收费。`max_state_bytes`、`max_read_bytes`、`max_states` 和 deadline 沿用原 reader 的检查；缓存中记录的 AST 节点数/深度还须满足当前请求的较低限制。相同证据不能因 warm 缓存绕过资源约束。

LRU 按已保存视图的保守 `view_bytes` 计量，受缓存对象的 `max_bytes` 与当前请求 `max_cache_bytes` 两者较小值限制。当前请求降低限额会淘汰此前较大预算留下的条目；单条过大则不保留。这里限制的是保留的解析视图，不是整个 Python 进程或解析 worker 的 RSS 总量；实验分别记录父/子进程累计峰值，不把二者相加冒充一次查询的独立内存峰值。

`statistics()` 返回累计 `hits`、`misses`、`parse_calls`、`reads`、`failed_reads`、实际解压 `read_bytes`、worker `load_seconds`/`decode_seconds`、淘汰数、超大条目旁路数以及保留/峰值字节。命中数只在原状态重新核验和预算检查成功后增加。命中、计时等成本指标独立保存，不注入 `TraceReport.scope`，因此不改变语义证据摘要。

## 当前测量与适用范围

实验仓本轮 campaign 的 `parse-cache-prototype/` 保存固定 D13 公共真实 K 工件、相同请求、关闭三次、冷填充一次、warm 三次的命令、源码身份、原始输出、报告和逐次成本。七次报告均保留 326 个节点及相同规范化证据；每次实际解压字节均为 4,271,574。关闭缓存每次解析 23 个状态；warm 每次解析 0 个、经原始字节重新核验命中 23 个。

本机关闭缓存平均约 2.190 秒，冷填充约 2.155 秒，warm 平均约 0.604 秒（约 3.62 倍）。顺序固定为 off/cold/warm，测量只覆盖这个请求和同进程复用；不能外推为全任务、跨进程或多来源案例的性能结论。后续 A9 应固定请求集合、报告冷成本、重复测量并保持语义证据相同。
