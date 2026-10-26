"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input data : i8, output result : i8>, parameters = [], sym_name = "ContractAdder"}> ({
  ^bb0(%data: i8):
    %one = "hw.constant"() <{value = 1 : i8}> : () -> i8
    %sum = "comb.add"(%data, %one) : (i8, i8) -> i8
    "hw.output"(%sum) : (i8) -> ()
  }) : () -> ()
}) : () -> ()
