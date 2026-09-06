#loc = loc("/Users/bytedance/cym/cymProject/k-circt-top-repo/services/circt-semantics/src/tests/resources/operation/seq/firreg_preset/firreg_preset.mlir":4:20)
#loc1 = loc("/Users/bytedance/cym/cymProject/k-circt-top-repo/services/circt-semantics/src/tests/resources/operation/seq/firreg_preset/firreg_preset.mlir":4:32)
#loc2 = loc("/Users/bytedance/cym/cymProject/k-circt-top-repo/services/circt-semantics/src/tests/resources/operation/seq/firreg_preset/firreg_preset.mlir":4:44)
#loc3 = loc("/Users/bytedance/cym/cymProject/k-circt-top-repo/services/circt-semantics/src/tests/resources/operation/seq/firreg_preset/firreg_preset.mlir":5:20)
#loc4 = loc("/Users/bytedance/cym/cymProject/k-circt-top-repo/services/circt-semantics/src/tests/resources/operation/seq/firreg_preset/firreg_preset.mlir":5:34)
#loc5 = loc("/Users/bytedance/cym/cymProject/k-circt-top-repo/services/circt-semantics/src/tests/resources/operation/seq/firreg_preset/firreg_preset.mlir":5:49)
"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input clk : i1, input reset : i1, input enable : i1, input d4 : i4, input d8 : i8, output q4 : i4, output q8 : i8, output qneg : i8, output qbit : i1, output plain : i4, output next4 : i4>, parameters = [], result_locs = [#loc, #loc1, #loc2, #loc3, #loc4, #loc5], sym_name = "Foo"}> ({
  ^bb0(%arg0: i1, %arg1: i1, %arg2: i1, %arg3: i4, %arg4: i8):
    %0 = "seq.to_clock"(%arg0) : (i1) -> !seq.clock
    %1 = "hw.constant"() <{value = 1 : i4}> : () -> i4
    %2 = "hw.constant"() <{value = 2 : i4}> : () -> i4
    %3 = "hw.constant"() <{value = 60 : i8}> : () -> i8
    %4 = "comb.add"(%6, %1) : (i4, i4) -> i4
    %5 = "comb.mux"(%arg2, %4, %6) : (i1, i4, i4) -> i4
    %6 = "seq.firreg"(%5, %0, %arg1, %2) <{name = "q4", preset = 5 : i4}> : (i4, !seq.clock, i1, i4) -> i4
    %7 = "comb.mux"(%arg2, %arg4, %8) : (i1, i8, i8) -> i8
    %8 = "seq.firreg"(%7, %0, %arg1, %3) <{name = "q8", preset = -91 : i8}> : (i8, !seq.clock, i1, i8) -> i8
    %9 = "seq.firreg"(%arg4, %0) <{name = "qneg", preset = -1 : i8}> : (i8, !seq.clock) -> i8
    %10 = "seq.firreg"(%arg2, %0) <{name = "qbit", preset = true}> : (i1, !seq.clock) -> i1
    %11 = "seq.firreg"(%arg3, %0) <{name = "plain"}> : (i4, !seq.clock) -> i4
    "hw.output"(%6, %8, %9, %10, %11, %4) : (i4, i8, i8, i1, i4, i4) -> ()
  }) : () -> ()
}) : () -> ()

