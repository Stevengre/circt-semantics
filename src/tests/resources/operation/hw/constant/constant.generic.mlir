#loc = loc("hw/constant/constant.mlir":1:20)
"builtin.module"() ({
  "hw.module"() ({
    %0 = "hw.constant"() {value = 42 : i8} : () -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

