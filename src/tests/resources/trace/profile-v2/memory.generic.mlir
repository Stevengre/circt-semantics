"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input clk : i1, input enable : i1, input address : i2, input data : i8, input read_address : i2, output result : i8>, parameters = [], sym_name = "ProfileMemory"}> ({
  ^bb0(%clk: i1, %enable: i1, %address: i2, %data: i8, %read_address: i2):
    %clock = "seq.to_clock"(%clk) : (i1) -> !seq.clock
    %mem = "seq.firmem"() <{name = "memory", readLatency = 0 : i32, writeLatency = 1 : i32, ruw = 0 : i32, wuw = 1 : i32}> : () -> !seq.firmem<4 x 8>
    %read = "seq.firmem.read_port"(%mem, %read_address, %clock) : (!seq.firmem<4 x 8>, i2, !seq.clock) -> i8
    "seq.firmem.write_port"(%mem, %address, %clock, %enable, %data) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<4 x 8>, i2, !seq.clock, i1, i8) -> ()
    "hw.output"(%read) : (i8) -> ()
  }) : () -> ()
}) : () -> ()
