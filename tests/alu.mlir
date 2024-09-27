#loc = loc("tests/a.mlir":1:24)
#loc1 = loc("tests/a.mlir":19:31)
"builtin.module"() ({

    "hw.module"() ({
    ^bb0(%a: i8, %b: i8):
        %out = "comb.add"(%a, %b) : (i8, i8) -> i8
        "hw.output"(%out) : (i8) -> ()
    }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Adder"} : () -> ()

}) : () -> ()
