"builtin.module"() ({
  "hw.module"() ({
    ^bb0(%clk: !seq.clock, %data_in_w: i8, %data_in_rw : i8, %addr_r : i2, %addr_w : i2, %addr_rw : i2, %mode : i1, %enable_r : i1,%enable_w : i1, %enable_rw : i1):
      %mem = "seq.firmem"() <{name = "memory", depth = 4 : i64, width = 8 : i64, readLatency = 1 : i32, writeLatency = 1 : i32,ruw = 0 : i32, wuw = 1 : i32}> : () -> !seq.firmem<4 x 8>

      %writemode = "hw.constant"() {value = 1 : i1} : () -> i1
      %readmode = "hw.constant"() {value = 0 : i1} : () -> i1

      %read_data = "seq.firmem.read_port"(%mem, %addr_r, %clk, %enable_r) : (!seq.firmem<4 x 8>, i2, !seq.clock, i1) -> i8

      "seq.firmem.write_port"(%mem, %addr_w, %clk,%enable_w,%data_in_w) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<4 x 8>, i2,!seq.clock, i1, i8) -> ()

      "hw.output"(%read_data) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : !seq.clock, input data_in_w : i8,input data_in_rw : i8,input addr_r : i2,input addr_w : i2,input addr_rw : i2,input mode : i1,input enable_r : i1,input enable_w : i1,input enable_rw : i1, output read_out : i8>, sym_name = "Foo", parameters = []} : () -> ()
}) : () -> ()
