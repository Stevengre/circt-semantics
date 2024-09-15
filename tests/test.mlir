#loc = loc("foo.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.icmp"(%arg0, %arg1) <{predicate = 0 : i64, twoState}> : (i8, i8) -> i1
    "hw.output"(%0) : (i1) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i1>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()