#loc = loc("a.mlir":1:20)
#loc1 = loc("a.mlir":1:33)
#loc2 = loc("a.mlir":7:20)
#loc3 = loc("a.mlir":7:32)
#loc4 = loc("a.mlir":7:45)
#loc5 = loc("a.mlir":7:59)
#loc6 = loc("a.mlir":15:21)
#loc7 = loc("a.mlir":15:32)
#loc8 = loc("a.mlir":15:44)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "sv.reg"() {inner_sym = #hw<innerSym@sym_x>, name = "y", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
    %1 = "sv.wire"() {inner_sym = #hw<innerSym@sym_y>, name = "z", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
    "sv.assign"(%0, %arg0) : (!hw.inout<i8>, i8) -> ()
    "hw.output"(%arg0) : (i8) -> ()
  }) {module_type = !hw.modty<input xx : i8, output res : i8>, parameters = [], port_locs = [#loc, #loc1], sym_name = "Wrap"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.instance"(%arg0) {argNames = ["xx"], inner_sym = #hw<innerSym@sym_wrap>, instanceName = "wrap", moduleName = @Wrap, parameters = [], resultNames = ["res"]} : (i8) -> i8
    "hw.output"(%arg1, %0) : (i8, i8) -> ()
  }) {module_type = !hw.modty<input xx : i8, input yy : i8, output res1 : i8, output res2 : i8>, parameters = [], port_locs = [#loc2, #loc3, #loc4, #loc5], sym_name = "Swap"} : () -> ()
  
  "hw.hierpath"() {namepath = [#hw.innerNameRef<@Adder::@sym_swap1>, #hw.innerNameRef<@Swap::@sym_wrap>, #hw.innerNameRef<@Wrap::@sym_x>], sym_name = "ref1"} : () -> ()
  "hw.hierpath"() {namepath = [#hw.innerNameRef<@Adder::@sym_swap2>, #hw.innerNameRef<@Swap::@sym_wrap>, #hw.innerNameRef<@Wrap::@sym_y>], sym_name = "ref2"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0#0, %0#1 = "hw.instance"(%arg0, %arg1) {argNames = ["xx", "yy"], inner_sym = #hw<innerSym@sym_swap1>, instanceName = "swap1", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
    %1#0, %1#1 = "hw.instance"(%arg0, %arg1) {argNames = ["xx", "yy"], inner_sym = #hw<innerSym@sym_swap2>, instanceName = "swap2", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
    %2 = "sv.xmr.ref"() {ref = @ref1, verbatimSuffix = ""} : () -> !hw.inout<i8>
    %3 = "sv.xmr.ref"() {ref = @ref2, verbatimSuffix = ".x.y.z[42]"} : () -> !hw.inout<i8>
    %4 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
    %5 = "comb.add"(%1#0, %4) : (i8, i8) -> i8
    "hw.output"(%5) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output result : i8>, parameters = [], port_locs = [#loc6, #loc7, #loc8], sym_name = "Adder"} : () -> ()
}) : () -> ()