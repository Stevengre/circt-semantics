#loc = loc("sv/struct_field_inout/struct_field_inout.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.struct_create"(%arg0, %arg1) : (i8, i8) -> !hw.struct<a: i8, b: i8>
    %1 = "sv.reg"() {name = "reg"} : () -> !hw.inout<struct<a: i8, b: i8>>
    "sv.assign"(%1, %0) : (!hw.inout<struct<a: i8, b: i8>>, !hw.struct<a: i8, b: i8>) -> ()
    %2 = "sv.struct_field_inout"(%1) {field = "a"} : (!hw.inout<struct<a: i8, b: i8>>) -> !hw.inout<i8>
    %3 = "sv.struct_field_inout"(%1) {field = "b"} : (!hw.inout<struct<a: i8, b: i8>>) -> !hw.inout<i8>
    %4 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
    %5 = "sv.read_inout"(%3) : (!hw.inout<i8>) -> i8
    %6 = "comb.add"(%4, %5) : (i8, i8) -> i8
    "hw.output"(%6) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

