#loc = loc("sv/if/if.mlir":1:54)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.always"(%arg0) ({
      "sv.if"(%0) ({
        "sv.info"() {message = "hitIf"} : () -> ()
      }, {
      }) : (i1) -> ()
    }) {events = [0 : i32]} : (i1) -> ()
    %1 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

