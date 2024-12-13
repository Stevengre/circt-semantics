#loc = loc("seq/firreg/firreg.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: !seq.clock, %arg1: i1):
    %0 = "seq.firreg"(%3, %arg0, %arg1, %1) <{name = "reg_port"}> {firrtl.random_init_start = 0 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %1 = "hw.constant"() {value = 0 : i8} : () -> i8
    %2 = "hw.constant"() {value = 1 : i8} : () -> i8
    %3 = "comb.add"(%0, %2) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : !seq.clock, input reset : i1, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

