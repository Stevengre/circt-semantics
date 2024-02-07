#loc = loc("a.mlir":1:20)
#loc1 = loc("a.mlir":1:33)
#loc2 = loc("a.mlir":7:20)
#loc3 = loc("a.mlir":7:32)
#loc4 = loc("a.mlir":7:45)
#loc5 = loc("a.mlir":7:59)
#loc6 = loc("a.mlir":15:21)
#loc7 = loc("a.mlir":15:32)
#loc8 = loc("a.mlir":15:44)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "hw.struct_create"(%arg1, %arg2) : (i8, i8) -> !hw.struct<aa: i8, bb: i8>
    %1 = "sv.reg"() {name = "reg"} : () -> !hw.inout<struct<aa: i8, bb: i8>>
    "sv.assign"(%1, %0) : (!hw.inout<struct<aa: i8, bb: i8>>, !hw.struct<aa: i8, bb: i8>) -> ()
    %2 = "sv.struct_field_inout"(%1) {field = "aa"} : (!hw.inout<struct<aa: i8, bb: i8>>) -> !hw.inout<i8>
    %3 = "sv.struct_field_inout"(%1) {field = "bb"} : (!hw.inout<struct<aa: i8, bb: i8>>) -> !hw.inout<i8>
    %4 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
    %5 = "sv.read_inout"(%3) : (!hw.inout<i8>) -> i8
    %6 = "comb.add"(%4, %5) : (i8, i8) -> i8
    "hw.output"(%6) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], port_locs = [#loc6, #loc7, #loc8, #loc9], sym_name = "Adder"} : () -> ()
}) : () -> ()