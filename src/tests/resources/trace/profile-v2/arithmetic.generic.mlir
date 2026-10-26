"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input a : i64, input b : i64, input bit : i1, input nibble : i4, output product : i64, output triple : i64, output extended : i64, output tiled : i16>, parameters = [], sym_name = "ProfileArithmetic"}> ({
  ^bb0(%a: i64, %b: i64, %bit: i1, %nibble: i4):
    %three = "hw.constant"() <{value = 3 : i64}> : () -> i64
    %product = "comb.mul"(%a, %b) : (i64, i64) -> i64
    %triple = "comb.mul"(%a, %b, %three) : (i64, i64, i64) -> i64
    %extended = "comb.replicate"(%bit) : (i1) -> i64
    %tiled = "comb.replicate"(%nibble) : (i4) -> i16
    "hw.output"(%product, %triple, %extended, %tiled) : (i64, i64, i64, i16) -> ()
  }) : () -> ()
}) : () -> ()
