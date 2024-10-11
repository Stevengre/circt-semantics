seq.firmem.read_write_port
```mlir
#loc = loc("foo.mlir":1:41)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%clk: !seq.clock):
    %mem = "seq.firmem"() <{name = "mem", prefix = "", readLatency = 1 : i32, ruw = 0 : i32, writeLatency = 1 : i32, wuw = 1 : i32}> : () -> !seq.firmem<512 x 8>
    %addr = "hw.constant"() {value = 9 : i9} : () -> i9
    %data = "hw.constant"() {value = 2 : i8} : () -> i8
    %enable = "hw.constant"() {value = true} : () -> i1
    %mode = "hw.constant"() {value = true} : () -> i1
    %out = "seq.firmem.read_write_port"(%mem, %addr, %clk, %enable, %data, %mode) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<512 x 8>, i9, !seq.clock, i1, i8, i1) -> i8
    "hw.output"(%out) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : !seq.clock, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```