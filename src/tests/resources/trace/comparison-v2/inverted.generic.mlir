"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input a : i8, input b : i8, input sel : i1, output result : i8>, parameters = [], sym_name = "ControlPair"}> ({
  ^bb0(%a: i8, %b: i8, %sel: i1):
    %polarity = "hw.constant"() <{value = 1 : i1}> : () -> i1
    %condition = "comb.xor"(%sel, %polarity) : (i1, i1) -> i1
    %selected = "comb.mux"(%condition, %a, %b) : (i1, i8, i8) -> i8
    "hw.output"(%selected) : (i8) -> ()
  }) : () -> ()
}) : () -> ()
