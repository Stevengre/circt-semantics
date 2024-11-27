#loc = loc("comb/replicate/replicate.mlir":1:31)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "comb.replicate"(%arg0) : (i8) -> i16
    "hw.output"(%0) : (i16) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i16>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

