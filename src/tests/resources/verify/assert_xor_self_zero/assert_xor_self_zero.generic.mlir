"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input a : i8, output res : i8>, parameters = [], sym_name = "AssertXorSelfZero"}> ({
  ^bb0(%arg0: i8):
    %0 = "comb.xor"(%arg0, %arg0) : (i8, i8) -> i8
    %1 = "hw.constant"() {value = 0 : i8} : () -> i8
    %2 = "comb.icmp"(%0, %1) <{predicate = 0 : i64}> : (i8, i8) -> i1
    "sv.alwayscomb"() ({
      "sv.assert"(%2) <{defer = 0 : i32, label = "assert_xor_self_zero"}> : (i1) -> ()
    }) : () -> ()
    "hw.output"(%0) : (i8) -> ()
  }) : () -> ()
}) : () -> ()
