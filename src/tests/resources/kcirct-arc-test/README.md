# K-CIRCT / Arcilator 对照测试资源

该目录集中保存 Riscinator、Boom 和 Rocket 的 K-CIRCT / Arcilator 对照测试资源。

论文格式的 Rocket、Boom 与 Riscinator 指标见
[`benchmark-results.md`](benchmark-results.md)。

```text
kcirct-arc-test/
├── inputs/                  # 独立 Git 子仓库
│   ├── boom/
│   ├── riscinator/
│   └── rocket/
└── mlir/                   # circt-semantics 主仓库管理
    ├── boom/
    ├── riscinator/
    └── rocket/
```

## 资源边界

- `inputs/` 保存输入 JSON 和作为比较基准的标准 VCD。它们通常较大，由本次测试
  专用的新子仓库独立管理。
- `mlir/<project>/` 保存原始 `*.generic.mlir` 和测试实际消费的 `*-drop.mlir`。
- `mlir/<project>/.work/<case>/` 保存 `pgm.kore`、`preprocessed.kore`、
  `setup.kore`、滚动仿真状态、state JSON、K-CIRCT VCD 和日志。`.work/` 已由
  主仓库忽略，不应提交。

期望的输入仓库结构如下：

```text
inputs/
├── boom/
│   ├── test_data.json
│   └── boom-arcs.vcd
├── riscinator/
│   ├── test_data.json
│   └── riscinator-itype.vcd
└── rocket/
    ├── input_1.4twoedge.json
    ├── input_twoedge.json
    ├── input_v1.6.json
    ├── input_v1.6start.json
    └── inputv1.6_2edge.json
```

可以通过 `KCIRCT_ARC_INPUT_ROOT` 临时指定另一份具有相同布局的输入目录。

## 运行入口

统一入口：

```bash
poetry run python -m tests.integration.arc_test riscinator
poetry run python -m tests.integration.arc_test boom --cycles 100 --no-compare
poetry run python -m tests.integration.arc_test boom --cycles 1000 --compare-after 201
poetry run python -m tests.integration.arc_test rocket --variant v1.6-two-edge
```

历史入口继续保留：

```bash
poetry run python -m tests.integration.test_riscinator
poetry run python -m tests.integration.test_boom
poetry run python -m tests.integration.test_rocket2
```

Rocket 的默认 variant 是 `v1.6-two-edge`。可选值通过以下命令查看：

```bash
poetry run python -m tests.integration.arc_test rocket --help
```

Rocket 各配置保留旧脚本的输入文件映射。`master`、`v1.4` 和
`v1.6-two-edge` 根据 `twoedge` 输入命名每条 input event 调用两次 simulate；
`v1.6` 和 `v1.6-main` 每条调用一次。2026-09-09 已接入默认 `v1.6-two-edge`
的事件输入，另存 BOOM 风格 `test_data.json`；其余 variant 输入仍未取得。
Rocket 的 `--cycles` 计 input event，不是硬件周期，详见输入仓库的计数记录。

存在标准 VCD 的项目会在仿真后自动执行 `scripts/diffvcd.py`。比较器会验证时间
窗口非空，并在 `--after` 边界比较该时刻已经稳定的值，避免空 transition 列表被
误判为通过。

## 当前验证状态

- Riscinator 已用 204 组输入完成回归；显式排除 9 个 K VCD 中无采样值的
  `regs_ext` memory-port observer，以及一个与其他已比较信号共用 Arcilator
  state offset 的 `writeback.io_ctrl_wb_en` 别名后，其余 140 个共同信号比较通过。
- Boom 的现有 100 周期本地 VCD 在 `#20` 到 `#199` 一致，但在 `#200` 的 6 个
  `io_aggregator_*_reset` 上表现为 K=`1`、标准 VCD=`0`。该点正好是标准 VCD 的
  reset deassert 边界，因此默认比较从 `#201` 开始；100 周期 smoke test 尚未覆盖
  reset 之后的有效比较窗口，不能作为功能通过结论。
- Rocket small-v1.6 原生 ARC / Verilator 各三次 Dhrystone 成功；K 长测完成
  1170 条输入、585 个硬件周期。2026-09-10 已离线比较：`#1–#1170` 的8234个
  共同内部信号一致，顶层仅 reset 在#200有采样边界差异；`#201–#1170` 的
  8327个共同信号全部一致。未覆盖单侧声明信号或Dhrystone主循环；原模板日志
  仍为skipped，本结论来自保存波形后的独立比较。
  见 [`inputs/rocket/20260910-vcd-compare/README.md`](inputs/rocket/20260910-vcd-compare/README.md)。

`inputs/` 是本次测试专用的新 submodule：
`git@github.com:nn020701/k-circt-arc-test-input.git`，与现有
`src/tests/resources/arc-test` 无关；不要复用或修改后者。输入文件通过 Git LFS
管理。首次检出前应先安装 Git LFS 客户端，然后在 `services/circt-semantics`
仓库根目录执行：

```bash
git lfs install
git submodule update --init src/tests/resources/kcirct-arc-test/inputs
git -C src/tests/resources/kcirct-arc-test/inputs lfs pull
```

仍可使用 `KCIRCT_ARC_INPUT_ROOT` 临时指向另一份具有相同项目布局的输入目录。
