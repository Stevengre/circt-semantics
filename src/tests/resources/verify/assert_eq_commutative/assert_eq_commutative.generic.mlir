"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input a : i8, input b : i8, output res : i1>, parameters = [], sym_name = "AssertEqCommutative"}> ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.icmp"(%arg0, %arg1) <{predicate = 0 : i64}> : (i8, i8) -> i1
    %1 = "comb.icmp"(%arg1, %arg0) <{predicate = 0 : i64}> : (i8, i8) -> i1
    %2 = "comb.icmp"(%0, %1) <{predicate = 0 : i64}> : (i1, i1) -> i1
    "sv.alwayscomb"() ({
      "sv.assert"(%2) <{defer = 0 : i32, label = "assert_eq_commutative"}> : (i1) -> ()
    }) : () -> ()
    "hw.output"(%0) : (i1) -> ()
  }) : () -> ()
}) : () -> ()
