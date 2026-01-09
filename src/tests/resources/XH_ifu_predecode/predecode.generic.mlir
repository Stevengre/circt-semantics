#loc = loc("predecode.mlir":1:534)
#loc1 = loc("predecode.mlir":1:562)
#loc2 = loc("predecode.mlir":1:590)
#loc3 = loc("predecode.mlir":1:618)
#loc4 = loc("predecode.mlir":1:646)
#loc5 = loc("predecode.mlir":1:674)
#loc6 = loc("predecode.mlir":1:702)
#loc7 = loc("predecode.mlir":1:730)
#loc8 = loc("predecode.mlir":1:758)
#loc9 = loc("predecode.mlir":1:786)
#loc10 = loc("predecode.mlir":1:814)
#loc11 = loc("predecode.mlir":1:842)
#loc12 = loc("predecode.mlir":1:870)
#loc13 = loc("predecode.mlir":1:898)
#loc14 = loc("predecode.mlir":1:926)
#loc15 = loc("predecode.mlir":1:954)
#loc16 = loc("predecode.mlir":1:982)
#loc17 = loc("predecode.mlir":1:1010)
#loc18 = loc("predecode.mlir":1:1038)
#loc19 = loc("predecode.mlir":1:1066)
#loc20 = loc("predecode.mlir":1:1095)
#loc21 = loc("predecode.mlir":1:1124)
#loc22 = loc("predecode.mlir":1:1153)
#loc23 = loc("predecode.mlir":1:1182)
#loc24 = loc("predecode.mlir":1:1211)
#loc25 = loc("predecode.mlir":1:1240)
#loc26 = loc("predecode.mlir":1:1269)
#loc27 = loc("predecode.mlir":1:1298)
#loc28 = loc("predecode.mlir":1:1327)
#loc29 = loc("predecode.mlir":1:1356)
#loc30 = loc("predecode.mlir":1:1385)
#loc31 = loc("predecode.mlir":1:1414)
#loc32 = loc("predecode.mlir":1:1446)
#loc33 = loc("predecode.mlir":1:1478)
#loc34 = loc("predecode.mlir":1:1510)
#loc35 = loc("predecode.mlir":1:1542)
#loc36 = loc("predecode.mlir":1:1574)
#loc37 = loc("predecode.mlir":1:1606)
#loc38 = loc("predecode.mlir":1:1638)
#loc39 = loc("predecode.mlir":1:1670)
#loc40 = loc("predecode.mlir":1:1703)
#loc41 = loc("predecode.mlir":1:1736)
#loc42 = loc("predecode.mlir":1:1769)
#loc43 = loc("predecode.mlir":1:1802)
#loc44 = loc("predecode.mlir":1:1835)
#loc45 = loc("predecode.mlir":1:1868)
#loc46 = loc("predecode.mlir":1:1894)
#loc47 = loc("predecode.mlir":1:1920)
#loc48 = loc("predecode.mlir":1:1946)
#loc49 = loc("predecode.mlir":1:1972)
#loc50 = loc("predecode.mlir":1:1998)
#loc51 = loc("predecode.mlir":1:2024)
#loc52 = loc("predecode.mlir":1:2050)
#loc53 = loc("predecode.mlir":1:2076)
#loc54 = loc("predecode.mlir":1:2102)
#loc55 = loc("predecode.mlir":1:2128)
#loc56 = loc("predecode.mlir":1:2155)
#loc57 = loc("predecode.mlir":1:2182)
#loc58 = loc("predecode.mlir":1:2209)
#loc59 = loc("predecode.mlir":1:2236)
#loc60 = loc("predecode.mlir":1:2263)
#loc61 = loc("predecode.mlir":1:2290)
#loc62 = loc("predecode.mlir":1:2321)
#loc63 = loc("predecode.mlir":1:2352)
#loc64 = loc("predecode.mlir":1:2383)
#loc65 = loc("predecode.mlir":1:2414)
#loc66 = loc("predecode.mlir":1:2445)
#loc67 = loc("predecode.mlir":1:2476)
#loc68 = loc("predecode.mlir":1:2507)
#loc69 = loc("predecode.mlir":1:2538)
#loc70 = loc("predecode.mlir":1:2569)
#loc71 = loc("predecode.mlir":1:2600)
#loc72 = loc("predecode.mlir":1:2632)
#loc73 = loc("predecode.mlir":1:2664)
#loc74 = loc("predecode.mlir":1:2696)
#loc75 = loc("predecode.mlir":1:2728)
#loc76 = loc("predecode.mlir":1:2760)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i16, %arg1: i16, %arg2: i16, %arg3: i16, %arg4: i16, %arg5: i16, %arg6: i16, %arg7: i16, %arg8: i16, %arg9: i16, %arg10: i16, %arg11: i16, %arg12: i16, %arg13: i16, %arg14: i16, %arg15: i16, %arg16: i16):
    %0 = "hw.constant"() {value = -29 : i7} : () -> i7
    %1 = "hw.constant"() {value = 103 : i10} : () -> i10
    %2 = "hw.constant"() {value = -17 : i7} : () -> i7
    %3 = "hw.constant"() {value = -3 : i4} : () -> i4
    %4 = "hw.constant"() {value = -510 : i10} : () -> i10
    %5 = "hw.constant"() {value = -11 : i5} : () -> i5
    %6 = "hw.constant"() {value = -16382 : i15} : () -> i15
    %7 = "hw.constant"() {value = -1 : i2} : () -> i2
    %8 = "hw.constant"() {value = -2 : i2} : () -> i2
    %9 = "hw.constant"() {value = false} : () -> i1
    %10 = "hw.constant"() {value = true} : () -> i1
    %11 = "hw.constant"() {value = 1 : i2} : () -> i2
    %12 = "hw.constant"() {value = 0 : i2} : () -> i2
    %13 = "comb.concat"(%arg1, %arg0) {sv.namehint = "inst"} : (i16, i16) -> i32
    %14 = "comb.concat"(%arg2, %arg1) {sv.namehint = "inst_1"} : (i16, i16) -> i32
    %15 = "comb.concat"(%arg3, %arg2) {sv.namehint = "inst_2"} : (i16, i16) -> i32
    %16 = "comb.concat"(%arg4, %arg3) {sv.namehint = "inst_3"} : (i16, i16) -> i32
    %17 = "comb.concat"(%arg5, %arg4) {sv.namehint = "inst_4"} : (i16, i16) -> i32
    %18 = "comb.concat"(%arg6, %arg5) {sv.namehint = "inst_5"} : (i16, i16) -> i32
    %19 = "comb.concat"(%arg7, %arg6) {sv.namehint = "inst_6"} : (i16, i16) -> i32
    %20 = "comb.concat"(%arg8, %arg7) {sv.namehint = "inst_7"} : (i16, i16) -> i32
    %21 = "comb.concat"(%arg9, %arg8) {sv.namehint = "inst_8"} : (i16, i16) -> i32
    %22 = "comb.concat"(%arg10, %arg9) {sv.namehint = "inst_9"} : (i16, i16) -> i32
    %23 = "comb.concat"(%arg11, %arg10) {sv.namehint = "inst_10"} : (i16, i16) -> i32
    %24 = "comb.concat"(%arg12, %arg11) {sv.namehint = "inst_11"} : (i16, i16) -> i32
    %25 = "comb.concat"(%arg13, %arg12) {sv.namehint = "inst_12"} : (i16, i16) -> i32
    %26 = "comb.concat"(%arg14, %arg13) {sv.namehint = "inst_13"} : (i16, i16) -> i32
    %27 = "comb.concat"(%arg15, %arg14) {sv.namehint = "inst_14"} : (i16, i16) -> i32
    %28 = "comb.concat"(%arg16, %arg15) {sv.namehint = "inst_15"} : (i16, i16) -> i32
    %29 = "comb.extract"(%arg0) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_1"} : (i16) -> i2
    %30 = "comb.icmp"(%29, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_0"} : (i2, i2) -> i1
    %31 = "comb.extract"(%arg0) <{lowBit = 13 : i32}> : (i16) -> i3
    %32 = "comb.extract"(%arg0) <{lowBit = 0 : i32}> : (i16) -> i12
    %33 = "comb.concat"(%31, %32) : (i3, i12) -> i15
    %34 = "comb.icmp"(%33, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_1"} : (i15, i15) -> i1
    %35 = "comb.extract"(%arg0) <{lowBit = 13 : i32}> : (i16) -> i3
    %36 = "comb.extract"(%arg0) <{lowBit = 0 : i32}> : (i16) -> i2
    %37 = "comb.concat"(%35, %36) : (i3, i2) -> i5
    %38 = "comb.icmp"(%37, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_3"} : (i5, i5) -> i1
    %39 = "comb.extract"(%arg0) <{lowBit = 13 : i32}> : (i16) -> i3
    %40 = "comb.extract"(%arg0) <{lowBit = 0 : i32}> : (i16) -> i7
    %41 = "comb.concat"(%39, %40) : (i3, i7) -> i10
    %42 = "comb.icmp"(%41, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_5"} : (i10, i10) -> i1
    %43 = "comb.extract"(%arg0) <{lowBit = 14 : i32}> : (i16) -> i2
    %44 = "comb.extract"(%arg0) <{lowBit = 0 : i32}> : (i16) -> i2
    %45 = "comb.concat"(%43, %44) : (i2, i2) -> i4
    %46 = "comb.icmp"(%45, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_7"} : (i4, i4) -> i1
    %47 = "comb.extract"(%arg0) <{lowBit = 0 : i32}> : (i16) -> i7
    %48 = "comb.icmp"(%47, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_9"} : (i7, i7) -> i1
    %49 = "comb.extract"(%arg0) <{lowBit = 12 : i32}> : (i16) -> i3
    %50 = "comb.extract"(%arg0) <{lowBit = 0 : i32}> : (i16) -> i7
    %51 = "comb.concat"(%49, %50) : (i3, i7) -> i10
    %52 = "comb.icmp"(%51, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_11"} : (i10, i10) -> i1
    %53 = "comb.icmp"(%47, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_14"} : (i7, i7) -> i1
    %54 = "comb.concat"(%9, %53) : (i1, i1) -> i2
    %55 = "comb.mux"(%52, %7, %54) <{twoState}> {sv.namehint = "_brType_T_15"} : (i1, i2, i2) -> i2
    %56 = "comb.mux"(%48, %8, %55) <{twoState}> {sv.namehint = "_brType_T_16"} : (i1, i2, i2) -> i2
    %57 = "comb.mux"(%46, %11, %56) <{twoState}> {sv.namehint = "_brType_T_17"} : (i1, i2, i2) -> i2
    %58 = "comb.mux"(%42, %7, %57) <{twoState}> {sv.namehint = "_brType_T_18"} : (i1, i2, i2) -> i2
    %59 = "comb.mux"(%38, %8, %58) <{twoState}> {sv.namehint = "_brType_T_19"} : (i1, i2, i2) -> i2
    %60 = "comb.mux"(%34, %12, %59) <{twoState}> {sv.namehint = "brType"} : (i1, i2, i2) -> i2
    %61 = "comb.extract"(%arg0) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T"} : (i16) -> i1
    %62 = "comb.extract"(%arg0) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_1"} : (i16) -> i1
    %63 = "comb.extract"(%arg0) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_2"} : (i16) -> i2
    %64 = "comb.extract"(%arg0) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_3"} : (i16) -> i1
    %65 = "comb.extract"(%arg0) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_1"} : (i16) -> i1
    %66 = "comb.extract"(%arg0) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_2"} : (i16) -> i1
    %67 = "comb.extract"(%arg0) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_6"} : (i16) -> i1
    %68 = "comb.extract"(%arg0) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_7"} : (i16) -> i3
    %69 = "comb.extract"(%arg1) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T"} : (i16) -> i1
    %70 = "comb.extract"(%arg0) <{lowBit = 12 : i32}> : (i16) -> i4
    %71 = "comb.extract"(%arg1) <{lowBit = 0 : i32}> : (i16) -> i4
    %72 = "comb.extract"(%arg1) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_2"} : (i16) -> i1
    %73 = "comb.extract"(%arg1) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_3"} : (i16) -> i10
    %74 = "comb.replicate"(%61) : (i1) -> i10
    %75 = "comb.concat"(%74, %62, %63, %64, %65, %66, %67, %68) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %76 = "comb.concat"(%69, %71, %70, %72, %73) : (i1, i4, i4, i1, i10) -> i20
    %77 = "comb.mux"(%30, %75, %76) <{twoState}> : (i1, i20, i20) -> i20
    %78 = "comb.extract"(%77) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_2"} : (i20) -> i1
    %79 = "comb.extract"(%arg0) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_1"} : (i16) -> i2
    %80 = "comb.extract"(%arg0) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_3"} : (i16) -> i2
    %81 = "comb.extract"(%arg0) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_4"} : (i16) -> i2
    %82 = "comb.extract"(%arg1) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_2"} : (i16) -> i6
    %83 = "comb.extract"(%arg0) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_3"} : (i16) -> i4
    %84 = "comb.replicate"(%61) : (i1) -> i5
    %85 = "comb.concat"(%84, %79, %66, %80, %81) : (i5, i2, i1, i2, i2) -> i12
    %86 = "comb.concat"(%69, %65, %82, %83) : (i1, i1, i6, i4) -> i12
    %87 = "comb.mux"(%30, %85, %86) <{twoState}> : (i1, i12, i12) -> i12
    %88 = "comb.extract"(%87) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_2"} : (i12) -> i1
    %89 = "comb.icmp"(%60, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_0_T"} : (i2, i2) -> i1
    %90 = "comb.replicate"(%88) : (i1) -> i51
    %91 = "comb.concat"(%90, %87) : (i51, i12) -> i63
    %92 = "comb.replicate"(%78) : (i1) -> i43
    %93 = "comb.concat"(%92, %77) : (i43, i20) -> i63
    %94 = "comb.mux"(%89, %91, %93) <{twoState}> : (i1, i63, i63) -> i63
    %95 = "comb.concat"(%94, %9) {sv.namehint = "io_out_jumpOffset_0"} : (i63, i1) -> i64
    %96 = "comb.extract"(%arg1) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_11"} : (i16) -> i2
    %97 = "comb.icmp"(%96, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_1"} : (i2, i2) -> i1
    %98 = "comb.extract"(%arg1) <{lowBit = 13 : i32}> : (i16) -> i3
    %99 = "comb.extract"(%arg1) <{lowBit = 0 : i32}> : (i16) -> i12
    %100 = "comb.concat"(%98, %99) : (i3, i12) -> i15
    %101 = "comb.icmp"(%100, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_21"} : (i15, i15) -> i1
    %102 = "comb.extract"(%arg1) <{lowBit = 13 : i32}> : (i16) -> i3
    %103 = "comb.extract"(%arg1) <{lowBit = 0 : i32}> : (i16) -> i2
    %104 = "comb.concat"(%102, %103) : (i3, i2) -> i5
    %105 = "comb.icmp"(%104, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_23"} : (i5, i5) -> i1
    %106 = "comb.extract"(%arg1) <{lowBit = 13 : i32}> : (i16) -> i3
    %107 = "comb.extract"(%arg1) <{lowBit = 0 : i32}> : (i16) -> i7
    %108 = "comb.concat"(%106, %107) : (i3, i7) -> i10
    %109 = "comb.icmp"(%108, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_25"} : (i10, i10) -> i1
    %110 = "comb.extract"(%arg1) <{lowBit = 14 : i32}> : (i16) -> i2
    %111 = "comb.extract"(%arg1) <{lowBit = 0 : i32}> : (i16) -> i2
    %112 = "comb.concat"(%110, %111) : (i2, i2) -> i4
    %113 = "comb.icmp"(%112, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_27"} : (i4, i4) -> i1
    %114 = "comb.extract"(%arg1) <{lowBit = 0 : i32}> : (i16) -> i7
    %115 = "comb.icmp"(%114, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_29"} : (i7, i7) -> i1
    %116 = "comb.extract"(%arg1) <{lowBit = 12 : i32}> : (i16) -> i3
    %117 = "comb.extract"(%arg1) <{lowBit = 0 : i32}> : (i16) -> i7
    %118 = "comb.concat"(%116, %117) : (i3, i7) -> i10
    %119 = "comb.icmp"(%118, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_31"} : (i10, i10) -> i1
    %120 = "comb.icmp"(%114, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_34"} : (i7, i7) -> i1
    %121 = "comb.concat"(%9, %120) : (i1, i1) -> i2
    %122 = "comb.mux"(%119, %7, %121) <{twoState}> {sv.namehint = "_brType_T_35"} : (i1, i2, i2) -> i2
    %123 = "comb.mux"(%115, %8, %122) <{twoState}> {sv.namehint = "_brType_T_36"} : (i1, i2, i2) -> i2
    %124 = "comb.mux"(%113, %11, %123) <{twoState}> {sv.namehint = "_brType_T_37"} : (i1, i2, i2) -> i2
    %125 = "comb.mux"(%109, %7, %124) <{twoState}> {sv.namehint = "_brType_T_38"} : (i1, i2, i2) -> i2
    %126 = "comb.mux"(%105, %8, %125) <{twoState}> {sv.namehint = "_brType_T_39"} : (i1, i2, i2) -> i2
    %127 = "comb.mux"(%101, %12, %126) <{twoState}> {sv.namehint = "brType_1"} : (i1, i2, i2) -> i2
    %128 = "comb.extract"(%arg1) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_5"} : (i16) -> i1
    %129 = "comb.extract"(%arg1) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_9"} : (i16) -> i1
    %130 = "comb.extract"(%arg1) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_10"} : (i16) -> i2
    %131 = "comb.extract"(%arg1) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_11"} : (i16) -> i1
    %132 = "comb.extract"(%arg1) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_5"} : (i16) -> i1
    %133 = "comb.extract"(%arg1) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_7"} : (i16) -> i1
    %134 = "comb.extract"(%arg1) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_14"} : (i16) -> i1
    %135 = "comb.extract"(%arg1) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_15"} : (i16) -> i3
    %136 = "comb.extract"(%arg2) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_4"} : (i16) -> i1
    %137 = "comb.extract"(%arg1) <{lowBit = 12 : i32}> : (i16) -> i4
    %138 = "comb.extract"(%arg2) <{lowBit = 0 : i32}> : (i16) -> i4
    %139 = "comb.extract"(%arg2) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_6"} : (i16) -> i1
    %140 = "comb.extract"(%arg2) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_7"} : (i16) -> i10
    %141 = "comb.replicate"(%128) : (i1) -> i10
    %142 = "comb.concat"(%141, %129, %130, %131, %132, %133, %134, %135) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %143 = "comb.concat"(%136, %138, %137, %139, %140) : (i1, i4, i4, i1, i10) -> i20
    %144 = "comb.mux"(%97, %142, %143) <{twoState}> : (i1, i20, i20) -> i20
    %145 = "comb.extract"(%144) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_5"} : (i20) -> i1
    %146 = "comb.extract"(%arg1) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_6"} : (i16) -> i2
    %147 = "comb.extract"(%arg1) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_8"} : (i16) -> i2
    %148 = "comb.extract"(%arg1) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_9"} : (i16) -> i2
    %149 = "comb.extract"(%arg2) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_6"} : (i16) -> i6
    %150 = "comb.extract"(%arg1) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_7"} : (i16) -> i4
    %151 = "comb.replicate"(%128) : (i1) -> i5
    %152 = "comb.concat"(%151, %146, %133, %147, %148) : (i5, i2, i1, i2, i2) -> i12
    %153 = "comb.concat"(%136, %132, %149, %150) : (i1, i1, i6, i4) -> i12
    %154 = "comb.mux"(%97, %152, %153) <{twoState}> : (i1, i12, i12) -> i12
    %155 = "comb.extract"(%154) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_5"} : (i12) -> i1
    %156 = "comb.icmp"(%127, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_1_T"} : (i2, i2) -> i1
    %157 = "comb.replicate"(%155) : (i1) -> i51
    %158 = "comb.concat"(%157, %154) : (i51, i12) -> i63
    %159 = "comb.replicate"(%145) : (i1) -> i43
    %160 = "comb.concat"(%159, %144) : (i43, i20) -> i63
    %161 = "comb.mux"(%156, %158, %160) <{twoState}> : (i1, i63, i63) -> i63
    %162 = "comb.concat"(%161, %9) {sv.namehint = "io_out_jumpOffset_1"} : (i63, i1) -> i64
    %163 = "comb.extract"(%arg2) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_21"} : (i16) -> i2
    %164 = "comb.icmp"(%163, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_2"} : (i2, i2) -> i1
    %165 = "comb.extract"(%arg2) <{lowBit = 13 : i32}> : (i16) -> i3
    %166 = "comb.extract"(%arg2) <{lowBit = 0 : i32}> : (i16) -> i12
    %167 = "comb.concat"(%165, %166) : (i3, i12) -> i15
    %168 = "comb.icmp"(%167, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_41"} : (i15, i15) -> i1
    %169 = "comb.extract"(%arg2) <{lowBit = 13 : i32}> : (i16) -> i3
    %170 = "comb.extract"(%arg2) <{lowBit = 0 : i32}> : (i16) -> i2
    %171 = "comb.concat"(%169, %170) : (i3, i2) -> i5
    %172 = "comb.icmp"(%171, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_43"} : (i5, i5) -> i1
    %173 = "comb.extract"(%arg2) <{lowBit = 13 : i32}> : (i16) -> i3
    %174 = "comb.extract"(%arg2) <{lowBit = 0 : i32}> : (i16) -> i7
    %175 = "comb.concat"(%173, %174) : (i3, i7) -> i10
    %176 = "comb.icmp"(%175, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_45"} : (i10, i10) -> i1
    %177 = "comb.extract"(%arg2) <{lowBit = 14 : i32}> : (i16) -> i2
    %178 = "comb.extract"(%arg2) <{lowBit = 0 : i32}> : (i16) -> i2
    %179 = "comb.concat"(%177, %178) : (i2, i2) -> i4
    %180 = "comb.icmp"(%179, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_47"} : (i4, i4) -> i1
    %181 = "comb.extract"(%arg2) <{lowBit = 0 : i32}> : (i16) -> i7
    %182 = "comb.icmp"(%181, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_49"} : (i7, i7) -> i1
    %183 = "comb.extract"(%arg2) <{lowBit = 12 : i32}> : (i16) -> i3
    %184 = "comb.extract"(%arg2) <{lowBit = 0 : i32}> : (i16) -> i7
    %185 = "comb.concat"(%183, %184) : (i3, i7) -> i10
    %186 = "comb.icmp"(%185, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_51"} : (i10, i10) -> i1
    %187 = "comb.icmp"(%181, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_54"} : (i7, i7) -> i1
    %188 = "comb.concat"(%9, %187) : (i1, i1) -> i2
    %189 = "comb.mux"(%186, %7, %188) <{twoState}> {sv.namehint = "_brType_T_55"} : (i1, i2, i2) -> i2
    %190 = "comb.mux"(%182, %8, %189) <{twoState}> {sv.namehint = "_brType_T_56"} : (i1, i2, i2) -> i2
    %191 = "comb.mux"(%180, %11, %190) <{twoState}> {sv.namehint = "_brType_T_57"} : (i1, i2, i2) -> i2
    %192 = "comb.mux"(%176, %7, %191) <{twoState}> {sv.namehint = "_brType_T_58"} : (i1, i2, i2) -> i2
    %193 = "comb.mux"(%172, %8, %192) <{twoState}> {sv.namehint = "_brType_T_59"} : (i1, i2, i2) -> i2
    %194 = "comb.mux"(%168, %12, %193) <{twoState}> {sv.namehint = "brType_2"} : (i1, i2, i2) -> i2
    %195 = "comb.extract"(%arg2) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_10"} : (i16) -> i1
    %196 = "comb.extract"(%arg2) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_17"} : (i16) -> i1
    %197 = "comb.extract"(%arg2) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_18"} : (i16) -> i2
    %198 = "comb.extract"(%arg2) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_19"} : (i16) -> i1
    %199 = "comb.extract"(%arg2) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_9"} : (i16) -> i1
    %200 = "comb.extract"(%arg2) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_12"} : (i16) -> i1
    %201 = "comb.extract"(%arg2) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_22"} : (i16) -> i1
    %202 = "comb.extract"(%arg2) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_23"} : (i16) -> i3
    %203 = "comb.extract"(%arg3) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_8"} : (i16) -> i1
    %204 = "comb.extract"(%arg2) <{lowBit = 12 : i32}> : (i16) -> i4
    %205 = "comb.extract"(%arg3) <{lowBit = 0 : i32}> : (i16) -> i4
    %206 = "comb.extract"(%arg3) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_10"} : (i16) -> i1
    %207 = "comb.extract"(%arg3) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_11"} : (i16) -> i10
    %208 = "comb.replicate"(%195) : (i1) -> i10
    %209 = "comb.concat"(%208, %196, %197, %198, %199, %200, %201, %202) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %210 = "comb.concat"(%203, %205, %204, %206, %207) : (i1, i4, i4, i1, i10) -> i20
    %211 = "comb.mux"(%164, %209, %210) <{twoState}> : (i1, i20, i20) -> i20
    %212 = "comb.extract"(%211) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_8"} : (i20) -> i1
    %213 = "comb.extract"(%arg2) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_11"} : (i16) -> i2
    %214 = "comb.extract"(%arg2) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_13"} : (i16) -> i2
    %215 = "comb.extract"(%arg2) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_14"} : (i16) -> i2
    %216 = "comb.extract"(%arg3) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_10"} : (i16) -> i6
    %217 = "comb.extract"(%arg2) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_11"} : (i16) -> i4
    %218 = "comb.replicate"(%195) : (i1) -> i5
    %219 = "comb.concat"(%218, %213, %200, %214, %215) : (i5, i2, i1, i2, i2) -> i12
    %220 = "comb.concat"(%203, %199, %216, %217) : (i1, i1, i6, i4) -> i12
    %221 = "comb.mux"(%164, %219, %220) <{twoState}> : (i1, i12, i12) -> i12
    %222 = "comb.extract"(%221) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_8"} : (i12) -> i1
    %223 = "comb.icmp"(%194, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_2_T"} : (i2, i2) -> i1
    %224 = "comb.replicate"(%222) : (i1) -> i51
    %225 = "comb.concat"(%224, %221) : (i51, i12) -> i63
    %226 = "comb.replicate"(%212) : (i1) -> i43
    %227 = "comb.concat"(%226, %211) : (i43, i20) -> i63
    %228 = "comb.mux"(%223, %225, %227) <{twoState}> : (i1, i63, i63) -> i63
    %229 = "comb.concat"(%228, %9) {sv.namehint = "io_out_jumpOffset_2"} : (i63, i1) -> i64
    %230 = "comb.extract"(%arg3) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_31"} : (i16) -> i2
    %231 = "comb.icmp"(%230, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_3"} : (i2, i2) -> i1
    %232 = "comb.extract"(%arg3) <{lowBit = 13 : i32}> : (i16) -> i3
    %233 = "comb.extract"(%arg3) <{lowBit = 0 : i32}> : (i16) -> i12
    %234 = "comb.concat"(%232, %233) : (i3, i12) -> i15
    %235 = "comb.icmp"(%234, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_61"} : (i15, i15) -> i1
    %236 = "comb.extract"(%arg3) <{lowBit = 13 : i32}> : (i16) -> i3
    %237 = "comb.extract"(%arg3) <{lowBit = 0 : i32}> : (i16) -> i2
    %238 = "comb.concat"(%236, %237) : (i3, i2) -> i5
    %239 = "comb.icmp"(%238, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_63"} : (i5, i5) -> i1
    %240 = "comb.extract"(%arg3) <{lowBit = 13 : i32}> : (i16) -> i3
    %241 = "comb.extract"(%arg3) <{lowBit = 0 : i32}> : (i16) -> i7
    %242 = "comb.concat"(%240, %241) : (i3, i7) -> i10
    %243 = "comb.icmp"(%242, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_65"} : (i10, i10) -> i1
    %244 = "comb.extract"(%arg3) <{lowBit = 14 : i32}> : (i16) -> i2
    %245 = "comb.extract"(%arg3) <{lowBit = 0 : i32}> : (i16) -> i2
    %246 = "comb.concat"(%244, %245) : (i2, i2) -> i4
    %247 = "comb.icmp"(%246, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_67"} : (i4, i4) -> i1
    %248 = "comb.extract"(%arg3) <{lowBit = 0 : i32}> : (i16) -> i7
    %249 = "comb.icmp"(%248, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_69"} : (i7, i7) -> i1
    %250 = "comb.extract"(%arg3) <{lowBit = 12 : i32}> : (i16) -> i3
    %251 = "comb.extract"(%arg3) <{lowBit = 0 : i32}> : (i16) -> i7
    %252 = "comb.concat"(%250, %251) : (i3, i7) -> i10
    %253 = "comb.icmp"(%252, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_71"} : (i10, i10) -> i1
    %254 = "comb.icmp"(%248, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_74"} : (i7, i7) -> i1
    %255 = "comb.concat"(%9, %254) : (i1, i1) -> i2
    %256 = "comb.mux"(%253, %7, %255) <{twoState}> {sv.namehint = "_brType_T_75"} : (i1, i2, i2) -> i2
    %257 = "comb.mux"(%249, %8, %256) <{twoState}> {sv.namehint = "_brType_T_76"} : (i1, i2, i2) -> i2
    %258 = "comb.mux"(%247, %11, %257) <{twoState}> {sv.namehint = "_brType_T_77"} : (i1, i2, i2) -> i2
    %259 = "comb.mux"(%243, %7, %258) <{twoState}> {sv.namehint = "_brType_T_78"} : (i1, i2, i2) -> i2
    %260 = "comb.mux"(%239, %8, %259) <{twoState}> {sv.namehint = "_brType_T_79"} : (i1, i2, i2) -> i2
    %261 = "comb.mux"(%235, %12, %260) <{twoState}> {sv.namehint = "brType_3"} : (i1, i2, i2) -> i2
    %262 = "comb.extract"(%arg3) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_15"} : (i16) -> i1
    %263 = "comb.extract"(%arg3) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_25"} : (i16) -> i1
    %264 = "comb.extract"(%arg3) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_26"} : (i16) -> i2
    %265 = "comb.extract"(%arg3) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_27"} : (i16) -> i1
    %266 = "comb.extract"(%arg3) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_13"} : (i16) -> i1
    %267 = "comb.extract"(%arg3) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_17"} : (i16) -> i1
    %268 = "comb.extract"(%arg3) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_30"} : (i16) -> i1
    %269 = "comb.extract"(%arg3) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_31"} : (i16) -> i3
    %270 = "comb.extract"(%arg4) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_12"} : (i16) -> i1
    %271 = "comb.extract"(%arg3) <{lowBit = 12 : i32}> : (i16) -> i4
    %272 = "comb.extract"(%arg4) <{lowBit = 0 : i32}> : (i16) -> i4
    %273 = "comb.extract"(%arg4) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_14"} : (i16) -> i1
    %274 = "comb.extract"(%arg4) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_15"} : (i16) -> i10
    %275 = "comb.replicate"(%262) : (i1) -> i10
    %276 = "comb.concat"(%275, %263, %264, %265, %266, %267, %268, %269) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %277 = "comb.concat"(%270, %272, %271, %273, %274) : (i1, i4, i4, i1, i10) -> i20
    %278 = "comb.mux"(%231, %276, %277) <{twoState}> : (i1, i20, i20) -> i20
    %279 = "comb.extract"(%278) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_11"} : (i20) -> i1
    %280 = "comb.extract"(%arg3) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_16"} : (i16) -> i2
    %281 = "comb.extract"(%arg3) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_18"} : (i16) -> i2
    %282 = "comb.extract"(%arg3) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_19"} : (i16) -> i2
    %283 = "comb.extract"(%arg4) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_14"} : (i16) -> i6
    %284 = "comb.extract"(%arg3) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_15"} : (i16) -> i4
    %285 = "comb.replicate"(%262) : (i1) -> i5
    %286 = "comb.concat"(%285, %280, %267, %281, %282) : (i5, i2, i1, i2, i2) -> i12
    %287 = "comb.concat"(%270, %266, %283, %284) : (i1, i1, i6, i4) -> i12
    %288 = "comb.mux"(%231, %286, %287) <{twoState}> : (i1, i12, i12) -> i12
    %289 = "comb.extract"(%288) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_11"} : (i12) -> i1
    %290 = "comb.icmp"(%261, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_3_T"} : (i2, i2) -> i1
    %291 = "comb.replicate"(%289) : (i1) -> i51
    %292 = "comb.concat"(%291, %288) : (i51, i12) -> i63
    %293 = "comb.replicate"(%279) : (i1) -> i43
    %294 = "comb.concat"(%293, %278) : (i43, i20) -> i63
    %295 = "comb.mux"(%290, %292, %294) <{twoState}> : (i1, i63, i63) -> i63
    %296 = "comb.concat"(%295, %9) {sv.namehint = "io_out_jumpOffset_3"} : (i63, i1) -> i64
    %297 = "comb.extract"(%arg4) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_41"} : (i16) -> i2
    %298 = "comb.icmp"(%297, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_4"} : (i2, i2) -> i1
    %299 = "comb.extract"(%arg4) <{lowBit = 13 : i32}> : (i16) -> i3
    %300 = "comb.extract"(%arg4) <{lowBit = 0 : i32}> : (i16) -> i12
    %301 = "comb.concat"(%299, %300) : (i3, i12) -> i15
    %302 = "comb.icmp"(%301, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_81"} : (i15, i15) -> i1
    %303 = "comb.extract"(%arg4) <{lowBit = 13 : i32}> : (i16) -> i3
    %304 = "comb.extract"(%arg4) <{lowBit = 0 : i32}> : (i16) -> i2
    %305 = "comb.concat"(%303, %304) : (i3, i2) -> i5
    %306 = "comb.icmp"(%305, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_83"} : (i5, i5) -> i1
    %307 = "comb.extract"(%arg4) <{lowBit = 13 : i32}> : (i16) -> i3
    %308 = "comb.extract"(%arg4) <{lowBit = 0 : i32}> : (i16) -> i7
    %309 = "comb.concat"(%307, %308) : (i3, i7) -> i10
    %310 = "comb.icmp"(%309, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_85"} : (i10, i10) -> i1
    %311 = "comb.extract"(%arg4) <{lowBit = 14 : i32}> : (i16) -> i2
    %312 = "comb.extract"(%arg4) <{lowBit = 0 : i32}> : (i16) -> i2
    %313 = "comb.concat"(%311, %312) : (i2, i2) -> i4
    %314 = "comb.icmp"(%313, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_87"} : (i4, i4) -> i1
    %315 = "comb.extract"(%arg4) <{lowBit = 0 : i32}> : (i16) -> i7
    %316 = "comb.icmp"(%315, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_89"} : (i7, i7) -> i1
    %317 = "comb.extract"(%arg4) <{lowBit = 12 : i32}> : (i16) -> i3
    %318 = "comb.extract"(%arg4) <{lowBit = 0 : i32}> : (i16) -> i7
    %319 = "comb.concat"(%317, %318) : (i3, i7) -> i10
    %320 = "comb.icmp"(%319, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_91"} : (i10, i10) -> i1
    %321 = "comb.icmp"(%315, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_94"} : (i7, i7) -> i1
    %322 = "comb.concat"(%9, %321) : (i1, i1) -> i2
    %323 = "comb.mux"(%320, %7, %322) <{twoState}> {sv.namehint = "_brType_T_95"} : (i1, i2, i2) -> i2
    %324 = "comb.mux"(%316, %8, %323) <{twoState}> {sv.namehint = "_brType_T_96"} : (i1, i2, i2) -> i2
    %325 = "comb.mux"(%314, %11, %324) <{twoState}> {sv.namehint = "_brType_T_97"} : (i1, i2, i2) -> i2
    %326 = "comb.mux"(%310, %7, %325) <{twoState}> {sv.namehint = "_brType_T_98"} : (i1, i2, i2) -> i2
    %327 = "comb.mux"(%306, %8, %326) <{twoState}> {sv.namehint = "_brType_T_99"} : (i1, i2, i2) -> i2
    %328 = "comb.mux"(%302, %12, %327) <{twoState}> {sv.namehint = "brType_4"} : (i1, i2, i2) -> i2
    %329 = "comb.extract"(%arg4) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_20"} : (i16) -> i1
    %330 = "comb.extract"(%arg4) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_33"} : (i16) -> i1
    %331 = "comb.extract"(%arg4) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_34"} : (i16) -> i2
    %332 = "comb.extract"(%arg4) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_35"} : (i16) -> i1
    %333 = "comb.extract"(%arg4) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_17"} : (i16) -> i1
    %334 = "comb.extract"(%arg4) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_22"} : (i16) -> i1
    %335 = "comb.extract"(%arg4) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_38"} : (i16) -> i1
    %336 = "comb.extract"(%arg4) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_39"} : (i16) -> i3
    %337 = "comb.extract"(%arg5) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_16"} : (i16) -> i1
    %338 = "comb.extract"(%arg4) <{lowBit = 12 : i32}> : (i16) -> i4
    %339 = "comb.extract"(%arg5) <{lowBit = 0 : i32}> : (i16) -> i4
    %340 = "comb.extract"(%arg5) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_18"} : (i16) -> i1
    %341 = "comb.extract"(%arg5) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_19"} : (i16) -> i10
    %342 = "comb.replicate"(%329) : (i1) -> i10
    %343 = "comb.concat"(%342, %330, %331, %332, %333, %334, %335, %336) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %344 = "comb.concat"(%337, %339, %338, %340, %341) : (i1, i4, i4, i1, i10) -> i20
    %345 = "comb.mux"(%298, %343, %344) <{twoState}> : (i1, i20, i20) -> i20
    %346 = "comb.extract"(%345) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_14"} : (i20) -> i1
    %347 = "comb.extract"(%arg4) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_21"} : (i16) -> i2
    %348 = "comb.extract"(%arg4) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_23"} : (i16) -> i2
    %349 = "comb.extract"(%arg4) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_24"} : (i16) -> i2
    %350 = "comb.extract"(%arg5) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_18"} : (i16) -> i6
    %351 = "comb.extract"(%arg4) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_19"} : (i16) -> i4
    %352 = "comb.replicate"(%329) : (i1) -> i5
    %353 = "comb.concat"(%352, %347, %334, %348, %349) : (i5, i2, i1, i2, i2) -> i12
    %354 = "comb.concat"(%337, %333, %350, %351) : (i1, i1, i6, i4) -> i12
    %355 = "comb.mux"(%298, %353, %354) <{twoState}> : (i1, i12, i12) -> i12
    %356 = "comb.extract"(%355) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_14"} : (i12) -> i1
    %357 = "comb.icmp"(%328, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_4_T"} : (i2, i2) -> i1
    %358 = "comb.replicate"(%356) : (i1) -> i51
    %359 = "comb.concat"(%358, %355) : (i51, i12) -> i63
    %360 = "comb.replicate"(%346) : (i1) -> i43
    %361 = "comb.concat"(%360, %345) : (i43, i20) -> i63
    %362 = "comb.mux"(%357, %359, %361) <{twoState}> : (i1, i63, i63) -> i63
    %363 = "comb.concat"(%362, %9) {sv.namehint = "io_out_jumpOffset_4"} : (i63, i1) -> i64
    %364 = "comb.extract"(%arg5) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_51"} : (i16) -> i2
    %365 = "comb.icmp"(%364, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_5"} : (i2, i2) -> i1
    %366 = "comb.extract"(%arg5) <{lowBit = 13 : i32}> : (i16) -> i3
    %367 = "comb.extract"(%arg5) <{lowBit = 0 : i32}> : (i16) -> i12
    %368 = "comb.concat"(%366, %367) : (i3, i12) -> i15
    %369 = "comb.icmp"(%368, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_101"} : (i15, i15) -> i1
    %370 = "comb.extract"(%arg5) <{lowBit = 13 : i32}> : (i16) -> i3
    %371 = "comb.extract"(%arg5) <{lowBit = 0 : i32}> : (i16) -> i2
    %372 = "comb.concat"(%370, %371) : (i3, i2) -> i5
    %373 = "comb.icmp"(%372, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_103"} : (i5, i5) -> i1
    %374 = "comb.extract"(%arg5) <{lowBit = 13 : i32}> : (i16) -> i3
    %375 = "comb.extract"(%arg5) <{lowBit = 0 : i32}> : (i16) -> i7
    %376 = "comb.concat"(%374, %375) : (i3, i7) -> i10
    %377 = "comb.icmp"(%376, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_105"} : (i10, i10) -> i1
    %378 = "comb.extract"(%arg5) <{lowBit = 14 : i32}> : (i16) -> i2
    %379 = "comb.extract"(%arg5) <{lowBit = 0 : i32}> : (i16) -> i2
    %380 = "comb.concat"(%378, %379) : (i2, i2) -> i4
    %381 = "comb.icmp"(%380, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_107"} : (i4, i4) -> i1
    %382 = "comb.extract"(%arg5) <{lowBit = 0 : i32}> : (i16) -> i7
    %383 = "comb.icmp"(%382, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_109"} : (i7, i7) -> i1
    %384 = "comb.extract"(%arg5) <{lowBit = 12 : i32}> : (i16) -> i3
    %385 = "comb.extract"(%arg5) <{lowBit = 0 : i32}> : (i16) -> i7
    %386 = "comb.concat"(%384, %385) : (i3, i7) -> i10
    %387 = "comb.icmp"(%386, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_111"} : (i10, i10) -> i1
    %388 = "comb.icmp"(%382, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_114"} : (i7, i7) -> i1
    %389 = "comb.concat"(%9, %388) : (i1, i1) -> i2
    %390 = "comb.mux"(%387, %7, %389) <{twoState}> {sv.namehint = "_brType_T_115"} : (i1, i2, i2) -> i2
    %391 = "comb.mux"(%383, %8, %390) <{twoState}> {sv.namehint = "_brType_T_116"} : (i1, i2, i2) -> i2
    %392 = "comb.mux"(%381, %11, %391) <{twoState}> {sv.namehint = "_brType_T_117"} : (i1, i2, i2) -> i2
    %393 = "comb.mux"(%377, %7, %392) <{twoState}> {sv.namehint = "_brType_T_118"} : (i1, i2, i2) -> i2
    %394 = "comb.mux"(%373, %8, %393) <{twoState}> {sv.namehint = "_brType_T_119"} : (i1, i2, i2) -> i2
    %395 = "comb.mux"(%369, %12, %394) <{twoState}> {sv.namehint = "brType_5"} : (i1, i2, i2) -> i2
    %396 = "comb.extract"(%arg5) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_25"} : (i16) -> i1
    %397 = "comb.extract"(%arg5) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_41"} : (i16) -> i1
    %398 = "comb.extract"(%arg5) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_42"} : (i16) -> i2
    %399 = "comb.extract"(%arg5) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_43"} : (i16) -> i1
    %400 = "comb.extract"(%arg5) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_21"} : (i16) -> i1
    %401 = "comb.extract"(%arg5) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_27"} : (i16) -> i1
    %402 = "comb.extract"(%arg5) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_46"} : (i16) -> i1
    %403 = "comb.extract"(%arg5) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_47"} : (i16) -> i3
    %404 = "comb.extract"(%arg6) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_20"} : (i16) -> i1
    %405 = "comb.extract"(%arg5) <{lowBit = 12 : i32}> : (i16) -> i4
    %406 = "comb.extract"(%arg6) <{lowBit = 0 : i32}> : (i16) -> i4
    %407 = "comb.extract"(%arg6) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_22"} : (i16) -> i1
    %408 = "comb.extract"(%arg6) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_23"} : (i16) -> i10
    %409 = "comb.replicate"(%396) : (i1) -> i10
    %410 = "comb.concat"(%409, %397, %398, %399, %400, %401, %402, %403) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %411 = "comb.concat"(%404, %406, %405, %407, %408) : (i1, i4, i4, i1, i10) -> i20
    %412 = "comb.mux"(%365, %410, %411) <{twoState}> : (i1, i20, i20) -> i20
    %413 = "comb.extract"(%412) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_17"} : (i20) -> i1
    %414 = "comb.extract"(%arg5) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_26"} : (i16) -> i2
    %415 = "comb.extract"(%arg5) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_28"} : (i16) -> i2
    %416 = "comb.extract"(%arg5) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_29"} : (i16) -> i2
    %417 = "comb.extract"(%arg6) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_22"} : (i16) -> i6
    %418 = "comb.extract"(%arg5) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_23"} : (i16) -> i4
    %419 = "comb.replicate"(%396) : (i1) -> i5
    %420 = "comb.concat"(%419, %414, %401, %415, %416) : (i5, i2, i1, i2, i2) -> i12
    %421 = "comb.concat"(%404, %400, %417, %418) : (i1, i1, i6, i4) -> i12
    %422 = "comb.mux"(%365, %420, %421) <{twoState}> : (i1, i12, i12) -> i12
    %423 = "comb.extract"(%422) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_17"} : (i12) -> i1
    %424 = "comb.icmp"(%395, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_5_T"} : (i2, i2) -> i1
    %425 = "comb.replicate"(%423) : (i1) -> i51
    %426 = "comb.concat"(%425, %422) : (i51, i12) -> i63
    %427 = "comb.replicate"(%413) : (i1) -> i43
    %428 = "comb.concat"(%427, %412) : (i43, i20) -> i63
    %429 = "comb.mux"(%424, %426, %428) <{twoState}> : (i1, i63, i63) -> i63
    %430 = "comb.concat"(%429, %9) {sv.namehint = "io_out_jumpOffset_5"} : (i63, i1) -> i64
    %431 = "comb.extract"(%arg6) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_61"} : (i16) -> i2
    %432 = "comb.icmp"(%431, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_6"} : (i2, i2) -> i1
    %433 = "comb.extract"(%arg6) <{lowBit = 13 : i32}> : (i16) -> i3
    %434 = "comb.extract"(%arg6) <{lowBit = 0 : i32}> : (i16) -> i12
    %435 = "comb.concat"(%433, %434) : (i3, i12) -> i15
    %436 = "comb.icmp"(%435, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_121"} : (i15, i15) -> i1
    %437 = "comb.extract"(%arg6) <{lowBit = 13 : i32}> : (i16) -> i3
    %438 = "comb.extract"(%arg6) <{lowBit = 0 : i32}> : (i16) -> i2
    %439 = "comb.concat"(%437, %438) : (i3, i2) -> i5
    %440 = "comb.icmp"(%439, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_123"} : (i5, i5) -> i1
    %441 = "comb.extract"(%arg6) <{lowBit = 13 : i32}> : (i16) -> i3
    %442 = "comb.extract"(%arg6) <{lowBit = 0 : i32}> : (i16) -> i7
    %443 = "comb.concat"(%441, %442) : (i3, i7) -> i10
    %444 = "comb.icmp"(%443, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_125"} : (i10, i10) -> i1
    %445 = "comb.extract"(%arg6) <{lowBit = 14 : i32}> : (i16) -> i2
    %446 = "comb.extract"(%arg6) <{lowBit = 0 : i32}> : (i16) -> i2
    %447 = "comb.concat"(%445, %446) : (i2, i2) -> i4
    %448 = "comb.icmp"(%447, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_127"} : (i4, i4) -> i1
    %449 = "comb.extract"(%arg6) <{lowBit = 0 : i32}> : (i16) -> i7
    %450 = "comb.icmp"(%449, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_129"} : (i7, i7) -> i1
    %451 = "comb.extract"(%arg6) <{lowBit = 12 : i32}> : (i16) -> i3
    %452 = "comb.extract"(%arg6) <{lowBit = 0 : i32}> : (i16) -> i7
    %453 = "comb.concat"(%451, %452) : (i3, i7) -> i10
    %454 = "comb.icmp"(%453, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_131"} : (i10, i10) -> i1
    %455 = "comb.icmp"(%449, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_134"} : (i7, i7) -> i1
    %456 = "comb.concat"(%9, %455) : (i1, i1) -> i2
    %457 = "comb.mux"(%454, %7, %456) <{twoState}> {sv.namehint = "_brType_T_135"} : (i1, i2, i2) -> i2
    %458 = "comb.mux"(%450, %8, %457) <{twoState}> {sv.namehint = "_brType_T_136"} : (i1, i2, i2) -> i2
    %459 = "comb.mux"(%448, %11, %458) <{twoState}> {sv.namehint = "_brType_T_137"} : (i1, i2, i2) -> i2
    %460 = "comb.mux"(%444, %7, %459) <{twoState}> {sv.namehint = "_brType_T_138"} : (i1, i2, i2) -> i2
    %461 = "comb.mux"(%440, %8, %460) <{twoState}> {sv.namehint = "_brType_T_139"} : (i1, i2, i2) -> i2
    %462 = "comb.mux"(%436, %12, %461) <{twoState}> {sv.namehint = "brType_6"} : (i1, i2, i2) -> i2
    %463 = "comb.extract"(%arg6) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_30"} : (i16) -> i1
    %464 = "comb.extract"(%arg6) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_49"} : (i16) -> i1
    %465 = "comb.extract"(%arg6) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_50"} : (i16) -> i2
    %466 = "comb.extract"(%arg6) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_51"} : (i16) -> i1
    %467 = "comb.extract"(%arg6) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_25"} : (i16) -> i1
    %468 = "comb.extract"(%arg6) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_32"} : (i16) -> i1
    %469 = "comb.extract"(%arg6) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_54"} : (i16) -> i1
    %470 = "comb.extract"(%arg6) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_55"} : (i16) -> i3
    %471 = "comb.extract"(%arg7) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_24"} : (i16) -> i1
    %472 = "comb.extract"(%arg6) <{lowBit = 12 : i32}> : (i16) -> i4
    %473 = "comb.extract"(%arg7) <{lowBit = 0 : i32}> : (i16) -> i4
    %474 = "comb.extract"(%arg7) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_26"} : (i16) -> i1
    %475 = "comb.extract"(%arg7) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_27"} : (i16) -> i10
    %476 = "comb.replicate"(%463) : (i1) -> i10
    %477 = "comb.concat"(%476, %464, %465, %466, %467, %468, %469, %470) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %478 = "comb.concat"(%471, %473, %472, %474, %475) : (i1, i4, i4, i1, i10) -> i20
    %479 = "comb.mux"(%432, %477, %478) <{twoState}> : (i1, i20, i20) -> i20
    %480 = "comb.extract"(%479) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_20"} : (i20) -> i1
    %481 = "comb.extract"(%arg6) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_31"} : (i16) -> i2
    %482 = "comb.extract"(%arg6) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_33"} : (i16) -> i2
    %483 = "comb.extract"(%arg6) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_34"} : (i16) -> i2
    %484 = "comb.extract"(%arg7) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_26"} : (i16) -> i6
    %485 = "comb.extract"(%arg6) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_27"} : (i16) -> i4
    %486 = "comb.replicate"(%463) : (i1) -> i5
    %487 = "comb.concat"(%486, %481, %468, %482, %483) : (i5, i2, i1, i2, i2) -> i12
    %488 = "comb.concat"(%471, %467, %484, %485) : (i1, i1, i6, i4) -> i12
    %489 = "comb.mux"(%432, %487, %488) <{twoState}> : (i1, i12, i12) -> i12
    %490 = "comb.extract"(%489) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_20"} : (i12) -> i1
    %491 = "comb.icmp"(%462, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_6_T"} : (i2, i2) -> i1
    %492 = "comb.replicate"(%490) : (i1) -> i51
    %493 = "comb.concat"(%492, %489) : (i51, i12) -> i63
    %494 = "comb.replicate"(%480) : (i1) -> i43
    %495 = "comb.concat"(%494, %479) : (i43, i20) -> i63
    %496 = "comb.mux"(%491, %493, %495) <{twoState}> : (i1, i63, i63) -> i63
    %497 = "comb.concat"(%496, %9) {sv.namehint = "io_out_jumpOffset_6"} : (i63, i1) -> i64
    %498 = "comb.extract"(%arg7) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_71"} : (i16) -> i2
    %499 = "comb.icmp"(%498, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_7"} : (i2, i2) -> i1
    %500 = "comb.extract"(%arg7) <{lowBit = 13 : i32}> : (i16) -> i3
    %501 = "comb.extract"(%arg7) <{lowBit = 0 : i32}> : (i16) -> i12
    %502 = "comb.concat"(%500, %501) : (i3, i12) -> i15
    %503 = "comb.icmp"(%502, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_141"} : (i15, i15) -> i1
    %504 = "comb.extract"(%arg7) <{lowBit = 13 : i32}> : (i16) -> i3
    %505 = "comb.extract"(%arg7) <{lowBit = 0 : i32}> : (i16) -> i2
    %506 = "comb.concat"(%504, %505) : (i3, i2) -> i5
    %507 = "comb.icmp"(%506, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_143"} : (i5, i5) -> i1
    %508 = "comb.extract"(%arg7) <{lowBit = 13 : i32}> : (i16) -> i3
    %509 = "comb.extract"(%arg7) <{lowBit = 0 : i32}> : (i16) -> i7
    %510 = "comb.concat"(%508, %509) : (i3, i7) -> i10
    %511 = "comb.icmp"(%510, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_145"} : (i10, i10) -> i1
    %512 = "comb.extract"(%arg7) <{lowBit = 14 : i32}> : (i16) -> i2
    %513 = "comb.extract"(%arg7) <{lowBit = 0 : i32}> : (i16) -> i2
    %514 = "comb.concat"(%512, %513) : (i2, i2) -> i4
    %515 = "comb.icmp"(%514, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_147"} : (i4, i4) -> i1
    %516 = "comb.extract"(%arg7) <{lowBit = 0 : i32}> : (i16) -> i7
    %517 = "comb.icmp"(%516, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_149"} : (i7, i7) -> i1
    %518 = "comb.extract"(%arg7) <{lowBit = 12 : i32}> : (i16) -> i3
    %519 = "comb.extract"(%arg7) <{lowBit = 0 : i32}> : (i16) -> i7
    %520 = "comb.concat"(%518, %519) : (i3, i7) -> i10
    %521 = "comb.icmp"(%520, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_151"} : (i10, i10) -> i1
    %522 = "comb.icmp"(%516, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_154"} : (i7, i7) -> i1
    %523 = "comb.concat"(%9, %522) : (i1, i1) -> i2
    %524 = "comb.mux"(%521, %7, %523) <{twoState}> {sv.namehint = "_brType_T_155"} : (i1, i2, i2) -> i2
    %525 = "comb.mux"(%517, %8, %524) <{twoState}> {sv.namehint = "_brType_T_156"} : (i1, i2, i2) -> i2
    %526 = "comb.mux"(%515, %11, %525) <{twoState}> {sv.namehint = "_brType_T_157"} : (i1, i2, i2) -> i2
    %527 = "comb.mux"(%511, %7, %526) <{twoState}> {sv.namehint = "_brType_T_158"} : (i1, i2, i2) -> i2
    %528 = "comb.mux"(%507, %8, %527) <{twoState}> {sv.namehint = "_brType_T_159"} : (i1, i2, i2) -> i2
    %529 = "comb.mux"(%503, %12, %528) <{twoState}> {sv.namehint = "brType_7"} : (i1, i2, i2) -> i2
    %530 = "comb.extract"(%arg7) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_35"} : (i16) -> i1
    %531 = "comb.extract"(%arg7) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_57"} : (i16) -> i1
    %532 = "comb.extract"(%arg7) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_58"} : (i16) -> i2
    %533 = "comb.extract"(%arg7) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_59"} : (i16) -> i1
    %534 = "comb.extract"(%arg7) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_29"} : (i16) -> i1
    %535 = "comb.extract"(%arg7) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_37"} : (i16) -> i1
    %536 = "comb.extract"(%arg7) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_62"} : (i16) -> i1
    %537 = "comb.extract"(%arg7) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_63"} : (i16) -> i3
    %538 = "comb.extract"(%arg8) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_28"} : (i16) -> i1
    %539 = "comb.extract"(%arg7) <{lowBit = 12 : i32}> : (i16) -> i4
    %540 = "comb.extract"(%arg8) <{lowBit = 0 : i32}> : (i16) -> i4
    %541 = "comb.extract"(%arg8) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_30"} : (i16) -> i1
    %542 = "comb.extract"(%arg8) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_31"} : (i16) -> i10
    %543 = "comb.replicate"(%530) : (i1) -> i10
    %544 = "comb.concat"(%543, %531, %532, %533, %534, %535, %536, %537) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %545 = "comb.concat"(%538, %540, %539, %541, %542) : (i1, i4, i4, i1, i10) -> i20
    %546 = "comb.mux"(%499, %544, %545) <{twoState}> : (i1, i20, i20) -> i20
    %547 = "comb.extract"(%546) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_23"} : (i20) -> i1
    %548 = "comb.extract"(%arg7) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_36"} : (i16) -> i2
    %549 = "comb.extract"(%arg7) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_38"} : (i16) -> i2
    %550 = "comb.extract"(%arg7) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_39"} : (i16) -> i2
    %551 = "comb.extract"(%arg8) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_30"} : (i16) -> i6
    %552 = "comb.extract"(%arg7) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_31"} : (i16) -> i4
    %553 = "comb.replicate"(%530) : (i1) -> i5
    %554 = "comb.concat"(%553, %548, %535, %549, %550) : (i5, i2, i1, i2, i2) -> i12
    %555 = "comb.concat"(%538, %534, %551, %552) : (i1, i1, i6, i4) -> i12
    %556 = "comb.mux"(%499, %554, %555) <{twoState}> : (i1, i12, i12) -> i12
    %557 = "comb.extract"(%556) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_23"} : (i12) -> i1
    %558 = "comb.icmp"(%529, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_7_T"} : (i2, i2) -> i1
    %559 = "comb.replicate"(%557) : (i1) -> i51
    %560 = "comb.concat"(%559, %556) : (i51, i12) -> i63
    %561 = "comb.replicate"(%547) : (i1) -> i43
    %562 = "comb.concat"(%561, %546) : (i43, i20) -> i63
    %563 = "comb.mux"(%558, %560, %562) <{twoState}> : (i1, i63, i63) -> i63
    %564 = "comb.concat"(%563, %9) {sv.namehint = "io_out_jumpOffset_7"} : (i63, i1) -> i64
    %565 = "comb.extract"(%arg8) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_81"} : (i16) -> i2
    %566 = "comb.icmp"(%565, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_8"} : (i2, i2) -> i1
    %567 = "comb.extract"(%arg8) <{lowBit = 13 : i32}> : (i16) -> i3
    %568 = "comb.extract"(%arg8) <{lowBit = 0 : i32}> : (i16) -> i12
    %569 = "comb.concat"(%567, %568) : (i3, i12) -> i15
    %570 = "comb.icmp"(%569, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_161"} : (i15, i15) -> i1
    %571 = "comb.extract"(%arg8) <{lowBit = 13 : i32}> : (i16) -> i3
    %572 = "comb.extract"(%arg8) <{lowBit = 0 : i32}> : (i16) -> i2
    %573 = "comb.concat"(%571, %572) : (i3, i2) -> i5
    %574 = "comb.icmp"(%573, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_163"} : (i5, i5) -> i1
    %575 = "comb.extract"(%arg8) <{lowBit = 13 : i32}> : (i16) -> i3
    %576 = "comb.extract"(%arg8) <{lowBit = 0 : i32}> : (i16) -> i7
    %577 = "comb.concat"(%575, %576) : (i3, i7) -> i10
    %578 = "comb.icmp"(%577, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_165"} : (i10, i10) -> i1
    %579 = "comb.extract"(%arg8) <{lowBit = 14 : i32}> : (i16) -> i2
    %580 = "comb.extract"(%arg8) <{lowBit = 0 : i32}> : (i16) -> i2
    %581 = "comb.concat"(%579, %580) : (i2, i2) -> i4
    %582 = "comb.icmp"(%581, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_167"} : (i4, i4) -> i1
    %583 = "comb.extract"(%arg8) <{lowBit = 0 : i32}> : (i16) -> i7
    %584 = "comb.icmp"(%583, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_169"} : (i7, i7) -> i1
    %585 = "comb.extract"(%arg8) <{lowBit = 12 : i32}> : (i16) -> i3
    %586 = "comb.extract"(%arg8) <{lowBit = 0 : i32}> : (i16) -> i7
    %587 = "comb.concat"(%585, %586) : (i3, i7) -> i10
    %588 = "comb.icmp"(%587, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_171"} : (i10, i10) -> i1
    %589 = "comb.icmp"(%583, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_174"} : (i7, i7) -> i1
    %590 = "comb.concat"(%9, %589) : (i1, i1) -> i2
    %591 = "comb.mux"(%588, %7, %590) <{twoState}> {sv.namehint = "_brType_T_175"} : (i1, i2, i2) -> i2
    %592 = "comb.mux"(%584, %8, %591) <{twoState}> {sv.namehint = "_brType_T_176"} : (i1, i2, i2) -> i2
    %593 = "comb.mux"(%582, %11, %592) <{twoState}> {sv.namehint = "_brType_T_177"} : (i1, i2, i2) -> i2
    %594 = "comb.mux"(%578, %7, %593) <{twoState}> {sv.namehint = "_brType_T_178"} : (i1, i2, i2) -> i2
    %595 = "comb.mux"(%574, %8, %594) <{twoState}> {sv.namehint = "_brType_T_179"} : (i1, i2, i2) -> i2
    %596 = "comb.mux"(%570, %12, %595) <{twoState}> {sv.namehint = "brType_8"} : (i1, i2, i2) -> i2
    %597 = "comb.extract"(%arg8) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_40"} : (i16) -> i1
    %598 = "comb.extract"(%arg8) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_65"} : (i16) -> i1
    %599 = "comb.extract"(%arg8) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_66"} : (i16) -> i2
    %600 = "comb.extract"(%arg8) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_67"} : (i16) -> i1
    %601 = "comb.extract"(%arg8) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_33"} : (i16) -> i1
    %602 = "comb.extract"(%arg8) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_42"} : (i16) -> i1
    %603 = "comb.extract"(%arg8) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_70"} : (i16) -> i1
    %604 = "comb.extract"(%arg8) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_71"} : (i16) -> i3
    %605 = "comb.extract"(%arg9) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_32"} : (i16) -> i1
    %606 = "comb.extract"(%arg8) <{lowBit = 12 : i32}> : (i16) -> i4
    %607 = "comb.extract"(%arg9) <{lowBit = 0 : i32}> : (i16) -> i4
    %608 = "comb.extract"(%arg9) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_34"} : (i16) -> i1
    %609 = "comb.extract"(%arg9) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_35"} : (i16) -> i10
    %610 = "comb.replicate"(%597) : (i1) -> i10
    %611 = "comb.concat"(%610, %598, %599, %600, %601, %602, %603, %604) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %612 = "comb.concat"(%605, %607, %606, %608, %609) : (i1, i4, i4, i1, i10) -> i20
    %613 = "comb.mux"(%566, %611, %612) <{twoState}> : (i1, i20, i20) -> i20
    %614 = "comb.extract"(%613) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_26"} : (i20) -> i1
    %615 = "comb.extract"(%arg8) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_41"} : (i16) -> i2
    %616 = "comb.extract"(%arg8) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_43"} : (i16) -> i2
    %617 = "comb.extract"(%arg8) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_44"} : (i16) -> i2
    %618 = "comb.extract"(%arg9) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_34"} : (i16) -> i6
    %619 = "comb.extract"(%arg8) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_35"} : (i16) -> i4
    %620 = "comb.replicate"(%597) : (i1) -> i5
    %621 = "comb.concat"(%620, %615, %602, %616, %617) : (i5, i2, i1, i2, i2) -> i12
    %622 = "comb.concat"(%605, %601, %618, %619) : (i1, i1, i6, i4) -> i12
    %623 = "comb.mux"(%566, %621, %622) <{twoState}> : (i1, i12, i12) -> i12
    %624 = "comb.extract"(%623) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_26"} : (i12) -> i1
    %625 = "comb.icmp"(%596, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_8_T"} : (i2, i2) -> i1
    %626 = "comb.replicate"(%624) : (i1) -> i51
    %627 = "comb.concat"(%626, %623) : (i51, i12) -> i63
    %628 = "comb.replicate"(%614) : (i1) -> i43
    %629 = "comb.concat"(%628, %613) : (i43, i20) -> i63
    %630 = "comb.mux"(%625, %627, %629) <{twoState}> : (i1, i63, i63) -> i63
    %631 = "comb.concat"(%630, %9) {sv.namehint = "io_out_jumpOffset_8"} : (i63, i1) -> i64
    %632 = "comb.extract"(%arg9) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_91"} : (i16) -> i2
    %633 = "comb.icmp"(%632, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_9"} : (i2, i2) -> i1
    %634 = "comb.extract"(%arg9) <{lowBit = 13 : i32}> : (i16) -> i3
    %635 = "comb.extract"(%arg9) <{lowBit = 0 : i32}> : (i16) -> i12
    %636 = "comb.concat"(%634, %635) : (i3, i12) -> i15
    %637 = "comb.icmp"(%636, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_181"} : (i15, i15) -> i1
    %638 = "comb.extract"(%arg9) <{lowBit = 13 : i32}> : (i16) -> i3
    %639 = "comb.extract"(%arg9) <{lowBit = 0 : i32}> : (i16) -> i2
    %640 = "comb.concat"(%638, %639) : (i3, i2) -> i5
    %641 = "comb.icmp"(%640, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_183"} : (i5, i5) -> i1
    %642 = "comb.extract"(%arg9) <{lowBit = 13 : i32}> : (i16) -> i3
    %643 = "comb.extract"(%arg9) <{lowBit = 0 : i32}> : (i16) -> i7
    %644 = "comb.concat"(%642, %643) : (i3, i7) -> i10
    %645 = "comb.icmp"(%644, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_185"} : (i10, i10) -> i1
    %646 = "comb.extract"(%arg9) <{lowBit = 14 : i32}> : (i16) -> i2
    %647 = "comb.extract"(%arg9) <{lowBit = 0 : i32}> : (i16) -> i2
    %648 = "comb.concat"(%646, %647) : (i2, i2) -> i4
    %649 = "comb.icmp"(%648, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_187"} : (i4, i4) -> i1
    %650 = "comb.extract"(%arg9) <{lowBit = 0 : i32}> : (i16) -> i7
    %651 = "comb.icmp"(%650, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_189"} : (i7, i7) -> i1
    %652 = "comb.extract"(%arg9) <{lowBit = 12 : i32}> : (i16) -> i3
    %653 = "comb.extract"(%arg9) <{lowBit = 0 : i32}> : (i16) -> i7
    %654 = "comb.concat"(%652, %653) : (i3, i7) -> i10
    %655 = "comb.icmp"(%654, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_191"} : (i10, i10) -> i1
    %656 = "comb.icmp"(%650, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_194"} : (i7, i7) -> i1
    %657 = "comb.concat"(%9, %656) : (i1, i1) -> i2
    %658 = "comb.mux"(%655, %7, %657) <{twoState}> {sv.namehint = "_brType_T_195"} : (i1, i2, i2) -> i2
    %659 = "comb.mux"(%651, %8, %658) <{twoState}> {sv.namehint = "_brType_T_196"} : (i1, i2, i2) -> i2
    %660 = "comb.mux"(%649, %11, %659) <{twoState}> {sv.namehint = "_brType_T_197"} : (i1, i2, i2) -> i2
    %661 = "comb.mux"(%645, %7, %660) <{twoState}> {sv.namehint = "_brType_T_198"} : (i1, i2, i2) -> i2
    %662 = "comb.mux"(%641, %8, %661) <{twoState}> {sv.namehint = "_brType_T_199"} : (i1, i2, i2) -> i2
    %663 = "comb.mux"(%637, %12, %662) <{twoState}> {sv.namehint = "brType_9"} : (i1, i2, i2) -> i2
    %664 = "comb.extract"(%arg9) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_45"} : (i16) -> i1
    %665 = "comb.extract"(%arg9) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_73"} : (i16) -> i1
    %666 = "comb.extract"(%arg9) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_74"} : (i16) -> i2
    %667 = "comb.extract"(%arg9) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_75"} : (i16) -> i1
    %668 = "comb.extract"(%arg9) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_37"} : (i16) -> i1
    %669 = "comb.extract"(%arg9) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_47"} : (i16) -> i1
    %670 = "comb.extract"(%arg9) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_78"} : (i16) -> i1
    %671 = "comb.extract"(%arg9) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_79"} : (i16) -> i3
    %672 = "comb.extract"(%arg10) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_36"} : (i16) -> i1
    %673 = "comb.extract"(%arg9) <{lowBit = 12 : i32}> : (i16) -> i4
    %674 = "comb.extract"(%arg10) <{lowBit = 0 : i32}> : (i16) -> i4
    %675 = "comb.extract"(%arg10) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_38"} : (i16) -> i1
    %676 = "comb.extract"(%arg10) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_39"} : (i16) -> i10
    %677 = "comb.replicate"(%664) : (i1) -> i10
    %678 = "comb.concat"(%677, %665, %666, %667, %668, %669, %670, %671) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %679 = "comb.concat"(%672, %674, %673, %675, %676) : (i1, i4, i4, i1, i10) -> i20
    %680 = "comb.mux"(%633, %678, %679) <{twoState}> : (i1, i20, i20) -> i20
    %681 = "comb.extract"(%680) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_29"} : (i20) -> i1
    %682 = "comb.extract"(%arg9) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_46"} : (i16) -> i2
    %683 = "comb.extract"(%arg9) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_48"} : (i16) -> i2
    %684 = "comb.extract"(%arg9) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_49"} : (i16) -> i2
    %685 = "comb.extract"(%arg10) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_38"} : (i16) -> i6
    %686 = "comb.extract"(%arg9) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_39"} : (i16) -> i4
    %687 = "comb.replicate"(%664) : (i1) -> i5
    %688 = "comb.concat"(%687, %682, %669, %683, %684) : (i5, i2, i1, i2, i2) -> i12
    %689 = "comb.concat"(%672, %668, %685, %686) : (i1, i1, i6, i4) -> i12
    %690 = "comb.mux"(%633, %688, %689) <{twoState}> : (i1, i12, i12) -> i12
    %691 = "comb.extract"(%690) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_29"} : (i12) -> i1
    %692 = "comb.icmp"(%663, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_9_T"} : (i2, i2) -> i1
    %693 = "comb.replicate"(%691) : (i1) -> i51
    %694 = "comb.concat"(%693, %690) : (i51, i12) -> i63
    %695 = "comb.replicate"(%681) : (i1) -> i43
    %696 = "comb.concat"(%695, %680) : (i43, i20) -> i63
    %697 = "comb.mux"(%692, %694, %696) <{twoState}> : (i1, i63, i63) -> i63
    %698 = "comb.concat"(%697, %9) {sv.namehint = "io_out_jumpOffset_9"} : (i63, i1) -> i64
    %699 = "comb.extract"(%arg10) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_101"} : (i16) -> i2
    %700 = "comb.icmp"(%699, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_10"} : (i2, i2) -> i1
    %701 = "comb.extract"(%arg10) <{lowBit = 13 : i32}> : (i16) -> i3
    %702 = "comb.extract"(%arg10) <{lowBit = 0 : i32}> : (i16) -> i12
    %703 = "comb.concat"(%701, %702) : (i3, i12) -> i15
    %704 = "comb.icmp"(%703, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_201"} : (i15, i15) -> i1
    %705 = "comb.extract"(%arg10) <{lowBit = 13 : i32}> : (i16) -> i3
    %706 = "comb.extract"(%arg10) <{lowBit = 0 : i32}> : (i16) -> i2
    %707 = "comb.concat"(%705, %706) : (i3, i2) -> i5
    %708 = "comb.icmp"(%707, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_203"} : (i5, i5) -> i1
    %709 = "comb.extract"(%arg10) <{lowBit = 13 : i32}> : (i16) -> i3
    %710 = "comb.extract"(%arg10) <{lowBit = 0 : i32}> : (i16) -> i7
    %711 = "comb.concat"(%709, %710) : (i3, i7) -> i10
    %712 = "comb.icmp"(%711, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_205"} : (i10, i10) -> i1
    %713 = "comb.extract"(%arg10) <{lowBit = 14 : i32}> : (i16) -> i2
    %714 = "comb.extract"(%arg10) <{lowBit = 0 : i32}> : (i16) -> i2
    %715 = "comb.concat"(%713, %714) : (i2, i2) -> i4
    %716 = "comb.icmp"(%715, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_207"} : (i4, i4) -> i1
    %717 = "comb.extract"(%arg10) <{lowBit = 0 : i32}> : (i16) -> i7
    %718 = "comb.icmp"(%717, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_209"} : (i7, i7) -> i1
    %719 = "comb.extract"(%arg10) <{lowBit = 12 : i32}> : (i16) -> i3
    %720 = "comb.extract"(%arg10) <{lowBit = 0 : i32}> : (i16) -> i7
    %721 = "comb.concat"(%719, %720) : (i3, i7) -> i10
    %722 = "comb.icmp"(%721, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_211"} : (i10, i10) -> i1
    %723 = "comb.icmp"(%717, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_214"} : (i7, i7) -> i1
    %724 = "comb.concat"(%9, %723) : (i1, i1) -> i2
    %725 = "comb.mux"(%722, %7, %724) <{twoState}> {sv.namehint = "_brType_T_215"} : (i1, i2, i2) -> i2
    %726 = "comb.mux"(%718, %8, %725) <{twoState}> {sv.namehint = "_brType_T_216"} : (i1, i2, i2) -> i2
    %727 = "comb.mux"(%716, %11, %726) <{twoState}> {sv.namehint = "_brType_T_217"} : (i1, i2, i2) -> i2
    %728 = "comb.mux"(%712, %7, %727) <{twoState}> {sv.namehint = "_brType_T_218"} : (i1, i2, i2) -> i2
    %729 = "comb.mux"(%708, %8, %728) <{twoState}> {sv.namehint = "_brType_T_219"} : (i1, i2, i2) -> i2
    %730 = "comb.mux"(%704, %12, %729) <{twoState}> {sv.namehint = "brType_10"} : (i1, i2, i2) -> i2
    %731 = "comb.extract"(%arg10) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_50"} : (i16) -> i1
    %732 = "comb.extract"(%arg10) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_81"} : (i16) -> i1
    %733 = "comb.extract"(%arg10) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_82"} : (i16) -> i2
    %734 = "comb.extract"(%arg10) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_83"} : (i16) -> i1
    %735 = "comb.extract"(%arg10) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_41"} : (i16) -> i1
    %736 = "comb.extract"(%arg10) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_52"} : (i16) -> i1
    %737 = "comb.extract"(%arg10) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_86"} : (i16) -> i1
    %738 = "comb.extract"(%arg10) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_87"} : (i16) -> i3
    %739 = "comb.extract"(%arg11) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_40"} : (i16) -> i1
    %740 = "comb.extract"(%arg10) <{lowBit = 12 : i32}> : (i16) -> i4
    %741 = "comb.extract"(%arg11) <{lowBit = 0 : i32}> : (i16) -> i4
    %742 = "comb.extract"(%arg11) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_42"} : (i16) -> i1
    %743 = "comb.extract"(%arg11) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_43"} : (i16) -> i10
    %744 = "comb.replicate"(%731) : (i1) -> i10
    %745 = "comb.concat"(%744, %732, %733, %734, %735, %736, %737, %738) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %746 = "comb.concat"(%739, %741, %740, %742, %743) : (i1, i4, i4, i1, i10) -> i20
    %747 = "comb.mux"(%700, %745, %746) <{twoState}> : (i1, i20, i20) -> i20
    %748 = "comb.extract"(%747) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_32"} : (i20) -> i1
    %749 = "comb.extract"(%arg10) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_51"} : (i16) -> i2
    %750 = "comb.extract"(%arg10) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_53"} : (i16) -> i2
    %751 = "comb.extract"(%arg10) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_54"} : (i16) -> i2
    %752 = "comb.extract"(%arg11) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_42"} : (i16) -> i6
    %753 = "comb.extract"(%arg10) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_43"} : (i16) -> i4
    %754 = "comb.replicate"(%731) : (i1) -> i5
    %755 = "comb.concat"(%754, %749, %736, %750, %751) : (i5, i2, i1, i2, i2) -> i12
    %756 = "comb.concat"(%739, %735, %752, %753) : (i1, i1, i6, i4) -> i12
    %757 = "comb.mux"(%700, %755, %756) <{twoState}> : (i1, i12, i12) -> i12
    %758 = "comb.extract"(%757) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_32"} : (i12) -> i1
    %759 = "comb.icmp"(%730, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_10_T"} : (i2, i2) -> i1
    %760 = "comb.replicate"(%758) : (i1) -> i51
    %761 = "comb.concat"(%760, %757) : (i51, i12) -> i63
    %762 = "comb.replicate"(%748) : (i1) -> i43
    %763 = "comb.concat"(%762, %747) : (i43, i20) -> i63
    %764 = "comb.mux"(%759, %761, %763) <{twoState}> : (i1, i63, i63) -> i63
    %765 = "comb.concat"(%764, %9) {sv.namehint = "io_out_jumpOffset_10"} : (i63, i1) -> i64
    %766 = "comb.extract"(%arg11) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_111"} : (i16) -> i2
    %767 = "comb.icmp"(%766, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_11"} : (i2, i2) -> i1
    %768 = "comb.extract"(%arg11) <{lowBit = 13 : i32}> : (i16) -> i3
    %769 = "comb.extract"(%arg11) <{lowBit = 0 : i32}> : (i16) -> i12
    %770 = "comb.concat"(%768, %769) : (i3, i12) -> i15
    %771 = "comb.icmp"(%770, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_221"} : (i15, i15) -> i1
    %772 = "comb.extract"(%arg11) <{lowBit = 13 : i32}> : (i16) -> i3
    %773 = "comb.extract"(%arg11) <{lowBit = 0 : i32}> : (i16) -> i2
    %774 = "comb.concat"(%772, %773) : (i3, i2) -> i5
    %775 = "comb.icmp"(%774, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_223"} : (i5, i5) -> i1
    %776 = "comb.extract"(%arg11) <{lowBit = 13 : i32}> : (i16) -> i3
    %777 = "comb.extract"(%arg11) <{lowBit = 0 : i32}> : (i16) -> i7
    %778 = "comb.concat"(%776, %777) : (i3, i7) -> i10
    %779 = "comb.icmp"(%778, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_225"} : (i10, i10) -> i1
    %780 = "comb.extract"(%arg11) <{lowBit = 14 : i32}> : (i16) -> i2
    %781 = "comb.extract"(%arg11) <{lowBit = 0 : i32}> : (i16) -> i2
    %782 = "comb.concat"(%780, %781) : (i2, i2) -> i4
    %783 = "comb.icmp"(%782, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_227"} : (i4, i4) -> i1
    %784 = "comb.extract"(%arg11) <{lowBit = 0 : i32}> : (i16) -> i7
    %785 = "comb.icmp"(%784, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_229"} : (i7, i7) -> i1
    %786 = "comb.extract"(%arg11) <{lowBit = 12 : i32}> : (i16) -> i3
    %787 = "comb.extract"(%arg11) <{lowBit = 0 : i32}> : (i16) -> i7
    %788 = "comb.concat"(%786, %787) : (i3, i7) -> i10
    %789 = "comb.icmp"(%788, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_231"} : (i10, i10) -> i1
    %790 = "comb.icmp"(%784, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_234"} : (i7, i7) -> i1
    %791 = "comb.concat"(%9, %790) : (i1, i1) -> i2
    %792 = "comb.mux"(%789, %7, %791) <{twoState}> {sv.namehint = "_brType_T_235"} : (i1, i2, i2) -> i2
    %793 = "comb.mux"(%785, %8, %792) <{twoState}> {sv.namehint = "_brType_T_236"} : (i1, i2, i2) -> i2
    %794 = "comb.mux"(%783, %11, %793) <{twoState}> {sv.namehint = "_brType_T_237"} : (i1, i2, i2) -> i2
    %795 = "comb.mux"(%779, %7, %794) <{twoState}> {sv.namehint = "_brType_T_238"} : (i1, i2, i2) -> i2
    %796 = "comb.mux"(%775, %8, %795) <{twoState}> {sv.namehint = "_brType_T_239"} : (i1, i2, i2) -> i2
    %797 = "comb.mux"(%771, %12, %796) <{twoState}> {sv.namehint = "brType_11"} : (i1, i2, i2) -> i2
    %798 = "comb.extract"(%arg11) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_55"} : (i16) -> i1
    %799 = "comb.extract"(%arg11) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_89"} : (i16) -> i1
    %800 = "comb.extract"(%arg11) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_90"} : (i16) -> i2
    %801 = "comb.extract"(%arg11) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_91"} : (i16) -> i1
    %802 = "comb.extract"(%arg11) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_45"} : (i16) -> i1
    %803 = "comb.extract"(%arg11) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_57"} : (i16) -> i1
    %804 = "comb.extract"(%arg11) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_94"} : (i16) -> i1
    %805 = "comb.extract"(%arg11) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_95"} : (i16) -> i3
    %806 = "comb.extract"(%arg12) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_44"} : (i16) -> i1
    %807 = "comb.extract"(%arg11) <{lowBit = 12 : i32}> : (i16) -> i4
    %808 = "comb.extract"(%arg12) <{lowBit = 0 : i32}> : (i16) -> i4
    %809 = "comb.extract"(%arg12) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_46"} : (i16) -> i1
    %810 = "comb.extract"(%arg12) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_47"} : (i16) -> i10
    %811 = "comb.replicate"(%798) : (i1) -> i10
    %812 = "comb.concat"(%811, %799, %800, %801, %802, %803, %804, %805) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %813 = "comb.concat"(%806, %808, %807, %809, %810) : (i1, i4, i4, i1, i10) -> i20
    %814 = "comb.mux"(%767, %812, %813) <{twoState}> : (i1, i20, i20) -> i20
    %815 = "comb.extract"(%814) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_35"} : (i20) -> i1
    %816 = "comb.extract"(%arg11) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_56"} : (i16) -> i2
    %817 = "comb.extract"(%arg11) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_58"} : (i16) -> i2
    %818 = "comb.extract"(%arg11) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_59"} : (i16) -> i2
    %819 = "comb.extract"(%arg12) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_46"} : (i16) -> i6
    %820 = "comb.extract"(%arg11) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_47"} : (i16) -> i4
    %821 = "comb.replicate"(%798) : (i1) -> i5
    %822 = "comb.concat"(%821, %816, %803, %817, %818) : (i5, i2, i1, i2, i2) -> i12
    %823 = "comb.concat"(%806, %802, %819, %820) : (i1, i1, i6, i4) -> i12
    %824 = "comb.mux"(%767, %822, %823) <{twoState}> : (i1, i12, i12) -> i12
    %825 = "comb.extract"(%824) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_35"} : (i12) -> i1
    %826 = "comb.icmp"(%797, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_11_T"} : (i2, i2) -> i1
    %827 = "comb.replicate"(%825) : (i1) -> i51
    %828 = "comb.concat"(%827, %824) : (i51, i12) -> i63
    %829 = "comb.replicate"(%815) : (i1) -> i43
    %830 = "comb.concat"(%829, %814) : (i43, i20) -> i63
    %831 = "comb.mux"(%826, %828, %830) <{twoState}> : (i1, i63, i63) -> i63
    %832 = "comb.concat"(%831, %9) {sv.namehint = "io_out_jumpOffset_11"} : (i63, i1) -> i64
    %833 = "comb.extract"(%arg12) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_121"} : (i16) -> i2
    %834 = "comb.icmp"(%833, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_12"} : (i2, i2) -> i1
    %835 = "comb.extract"(%arg12) <{lowBit = 13 : i32}> : (i16) -> i3
    %836 = "comb.extract"(%arg12) <{lowBit = 0 : i32}> : (i16) -> i12
    %837 = "comb.concat"(%835, %836) : (i3, i12) -> i15
    %838 = "comb.icmp"(%837, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_241"} : (i15, i15) -> i1
    %839 = "comb.extract"(%arg12) <{lowBit = 13 : i32}> : (i16) -> i3
    %840 = "comb.extract"(%arg12) <{lowBit = 0 : i32}> : (i16) -> i2
    %841 = "comb.concat"(%839, %840) : (i3, i2) -> i5
    %842 = "comb.icmp"(%841, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_243"} : (i5, i5) -> i1
    %843 = "comb.extract"(%arg12) <{lowBit = 13 : i32}> : (i16) -> i3
    %844 = "comb.extract"(%arg12) <{lowBit = 0 : i32}> : (i16) -> i7
    %845 = "comb.concat"(%843, %844) : (i3, i7) -> i10
    %846 = "comb.icmp"(%845, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_245"} : (i10, i10) -> i1
    %847 = "comb.extract"(%arg12) <{lowBit = 14 : i32}> : (i16) -> i2
    %848 = "comb.extract"(%arg12) <{lowBit = 0 : i32}> : (i16) -> i2
    %849 = "comb.concat"(%847, %848) : (i2, i2) -> i4
    %850 = "comb.icmp"(%849, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_247"} : (i4, i4) -> i1
    %851 = "comb.extract"(%arg12) <{lowBit = 0 : i32}> : (i16) -> i7
    %852 = "comb.icmp"(%851, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_249"} : (i7, i7) -> i1
    %853 = "comb.extract"(%arg12) <{lowBit = 12 : i32}> : (i16) -> i3
    %854 = "comb.extract"(%arg12) <{lowBit = 0 : i32}> : (i16) -> i7
    %855 = "comb.concat"(%853, %854) : (i3, i7) -> i10
    %856 = "comb.icmp"(%855, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_251"} : (i10, i10) -> i1
    %857 = "comb.icmp"(%851, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_254"} : (i7, i7) -> i1
    %858 = "comb.concat"(%9, %857) : (i1, i1) -> i2
    %859 = "comb.mux"(%856, %7, %858) <{twoState}> {sv.namehint = "_brType_T_255"} : (i1, i2, i2) -> i2
    %860 = "comb.mux"(%852, %8, %859) <{twoState}> {sv.namehint = "_brType_T_256"} : (i1, i2, i2) -> i2
    %861 = "comb.mux"(%850, %11, %860) <{twoState}> {sv.namehint = "_brType_T_257"} : (i1, i2, i2) -> i2
    %862 = "comb.mux"(%846, %7, %861) <{twoState}> {sv.namehint = "_brType_T_258"} : (i1, i2, i2) -> i2
    %863 = "comb.mux"(%842, %8, %862) <{twoState}> {sv.namehint = "_brType_T_259"} : (i1, i2, i2) -> i2
    %864 = "comb.mux"(%838, %12, %863) <{twoState}> {sv.namehint = "brType_12"} : (i1, i2, i2) -> i2
    %865 = "comb.extract"(%arg12) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_60"} : (i16) -> i1
    %866 = "comb.extract"(%arg12) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_97"} : (i16) -> i1
    %867 = "comb.extract"(%arg12) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_98"} : (i16) -> i2
    %868 = "comb.extract"(%arg12) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_99"} : (i16) -> i1
    %869 = "comb.extract"(%arg12) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_49"} : (i16) -> i1
    %870 = "comb.extract"(%arg12) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_62"} : (i16) -> i1
    %871 = "comb.extract"(%arg12) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_102"} : (i16) -> i1
    %872 = "comb.extract"(%arg12) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_103"} : (i16) -> i3
    %873 = "comb.extract"(%arg13) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_48"} : (i16) -> i1
    %874 = "comb.extract"(%arg12) <{lowBit = 12 : i32}> : (i16) -> i4
    %875 = "comb.extract"(%arg13) <{lowBit = 0 : i32}> : (i16) -> i4
    %876 = "comb.extract"(%arg13) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_50"} : (i16) -> i1
    %877 = "comb.extract"(%arg13) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_51"} : (i16) -> i10
    %878 = "comb.replicate"(%865) : (i1) -> i10
    %879 = "comb.concat"(%878, %866, %867, %868, %869, %870, %871, %872) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %880 = "comb.concat"(%873, %875, %874, %876, %877) : (i1, i4, i4, i1, i10) -> i20
    %881 = "comb.mux"(%834, %879, %880) <{twoState}> : (i1, i20, i20) -> i20
    %882 = "comb.extract"(%881) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_38"} : (i20) -> i1
    %883 = "comb.extract"(%arg12) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_61"} : (i16) -> i2
    %884 = "comb.extract"(%arg12) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_63"} : (i16) -> i2
    %885 = "comb.extract"(%arg12) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_64"} : (i16) -> i2
    %886 = "comb.extract"(%arg13) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_50"} : (i16) -> i6
    %887 = "comb.extract"(%arg12) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_51"} : (i16) -> i4
    %888 = "comb.replicate"(%865) : (i1) -> i5
    %889 = "comb.concat"(%888, %883, %870, %884, %885) : (i5, i2, i1, i2, i2) -> i12
    %890 = "comb.concat"(%873, %869, %886, %887) : (i1, i1, i6, i4) -> i12
    %891 = "comb.mux"(%834, %889, %890) <{twoState}> : (i1, i12, i12) -> i12
    %892 = "comb.extract"(%891) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_38"} : (i12) -> i1
    %893 = "comb.icmp"(%864, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_12_T"} : (i2, i2) -> i1
    %894 = "comb.replicate"(%892) : (i1) -> i51
    %895 = "comb.concat"(%894, %891) : (i51, i12) -> i63
    %896 = "comb.replicate"(%882) : (i1) -> i43
    %897 = "comb.concat"(%896, %881) : (i43, i20) -> i63
    %898 = "comb.mux"(%893, %895, %897) <{twoState}> : (i1, i63, i63) -> i63
    %899 = "comb.concat"(%898, %9) {sv.namehint = "io_out_jumpOffset_12"} : (i63, i1) -> i64
    %900 = "comb.extract"(%arg13) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_131"} : (i16) -> i2
    %901 = "comb.icmp"(%900, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_13"} : (i2, i2) -> i1
    %902 = "comb.extract"(%arg13) <{lowBit = 13 : i32}> : (i16) -> i3
    %903 = "comb.extract"(%arg13) <{lowBit = 0 : i32}> : (i16) -> i12
    %904 = "comb.concat"(%902, %903) : (i3, i12) -> i15
    %905 = "comb.icmp"(%904, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_261"} : (i15, i15) -> i1
    %906 = "comb.extract"(%arg13) <{lowBit = 13 : i32}> : (i16) -> i3
    %907 = "comb.extract"(%arg13) <{lowBit = 0 : i32}> : (i16) -> i2
    %908 = "comb.concat"(%906, %907) : (i3, i2) -> i5
    %909 = "comb.icmp"(%908, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_263"} : (i5, i5) -> i1
    %910 = "comb.extract"(%arg13) <{lowBit = 13 : i32}> : (i16) -> i3
    %911 = "comb.extract"(%arg13) <{lowBit = 0 : i32}> : (i16) -> i7
    %912 = "comb.concat"(%910, %911) : (i3, i7) -> i10
    %913 = "comb.icmp"(%912, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_265"} : (i10, i10) -> i1
    %914 = "comb.extract"(%arg13) <{lowBit = 14 : i32}> : (i16) -> i2
    %915 = "comb.extract"(%arg13) <{lowBit = 0 : i32}> : (i16) -> i2
    %916 = "comb.concat"(%914, %915) : (i2, i2) -> i4
    %917 = "comb.icmp"(%916, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_267"} : (i4, i4) -> i1
    %918 = "comb.extract"(%arg13) <{lowBit = 0 : i32}> : (i16) -> i7
    %919 = "comb.icmp"(%918, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_269"} : (i7, i7) -> i1
    %920 = "comb.extract"(%arg13) <{lowBit = 12 : i32}> : (i16) -> i3
    %921 = "comb.extract"(%arg13) <{lowBit = 0 : i32}> : (i16) -> i7
    %922 = "comb.concat"(%920, %921) : (i3, i7) -> i10
    %923 = "comb.icmp"(%922, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_271"} : (i10, i10) -> i1
    %924 = "comb.icmp"(%918, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_274"} : (i7, i7) -> i1
    %925 = "comb.concat"(%9, %924) : (i1, i1) -> i2
    %926 = "comb.mux"(%923, %7, %925) <{twoState}> {sv.namehint = "_brType_T_275"} : (i1, i2, i2) -> i2
    %927 = "comb.mux"(%919, %8, %926) <{twoState}> {sv.namehint = "_brType_T_276"} : (i1, i2, i2) -> i2
    %928 = "comb.mux"(%917, %11, %927) <{twoState}> {sv.namehint = "_brType_T_277"} : (i1, i2, i2) -> i2
    %929 = "comb.mux"(%913, %7, %928) <{twoState}> {sv.namehint = "_brType_T_278"} : (i1, i2, i2) -> i2
    %930 = "comb.mux"(%909, %8, %929) <{twoState}> {sv.namehint = "_brType_T_279"} : (i1, i2, i2) -> i2
    %931 = "comb.mux"(%905, %12, %930) <{twoState}> {sv.namehint = "brType_13"} : (i1, i2, i2) -> i2
    %932 = "comb.extract"(%arg13) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_65"} : (i16) -> i1
    %933 = "comb.extract"(%arg13) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_105"} : (i16) -> i1
    %934 = "comb.extract"(%arg13) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_106"} : (i16) -> i2
    %935 = "comb.extract"(%arg13) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_107"} : (i16) -> i1
    %936 = "comb.extract"(%arg13) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_53"} : (i16) -> i1
    %937 = "comb.extract"(%arg13) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_67"} : (i16) -> i1
    %938 = "comb.extract"(%arg13) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_110"} : (i16) -> i1
    %939 = "comb.extract"(%arg13) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_111"} : (i16) -> i3
    %940 = "comb.extract"(%arg14) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_52"} : (i16) -> i1
    %941 = "comb.extract"(%arg13) <{lowBit = 12 : i32}> : (i16) -> i4
    %942 = "comb.extract"(%arg14) <{lowBit = 0 : i32}> : (i16) -> i4
    %943 = "comb.extract"(%arg14) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_54"} : (i16) -> i1
    %944 = "comb.extract"(%arg14) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_55"} : (i16) -> i10
    %945 = "comb.replicate"(%932) : (i1) -> i10
    %946 = "comb.concat"(%945, %933, %934, %935, %936, %937, %938, %939) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %947 = "comb.concat"(%940, %942, %941, %943, %944) : (i1, i4, i4, i1, i10) -> i20
    %948 = "comb.mux"(%901, %946, %947) <{twoState}> : (i1, i20, i20) -> i20
    %949 = "comb.extract"(%948) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_41"} : (i20) -> i1
    %950 = "comb.extract"(%arg13) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_66"} : (i16) -> i2
    %951 = "comb.extract"(%arg13) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_68"} : (i16) -> i2
    %952 = "comb.extract"(%arg13) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_69"} : (i16) -> i2
    %953 = "comb.extract"(%arg14) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_54"} : (i16) -> i6
    %954 = "comb.extract"(%arg13) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_55"} : (i16) -> i4
    %955 = "comb.replicate"(%932) : (i1) -> i5
    %956 = "comb.concat"(%955, %950, %937, %951, %952) : (i5, i2, i1, i2, i2) -> i12
    %957 = "comb.concat"(%940, %936, %953, %954) : (i1, i1, i6, i4) -> i12
    %958 = "comb.mux"(%901, %956, %957) <{twoState}> : (i1, i12, i12) -> i12
    %959 = "comb.extract"(%958) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_41"} : (i12) -> i1
    %960 = "comb.icmp"(%931, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_13_T"} : (i2, i2) -> i1
    %961 = "comb.replicate"(%959) : (i1) -> i51
    %962 = "comb.concat"(%961, %958) : (i51, i12) -> i63
    %963 = "comb.replicate"(%949) : (i1) -> i43
    %964 = "comb.concat"(%963, %948) : (i43, i20) -> i63
    %965 = "comb.mux"(%960, %962, %964) <{twoState}> : (i1, i63, i63) -> i63
    %966 = "comb.concat"(%965, %9) {sv.namehint = "io_out_jumpOffset_13"} : (i63, i1) -> i64
    %967 = "comb.extract"(%arg14) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_141"} : (i16) -> i2
    %968 = "comb.icmp"(%967, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_14"} : (i2, i2) -> i1
    %969 = "comb.extract"(%arg14) <{lowBit = 13 : i32}> : (i16) -> i3
    %970 = "comb.extract"(%arg14) <{lowBit = 0 : i32}> : (i16) -> i12
    %971 = "comb.concat"(%969, %970) : (i3, i12) -> i15
    %972 = "comb.icmp"(%971, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_281"} : (i15, i15) -> i1
    %973 = "comb.extract"(%arg14) <{lowBit = 13 : i32}> : (i16) -> i3
    %974 = "comb.extract"(%arg14) <{lowBit = 0 : i32}> : (i16) -> i2
    %975 = "comb.concat"(%973, %974) : (i3, i2) -> i5
    %976 = "comb.icmp"(%975, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_283"} : (i5, i5) -> i1
    %977 = "comb.extract"(%arg14) <{lowBit = 13 : i32}> : (i16) -> i3
    %978 = "comb.extract"(%arg14) <{lowBit = 0 : i32}> : (i16) -> i7
    %979 = "comb.concat"(%977, %978) : (i3, i7) -> i10
    %980 = "comb.icmp"(%979, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_285"} : (i10, i10) -> i1
    %981 = "comb.extract"(%arg14) <{lowBit = 14 : i32}> : (i16) -> i2
    %982 = "comb.extract"(%arg14) <{lowBit = 0 : i32}> : (i16) -> i2
    %983 = "comb.concat"(%981, %982) : (i2, i2) -> i4
    %984 = "comb.icmp"(%983, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_287"} : (i4, i4) -> i1
    %985 = "comb.extract"(%arg14) <{lowBit = 0 : i32}> : (i16) -> i7
    %986 = "comb.icmp"(%985, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_289"} : (i7, i7) -> i1
    %987 = "comb.extract"(%arg14) <{lowBit = 12 : i32}> : (i16) -> i3
    %988 = "comb.extract"(%arg14) <{lowBit = 0 : i32}> : (i16) -> i7
    %989 = "comb.concat"(%987, %988) : (i3, i7) -> i10
    %990 = "comb.icmp"(%989, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_291"} : (i10, i10) -> i1
    %991 = "comb.icmp"(%985, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_294"} : (i7, i7) -> i1
    %992 = "comb.concat"(%9, %991) : (i1, i1) -> i2
    %993 = "comb.mux"(%990, %7, %992) <{twoState}> {sv.namehint = "_brType_T_295"} : (i1, i2, i2) -> i2
    %994 = "comb.mux"(%986, %8, %993) <{twoState}> {sv.namehint = "_brType_T_296"} : (i1, i2, i2) -> i2
    %995 = "comb.mux"(%984, %11, %994) <{twoState}> {sv.namehint = "_brType_T_297"} : (i1, i2, i2) -> i2
    %996 = "comb.mux"(%980, %7, %995) <{twoState}> {sv.namehint = "_brType_T_298"} : (i1, i2, i2) -> i2
    %997 = "comb.mux"(%976, %8, %996) <{twoState}> {sv.namehint = "_brType_T_299"} : (i1, i2, i2) -> i2
    %998 = "comb.mux"(%972, %12, %997) <{twoState}> {sv.namehint = "brType_14"} : (i1, i2, i2) -> i2
    %999 = "comb.extract"(%arg14) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_70"} : (i16) -> i1
    %1000 = "comb.extract"(%arg14) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_113"} : (i16) -> i1
    %1001 = "comb.extract"(%arg14) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_114"} : (i16) -> i2
    %1002 = "comb.extract"(%arg14) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_115"} : (i16) -> i1
    %1003 = "comb.extract"(%arg14) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_57"} : (i16) -> i1
    %1004 = "comb.extract"(%arg14) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_72"} : (i16) -> i1
    %1005 = "comb.extract"(%arg14) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_118"} : (i16) -> i1
    %1006 = "comb.extract"(%arg14) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_119"} : (i16) -> i3
    %1007 = "comb.extract"(%arg15) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_56"} : (i16) -> i1
    %1008 = "comb.extract"(%arg14) <{lowBit = 12 : i32}> : (i16) -> i4
    %1009 = "comb.extract"(%arg15) <{lowBit = 0 : i32}> : (i16) -> i4
    %1010 = "comb.extract"(%arg15) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_58"} : (i16) -> i1
    %1011 = "comb.extract"(%arg15) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_59"} : (i16) -> i10
    %1012 = "comb.replicate"(%999) : (i1) -> i10
    %1013 = "comb.concat"(%1012, %1000, %1001, %1002, %1003, %1004, %1005, %1006) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %1014 = "comb.concat"(%1007, %1009, %1008, %1010, %1011) : (i1, i4, i4, i1, i10) -> i20
    %1015 = "comb.mux"(%968, %1013, %1014) <{twoState}> : (i1, i20, i20) -> i20
    %1016 = "comb.extract"(%1015) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_44"} : (i20) -> i1
    %1017 = "comb.extract"(%arg14) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_71"} : (i16) -> i2
    %1018 = "comb.extract"(%arg14) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_73"} : (i16) -> i2
    %1019 = "comb.extract"(%arg14) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_74"} : (i16) -> i2
    %1020 = "comb.extract"(%arg15) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_58"} : (i16) -> i6
    %1021 = "comb.extract"(%arg14) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_59"} : (i16) -> i4
    %1022 = "comb.replicate"(%999) : (i1) -> i5
    %1023 = "comb.concat"(%1022, %1017, %1004, %1018, %1019) : (i5, i2, i1, i2, i2) -> i12
    %1024 = "comb.concat"(%1007, %1003, %1020, %1021) : (i1, i1, i6, i4) -> i12
    %1025 = "comb.mux"(%968, %1023, %1024) <{twoState}> : (i1, i12, i12) -> i12
    %1026 = "comb.extract"(%1025) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_44"} : (i12) -> i1
    %1027 = "comb.icmp"(%998, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_14_T"} : (i2, i2) -> i1
    %1028 = "comb.replicate"(%1026) : (i1) -> i51
    %1029 = "comb.concat"(%1028, %1025) : (i51, i12) -> i63
    %1030 = "comb.replicate"(%1016) : (i1) -> i43
    %1031 = "comb.concat"(%1030, %1015) : (i43, i20) -> i63
    %1032 = "comb.mux"(%1027, %1029, %1031) <{twoState}> : (i1, i63, i63) -> i63
    %1033 = "comb.concat"(%1032, %9) {sv.namehint = "io_out_jumpOffset_14"} : (i63, i1) -> i64
    %1034 = "comb.extract"(%arg15) <{lowBit = 0 : i32}> {sv.namehint = "_isCall_T_151"} : (i16) -> i2
    %1035 = "comb.icmp"(%1034, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "currentIsRVC_15"} : (i2, i2) -> i1
    %1036 = "comb.extract"(%arg15) <{lowBit = 13 : i32}> : (i16) -> i3
    %1037 = "comb.extract"(%arg15) <{lowBit = 0 : i32}> : (i16) -> i12
    %1038 = "comb.concat"(%1036, %1037) : (i3, i12) -> i15
    %1039 = "comb.icmp"(%1038, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_301"} : (i15, i15) -> i1
    %1040 = "comb.extract"(%arg15) <{lowBit = 13 : i32}> : (i16) -> i3
    %1041 = "comb.extract"(%arg15) <{lowBit = 0 : i32}> : (i16) -> i2
    %1042 = "comb.concat"(%1040, %1041) : (i3, i2) -> i5
    %1043 = "comb.icmp"(%1042, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_303"} : (i5, i5) -> i1
    %1044 = "comb.extract"(%arg15) <{lowBit = 13 : i32}> : (i16) -> i3
    %1045 = "comb.extract"(%arg15) <{lowBit = 0 : i32}> : (i16) -> i7
    %1046 = "comb.concat"(%1044, %1045) : (i3, i7) -> i10
    %1047 = "comb.icmp"(%1046, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_305"} : (i10, i10) -> i1
    %1048 = "comb.extract"(%arg15) <{lowBit = 14 : i32}> : (i16) -> i2
    %1049 = "comb.extract"(%arg15) <{lowBit = 0 : i32}> : (i16) -> i2
    %1050 = "comb.concat"(%1048, %1049) : (i2, i2) -> i4
    %1051 = "comb.icmp"(%1050, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_307"} : (i4, i4) -> i1
    %1052 = "comb.extract"(%arg15) <{lowBit = 0 : i32}> : (i16) -> i7
    %1053 = "comb.icmp"(%1052, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_309"} : (i7, i7) -> i1
    %1054 = "comb.extract"(%arg15) <{lowBit = 12 : i32}> : (i16) -> i3
    %1055 = "comb.extract"(%arg15) <{lowBit = 0 : i32}> : (i16) -> i7
    %1056 = "comb.concat"(%1054, %1055) : (i3, i7) -> i10
    %1057 = "comb.icmp"(%1056, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_311"} : (i10, i10) -> i1
    %1058 = "comb.icmp"(%1052, %0) <{predicate = 0 : i64, twoState}> {sv.namehint = "_brType_T_314"} : (i7, i7) -> i1
    %1059 = "comb.concat"(%9, %1058) : (i1, i1) -> i2
    %1060 = "comb.mux"(%1057, %7, %1059) <{twoState}> {sv.namehint = "_brType_T_315"} : (i1, i2, i2) -> i2
    %1061 = "comb.mux"(%1053, %8, %1060) <{twoState}> {sv.namehint = "_brType_T_316"} : (i1, i2, i2) -> i2
    %1062 = "comb.mux"(%1051, %11, %1061) <{twoState}> {sv.namehint = "_brType_T_317"} : (i1, i2, i2) -> i2
    %1063 = "comb.mux"(%1047, %7, %1062) <{twoState}> {sv.namehint = "_brType_T_318"} : (i1, i2, i2) -> i2
    %1064 = "comb.mux"(%1043, %8, %1063) <{twoState}> {sv.namehint = "_brType_T_319"} : (i1, i2, i2) -> i2
    %1065 = "comb.mux"(%1039, %12, %1064) <{twoState}> {sv.namehint = "brType_15"} : (i1, i2, i2) -> i2
    %1066 = "comb.extract"(%arg15) <{lowBit = 12 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_75"} : (i16) -> i1
    %1067 = "comb.extract"(%arg15) <{lowBit = 8 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_121"} : (i16) -> i1
    %1068 = "comb.extract"(%arg15) <{lowBit = 9 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_122"} : (i16) -> i2
    %1069 = "comb.extract"(%arg15) <{lowBit = 6 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_123"} : (i16) -> i1
    %1070 = "comb.extract"(%arg15) <{lowBit = 7 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_61"} : (i16) -> i1
    %1071 = "comb.extract"(%arg15) <{lowBit = 2 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_77"} : (i16) -> i1
    %1072 = "comb.extract"(%arg15) <{lowBit = 11 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_126"} : (i16) -> i1
    %1073 = "comb.extract"(%arg15) <{lowBit = 3 : i32}> {sv.namehint = "_jalOffset_rvc_offset_T_127"} : (i16) -> i3
    %1074 = "comb.extract"(%arg16) <{lowBit = 15 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_60"} : (i16) -> i1
    %1075 = "comb.extract"(%arg15) <{lowBit = 12 : i32}> : (i16) -> i4
    %1076 = "comb.extract"(%arg16) <{lowBit = 0 : i32}> : (i16) -> i4
    %1077 = "comb.extract"(%arg16) <{lowBit = 4 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_62"} : (i16) -> i1
    %1078 = "comb.extract"(%arg16) <{lowBit = 5 : i32}> {sv.namehint = "_jalOffset_rvi_offset_T_63"} : (i16) -> i10
    %1079 = "comb.replicate"(%1066) : (i1) -> i10
    %1080 = "comb.concat"(%1079, %1067, %1068, %1069, %1070, %1071, %1072, %1073) : (i10, i1, i2, i1, i1, i1, i1, i3) -> i20
    %1081 = "comb.concat"(%1074, %1076, %1075, %1077, %1078) : (i1, i4, i4, i1, i10) -> i20
    %1082 = "comb.mux"(%1035, %1080, %1081) <{twoState}> : (i1, i20, i20) -> i20
    %1083 = "comb.extract"(%1082) <{lowBit = 19 : i32}> {sv.namehint = "jalOffset_signBit_47"} : (i20) -> i1
    %1084 = "comb.extract"(%arg15) <{lowBit = 5 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_76"} : (i16) -> i2
    %1085 = "comb.extract"(%arg15) <{lowBit = 10 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_78"} : (i16) -> i2
    %1086 = "comb.extract"(%arg15) <{lowBit = 3 : i32}> {sv.namehint = "_brOffset_rvc_offset_T_79"} : (i16) -> i2
    %1087 = "comb.extract"(%arg16) <{lowBit = 9 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_62"} : (i16) -> i6
    %1088 = "comb.extract"(%arg15) <{lowBit = 8 : i32}> {sv.namehint = "_brOffset_rvi_offset_T_63"} : (i16) -> i4
    %1089 = "comb.replicate"(%1066) : (i1) -> i5
    %1090 = "comb.concat"(%1089, %1084, %1071, %1085, %1086) : (i5, i2, i1, i2, i2) -> i12
    %1091 = "comb.concat"(%1074, %1070, %1087, %1088) : (i1, i1, i6, i4) -> i12
    %1092 = "comb.mux"(%1035, %1090, %1091) <{twoState}> : (i1, i12, i12) -> i12
    %1093 = "comb.extract"(%1092) <{lowBit = 11 : i32}> {sv.namehint = "brOffset_signBit_47"} : (i12) -> i1
    %1094 = "comb.icmp"(%1065, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_jumpOffset_15_T"} : (i2, i2) -> i1
    %1095 = "comb.replicate"(%1093) : (i1) -> i51
    %1096 = "comb.concat"(%1095, %1092) : (i51, i12) -> i63
    %1097 = "comb.replicate"(%1083) : (i1) -> i43
    %1098 = "comb.concat"(%1097, %1082) : (i43, i20) -> i63
    %1099 = "comb.mux"(%1094, %1096, %1098) <{twoState}> : (i1, i63, i63) -> i63
    %1100 = "comb.concat"(%1099, %9) {sv.namehint = "io_out_jumpOffset_15"} : (i63, i1) -> i64
    %1101 = "comb.and"(%30, %97) <{twoState}> {sv.namehint = "_validEnd_1_T"} : (i1, i1) -> i1
    %1102 = "comb.xor"(%30, %10) <{twoState}> {sv.namehint = "_validEnd_1_T_1"} : (i1, i1) -> i1
    %1103 = "comb.or"(%1101, %1102) <{twoState}> {sv.namehint = "validEnd_1"} : (i1, i1) -> i1
    %1104 = "comb.and"(%1103, %164) <{twoState}> {sv.namehint = "_validEnd_2_T"} : (i1, i1) -> i1
    %1105 = "comb.xor"(%1103, %10) <{twoState}> {sv.namehint = "_validEnd_2_T_1"} : (i1, i1) -> i1
    %1106 = "comb.or"(%1104, %1105) <{twoState}> {sv.namehint = "validEnd_2"} : (i1, i1) -> i1
    %1107 = "comb.and"(%97, %164) <{twoState}> {sv.namehint = "_h_validEnd_2_T"} : (i1, i1) -> i1
    %1108 = "comb.xor"(%97, %10) <{twoState}> {sv.namehint = "_h_validEnd_2_T_1"} : (i1, i1) -> i1
    %1109 = "comb.or"(%1107, %1108) <{twoState}> {sv.namehint = "h_validEnd_2"} : (i1, i1) -> i1
    %1110 = "comb.and"(%1106, %231) <{twoState}> {sv.namehint = "_validEnd_3_T"} : (i1, i1) -> i1
    %1111 = "comb.xor"(%1106, %10) <{twoState}> {sv.namehint = "_validEnd_3_T_1"} : (i1, i1) -> i1
    %1112 = "comb.or"(%1110, %1111) <{twoState}> {sv.namehint = "validEnd_3"} : (i1, i1) -> i1
    %1113 = "comb.and"(%1109, %231) <{twoState}> {sv.namehint = "_h_validEnd_3_T"} : (i1, i1) -> i1
    %1114 = "comb.xor"(%1109, %10) <{twoState}> {sv.namehint = "_h_validEnd_3_T_1"} : (i1, i1) -> i1
    %1115 = "comb.or"(%1113, %1114) <{twoState}> {sv.namehint = "h_validEnd_3"} : (i1, i1) -> i1
    %1116 = "comb.and"(%1112, %298) <{twoState}> {sv.namehint = "_validEnd_4_T"} : (i1, i1) -> i1
    %1117 = "comb.xor"(%1112, %10) <{twoState}> {sv.namehint = "_validEnd_4_T_1"} : (i1, i1) -> i1
    %1118 = "comb.or"(%1116, %1117) <{twoState}> {sv.namehint = "validEnd_4"} : (i1, i1) -> i1
    %1119 = "comb.and"(%1115, %298) <{twoState}> {sv.namehint = "_h_validEnd_4_T"} : (i1, i1) -> i1
    %1120 = "comb.xor"(%1115, %10) <{twoState}> {sv.namehint = "_h_validEnd_4_T_1"} : (i1, i1) -> i1
    %1121 = "comb.or"(%1119, %1120) <{twoState}> {sv.namehint = "h_validEnd_4"} : (i1, i1) -> i1
    %1122 = "comb.and"(%1118, %365) <{twoState}> {sv.namehint = "_validEnd_5_T"} : (i1, i1) -> i1
    %1123 = "comb.xor"(%1118, %10) <{twoState}> {sv.namehint = "_validEnd_5_T_1"} : (i1, i1) -> i1
    %1124 = "comb.or"(%1122, %1123) <{twoState}> {sv.namehint = "validEnd_5"} : (i1, i1) -> i1
    %1125 = "comb.and"(%1121, %365) <{twoState}> {sv.namehint = "_h_validEnd_5_T"} : (i1, i1) -> i1
    %1126 = "comb.xor"(%1121, %10) <{twoState}> {sv.namehint = "_h_validEnd_5_T_1"} : (i1, i1) -> i1
    %1127 = "comb.or"(%1125, %1126) <{twoState}> {sv.namehint = "h_validEnd_5"} : (i1, i1) -> i1
    %1128 = "comb.and"(%1124, %432) <{twoState}> {sv.namehint = "_validEnd_6_T"} : (i1, i1) -> i1
    %1129 = "comb.xor"(%1124, %10) <{twoState}> {sv.namehint = "_validEnd_6_T_1"} : (i1, i1) -> i1
    %1130 = "comb.or"(%1128, %1129) <{twoState}> {sv.namehint = "validEnd_6"} : (i1, i1) -> i1
    %1131 = "comb.and"(%1127, %432) <{twoState}> {sv.namehint = "_h_validEnd_6_T"} : (i1, i1) -> i1
    %1132 = "comb.xor"(%1127, %10) <{twoState}> {sv.namehint = "_h_validEnd_6_T_1"} : (i1, i1) -> i1
    %1133 = "comb.or"(%1131, %1132) <{twoState}> {sv.namehint = "h_validEnd_6"} : (i1, i1) -> i1
    %1134 = "comb.and"(%1130, %499) <{twoState}> {sv.namehint = "_validEnd_7_T"} : (i1, i1) -> i1
    %1135 = "comb.xor"(%1130, %10) <{twoState}> {sv.namehint = "_validEnd_7_T_1"} : (i1, i1) -> i1
    %1136 = "comb.or"(%1134, %1135) <{twoState}> {sv.namehint = "validEnd_7"} : (i1, i1) -> i1
    %1137 = "comb.and"(%1133, %499) <{twoState}> {sv.namehint = "_h_validEnd_7_T"} : (i1, i1) -> i1
    %1138 = "comb.xor"(%1133, %10) <{twoState}> {sv.namehint = "_h_validEnd_7_T_1"} : (i1, i1) -> i1
    %1139 = "comb.or"(%1137, %1138) <{twoState}> {sv.namehint = "h_validEnd_7"} : (i1, i1) -> i1
    %1140 = "comb.and"(%566, %633) <{twoState}> {sv.namehint = "_validEnd_half_9_T"} : (i1, i1) -> i1
    %1141 = "comb.xor"(%566, %10) <{twoState}> {sv.namehint = "_validEnd_half_9_T_1"} : (i1, i1) -> i1
    %1142 = "comb.or"(%1140, %1141) <{twoState}> {sv.namehint = "lastIsValidEnd_23"} : (i1, i1) -> i1
    %1143 = "comb.and"(%566, %633) <{twoState}> {sv.namehint = "_h_validEnd_half_9_T"} : (i1, i1) -> i1
    %1144 = "comb.xor"(%566, %10) <{twoState}> {sv.namehint = "_h_validEnd_half_9_T_1"} : (i1, i1) -> i1
    %1145 = "comb.or"(%1143, %1144) <{twoState}> {sv.namehint = "h_lastIsValidEnd_23"} : (i1, i1) -> i1
    %1146 = "comb.and"(%1142, %700) <{twoState}> {sv.namehint = "_validEnd_half_10_T"} : (i1, i1) -> i1
    %1147 = "comb.xor"(%1142, %10) <{twoState}> {sv.namehint = "_validEnd_half_10_T_1"} : (i1, i1) -> i1
    %1148 = "comb.or"(%1146, %1147) <{twoState}> {sv.namehint = "lastIsValidEnd_24"} : (i1, i1) -> i1
    %1149 = "comb.and"(%1145, %700) <{twoState}> {sv.namehint = "_h_validEnd_half_10_T"} : (i1, i1) -> i1
    %1150 = "comb.xor"(%1145, %10) <{twoState}> {sv.namehint = "_h_validEnd_half_10_T_1"} : (i1, i1) -> i1
    %1151 = "comb.or"(%1149, %1150) <{twoState}> {sv.namehint = "h_lastIsValidEnd_24"} : (i1, i1) -> i1
    %1152 = "comb.and"(%1148, %767) <{twoState}> {sv.namehint = "_validEnd_half_11_T"} : (i1, i1) -> i1
    %1153 = "comb.xor"(%1148, %10) <{twoState}> {sv.namehint = "_validEnd_half_11_T_1"} : (i1, i1) -> i1
    %1154 = "comb.or"(%1152, %1153) <{twoState}> {sv.namehint = "lastIsValidEnd_25"} : (i1, i1) -> i1
    %1155 = "comb.and"(%1151, %767) <{twoState}> {sv.namehint = "_h_validEnd_half_11_T"} : (i1, i1) -> i1
    %1156 = "comb.xor"(%1151, %10) <{twoState}> {sv.namehint = "_h_validEnd_half_11_T_1"} : (i1, i1) -> i1
    %1157 = "comb.or"(%1155, %1156) <{twoState}> {sv.namehint = "h_lastIsValidEnd_25"} : (i1, i1) -> i1
    %1158 = "comb.and"(%1154, %834) <{twoState}> {sv.namehint = "_validEnd_half_12_T"} : (i1, i1) -> i1
    %1159 = "comb.xor"(%1154, %10) <{twoState}> {sv.namehint = "_validEnd_half_12_T_1"} : (i1, i1) -> i1
    %1160 = "comb.or"(%1158, %1159) <{twoState}> {sv.namehint = "lastIsValidEnd_26"} : (i1, i1) -> i1
    %1161 = "comb.and"(%1157, %834) <{twoState}> {sv.namehint = "_h_validEnd_half_12_T"} : (i1, i1) -> i1
    %1162 = "comb.xor"(%1157, %10) <{twoState}> {sv.namehint = "_h_validEnd_half_12_T_1"} : (i1, i1) -> i1
    %1163 = "comb.or"(%1161, %1162) <{twoState}> {sv.namehint = "h_lastIsValidEnd_26"} : (i1, i1) -> i1
    %1164 = "comb.and"(%1160, %901) <{twoState}> {sv.namehint = "_validEnd_half_13_T"} : (i1, i1) -> i1
    %1165 = "comb.xor"(%1160, %10) <{twoState}> {sv.namehint = "_validEnd_half_13_T_1"} : (i1, i1) -> i1
    %1166 = "comb.or"(%1164, %1165) <{twoState}> {sv.namehint = "lastIsValidEnd_27"} : (i1, i1) -> i1
    %1167 = "comb.and"(%1163, %901) <{twoState}> {sv.namehint = "_h_validEnd_half_13_T"} : (i1, i1) -> i1
    %1168 = "comb.xor"(%1163, %10) <{twoState}> {sv.namehint = "_h_validEnd_half_13_T_1"} : (i1, i1) -> i1
    %1169 = "comb.or"(%1167, %1168) <{twoState}> {sv.namehint = "h_lastIsValidEnd_27"} : (i1, i1) -> i1
    %1170 = "comb.and"(%1166, %968) <{twoState}> {sv.namehint = "_validEnd_half_14_T"} : (i1, i1) -> i1
    %1171 = "comb.xor"(%1166, %10) <{twoState}> {sv.namehint = "_validEnd_half_14_T_1"} : (i1, i1) -> i1
    %1172 = "comb.or"(%1170, %1171) <{twoState}> {sv.namehint = "lastIsValidEnd_28"} : (i1, i1) -> i1
    %1173 = "comb.and"(%1169, %968) <{twoState}> {sv.namehint = "_h_validEnd_half_14_T"} : (i1, i1) -> i1
    %1174 = "comb.xor"(%1169, %10) <{twoState}> {sv.namehint = "_h_validEnd_half_14_T_1"} : (i1, i1) -> i1
    %1175 = "comb.or"(%1173, %1174) <{twoState}> {sv.namehint = "h_lastIsValidEnd_28"} : (i1, i1) -> i1
    %1176 = "comb.and"(%633, %700) <{twoState}> {sv.namehint = "_validEnd_halfPlus1_10_T"} : (i1, i1) -> i1
    %1177 = "comb.xor"(%633, %10) <{twoState}> {sv.namehint = "_validEnd_halfPlus1_10_T_1"} : (i1, i1) -> i1
    %1178 = "comb.or"(%1176, %1177) <{twoState}> {sv.namehint = "lastIsValidEnd_30"} : (i1, i1) -> i1
    %1179 = "comb.and"(%633, %700) <{twoState}> {sv.namehint = "_h_validEnd_halfPlus1_10_T"} : (i1, i1) -> i1
    %1180 = "comb.xor"(%633, %10) <{twoState}> {sv.namehint = "_h_validEnd_halfPlus1_10_T_1"} : (i1, i1) -> i1
    %1181 = "comb.or"(%1179, %1180) <{twoState}> {sv.namehint = "h_lastIsValidEnd_30"} : (i1, i1) -> i1
    %1182 = "comb.and"(%1178, %767) <{twoState}> {sv.namehint = "_validEnd_halfPlus1_11_T"} : (i1, i1) -> i1
    %1183 = "comb.xor"(%1178, %10) <{twoState}> {sv.namehint = "_validEnd_halfPlus1_11_T_1"} : (i1, i1) -> i1
    %1184 = "comb.or"(%1182, %1183) <{twoState}> {sv.namehint = "lastIsValidEnd_31"} : (i1, i1) -> i1
    %1185 = "comb.and"(%1181, %767) <{twoState}> {sv.namehint = "_h_validEnd_halfPlus1_11_T"} : (i1, i1) -> i1
    %1186 = "comb.xor"(%1181, %10) <{twoState}> {sv.namehint = "_h_validEnd_halfPlus1_11_T_1"} : (i1, i1) -> i1
    %1187 = "comb.or"(%1185, %1186) <{twoState}> {sv.namehint = "h_lastIsValidEnd_31"} : (i1, i1) -> i1
    %1188 = "comb.and"(%1184, %834) <{twoState}> {sv.namehint = "_validEnd_halfPlus1_12_T"} : (i1, i1) -> i1
    %1189 = "comb.xor"(%1184, %10) <{twoState}> {sv.namehint = "_validEnd_halfPlus1_12_T_1"} : (i1, i1) -> i1
    %1190 = "comb.or"(%1188, %1189) <{twoState}> {sv.namehint = "lastIsValidEnd_32"} : (i1, i1) -> i1
    %1191 = "comb.and"(%1187, %834) <{twoState}> {sv.namehint = "_h_validEnd_halfPlus1_12_T"} : (i1, i1) -> i1
    %1192 = "comb.xor"(%1187, %10) <{twoState}> {sv.namehint = "_h_validEnd_halfPlus1_12_T_1"} : (i1, i1) -> i1
    %1193 = "comb.or"(%1191, %1192) <{twoState}> {sv.namehint = "h_lastIsValidEnd_32"} : (i1, i1) -> i1
    %1194 = "comb.and"(%1190, %901) <{twoState}> {sv.namehint = "_validEnd_halfPlus1_13_T"} : (i1, i1) -> i1
    %1195 = "comb.xor"(%1190, %10) <{twoState}> {sv.namehint = "_validEnd_halfPlus1_13_T_1"} : (i1, i1) -> i1
    %1196 = "comb.or"(%1194, %1195) <{twoState}> {sv.namehint = "lastIsValidEnd_33"} : (i1, i1) -> i1
    %1197 = "comb.and"(%1193, %901) <{twoState}> {sv.namehint = "_h_validEnd_halfPlus1_13_T"} : (i1, i1) -> i1
    %1198 = "comb.xor"(%1193, %10) <{twoState}> {sv.namehint = "_h_validEnd_halfPlus1_13_T_1"} : (i1, i1) -> i1
    %1199 = "comb.or"(%1197, %1198) <{twoState}> {sv.namehint = "h_lastIsValidEnd_33"} : (i1, i1) -> i1
    %1200 = "comb.and"(%1196, %968) <{twoState}> {sv.namehint = "_validEnd_halfPlus1_14_T"} : (i1, i1) -> i1
    %1201 = "comb.xor"(%1196, %10) <{twoState}> {sv.namehint = "_validEnd_halfPlus1_14_T_1"} : (i1, i1) -> i1
    %1202 = "comb.or"(%1200, %1201) <{twoState}> {sv.namehint = "lastIsValidEnd_34"} : (i1, i1) -> i1
    %1203 = "comb.and"(%1199, %968) <{twoState}> {sv.namehint = "_h_validEnd_halfPlus1_14_T"} : (i1, i1) -> i1
    %1204 = "comb.xor"(%1199, %10) <{twoState}> {sv.namehint = "_h_validEnd_halfPlus1_14_T_1"} : (i1, i1) -> i1
    %1205 = "comb.or"(%1203, %1204) <{twoState}> {sv.namehint = "h_lastIsValidEnd_34"} : (i1, i1) -> i1
    %1206 = "comb.xor"(%1136, %10) : (i1, i1) -> i1
    %1207 = "comb.or"(%1206, %566) {sv.namehint = "validStart_9"} : (i1, i1) -> i1
    %1208 = "comb.xor"(%1139, %10) : (i1, i1) -> i1
    %1209 = "comb.or"(%1208, %566) {sv.namehint = "h_validStart_9"} : (i1, i1) -> i1
    %1210 = "comb.mux"(%1136, %1142, %633) <{twoState}> {sv.namehint = "validStart_10"} : (i1, i1, i1) -> i1
    %1211 = "comb.mux"(%1139, %1145, %633) <{twoState}> {sv.namehint = "h_validStart_10"} : (i1, i1, i1) -> i1
    %1212 = "comb.mux"(%1136, %1148, %1178) <{twoState}> {sv.namehint = "validStart_11"} : (i1, i1, i1) -> i1
    %1213 = "comb.mux"(%1139, %1151, %1181) <{twoState}> {sv.namehint = "h_validStart_11"} : (i1, i1, i1) -> i1
    %1214 = "comb.mux"(%1136, %1154, %1184) <{twoState}> {sv.namehint = "validStart_12"} : (i1, i1, i1) -> i1
    %1215 = "comb.mux"(%1139, %1157, %1187) <{twoState}> {sv.namehint = "h_validStart_12"} : (i1, i1, i1) -> i1
    %1216 = "comb.mux"(%1136, %1160, %1190) <{twoState}> {sv.namehint = "validStart_13"} : (i1, i1, i1) -> i1
    %1217 = "comb.mux"(%1139, %1163, %1193) <{twoState}> {sv.namehint = "h_validStart_13"} : (i1, i1, i1) -> i1
    %1218 = "comb.mux"(%1136, %1166, %1196) <{twoState}> {sv.namehint = "validStart_14"} : (i1, i1, i1) -> i1
    %1219 = "comb.mux"(%1139, %1169, %1199) <{twoState}> {sv.namehint = "h_validStart_14"} : (i1, i1, i1) -> i1
    %1220 = "comb.mux"(%1136, %1172, %1202) <{twoState}> {sv.namehint = "validStart_15"} : (i1, i1, i1) -> i1
    %1221 = "comb.mux"(%1139, %1175, %1205) <{twoState}> {sv.namehint = "h_validStart_15"} : (i1, i1, i1) -> i1
    "hw.output"(%30, %30, %97, %1103, %164, %1106, %231, %1112, %298, %1118, %365, %1124, %432, %1130, %499, %1136, %566, %1207, %633, %1210, %700, %1212, %767, %1214, %834, %1216, %901, %1218, %968, %1220, %1035, %97, %1109, %1115, %1121, %1127, %1133, %1139, %1209, %1211, %1213, %1215, %1217, %1219, %1221, %13, %14, %15, %16, %17, %18, %19, %20, %21, %22, %23, %24, %25, %26, %27, %28, %95, %162, %229, %296, %363, %430, %497, %564, %631, %698, %765, %832, %899, %966, %1033, %1100) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64) -> ()
  }) {module_type = !hw.modty<input io_in_bits_data_0 : i16, input io_in_bits_data_1 : i16, input io_in_bits_data_2 : i16, input io_in_bits_data_3 : i16, input io_in_bits_data_4 : i16, input io_in_bits_data_5 : i16, input io_in_bits_data_6 : i16, input io_in_bits_data_7 : i16, input io_in_bits_data_8 : i16, input io_in_bits_data_9 : i16, input io_in_bits_data_10 : i16, input io_in_bits_data_11 : i16, input io_in_bits_data_12 : i16, input io_in_bits_data_13 : i16, input io_in_bits_data_14 : i16, input io_in_bits_data_15 : i16, input io_in_bits_data_16 : i16, output io_out_pd_0_isRVC : i1, output io_out_pd_1_valid : i1, output io_out_pd_1_isRVC : i1, output io_out_pd_2_valid : i1, output io_out_pd_2_isRVC : i1, output io_out_pd_3_valid : i1, output io_out_pd_3_isRVC : i1, output io_out_pd_4_valid : i1, output io_out_pd_4_isRVC : i1, output io_out_pd_5_valid : i1, output io_out_pd_5_isRVC : i1, output io_out_pd_6_valid : i1, output io_out_pd_6_isRVC : i1, output io_out_pd_7_valid : i1, output io_out_pd_7_isRVC : i1, output io_out_pd_8_valid : i1, output io_out_pd_8_isRVC : i1, output io_out_pd_9_valid : i1, output io_out_pd_9_isRVC : i1, output io_out_pd_10_valid : i1, output io_out_pd_10_isRVC : i1, output io_out_pd_11_valid : i1, output io_out_pd_11_isRVC : i1, output io_out_pd_12_valid : i1, output io_out_pd_12_isRVC : i1, output io_out_pd_13_valid : i1, output io_out_pd_13_isRVC : i1, output io_out_pd_14_valid : i1, output io_out_pd_14_isRVC : i1, output io_out_pd_15_valid : i1, output io_out_pd_15_isRVC : i1, output io_out_hasHalfValid_2 : i1, output io_out_hasHalfValid_3 : i1, output io_out_hasHalfValid_4 : i1, output io_out_hasHalfValid_5 : i1, output io_out_hasHalfValid_6 : i1, output io_out_hasHalfValid_7 : i1, output io_out_hasHalfValid_8 : i1, output io_out_hasHalfValid_9 : i1, output io_out_hasHalfValid_10 : i1, output io_out_hasHalfValid_11 : i1, output io_out_hasHalfValid_12 : i1, output io_out_hasHalfValid_13 : i1, output io_out_hasHalfValid_14 : i1, output io_out_hasHalfValid_15 : i1, output io_out_instr_0 : i32, output io_out_instr_1 : i32, output io_out_instr_2 : i32, output io_out_instr_3 : i32, output io_out_instr_4 : i32, output io_out_instr_5 : i32, output io_out_instr_6 : i32, output io_out_instr_7 : i32, output io_out_instr_8 : i32, output io_out_instr_9 : i32, output io_out_instr_10 : i32, output io_out_instr_11 : i32, output io_out_instr_12 : i32, output io_out_instr_13 : i32, output io_out_instr_14 : i32, output io_out_instr_15 : i32, output io_out_jumpOffset_0 : i64, output io_out_jumpOffset_1 : i64, output io_out_jumpOffset_2 : i64, output io_out_jumpOffset_3 : i64, output io_out_jumpOffset_4 : i64, output io_out_jumpOffset_5 : i64, output io_out_jumpOffset_6 : i64, output io_out_jumpOffset_7 : i64, output io_out_jumpOffset_8 : i64, output io_out_jumpOffset_9 : i64, output io_out_jumpOffset_10 : i64, output io_out_jumpOffset_11 : i64, output io_out_jumpOffset_12 : i64, output io_out_jumpOffset_13 : i64, output io_out_jumpOffset_14 : i64, output io_out_jumpOffset_15 : i64>, parameters = [], result_locs = [#loc, #loc1, #loc2, #loc3, #loc4, #loc5, #loc6, #loc7, #loc8, #loc9, #loc10, #loc11, #loc12, #loc13, #loc14, #loc15, #loc16, #loc17, #loc18, #loc19, #loc20, #loc21, #loc22, #loc23, #loc24, #loc25, #loc26, #loc27, #loc28, #loc29, #loc30, #loc31, #loc32, #loc33, #loc34, #loc35, #loc36, #loc37, #loc38, #loc39, #loc40, #loc41, #loc42, #loc43, #loc44, #loc45, #loc46, #loc47, #loc48, #loc49, #loc50, #loc51, #loc52, #loc53, #loc54, #loc55, #loc56, #loc57, #loc58, #loc59, #loc60, #loc61, #loc62, #loc63, #loc64, #loc65, #loc66, #loc67, #loc68, #loc69, #loc70, #loc71, #loc72, #loc73, #loc74, #loc75, #loc76], sym_name = "PreDecode", sym_visibility = "private"} : () -> ()
}) : () -> ()

