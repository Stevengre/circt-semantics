"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input a : i8, output res : i8>, parameters = [], sym_name = "AssertTrue"}> ({
  ^bb0(%arg0: i8):
    %0 = "hw.constant"() <{value = true}> : () -> i1
    "sv.alwayscomb"() ({
      "sv.assert"(%0) <{defer = 0 : i32, label = "assert_true"}> : (i1) -> ()
    }) : () -> ()
    "hw.output"(%arg0) : (i8) -> ()
  }) : () -> ()
}) : () -> ()
