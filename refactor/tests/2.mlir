#loc = loc("foo.mlir":1:53)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%clk: !seq.clock, %rst: i1):
    %const_0 = "hw.constant"() {value = 0 : i8} : () -> i8
    %reg = "seq.firreg"(%next, %clk, %rst, %const_0) <{name = "reg"}> : (i8, !seq.clock, i1, i8) -> i8
    %const_1 = "hw.constant"() {value = 1 : i8} : () -> i8
    %next = "comb.add"(%reg, %const_1) : (i8, i8) -> i8
    "hw.output"(%reg) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : !seq.clock, input rst : i1, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()