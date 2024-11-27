#loc = loc("comb/concat/concat.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.concat"(%arg0, %arg1) : (i8, i8) -> i16
    "hw.output"(%0) : (i16) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i16>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

