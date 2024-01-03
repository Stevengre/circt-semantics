#loc = loc("adder.mlir":1:20)
#loc1 = loc("adder.mlir":1:32)
#loc2 = loc("adder.mlir":5:20)
#loc3 = loc("adder.mlir":5:31)
#loc4 = loc("adder.mlir":5:43)
#loc5 = loc("adder.mlir":5:60)
#loc6 = loc("adder.mlir":11:21)
#loc7 = loc("adder.mlir":11:32)
#loc8 = loc("adder.mlir":11:44)
"builtin.module"() ({

    "sv.macro.decl"() {sym_name = "RANDOM"} : () -> ()
    "sv.macro.decl"() {sym_name = "foo"} : () -> ()

    "sv.bind"() {instance = #hw.innerNameRef<@AB::@b1>} : () -> ()
    "hw.hierpath"() {namepath = [#hw.innerNameRef<@XMRRefOp::@bar>], sym_name = "ref2"} : () -> ()
    
    "hw.module"() ({
        ^bb0(%arg0: i8):
            "hw.output"(%arg0) : (i8) -> ()
    }) {module_type = !hw.modty<input xx : i8, output res : i8>, parameters = [], port_locs = [#loc, #loc1], sym_name = "Same"} : () -> ()
    
    "hw.module"() ({
        ^bb0(%arg0: i8, %arg1: i8):
            %0 = "hw.instance"(%arg0) {argNames = ["xx"], instanceName = "same1", moduleName = @Same, parameters = [], resultNames = ["res"]} : (i8) -> i8
            %1 = "hw.instance"(%arg1) {argNames = ["xx"], instanceName = "same2", moduleName = @Same, parameters = [], resultNames = ["res"]} : (i8) -> i8
            "hw.output"(%1, %0) : (i8, i8) -> ()
    }) {module_type = !hw.modty<input xx : i8, input yy : i8, output result1 : i8, output result2 : i8>, parameters = [], port_locs = [#loc2, #loc3, #loc4, #loc5], sym_name = "Swap"} : () -> ()
    
    "hw.module"() ({
        ^bb0(%arg0: i8, %arg1: i8):
           "sv.always"(%arg0) ({
                "sv.error"() {message = "error"} : () -> ()
            }) {events = [0 : i32]} : (i1) -> ()

            %0, %1 = "hw.instance"(%arg0, %arg1) {argNames = ["x", "y"], instanceName = "swap", moduleName = @Swap, parameters = [], resultNames = ["result1", "result2"]} : (i8, i8) -> (i8, i8)
            %2 = "comb.add"(%0, %1) : (i8, i8) -> i8
            "hw.output"(%2) : (i8) -> ()
    }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], port_locs = [#loc6, #loc7, #loc8], sym_name = "Adder"} : () -> ()
}) : () -> ()