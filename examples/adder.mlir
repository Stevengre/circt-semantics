"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "sv.reg"() {name = "y", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
    %1 = "sv.wire"() {name = "z", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
    "hw.output"(%arg0) : (i8) -> ()
  }) {module_type = !hw.modty<input xx : i8, output res : i8>, parameters = [], port_locs = [#loc, #loc1], sym_name = "Wrap"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.instance"(%arg0) {argNames = ["x"], instanceName = "wrap", moduleName = @Wrap, parameters = [], resultNames = ["res"]} : (i8) -> i8
    "hw.output"(%arg1, %0) : (i8, i8) -> ()
  }) {module_type = !hw.modty<input xx : i8, input y : i8, output res1 : i8, output res2 : i8>, parameters = [], port_locs = [#loc2, #loc3, #loc4, #loc5], sym_name = "Swap"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0#0, %0#1 = "hw.instance"(%arg0, %arg1) {argNames = ["x", "y"], instanceName = "swap1", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
    %1#0, %1#1 = "hw.instance"(%arg0, %arg1) {argNames = ["x", "y"], instanceName = "swap2", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
    %2 = "sv.xmr"() {isRooted, path = ["swap1", "wrap"], terminal = "y"} : () -> !hw.inout<i8>
    %3 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%1#1, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], port_locs = [#loc6, #loc7, #loc8], sym_name = "Adder"} : () -> ()
}) : () -> ()