#loc = loc("hw/constant/constant.mlir":1:31)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "hw.constant"() {value = 42 : i8} : () -> i8
    %1 = "comb.add"(%arg0, %0) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

