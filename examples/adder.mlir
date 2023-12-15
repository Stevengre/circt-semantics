#loc = loc("adder.mlir":1:20)
#loc1 = loc("adder.mlir":1:31)
#loc2 = loc("adder.mlir":1:43)
#loc3 = loc("adder.mlir":1:60)
#loc4 = loc("adder.mlir":5:21)
#loc5 = loc("adder.mlir":5:32)
#loc6 = loc("adder.mlir":5:44)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    "hw.output"(%arg1, %arg0) : (i8, i8) -> ()
  }) {module_type = !hw.modty<input xx : i8, input yy : i8, output result1 : i8, output result2 : i8>, parameters = [], port_locs = [#loc, #loc1, #loc2, #loc3], sym_name = "Swap"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0, %1 = "hw.instance"(%arg0, %arg1) {argNames = ["x", "y"], instanceName = "swap", moduleName = @Swap, parameters = [], resultNames = ["result1", "result2"]} : (i8, i8) -> (i8, i8)
    %2 = "comb.add"(%0, %1) : (i8, i8) -> i8
    "hw.output"(%2) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], port_locs = [#loc4, #loc5, #loc6], sym_name = "Adder"} : () -> ()
}) : () -> ()