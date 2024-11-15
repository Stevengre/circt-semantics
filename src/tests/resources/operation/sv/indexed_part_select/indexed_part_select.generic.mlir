#loc = loc("sv/indexed_part_select/indexed_part_select.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.constant"() {value = 0 : i8} : () -> i8
    %1 = "sv.indexed_part_select"(%arg0, %0) {width = 8 : i32} : (i8, i8) -> i8
    %2 = "sv.indexed_part_select"(%arg1, %0) {width = 8 : i32} : (i8, i8) -> i8
    %3 = "comb.add"(%1, %2) : (i8, i8) -> i8
    "hw.output"(%3) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

