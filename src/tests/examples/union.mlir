#loc = loc("a.mlir":1:24)
#loc1 = loc("a.mlir":1:61)
#loc2 = loc("a.mlir":1:72)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: !hw.union<foo: i1, bar: i3>):
    %0 = "hw.union_extract"(%arg0) {fieldIndex = 1 : i32} : (!hw.union<foo: i1, bar: i3>) -> i3
    %1 = "hw.union_create"(%0) {fieldIndex = 0 : i32} : (i3) -> !hw.union<bar: i3, baz: i8>
    "hw.output"(%0, %1) : (i3, !hw.union<bar: i3, baz: i8>) -> ()
  }) {parameters = [], port_locs = [#loc, #loc1, #loc2], sym_name = "UnionOps"} : () -> ()
}) : () -> ()
