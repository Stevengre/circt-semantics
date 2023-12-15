#loc = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder/adder.mlir":2:20)
#loc1 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder/adder.mlir":2:32)
#loc2 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder/adder.mlir":2:44)
#loc3 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder/adder.mlir":2:55)
#loc4 = loc("/Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/adder/adder.mlir":2:70)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i1, %arg2: i8, %arg3: i8):
    %0 = "comb.add"(%arg2, %arg3) {sv.namehint = "_io_out_T_1"} : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {argLocs = [#loc, #loc1, #loc2, #loc3], argNames = ["clock", "reset", "io_a", "io_b"], comment = "", function_type = (i1, i1, i8, i8) -> i8, parameters = [], resultLocs = [#loc4], resultNames = ["io_out"], sym_name = "Adder"} : () -> ()
}) : () -> ()

