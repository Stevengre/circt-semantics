#loc = loc("foo.mlir":1:33)
#loc1 = loc("foo.mlir":8:45)
#loc2 = loc("foo.mlir":8:59)
#loc3 = loc("foo.mlir":16:42)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0(%arg0: i8):
        %0 = "sv.reg"() {inner_sym = #hw<innerSym@sym_x>, name = "y", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
        %1 = "sv.wire"() {inner_sym = #hw<innerSym@sym_y>, name = "z", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
        "sv.assign"(%0, %arg0) : (!hw.inout<i8>, i8) -> ()
        "hw.output"(%arg0) : (i8) -> ()
    }) {module_type = !hw.modty<input xx : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Wrap"} : () -> ()
    
    "hw.module"() ({
    ^bb0(%arg0: i8, %arg1: i8):
        %0 = "hw.instance"(%arg0) {argNames = ["xx"], inner_sym = #hw<innerSym@sym_wrap>, instanceName = "wrap", moduleName = @Wrap, parameters = [], resultNames = ["res"]} : (i8) -> i8
        "hw.output"(%arg1, %0) : (i8, i8) -> ()
    }) {module_type = !hw.modty<input xx : i8, input yy : i8, output res1 : i8, output res2 : i8>, parameters = [], result_locs = [#loc1, #loc2], sym_name = "Swap"} : () -> ()
  
    "hw.hierpath"() {
        namepath = [#hw.innerNameRef<@Foo::@sym_swap1>, #hw.innerNameRef<@Swap::@sym_wrap>, #hw.innerNameRef<@Wrap::@sym_x>], 
        sym_name = "ref1"
    } : () -> ()
    "hw.hierpath"() {
        namepath = [#hw.innerNameRef<@Foo::@sym_swap2>, #hw.innerNameRef<@Swap::@sym_wrap>, #hw.innerNameRef<@Wrap::@sym_y>],
        sym_name = "ref2"
    } : () -> ()
  
    "hw.module"() ({
    ^bb0(%arg0: i8, %arg1: i8):
        %0:2 = "hw.instance"(%arg0, %arg1) {argNames = ["xx", "yy"], inner_sym = #hw<innerSym@sym_swap1>, instanceName = "swap1", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
        %1:2 = "hw.instance"(%arg0, %arg1) {argNames = ["xx", "yy"], inner_sym = #hw<innerSym@sym_swap2>, instanceName = "swap2", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
        %2 = "sv.xmr.ref"() {ref = @ref1, verbatimSuffix = ""} : () -> !hw.inout<i8>
        %3 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
        %4 = "comb.add"(%1#0, %3) : (i8, i8) -> i8
        "hw.output"(%4) : (i8) -> ()
    }) {
        module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, 
        parameters = [], 
        result_locs = [#loc3], 
        sym_name = "Foo"
    } : () -> ()
}) : () -> ()