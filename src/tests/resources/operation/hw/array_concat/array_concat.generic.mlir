#loc = loc("hw/array_concat/array_concat.mlir":1:62)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8, %arg2: i1, %arg3: i1):
    %0 = "hw.array_create"(%arg0) : (i8) -> !hw.array<1xi8>
    %1 = "hw.array_create"(%arg1) : (i8) -> !hw.array<1xi8>
    %2 = "hw.array_concat"(%0, %1) : (!hw.array<1xi8>, !hw.array<1xi8>) -> !hw.array<2xi8>
    %3 = "hw.constant"() {value = false} : () -> i1
    %4 = "hw.constant"() {value = true} : () -> i1
    %5 = "hw.array_get"(%2, %arg2) : (!hw.array<2xi8>, i1) -> i8
    %6 = "hw.array_get"(%2, %arg3) : (!hw.array<2xi8>, i1) -> i8
    %7 = "comb.add"(%5, %6) : (i8, i8) -> i8
    "hw.output"(%7) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, input c : i1, input d : i1, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

