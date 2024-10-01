#loc = loc("circt-semantics/src/tests/resources/modules/adder/adder.mlir":1:50)
#loc1 = loc("circt-semantics/src/tests/resources/modules/adder/adder.mlir":1:67)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    %1 = "comb.sub"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0, %1) : (i8, i8) -> ()
  }) {module_type = !hw.modty<input io_a : i8, input io_b : i8, output res_add : i8, output res_sub : i8>, parameters = [], result_locs = [#loc, #loc1], sym_name = "Adder"} : () -> ()
}) : () -> ()