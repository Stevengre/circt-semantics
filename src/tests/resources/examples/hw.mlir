#loc = loc("basic.mlir":4:21)
#loc1 = loc("basic.mlir":4:35)
#loc2 = loc("basic.mlir":4:49)
#loc3 = loc("basic.mlir":4:80)
#loc4 = loc("basic.mlir":148:24)
#loc5 = loc("basic.mlir":148:61)
#loc6 = loc("basic.mlir":148:72)
#loc7 = loc("basic.mlir":160:29)
#loc8 = loc("basic.mlir":160:45)
#loc9 = loc("basic.mlir":177:28)
#loc10 = loc("basic.mlir":185:26)
#loc11 = loc("basic.mlir":188:28)
#loc12 = loc("basic.mlir":196:19)
#loc13 = loc("basic.mlir":196:37)
#loc14 = loc("basic.mlir":196:53)
#loc15 = loc("basic.mlir":196:66)
#loc16 = loc("basic.mlir":200:19)
#loc17 = loc("basic.mlir":200:34)
#loc18 = loc("basic.mlir":200:47)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i3, %arg1: i1, %arg2: !hw.array<8xi8>):
    %0 = "hw.constant"() {value = 42 : i12} : () -> i12
    %1 = "comb.add"(%0, %0) : (i12, i12) -> i12
    %2 = "comb.mul"(%0, %1) : (i12, i12) -> i12
    %3 = "comb.concat"(%arg0, %arg0, %arg1) : (i3, i3, i1) -> i7
    %4 = "comb.concat"(%0) : (i12) -> i12
    %5 = "comb.parity"(%4) : (i12) -> i1
    %6 = "comb.concat"(%4, %1, %2, %3, %3) : (i12, i12, i12, i7, i7) -> i50
    %7 = "comb.extract"(%6) {lowBit = 4 : i32} : (i50) -> i19
    %8 = "comb.extract"(%6) {lowBit = 31 : i32} : (i50) -> i19
    %9 = "comb.add"(%7, %8) : (i19, i19) -> i19
    %10 = "comb.icmp"(%7, %8) {predicate = 0 : i64} : (i19, i19) -> i1
    %11 = "comb.icmp"(%7, %8) {predicate = 1 : i64} : (i19, i19) -> i1
    %12 = "comb.icmp"(%7, %8) {predicate = 2 : i64} : (i19, i19) -> i1
    %13 = "comb.icmp"(%7, %8) {predicate = 6 : i64} : (i19, i19) -> i1
    %14 = "comb.icmp"(%7, %8) {predicate = 3 : i64} : (i19, i19) -> i1
    %15 = "comb.icmp"(%7, %8) {predicate = 7 : i64} : (i19, i19) -> i1
    %16 = "comb.icmp"(%7, %8) {predicate = 4 : i64} : (i19, i19) -> i1
    %17 = "comb.icmp"(%7, %8) {predicate = 8 : i64} : (i19, i19) -> i1
    %18 = "comb.icmp"(%7, %8) {predicate = 5 : i64} : (i19, i19) -> i1
    %19 = "comb.icmp"(%7, %8) {predicate = 9 : i64} : (i19, i19) -> i1
    %20 = "sv.wire"() {name = "w"} : () -> !hw.inout<i4>
    %21 = "sv.wire"() {name = "after1"} : () -> !hw.inout<i4>
    %22 = "sv.read_inout"(%21) : (!hw.inout<i4>) -> i4
    %23 = "sv.wire"() {name = "after2_conflict"} : () -> !hw.inout<i4>
    %24 = "sv.wire"() {name = "after2_conflict"} : () -> !hw.inout<i4>
    %25 = "sv.wire"() {name = "after3", someAttr = "foo"} : () -> !hw.inout<i4>
    %26 = "hw.wire"(%3) {name = "w2"} : (i7) -> i7
    %27 = "hw.wire"(%3) {name = "after4"} : (i7) -> i7
    %28 = "hw.wire"(%3) {name = "after5_conflict"} : (i7) -> i7
    %29 = "hw.wire"(%3) {name = "after5_conflict"} : (i7) -> i7
    %30 = "hw.wire"(%3) {name = "after6", someAttr = "foo"} : (i7) -> i7
    %31 = "comb.mux"(%arg1, %3, %3) : (i1, i7, i7) -> i7
    %32 = "hw.struct_create"(%7, %31) : (i19, i7) -> !hw.struct<foo: i19, bar: i7>
    %33 = "hw.struct_extract"(%32) {fieldIndex = 0 : i32} : (!hw.struct<foo: i19, bar: i7>) -> i19
    %34 = "hw.struct_inject"(%32, %33) {fieldIndex = 0 : i32} : (!hw.struct<foo: i19, bar: i7>, i19) -> !hw.struct<foo: i19, bar: i7>
    %35:2 = "hw.struct_explode"(%32) : (!hw.struct<foo: i19, bar: i7>) -> (i19, i7)
    %36 = "hw.bitcast"(%32) : (!hw.struct<foo: i19, bar: i7>) -> i26
    %37 = "hw.constant"() {value = 3 : i10} : () -> i10
    %38 = "hw.array_slice"(%arg2, %37) : (!hw.array<8xi8>, i10) -> !hw.array<4xi8>
    %39 = "hw.array_create"(%7, %8) : (i19, i19) -> !hw.array<2xi19>
    %40 = "hw.array_create"(%7, %8, %9) : (i19, i19, i19) -> !hw.array<3xi19>
    %41 = "hw.array_concat"(%39, %40) : (!hw.array<2xi19>, !hw.array<3xi19>) -> !hw.array<5xi19>
    %42 = "hw.enum.constant"() {field = #hw.enum.field<A, !hw.enum<A, B, C>>} : () -> !hw.enum<A, B, C>
    %43 = "hw.enum.constant"() {field = #hw.enum.field<B, !hw.enum<A, B, C>>} : () -> !hw.enum<A, B, C>
    %44 = "hw.enum.cmp"(%42, %43) : (!hw.enum<A, B, C>, !hw.enum<A, B, C>) -> i1
    %45 = "hw.aggregate_constant"() {fields = [false, true]} : () -> !hw.struct<a: i1, b: i1>
    %46 = "hw.aggregate_constant"() {fields = [0 : i2, 1 : i2, -2 : i2, -1 : i2]} : () -> !hw.array<4xi2>
    %47 = "hw.aggregate_constant"() {fields = [false]} : () -> !hw.array<1xi1>
    %48 = "hw.aggregate_constant"() {fields = [[false]]} : () -> !hw.struct<a: !hw.array<1xi1>>
    %49 = "hw.aggregate_constant"() {fields = ["A"]} : () -> !hw.struct<a: !hw.enum<A, B, C>>
    %50 = "hw.aggregate_constant"() {fields = ["A"]} : () -> !hw.array<1xenum<A, B, C>>
    "hw.output"(%6) : (i50) -> ()
  }) {parameters = [], port_locs = [#loc, #loc1, #loc2, #loc3], sym_name = "test1"} : () -> ()
  
}) : () -> ()
