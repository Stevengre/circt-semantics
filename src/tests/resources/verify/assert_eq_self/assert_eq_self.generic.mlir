"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input a : i8, output res : i8>, parameters = [], sym_name = "AssertEqSelf"}> ({
  ^bb0(%arg0: i8):
    %0 = "comb.icmp"(%arg0, %arg0) <{predicate = 0 : i64}> : (i8, i8) -> i1
    "sv.alwayscomb"() ({
      "sv.assert"(%0) <{defer = 0 : i32, label = "assert_eq_self"}> : (i1) -> ()
    }) : () -> ()
    "hw.output"(%arg0) : (i8) -> ()
  }) : () -> ()
}) : () -> ()
