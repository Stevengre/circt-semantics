#loc = loc("hw/struct_inject/struct_inject.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.struct_create"(%arg1, %arg0) : (i8, i8) -> !hw.struct<a: i8, b: i8>
    %1 = "hw.struct_inject"(%0, %arg0) {fieldIndex = 0 : i32} : (!hw.struct<a: i8, b: i8>, i8) -> !hw.struct<a: i8, b: i8>
    %2 = "hw.struct_inject"(%1, %arg1) {fieldIndex = 1 : i32} : (!hw.struct<a: i8, b: i8>, i8) -> !hw.struct<a: i8, b: i8>
    %3:2 = "hw.struct_explode"(%2) : (!hw.struct<a: i8, b: i8>) -> (i8, i8)
    %4 = "comb.add"(%3#0, %3#1) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

