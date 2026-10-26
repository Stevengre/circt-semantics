"builtin.module"() ({
 "hw.module"() <{module_type = !hw.modty<input clk : i1, input data : i8, output result : i8>, parameters = [], sym_name = "ClockChild"}> ({
 ^bb0(%clk: i1, %data: i8):
  %clock = "seq.to_clock"(%clk) : (i1) -> !seq.clock
  %reset = "hw.constant"() <{value = false}> : () -> i1
  %zero = "hw.constant"() <{value = 0 : i8}> : () -> i8
  %q = "seq.firreg"(%data, %clock, %reset, %zero) <{name = "q", preset = 0 : i8}> : (i8, !seq.clock, i1, i8) -> i8
  "hw.output"(%q) : (i8) -> ()
 }) : () -> ()
 "hw.module"() <{module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output both : i8, output constant_result : i8>, parameters = [], sym_name = "SingleClockWrapper"}> ({
 ^bb0(%clk: i1, %a: i8, %b: i8):
  %low = "hw.constant"() <{value = false}> : () -> i1
  %left = "hw.instance"(%clk, %a) <{argNames = ["clk", "data"], instanceName = "left", moduleName = @ClockChild, parameters = [], resultNames = ["result"]}> : (i1, i8) -> i8
  %right = "hw.instance"(%clk, %b) <{argNames = ["clk", "data"], instanceName = "right", moduleName = @ClockChild, parameters = [], resultNames = ["result"]}> : (i1, i8) -> i8
  %constant = "hw.instance"(%low, %b) <{argNames = ["clk", "data"], instanceName = "constant", moduleName = @ClockChild, parameters = [], resultNames = ["result"]}> : (i1, i8) -> i8
  %sum = "comb.add"(%left, %right) : (i8, i8) -> i8
  "hw.output"(%sum, %constant) : (i8, i8) -> ()
 }) : () -> ()
}) : () -> ()
