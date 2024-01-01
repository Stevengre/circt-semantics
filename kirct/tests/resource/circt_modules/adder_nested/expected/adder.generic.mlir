#loc = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder_nested/adder.mlir":2:32)
#loc1 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder_nested/adder.mlir":2:48)
#loc2 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder_nested/adder.mlir":7:32)
#loc3 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder_nested/adder.mlir":7:48)
#loc4 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder_nested/adder.mlir":12:23)
#loc5 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder_nested/adder.mlir":12:39)
#loc6 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder_nested/adder.mlir":12:58)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "hw.constant"() {value = 1 : i8} : () -> i8
    %1 = "comb.add"(%arg0, %0) {sv.namehint = "_out_T"} : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input io_a : i8, output res : i8>, parameters = [], port_locs = [#loc, #loc1], sym_name = "AddOne", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "hw.instance"(%arg0) {argNames = ["io_a"], instanceName = "i0", moduleName = @AddOne, parameters = [], resultNames = ["res"]} : (i8) -> i8
    %1 = "hw.instance"(%0) {argNames = ["io_a"], instanceName = "i1", moduleName = @AddOne, parameters = [], resultNames = ["res"]} : (i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input io_a : i8, output res2 : i8>, parameters = [], port_locs = [#loc2, #loc3], sym_name = "AddTwo", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "hw.instance"(%arg0) {argNames = ["io_a"], instanceName = "i0", moduleName = @AddTwo, parameters = [], resultNames = ["res2"]} : (i8) -> i8
    %1 = "hw.instance"(%0) {argNames = ["io_a"], instanceName = "i2", moduleName = @AddOne, parameters = [], resultNames = ["res"]} : (i8) -> i8
    "hw.output"(%0, %1) : (i8, i8) -> ()
  }) {module_type = !hw.modty<input io_a : i8, output res_out2 : i8, output res_out1 : i8>, parameters = [], port_locs = [#loc4, #loc5, #loc6], sym_name = "Adder"} : () -> ()
}) : () -> ()

