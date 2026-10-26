"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input a : i8, input b : i8, output p0 : i1, output p1 : i1, output p2 : i1, output p3 : i1, output p4 : i1, output p5 : i1, output p6 : i1, output p7 : i1, output p8 : i1, output p9 : i1, output p10 : i1, output p11 : i1>, parameters = [], sym_name = "ProfileICmp"}> ({
  ^bb0(%a: i8, %b: i8):
    %p0 = "comb.icmp"(%a, %b) <{predicate = 0 : i64, twoState}> : (i8, i8) -> i1
    %p1 = "comb.icmp"(%a, %b) <{predicate = 1 : i64, twoState}> : (i8, i8) -> i1
    %p2 = "comb.icmp"(%a, %b) <{predicate = 2 : i64, twoState}> : (i8, i8) -> i1
    %p3 = "comb.icmp"(%a, %b) <{predicate = 3 : i64, twoState}> : (i8, i8) -> i1
    %p4 = "comb.icmp"(%a, %b) <{predicate = 4 : i64, twoState}> : (i8, i8) -> i1
    %p5 = "comb.icmp"(%a, %b) <{predicate = 5 : i64, twoState}> : (i8, i8) -> i1
    %p6 = "comb.icmp"(%a, %b) <{predicate = 6 : i64, twoState}> : (i8, i8) -> i1
    %p7 = "comb.icmp"(%a, %b) <{predicate = 7 : i64, twoState}> : (i8, i8) -> i1
    %p8 = "comb.icmp"(%a, %b) <{predicate = 8 : i64, twoState}> : (i8, i8) -> i1
    %p9 = "comb.icmp"(%a, %b) <{predicate = 9 : i64, twoState}> : (i8, i8) -> i1
    %p10 = "comb.icmp"(%a, %b) <{predicate = 10 : i64, twoState}> : (i8, i8) -> i1
    %p11 = "comb.icmp"(%a, %b) <{predicate = 11 : i64, twoState}> : (i8, i8) -> i1
    "hw.output"(%p0, %p1, %p2, %p3, %p4, %p5, %p6, %p7, %p8, %p9, %p10, %p11) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> ()
  }) : () -> ()
}) : () -> ()
