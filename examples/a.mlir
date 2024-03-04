#loc = loc("a.mlir":1:33)
#loc1 = loc("a.mlir":1:57)
#loc2 = loc("a.mlir":1:77)
#loc3 = loc("a.mlir":1:98)
#loc4 = loc("a.mlir":1:119)
#loc5 = loc("a.mlir":1:139)
#loc6 = loc("a.mlir":1:156)
#loc7 = loc("a.mlir":1:175)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: !seq.clock, %arg1: i5, %arg2: i5, %arg3: i1, %arg4: i5, %arg5: i32):
    %0 = "hw.constant"() {value = 0 : i5} : () -> i5
    %1 = "hw.constant"() {value = 0 : i32} : () -> i32
    %2 = "seq.firmem"() <{name = "regs", prefix = "", readLatency = 0 : i32, ruw = 0 : i32, writeLatency = 1 : i32, wuw = 1 : i32}> : () -> !seq.firmem<32 x 32>
    "seq.firmem.write_port"(%2, %arg4, %arg0, %10, %arg5) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<32 x 32>, i5, !seq.clock, i1, i32) -> ()
    %3 = "seq.firmem.read_port"(%2, %arg1, %arg0) : (!seq.firmem<32 x 32>, i5, !seq.clock) -> i32
    %4 = "seq.firmem.read_port"(%2, %arg2, %arg0) : (!seq.firmem<32 x 32>, i5, !seq.clock) -> i32
    %5 = "comb.icmp"(%arg1, %0) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_rdata1_T"} : (i5, i5) -> i1
    %6 = "comb.mux"(%5, %3, %1) <{twoState}> {sv.namehint = "io_rdata1"} : (i1, i32, i32) -> i32
    %7 = "comb.icmp"(%arg2, %0) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_rdata2_T"} : (i5, i5) -> i1
    %8 = "comb.mux"(%7, %4, %1) <{twoState}> {sv.namehint = "io_rdata2"} : (i1, i32, i32) -> i32
    %9 = "comb.icmp"(%arg4, %0) <{predicate = 1 : i64, twoState}> : (i5, i5) -> i1
    %10 = "comb.and"(%arg3, %9) <{twoState}> : (i1, i1) -> i1
    "hw.output"(%6, %8) : (i32, i32) -> ()
  }) {module_type = !hw.modty<input clock : !seq.clock, input io_raddr1 : i5, input io_raddr2 : i5, output io_rdata1 : i32, output io_rdata2 : i32, input io_wen : i1, input io_waddr : i5, input io_wdata : i32>, parameters = [], port_locs = [#loc, #loc1, #loc2, #loc3, #loc4, #loc5, #loc6, #loc7], sym_name = "RegFile", sym_visibility = "private"} : () -> ()
}) : () -> ()