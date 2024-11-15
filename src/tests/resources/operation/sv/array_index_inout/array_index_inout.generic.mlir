#loc = loc("sv/array_index_inout/array_index_inout.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.array_create"(%arg0, %arg1) : (i8, i8) -> !hw.array<2xi8>
    %1 = "sv.reg"() {name = "reg"} : () -> !hw.inout<array<2xi8>>
    "sv.assign"(%1, %0) : (!hw.inout<array<2xi8>>, !hw.array<2xi8>) -> ()
    %2 = "hw.constant"() {value = 0 : i8} : () -> i8
    %3 = "hw.constant"() {value = 1 : i8} : () -> i8
    %4 = "sv.array_index_inout"(%1, %2) : (!hw.inout<array<2xi8>>, i8) -> !hw.inout<i8>
    %5 = "sv.array_index_inout"(%1, %3) : (!hw.inout<array<2xi8>>, i8) -> !hw.inout<i8>
    %6 = "sv.read_inout"(%4) : (!hw.inout<i8>) -> i8
    %7 = "sv.read_inout"(%5) : (!hw.inout<i8>) -> i8
    %8 = "comb.add"(%6, %7) : (i8, i8) -> i8
    "hw.output"(%8) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

