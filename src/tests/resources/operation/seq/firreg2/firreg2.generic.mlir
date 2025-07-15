#loc = loc("seq/firreg2/firreg2.mlir":1:61)
#loc1 = loc("seq/firreg2/firreg2.mlir":1:74)
#loc2 = loc("seq/firreg2/firreg2.mlir":1:88)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: !seq.clock, %arg1: i8, %arg2: i8):
    %0 = "seq.firreg"(%3, %arg0) <{name = "reg_port"}> {firrtl.random_init_start = 3 : ui64} : (i8, !seq.clock) -> i8
    %1 = "hw.constant"() {value = 0 : i8} : () -> i8
    %2 = "hw.constant"() {value = 1 : i8} : () -> i8
    %3 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    %4 = "comb.add"(%0, %2) : (i8, i8) -> i8
    %5 = "seq.firreg"(%4, %arg0) <{name = "reg_port2"}> {firrtl.random_init_start = 3 : ui64} : (i8, !seq.clock) -> i8
    "hw.output"(%3, %0, %5) : (i8, i8, i8) -> ()
  }) {module_type = !hw.modty<input clk : !seq.clock, input a : i8, input b : i8, output res : i8, output res2 : i8, output res3 : i8>, parameters = [], result_locs = [#loc, #loc1, #loc2], sym_name = "Foo"} : () -> ()
}) : () -> ()

