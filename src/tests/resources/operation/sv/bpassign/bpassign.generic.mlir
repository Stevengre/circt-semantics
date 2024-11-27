#loc = loc("sv/bpassign/bpassign.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "sv.reg"() {name = "reg"} : () -> !hw.inout<i8>
    "sv.always"() ({
      "sv.bpassign"(%0, %arg1) : (!hw.inout<i8>, i8) -> ()
    }) {events = []} : () -> ()
    %1 = "sv.read_inout"(%0) : (!hw.inout<i8>) -> i8
    %2 = "comb.add"(%1, %arg2) : (i8, i8) -> i8
    "hw.output"(%2) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

