"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%clk: i1):
    %clock = "seq.to_clock"(%clk) : (i1) -> !seq.clock
    "hw.output"(%clock) : (!seq.clock) -> ()
  }) {module_type = !hw.modty<input clk : i1, output res : !seq.clock>, parameters = [], sym_name = "Foo"} : () -> ()
}) : () -> ()
