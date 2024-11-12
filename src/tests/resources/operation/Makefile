
# 定义变量
FILE_MLIR ?= default.mlir
FILE_PATH := $(dir $(FILE_MLIR))
FILE_NAME := $(basename $(notdir $(FILE_MLIR)))
FILE := $(FILE_PATH)$(FILE_NAME)

# 定义默认目标
all: $(FILE_PATH)V$(FILE_NAME)

# 定义规则
$(FILE).generic.mlir: $(FILE).mlir
	circt-opt --mlir-print-op-generic $< > $@

$(FILE).sv: $(FILE).generic.mlir
	firtool --lowering-options=disallowLocalVariables  $< -o $@

$(FILE)__main.cpp: $(FILE).sv
	@verilator --cc --exe --build $< --trace --main --Mdir $(FILE_PATH)obj_dir
	@cp $(FILE_PATH)obj_dir/V$(FILE_NAME)__main.cpp $@
	@echo "Please edit $(FILE)__main.cpp and build again"

.PHONY: $(FILE_PATH)V$(FILE_NAME)
$(FILE_PATH)V$(FILE_NAME): $(FILE)__main.cpp $(FILE).sv
	@verilator -LDFLAGS "-ljsoncpp" --cc --exe --build $(FILE_NAME)__main.cpp $(FILE).sv --trace --Mdir $(FILE_PATH)obj_dir
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
	find . -type f -name '*.vcd' -exec rm -f {} +
	find . -type f -name 'state.json' -exec rm -f {} +
	find . -type f -name 'V*' -exec rm -f {} +

# 帮助信息
help:
	@echo "Usage:"
	@echo "  make FILE_MLIR=<path_to_generic_mlir_file>"
	@echo "  make help"
	@echo "  edit obj_dir/V__main.cpp"
