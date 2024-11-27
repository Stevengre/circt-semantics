#loc = loc("hw/enum_cmp/enum_cmp.mlir":1:20)
"builtin.module"() ({
  "hw.module"() ({
    %0 = "hw.enum.constant"() {field = #hw.enum.field<A, !hw.enum<A, B, C>>} : () -> !hw.enum<A, B, C>
    %1 = "hw.enum.constant"() {field = #hw.enum.field<A, !hw.enum<A, B, C>>} : () -> !hw.enum<A, B, C>
    %2 = "hw.enum.cmp"(%0, %1) : (!hw.enum<A, B, C>, !hw.enum<A, B, C>) -> i1
    "hw.output"(%2) : (i1) -> ()
  }) {module_type = !hw.modty<output res : i1>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

