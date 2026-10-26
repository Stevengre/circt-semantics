"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input clk : i1, input reset : i1, input sel : i1, input a : i8, input b : i8, output result : i8>, parameters = [], sym_name = "ProfileRegister"}> ({
  ^bb0(%clk: i1, %reset: i1, %sel: i1, %a: i8, %b: i8):
    %clock = "seq.to_clock"(%clk) : (i1) -> !seq.clock
    %zero = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %next = "comb.mux"(%sel, %a, %b) : (i1, i8, i8) -> i8
    %q = "seq.firreg"(%next, %clock, %reset, %zero) <{name = "q", preset = 7 : i8}> : (i8, !seq.clock, i1, i8) -> i8
    "hw.output"(%q) : (i8) -> ()
  }) : () -> ()
}) : () -> ()
