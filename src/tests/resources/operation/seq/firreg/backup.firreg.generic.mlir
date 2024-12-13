"builtin.module"() ({
  "hw.module"() ({
    ^bb0(%clk: !seq.clock, %reset: i1):
      %reg_port = "seq.firreg"(%next, %clk, %reset, %c0) <{name = "counter"}> : (i8, !seq.clock, i1, i8) -> i8
      %next = "comb.add"(%reg_port, %c1) : (i8, i8) -> i8
      %c0 = "hw.constant"() {value = 0 : i8} : () -> i8
      %c1 = "hw.constant"() {value = 1 : i8} : () -> i8
      "hw.output"(%reg_port) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : !seq.clock, input reset : i1, output res : i8>, sym_name = "Foo", parameters = []} : () -> ()
}) : () -> ()

