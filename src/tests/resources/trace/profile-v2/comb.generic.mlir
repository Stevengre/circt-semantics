"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input a : i8, input b : i8, input sel : i1, output sum : i8, output bits_and : i8, output bits_or : i8, output bits_xor : i8, output left : i8, output right : i8, output joined : i16, output slice : i4, output equal : i1, output selected : i8>, parameters = [], sym_name = "ProfileComb"}> ({
  ^bb0(%a: i8, %b: i8, %sel: i1):
    %sum = "comb.add"(%a, %b) : (i8, i8) -> i8
    %and = "comb.and"(%a, %b) : (i8, i8) -> i8
    %or = "comb.or"(%a, %b) : (i8, i8) -> i8
    %xor = "comb.xor"(%a, %b) : (i8, i8) -> i8
    %left = "comb.shl"(%a, %b) : (i8, i8) -> i8
    %right = "comb.shru"(%a, %b) : (i8, i8) -> i8
    %joined = "comb.concat"(%a, %b) : (i8, i8) -> i16
    %slice = "comb.extract"(%a) <{lowBit = 3 : i32}> : (i8) -> i4
    %equal = "comb.icmp"(%a, %b) <{predicate = 0 : i64, twoState}> : (i8, i8) -> i1
    %selected = "comb.mux"(%sel, %a, %b) : (i1, i8, i8) -> i8
    "hw.output"(%sum, %and, %or, %xor, %left, %right, %joined, %slice, %equal, %selected) : (i8, i8, i8, i8, i8, i8, i16, i4, i1, i8) -> ()
  }) : () -> ()
}) : () -> ()
