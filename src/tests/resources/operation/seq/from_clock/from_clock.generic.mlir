"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%clk: !seq.clock):
    %cond = "seq.from_clock"(%clk) : (!seq.clock) -> i1
    "hw.output"(%cond) : (i1) -> ()
  }) {module_type = !hw.modty<input clk : !seq.clock, output res : i1>, parameters = [], sym_name = "Foo"} : () -> ()
}) : () -> ()

