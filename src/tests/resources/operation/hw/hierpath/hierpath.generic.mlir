#loc = loc("hw/hierpath/hierpath.mlir":1:42)
#loc1 = loc("hw/hierpath/hierpath.mlir":6:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.reg"() {inner_sym = #hw<innerSym@sym_reg>, name = "reg", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Bar"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.instance"(%arg0, %arg1) {argNames = ["a", "b"], inner_sym = #hw<innerSym@sym_bar>, instanceName = "bar", moduleName = @Bar, parameters = [], resultNames = ["res"]} : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc1], sym_name = "Fuu"} : () -> ()
  "hw.hierpath"() {namepath = [#hw.innerNameRef<@Fuu::@sym_bar>, #hw.innerNameRef<@Bar::@sym_reg>], sym_name = "ref"} : () -> ()
  "hw.module"() ({
    %0 = "sv.xmr.ref"() {ref = @ref, verbatimSuffix = ""} : () -> !hw.inout<i8>
    "hw.output"() : () -> ()
  }) {module_type = !hw.modty<>, parameters = [], sym_name = "Foo"} : () -> ()
}) : () -> ()

