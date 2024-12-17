#loc = loc("sv/for/for.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "hw.constant"() {value = 0 : i8} : () -> i8
    %1 = "hw.constant"() {value = 1 : i8} : () -> i8
    "sv.always"(%arg0) ({
      "sv.for"(%0, %arg2, %1) ({
      ^bb0(%arg3: i8):
        "sv.info"() {message = "This is a test"} : () -> ()
      }) {inductionVarName = "i"} : (i8, i8, i8) -> ()
    }) {events = [0 : i32]} : (i1) -> ()
    %2 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%2) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

