"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input sel : i1, input a : i8, output res : i8>, parameters = [], sym_name = "AssertMuxSameBranch"}> ({
  ^bb0(%arg0: i1, %arg1: i8):
    %0 = "comb.mux"(%arg0, %arg1, %arg1) : (i1, i8, i8) -> i8
    %1 = "comb.icmp"(%0, %arg1) <{predicate = 0 : i64}> : (i8, i8) -> i1
    "sv.alwayscomb"() ({
      "sv.assert"(%1) <{defer = 0 : i32, label = "assert_mux_same_branch"}> : (i1) -> ()
    }) : () -> ()
    "hw.output"(%0) : (i8) -> ()
  }) : () -> ()
}) : () -> ()
