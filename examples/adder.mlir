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
    "sv.macro.decl"() {sym_name = "PRINTF_COND_"} : () -> ()

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
            %t1 = "hw.constant"() {value = true} : () -> i1
            %t2 = "hw.constant"() {value = -2147483646 : i32} : () -> i32
            %t3 = "sv.localparam"() {name = "param_x", value = 11 : i42} : () -> i42
            %t4 = "sv.reg"() {name = "myReg2"} : () -> !hw.inout<i32>
            %t5 = "hw.constant"() {value = 1 : i4} : () -> i4
            %t6 = "sv.indexed_part_select_inout"(%t4, %t5) {decrement, width = 5 : i32} : (!hw.inout<i32>, i4) -> !hw.inout<i5>

            "sv.initial"() ({
                "sv.error"() {message = "initial"} : () -> ()
                "sv.if"(%t1) ({
                    "sv.fwrite"(%t2) {format_string = "yes"} : (i32) -> ()
                }, {
                    "sv.fwrite"(%t2) {format_string = "no"} : (i32) -> ()
                }) : (i1) -> ()
            }) : () -> ()

           "sv.always"(%arg0) ({
                "sv.error"() {message = "always"} : () -> ()

                "sv.ifdef.procedural"() ({
                    ^bb0:
                }, {
                    %10 = "sv.macro.ref"() {macroName = @PRINTF_COND_} : () -> i1
                    %11 = "sv.constantX"() : () -> i1
                    %12 = "sv.constantZ"() : () -> i1
                    %13 = "comb.and"(%10, %11, %12, %t1) : (i1, i1, i1, i1) -> i1
                   
                    "sv.if"(%13) ({
                        "sv.fwrite"(%0, %13) {format_string = "%x"} : (i32, i1) -> ()
                        }, {
                    "sv.fwrite"(%0) {format_string = "There"} : (i32) -> ()
                    }) : (i1) -> ()
                }) {cond = #sv<macro.ident "SYNTHESIS">} : () -> ()
            }) {events = [0 : i32]} : (i1) -> ()

            %0, %1 = "hw.instance"(%arg0, %arg1) {argNames = ["x", "y"], instanceName = "swap", moduleName = @Swap, parameters = [], resultNames = ["result1", "result2"]} : (i8, i8) -> (i8, i8)
            %2 = "comb.add"(%0, %1) : (i8, i8) -> i8
            "hw.output"(%2) : (i8) -> ()
    }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], port_locs = [#loc6, #loc7, #loc8], sym_name = "Adder"} : () -> ()
}) : () -> ()