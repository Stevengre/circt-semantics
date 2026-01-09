#loc = loc("module-eq.mlir":2:42)
#loc1 = loc("module-eq.mlir":6:45)
#loc2 = loc("module-eq.mlir":11:34)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "comb.add"(%arg0, %arg0) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Add", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "hw.constant"() {value = 2 : i8} : () -> i8
    %1 = "comb.mul"(%arg0, %0) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i8>, parameters = [], result_locs = [#loc1], sym_name = "MulTwo", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "hw.instance"(%arg0) {argNames = ["a"], instanceName = "Add_", moduleName = @Add, parameters = [], resultNames = ["res"]} : (i8) -> i8
    %1 = "hw.instance"(%arg0) {argNames = ["a"], instanceName = "MulTwo_", moduleName = @MulTwo, parameters = [], resultNames = ["res"]} : (i8) -> i8
    %2 = "comb.icmp"(%0, %1) <{predicate = 0 : i64, twoState}> : (i8, i8) -> i1
    "hw.output"(%2) : (i1) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i1>, parameters = [], result_locs = [#loc2], sym_name = "Foo"} : () -> ()
}) : () -> ()

