#loc = loc("src/tests/resources/trace/simulation/design.mlir":3:8)
"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input clk : i1, input reset : i1, output result : i8>, parameters = [], result_locs = [#loc], sym_name = "TraceSimulation"}> ({
  ^bb0(%clk: i1, %reset: i1):
    %clock = "seq.to_clock"(%clk) : (i1) -> !seq.clock
    %zero = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %one = "hw.constant"() <{value = 1 : i8}> : () -> i8
    %q = "seq.firreg"(%next, %clock, %reset, %zero) <{name = "counter"}> : (i8, !seq.clock, i1, i8) -> i8
    %next = "comb.add"(%q, %one) : (i8, i8) -> i8
    "hw.output"(%q) : (i8) -> ()
  }) : () -> ()
}) : () -> ()
