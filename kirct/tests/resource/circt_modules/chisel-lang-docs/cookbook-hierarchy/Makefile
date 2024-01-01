MODULE = AddTwo

# 目标文件
FIR_FILE = ./source/$(MODULE).fir
MLIR_FILE = ./$(MODULE).mlir

# 默认目标
all: $(MLIR_FILE)

# 如何生成 MLIR 文件：依赖于 FIR 文件
$(MLIR_FILE): $(FIR_FILE)
	firtool --ir-hw $(FIR_FILE) -o $(MLIR_FILE)

# 如何生成 FIR 文件：依赖于 Scala 源文件
$(FIR_FILE): ./source/$(MODULE).scala
	scala-cli run $< > $@

# 清理生成的文件
clean:
	rm -rf ./source/.bsp ./source/.scala-build
	rm -f $(FIR_FILE) $(MLIR_FILE)
