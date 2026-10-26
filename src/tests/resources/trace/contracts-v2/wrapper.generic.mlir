"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input data : i8, output result : i8>, parameters = [], sym_name = "ContractAdder"}> ({
  ^bb0(%data: i8):
    %one = "hw.constant"() <{value = 1 : i8}> : () -> i8
    %sum = "comb.add"(%data, %one) : (i8, i8) -> i8
    "hw.output"(%sum) : (i8) -> ()
  }) : () -> ()
  "hw.module"() <{module_type = !hw.modty<input a : i8, input b : i8, output left_result : i8, output right_result : i8>, parameters = [], sym_name = "ContractWrapper"}> ({
  ^bb0(%a: i8, %b: i8):
    %left = "hw.instance"(%a) <{argNames = ["data"], instanceName = "left", moduleName = @ContractAdder, parameters = [], resultNames = ["result"]}> : (i8) -> i8
    %right = "hw.instance"(%b) <{argNames = ["data"], instanceName = "right", moduleName = @ContractAdder, parameters = [], resultNames = ["result"]}> : (i8) -> i8
    "hw.output"(%left, %right) : (i8, i8) -> ()
  }) : () -> ()
}) : () -> ()
