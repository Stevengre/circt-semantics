"builtin.module"() ({
  "hw.module"() ({
    ^bb0(%clk: !seq.clock, %data_in_w: i8, %addr: i2):
      %addr = "hw.constant"() {value = 0 : i1} : () -> i1
      %mem1 = "seq.firmem"() {name = "memory1", depth = 4 : i64, width = 8 : i64, readLatency = 1 : i32, writeLatency = 1 : i32,ruw = 0 : i32, wuw = 1 : i32} : () -> !seq.firmem<4 x 8>
      %mem1_addr = "seq.firmem"() {name = "memory1_addr", depth = 1 : i64, width = 4 : i64, readLatency = 1 : i32, writeLatency = 1 : i32,ruw = 0 : i32, wuw = 1 : i32} : () -> !seq.firmem<1 x 4>
      %mem2 = "seq.firmem"() {name = "memory2", depth = 4 : i64, width = 8 : i64, readLatency = 0 : i32, writeLatency = 1 : i32,ruw = 0 : i32, wuw = 1 : i32} : () -> !seq.firmem<4 x 8>
      %mem2_addr = "seq.firmem"() {name = "memory2_addr", depth = 1 : i64, width = 4 : i64, readLatency = 0 : i32, writeLatency = 1 : i32,ruw = 0 : i32, wuw = 1 : i32} : () -> !seq.firmem<1 x 4>
      %mem3 = "seq.firmem"() {name = "memory3", depth = 4 : i64, width = 8 : i64, readLatency = 0 : i32, writeLatency = 1 : i32,ruw = 0 : i32, wuw = 1 : i32} : () -> !seq.firmem<4 x 8>
      %mem3_addr = "seq.firmem"() {name = "memory3_addr", depth = 1 : i64, width = 4 : i64, readLatency = 0 : i32, writeLatency = 1 : i32,ruw = 0 : i32, wuw = 1 : i32} : () -> !seq.firmem<1 x 4>
      %mem4 = "seq.firmem"() {name = "memory4", depth = 4 : i64, width = 8 : i64, readLatency = 1 : i32, writeLatency = 1 : i32,ruw = 0 : i32, wuw = 1 : i32} : () -> !seq.firmem<4 x 8>

      %enable = "hw.constant"() {value = 1 : i1} : () -> i1
      "seq.firmem.write_port"(%mem1, %addr, %clk, %enable, %data_in_w) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<1 x 8>, i1,!seq.clock, i1, i8) -> ()
      %read1 = "seq.firmem.read_port"(%mem1, %addr, %clk, %enable) : (!seq.firmem<1 x 8>, i1, !seq.clock, i1) -> i8

      "seq.firmem.write_port"(%mem2, %addr, %clk, %enable, %read1) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<1 x 8>, i1,!seq.clock, i1, i8) -> ()
      %read2 = "seq.firmem.read_port"(%mem2, %addr, %clk, %enable) : (!seq.firmem<1 x 8>, i1, !seq.clock, i1) -> i8

      "seq.firmem.write_port"(%mem3, %addr, %clk, %enable, %read2) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<1 x 8>, i1,!seq.clock, i1, i8) -> ()
      %read3 = "seq.firmem.read_port"(%mem3, %addr, %clk, %enable) : (!seq.firmem<1 x 8>, i1, !seq.clock, i1) -> i8

      "seq.firmem.write_port"(%mem4, %addr, %clk, %enable, %read3) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<1 x 8>, i1,!seq.clock, i1, i8) -> ()
      %read4 = "seq.firmem.read_port"(%mem4, %addr, %clk, %enable) : (!seq.firmem<1 x 8>, i1, !seq.clock, i1) -> i8
      "hw.output"(%read1, %read2, %read3, %read4) : (i8, i8, i8, i8) -> ()
  }) {module_type = !hw.modty<input clk : !seq.clock, input data_in_w : i8, output read1 : i8, output read2 : i8, output read3 : i8, output read4 : i8>, sym_name = "Foo", parameters = []} : () -> ()
}) : () -> ()
