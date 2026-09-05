# Operation 测试流程

Operation 测试使用同一份 generic MLIR 和输入数据，分别运行 K 仿真器与
Verilator，再比较两端的 VCD。

每个案例放在 `<dialect>/<operation>/`，包含：

- `<operation>.mlir` 与 `<operation>.generic.mlir`：可读版本和两端共用的测试程序。
- `<operation>__main.cpp`：读取输入、驱动 Verilator 并输出参考波形。
- `test_data.json`：输入数据，每个输入值同时记录位宽。
- `trace_vtor.vcd`：Verilator 参考波形。

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
