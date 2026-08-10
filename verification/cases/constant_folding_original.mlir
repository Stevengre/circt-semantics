#loc = loc("constant_folding_original.mlir":1:1)
#loc1 = loc("constant_folding_original.mlir":2:1)
#loc2 = loc("constant_folding_original.mlir":3:1)
#loc3 = loc("constant_folding_original.mlir":4:1)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0():
        %c5 = "hw.constant"() {value = 5 : i8} : () -> i8
        %c3 = "hw.constant"() {value = 3 : i8} : () -> i8  
        %sum = "comb.add"(%c5, %c3) : (i8, i8) -> i8
        "hw.output"(%sum) : (i8) -> ()
    }) {module_type = !hw.modty<output result : i8>, parameters = [], result_locs = [#loc], sym_name = "ConstantFoldingOriginal"} : () -> ()
}) : () -> ()