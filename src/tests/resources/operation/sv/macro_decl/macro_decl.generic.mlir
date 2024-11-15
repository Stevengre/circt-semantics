#loc = loc("sv/macro_decl/macro_decl.mlir":2:42)
"builtin.module"() ({
  "sv.macro.decl"() {sym_name = "MACRO", verilogName = "1"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.macro.ref"() {macroName = @MACRO} : () -> i1
    "sv.always"() ({
      "sv.assert"(%0) {defer = 0 : i32} : (i1) -> ()
    }) {events = []} : () -> ()
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

