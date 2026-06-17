#loc = loc("constant_folding_optimized.mlir":1:1)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0():
        %c8 = "hw.constant"() {value = 8 : i8} : () -> i8
        "hw.output"(%c8) : (i8) -> ()
    }) {module_type = !hw.modty<output result : i8>, parameters = [], result_locs = [#loc], sym_name = "ConstantFoldingOptimized"} : () -> ()
}) : () -> ()