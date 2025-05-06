#loc = loc("comb/extract/extract.mlir":1:31)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "comb.extract"(%arg0) <{lowBit = 3 : i32}> : (i8) -> i4
    "hw.output"(%0) : (i4) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i4>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

