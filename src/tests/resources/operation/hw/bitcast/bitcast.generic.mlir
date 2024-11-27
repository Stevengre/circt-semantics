#loc = loc("hw/bitcast/bitcast.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.struct_create"(%arg0, %arg1) : (i8, i8) -> !hw.struct<a: i8, b: i8>
    %1 = "hw.bitcast"(%0) : (!hw.struct<a: i8, b: i8>) -> i16
    "hw.output"(%1) : (i16) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i16>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

