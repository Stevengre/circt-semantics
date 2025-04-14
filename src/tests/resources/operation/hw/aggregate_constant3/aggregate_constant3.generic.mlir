#loc = loc("hw/aggregate_constant3/aggregate_constant3.mlir":1:43)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i2, %arg1: i64):
    %0 = "hw.aggregate_constant"() {fields = [-1, 0, 1, 2]} : () -> !hw.array<4xi64>
    %1 = "hw.constant"() {value = -1 : i2} : () -> i2
    %2 = "hw.array_get"(%0, %1) {sv.namehint = "add1"} : (!hw.array<4xi64>, i2) -> i64
    %3 = "comb.add"(%2, %arg1) : (i64, i64) -> i64
    "hw.output"(%3) : (i64) -> ()
  }) {module_type = !hw.modty<input a : i2, input b : i64, output res : i64>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

