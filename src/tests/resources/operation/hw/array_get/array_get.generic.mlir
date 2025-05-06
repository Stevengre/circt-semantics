#loc = loc("hw/array_get/array_get.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.array_create"(%arg0, %arg1) : (i8, i8) -> !hw.array<2xi8>
    %1 = "hw.constant"() {value = true} : () -> i1
    %2 = "hw.constant"() {value = false} : () -> i1
    %3 = "hw.array_get"(%0, %1) : (!hw.array<2xi8>, i1) -> i8
    %4 = "hw.array_get"(%0, %2) : (!hw.array<2xi8>, i1) -> i8
    %5 = "comb.sub"(%3, %4) : (i8, i8) -> i8
    "hw.output"(%5) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

