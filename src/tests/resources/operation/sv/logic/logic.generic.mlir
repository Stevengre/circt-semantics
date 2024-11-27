#loc = loc("sv/logic/logic.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.logic"() {name = "logic_a"} : () -> !hw.inout<i8>
    %1 = "sv.logic"() {name = "logic_b"} : () -> !hw.inout<i8>
    "sv.assign"(%0, %arg0) : (!hw.inout<i8>, i8) -> ()
    "sv.assign"(%1, %arg1) : (!hw.inout<i8>, i8) -> ()
    %2 = "sv.read_inout"(%0) : (!hw.inout<i8>) -> i8
    %3 = "sv.read_inout"(%1) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%2, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

