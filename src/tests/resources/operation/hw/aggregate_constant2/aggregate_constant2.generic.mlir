#loc = loc("hw/aggregate_constant2/aggregate_constant2.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i2, %arg1: i8):
    %0 = "hw.aggregate_constant"() {fields = [-1 : i8, 0 : i8, 1 : i8, 2 : i8]} : () -> !hw.array<4xi8>
    %1 = "hw.constant"() {value = -1 : i2} : () -> i2
    %2 = "hw.array_get"(%0, %arg0) {sv.namehint = "add1"} : (!hw.array<4xi8>, i2) -> i8
    %3 = "comb.add"(%2, %arg1) : (i8, i8) -> i8
    "hw.output"(%3) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i2, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

