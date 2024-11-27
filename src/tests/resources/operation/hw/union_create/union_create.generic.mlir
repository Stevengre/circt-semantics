#loc = loc("hw/union_create/union_create.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.union_create"(%arg0) {fieldIndex = 0 : i32} : (i8) -> !hw.union<foo: i8, bar: i8>
    %1 = "hw.union_extract"(%0) {fieldIndex = 0 : i32} : (!hw.union<foo: i8, bar: i8>) -> i8
    %2 = "hw.union_create"(%arg1) {fieldIndex = 1 : i32} : (i8) -> !hw.union<foo: i8, bar: i8>
    %3 = "hw.union_extract"(%2) {fieldIndex = 1 : i32} : (!hw.union<foo: i8, bar: i8>) -> i8
    %4 = "comb.add"(%1, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

