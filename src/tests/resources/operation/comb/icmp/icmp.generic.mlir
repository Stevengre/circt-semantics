"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.icmp"(%arg0, %arg1) <{predicate = 0 : i64, twoState}> : (i8, i8) -> i1
    %1 = "comb.icmp"(%arg0, %arg1) <{predicate = 1 : i64, twoState}> : (i8, i8) -> i1
    %6 = "comb.icmp"(%arg0, %arg1) <{predicate = 6 : i64, twoState}> : (i8, i8) -> i1
    %8 = "comb.icmp"(%arg0, %arg1) <{predicate = 8 : i64, twoState}> : (i8, i8) -> i1
    %9 = "comb.icmp"(%arg0, %arg1) <{predicate = 9 : i64, twoState}> : (i8, i8) -> i1
    "hw.output"(%0, %1, %6, %8, %9) : (i1, i1, i1, i1, i1) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i1, output res1 : i1, output res6 : i1, output res8 : i1,output res9 : i1>, parameters = [],  sym_name = "Foo"} : () -> ()
}) : () -> ()

