#loc = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder/adder.mlir":1:21)
#loc1 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder/adder.mlir":1:35)
#loc2 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder/adder.mlir":1:50)
#loc3 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder/adder.mlir":1:67)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    %1 = "comb.sub"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0, %1) : (i8, i8) -> ()
  }) {module_type = !hw.modty<input io_a : i8, input io_b : i8, output res_add : i8, output res_sub : i8>, parameters = [], port_locs = [#loc, #loc1, #loc2, #loc3], sym_name = "Adder"} : () -> ()
}) : () -> ()

