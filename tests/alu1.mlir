// krun tests/alu1.mlir -cEntry='"Foo"' -cInput="ListItem( ListItem(bits(2, 8) : i8) ListItem(bits(3, 8) : i8) )" -d main-llvm
#loc = loc("tests/a.mlir":1:24)
#loc1 = loc("tests/a.mlir":19:31)
"builtin.module"() ({

    "hw.module"() ({
    ^bb0(%a: i8, %b: i8):
        %out = "comb.add"(%a, %b) : (i8, i8) -> i8
        "hw.output"(%out) : (i8) -> ()
    }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Adder"} : () -> ()


    "hw.module"() ({
    ^bb0(%a: i8, %b: i8):
        // %a = "hw.constant"() {value = 1 : i8} : () -> i8
        // %b = "hw.constant"() {value = 2 : i8} : () -> i8

        %res = "hw.instance"(%a, %b) {argNames = ["a", "b"], instanceName = "adder", moduleName = @Adder, parameters = [], resultNames = ["res"]} : (i8, i8) -> i8
        "hw.output"(%res) : (i8) -> ()
    }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc1], sym_name = "Foo"} : () -> ()
}) : () -> ()
