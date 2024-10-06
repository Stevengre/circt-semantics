#loc = loc("a.mlir":1:54)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0(%clk: !seq.clock, %rst: i1):
        %0 = "hw.constant"() {value = 0 : i8} : () -> i8
        %1 = "hw.constant"() {value = 1 : i8} : () -> i8
        %reg = "seq.firreg"(%next, %clk, %rst, %0) <{name = "reg"}> : (i8, !seq.clock, i1, i8) -> i8
        %next = "comb.add"(%reg, %1) : (i8, i8) -> i8
        "hw.output"(%reg) : (i8) -> ()
    }) {module_type = !hw.modty<input clk : !seq.clock, input rst : i1, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()