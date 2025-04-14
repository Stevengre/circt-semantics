#loc = loc("hw/constant/constant.mlir":1:31)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "hw.constant"() {value = 42 : i8} : () -> i8
    %1 = "hw.constant"() {value = false} : () -> i1
    %2 = "hw.constant"() {value = true} : () -> i1
    %3 = "comb.replicate"(%2) : (i1) -> i8
    %4 = "comb.add"(%3, %arg0) : (i8, i8) -> i8
    %5 = "comb.add"(%4, %0) : (i8, i8) -> i8
    "hw.output"(%5) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

