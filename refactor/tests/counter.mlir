"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%clk: i1):
    %0 = "hw.constant"() {value = 0 : i8} : () -> i8
    %1 = "hw.constant"() {value = 1 : i8} : () -> i8
    %reg = "sv.reg"() {name = "reg"} : () -> !hw.inout<i8>
    %res = "sv.read_inout"(%reg) : (!hw.inout<i8>) -> i8
    %next = "comb.add"(%res, %1) : (i8, i8) -> i8
    
    "sv.initial"() ({
      "sv.passign"(%reg, %0) : (!hw.inout<i8>, i8) -> ()
    }) : () -> ()
    
    "sv.always"(%clk) ({
      "sv.passign"(%reg, %next) : (!hw.inout<i8>, i8) -> ()
    }) {events = [0 : i32]} : (i1) -> ()
    
    "hw.output"(%res) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, output res : i8>, parameters = [], sym_name = "Counter"} : () -> ()
}) : () -> ()