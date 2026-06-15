"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input a : i8, output res : i8>, parameters = [], sym_name = "AssertAddZeroIdentity"}> ({
  ^bb0(%arg0: i8):
    %0 = "hw.constant"() {value = 0 : i8} : () -> i8
    %1 = "comb.add"(%arg0, %0) : (i8, i8) -> i8
    %2 = "comb.icmp"(%1, %arg0) <{predicate = 0 : i64}> : (i8, i8) -> i1
    "sv.alwayscomb"() ({
      "sv.assert"(%2) <{defer = 0 : i32, label = "assert_add_zero_identity"}> : (i1) -> ()
    }) : () -> ()
    "hw.output"(%1) : (i8) -> ()
  }) : () -> ()
}) : () -> ()
