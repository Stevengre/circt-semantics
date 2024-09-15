"builtin.module"() ({
  "hw.module"() ({
    %0 = "hw.constant"() {value = 0 : i8} : () -> i8
    %1 = "hw.constant"() {value = 1 : i8} : () -> i8
    %reg = "sv.reg"() {name = "reg"} : () -> !hw.inout<i8>
    %res = "sv.read_inout"(%reg) : (!hw.inout<i8>) -> i8
    %next = "comb.add"(%res, %1) : (i8, i8) -> i8
    
    "sv.initial"() ({
      "sv.passign"(%reg, %0) : (!hw.inout<i8>, i8) -> ()
    }) : () -> ()
    
    "sv.always"() ({
      "sv.passign"(%reg, %next) : (!hw.inout<i8>, i8) -> ()
    }) {events = []} : () -> ()
    
    "hw.output"(%res) : (i8) -> ()
  }) {module_type = !hw.modty<output res : i8>, parameters = [], sym_name = "Counter"} : () -> ()
}) : () -> ()