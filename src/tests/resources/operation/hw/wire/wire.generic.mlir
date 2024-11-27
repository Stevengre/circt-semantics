#loc = loc("hw/wire/wire.mlir":1:20)
"builtin.module"() ({
  "hw.module"() ({
    %0 = "hw.constant"() {value = 0 : i8} : () -> i8
    %1 = "hw.wire"(%0) {inner_sym = #hw<innerSym@mySym>, name = "myWire"} : (i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

