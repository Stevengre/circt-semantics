"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], sym_name = "AssertNoSignedOverflow"}> ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.constant"() <{value = true}> : () -> i1
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    %2 = "comb.extract"(%arg0) <{lowBit = 7 : i32}> : (i8) -> i1
    %3 = "comb.extract"(%arg1) <{lowBit = 7 : i32}> : (i8) -> i1
    %4 = "comb.extract"(%1) <{lowBit = 7 : i32}> : (i8) -> i1
    %5 = "comb.icmp"(%2, %3) <{predicate = 0 : i64}> : (i1, i1) -> i1
    %6 = "comb.icmp"(%4, %2) <{predicate = 1 : i64}> : (i1, i1) -> i1
    %7 = "comb.and"(%5, %6) : (i1, i1) -> i1
    %8 = "comb.xor"(%7, %0) : (i1, i1) -> i1
    "sv.alwayscomb"() ({
      "sv.assert"(%8) <{defer = 0 : i32, label = "assert_no_signed_overflow"}> : (i1) -> ()
    }) : () -> ()
    "hw.output"(%1) : (i8) -> ()
  }) : () -> ()
}) : () -> ()
