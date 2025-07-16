#loc = loc("test.mlir":2:50)
#loc1 = loc("test.mlir":7:69)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "hw.constant"() {value = 1 : i8} : () -> i8
    %1 = "comb.add"(%arg0, %0) {sv.namehint = "_out_T"} : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input io_a : i8, output res2 : i8>, parameters = [], result_locs = [#loc], sym_name = "AddOne", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: !seq.clock, %arg1: i8, %arg2: i8):
    %0 = "hw.constant"() {value = false} : () -> i1
    %1 = "hw.constant"() {value = true} : () -> i1
    %2 = "hw.constant"() {value = 1 : i2} : () -> i2
    %3 = "hw.constant"() {value = true} : () -> i1
    %4 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    %5 = "comb.and"(%arg1, %arg2) : (i8, i8) -> i8
    %6 = "comb.concat"(%arg1, %arg2) : (i8, i8) -> i16
    %7 = "comb.divs"(%arg1, %arg2) : (i8, i8) -> i8
    %8 = "comb.extract"(%arg1) <{lowBit = 3 : i32}> : (i8) -> i4
    %9 = "comb.icmp"(%arg1, %arg2) <{predicate = 0 : i64, twoState}> : (i8, i8) -> i1
    %10 = "comb.mux"(%0, %arg1, %arg2) : (i1, i8, i8) -> i8
    %11 = "comb.parity"(%arg1) : (i8) -> i1
    %12 = "comb.replicate"(%arg1) : (i8) -> i16
    %13 = "hw.aggregate_constant"() {fields = [-1 : i8, 0 : i8, 1 : i8, 2 : i8]} : () -> !hw.array<4xi8>
    %14 = "hw.array_create"(%arg1) : (i8) -> !hw.array<1xi8>
    %15 = "hw.array_create"(%arg2) : (i8) -> !hw.array<1xi8>
    %16 = "hw.array_concat"(%14, %15) : (!hw.array<1xi8>, !hw.array<1xi8>) -> !hw.array<2xi8>
    %17 = "hw.array_get"(%16, %0) : (!hw.array<2xi8>, i1) -> i8
    %18 = "hw.instance"(%arg1) {argNames = ["io_a"], instanceName = "i0", moduleName = @AddOne, parameters = [], resultNames = ["res2"]} : (i8) -> i8
    %19 = "seq.from_clock"(%arg0) : (!seq.clock) -> i1
    %20 = "seq.firreg"(%5, %arg0, %0, %7) <{name = "a_first_counter"}> {firrtl.random_init_start = 0 : ui64} : (i8, !seq.clock, i1, i8) -> i8
    %21 = "seq.firmem"() <{name = "ram", prefix = "", readLatency = 0 : i32, ruw = 0 : i32, writeLatency = 1 : i32, wuw = 1 : i32}> : () -> !seq.firmem<4 x 8>
    "seq.firmem.write_port"(%21, %2, %arg0, %1, %10) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<4 x 8>, i2, !seq.clock, i1, i8) -> ()
    "seq.firmem.write_port"(%21, %2, %arg0, %1, %5) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<4 x 8>, i2, !seq.clock, i1, i8) -> ()
    %22 = "seq.firmem.read_port"(%21, %2, %arg0) : (!seq.firmem<4 x 8>, i2, !seq.clock) -> i8
    %23 = "seq.firmem.read_write_port"(%21, %2, %arg0, %1, %4, %3) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 1, 0>}> {sv.namehint = "data11111"} : (!seq.firmem<4 x 8>, i2, !seq.clock, i1, i8, i1) -> i8
    "sv.always"(%19) ({
      "sv.if"(%1) ({
        "sv.info"() {message = "hitIf"} : () -> ()
      }, {
      }) : (i1) -> ()
    }) {events = [0 : i32]} : (i1) -> ()
    "hw.output"(%23) : (i8) -> ()
  }) {module_type = !hw.modty<input clock : !seq.clock, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc1], sym_name = "Foo"} : () -> ()
}) : () -> ()

