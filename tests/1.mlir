#loc = loc("tests/1.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: !seq.clock):
    %0 = "seq.from_clock"(%arg0) : (!seq.clock) -> i1
    "hw.output"(%0) : (i1) -> ()
  }) {module_type = !hw.modty<input clk : !seq.clock, output res : i1>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()