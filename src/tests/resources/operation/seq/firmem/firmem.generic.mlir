"builtin.module"() ({
  "hw.module"() ({
    ^bb0(%clk: !seq.clock, %reset: i1, %data_in : i8, %addr : i2):
      %mem = "seq.firmem"() {name = "memory", depth = 4 : i64, width = 8 : i64, readLatency = 0 : i32, writeLatency = 1 : i32,ruw = 0 : i32, wuw = 1 : i32} : () -> !seq.firmem<4 x 8>

      %enable = "hw.constant"() {value = 1 : i1} : () -> i1
      %writemode = "hw.constant"() {value = 1 : i1} : () -> i1
      %readmode = "hw.constant"() {value = 0 : i1} : () -> i1

      %read_data = "seq.firmem.read_port"(%mem, %addr, %clk, %enable) : (!seq.firmem<4 x 8>, i2, !seq.clock, i1) -> i8

      "seq.firmem.write_port"(%mem, %addr, %clk,%enable,%data_in) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<4 x 8>, i2,!seq.clock, i1, i8) -> ()

      %read_write_data = "seq.firmem.read_write_port"(%mem, %addr, %clk, %enable, %data_in, %readmode) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<4 x 8>, i2, !seq.clock, i1, i8, i1) -> i8

      "hw.output"(%read_data, %read_write_data) : (i8, i8) -> ()
  }) {module_type = !hw.modty<input clk : !seq.clock, input reset : i1,input data_in : i8,input addr : i2, output read_out : i8, output rw_out : i8>, sym_name = "Foo", parameters = []} : () -> ()
}) : () -> ()
