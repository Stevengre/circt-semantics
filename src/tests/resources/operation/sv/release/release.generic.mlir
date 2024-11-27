#loc = loc("sv/release/release.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "sv.reg"() {name = "reg_a"} : () -> !hw.inout<i8>
    %1 = "sv.reg"() {name = "reg_b"} : () -> !hw.inout<i8>
    "sv.initial"() ({
      "sv.force"(%0, %arg2) : (!hw.inout<i8>, i8) -> ()
      "sv.force"(%1, %arg1) : (!hw.inout<i8>, i8) -> ()
      "sv.release"(%0) : (!hw.inout<i8>) -> ()
      "sv.release"(%1) : (!hw.inout<i8>) -> ()
    }) : () -> ()
    %2 = "sv.read_inout"(%0) : (!hw.inout<i8>) -> i8
    %3 = "sv.read_inout"(%1) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%2, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

