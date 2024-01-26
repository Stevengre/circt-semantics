#loc = loc("a.mlir":1:20)
#loc1 = loc("a.mlir":1:33)
#loc2 = loc("a.mlir":7:20)
#loc3 = loc("a.mlir":7:32)
#loc4 = loc("a.mlir":7:45)
#loc5 = loc("a.mlir":7:59)
#loc6 = loc("a.mlir":15:21)
#loc7 = loc("a.mlir":15:32)
#loc8 = loc("a.mlir":15:44)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.assert.concurrent"(%arg0, %0) {event = 0 : i32} : (i1, i1) -> ()
    %1 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], port_locs = [#loc6, #loc7, #loc8, #loc9], sym_name = "Adder"} : () -> ()
}) : () -> ()