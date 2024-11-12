#loc = loc("hw/aggregate_constant/aggregate_constant.mlir":1:20)
"builtin.module"() ({
  "hw.module"() ({
    %0 = "hw.aggregate_constant"() {fields = [1 : i2, -2 : i2, -1 : i2]} : () -> !hw.struct<a: i2, b: i2, c: i2>
    "hw.output"(%0) : (!hw.struct<a: i2, b: i2, c: i2>) -> ()
  }) {module_type = !hw.modty<output res : !hw.struct<a: i2, b: i2, c: i2>>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

