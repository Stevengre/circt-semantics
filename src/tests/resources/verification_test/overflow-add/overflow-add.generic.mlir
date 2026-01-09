#loc = loc("overflow-add.mlir":1:42)
#loc1 = loc("overflow-add.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.constant"() {value = false} : () -> i1
    %1 = "comb.concat"(%0, %arg0) : (i1, i8) -> i9
    %2 = "comb.concat"(%0, %arg1) : (i1, i8) -> i9
    %3 = "comb.add"(%1, %2) : (i9, i9) -> i9
    %4 = "comb.extract"(%3) <{lowBit = 0 : i32}> : (i9) -> i8
    %5 = "comb.extract"(%3) <{lowBit = 4 : i32}> : (i9) -> i1
    "hw.output"(%4, %5) : (i8, i1) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8, output overflow : i1>, parameters = [], result_locs = [#loc, #loc1], sym_name = "Foo"} : () -> ()
}) : () -> ()

