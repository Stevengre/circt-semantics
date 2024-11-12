#loc = loc("hw/struct_extract/struct_extract.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.struct_create"(%arg0, %arg1) : (i8, i8) -> !hw.struct<a: i8, b: i8>
    %1 = "hw.struct_extract"(%0) {fieldIndex = 0 : i32} : (!hw.struct<a: i8, b: i8>) -> i8
    %2 = "hw.struct_extract"(%0) {fieldIndex = 1 : i32} : (!hw.struct<a: i8, b: i8>) -> i8
    %3 = "comb.add"(%1, %2) : (i8, i8) -> i8
    "hw.output"(%3) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

