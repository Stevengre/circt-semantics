#loc = loc("comb/parity/parity.mlir":1:31)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "comb.parity"(%arg0) : (i8) -> i1
    "hw.output"(%0) : (i1) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i1>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

