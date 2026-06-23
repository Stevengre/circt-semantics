"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input sel : i1, output res : i1>, parameters = [], sym_name = "AssertMuxSymbolicBoolSelect"}> ({
  ^bb0(%arg0: i1):
    %0 = "hw.constant"() {value = true} : () -> i1
    %1 = "hw.constant"() {value = false} : () -> i1
    %2 = "comb.mux"(%arg0, %0, %1) : (i1, i1, i1) -> i1
    %3 = "comb.icmp"(%2, %arg0) <{predicate = 0 : i64}> : (i1, i1) -> i1
    "sv.alwayscomb"() ({
      "sv.assert"(%3) <{defer = 0 : i32, label = "assert_mux_symbolic_bool_select"}> : (i1) -> ()
    }) : () -> ()
    "hw.output"(%2) : (i1) -> ()
  }) : () -> ()
}) : () -> ()
