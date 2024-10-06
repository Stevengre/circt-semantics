#loc = loc("tests/a.mlir":1:24)
#loc1 = loc("tests/a.mlir":19:31)
"builtin.module"() ({
    "hw.module"() ({
        ^bb0(%clk: i1):
        %0 = "hw.constant"() {value = 0 : i8} : () -> i8
        %1 = "hw.constant"() {value = 1 : i8} : () -> i8
        %reg = "sv.reg"() {name = "reg"} : () -> !hw.inout<i8>
        %3 = "sv.read_inout"(%reg) : (!hw.inout<i8>) -> i8
        %4 = "comb.add"(%3, %3) : (i8, i8) -> i8

        %end = "hw.constant"() {value = 5 : i8} : () -> i8
        
        "sv.initial"() ({
            "sv.passign"(%reg, %0) : (!hw.inout<i8>, i8) -> ()

            "sv.for"(%0, %end, %1) ({
            ^bb0(%i: i8):
                %next = "comb.add"(%3, %i) : (i8, i8) -> i8
                "sv.passign"(%reg, %next) : (!hw.inout<i8>, i8) -> ()
            }) {inductionVarName = "i"} : (i8, i8, i8) -> ()

        }) : () -> ()
        
        "sv.always"(%clk) ({
            "sv.passign"(%reg, %4) : (!hw.inout<i8>, i8) -> ()
        }) {events = [0 : i32]} : (i1) -> ()
        
        "hw.output"(%3) : (i8) -> ()
    }) {module_type = !hw.modty<input clk : i1, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Counter"} : () -> ()
    
    "hw.module"() ({
    ^bb0(%clk: i1):
        %0 = "hw.instance"(%clk) {argNames = ["clk"], instanceName = "counter", moduleName = @Counter, parameters = [], resultNames = ["res"]} : (i1) -> i8
        "hw.output"(%0) : (i8) -> ()
    }) {module_type = !hw.modty<input clk : i1, output res : i8>, parameters = [], result_locs = [#loc1], sym_name = "Foo"} : () -> ()
}) : () -> ()
