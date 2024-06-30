#loc = loc("tests/a.mlir":1:24)
#loc1 = loc("tests/a.mlir":19:31)
"builtin.module"() ({
  "hw.module"() ({
    %0 = "hw.constant"() {value = 0 : i8} : () -> i8
    %1 = "hw.constant"() {value = 1 : i8} : () -> i8
    %2 = "sv.reg"() {name = "reg"} : () -> !hw.inout<i8>
    %3 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%3, %1) : (i8, i8) -> i8
    
    "sv.initial"() ({
      "sv.passign"(%2, %0) : (!hw.inout<i8>, i8) -> ()
    }) : () -> ()
    
    "sv.always"() ({
      "sv.passign"(%2, %4) : (!hw.inout<i8>, i8) -> ()
    }) {events = []} : () -> ()
    
    "hw.output"(%3) : (i8) -> ()
  }) {module_type = !hw.modty<output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Counter"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "hw.instance"() {argNames = [], instanceName = "counter", moduleName = @Counter, parameters = [], resultNames = ["res"]} : () -> i8
    %1 = "comb.add"(%arg0, %0) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i8>, parameters = [], result_locs = [#loc1], sym_name = "Foo"} : () -> ()
}) : () -> ()
