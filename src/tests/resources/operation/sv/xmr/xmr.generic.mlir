#loc = loc("foo.mlir":1:32)
#loc1 = loc("foo.mlir":7:43)
#loc2 = loc("foo.mlir":7:57)
#loc3 = loc("foo.mlir":12:42)
"builtin.module"() ({
    "hw.module"() ({
        ^bb0(%arg0: i8):
            %0 = "sv.reg"() {name = "y", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
            %1 = "sv.wire"() {name = "z", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
            "hw.output"(%arg0) : (i8) -> ()
    }) {module_type = !hw.modty<input x : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Wrap"} : () -> ()
    
    "hw.module"() ({
        ^bb0(%arg0: i8, %arg1: i8):
            %0 = "hw.instance"(%arg0) {argNames = ["x"], instanceName = "wrap", moduleName = @Wrap, parameters = [], resultNames = ["res"]} : (i8) -> i8
            "hw.output"(%arg1, %0) : (i8, i8) -> ()
    }) {module_type = !hw.modty<input x : i8, input y : i8, output res1 : i8, output res2 : i8>, parameters = [], result_locs = [#loc1, #loc2], sym_name = "Swap"} : () -> ()
  
    "hw.module"() ({
        ^bb0(%arg0: i8, %arg1: i8):
            %0:2 = "hw.instance"(%arg0, %arg1) {argNames = ["x", "y"], instanceName = "swap1", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
            %1:2 = "hw.instance"(%arg0, %arg1) {argNames = ["x", "y"], instanceName = "swap2", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
            %2 = "sv.xmr"() {isRooted, path = ["swap1", "wrap"], terminal = "y"} : () -> !hw.inout<i8>
            %3 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
            %4 = "comb.add"(%1#1, %3) : (i8, i8) -> i8
            "hw.output"(%4) : (i8) -> ()
    }) {
        module_type = !hw.modty<input a : i8, input b : i8, output result : i8>,
        parameters = [],
        result_locs = [#loc3],
        sym_name = "Foo"
    } : () -> ()
}) : () -> ()