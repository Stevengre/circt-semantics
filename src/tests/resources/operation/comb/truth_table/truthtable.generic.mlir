#loc = loc("comb/truth_table/truthtable.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i1):
    %0 = "comb.truth_table"(%arg0, %arg1) <{lookupTable = [false, true, true, false]}> : (i1, i1) -> i1
    "hw.output"(%0) : (i1) -> ()
  }) {module_type = !hw.modty<input a : i1, input b : i1, output res : i1>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

