#loc = loc("hw/instance/instance.mlir":1:42)
#loc1 = loc("hw/instance/instance.mlir":5:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Bar"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.instance"(%arg0, %arg1) {argNames = ["a", "b"], inner_sym = #hw<innerSym@sym_bar>, instanceName = "bar", moduleName = @Bar, parameters = [], resultNames = ["res"]} : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc1], sym_name = "Foo"} : () -> ()
}) : () -> ()

