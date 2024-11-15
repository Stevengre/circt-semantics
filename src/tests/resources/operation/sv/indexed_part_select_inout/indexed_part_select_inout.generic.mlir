#loc = loc("sv/indexed_part_select_inout/indexed_part_select_inout.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.array_create"(%arg0, %arg1, %arg0, %arg1) : (i8, i8, i8, i8) -> !hw.array<4xi8>
    %1 = "sv.reg"() {name = "reg"} : () -> !hw.inout<array<4xi8>>
    "sv.assign"(%1, %0) : (!hw.inout<array<4xi8>>, !hw.array<4xi8>) -> ()
    %2 = "hw.constant"() {value = 0 : i8} : () -> i8
    %3 = "sv.indexed_part_select_inout"(%1, %2) {width = 2 : i32} : (!hw.inout<array<4xi8>>, i8) -> !hw.inout<array<2xi8>>
    %4 = "sv.read_inout"(%3) : (!hw.inout<array<2xi8>>) -> !hw.array<2xi8>
    %5 = "hw.constant"() {value = false} : () -> i1
    %6 = "hw.constant"() {value = true} : () -> i1
    %7 = "hw.array_get"(%4, %5) : (!hw.array<2xi8>, i1) -> i8
    %8 = "hw.array_get"(%4, %6) : (!hw.array<2xi8>, i1) -> i8
    %9 = "comb.add"(%7, %8) : (i8, i8) -> i8
    "hw.output"(%9) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

