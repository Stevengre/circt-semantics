
# 定义变量
FILE_MLIR ?= default.mlir
FILE_PATH := $(dir $(FILE_MLIR))
FILE_NAME := $(basename $(notdir $(FILE_MLIR)))
FILE := $(FILE_PATH)$(FILE_NAME)

# 定义伪目标
.PHONY: rebuild buildVcd buildExe cleanProcess clean cleanObj cleanAll cleanVcd build help cleanTestVcd

# 定义默认目标

force_rebuild:
	@rm -f $(FILE_PATH)V$(FILE_NAME)
	@rm -f $(FILE_PATH)trace_vtor.vcd

rebuild: force_rebuild buildVcd

buildExe: $(FILE_PATH)V$(FILE_NAME)

buildVcd: $(FILE_PATH)trace_vtor.vcd
 
$(FILE_PATH)trace_vtor.vcd: $(FILE_PATH)V$(FILE_NAME)
	./$(FILE_PATH)V$(FILE_NAME)

# 定义规则
$(FILE).generic.mlir: 
	circt-opt --mlir-print-op-generic $(FILE).mlir > $@

$(FILE).sv: $(FILE).generic.mlir
	firtool --lowering-options=disallowLocalVariables  $< -o $@

$(FILE_PATH)V$(FILE_NAME): $(FILE)__main.cpp $(FILE).sv
	@verilator -LDFLAGS "-ljsoncpp" --cc --sv --exe --build $(FILE_NAME)__main.cpp $(FILE).sv --trace --Mdir $(FILE_PATH)obj_dir
	@cp $(FILE_PATH)obj_dir/V$(FILE_NAME) $@
	@echo "Run $@"

cleanProcess:
	find . -type d -name 'obj_dir' -exec rm -rf {} +
	find . -type f -name 'pgm.kore' -exec rm -f {} +
	find . -type f -name 'preprocessed.kore' -exec rm -f {} +
	find . -type f -name 'preprocessed.kore.prestate' -exec rm -f {} +
	find . -type f -name 'preprocessed.pretty' -exec rm -f {} +
	find . -type f -name 'setup.kore' -exec rm -f {} +
	find . -type f -name 'setup.kore.prestate' -exec rm -f {} +
	find . -type f -name 'setup.pretty' -exec rm -f {} +
	find . -type f -name 'simulated.*.kore' -exec rm -f {} +
	find . -type f -name 'simulated.*.pretty' -exec rm -f {} +
	find . -type f -name 'simulated.*.kore.prestate' -exec rm -f {} +

cleanObj:
	find . -type d -name 'obj_dir' -exec rm -rf {} +

clean:
	find . -type d -name 'obj_dir' -exec rm -rf {} +
	find . -type f -name 'pgm.kore' -exec rm -f {} +
	find . -type f -name 'preprocessed.kore' -exec rm -f {} +
	find . -type f -name 'preprocessed.kore.prestate' -exec rm -f {} +
	find . -type f -name 'preprocessed.pretty' -exec rm -f {} +
	find . -type f -name 'setup.kore' -exec rm -f {} +
	find . -type f -name 'setup.kore.prestate' -exec rm -f {} +
	find . -type f -name 'setup.pretty' -exec rm -f {} +
	find . -type f -name 'simulated.*.kore' -exec rm -f {} +
	find . -type f -name 'simulated.*.pretty' -exec rm -f {} +
	find . -type f -name 'simulated.*.kore.prestate' -exec rm -f {} +
	find . -type f -name 'state.json' -exec rm -f {} +
	find . -type f -name 'V*' -exec rm -f {} +
	find . -type f -name 't.txt' -exec rm -f {} +
	find . -type f -name '*.sv' -exec rm -f {} +
	find . -type f -name '*.pretty' -exec rm -f {} +

cleanTestVcd:
	find . -type f -name 'test.vcd' -exec rm -f {} +

cleanVcd:
	find . -type f -name '*.vcd' -exec rm -f {} +

cleanAll: clean cleanVcd

buildAll:
	poetry run python test_operation_expected.py

# 帮助信息
help:
	@echo "Usage:"
	@echo "  make FILE_MLIR=<path_to_generic_mlir_file>"
	@echo "  make help"
	@echo "  edit obj_dir/V__main.cpp"
