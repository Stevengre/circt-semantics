#loc = loc("sv/stop/stop.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    "sv.always"() ({
      "sv.stop"() {verbosity = 2 : i8} : () -> ()
    }) {events = []} : () -> ()
    %0 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

