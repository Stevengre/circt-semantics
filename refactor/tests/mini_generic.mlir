#loc = loc("mini.mlir":2:123)
#loc1 = loc("mini.mlir":2:281)
#loc2 = loc("mini.mlir":2:299)
#loc3 = loc("mini.mlir":2:318)
#loc4 = loc("mini.mlir":2:402)
#loc5 = loc("mini.mlir":394:98)
#loc6 = loc("mini.mlir":394:119)
#loc7 = loc("mini.mlir":409:86)
#loc8 = loc("mini.mlir":409:104)
#loc9 = loc("mini.mlir":580:73)
#loc10 = loc("mini.mlir":629:94)
#loc11 = loc("mini.mlir":664:141)
#loc12 = loc("mini.mlir":664:167)
#loc13 = loc("mini.mlir":664:197)
#loc14 = loc("mini.mlir":664:299)
#loc15 = loc("mini.mlir":664:325)
#loc16 = loc("mini.mlir":664:355)
#loc17 = loc("mini.mlir":664:390)
#loc18 = loc("mini.mlir":664:425)
#loc19 = loc("mini.mlir":664:526)
#loc20 = loc("mini.mlir":843:53)
#loc21 = loc("mini.mlir":843:73)
#loc22 = loc("mini.mlir":843:96)
#loc23 = loc("mini.mlir":843:115)
#loc24 = loc("mini.mlir":843:134)
#loc25 = loc("mini.mlir":843:155)
#loc26 = loc("mini.mlir":843:175)
#loc27 = loc("mini.mlir":843:196)
#loc28 = loc("mini.mlir":843:217)
#loc29 = loc("mini.mlir":843:238)
#loc30 = loc("mini.mlir":843:258)
#loc31 = loc("mini.mlir":843:277)
#loc32 = loc("mini.mlir":843:298)
#loc33 = loc("mini.mlir":1238:137)
#loc34 = loc("mini.mlir":1238:163)
#loc35 = loc("mini.mlir":1238:193)
#loc36 = loc("mini.mlir":1238:295)
#loc37 = loc("mini.mlir":1238:321)
#loc38 = loc("mini.mlir":1238:351)
#loc39 = loc("mini.mlir":1238:386)
#loc40 = loc("mini.mlir":1238:421)
#loc41 = loc("mini.mlir":1243:217)
#loc42 = loc("mini.mlir":1243:245)
#loc43 = loc("mini.mlir":1243:306)
#loc44 = loc("mini.mlir":1243:334)
#loc45 = loc("mini.mlir":1243:394)
#loc46 = loc("mini.mlir":1243:421)
#loc47 = loc("mini.mlir":1243:453)
#loc48 = loc("mini.mlir":1243:484)
#loc49 = loc("mini.mlir":1243:566)
#loc50 = loc("mini.mlir":1243:594)
#loc51 = loc("mini.mlir":1243:627)
#loc52 = loc("mini.mlir":1445:77)
#loc53 = loc("mini.mlir":1445:197)
#loc54 = loc("mini.mlir":1445:225)
#loc55 = loc("mini.mlir":1445:258)
#loc56 = loc("mini.mlir":1445:350)
#loc57 = loc("mini.mlir":1445:499)
#loc58 = loc("mini.mlir":1445:527)
#loc59 = loc("mini.mlir":1445:647)
#loc60 = loc("mini.mlir":1445:675)
#loc61 = loc("mini.mlir":1445:736)
#loc62 = loc("mini.mlir":1445:764)
#loc63 = loc("mini.mlir":1445:824)
#loc64 = loc("mini.mlir":1445:851)
#loc65 = loc("mini.mlir":1445:883)
#loc66 = loc("mini.mlir":1445:914)
#loc67 = loc("mini.mlir":1445:996)
#loc68 = loc("mini.mlir":1445:1024)
#loc69 = loc("mini.mlir":1445:1057)
#loc70 = loc("mini.mlir":1499:129)
#loc71 = loc("mini.mlir":1499:183)
#loc72 = loc("mini.mlir":1499:211)
#loc73 = loc("mini.mlir":1499:241)
#loc74 = loc("mini.mlir":1499:274)
#loc75 = loc("mini.mlir":1499:305)
#loc76 = loc("mini.mlir":1499:337)
#loc77 = loc("mini.mlir":1499:370)
#loc78 = loc("mini.mlir":1499:402)
#loc79 = loc("mini.mlir":1499:435)
#loc80 = loc("mini.mlir":1499:467)
#loc81 = loc("mini.mlir":1499:525)
#loc82 = loc("mini.mlir":1499:552)
#loc83 = loc("mini.mlir":1499:584)
#loc84 = loc("mini.mlir":1499:615)
#loc85 = loc("mini.mlir":1499:646)
#loc86 = loc("mini.mlir":1499:788)
#loc87 = loc("mini.mlir":1499:816)
#loc88 = loc("mini.mlir":1499:846)
#loc89 = loc("mini.mlir":1499:879)
#loc90 = loc("mini.mlir":1499:910)
#loc91 = loc("mini.mlir":1499:942)
#loc92 = loc("mini.mlir":1499:975)
#loc93 = loc("mini.mlir":1499:1007)
#loc94 = loc("mini.mlir":1499:1040)
#loc95 = loc("mini.mlir":1499:1072)
#loc96 = loc("mini.mlir":1499:1103)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: !seq.clock, %arg1: i1, %arg2: i1, %arg3: i3, %arg4: i32, %arg5: i32, %arg6: i32, %arg7: i32, %arg8: i1, %arg9: i2, %arg10: i3, %arg11: i1, %arg12: i1, %arg13: i32):
    %0 = "hw.constant"() {value = true} : () -> i1
    %1 = "hw.constant"() {value = 0 : i3} : () -> i3
    %2 = "hw.constant"() {value = 1 : i3} : () -> i3
    %3 = "hw.constant"() {value = 0 : i2} : () -> i2
    %4 = "hw.constant"() {value = -8 : i4} : () -> i4
    %5 = "hw.constant"() {value = false} : () -> i1
    %6 = "hw.constant"() {value = 1 : i32} : () -> i32
    %7 = "hw.constant"() {value = 0 : i24} : () -> i24
    %8 = "hw.constant"() {value = 256 : i32} : () -> i32
    %9 = "hw.constant"() {value = 0 : i26} : () -> i26
    %10 = "hw.constant"() {value = 0 : i28} : () -> i28
    %11 = "hw.constant"() {value = 0 : i6} : () -> i6
    %12 = "hw.constant"() {value = -1 : i32} : () -> i32
    %13 = "hw.constant"() {value = 0 : i5} : () -> i5
    %14 = "hw.constant"() {value = -1 : i2} : () -> i2
    %15 = "hw.constant"() {value = -1024 : i12} : () -> i12
    %16 = "hw.constant"() {value = -1023 : i12} : () -> i12
    %17 = "hw.constant"() {value = -1022 : i12} : () -> i12
    %18 = "hw.constant"() {value = -896 : i12} : () -> i12
    %19 = "hw.constant"() {value = -895 : i12} : () -> i12
    %20 = "hw.constant"() {value = -894 : i12} : () -> i12
    %21 = "hw.constant"() {value = -1792 : i12} : () -> i12
    %22 = "hw.constant"() {value = -1791 : i12} : () -> i12
    %23 = "hw.constant"() {value = -1790 : i12} : () -> i12
    %24 = "hw.constant"() {value = -1664 : i12} : () -> i12
    %25 = "hw.constant"() {value = -1663 : i12} : () -> i12
    %26 = "hw.constant"() {value = -1662 : i12} : () -> i12
    %27 = "hw.constant"() {value = -256 : i12} : () -> i12
    %28 = "hw.constant"() {value = -255 : i12} : () -> i12
    %29 = "hw.constant"() {value = -240 : i12} : () -> i12
    %30 = "hw.constant"() {value = -4 : i3} : () -> i3
    %31 = "hw.constant"() {value = 769 : i12} : () -> i12
    %32 = "hw.constant"() {value = 770 : i12} : () -> i12
    %33 = "hw.constant"() {value = 2 : i3} : () -> i3
    %34 = "hw.constant"() {value = 3 : i3} : () -> i3
    %35 = "hw.constant"() {value = 1 : i2} : () -> i2
    %36 = "hw.constant"() {value = -2 : i2} : () -> i2
    %37 = "hw.constant"() {value = 19 : i32} : () -> i32
    %38 = "hw.constant"() {value = 768 : i12} : () -> i12
    %39 = "hw.constant"() {value = 836 : i12} : () -> i12
    %40 = "hw.constant"() {value = 772 : i12} : () -> i12
    %41 = "hw.constant"() {value = 1793 : i12} : () -> i12
    %42 = "hw.constant"() {value = 1857 : i12} : () -> i12
    %43 = "hw.constant"() {value = 801 : i12} : () -> i12
    %44 = "hw.constant"() {value = 832 : i12} : () -> i12
    %45 = "hw.constant"() {value = 833 : i12} : () -> i12
    %46 = "hw.constant"() {value = 834 : i12} : () -> i12
    %47 = "hw.constant"() {value = -2147483633 : i32} : () -> i32
    %48 = "hw.constant"() {value = 835 : i12} : () -> i12
    %49 = "hw.constant"() {value = 1920 : i12} : () -> i12
    %50 = "hw.constant"() {value = 1921 : i12} : () -> i12
    %51 = "hw.constant"() {value = 1048832 : i32} : () -> i32
    %52 = "hw.constant"() {value = 0 : i32} : () -> i32
    %53 = "hw.constant"() {value = 6 : i4} : () -> i4
    %54 = "hw.constant"() {value = 4 : i4} : () -> i4
    %55 = "hw.constant"() {value = 0 : i4} : () -> i4
    %56 = "comb.extract"(%arg7) <{lowBit = 20 : i32}> {sv.namehint = "csr_addr"} : (i32) -> i12
    %57 = "comb.extract"(%arg7) <{lowBit = 15 : i32}> {sv.namehint = "rs1_addr"} : (i32) -> i5
    %58 = "seq.firreg"(%348, %arg0, %arg1, %52) <{name = "time"}> {firrtl.random_init_start = 0 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %59 = "seq.firreg"(%364, %arg0, %arg1, %52) <{name = "timeh"}> {firrtl.random_init_start = 32 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %60 = "seq.firreg"(%340, %arg0, %arg1, %52) <{name = "cycle"}> {firrtl.random_init_start = 64 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %61 = "seq.firreg"(%356, %arg0, %arg1, %52) <{name = "cycleh"}> {firrtl.random_init_start = 96 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %62 = "seq.firreg"(%352, %arg0, %arg1, %52) <{name = "instret"}> {firrtl.random_init_start = 128 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %63 = "seq.firreg"(%367, %arg0, %arg1, %52) <{name = "instreth"}> {firrtl.random_init_start = 160 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %64 = "seq.firreg"(%275, %arg0, %arg1, %14) <{name = "PRV"}> {firrtl.random_init_start = 192 : ui64} : (i2, !seq.clock, i1, i2) -> i2
    %65 = "seq.firreg"(%265, %arg0, %arg1, %14) <{name = "PRV1"}> {firrtl.random_init_start = 194 : ui64} : (i2, !seq.clock, i1, i2) -> i2
    %66 = "seq.firreg"(%281, %arg0, %arg1, %5) <{name = "IE"}> {firrtl.random_init_start = 196 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %67 = "seq.firreg"(%270, %arg0, %arg1, %5) <{name = "IE1"}> {firrtl.random_init_start = 197 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %68 = "comb.concat"(%9, %65, %67, %64, %66) {sv.namehint = "mstatus"} : (i26, i2, i1, i2, i1) -> i32
    %69 = "seq.firreg"(%288, %arg0, %arg1, %5) <{name = "MTIP"}> {firrtl.random_init_start = 198 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %70 = "seq.firreg"(%295, %arg0, %arg1, %5) <{name = "MTIE"}> {firrtl.random_init_start = 199 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %71 = "seq.firreg"(%290, %arg0, %arg1, %5) <{name = "MSIP"}> {firrtl.random_init_start = 200 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %72 = "seq.firreg"(%297, %arg0, %arg1, %5) <{name = "MSIE"}> {firrtl.random_init_start = 201 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %73 = "comb.concat"(%7, %69, %1, %71, %1) {sv.namehint = "mip"} : (i24, i1, i3, i1, i3) -> i32
    %74 = "comb.concat"(%7, %70, %1, %72, %1) {sv.namehint = "mie"} : (i24, i1, i3, i1, i3) -> i32
    %75 = "seq.firreg"(%303, %arg0) <{name = "mtimecmp"}> {firrtl.random_init_start = 202 : ui64} : (i32, !seq.clock) -> i32
    %76 = "seq.firreg"(%307, %arg0) <{name = "mscratch"}> {firrtl.random_init_start = 234 : ui64} : (i32, !seq.clock) -> i32
    %77 = "seq.firreg"(%315, %arg0) <{name = "mepc"}> {firrtl.random_init_start = 266 : ui64, sv.namehint = "mepc"} : (i32, !seq.clock) -> i32
    %78 = "seq.firreg"(%322, %arg0) <{name = "mcause"}> {firrtl.random_init_start = 298 : ui64} : (i32, !seq.clock) -> i32
    %79 = "seq.firreg"(%328, %arg0) <{name = "mbadaddr"}> {firrtl.random_init_start = 330 : ui64} : (i32, !seq.clock) -> i32
    %80 = "seq.firreg"(%332, %arg0, %arg1, %52) <{name = "mtohost"}> {firrtl.random_init_start = 362 : ui64, sv.namehint = "mtohost"} : (i32, !seq.clock, i1, i32) -> i32
    %81 = "seq.firreg"(%336, %arg0) <{name = "mfromhost"}> {firrtl.random_init_start = 394 : ui64} : (i32, !seq.clock) -> i32
    %82 = "comb.mux"(%arg12, %arg13, %81) <{twoState}> : (i1, i32, i32) -> i32
    %83 = "comb.icmp"(%56, %15) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_1"} : (i12, i12) -> i1
    %84 = "comb.icmp"(%56, %16) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_3"} : (i12, i12) -> i1
    %85 = "comb.icmp"(%56, %17) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_5"} : (i12, i12) -> i1
    %86 = "comb.icmp"(%56, %18) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_7"} : (i12, i12) -> i1
    %87 = "comb.icmp"(%56, %19) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_9"} : (i12, i12) -> i1
    %88 = "comb.icmp"(%56, %20) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_11"} : (i12, i12) -> i1
    %89 = "comb.icmp"(%56, %21) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_13"} : (i12, i12) -> i1
    %90 = "comb.icmp"(%56, %22) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_15"} : (i12, i12) -> i1
    %91 = "comb.icmp"(%56, %23) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_17"} : (i12, i12) -> i1
    %92 = "comb.icmp"(%56, %24) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_19"} : (i12, i12) -> i1
    %93 = "comb.icmp"(%56, %25) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_21"} : (i12, i12) -> i1
    %94 = "comb.icmp"(%56, %26) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_23"} : (i12, i12) -> i1
    %95 = "comb.icmp"(%56, %27) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_25"} : (i12, i12) -> i1
    %96 = "comb.icmp"(%56, %28) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_27"} : (i12, i12) -> i1
    %97 = "comb.icmp"(%56, %29) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_29"} : (i12, i12) -> i1
    %98 = "comb.icmp"(%56, %31) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_31"} : (i12, i12) -> i1
    %99 = "comb.icmp"(%56, %32) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_33"} : (i12, i12) -> i1
    %100 = "comb.icmp"(%56, %40) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_35"} : (i12, i12) -> i1
    %101 = "comb.icmp"(%56, %43) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_37"} : (i12, i12) -> i1
    %102 = "comb.icmp"(%56, %41) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_39"} : (i12, i12) -> i1
    %103 = "comb.icmp"(%56, %42) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_41"} : (i12, i12) -> i1
    %104 = "comb.icmp"(%56, %44) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_43"} : (i12, i12) -> i1
    %105 = "comb.icmp"(%56, %45) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_45"} : (i12, i12) -> i1
    %106 = "comb.icmp"(%56, %46) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_47"} : (i12, i12) -> i1
    %107 = "comb.icmp"(%56, %48) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_49"} : (i12, i12) -> i1
    %108 = "comb.icmp"(%56, %39) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_51"} : (i12, i12) -> i1
    %109 = "comb.icmp"(%56, %49) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_53"} : (i12, i12) -> i1
    %110 = "comb.icmp"(%56, %50) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_55"} : (i12, i12) -> i1
    %111 = "comb.icmp"(%56, %38) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_57"} : (i12, i12) -> i1
    %112 = "comb.mux"(%111, %68, %52) <{twoState}> {sv.namehint = "_io_out_T_58"} : (i1, i32, i32) -> i32
    %113 = "comb.mux"(%110, %81, %112) <{twoState}> {sv.namehint = "_io_out_T_59"} : (i1, i32, i32) -> i32
    %114 = "comb.mux"(%109, %80, %113) <{twoState}> {sv.namehint = "_io_out_T_60"} : (i1, i32, i32) -> i32
    %115 = "comb.mux"(%108, %73, %114) <{twoState}> {sv.namehint = "_io_out_T_61"} : (i1, i32, i32) -> i32
    %116 = "comb.mux"(%107, %79, %115) <{twoState}> {sv.namehint = "_io_out_T_62"} : (i1, i32, i32) -> i32
    %117 = "comb.mux"(%106, %78, %116) <{twoState}> {sv.namehint = "_io_out_T_63"} : (i1, i32, i32) -> i32
    %118 = "comb.mux"(%105, %77, %117) <{twoState}> {sv.namehint = "_io_out_T_64"} : (i1, i32, i32) -> i32
    %119 = "comb.mux"(%104, %76, %118) <{twoState}> {sv.namehint = "_io_out_T_65"} : (i1, i32, i32) -> i32
    %120 = "comb.mux"(%103, %59, %119) <{twoState}> {sv.namehint = "_io_out_T_66"} : (i1, i32, i32) -> i32
    %121 = "comb.mux"(%102, %58, %120) <{twoState}> {sv.namehint = "_io_out_T_67"} : (i1, i32, i32) -> i32
    %122 = "comb.mux"(%101, %75, %121) <{twoState}> {sv.namehint = "_io_out_T_68"} : (i1, i32, i32) -> i32
    %123 = "comb.mux"(%100, %74, %122) <{twoState}> {sv.namehint = "_io_out_T_69"} : (i1, i32, i32) -> i32
    %124 = "comb.mux"(%99, %52, %123) <{twoState}> {sv.namehint = "_io_out_T_70"} : (i1, i32, i32) -> i32
    %125 = "comb.mux"(%98, %8, %124) <{twoState}> {sv.namehint = "_io_out_T_71"} : (i1, i32, i32) -> i32
    %126 = "comb.or"(%96, %97) <{twoState}> : (i1, i1) -> i1
    %127 = "comb.mux"(%126, %52, %125) <{twoState}> {sv.namehint = "_io_out_T_73"} : (i1, i32, i32) -> i32
    %128 = "comb.mux"(%95, %51, %127) <{twoState}> {sv.namehint = "_io_out_T_74"} : (i1, i32, i32) -> i32
    %129 = "comb.mux"(%94, %63, %128) <{twoState}> {sv.namehint = "_io_out_T_75"} : (i1, i32, i32) -> i32
    %130 = "comb.mux"(%93, %59, %129) <{twoState}> {sv.namehint = "_io_out_T_76"} : (i1, i32, i32) -> i32
    %131 = "comb.mux"(%92, %61, %130) <{twoState}> {sv.namehint = "_io_out_T_77"} : (i1, i32, i32) -> i32
    %132 = "comb.mux"(%91, %62, %131) <{twoState}> {sv.namehint = "_io_out_T_78"} : (i1, i32, i32) -> i32
    %133 = "comb.mux"(%90, %58, %132) <{twoState}> {sv.namehint = "_io_out_T_79"} : (i1, i32, i32) -> i32
    %134 = "comb.mux"(%89, %60, %133) <{twoState}> {sv.namehint = "_io_out_T_80"} : (i1, i32, i32) -> i32
    %135 = "comb.mux"(%88, %63, %134) <{twoState}> {sv.namehint = "_io_out_T_81"} : (i1, i32, i32) -> i32
    %136 = "comb.mux"(%87, %59, %135) <{twoState}> {sv.namehint = "_io_out_T_82"} : (i1, i32, i32) -> i32
    %137 = "comb.mux"(%86, %61, %136) <{twoState}> {sv.namehint = "_io_out_T_83"} : (i1, i32, i32) -> i32
    %138 = "comb.mux"(%85, %62, %137) <{twoState}> {sv.namehint = "_io_out_T_84"} : (i1, i32, i32) -> i32
    %139 = "comb.mux"(%84, %58, %138) <{twoState}> {sv.namehint = "_io_out_T_85"} : (i1, i32, i32) -> i32
    %140 = "comb.mux"(%83, %60, %139) <{twoState}> {sv.namehint = "io_out"} : (i1, i32, i32) -> i32
    %141 = "comb.extract"(%arg7) <{lowBit = 28 : i32}> {sv.namehint = "_privValid_T"} : (i32) -> i2
    %142 = "comb.icmp"(%arg3, %30) <{predicate = 0 : i64, twoState}> {sv.namehint = "privInst"} : (i3, i3) -> i1
    %143 = "comb.extract"(%arg7) <{lowBit = 20 : i32}> {sv.namehint = "_isEret_T"} : (i32) -> i1
    %144 = "comb.xor"(%143, %0) <{twoState}> {sv.namehint = "_isEcall_T_1"} : (i1, i1) -> i1
    %145 = "comb.extract"(%arg7) <{lowBit = 28 : i32}> {sv.namehint = "_isEret_T_3"} : (i32) -> i1
    %146 = "comb.xor"(%145, %0) <{twoState}> {sv.namehint = "_isEcall_T_4"} : (i1, i1) -> i1
    %147 = "comb.and"(%142, %144, %146) <{twoState}> {sv.namehint = "isEcall"} : (i1, i1, i1) -> i1
    %148 = "comb.xor"(%145, %0) <{twoState}> {sv.namehint = "_isEbreak_T_3"} : (i1, i1) -> i1
    %149 = "comb.and"(%142, %143, %148) <{twoState}> {sv.namehint = "isEbreak"} : (i1, i1, i1) -> i1
    %150 = "comb.xor"(%143, %0) <{twoState}> {sv.namehint = "_isEret_T_1"} : (i1, i1) -> i1
    %151 = "comb.and"(%142, %150, %145) <{twoState}> {sv.namehint = "isEret"} : (i1, i1, i1) -> i1
    %152 = "comb.icmp"(%56, %15) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_1"} : (i12, i12) -> i1
    %153 = "comb.icmp"(%56, %16) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_3"} : (i12, i12) -> i1
    %154 = "comb.icmp"(%56, %17) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_5"} : (i12, i12) -> i1
    %155 = "comb.icmp"(%56, %18) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_7"} : (i12, i12) -> i1
    %156 = "comb.icmp"(%56, %19) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_9"} : (i12, i12) -> i1
    %157 = "comb.icmp"(%56, %20) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_11"} : (i12, i12) -> i1
    %158 = "comb.icmp"(%56, %21) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_13"} : (i12, i12) -> i1
    %159 = "comb.icmp"(%56, %22) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_15"} : (i12, i12) -> i1
    %160 = "comb.icmp"(%56, %23) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_17"} : (i12, i12) -> i1
    %161 = "comb.icmp"(%56, %24) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_19"} : (i12, i12) -> i1
    %162 = "comb.icmp"(%56, %25) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_21"} : (i12, i12) -> i1
    %163 = "comb.icmp"(%56, %26) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_23"} : (i12, i12) -> i1
    %164 = "comb.icmp"(%56, %27) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_25"} : (i12, i12) -> i1
    %165 = "comb.icmp"(%56, %28) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_27"} : (i12, i12) -> i1
    %166 = "comb.icmp"(%56, %29) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_29"} : (i12, i12) -> i1
    %167 = "comb.icmp"(%56, %31) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_31"} : (i12, i12) -> i1
    %168 = "comb.icmp"(%56, %32) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_33"} : (i12, i12) -> i1
    %169 = "comb.icmp"(%56, %40) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_35"} : (i12, i12) -> i1
    %170 = "comb.icmp"(%56, %43) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_37"} : (i12, i12) -> i1
    %171 = "comb.icmp"(%56, %41) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_39"} : (i12, i12) -> i1
    %172 = "comb.icmp"(%56, %42) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_41"} : (i12, i12) -> i1
    %173 = "comb.icmp"(%56, %44) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_43"} : (i12, i12) -> i1
    %174 = "comb.icmp"(%56, %45) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_45"} : (i12, i12) -> i1
    %175 = "comb.icmp"(%56, %46) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_47"} : (i12, i12) -> i1
    %176 = "comb.icmp"(%56, %48) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_49"} : (i12, i12) -> i1
    %177 = "comb.icmp"(%56, %39) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_51"} : (i12, i12) -> i1
    %178 = "comb.icmp"(%56, %49) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_53"} : (i12, i12) -> i1
    %179 = "comb.icmp"(%56, %50) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_55"} : (i12, i12) -> i1
    %180 = "comb.icmp"(%56, %38) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrValid_T_57"} : (i12, i12) -> i1
    %181 = "comb.or"(%152, %153, %154, %155, %156, %157, %158, %159, %160, %161, %162, %163, %164, %165, %166, %167, %168, %169, %170, %171, %172, %173, %174, %175, %176, %177, %178, %179, %180) <{twoState}> {sv.namehint = "csrValid"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %182 = "comb.extract"(%arg7) <{lowBit = 30 : i32}> {sv.namehint = "_csrRO_T"} : (i32) -> i2
    %183 = "comb.icmp"(%182, %14) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrRO_T_1"} : (i2, i2) -> i1
    %184 = "comb.icmp"(%56, %31) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrRO_T_2"} : (i12, i12) -> i1
    %185 = "comb.icmp"(%56, %32) <{predicate = 0 : i64, twoState}> {sv.namehint = "_csrRO_T_4"} : (i12, i12) -> i1
    %186 = "comb.or"(%183, %184, %185) <{twoState}> {sv.namehint = "csrRO"} : (i1, i1, i1) -> i1
    %187 = "comb.icmp"(%arg3, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_wen_T"} : (i3, i3) -> i1
    %188 = "comb.extract"(%arg3) <{lowBit = 1 : i32}> {sv.namehint = "_wen_T_1"} : (i3) -> i1
    %189 = "comb.icmp"(%57, %13) <{predicate = 1 : i64, twoState}> {sv.namehint = "_wen_T_2"} : (i5, i5) -> i1
    %190 = "comb.and"(%188, %189) <{twoState}> {sv.namehint = "_wen_T_3"} : (i1, i1) -> i1
    %191 = "comb.or"(%187, %190) <{twoState}> {sv.namehint = "wen"} : (i1, i1) -> i1
    %192 = "comb.or"(%140, %arg4) <{twoState}> {sv.namehint = "_wdata_T"} : (i32, i32) -> i32
    %193 = "comb.xor"(%arg4, %12) <{twoState}> {sv.namehint = "_wdata_T_1"} : (i32, i32) -> i32
    %194 = "comb.and"(%140, %193) <{twoState}> {sv.namehint = "_wdata_T_2"} : (i32, i32) -> i32
    %195 = "comb.icmp"(%arg3, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_wdata_T_3"} : (i3, i3) -> i1
    %196 = "comb.mux"(%195, %arg4, %52) <{twoState}> {sv.namehint = "_wdata_T_4"} : (i1, i32, i32) -> i32
    %197 = "comb.icmp"(%arg3, %33) <{predicate = 0 : i64, twoState}> {sv.namehint = "_wdata_T_5"} : (i3, i3) -> i1
    %198 = "comb.mux"(%197, %192, %196) <{twoState}> {sv.namehint = "_wdata_T_6"} : (i1, i32, i32) -> i32
    %199 = "comb.icmp"(%arg3, %34) <{predicate = 0 : i64, twoState}> {sv.namehint = "_wdata_T_7"} : (i3, i3) -> i1
    %200 = "comb.mux"(%199, %194, %198) <{twoState}> {sv.namehint = "wdata"} : (i1, i32, i32) -> i32
    %201 = "comb.extract"(%arg6) <{lowBit = 1 : i32}> {sv.namehint = "_iaddrInvalid_T"} : (i32) -> i1
    %202 = "comb.and"(%arg11, %201) <{twoState}> {sv.namehint = "iaddrInvalid"} : (i1, i1) -> i1
    %203 = "comb.extract"(%arg6) <{lowBit = 0 : i32}> {sv.namehint = "_saddrInvalid_T"} : (i32) -> i2
    %204 = "comb.icmp"(%203, %3) <{predicate = 1 : i64, twoState}> {sv.namehint = "_laddrInvalid_T_1"} : (i2, i2) -> i1
    %205 = "comb.extract"(%arg6) <{lowBit = 0 : i32}> {sv.namehint = "_saddrInvalid_T_2"} : (i32) -> i1
    %206 = "comb.icmp"(%arg10, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_laddrInvalid_T_4"} : (i3, i3) -> i1
    %207 = "comb.and"(%206, %204) {sv.namehint = "_laddrInvalid_T_5"} : (i1, i1) -> i1
    %208 = "comb.icmp"(%arg10, %33) <{predicate = 0 : i64, twoState}> {sv.namehint = "_laddrInvalid_T_6"} : (i3, i3) -> i1
    %209 = "comb.icmp"(%arg10, %30) <{predicate = 0 : i64, twoState}> {sv.namehint = "_laddrInvalid_T_8"} : (i3, i3) -> i1
    %210 = "comb.or"(%209, %208) <{twoState}> : (i1, i1) -> i1
    %211 = "comb.mux"(%210, %205, %207) <{twoState}> {sv.namehint = "laddrInvalid"} : (i1, i1, i1) -> i1
    %212 = "comb.icmp"(%203, %3) <{predicate = 1 : i64, twoState}> {sv.namehint = "_saddrInvalid_T_1"} : (i2, i2) -> i1
    %213 = "comb.icmp"(%arg9, %35) <{predicate = 0 : i64, twoState}> {sv.namehint = "_saddrInvalid_T_3"} : (i2, i2) -> i1
    %214 = "comb.and"(%213, %212) {sv.namehint = "_saddrInvalid_T_4"} : (i1, i1) -> i1
    %215 = "comb.icmp"(%arg9, %36) <{predicate = 0 : i64, twoState}> {sv.namehint = "_saddrInvalid_T_5"} : (i2, i2) -> i1
    %216 = "comb.mux"(%215, %205, %214) <{twoState}> {sv.namehint = "saddrInvalid"} : (i1, i1, i1) -> i1
    %217 = "comb.extract"(%arg3) <{lowBit = 0 : i32}> {sv.namehint = "_io_expt_T_3"} : (i3) -> i2
    %218 = "comb.icmp"(%217, %3) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_expt_T_4"} : (i2, i2) -> i1
    %219 = "comb.xor"(%181, %0) <{twoState}> {sv.namehint = "_io_expt_T_5"} : (i1, i1) -> i1
    %220 = "comb.icmp"(%141, %64) <{predicate = 8 : i64, twoState}> {sv.namehint = "_io_expt_T_12"} : (i2, i2) -> i1
    %221 = "comb.or"(%219, %220) <{twoState}> {sv.namehint = "_io_expt_T_7"} : (i1, i1) -> i1
    %222 = "comb.and"(%218, %221) <{twoState}> {sv.namehint = "_io_expt_T_8"} : (i1, i1) -> i1
    %223 = "comb.and"(%191, %186) <{twoState}> {sv.namehint = "_io_expt_T_10"} : (i1, i1) -> i1
    %224 = "comb.and"(%142, %220) <{twoState}> {sv.namehint = "_io_expt_T_13"} : (i1, i1) -> i1
    %225 = "comb.or"(%arg8, %202, %211, %216, %222, %223, %224, %147, %149) <{twoState}> {sv.namehint = "io_expt"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %226 = "comb.concat"(%7, %64, %11) : (i24, i2, i6) -> i32
    %227 = "comb.add"(%226, %8) {sv.namehint = "_io_evec_T_1"} : (i32, i32) -> i32
    %228 = "comb.add"(%58, %6) {sv.namehint = "_time_T"} : (i32, i32) -> i32
    %229 = "comb.icmp"(%58, %12) <{predicate = 0 : i64, twoState}> : (i32, i32) -> i1
    %230 = "comb.add"(%59, %6) {sv.namehint = "_timeh_T"} : (i32, i32) -> i32
    %231 = "comb.mux"(%229, %230, %59) <{twoState}> : (i1, i32, i32) -> i32
    %232 = "comb.add"(%60, %6) {sv.namehint = "_cycle_T"} : (i32, i32) -> i32
    %233 = "comb.icmp"(%60, %12) <{predicate = 0 : i64, twoState}> : (i32, i32) -> i1
    %234 = "comb.add"(%61, %6) {sv.namehint = "_cycleh_T"} : (i32, i32) -> i32
    %235 = "comb.mux"(%233, %234, %61) <{twoState}> : (i1, i32, i32) -> i32
    %236 = "comb.icmp"(%arg7, %37) <{predicate = 1 : i64, twoState}> {sv.namehint = "_isInstRet_T"} : (i32, i32) -> i1
    %237 = "comb.xor"(%225, %0) <{twoState}> {sv.namehint = "_isInstRet_T_1"} : (i1, i1) -> i1
    %238 = "comb.or"(%237, %147, %149) <{twoState}> {sv.namehint = "_isInstRet_T_3"} : (i1, i1, i1) -> i1
    %239 = "comb.xor"(%arg2, %0) <{twoState}> {sv.namehint = "_isInstRet_T_5"} : (i1, i1) -> i1
    %240 = "comb.and"(%236, %238, %239) <{twoState}> {sv.namehint = "isInstRet"} : (i1, i1, i1) -> i1
    %241 = "comb.add"(%62, %6) {sv.namehint = "_instret_T"} : (i32, i32) -> i32
    %242 = "comb.mux"(%240, %241, %62) <{twoState}> : (i1, i32, i32) -> i32
    %243 = "comb.icmp"(%62, %12) <{predicate = 0 : i64, twoState}> : (i32, i32) -> i1
    %244 = "comb.and"(%240, %243) <{twoState}> : (i1, i1) -> i1
    %245 = "comb.add"(%63, %6) {sv.namehint = "_instreth_T"} : (i32, i32) -> i32
    %246 = "comb.mux"(%244, %245, %63) <{twoState}> : (i1, i32, i32) -> i32
    %247 = "comb.extract"(%arg5) <{lowBit = 2 : i32}> {sv.namehint = "_mepc_T"} : (i32) -> i30
    %248 = "comb.concat"(%247, %3) {sv.namehint = "_mepc_T_1"} : (i30, i2) -> i32
    %249 = "comb.concat"(%3, %64) : (i2, i2) -> i4
    %250 = "comb.add"(%249, %4) {sv.namehint = "_mcause_T"} : (i4, i4) -> i4
    %251 = "comb.concat"(%2, %149) : (i3, i1) -> i4
    %252 = "comb.mux"(%147, %250, %251) <{twoState}> {sv.namehint = "_mcause_T_3"} : (i1, i4, i4) -> i4
    %253 = "comb.mux"(%216, %53, %252) <{twoState}> {sv.namehint = "_mcause_T_4"} : (i1, i4, i4) -> i4
    %254 = "comb.mux"(%211, %54, %253) <{twoState}> {sv.namehint = "_mcause_T_5"} : (i1, i4, i4) -> i4
    %255 = "comb.mux"(%202, %55, %254) <{twoState}> {sv.namehint = "_mcause_T_6"} : (i1, i4, i4) -> i4
    %256 = "comb.concat"(%10, %255) : (i28, i4) -> i32
    %257 = "comb.or"(%202, %211, %216) <{twoState}> : (i1, i1, i1) -> i1
    %258 = "comb.mux"(%257, %arg6, %79) <{twoState}> : (i1, i32, i32) -> i32
    %259 = "comb.icmp"(%56, %38) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %260 = "comb.extract"(%200) <{lowBit = 4 : i32}> {sv.namehint = "_PRV1_T"} : (i32) -> i2
    %261 = "comb.and"(%191, %259) <{twoState}> : (i1, i1) -> i1
    %262 = "comb.mux"(%261, %260, %65) <{twoState}> : (i1, i2, i2) -> i2
    %263 = "comb.mux"(%151, %3, %262) <{twoState}> : (i1, i2, i2) -> i2
    %264 = "comb.mux"(%225, %64, %263) <{twoState}> : (i1, i2, i2) -> i2
    %265 = "comb.mux"(%arg2, %65, %264) <{twoState}> : (i1, i2, i2) -> i2
    %266 = "comb.extract"(%200) <{lowBit = 3 : i32}> {sv.namehint = "_IE1_T"} : (i32) -> i1
    %267 = "comb.mux"(%261, %266, %67) <{twoState}> : (i1, i1, i1) -> i1
    %268 = "comb.or"(%151, %267) : (i1, i1) -> i1
    %269 = "comb.mux"(%225, %66, %268) <{twoState}> : (i1, i1, i1) -> i1
    %270 = "comb.mux"(%arg2, %67, %269) <{twoState}> : (i1, i1, i1) -> i1
    %271 = "comb.extract"(%200) <{lowBit = 1 : i32}> {sv.namehint = "_PRV_T"} : (i32) -> i2
    %272 = "comb.mux"(%261, %271, %64) <{twoState}> : (i1, i2, i2) -> i2
    %273 = "comb.mux"(%151, %65, %272) <{twoState}> : (i1, i2, i2) -> i2
    %274 = "comb.mux"(%225, %14, %273) <{twoState}> : (i1, i2, i2) -> i2
    %275 = "comb.mux"(%arg2, %64, %274) <{twoState}> : (i1, i2, i2) -> i2
    %276 = "comb.extract"(%200) <{lowBit = 0 : i32}> {sv.namehint = "_IE_T"} : (i32) -> i1
    %277 = "comb.mux"(%261, %276, %66) <{twoState}> : (i1, i1, i1) -> i1
    %278 = "comb.mux"(%151, %67, %277) <{twoState}> : (i1, i1, i1) -> i1
    %279 = "comb.xor"(%225, %0) : (i1, i1) -> i1
    %280 = "comb.and"(%279, %278) : (i1, i1) -> i1
    %281 = "comb.mux"(%arg2, %66, %280) <{twoState}> : (i1, i1, i1) -> i1
    %282 = "comb.icmp"(%56, %39) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %283 = "comb.extract"(%200) <{lowBit = 7 : i32}> {sv.namehint = "_MTIP_T"} : (i32) -> i1
    %284 = "comb.xor"(%282, %0) : (i1, i1) -> i1
    %285 = "comb.xor"(%191, %0) : (i1, i1) -> i1
    %286 = "comb.or"(%225, %151) <{twoState}> : (i1, i1) -> i1
    %287 = "comb.or"(%arg2, %286, %285, %259, %284) : (i1, i1, i1, i1, i1) -> i1
    %288 = "comb.mux"(%287, %69, %283) <{twoState}> : (i1, i1, i1) -> i1
    %289 = "comb.extract"(%200) <{lowBit = 3 : i32}> {sv.namehint = "_MSIP_T"} : (i32) -> i1
    %290 = "comb.mux"(%287, %71, %289) <{twoState}> : (i1, i1, i1) -> i1
    %291 = "comb.icmp"(%56, %40) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %292 = "comb.extract"(%200) <{lowBit = 7 : i32}> {sv.namehint = "_MTIE_T"} : (i32) -> i1
    %293 = "comb.xor"(%291, %0) : (i1, i1) -> i1
    %294 = "comb.or"(%arg2, %286, %285, %259, %282, %293) : (i1, i1, i1, i1, i1, i1) -> i1
    %295 = "comb.mux"(%294, %70, %292) <{twoState}> : (i1, i1, i1) -> i1
    %296 = "comb.extract"(%200) <{lowBit = 3 : i32}> {sv.namehint = "_MSIE_T"} : (i32) -> i1
    %297 = "comb.mux"(%294, %72, %296) <{twoState}> : (i1, i1, i1) -> i1
    %298 = "comb.icmp"(%56, %41) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %299 = "comb.icmp"(%56, %42) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %300 = "comb.icmp"(%56, %43) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %301 = "comb.xor"(%300, %0) : (i1, i1) -> i1
    %302 = "comb.or"(%arg2, %286, %285, %259, %282, %291, %298, %299, %301) : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %303 = "comb.mux"(%302, %75, %200) <{twoState}> : (i1, i32, i32) -> i32
    %304 = "comb.icmp"(%56, %44) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %305 = "comb.xor"(%304, %0) : (i1, i1) -> i1
    %306 = "comb.or"(%arg2, %286, %285, %259, %282, %291, %298, %299, %300, %305) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %307 = "comb.mux"(%306, %76, %200) <{twoState}> : (i1, i32, i32) -> i32
    %308 = "comb.icmp"(%56, %45) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %309 = "comb.extract"(%200) <{lowBit = 2 : i32}> : (i32) -> i30
    %310 = "comb.concat"(%309, %3) : (i30, i2) -> i32
    %311 = "comb.xor"(%308, %0) : (i1, i1) -> i1
    %312 = "comb.or"(%151, %285, %259, %282, %291, %298, %299, %300, %304, %311) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %313 = "comb.mux"(%312, %77, %310) <{twoState}> : (i1, i32, i32) -> i32
    %314 = "comb.mux"(%225, %248, %313) <{twoState}> : (i1, i32, i32) -> i32
    %315 = "comb.mux"(%arg2, %77, %314) <{twoState}> : (i1, i32, i32) -> i32
    %316 = "comb.icmp"(%56, %46) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %317 = "comb.and"(%200, %47) <{twoState}> {sv.namehint = "_mcause_T_7"} : (i32, i32) -> i32
    %318 = "comb.xor"(%316, %0) : (i1, i1) -> i1
    %319 = "comb.or"(%151, %285, %259, %282, %291, %298, %299, %300, %304, %308, %318) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %320 = "comb.mux"(%319, %78, %317) <{twoState}> : (i1, i32, i32) -> i32
    %321 = "comb.mux"(%225, %256, %320) <{twoState}> : (i1, i32, i32) -> i32
    %322 = "comb.mux"(%arg2, %78, %321) <{twoState}> : (i1, i32, i32) -> i32
    %323 = "comb.icmp"(%56, %48) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %324 = "comb.xor"(%323, %0) : (i1, i1) -> i1
    %325 = "comb.or"(%151, %285, %259, %282, %291, %298, %299, %300, %304, %308, %316, %324) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %326 = "comb.mux"(%325, %79, %200) <{twoState}> : (i1, i32, i32) -> i32
    %327 = "comb.mux"(%225, %258, %326) <{twoState}> : (i1, i32, i32) -> i32
    %328 = "comb.mux"(%arg2, %79, %327) <{twoState}> : (i1, i32, i32) -> i32
    %329 = "comb.icmp"(%56, %49) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %330 = "comb.xor"(%329, %0) : (i1, i1) -> i1
    %331 = "comb.or"(%arg2, %286, %285, %259, %282, %291, %298, %299, %300, %304, %308, %316, %323, %330) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %332 = "comb.mux"(%331, %80, %200) <{twoState}> : (i1, i32, i32) -> i32
    %333 = "comb.icmp"(%56, %50) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %334 = "comb.xor"(%333, %0) : (i1, i1) -> i1
    %335 = "comb.or"(%arg2, %286, %285, %259, %282, %291, %298, %299, %300, %304, %308, %316, %323, %329, %334) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %336 = "comb.mux"(%335, %82, %200) <{twoState}> : (i1, i32, i32) -> i32
    %337 = "comb.icmp"(%56, %21) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %338 = "comb.xor"(%337, %0) : (i1, i1) -> i1
    %339 = "comb.or"(%arg2, %286, %285, %259, %282, %291, %298, %299, %300, %304, %308, %316, %323, %329, %333, %338) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %340 = "comb.mux"(%339, %232, %200) <{twoState}> : (i1, i32, i32) -> i32
    %341 = "comb.icmp"(%56, %22) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %342 = "comb.xor"(%341, %0) : (i1, i1) -> i1
    %343 = "comb.or"(%299, %300, %304, %308, %316, %323, %329, %333, %337, %342) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %344 = "comb.xor"(%343, %0) : (i1, i1) -> i1
    %345 = "comb.or"(%298, %344) : (i1, i1) -> i1
    %346 = "comb.xor"(%345, %0) : (i1, i1) -> i1
    %347 = "comb.or"(%arg2, %286, %285, %259, %282, %291, %346) : (i1, i1, i1, i1, i1, i1, i1) -> i1
    %348 = "comb.mux"(%347, %228, %200) <{twoState}> : (i1, i32, i32) -> i32
    %349 = "comb.icmp"(%56, %23) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %350 = "comb.xor"(%349, %0) : (i1, i1) -> i1
    %351 = "comb.or"(%arg2, %286, %285, %259, %282, %291, %298, %299, %300, %304, %308, %316, %323, %329, %333, %337, %341, %350) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %352 = "comb.mux"(%351, %242, %200) <{twoState}> : (i1, i32, i32) -> i32
    %353 = "comb.icmp"(%56, %24) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %354 = "comb.xor"(%353, %0) : (i1, i1) -> i1
    %355 = "comb.or"(%arg2, %286, %285, %259, %282, %291, %298, %299, %300, %304, %308, %316, %323, %329, %333, %337, %341, %349, %354) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %356 = "comb.mux"(%355, %235, %200) <{twoState}> : (i1, i32, i32) -> i32
    %357 = "comb.icmp"(%56, %25) <{predicate = 0 : i64, twoState}> : (i12, i12) -> i1
    %358 = "comb.xor"(%357, %0) : (i1, i1) -> i1
    %359 = "comb.or"(%300, %304, %308, %316, %323, %329, %333, %337, %341, %349, %353, %358) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %360 = "comb.xor"(%359, %0) : (i1, i1) -> i1
    %361 = "comb.or"(%299, %360) : (i1, i1) -> i1
    %362 = "comb.xor"(%361, %0) : (i1, i1) -> i1
    %363 = "comb.or"(%arg2, %286, %285, %259, %282, %291, %298, %362) : (i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %364 = "comb.mux"(%363, %231, %200) <{twoState}> : (i1, i32, i32) -> i32
    %365 = "comb.icmp"(%56, %26) <{predicate = 1 : i64, twoState}> : (i12, i12) -> i1
    %366 = "comb.or"(%arg2, %286, %285, %259, %282, %291, %298, %299, %300, %304, %308, %316, %323, %329, %333, %337, %341, %349, %353, %357, %365) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %367 = "comb.mux"(%366, %246, %200) <{twoState}> : (i1, i32, i32) -> i32
    "hw.output"(%140, %225, %227, %77, %80) : (i32, i1, i32, i32, i32) -> ()
  }) {module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_stall : i1, input io_cmd : i3, input io_in : i32, output io_out : i32, input io_pc : i32, input io_addr : i32, input io_inst : i32, input io_illegal : i1, input io_st_type : i2, input io_ld_type : i3, input io_pc_check : i1, output io_expt : i1, output io_evec : i32, output io_epc : i32, input io_host_fromhost_valid : i1, input io_host_fromhost_bits : i32, output io_host_tohost : i32>, parameters = [], result_locs = [#loc, #loc1, #loc2, #loc3, #loc4], sym_name = "CSR", sym_visibility = "private"} : () -> ()
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
  }) {module_type = !hw.modty<input clock : !seq.clock, input io_raddr1 : i5, input io_raddr2 : i5, output io_rdata1 : i32, output io_rdata2 : i32, input io_wen : i1, input io_waddr : i5, input io_wdata : i32>, parameters = [], result_locs = [#loc5, #loc6], sym_name = "RegFile", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i32, %arg1: i32, %arg2: i4):
    %0 = "hw.constant"() {value = false} : () -> i1
    %1 = "hw.constant"() {value = -174763 : i19} : () -> i19
    %2 = "hw.constant"() {value = 0 : i2} : () -> i2
    %3 = "hw.constant"() {value = -13 : i6} : () -> i6
    %4 = "hw.constant"() {value = 0 : i4} : () -> i4
    %5 = "hw.constant"() {value = 5 : i4} : () -> i4
    %6 = "hw.constant"() {value = 85 : i8} : () -> i8
    %7 = "hw.constant"() {value = 3 : i4} : () -> i4
    %8 = "hw.constant"() {value = 51 : i8} : () -> i8
    %9 = "hw.constant"() {value = 0 : i32} : () -> i32
    %10 = "hw.constant"() {value = 0 : i31} : () -> i31
    %11 = "hw.constant"() {value = 0 : i28} : () -> i28
    %12 = "hw.constant"() {value = 1 : i4} : () -> i4
    %13 = "hw.constant"() {value = 7 : i4} : () -> i4
    %14 = "hw.constant"() {value = -7 : i4} : () -> i4
    %15 = "hw.constant"() {value = -8 : i4} : () -> i4
    %16 = "hw.constant"() {value = 6 : i4} : () -> i4
    %17 = "hw.constant"() {value = 2 : i4} : () -> i4
    %18 = "hw.constant"() {value = 4 : i4} : () -> i4
    %19 = "hw.constant"() {value = -6 : i4} : () -> i4
    %20 = "comb.extract"(%arg2) <{lowBit = 0 : i32}> {sv.namehint = "_shiftr_T"} : (i4) -> i1
    %21 = "comb.sub"(%9, %arg1) {sv.namehint = "_sum_T_2"} : (i32, i32) -> i32
    %22 = "comb.mux"(%20, %21, %arg1) <{twoState}> {sv.namehint = "_sum_T_3"} : (i1, i32, i32) -> i32
    %23 = "comb.add"(%arg0, %22) {sv.namehint = "_sum_T_4"} : (i32, i32) -> i32
    %24 = "comb.extract"(%arg0) <{lowBit = 31 : i32}> {sv.namehint = "_cmp_T_6"} : (i32) -> i1
    %25 = "comb.extract"(%arg1) <{lowBit = 31 : i32}> {sv.namehint = "_cmp_T_5"} : (i32) -> i1
    %26 = "comb.icmp"(%24, %25) <{predicate = 0 : i64, twoState}> {sv.namehint = "_cmp_T_2"} : (i1, i1) -> i1
    %27 = "comb.extract"(%23) <{lowBit = 31 : i32}> {sv.namehint = "_cmp_T_3"} : (i32) -> i1
    %28 = "comb.extract"(%arg2) <{lowBit = 1 : i32}> {sv.namehint = "_cmp_T_4"} : (i4) -> i1
    %29 = "comb.mux"(%28, %25, %24) <{twoState}> {sv.namehint = "_cmp_T_7"} : (i1, i1, i1) -> i1
    %30 = "comb.mux"(%26, %27, %29) <{twoState}> {sv.namehint = "cmp"} : (i1, i1, i1) -> i1
    %31 = "comb.extract"(%arg1) <{lowBit = 0 : i32}> {sv.namehint = "shamt"} : (i32) -> i5
    %32 = "comb.extract"(%arg2) <{lowBit = 3 : i32}> {sv.namehint = "_shin_T"} : (i4) -> i1
    %33 = "comb.extract"(%arg0) <{lowBit = 8 : i32}> : (i32) -> i4
    %34 = "comb.extract"(%arg0) <{lowBit = 16 : i32}> : (i32) -> i4
    %35 = "comb.extract"(%arg0) <{lowBit = 12 : i32}> : (i32) -> i4
    %36 = "comb.concat"(%35, %34) : (i4, i4) -> i8
    %37 = "comb.extract"(%arg0) <{lowBit = 14 : i32}> : (i32) -> i2
    %38 = "comb.concat"(%33, %37) : (i4, i2) -> i6
    %39 = "comb.and"(%38, %3) : (i6, i6) -> i6
    %40 = "comb.extract"(%arg0) <{lowBit = 4 : i32}> : (i32) -> i2
    %41 = "comb.extract"(%arg0) <{lowBit = 8 : i32}> : (i32) -> i2
    %42 = "comb.and"(%36, %8) : (i8, i8) -> i8
    %43 = "comb.extract"(%arg0) <{lowBit = 20 : i32}> : (i32) -> i2
    %44 = "comb.extract"(%arg0) <{lowBit = 24 : i32}> : (i32) -> i2
    %45 = "comb.extract"(%arg0) <{lowBit = 6 : i32}> : (i32) -> i2
    %46 = "comb.concat"(%45, %41) : (i2, i2) -> i4
    %47 = "comb.concat"(%39, %2) : (i6, i2) -> i8
    %48 = "comb.or"(%47, %42) : (i8, i8) -> i8
    %49 = "comb.extract"(%arg0) <{lowBit = 18 : i32}> : (i32) -> i2
    %50 = "comb.extract"(%arg0) <{lowBit = 22 : i32}> : (i32) -> i2
    %51 = "comb.concat"(%50, %44) : (i2, i2) -> i4
    %52 = "comb.extract"(%arg0) <{lowBit = 31 : i32}> : (i32) -> i1
    %53 = "comb.extract"(%arg0) <{lowBit = 23 : i32}> : (i32) -> i1
    %54 = "comb.concat"(%40, %45, %41, %48, %49, %43, %53) : (i2, i2, i2, i8, i2, i2, i1) -> i19
    %55 = "comb.and"(%54, %1) : (i19, i19) -> i19
    %56 = "comb.extract"(%arg0) <{lowBit = 0 : i32}> : (i32) -> i1
    %57 = "comb.extract"(%arg0) <{lowBit = 2 : i32}> : (i32) -> i1
    %58 = "comb.extract"(%arg0) <{lowBit = 4 : i32}> : (i32) -> i1
    %59 = "comb.and"(%46, %5) : (i4, i4) -> i4
    %60 = "comb.and"(%48, %6) : (i8, i8) -> i8
    %61 = "comb.extract"(%arg0) <{lowBit = 18 : i32}> : (i32) -> i1
    %62 = "comb.extract"(%arg0) <{lowBit = 20 : i32}> : (i32) -> i1
    %63 = "comb.and"(%51, %5) : (i4, i4) -> i4
    %64 = "comb.extract"(%arg0) <{lowBit = 26 : i32}> : (i32) -> i1
    %65 = "comb.extract"(%arg0) <{lowBit = 28 : i32}> : (i32) -> i1
    %66 = "comb.extract"(%arg0) <{lowBit = 30 : i32}> : (i32) -> i1
    %67 = "comb.extract"(%arg0) <{lowBit = 1 : i32}> : (i32) -> i1
    %68 = "comb.extract"(%arg0) <{lowBit = 3 : i32}> : (i32) -> i1
    %69 = "comb.extract"(%55) <{lowBit = 15 : i32}> : (i19) -> i4
    %70 = "comb.or"(%69, %59) : (i4, i4) -> i4
    %71 = "comb.extract"(%55) <{lowBit = 7 : i32}> : (i19) -> i8
    %72 = "comb.or"(%71, %60) : (i8, i8) -> i8
    %73 = "comb.extract"(%48) <{lowBit = 1 : i32}> : (i8) -> i1
    %74 = "comb.extract"(%55) <{lowBit = 5 : i32}> : (i19) -> i1
    %75 = "comb.or"(%74, %61) : (i1, i1) -> i1
    %76 = "comb.extract"(%arg0) <{lowBit = 19 : i32}> : (i32) -> i1
    %77 = "comb.extract"(%55) <{lowBit = 0 : i32}> : (i19) -> i3
    %78 = "comb.concat"(%77, %0) : (i3, i1) -> i4
    %79 = "comb.or"(%78, %63) : (i4, i4) -> i4
    %80 = "comb.extract"(%arg0) <{lowBit = 25 : i32}> : (i32) -> i1
    %81 = "comb.extract"(%arg0) <{lowBit = 27 : i32}> : (i32) -> i1
    %82 = "comb.extract"(%arg0) <{lowBit = 29 : i32}> : (i32) -> i1
    %83 = "comb.concat"(%56, %67, %57, %68, %58, %70, %72, %73, %75, %76, %62, %79, %80, %64, %81, %65, %82, %66, %52) : (i1, i1, i1, i1, i1, i4, i8, i1, i1, i1, i1, i4, i1, i1, i1, i1, i1, i1, i1) -> i32
    %84 = "comb.mux"(%32, %arg0, %83) <{twoState}> {sv.namehint = "shin"} : (i1, i32, i32) -> i32
    %85 = "comb.extract"(%84) <{lowBit = 31 : i32}> {sv.namehint = "_shiftr_T_1"} : (i32) -> i1
    %86 = "comb.and"(%20, %85) <{twoState}> {sv.namehint = "_shiftr_T_2"} : (i1, i1) -> i1
    %87 = "comb.concat"(%86, %84) {sv.namehint = "_shiftr_T_3"} : (i1, i32) -> i33
    %88 = "comb.concat"(%11, %31) : (i28, i5) -> i33
    %89 = "comb.shrs"(%87, %88) <{twoState}> {sv.namehint = "_shiftr_T_5"} : (i33, i33) -> i33
    %90 = "comb.extract"(%89) <{lowBit = 0 : i32}> {sv.namehint = "shiftr"} : (i33) -> i32
    %91 = "comb.extract"(%89) <{lowBit = 8 : i32}> : (i33) -> i4
    %92 = "comb.extract"(%89) <{lowBit = 16 : i32}> : (i33) -> i4
    %93 = "comb.extract"(%89) <{lowBit = 12 : i32}> : (i33) -> i4
    %94 = "comb.concat"(%93, %92) : (i4, i4) -> i8
    %95 = "comb.extract"(%89) <{lowBit = 14 : i32}> : (i33) -> i2
    %96 = "comb.concat"(%91, %95) : (i4, i2) -> i6
    %97 = "comb.and"(%96, %3) : (i6, i6) -> i6
    %98 = "comb.extract"(%89) <{lowBit = 4 : i32}> : (i33) -> i2
    %99 = "comb.extract"(%89) <{lowBit = 8 : i32}> : (i33) -> i2
    %100 = "comb.and"(%94, %8) : (i8, i8) -> i8
    %101 = "comb.extract"(%89) <{lowBit = 20 : i32}> : (i33) -> i2
    %102 = "comb.extract"(%89) <{lowBit = 24 : i32}> : (i33) -> i2
    %103 = "comb.extract"(%89) <{lowBit = 6 : i32}> : (i33) -> i2
    %104 = "comb.concat"(%103, %99) : (i2, i2) -> i4
    %105 = "comb.concat"(%97, %2) : (i6, i2) -> i8
    %106 = "comb.or"(%105, %100) : (i8, i8) -> i8
    %107 = "comb.extract"(%89) <{lowBit = 18 : i32}> : (i33) -> i2
    %108 = "comb.extract"(%89) <{lowBit = 22 : i32}> : (i33) -> i2
    %109 = "comb.concat"(%108, %102) : (i2, i2) -> i4
    %110 = "comb.extract"(%89) <{lowBit = 31 : i32}> : (i33) -> i1
    %111 = "comb.extract"(%89) <{lowBit = 23 : i32}> : (i33) -> i1
    %112 = "comb.concat"(%98, %103, %99, %106, %107, %101, %111) : (i2, i2, i2, i8, i2, i2, i1) -> i19
    %113 = "comb.and"(%112, %1) : (i19, i19) -> i19
    %114 = "comb.extract"(%89) <{lowBit = 0 : i32}> : (i33) -> i1
    %115 = "comb.extract"(%89) <{lowBit = 2 : i32}> : (i33) -> i1
    %116 = "comb.extract"(%89) <{lowBit = 4 : i32}> : (i33) -> i1
    %117 = "comb.and"(%104, %5) : (i4, i4) -> i4
    %118 = "comb.and"(%106, %6) : (i8, i8) -> i8
    %119 = "comb.extract"(%89) <{lowBit = 18 : i32}> : (i33) -> i1
    %120 = "comb.extract"(%89) <{lowBit = 20 : i32}> : (i33) -> i1
    %121 = "comb.and"(%109, %5) : (i4, i4) -> i4
    %122 = "comb.extract"(%89) <{lowBit = 26 : i32}> : (i33) -> i1
    %123 = "comb.extract"(%89) <{lowBit = 28 : i32}> : (i33) -> i1
    %124 = "comb.extract"(%89) <{lowBit = 30 : i32}> : (i33) -> i1
    %125 = "comb.extract"(%89) <{lowBit = 1 : i32}> : (i33) -> i1
    %126 = "comb.extract"(%89) <{lowBit = 3 : i32}> : (i33) -> i1
    %127 = "comb.extract"(%113) <{lowBit = 15 : i32}> : (i19) -> i4
    %128 = "comb.or"(%127, %117) : (i4, i4) -> i4
    %129 = "comb.extract"(%113) <{lowBit = 7 : i32}> : (i19) -> i8
    %130 = "comb.or"(%129, %118) : (i8, i8) -> i8
    %131 = "comb.extract"(%106) <{lowBit = 1 : i32}> : (i8) -> i1
    %132 = "comb.extract"(%113) <{lowBit = 5 : i32}> : (i19) -> i1
    %133 = "comb.or"(%132, %119) : (i1, i1) -> i1
    %134 = "comb.extract"(%89) <{lowBit = 19 : i32}> : (i33) -> i1
    %135 = "comb.extract"(%113) <{lowBit = 0 : i32}> : (i19) -> i3
    %136 = "comb.concat"(%135, %0) : (i3, i1) -> i4
    %137 = "comb.or"(%136, %121) : (i4, i4) -> i4
    %138 = "comb.extract"(%89) <{lowBit = 25 : i32}> : (i33) -> i1
    %139 = "comb.extract"(%89) <{lowBit = 27 : i32}> : (i33) -> i1
    %140 = "comb.extract"(%89) <{lowBit = 29 : i32}> : (i33) -> i1
    %141 = "comb.concat"(%114, %125, %115, %126, %116, %128, %130, %131, %133, %134, %120, %137, %138, %122, %139, %123, %140, %124, %110) : (i1, i1, i1, i1, i1, i4, i8, i1, i1, i1, i1, i4, i1, i1, i1, i1, i1, i1, i1) -> i32
    %142 = "comb.icmp"(%arg2, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_out_T"} : (i4, i4) -> i1
    %143 = "comb.icmp"(%arg2, %12) <{predicate = 0 : i64, twoState}> {sv.namehint = "_out_T_1"} : (i4, i4) -> i1
    %144 = "comb.or"(%142, %143) <{twoState}> {sv.namehint = "_out_T_2"} : (i1, i1) -> i1
    %145 = "comb.icmp"(%arg2, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_out_T_3"} : (i4, i4) -> i1
    %146 = "comb.icmp"(%arg2, %13) <{predicate = 0 : i64, twoState}> {sv.namehint = "_out_T_4"} : (i4, i4) -> i1
    %147 = "comb.or"(%145, %146) <{twoState}> {sv.namehint = "_out_T_5"} : (i1, i1) -> i1
    %148 = "comb.icmp"(%arg2, %14) <{predicate = 0 : i64, twoState}> {sv.namehint = "_out_T_6"} : (i4, i4) -> i1
    %149 = "comb.icmp"(%arg2, %15) <{predicate = 0 : i64, twoState}> {sv.namehint = "_out_T_7"} : (i4, i4) -> i1
    %150 = "comb.or"(%148, %149) <{twoState}> {sv.namehint = "_out_T_8"} : (i1, i1) -> i1
    %151 = "comb.icmp"(%arg2, %16) <{predicate = 0 : i64, twoState}> {sv.namehint = "_out_T_9"} : (i4, i4) -> i1
    %152 = "comb.icmp"(%arg2, %17) <{predicate = 0 : i64, twoState}> {sv.namehint = "_out_T_10"} : (i4, i4) -> i1
    %153 = "comb.and"(%arg0, %arg1) <{twoState}> {sv.namehint = "_out_T_11"} : (i32, i32) -> i32
    %154 = "comb.icmp"(%arg2, %7) <{predicate = 0 : i64, twoState}> {sv.namehint = "_out_T_12"} : (i4, i4) -> i1
    %155 = "comb.or"(%arg0, %arg1) <{twoState}> {sv.namehint = "_out_T_13"} : (i32, i32) -> i32
    %156 = "comb.icmp"(%arg2, %18) <{predicate = 0 : i64, twoState}> {sv.namehint = "_out_T_14"} : (i4, i4) -> i1
    %157 = "comb.xor"(%arg0, %arg1) <{twoState}> {sv.namehint = "_out_T_15"} : (i32, i32) -> i32
    %158 = "comb.icmp"(%arg2, %19) <{predicate = 0 : i64, twoState}> {sv.namehint = "_out_T_16"} : (i4, i4) -> i1
    %159 = "comb.mux"(%158, %arg0, %arg1) <{twoState}> {sv.namehint = "_out_T_17"} : (i1, i32, i32) -> i32
    %160 = "comb.mux"(%156, %157, %159) <{twoState}> {sv.namehint = "_out_T_18"} : (i1, i32, i32) -> i32
    %161 = "comb.mux"(%154, %155, %160) <{twoState}> {sv.namehint = "_out_T_19"} : (i1, i32, i32) -> i32
    %162 = "comb.mux"(%152, %153, %161) <{twoState}> {sv.namehint = "_out_T_20"} : (i1, i32, i32) -> i32
    %163 = "comb.mux"(%151, %141, %162) <{twoState}> {sv.namehint = "_out_T_21"} : (i1, i32, i32) -> i32
    %164 = "comb.mux"(%150, %90, %163) <{twoState}> {sv.namehint = "_out_T_22"} : (i1, i32, i32) -> i32
    %165 = "comb.concat"(%10, %30) : (i31, i1) -> i32
    %166 = "comb.mux"(%147, %165, %164) <{twoState}> {sv.namehint = "_out_T_23"} : (i1, i32, i32) -> i32
    %167 = "comb.mux"(%144, %23, %166) <{twoState}> {sv.namehint = "out"} : (i1, i32, i32) -> i32
    "hw.output"(%167, %23) : (i32, i32) -> ()
  }) {module_type = !hw.modty<input io_A : i32, input io_B : i32, input io_alu_op : i4, output io_out : i32, output io_sum : i32>, parameters = [], result_locs = [#loc7, #loc8], sym_name = "AluArea", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i32, %arg1: i3):
    %0 = "hw.constant"() {value = 0 : i27} : () -> i27
    %1 = "hw.constant"() {value = false} : () -> i1
    %2 = "hw.constant"() {value = 0 : i12} : () -> i12
    %3 = "hw.constant"() {value = 1 : i3} : () -> i3
    %4 = "hw.constant"() {value = 2 : i3} : () -> i3
    %5 = "hw.constant"() {value = -3 : i3} : () -> i3
    %6 = "hw.constant"() {value = 3 : i3} : () -> i3
    %7 = "hw.constant"() {value = -4 : i3} : () -> i3
    %8 = "hw.constant"() {value = -2 : i3} : () -> i3
    %9 = "comb.extract"(%arg0) <{lowBit = 20 : i32}> {sv.namehint = "_Iimm_T"} : (i32) -> i12
    %10 = "comb.extract"(%arg0) <{lowBit = 25 : i32}> {sv.namehint = "_Simm_T"} : (i32) -> i7
    %11 = "comb.extract"(%arg0) <{lowBit = 7 : i32}> {sv.namehint = "_Simm_T_1"} : (i32) -> i5
    %12 = "comb.concat"(%10, %11) {sv.namehint = "_Simm_T_2"} : (i7, i5) -> i12
    %13 = "comb.extract"(%arg0) <{lowBit = 31 : i32}> {sv.namehint = "_Jimm_T"} : (i32) -> i1
    %14 = "comb.extract"(%arg0) <{lowBit = 7 : i32}> {sv.namehint = "_Bimm_T_1"} : (i32) -> i1
    %15 = "comb.extract"(%arg0) <{lowBit = 25 : i32}> {sv.namehint = "_Jimm_T_3"} : (i32) -> i6
    %16 = "comb.extract"(%arg0) <{lowBit = 8 : i32}> {sv.namehint = "_Bimm_T_3"} : (i32) -> i4
    %17 = "comb.concat"(%13, %14, %15, %16, %1) {sv.namehint = "_Bimm_T_4"} : (i1, i1, i6, i4, i1) -> i13
    %18 = "comb.extract"(%arg0) <{lowBit = 12 : i32}> {sv.namehint = "_Uimm_T"} : (i32) -> i20
    %19 = "comb.concat"(%18, %2) {sv.namehint = "_Uimm_T_1"} : (i20, i12) -> i32
    %20 = "comb.extract"(%arg0) <{lowBit = 12 : i32}> {sv.namehint = "_Jimm_T_1"} : (i32) -> i8
    %21 = "comb.extract"(%arg0) <{lowBit = 20 : i32}> {sv.namehint = "_Jimm_T_2"} : (i32) -> i1
    %22 = "comb.extract"(%arg0) <{lowBit = 21 : i32}> {sv.namehint = "Jimm_lo_hi"} : (i32) -> i10
    %23 = "comb.extract"(%arg0) <{lowBit = 15 : i32}> {sv.namehint = "_Zimm_T"} : (i32) -> i5
    %24 = "comb.extract"(%arg0) <{lowBit = 21 : i32}> : (i32) -> i11
    %25 = "comb.concat"(%24, %1) {sv.namehint = "_io_out_T"} : (i11, i1) -> i12
    %26 = "comb.icmp"(%arg1, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_2"} : (i3, i3) -> i1
    %27 = "comb.mux"(%26, %9, %25) <{twoState}> {sv.namehint = "_io_out_T_3"} : (i1, i12, i12) -> i12
    %28 = "comb.icmp"(%arg1, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_4"} : (i3, i3) -> i1
    %29 = "comb.mux"(%28, %12, %27) <{twoState}> {sv.namehint = "_io_out_T_5"} : (i1, i12, i12) -> i12
    %30 = "comb.icmp"(%arg1, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_6"} : (i3, i3) -> i1
    %31 = "comb.extract"(%29) <{lowBit = 11 : i32}> : (i12) -> i1
    %32 = "comb.concat"(%31, %29) : (i1, i12) -> i13
    %33 = "comb.mux"(%30, %17, %32) <{twoState}> {sv.namehint = "_io_out_T_7"} : (i1, i13, i13) -> i13
    %34 = "comb.icmp"(%arg1, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_8"} : (i3, i3) -> i1
    %35 = "comb.extract"(%33) <{lowBit = 12 : i32}> : (i13) -> i1
    %36 = "comb.replicate"(%35) : (i1) -> i19
    %37 = "comb.concat"(%36, %33) : (i19, i13) -> i32
    %38 = "comb.mux"(%34, %19, %37) <{twoState}> {sv.namehint = "_io_out_T_9"} : (i1, i32, i32) -> i32
    %39 = "comb.icmp"(%arg1, %7) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_10"} : (i3, i3) -> i1
    %40 = "comb.replicate"(%13) : (i1) -> i12
    %41 = "comb.concat"(%40, %20, %21, %22, %1) : (i12, i8, i1, i10, i1) -> i32
    %42 = "comb.mux"(%39, %41, %38) <{twoState}> {sv.namehint = "_io_out_T_11"} : (i1, i32, i32) -> i32
    %43 = "comb.icmp"(%arg1, %8) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_out_T_12"} : (i3, i3) -> i1
    %44 = "comb.concat"(%0, %23) : (i27, i5) -> i32
    %45 = "comb.mux"(%43, %44, %42) <{twoState}> {sv.namehint = "io_out"} : (i1, i32, i32) -> i32
    "hw.output"(%45) : (i32) -> ()
  }) {module_type = !hw.modty<input io_inst : i32, input io_sel : i3, output io_out : i32>, parameters = [], result_locs = [#loc9], sym_name = "ImmGenWire", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i32, %arg1: i32, %arg2: i3):
    %0 = "hw.constant"() {value = true} : () -> i1
    %1 = "hw.constant"() {value = 0 : i32} : () -> i32
    %2 = "hw.constant"() {value = 3 : i3} : () -> i3
    %3 = "hw.constant"() {value = -2 : i3} : () -> i3
    %4 = "hw.constant"() {value = 2 : i3} : () -> i3
    %5 = "hw.constant"() {value = -3 : i3} : () -> i3
    %6 = "hw.constant"() {value = 1 : i3} : () -> i3
    %7 = "hw.constant"() {value = -4 : i3} : () -> i3
    %8 = "comb.sub"(%arg0, %arg1) {sv.namehint = "_diff_T"} : (i32, i32) -> i32
    %9 = "comb.icmp"(%8, %1) <{predicate = 1 : i64, twoState}> {sv.namehint = "neq"} : (i32, i32) -> i1
    %10 = "comb.xor"(%9, %0) <{twoState}> {sv.namehint = "eq"} : (i1, i1) -> i1
    %11 = "comb.extract"(%arg0) <{lowBit = 31 : i32}> {sv.namehint = "_lt_T_1"} : (i32) -> i1
    %12 = "comb.extract"(%arg1) <{lowBit = 31 : i32}> {sv.namehint = "_ltu_T_1"} : (i32) -> i1
    %13 = "comb.icmp"(%11, %12) <{predicate = 0 : i64, twoState}> {sv.namehint = "isSameSign"} : (i1, i1) -> i1
    %14 = "comb.extract"(%8) <{lowBit = 31 : i32}> {sv.namehint = "_ltu_T"} : (i32) -> i1
    %15 = "comb.mux"(%13, %14, %11) <{twoState}> {sv.namehint = "lt"} : (i1, i1, i1) -> i1
    %16 = "comb.mux"(%13, %14, %12) <{twoState}> {sv.namehint = "ltu"} : (i1, i1, i1) -> i1
    %17 = "comb.xor"(%15, %0) <{twoState}> {sv.namehint = "ge"} : (i1, i1) -> i1
    %18 = "comb.xor"(%16, %0) <{twoState}> {sv.namehint = "geu"} : (i1, i1) -> i1
    %19 = "comb.icmp"(%arg2, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_taken_T"} : (i3, i3) -> i1
    %20 = "comb.and"(%19, %10) <{twoState}> {sv.namehint = "_io_taken_T_1"} : (i1, i1) -> i1
    %21 = "comb.icmp"(%arg2, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_taken_T_2"} : (i3, i3) -> i1
    %22 = "comb.and"(%21, %9) <{twoState}> {sv.namehint = "_io_taken_T_3"} : (i1, i1) -> i1
    %23 = "comb.icmp"(%arg2, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_taken_T_5"} : (i3, i3) -> i1
    %24 = "comb.and"(%23, %15) <{twoState}> {sv.namehint = "_io_taken_T_6"} : (i1, i1) -> i1
    %25 = "comb.icmp"(%arg2, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_taken_T_8"} : (i3, i3) -> i1
    %26 = "comb.and"(%25, %17) <{twoState}> {sv.namehint = "_io_taken_T_9"} : (i1, i1) -> i1
    %27 = "comb.icmp"(%arg2, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_taken_T_11"} : (i3, i3) -> i1
    %28 = "comb.and"(%27, %16) <{twoState}> {sv.namehint = "_io_taken_T_12"} : (i1, i1) -> i1
    %29 = "comb.icmp"(%arg2, %7) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_taken_T_14"} : (i3, i3) -> i1
    %30 = "comb.and"(%29, %18) <{twoState}> {sv.namehint = "_io_taken_T_15"} : (i1, i1) -> i1
    %31 = "comb.or"(%20, %22, %24, %26, %28, %30) <{twoState}> {sv.namehint = "io_taken"} : (i1, i1, i1, i1, i1, i1) -> i1
    "hw.output"(%31) : (i1) -> ()
  }) {module_type = !hw.modty<input io_rs1 : i32, input io_rs2 : i32, input io_br_type : i3, output io_taken : i1>, parameters = [], result_locs = [#loc10], sym_name = "BrCondArea", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: !seq.clock, %arg1: i1, %arg2: i1, %arg3: i32, %arg4: i1, %arg5: i32, %arg6: i1, %arg7: i32, %arg8: i2, %arg9: i1, %arg10: i1, %arg11: i1, %arg12: i3, %arg13: i4, %arg14: i3, %arg15: i2, %arg16: i3, %arg17: i2, %arg18: i1, %arg19: i3, %arg20: i1):
    %0 = "hw.constant"() {value = false} : () -> i1
    %1 = "hw.constant"() {value = 4 : i32} : () -> i32
    %2 = "hw.constant"() {value = 0 : i25} : () -> i25
    %3 = "hw.constant"() {value = 0 : i17} : () -> i17
    %4 = "hw.constant"() {value = 0 : i27} : () -> i27
    %5 = "hw.constant"() {value = true} : () -> i1
    %6 = "hw.constant"() {value = 0 : i282} : () -> i282
    %7 = "hw.constant"() {value = 0 : i3} : () -> i3
    %8 = "hw.constant"() {value = 0 : i2} : () -> i2
    %9 = "hw.constant"() {value = 4 : i33} : () -> i33
    %10 = "hw.constant"() {value = 1 : i4} : () -> i4
    %11 = "hw.constant"() {value = 3 : i5} : () -> i5
    %12 = "hw.constant"() {value = 508 : i33} : () -> i33
    %13 = "hw.constant"() {value = 0 : i255} : () -> i255
    %14 = "hw.constant"() {value = 0 : i5} : () -> i5
    %15 = "hw.constant"() {value = -4 : i3} : () -> i3
    %16 = "hw.constant"() {value = -1 : i2} : () -> i2
    %17 = "hw.constant"() {value = 1 : i2} : () -> i2
    %18 = "hw.constant"() {value = -2 : i2} : () -> i2
    %19 = "hw.constant"() {value = -2 : i3} : () -> i3
    %20 = "hw.constant"() {value = 2 : i3} : () -> i3
    %21 = "hw.constant"() {value = 3 : i3} : () -> i3
    %22 = "hw.constant"() {value = -3 : i3} : () -> i3
    %23 = "hw.constant"() {value = 19 : i32} : () -> i32
    %24 = "hw.constant"() {value = 0 : i32} : () -> i32
    %25:5 = "hw.instance"(%arg0, %arg1, %46, %40, %35, %33, %34, %32, %41, %36, %37, %42, %arg2, %arg3) {argNames = ["clock", "reset", "io_stall", "io_cmd", "io_in", "io_pc", "io_addr", "io_inst", "io_illegal", "io_st_type", "io_ld_type", "io_pc_check", "io_host_fromhost_valid", "io_host_fromhost_bits"], instanceName = "csr", moduleName = @CSR, parameters = [], resultNames = ["io_out", "io_expt", "io_evec", "io_epc", "io_host_tohost"], sv.namehint = "io_host_tohost"} : (!seq.clock, i1, i1, i3, i32, i32, i32, i32, i1, i2, i3, i1, i1, i32) -> (i32, i1, i32, i32, i32)
    %26:2 = "hw.instance"(%arg0, %69, %70, %164, %71, %165) {argNames = ["clock", "io_raddr1", "io_raddr2", "io_wen", "io_waddr", "io_wdata"], instanceName = "regFile", moduleName = @RegFile, parameters = [], resultNames = ["io_rdata1", "io_rdata2"]} : (!seq.clock, i5, i5, i1, i5, i32) -> (i32, i32)
    %27:2 = "hw.instance"(%81, %82, %arg13) {argNames = ["io_A", "io_B", "io_alu_op"], instanceName = "alu", moduleName = @AluArea, parameters = [], resultNames = ["io_out", "io_sum"]} : (i32, i32, i4) -> (i32, i32)
    %28 = "hw.instance"(%30, %arg12) {argNames = ["io_inst", "io_sel"], instanceName = "immGen", moduleName = @ImmGenWire, parameters = [], resultNames = ["io_out"]} : (i32, i3) -> i32
    %29 = "hw.instance"(%78, %80, %arg14) {argNames = ["io_rs1", "io_rs2", "io_br_type"], instanceName = "brCond", moduleName = @BrCondArea, parameters = [], resultNames = ["io_taken"]} : (i32, i32, i3) -> i1
    %30 = "seq.firreg"(%68, %arg0, %arg1, %23) <{name = "fe_reg_inst"}> {firrtl.random_init_start = 0 : ui64, sv.namehint = "fe_reg_inst"} : (i32, !seq.clock, i1, i32) -> i32
    %31 = "seq.firreg"(%67, %arg0, %arg1, %24) <{name = "fe_reg_pc"}> {firrtl.random_init_start = 32 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %32 = "seq.firreg"(%116, %arg0, %arg1, %23) <{name = "ew_reg_inst"}> {firrtl.random_init_start = 64 : ui64, sv.namehint = "ew_reg_inst"} : (i32, !seq.clock, i1, i32) -> i32
    %33 = "seq.firreg"(%115, %arg0, %arg1, %24) <{name = "ew_reg_pc"}> {firrtl.random_init_start = 96 : ui64, sv.namehint = "ew_reg_pc"} : (i32, !seq.clock, i1, i32) -> i32
    %34 = "seq.firreg"(%117, %arg0, %arg1, %24) <{name = "ew_reg_alu"}> {firrtl.random_init_start = 128 : ui64, sv.namehint = "ew_reg_alu"} : (i32, !seq.clock, i1, i32) -> i32
    %35 = "seq.firreg"(%120, %arg0, %arg1, %24) <{name = "ew_reg_csr_in"}> {firrtl.random_init_start = 160 : ui64, sv.namehint = "ew_reg_csr_in"} : (i32, !seq.clock, i1, i32) -> i32
    %36 = "seq.firreg"(%122, %arg0) <{name = "st_type"}> {firrtl.random_init_start = 192 : ui64, sv.namehint = "st_type"} : (i2, !seq.clock) -> i2
    %37 = "seq.firreg"(%124, %arg0) <{name = "ld_type"}> {firrtl.random_init_start = 194 : ui64, sv.namehint = "ld_type"} : (i3, !seq.clock) -> i3
    %38 = "seq.firreg"(%125, %arg0) <{name = "wb_sel"}> {firrtl.random_init_start = 197 : ui64} : (i2, !seq.clock) -> i2
    %39 = "seq.firreg"(%128, %arg0) <{name = "wb_en"}> {firrtl.random_init_start = 199 : ui64} : (i1, !seq.clock) -> i1
    %40 = "seq.firreg"(%130, %arg0) <{name = "csr_cmd"}> {firrtl.random_init_start = 200 : ui64, sv.namehint = "csr_cmd"} : (i3, !seq.clock) -> i3
    %41 = "seq.firreg"(%132, %arg0) <{name = "illegal"}> {firrtl.random_init_start = 203 : ui64, sv.namehint = "illegal"} : (i1, !seq.clock) -> i1
    %42 = "seq.firreg"(%134, %arg0) <{name = "pc_check"}> {firrtl.random_init_start = 204 : ui64, sv.namehint = "pc_check"} : (i1, !seq.clock) -> i1
    %43 = "seq.firreg"(%arg1, %arg0) <{name = "started"}> {firrtl.random_init_start = 205 : ui64} : (i1, !seq.clock) -> i1
    %44 = "comb.xor"(%arg4, %5) <{twoState}> {sv.namehint = "_stall_T"} : (i1, i1) -> i1
    %45 = "comb.xor"(%arg6, %5) <{twoState}> {sv.namehint = "_stall_T_1"} : (i1, i1) -> i1
    %46 = "comb.or"(%44, %45) <{twoState}> {sv.namehint = "stall"} : (i1, i1) -> i1
    %47 = "seq.firreg"(%61, %arg0, %arg1, %12) <{name = "pc"}> {firrtl.random_init_start = 206 : ui64} : (i33, !seq.clock, i1, i33) -> i33
    %48 = "comb.add"(%47, %9) {sv.namehint = "_next_pc_T"} : (i33, i33) -> i33
    %49 = "comb.icmp"(%arg8, %16) <{predicate = 0 : i64, twoState}> {sv.namehint = "_next_pc_T_2"} : (i2, i2) -> i1
    %50 = "comb.icmp"(%arg8, %17) <{predicate = 0 : i64, twoState}> {sv.namehint = "_pc_check_T"} : (i2, i2) -> i1
    %51 = "comb.or"(%50, %29) <{twoState}> {sv.namehint = "_next_pc_T_4"} : (i1, i1) -> i1
    %52 = "comb.extract"(%27#1) <{lowBit = 1 : i32}> : (i32) -> i31
    %53 = "comb.concat"(%0, %52, %0) {sv.namehint = "_next_pc_T_6"} : (i1, i31, i1) -> i33
    %54 = "comb.icmp"(%arg8, %18) <{predicate = 0 : i64, twoState}> {sv.namehint = "_next_pc_T_7"} : (i2, i2) -> i1
    %55 = "comb.mux"(%54, %47, %48) <{twoState}> {sv.namehint = "_next_pc_T_8"} : (i1, i33, i33) -> i33
    %56 = "comb.mux"(%51, %53, %55) <{twoState}> {sv.namehint = "_next_pc_T_9"} : (i1, i33, i33) -> i33
    %57 = "comb.concat"(%0, %25#3) : (i1, i32) -> i33
    %58 = "comb.mux"(%49, %57, %56) <{twoState}> {sv.namehint = "_next_pc_T_10"} : (i1, i33, i33) -> i33
    %59 = "comb.concat"(%0, %25#2) : (i1, i32) -> i33
    %60 = "comb.mux"(%25#1, %59, %58) <{twoState}> {sv.namehint = "_next_pc_T_11"} : (i1, i33, i33) -> i33
    %61 = "comb.mux"(%46, %47, %60) <{twoState}> {sv.namehint = "next_pc"} : (i1, i33, i33) -> i33
    %62 = "comb.or"(%43, %arg9, %29, %25#1) <{twoState}> {sv.namehint = "_inst_T_2"} : (i1, i1, i1, i1) -> i1
    %63 = "comb.mux"(%62, %23, %arg5) <{twoState}> {sv.namehint = "inst"} : (i1, i32, i32) -> i32
    %64 = "comb.extract"(%61) <{lowBit = 0 : i32}> {sv.namehint = "io_icache_req_bits_addr"} : (i33) -> i32
    %65 = "comb.xor"(%46, %5) <{twoState}> {sv.namehint = "io_icache_req_valid"} : (i1, i1) -> i1
    %66 = "comb.extract"(%47) <{lowBit = 0 : i32}> : (i33) -> i32
    %67 = "comb.mux"(%46, %31, %66) <{twoState}> : (i1, i32, i32) -> i32
    %68 = "comb.mux"(%46, %30, %63) <{twoState}> : (i1, i32, i32) -> i32
    %69 = "comb.extract"(%30) <{lowBit = 15 : i32}> {sv.namehint = "rs1_addr"} : (i32) -> i5
    %70 = "comb.extract"(%30) <{lowBit = 20 : i32}> {sv.namehint = "rs2_addr"} : (i32) -> i5
    %71 = "comb.extract"(%32) <{lowBit = 7 : i32}> {sv.namehint = "wb_rd_addr"} : (i32) -> i5
    %72 = "comb.icmp"(%69, %14) <{predicate = 1 : i64, twoState}> {sv.namehint = "_rs1hazard_T"} : (i5, i5) -> i1
    %73 = "comb.icmp"(%69, %71) <{predicate = 0 : i64, twoState}> {sv.namehint = "_rs1hazard_T_2"} : (i5, i5) -> i1
    %74 = "comb.icmp"(%70, %14) <{predicate = 1 : i64, twoState}> {sv.namehint = "_rs2hazard_T"} : (i5, i5) -> i1
    %75 = "comb.icmp"(%70, %71) <{predicate = 0 : i64, twoState}> {sv.namehint = "_rs2hazard_T_2"} : (i5, i5) -> i1
    %76 = "comb.icmp"(%38, %8) <{predicate = 0 : i64, twoState}> {sv.namehint = "_rs2_T"} : (i2, i2) -> i1
    %77 = "comb.and"(%76, %39, %72, %73) <{twoState}> {sv.namehint = "_rs1_T_1"} : (i1, i1, i1, i1) -> i1
    %78 = "comb.mux"(%77, %34, %26#0) <{twoState}> {sv.namehint = "rs1"} : (i1, i32, i32) -> i32
    %79 = "comb.and"(%76, %39, %74, %75) <{twoState}> {sv.namehint = "_rs2_T_1"} : (i1, i1, i1, i1) -> i1
    %80 = "comb.mux"(%79, %34, %26#1) <{twoState}> {sv.namehint = "rs2"} : (i1, i32, i32) -> i32
    %81 = "comb.mux"(%arg10, %78, %31) <{twoState}> {sv.namehint = "_alu_io_A_T_1"} : (i1, i32, i32) -> i32
    %82 = "comb.mux"(%arg11, %80, %28) <{twoState}> {sv.namehint = "_alu_io_B_T_1"} : (i1, i32, i32) -> i32
    %83 = "comb.extract"(%34) <{lowBit = 2 : i32}> : (i32) -> i30
    %84 = "comb.extract"(%27#1) <{lowBit = 2 : i32}> : (i32) -> i30
    %85 = "comb.mux"(%46, %83, %84) {sv.namehint = "_daddr_T"} : (i1, i30, i30) -> i30
    %86 = "comb.extract"(%27#1) <{lowBit = 0 : i32}> : (i32) -> i2
    %87 = "comb.icmp"(%arg15, %8) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_dcache_req_valid_T_1"} : (i2, i2) -> i1
    %88 = "comb.icmp"(%arg16, %7) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_dcache_req_valid_T_2"} : (i3, i3) -> i1
    %89 = "comb.or"(%87, %88) <{twoState}> {sv.namehint = "_io_dcache_req_valid_T_3"} : (i1, i1) -> i1
    %90 = "comb.and"(%65, %89) <{twoState}> {sv.namehint = "io_dcache_req_valid"} : (i1, i1) -> i1
    %91 = "comb.concat"(%85, %8) {sv.namehint = "io_dcache_req_bits_addr"} : (i30, i2) -> i32
    %92 = "comb.concat"(%13, %80) : (i255, i32) -> i287
    %93 = "comb.concat"(%6, %86, %7) : (i282, i2, i3) -> i287
    %94 = "comb.shl"(%92, %93) <{twoState}> {sv.namehint = "_io_dcache_req_bits_data_T"} : (i287, i287) -> i287
    %95 = "comb.extract"(%94) <{lowBit = 0 : i32}> {sv.namehint = "io_dcache_req_bits_data"} : (i287) -> i32
    %96 = "comb.mux"(%46, %36, %arg15) <{twoState}> {sv.namehint = "_io_dcache_req_bits_mask_T"} : (i1, i2, i2) -> i2
    %97 = "comb.extract"(%27#1) <{lowBit = 0 : i32}> {sv.namehint = "_io_dcache_req_bits_mask_T_3"} : (i32) -> i2
    %98 = "comb.concat"(%7, %97) : (i3, i2) -> i5
    %99 = "comb.shl"(%11, %98) <{twoState}> {sv.namehint = "_io_dcache_req_bits_mask_T_2"} : (i5, i5) -> i5
    %100 = "comb.concat"(%8, %97) : (i2, i2) -> i4
    %101 = "comb.shl"(%10, %100) <{twoState}> {sv.namehint = "_io_dcache_req_bits_mask_T_4"} : (i4, i4) -> i4
    %102 = "comb.icmp"(%96, %17) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_dcache_req_bits_mask_T_5"} : (i2, i2) -> i1
    %103 = "comb.replicate"(%102) {sv.namehint = "_io_dcache_req_bits_mask_T_6"} : (i1) -> i4
    %104 = "comb.icmp"(%96, %18) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_dcache_req_bits_mask_T_7"} : (i2, i2) -> i1
    %105 = "comb.extract"(%99) <{lowBit = 0 : i32}> : (i5) -> i4
    %106 = "comb.mux"(%104, %105, %103) {sv.namehint = "_io_dcache_req_bits_mask_T_8"} : (i1, i4, i4) -> i4
    %107 = "comb.icmp"(%96, %16) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_dcache_req_bits_mask_T_9"} : (i2, i2) -> i1
    %108 = "comb.mux"(%107, %101, %106) {sv.namehint = "_io_dcache_req_bits_mask_T_10"} : (i1, i4, i4) -> i4
    %109 = "comb.and"(%65, %25#1) <{twoState}> : (i1, i1) -> i1
    %110 = "comb.or"(%arg1, %109) <{twoState}> : (i1, i1) -> i1
    %111 = "comb.xor"(%25#1, %5) <{twoState}> : (i1, i1) -> i1
    %112 = "comb.and"(%65, %111) <{twoState}> : (i1, i1) -> i1
    %113 = "comb.xor"(%112, %5) : (i1, i1) -> i1
    %114 = "comb.or"(%110, %113) : (i1, i1) -> i1
    %115 = "comb.mux"(%114, %33, %31) <{twoState}> : (i1, i32, i32) -> i32
    %116 = "comb.mux"(%114, %32, %30) <{twoState}> : (i1, i32, i32) -> i32
    %117 = "comb.mux"(%114, %34, %27#0) <{twoState}> : (i1, i32, i32) -> i32
    %118 = "comb.icmp"(%arg12, %19) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ew_reg_csr_in_T"} : (i3, i3) -> i1
    %119 = "comb.mux"(%118, %28, %78) <{twoState}> {sv.namehint = "_ew_reg_csr_in_T_1"} : (i1, i32, i32) -> i32
    %120 = "comb.mux"(%114, %35, %119) <{twoState}> : (i1, i32, i32) -> i32
    %121 = "comb.mux"(%112, %arg15, %36) <{twoState}> : (i1, i2, i2) -> i2
    %122 = "comb.mux"(%110, %8, %121) <{twoState}> : (i1, i2, i2) -> i2
    %123 = "comb.mux"(%112, %arg16, %37) <{twoState}> : (i1, i3, i3) -> i3
    %124 = "comb.mux"(%110, %7, %123) <{twoState}> : (i1, i3, i3) -> i3
    %125 = "comb.mux"(%114, %38, %arg17) <{twoState}> : (i1, i2, i2) -> i2
    %126 = "comb.mux"(%112, %arg18, %39) <{twoState}> : (i1, i1, i1) -> i1
    %127 = "comb.xor"(%110, %5) : (i1, i1) -> i1
    %128 = "comb.and"(%127, %126) : (i1, i1) -> i1
    %129 = "comb.mux"(%112, %arg19, %40) <{twoState}> : (i1, i3, i3) -> i3
    %130 = "comb.mux"(%110, %7, %129) <{twoState}> : (i1, i3, i3) -> i3
    %131 = "comb.mux"(%112, %arg20, %41) <{twoState}> : (i1, i1, i1) -> i1
    %132 = "comb.and"(%127, %131) : (i1, i1) -> i1
    %133 = "comb.mux"(%112, %50, %42) <{twoState}> : (i1, i1, i1) -> i1
    %134 = "comb.and"(%127, %133) : (i1, i1) -> i1
    %135 = "comb.extract"(%34) <{lowBit = 0 : i32}> : (i32) -> i2
    %136 = "comb.concat"(%4, %135, %7) : (i27, i2, i3) -> i32
    %137 = "comb.shru"(%arg7, %136) <{twoState}> {sv.namehint = "lshift"} : (i32, i32) -> i32
    %138 = "comb.concat"(%0, %arg7) : (i1, i32) -> i33
    %139 = "comb.extract"(%137) <{lowBit = 0 : i32}> {sv.namehint = "_load_T_5"} : (i32) -> i16
    %140 = "comb.extract"(%137) <{lowBit = 0 : i32}> {sv.namehint = "_load_T_7"} : (i32) -> i8
    %141 = "comb.icmp"(%37, %20) <{predicate = 0 : i64, twoState}> {sv.namehint = "_load_T_9"} : (i3, i3) -> i1
    %142 = "comb.extract"(%137) <{lowBit = 15 : i32}> : (i32) -> i1
    %143 = "comb.replicate"(%142) : (i1) -> i17
    %144 = "comb.concat"(%143, %139) : (i17, i16) -> i33
    %145 = "comb.mux"(%141, %144, %138) <{twoState}> {sv.namehint = "_load_T_10"} : (i1, i33, i33) -> i33
    %146 = "comb.icmp"(%37, %21) <{predicate = 0 : i64, twoState}> {sv.namehint = "_load_T_11"} : (i3, i3) -> i1
    %147 = "comb.extract"(%137) <{lowBit = 7 : i32}> : (i32) -> i1
    %148 = "comb.replicate"(%147) : (i1) -> i25
    %149 = "comb.concat"(%148, %140) : (i25, i8) -> i33
    %150 = "comb.mux"(%146, %149, %145) <{twoState}> {sv.namehint = "_load_T_12"} : (i1, i33, i33) -> i33
    %151 = "comb.icmp"(%37, %15) <{predicate = 0 : i64, twoState}> {sv.namehint = "_load_T_13"} : (i3, i3) -> i1
    %152 = "comb.concat"(%3, %139) : (i17, i16) -> i33
    %153 = "comb.mux"(%151, %152, %150) <{twoState}> {sv.namehint = "_load_T_14"} : (i1, i33, i33) -> i33
    %154 = "comb.icmp"(%37, %22) <{predicate = 0 : i64, twoState}> {sv.namehint = "_load_T_15"} : (i3, i3) -> i1
    %155 = "comb.concat"(%2, %140) : (i25, i8) -> i33
    %156 = "comb.mux"(%154, %155, %153) <{twoState}> {sv.namehint = "load"} : (i1, i33, i33) -> i33
    %157 = "comb.concat"(%0, %34) : (i1, i32) -> i33
    %158 = "comb.add"(%33, %1) {sv.namehint = "_regWrite_T_1"} : (i32, i32) -> i32
    %159 = "comb.concat"(%0, %158) : (i1, i32) -> i33
    %160 = "comb.concat"(%0, %25#0) : (i1, i32) -> i33
    %161 = "hw.array_create"(%160, %159, %156, %157) : (i33, i33, i33, i33) -> !hw.array<4xi33>
    %162 = "hw.array_get"(%161, %38) {sv.namehint = "_regWrite_T_10"} : (!hw.array<4xi33>, i2) -> i33
    %163 = "comb.xor"(%25#1, %5) <{twoState}> {sv.namehint = "_regFile_io_wen_T_2"} : (i1, i1) -> i1
    %164 = "comb.and"(%39, %65, %163) <{twoState}> {sv.namehint = "_regFile_io_wen_T_3"} : (i1, i1, i1) -> i1
    %165 = "comb.extract"(%162) <{lowBit = 0 : i32}> : (i33) -> i32
    "hw.output"(%25#4, %65, %64, %25#1, %90, %91, %95, %108, %30) : (i32, i1, i32, i1, i1, i32, i32, i4, i32) -> ()
  }) {module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_host_fromhost_valid : i1, input io_host_fromhost_bits : i32, output io_host_tohost : i32, output io_icache_req_valid : i1, output io_icache_req_bits_addr : i32, input io_icache_resp_valid : i1, input io_icache_resp_bits_data : i32, output io_dcache_abort : i1, output io_dcache_req_valid : i1, output io_dcache_req_bits_addr : i32, output io_dcache_req_bits_data : i32, output io_dcache_req_bits_mask : i4, input io_dcache_resp_valid : i1, input io_dcache_resp_bits_data : i32, output io_ctrl_inst : i32, input io_ctrl_pc_sel : i2, input io_ctrl_inst_kill : i1, input io_ctrl_A_sel : i1, input io_ctrl_B_sel : i1, input io_ctrl_imm_sel : i3, input io_ctrl_alu_op : i4, input io_ctrl_br_type : i3, input io_ctrl_st_type : i2, input io_ctrl_ld_type : i3, input io_ctrl_wb_sel : i2, input io_ctrl_wb_en : i1, input io_ctrl_csr_cmd : i3, input io_ctrl_illegal : i1>, parameters = [], result_locs = [#loc11, #loc12, #loc13, #loc14, #loc15, #loc16, #loc17, #loc18, #loc19], sym_name = "Datapath", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i32):
    %0 = "hw.constant"() {value = true} : () -> i1
    %1 = "hw.constant"() {value = 0 : i2} : () -> i2
    %2 = "hw.constant"() {value = false} : () -> i1
    %3 = "hw.constant"() {value = -13 : i10} : () -> i10
    %4 = "hw.constant"() {value = -141 : i10} : () -> i10
    %5 = "hw.constant"() {value = -269 : i10} : () -> i10
    %6 = "hw.constant"() {value = 499 : i10} : () -> i10
    %7 = "hw.constant"() {value = 371 : i10} : () -> i10
    %8 = "hw.constant"() {value = 243 : i10} : () -> i10
    %9 = "hw.constant"() {value = 15 : i24} : () -> i24
    %10 = "hw.constant"() {value = 947 : i17} : () -> i17
    %11 = "hw.constant"() {value = 819 : i17} : () -> i17
    %12 = "hw.constant"() {value = 33459 : i17} : () -> i17
    %13 = "hw.constant"() {value = 691 : i17} : () -> i17
    %14 = "hw.constant"() {value = 563 : i17} : () -> i17
    %15 = "hw.constant"() {value = 435 : i17} : () -> i17
    %16 = "hw.constant"() {value = 307 : i17} : () -> i17
    %17 = "hw.constant"() {value = 179 : i17} : () -> i17
    %18 = "hw.constant"() {value = 32819 : i17} : () -> i17
    %19 = "hw.constant"() {value = 51 : i17} : () -> i17
    %20 = "hw.constant"() {value = 33427 : i17} : () -> i17
    %21 = "hw.constant"() {value = 659 : i17} : () -> i17
    %22 = "hw.constant"() {value = 147 : i17} : () -> i17
    %23 = "hw.constant"() {value = -109 : i10} : () -> i10
    %24 = "hw.constant"() {value = -237 : i10} : () -> i10
    %25 = "hw.constant"() {value = -493 : i10} : () -> i10
    %26 = "hw.constant"() {value = 403 : i10} : () -> i10
    %27 = "hw.constant"() {value = 275 : i10} : () -> i10
    %28 = "hw.constant"() {value = 19 : i10} : () -> i10
    %29 = "hw.constant"() {value = 291 : i10} : () -> i10
    %30 = "hw.constant"() {value = 163 : i10} : () -> i10
    %31 = "hw.constant"() {value = 35 : i10} : () -> i10
    %32 = "hw.constant"() {value = -381 : i10} : () -> i10
    %33 = "hw.constant"() {value = -509 : i10} : () -> i10
    %34 = "hw.constant"() {value = 259 : i10} : () -> i10
    %35 = "hw.constant"() {value = 131 : i10} : () -> i10
    %36 = "hw.constant"() {value = 3 : i10} : () -> i10
    %37 = "hw.constant"() {value = -29 : i10} : () -> i10
    %38 = "hw.constant"() {value = -157 : i10} : () -> i10
    %39 = "hw.constant"() {value = -285 : i10} : () -> i10
    %40 = "hw.constant"() {value = -413 : i10} : () -> i10
    %41 = "hw.constant"() {value = 227 : i10} : () -> i10
    %42 = "hw.constant"() {value = 99 : i10} : () -> i10
    %43 = "hw.constant"() {value = 103 : i10} : () -> i10
    %44 = "hw.constant"() {value = -17 : i7} : () -> i7
    %45 = "hw.constant"() {value = 23 : i7} : () -> i7
    %46 = "hw.constant"() {value = 55 : i7} : () -> i7
    %47 = "hw.constant"() {value = 270532723 : i32} : () -> i32
    %48 = "hw.constant"() {value = 268435571 : i32} : () -> i32
    %49 = "hw.constant"() {value = 1048691 : i32} : () -> i32
    %50 = "hw.constant"() {value = 115 : i32} : () -> i32
    %51 = "hw.constant"() {value = 4111 : i32} : () -> i32
    %52 = "hw.constant"() {value = -1 : i2} : () -> i2
    %53 = "hw.constant"() {value = -2 : i2} : () -> i2
    %54 = "hw.constant"() {value = 1 : i2} : () -> i2
    %55 = "hw.constant"() {value = -2 : i3} : () -> i3
    %56 = "hw.constant"() {value = 1 : i3} : () -> i3
    %57 = "hw.constant"() {value = 2 : i3} : () -> i3
    %58 = "hw.constant"() {value = -3 : i3} : () -> i3
    %59 = "hw.constant"() {value = -4 : i3} : () -> i3
    %60 = "hw.constant"() {value = 3 : i3} : () -> i3
    %61 = "hw.constant"() {value = -6 : i4} : () -> i4
    %62 = "hw.constant"() {value = 2 : i4} : () -> i4
    %63 = "hw.constant"() {value = 3 : i4} : () -> i4
    %64 = "hw.constant"() {value = -7 : i4} : () -> i4
    %65 = "hw.constant"() {value = -8 : i4} : () -> i4
    %66 = "hw.constant"() {value = 4 : i4} : () -> i4
    %67 = "hw.constant"() {value = 7 : i4} : () -> i4
    %68 = "hw.constant"() {value = 5 : i4} : () -> i4
    %69 = "hw.constant"() {value = 6 : i4} : () -> i4
    %70 = "hw.constant"() {value = 1 : i4} : () -> i4
    %71 = "hw.constant"() {value = 0 : i4} : () -> i4
    %72 = "hw.constant"() {value = -5 : i4} : () -> i4
    %73 = "hw.constant"() {value = -1 : i4} : () -> i4
    %74 = "hw.constant"() {value = 0 : i3} : () -> i3
    %75 = "comb.extract"(%arg0) <{lowBit = 0 : i32}> : (i32) -> i7
    %76 = "comb.icmp"(%75, %46) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_1"} : (i7, i7) -> i1
    %77 = "comb.icmp"(%75, %45) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_3"} : (i7, i7) -> i1
    %78 = "comb.icmp"(%75, %44) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_5"} : (i7, i7) -> i1
    %79 = "comb.extract"(%arg0) <{lowBit = 12 : i32}> : (i32) -> i3
    %80 = "comb.concat"(%79, %75) : (i3, i7) -> i10
    %81 = "comb.icmp"(%80, %43) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_7"} : (i10, i10) -> i1
    %82 = "comb.icmp"(%80, %42) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_9"} : (i10, i10) -> i1
    %83 = "comb.icmp"(%80, %41) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_11"} : (i10, i10) -> i1
    %84 = "comb.icmp"(%80, %40) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_13"} : (i10, i10) -> i1
    %85 = "comb.icmp"(%80, %39) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_15"} : (i10, i10) -> i1
    %86 = "comb.icmp"(%80, %38) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_17"} : (i10, i10) -> i1
    %87 = "comb.icmp"(%80, %37) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_19"} : (i10, i10) -> i1
    %88 = "comb.icmp"(%80, %36) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_21"} : (i10, i10) -> i1
    %89 = "comb.icmp"(%80, %35) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_23"} : (i10, i10) -> i1
    %90 = "comb.icmp"(%80, %34) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_25"} : (i10, i10) -> i1
    %91 = "comb.icmp"(%80, %33) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_27"} : (i10, i10) -> i1
    %92 = "comb.icmp"(%80, %32) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_29"} : (i10, i10) -> i1
    %93 = "comb.icmp"(%80, %31) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_31"} : (i10, i10) -> i1
    %94 = "comb.icmp"(%80, %30) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_33"} : (i10, i10) -> i1
    %95 = "comb.icmp"(%80, %29) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_35"} : (i10, i10) -> i1
    %96 = "comb.icmp"(%80, %28) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_37"} : (i10, i10) -> i1
    %97 = "comb.icmp"(%80, %27) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_39"} : (i10, i10) -> i1
    %98 = "comb.icmp"(%80, %26) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_41"} : (i10, i10) -> i1
    %99 = "comb.icmp"(%80, %25) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_43"} : (i10, i10) -> i1
    %100 = "comb.icmp"(%80, %24) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_45"} : (i10, i10) -> i1
    %101 = "comb.icmp"(%80, %23) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_47"} : (i10, i10) -> i1
    %102 = "comb.extract"(%arg0) <{lowBit = 25 : i32}> : (i32) -> i7
    %103 = "comb.concat"(%102, %79, %75) : (i7, i3, i7) -> i17
    %104 = "comb.icmp"(%103, %22) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_49"} : (i17, i17) -> i1
    %105 = "comb.icmp"(%103, %21) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_51"} : (i17, i17) -> i1
    %106 = "comb.icmp"(%103, %20) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_53"} : (i17, i17) -> i1
    %107 = "comb.icmp"(%103, %19) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_55"} : (i17, i17) -> i1
    %108 = "comb.icmp"(%103, %18) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_57"} : (i17, i17) -> i1
    %109 = "comb.icmp"(%103, %17) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_59"} : (i17, i17) -> i1
    %110 = "comb.icmp"(%103, %16) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_61"} : (i17, i17) -> i1
    %111 = "comb.icmp"(%103, %15) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_63"} : (i17, i17) -> i1
    %112 = "comb.icmp"(%103, %14) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_65"} : (i17, i17) -> i1
    %113 = "comb.icmp"(%103, %13) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_67"} : (i17, i17) -> i1
    %114 = "comb.icmp"(%103, %12) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_69"} : (i17, i17) -> i1
    %115 = "comb.icmp"(%103, %11) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_71"} : (i17, i17) -> i1
    %116 = "comb.icmp"(%103, %10) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_206"} : (i17, i17) -> i1
    %117 = "comb.extract"(%arg0) <{lowBit = 28 : i32}> : (i32) -> i4
    %118 = "comb.extract"(%arg0) <{lowBit = 0 : i32}> : (i32) -> i20
    %119 = "comb.concat"(%117, %118) : (i4, i20) -> i24
    %120 = "comb.icmp"(%119, %9) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_75"} : (i24, i24) -> i1
    %121 = "comb.icmp"(%arg0, %51) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_77"} : (i32, i32) -> i1
    %122 = "comb.icmp"(%80, %8) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_79"} : (i10, i10) -> i1
    %123 = "comb.icmp"(%80, %7) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_81"} : (i10, i10) -> i1
    %124 = "comb.icmp"(%80, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_153"} : (i10, i10) -> i1
    %125 = "comb.icmp"(%80, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_85"} : (i10, i10) -> i1
    %126 = "comb.icmp"(%80, %4) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_87"} : (i10, i10) -> i1
    %127 = "comb.icmp"(%80, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_582"} : (i10, i10) -> i1
    %128 = "comb.icmp"(%arg0, %50) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_91"} : (i32, i32) -> i1
    %129 = "comb.icmp"(%arg0, %49) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_93"} : (i32, i32) -> i1
    %130 = "comb.icmp"(%arg0, %48) <{predicate = 0 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_387"} : (i32, i32) -> i1
    %131 = "comb.replicate"(%130) {sv.namehint = "_ctrlSignals_T_99"} : (i1) -> i2
    %132 = "comb.or"(%128, %129) <{twoState}> : (i1, i1) -> i1
    %133 = "comb.mux"(%132, %1, %131) <{twoState}> {sv.namehint = "_ctrlSignals_T_101"} : (i1, i2, i2) -> i2
    %134 = "comb.or"(%125, %126, %127) <{twoState}> : (i1, i1, i1) -> i1
    %135 = "comb.or"(%121, %122, %123, %124, %134) <{twoState}> : (i1, i1, i1, i1, i1) -> i1
    %136 = "comb.mux"(%135, %53, %133) <{twoState}> {sv.namehint = "_ctrlSignals_T_108"} : (i1, i2, i2) -> i2
    %137 = "comb.or"(%93, %94, %95, %96, %97, %98, %99, %100, %101, %104, %105, %106, %107, %108, %109, %110, %111, %112, %113, %114, %115, %116, %120) <{twoState}> : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %138 = "comb.mux"(%137, %1, %136) <{twoState}> {sv.namehint = "_ctrlSignals_T_131"} : (i1, i2, i2) -> i2
    %139 = "comb.or"(%88, %89, %90, %91, %92) <{twoState}> : (i1, i1, i1, i1, i1) -> i1
    %140 = "comb.mux"(%139, %53, %138) <{twoState}> {sv.namehint = "_ctrlSignals_T_136"} : (i1, i2, i2) -> i2
    %141 = "comb.or"(%82, %83, %84, %85, %86, %87) <{twoState}> : (i1, i1, i1, i1, i1, i1) -> i1
    %142 = "comb.mux"(%141, %1, %140) <{twoState}> {sv.namehint = "_ctrlSignals_T_142"} : (i1, i2, i2) -> i2
    %143 = "comb.or"(%78, %81) <{twoState}> : (i1, i1) -> i1
    %144 = "comb.mux"(%143, %54, %142) <{twoState}> {sv.namehint = "_ctrlSignals_T_144"} : (i1, i2, i2) -> i2
    %145 = "comb.or"(%76, %77) <{twoState}> : (i1, i1) -> i1
    %146 = "comb.mux"(%145, %1, %144) <{twoState}> {sv.namehint = "ctrlSignals_0"} : (i1, i2, i2) -> i2
    %147 = "comb.or"(%122, %123, %124) {sv.namehint = "_ctrlSignals_T_155"} : (i1, i1, i1) -> i1
    %148 = "comb.or"(%120, %121) <{twoState}> : (i1, i1) -> i1
    %149 = "comb.xor"(%148, %0) : (i1, i1) -> i1
    %150 = "comb.and"(%149, %147) {sv.namehint = "_ctrlSignals_T_157"} : (i1, i1) -> i1
    %151 = "comb.or"(%96, %97, %98, %99, %100, %101, %104, %105, %106, %107, %108, %109, %110, %111, %112, %113, %114, %115, %116) <{twoState}> : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %152 = "comb.or"(%88, %89, %90, %91, %92, %93, %94, %95, %151, %150) {sv.namehint = "_ctrlSignals_T_184"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %153 = "comb.xor"(%141, %0) : (i1, i1) -> i1
    %154 = "comb.and"(%153, %152) {sv.namehint = "_ctrlSignals_T_190"} : (i1, i1) -> i1
    %155 = "comb.or"(%81, %154) {sv.namehint = "_ctrlSignals_T_191"} : (i1, i1) -> i1
    %156 = "comb.or"(%76, %77, %78) <{twoState}> : (i1, i1, i1) -> i1
    %157 = "comb.xor"(%156, %0) : (i1, i1) -> i1
    %158 = "comb.and"(%157, %155) {sv.namehint = "ctrlSignals_1"} : (i1, i1) -> i1
    %159 = "comb.or"(%107, %108, %109, %110, %111, %112, %113, %114, %115, %116) {sv.namehint = "_ctrlSignals_T_215"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %160 = "comb.or"(%96, %97, %98, %99, %100, %101, %104, %105, %106) <{twoState}> : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %161 = "comb.or"(%76, %77, %78, %81, %82, %83, %84, %85, %86, %87, %88, %89, %90, %91, %92, %93, %94, %95, %160) <{twoState}> : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %162 = "comb.xor"(%161, %0) : (i1, i1) -> i1
    %163 = "comb.and"(%162, %159) {sv.namehint = "ctrlSignals_2"} : (i1, i1) -> i1
    %164 = "comb.or"(%122, %123, %124) <{twoState}> : (i1, i1, i1) -> i1
    %165 = "comb.xor"(%134, %0) : (i1, i1) -> i1
    %166 = "comb.or"(%107, %108, %109, %110, %111, %112, %113, %114, %115, %116, %120, %121, %164, %165) : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %167 = "comb.mux"(%166, %74, %55) <{twoState}> {sv.namehint = "_ctrlSignals_T_263"} : (i1, i3, i3) -> i3
    %168 = "comb.mux"(%160, %56, %167) <{twoState}> {sv.namehint = "_ctrlSignals_T_272"} : (i1, i3, i3) -> i3
    %169 = "comb.or"(%93, %94, %95) <{twoState}> : (i1, i1, i1) -> i1
    %170 = "comb.mux"(%169, %57, %168) <{twoState}> {sv.namehint = "_ctrlSignals_T_275"} : (i1, i3, i3) -> i3
    %171 = "comb.mux"(%139, %56, %170) <{twoState}> {sv.namehint = "_ctrlSignals_T_280"} : (i1, i3, i3) -> i3
    %172 = "comb.mux"(%141, %58, %171) <{twoState}> {sv.namehint = "_ctrlSignals_T_286"} : (i1, i3, i3) -> i3
    %173 = "comb.mux"(%81, %56, %172) <{twoState}> {sv.namehint = "_ctrlSignals_T_287"} : (i1, i3, i3) -> i3
    %174 = "comb.mux"(%78, %59, %173) <{twoState}> {sv.namehint = "_ctrlSignals_T_288"} : (i1, i3, i3) -> i3
    %175 = "comb.mux"(%145, %60, %174) <{twoState}> {sv.namehint = "ctrlSignals_3"} : (i1, i3, i3) -> i3
    %176 = "comb.xor"(%164, %0) : (i1, i1) -> i1
    %177 = "comb.or"(%148, %176) : (i1, i1) -> i1
    %178 = "comb.mux"(%177, %73, %61) <{twoState}> {sv.namehint = "_ctrlSignals_T_301"} : (i1, i4, i4) -> i4
    %179 = "comb.mux"(%116, %62, %178) <{twoState}> {sv.namehint = "_ctrlSignals_T_302"} : (i1, i4, i4) -> i4
    %180 = "comb.mux"(%115, %63, %179) <{twoState}> {sv.namehint = "_ctrlSignals_T_303"} : (i1, i4, i4) -> i4
    %181 = "comb.mux"(%114, %64, %180) <{twoState}> {sv.namehint = "_ctrlSignals_T_304"} : (i1, i4, i4) -> i4
    %182 = "comb.mux"(%113, %65, %181) <{twoState}> {sv.namehint = "_ctrlSignals_T_305"} : (i1, i4, i4) -> i4
    %183 = "comb.mux"(%112, %66, %182) <{twoState}> {sv.namehint = "_ctrlSignals_T_306"} : (i1, i4, i4) -> i4
    %184 = "comb.mux"(%111, %67, %183) <{twoState}> {sv.namehint = "_ctrlSignals_T_307"} : (i1, i4, i4) -> i4
    %185 = "comb.mux"(%110, %68, %184) <{twoState}> {sv.namehint = "_ctrlSignals_T_308"} : (i1, i4, i4) -> i4
    %186 = "comb.mux"(%109, %69, %185) <{twoState}> {sv.namehint = "_ctrlSignals_T_309"} : (i1, i4, i4) -> i4
    %187 = "comb.mux"(%108, %70, %186) <{twoState}> {sv.namehint = "_ctrlSignals_T_310"} : (i1, i4, i4) -> i4
    %188 = "comb.mux"(%107, %71, %187) <{twoState}> {sv.namehint = "_ctrlSignals_T_311"} : (i1, i4, i4) -> i4
    %189 = "comb.mux"(%106, %64, %188) <{twoState}> {sv.namehint = "_ctrlSignals_T_312"} : (i1, i4, i4) -> i4
    %190 = "comb.mux"(%105, %65, %189) <{twoState}> {sv.namehint = "_ctrlSignals_T_313"} : (i1, i4, i4) -> i4
    %191 = "comb.mux"(%104, %69, %190) <{twoState}> {sv.namehint = "_ctrlSignals_T_314"} : (i1, i4, i4) -> i4
    %192 = "comb.mux"(%101, %62, %191) <{twoState}> {sv.namehint = "_ctrlSignals_T_315"} : (i1, i4, i4) -> i4
    %193 = "comb.mux"(%100, %63, %192) <{twoState}> {sv.namehint = "_ctrlSignals_T_316"} : (i1, i4, i4) -> i4
    %194 = "comb.mux"(%99, %66, %193) <{twoState}> {sv.namehint = "_ctrlSignals_T_317"} : (i1, i4, i4) -> i4
    %195 = "comb.mux"(%98, %67, %194) <{twoState}> {sv.namehint = "_ctrlSignals_T_318"} : (i1, i4, i4) -> i4
    %196 = "comb.mux"(%97, %68, %195) <{twoState}> {sv.namehint = "_ctrlSignals_T_319"} : (i1, i4, i4) -> i4
    %197 = "comb.or"(%77, %78, %81, %82, %83, %84, %85, %86, %87, %88, %89, %90, %91, %92, %93, %94, %95, %96) <{twoState}> : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %198 = "comb.mux"(%197, %71, %196) <{twoState}> {sv.namehint = "_ctrlSignals_T_337"} : (i1, i4, i4) -> i4
    %199 = "comb.mux"(%76, %72, %198) <{twoState}> {sv.namehint = "ctrlSignals_4"} : (i1, i4, i4) -> i4
    %200 = "comb.concat"(%87, %1) {sv.namehint = "_ctrlSignals_T_377"} : (i1, i2) -> i3
    %201 = "comb.mux"(%86, %56, %200) <{twoState}> {sv.namehint = "_ctrlSignals_T_378"} : (i1, i3, i3) -> i3
    %202 = "comb.mux"(%85, %58, %201) <{twoState}> {sv.namehint = "_ctrlSignals_T_379"} : (i1, i3, i3) -> i3
    %203 = "comb.mux"(%84, %57, %202) <{twoState}> {sv.namehint = "_ctrlSignals_T_380"} : (i1, i3, i3) -> i3
    %204 = "comb.mux"(%83, %55, %203) <{twoState}> {sv.namehint = "_ctrlSignals_T_381"} : (i1, i3, i3) -> i3
    %205 = "comb.mux"(%82, %60, %204) <{twoState}> {sv.namehint = "_ctrlSignals_T_382"} : (i1, i3, i3) -> i3
    %206 = "comb.or"(%76, %77, %143) <{twoState}> : (i1, i1, i1) -> i1
    %207 = "comb.mux"(%206, %74, %205) <{twoState}> {sv.namehint = "ctrlSignals_5"} : (i1, i3, i3) -> i3
    %208 = "comb.xor"(%132, %0) : (i1, i1) -> i1
    %209 = "comb.and"(%208, %130) {sv.namehint = "_ctrlSignals_T_389"} : (i1, i1) -> i1
    %210 = "comb.or"(%135, %209) {sv.namehint = "_ctrlSignals_T_396"} : (i1, i1) -> i1
    %211 = "comb.xor"(%137, %0) : (i1, i1) -> i1
    %212 = "comb.and"(%211, %210) {sv.namehint = "_ctrlSignals_T_419"} : (i1, i1) -> i1
    %213 = "comb.or"(%139, %212) {sv.namehint = "_ctrlSignals_T_424"} : (i1, i1) -> i1
    %214 = "comb.and"(%153, %213) {sv.namehint = "_ctrlSignals_T_430"} : (i1, i1) -> i1
    %215 = "comb.or"(%143, %214) {sv.namehint = "_ctrlSignals_T_432"} : (i1, i1) -> i1
    %216 = "comb.xor"(%145, %0) : (i1, i1) -> i1
    %217 = "comb.and"(%216, %215) {sv.namehint = "ctrlSignals_6"} : (i1, i1) -> i1
    %218 = "comb.concat"(%2, %95) {sv.namehint = "_ctrlSignals_T_465"} : (i1, i1) -> i2
    %219 = "comb.mux"(%94, %53, %218) <{twoState}> {sv.namehint = "_ctrlSignals_T_466"} : (i1, i2, i2) -> i2
    %220 = "comb.mux"(%93, %52, %219) <{twoState}> {sv.namehint = "_ctrlSignals_T_467"} : (i1, i2, i2) -> i2
    %221 = "comb.or"(%76, %77, %78, %81, %82, %83, %84, %85, %86, %87, %139) <{twoState}> : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %222 = "comb.mux"(%221, %1, %220) <{twoState}> {sv.namehint = "ctrlSignals_7"} : (i1, i2, i2) -> i2
    %223 = "comb.concat"(%92, %1) {sv.namehint = "_ctrlSignals_T_516"} : (i1, i2) -> i3
    %224 = "comb.mux"(%91, %58, %223) <{twoState}> {sv.namehint = "_ctrlSignals_T_517"} : (i1, i3, i3) -> i3
    %225 = "comb.mux"(%90, %56, %224) <{twoState}> {sv.namehint = "_ctrlSignals_T_518"} : (i1, i3, i3) -> i3
    %226 = "comb.mux"(%89, %57, %225) <{twoState}> {sv.namehint = "_ctrlSignals_T_519"} : (i1, i3, i3) -> i3
    %227 = "comb.mux"(%88, %60, %226) <{twoState}> {sv.namehint = "_ctrlSignals_T_520"} : (i1, i3, i3) -> i3
    %228 = "comb.or"(%76, %77, %78, %81, %141) <{twoState}> : (i1, i1, i1, i1, i1) -> i1
    %229 = "comb.mux"(%228, %74, %227) <{twoState}> {sv.namehint = "ctrlSignals_8"} : (i1, i3, i3) -> i3
    %230 = "comb.or"(%128, %129, %130) <{twoState}> : (i1, i1, i1) -> i1
    %231 = "comb.or"(%122, %123, %124, %125, %126, %127, %230) <{twoState}> : (i1, i1, i1, i1, i1, i1, i1) -> i1
    %232 = "comb.replicate"(%231) {sv.namehint = "_ctrlSignals_T_539"} : (i1) -> i2
    %233 = "comb.or"(%93, %94, %95, %96, %97, %98, %99, %100, %101, %104, %105, %106, %107, %108, %109, %110, %111, %112, %113, %114, %115, %116, %148) <{twoState}> : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %234 = "comb.mux"(%233, %1, %232) <{twoState}> {sv.namehint = "_ctrlSignals_T_563"} : (i1, i2, i2) -> i2
    %235 = "comb.mux"(%139, %54, %234) <{twoState}> {sv.namehint = "_ctrlSignals_T_568"} : (i1, i2, i2) -> i2
    %236 = "comb.mux"(%141, %1, %235) <{twoState}> {sv.namehint = "_ctrlSignals_T_574"} : (i1, i2, i2) -> i2
    %237 = "comb.mux"(%143, %53, %236) <{twoState}> {sv.namehint = "_ctrlSignals_T_576"} : (i1, i2, i2) -> i2
    %238 = "comb.mux"(%145, %1, %237) <{twoState}> {sv.namehint = "ctrlSignals_9"} : (i1, i2, i2) -> i2
    %239 = "comb.or"(%122, %123, %124, %125, %126, %127) {sv.namehint = "_ctrlSignals_T_587"} : (i1, i1, i1, i1, i1, i1) -> i1
    %240 = "comb.and"(%149, %239) {sv.namehint = "_ctrlSignals_T_589"} : (i1, i1) -> i1
    %241 = "comb.or"(%151, %240) {sv.namehint = "_ctrlSignals_T_608"} : (i1, i1) -> i1
    %242 = "comb.xor"(%169, %0) : (i1, i1) -> i1
    %243 = "comb.and"(%242, %241) {sv.namehint = "_ctrlSignals_T_611"} : (i1, i1) -> i1
    %244 = "comb.or"(%139, %243) {sv.namehint = "_ctrlSignals_T_616"} : (i1, i1) -> i1
    %245 = "comb.and"(%153, %244) {sv.namehint = "_ctrlSignals_T_622"} : (i1, i1) -> i1
    %246 = "comb.or"(%206, %245) {sv.namehint = "ctrlSignals_10"} : (i1, i1) -> i1
    %247 = "comb.concat"(%230, %1) {sv.namehint = "_ctrlSignals_T_629"} : (i1, i2) -> i3
    %248 = "comb.mux"(%127, %60, %247) <{twoState}> {sv.namehint = "_ctrlSignals_T_630"} : (i1, i3, i3) -> i3
    %249 = "comb.mux"(%126, %57, %248) <{twoState}> {sv.namehint = "_ctrlSignals_T_631"} : (i1, i3, i3) -> i3
    %250 = "comb.mux"(%125, %56, %249) <{twoState}> {sv.namehint = "_ctrlSignals_T_632"} : (i1, i3, i3) -> i3
    %251 = "comb.mux"(%124, %60, %250) <{twoState}> {sv.namehint = "_ctrlSignals_T_633"} : (i1, i3, i3) -> i3
    %252 = "comb.mux"(%123, %57, %251) <{twoState}> {sv.namehint = "_ctrlSignals_T_634"} : (i1, i3, i3) -> i3
    %253 = "comb.mux"(%122, %56, %252) <{twoState}> {sv.namehint = "_ctrlSignals_T_635"} : (i1, i3, i3) -> i3
    %254 = "comb.or"(%76, %77, %78, %81, %82, %83, %84, %85, %86, %87, %88, %89, %90, %91, %92, %233) <{twoState}> : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %255 = "comb.mux"(%254, %74, %253) <{twoState}> {sv.namehint = "ctrlSignals_11"} : (i1, i3, i3) -> i3
    %256 = "comb.icmp"(%arg0, %47) <{predicate = 1 : i64, twoState}> {sv.namehint = "_ctrlSignals_T_674"} : (i32, i32) -> i1
    %257 = "comb.or"(%76, %77, %78, %81, %82, %83, %84, %85, %86, %87, %88, %89, %90, %91, %92, %93, %94, %95, %96, %97, %98, %99, %100, %101, %104, %105, %106, %107, %108, %109, %110, %111, %112, %113, %114, %115, %116, %120, %121, %231) <{twoState}> : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %258 = "comb.xor"(%257, %0) : (i1, i1) -> i1
    %259 = "comb.and"(%258, %256) {sv.namehint = "io_illegal"} : (i1, i1) -> i1
    "hw.output"(%146, %217, %158, %163, %175, %199, %207, %222, %229, %238, %246, %255, %259) : (i2, i1, i1, i1, i3, i4, i3, i2, i3, i2, i1, i3, i1) -> ()
  }) {module_type = !hw.modty<input io_inst : i32, output io_pc_sel : i2, output io_inst_kill : i1, output io_A_sel : i1, output io_B_sel : i1, output io_imm_sel : i3, output io_alu_op : i4, output io_br_type : i3, output io_st_type : i2, output io_ld_type : i3, output io_wb_sel : i2, output io_wb_en : i1, output io_csr_cmd : i3, output io_illegal : i1>, parameters = [], result_locs = [#loc20, #loc21, #loc22, #loc23, #loc24, #loc25, #loc26, #loc27, #loc28, #loc29, #loc30, #loc31, #loc32], sym_name = "Control", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: !seq.clock, %arg1: i1, %arg2: i1, %arg3: i32, %arg4: i1, %arg5: i32, %arg6: i1, %arg7: i32):
    %0:9 = "hw.instance"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %1#0, %1#1, %1#2, %1#3, %1#4, %1#5, %1#6, %1#7, %1#8, %1#9, %1#10, %1#11, %1#12) {argNames = ["clock", "reset", "io_host_fromhost_valid", "io_host_fromhost_bits", "io_icache_resp_valid", "io_icache_resp_bits_data", "io_dcache_resp_valid", "io_dcache_resp_bits_data", "io_ctrl_pc_sel", "io_ctrl_inst_kill", "io_ctrl_A_sel", "io_ctrl_B_sel", "io_ctrl_imm_sel", "io_ctrl_alu_op", "io_ctrl_br_type", "io_ctrl_st_type", "io_ctrl_ld_type", "io_ctrl_wb_sel", "io_ctrl_wb_en", "io_ctrl_csr_cmd", "io_ctrl_illegal"], instanceName = "dpath", moduleName = @Datapath, parameters = [], resultNames = ["io_host_tohost", "io_icache_req_valid", "io_icache_req_bits_addr", "io_dcache_abort", "io_dcache_req_valid", "io_dcache_req_bits_addr", "io_dcache_req_bits_data", "io_dcache_req_bits_mask", "io_ctrl_inst"], sv.namehint = "io_host_tohost"} : (!seq.clock, i1, i1, i32, i1, i32, i1, i32, i2, i1, i1, i1, i3, i4, i3, i2, i3, i2, i1, i3, i1) -> (i32, i1, i32, i1, i1, i32, i32, i4, i32)
    %1:13 = "hw.instance"(%0#8) {argNames = ["io_inst"], instanceName = "ctrl", moduleName = @Control, parameters = [], resultNames = ["io_pc_sel", "io_inst_kill", "io_A_sel", "io_B_sel", "io_imm_sel", "io_alu_op", "io_br_type", "io_st_type", "io_ld_type", "io_wb_sel", "io_wb_en", "io_csr_cmd", "io_illegal"]} : (i32) -> (i2, i1, i1, i1, i3, i4, i3, i2, i3, i2, i1, i3, i1)
    "hw.output"(%0#0, %0#1, %0#2, %0#3, %0#4, %0#5, %0#6, %0#7) : (i32, i1, i32, i1, i1, i32, i32, i4) -> ()
  }) {module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_host_fromhost_valid : i1, input io_host_fromhost_bits : i32, output io_host_tohost : i32, output io_icache_req_valid : i1, output io_icache_req_bits_addr : i32, input io_icache_resp_valid : i1, input io_icache_resp_bits_data : i32, output io_dcache_abort : i1, output io_dcache_req_valid : i1, output io_dcache_req_bits_addr : i32, output io_dcache_req_bits_data : i32, output io_dcache_req_bits_mask : i4, input io_dcache_resp_valid : i1, input io_dcache_resp_bits_data : i32>, parameters = [], result_locs = [#loc33, #loc34, #loc35, #loc36, #loc37, #loc38, #loc39, #loc40], sym_name = "Core", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: !seq.clock, %arg1: i1, %arg2: i1, %arg3: i1, %arg4: i32, %arg5: i32, %arg6: i4, %arg7: i1, %arg8: i1, %arg9: i1, %arg10: i1, %arg11: i1, %arg12: i64):
    %0 = "hw.constant"() {value = false} : () -> i1
    %1 = "hw.constant"() {value = true} : () -> i1
    %2 = "hw.constant"() {value = -1 : i16} : () -> i16
    %3 = "hw.constant"() {value = 0 : i4} : () -> i4
    %4 = "hw.constant"() {value = 1 : i256} : () -> i256
    %5 = "hw.constant"() {value = 2 : i3} : () -> i3
    %6 = "hw.constant"() {value = 1 : i3} : () -> i3
    %7 = "hw.constant"() {value = -1 : i256} : () -> i256
    %8 = "hw.constant"() {value = 0 : i15} : () -> i15
    %9 = "hw.constant"() {value = 0 : i248} : () -> i248
    %10 = "hw.constant"() {value = 0 : i256} : () -> i256
    %11 = "hw.constant"() {value = 0 : i2} : () -> i2
    %12 = "hw.constant"() {value = 3 : i3} : () -> i3
    %13 = "hw.constant"() {value = 1 : i2} : () -> i2
    %14 = "hw.constant"() {value = 0 : i3} : () -> i3
    %15 = "hw.constant"() {value = -2 : i2} : () -> i2
    %16 = "hw.constant"() {value = -4 : i3} : () -> i3
    %17 = "hw.constant"() {value = -3 : i3} : () -> i3
    %18 = "hw.constant"() {value = -2 : i3} : () -> i3
    %19 = "seq.firreg"(%190, %arg0, %arg1, %14) <{name = "state"}> {firrtl.random_init_start = 0 : ui64} : (i3, !seq.clock, i1, i3) -> i3
    %20 = "seq.firreg"(%115, %arg0, %arg1, %10) <{name = "v"}> {firrtl.random_init_start = 3 : ui64} : (i256, !seq.clock, i1, i256) -> i256
    %21 = "seq.firreg"(%121, %arg0, %arg1, %10) <{name = "d"}> {firrtl.random_init_start = 259 : ui64} : (i256, !seq.clock, i1, i256) -> i256
    %22 = "seq.firmem"() <{name = "metaMem_tag", prefix = "", readLatency = 1 : i32, ruw = 0 : i32, writeLatency = 1 : i32, wuw = 1 : i32}> : () -> !seq.firmem<256 x 20>
    %23 = "seq.firmem.read_write_port"(%22, %24, %arg0, %25, %73, %67) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 1, 0>}> {sv.namehint = "metaMem_rmeta_data_tag"} : (!seq.firmem<256 x 20>, i8, !seq.clock, i1, i20, i1) -> i20
    %24 = "comb.mux"(%122, %74, %72) <{twoState}> : (i1, i8, i8) -> i8
    %25 = "comb.or"(%70, %122) <{twoState}> : (i1, i1) -> i1
    %26 = "seq.firmem"() <{name = "dataMem_0", prefix = "", readLatency = 1 : i32, ruw = 0 : i32, writeLatency = 1 : i32, wuw = 1 : i32}> : () -> !seq.firmem<256 x 32, mask 4>
    %27 = "seq.firmem.read_write_port"(%26, %28, %arg0, %29, %30, %67, %31) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 1, 1>}> : (!seq.firmem<256 x 32, mask 4>, i8, !seq.clock, i1, i32, i1, i4) -> i32
    %28 = "comb.mux"(%67, %74, %72) <{twoState}> : (i1, i8, i8) -> i8
    %29 = "comb.or"(%70, %67) <{twoState}> : (i1, i1) -> i1
    %30 = "comb.extract"(%111) <{lowBit = 0 : i32}> : (i128) -> i32
    %31 = "comb.extract"(%107) <{lowBit = 0 : i32}> : (i16) -> i4
    %32 = "seq.firmem"() <{name = "dataMem_1", prefix = "", readLatency = 1 : i32, ruw = 0 : i32, writeLatency = 1 : i32, wuw = 1 : i32}> : () -> !seq.firmem<256 x 32, mask 4>
    %33 = "seq.firmem.read_write_port"(%32, %28, %arg0, %29, %34, %67, %35) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 1, 1>}> : (!seq.firmem<256 x 32, mask 4>, i8, !seq.clock, i1, i32, i1, i4) -> i32
    %34 = "comb.extract"(%111) <{lowBit = 32 : i32}> : (i128) -> i32
    %35 = "comb.extract"(%107) <{lowBit = 4 : i32}> : (i16) -> i4
    %36 = "seq.firmem"() <{name = "dataMem_2", prefix = "", readLatency = 1 : i32, ruw = 0 : i32, writeLatency = 1 : i32, wuw = 1 : i32}> : () -> !seq.firmem<256 x 32, mask 4>
    %37 = "seq.firmem.read_write_port"(%36, %28, %arg0, %29, %38, %67, %39) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 1, 1>}> : (!seq.firmem<256 x 32, mask 4>, i8, !seq.clock, i1, i32, i1, i4) -> i32
    %38 = "comb.extract"(%111) <{lowBit = 64 : i32}> : (i128) -> i32
    %39 = "comb.extract"(%107) <{lowBit = 8 : i32}> : (i16) -> i4
    %40 = "seq.firmem"() <{name = "dataMem_3", prefix = "", readLatency = 1 : i32, ruw = 0 : i32, writeLatency = 1 : i32, wuw = 1 : i32}> : () -> !seq.firmem<256 x 32, mask 4>
    %41 = "seq.firmem.read_write_port"(%40, %28, %arg0, %29, %42, %67, %43) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 1, 1>}> : (!seq.firmem<256 x 32, mask 4>, i8, !seq.clock, i1, i32, i1, i4) -> i32
    %42 = "comb.extract"(%111) <{lowBit = 96 : i32}> : (i128) -> i32
    %43 = "comb.extract"(%107) <{lowBit = 12 : i32}> : (i16) -> i4
    %44 = "seq.firreg"(%100, %arg0) <{name = "addr_reg"}> {firrtl.random_init_start = 515 : ui64} : (i32, !seq.clock) -> i32
    %45 = "seq.firreg"(%101, %arg0) <{name = "cpu_data"}> {firrtl.random_init_start = 547 : ui64} : (i32, !seq.clock) -> i32
    %46 = "seq.firreg"(%102, %arg0) <{name = "cpu_mask"}> {firrtl.random_init_start = 579 : ui64} : (i4, !seq.clock) -> i4
    %47 = "comb.and"(%61, %arg11) <{twoState}> : (i1, i1) -> i1
    %48 = "seq.firreg"(%50, %arg0, %arg1, %0) <{name = "wrap_wrap"}> {firrtl.random_init_start = 583 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %49 = "comb.add"(%48, %1) {sv.namehint = "_wrap_value_T"} : (i1, i1) -> i1
    %50 = "comb.mux"(%47, %49, %48) <{twoState}> : (i1, i1, i1) -> i1
    %51 = "comb.and"(%47, %48) {sv.namehint = "read_wrap_out"} : (i1, i1) -> i1
    %52 = "comb.and"(%arg8, %169) <{twoState}> : (i1, i1) -> i1
    %53 = "seq.firreg"(%55, %arg0, %arg1, %0) <{name = "write_count"}> {firrtl.random_init_start = 584 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %54 = "comb.add"(%53, %1) {sv.namehint = "_wrap_value_T_2"} : (i1, i1) -> i1
    %55 = "comb.mux"(%52, %54, %53) <{twoState}> : (i1, i1, i1) -> i1
    %56 = "comb.and"(%52, %53) {sv.namehint = "write_wrap_out"} : (i1, i1) -> i1
    %57 = "comb.icmp"(%19, %14) <{predicate = 1 : i64, twoState}> : (i3, i3) -> i1
    %58 = "comb.xor"(%57, %1) <{twoState}> {sv.namehint = "is_idle"} : (i1, i1) -> i1
    %59 = "comb.icmp"(%19, %6) <{predicate = 0 : i64, twoState}> {sv.namehint = "is_read"} : (i3, i3) -> i1
    %60 = "comb.icmp"(%19, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "is_write"} : (i3, i3) -> i1
    %61 = "comb.icmp"(%19, %18) <{predicate = 0 : i64, twoState}> {sv.namehint = "io_nasti_r_ready"} : (i3, i3) -> i1
    %62 = "comb.and"(%61, %51) <{twoState}> {sv.namehint = "is_alloc"} : (i1, i1) -> i1
    %63 = "seq.firreg"(%62, %arg0) <{name = "is_alloc_reg"}> {firrtl.random_init_start = 585 : ui64} : (i1, !seq.clock) -> i1
    %64 = "comb.or"(%88, %63) <{twoState}> {sv.namehint = "_wen_T"} : (i1, i1) -> i1
    %65 = "comb.xor"(%arg2, %1) <{twoState}> {sv.namehint = "_wen_T_2"} : (i1, i1) -> i1
    %66 = "comb.and"(%60, %64, %65) <{twoState}> {sv.namehint = "_wen_T_3"} : (i1, i1, i1) -> i1
    %67 = "comb.or"(%66, %62) <{twoState}> {sv.namehint = "wen"} : (i1, i1) -> i1
    %68 = "comb.xor"(%67, %1) <{twoState}> {sv.namehint = "_ren_T"} : (i1, i1) -> i1
    %69 = "comb.or"(%58, %59) <{twoState}> {sv.namehint = "_ren_T_1"} : (i1, i1) -> i1
    %70 = "comb.and"(%68, %69, %arg3) <{twoState}> {sv.namehint = "ren"} : (i1, i1, i1) -> i1
    %71 = "seq.firreg"(%70, %arg0) <{name = "ren_reg"}> {firrtl.random_init_start = 586 : ui64} : (i1, !seq.clock) -> i1
    %72 = "comb.extract"(%arg4) <{lowBit = 4 : i32}> {sv.namehint = "idx"} : (i32) -> i8
    %73 = "comb.extract"(%44) <{lowBit = 12 : i32}> {sv.namehint = "tag_reg"} : (i32) -> i20
    %74 = "comb.extract"(%44) <{lowBit = 4 : i32}> {sv.namehint = "writeAddr"} : (i32) -> i8
    %75 = "comb.extract"(%44) <{lowBit = 2 : i32}> {sv.namehint = "off_reg"} : (i32) -> i2
    %76 = "comb.concat"(%41, %37, %33, %27) {sv.namehint = "rdata"} : (i32, i32, i32, i32) -> i128
    %77 = "seq.firreg"(%78, %arg0) <{name = "rdata_buf"}> {firrtl.random_init_start = 587 : ui64} : (i128, !seq.clock) -> i128
    %78 = "comb.mux"(%71, %76, %77) <{twoState}> : (i1, i128, i128) -> i128
    %79 = "seq.firreg"(%127, %arg0) <{name = "refill_buf_0"}> {firrtl.random_init_start = 715 : ui64} : (i64, !seq.clock) -> i64
    %80 = "seq.firreg"(%129, %arg0) <{name = "refill_buf_1"}> {firrtl.random_init_start = 779 : ui64} : (i64, !seq.clock) -> i64
    %81 = "comb.concat"(%80, %79) {sv.namehint = "_read_T"} : (i64, i64) -> i128
    %82 = "comb.mux"(%71, %76, %77) <{twoState}> {sv.namehint = "_read_T_1"} : (i1, i128, i128) -> i128
    %83 = "comb.mux"(%63, %81, %82) <{twoState}> {sv.namehint = "read"} : (i1, i128, i128) -> i128
    %84 = "comb.concat"(%9, %74) : (i248, i8) -> i256
    %85 = "comb.shru"(%20, %84) <{twoState}> {sv.namehint = "_is_dirty_T"} : (i256, i256) -> i256
    %86 = "comb.extract"(%85) <{lowBit = 0 : i32}> {sv.namehint = "_hit_T_1"} : (i256) -> i1
    %87 = "comb.icmp"(%23, %73) <{predicate = 0 : i64, twoState}> {sv.namehint = "_hit_T_2"} : (i20, i20) -> i1
    %88 = "comb.and"(%86, %87) <{twoState}> {sv.namehint = "hit"} : (i1, i1) -> i1
    %89 = "comb.extract"(%83) <{lowBit = 0 : i32}> {sv.namehint = "_io_cpu_resp_bits_data_T"} : (i128) -> i32
    %90 = "comb.extract"(%83) <{lowBit = 32 : i32}> {sv.namehint = "_io_cpu_resp_bits_data_T_1"} : (i128) -> i32
    %91 = "comb.extract"(%83) <{lowBit = 64 : i32}> {sv.namehint = "_io_cpu_resp_bits_data_T_2"} : (i128) -> i32
    %92 = "comb.extract"(%83) <{lowBit = 96 : i32}> {sv.namehint = "_io_cpu_resp_bits_data_T_3"} : (i128) -> i32
    %93 = "hw.array_create"(%92, %91, %90, %89) : (i32, i32, i32, i32) -> !hw.array<4xi32>
    %94 = "hw.array_get"(%93, %75) {sv.namehint = "io_cpu_resp_bits_data"} : (!hw.array<4xi32>, i2) -> i32
    %95 = "comb.and"(%59, %88) <{twoState}> {sv.namehint = "_io_cpu_resp_valid_T"} : (i1, i1) -> i1
    %96 = "comb.icmp"(%46, %3) <{predicate = 1 : i64, twoState}> {sv.namehint = "_state_T_4"} : (i4, i4) -> i1
    %97 = "comb.xor"(%96, %1) <{twoState}> {sv.namehint = "_io_cpu_resp_valid_T_3"} : (i1, i1) -> i1
    %98 = "comb.and"(%63, %97) <{twoState}> {sv.namehint = "_io_cpu_resp_valid_T_4"} : (i1, i1) -> i1
    %99 = "comb.or"(%58, %95, %98) <{twoState}> {sv.namehint = "io_cpu_resp_valid"} : (i1, i1, i1) -> i1
    %100 = "comb.mux"(%99, %arg4, %44) <{twoState}> : (i1, i32, i32) -> i32
    %101 = "comb.mux"(%99, %arg5, %45) <{twoState}> : (i1, i32, i32) -> i32
    %102 = "comb.mux"(%99, %arg6, %46) <{twoState}> : (i1, i4, i4) -> i4
    %103 = "comb.concat"(%8, %46) : (i15, i4) -> i19
    %104 = "comb.concat"(%8, %75, %11) : (i15, i2, i2) -> i19
    %105 = "comb.shl"(%103, %104) <{twoState}> {sv.namehint = "_wmask_T_2"} : (i19, i19) -> i19
    %106 = "comb.extract"(%105) <{lowBit = 0 : i32}> : (i19) -> i16
    %107 = "comb.mux"(%62, %2, %106) {sv.namehint = "wmask"} : (i1, i16, i16) -> i16
    %108 = "comb.replicate"(%45) {sv.namehint = "_wdata_T_1"} : (i32) -> i64
    %109 = "comb.replicate"(%108) {sv.namehint = "_wdata_T_2"} : (i64) -> i128
    %110 = "comb.concat"(%arg12, %79) {sv.namehint = "_wdata_T_3"} : (i64, i64) -> i128
    %111 = "comb.mux"(%62, %110, %109) <{twoState}> {sv.namehint = "wdata"} : (i1, i128, i128) -> i128
    %112 = "comb.shl"(%4, %84) <{twoState}> {sv.namehint = "_d_T_1"} : (i256, i256) -> i256
    %113 = "comb.replicate"(%67) : (i1) -> i256
    %114 = "comb.and"(%113, %112) : (i256, i256) -> i256
    %115 = "comb.or"(%114, %20) : (i256, i256) -> i256
    %116 = "comb.or"(%21, %112) <{twoState}> {sv.namehint = "_d_T_2"} : (i256, i256) -> i256
    %117 = "comb.xor"(%21, %7) <{twoState}> {sv.namehint = "_d_T_3"} : (i256, i256) -> i256
    %118 = "comb.or"(%117, %112) <{twoState}> {sv.namehint = "_d_T_4"} : (i256, i256) -> i256
    %119 = "comb.xor"(%118, %7) <{twoState}> {sv.namehint = "_d_T_5"} : (i256, i256) -> i256
    %120 = "comb.mux"(%62, %119, %116) <{twoState}> {sv.namehint = "_d_T_6"} : (i1, i256, i256) -> i256
    %121 = "comb.mux"(%67, %120, %21) <{twoState}> : (i1, i256, i256) -> i256
    %122 = "comb.and"(%67, %62) {sv.namehint = "writeEnable"} : (i1, i1) -> i1
    %123 = "comb.extract"(%44) <{lowBit = 4 : i32}> {sv.namehint = "_io_nasti_ar_bits_T"} : (i32) -> i28
    %124 = "comb.concat"(%123, %3) {sv.namehint = "io_nasti_ar_bits_aw_addr"} : (i28, i4) -> i32
    %125 = "comb.xor"(%48, %1) <{twoState}> : (i1, i1) -> i1
    %126 = "comb.and"(%47, %125) <{twoState}> : (i1, i1) -> i1
    %127 = "comb.mux"(%126, %arg12, %79) <{twoState}> : (i1, i64, i64) -> i64
    %128 = "comb.and"(%47, %48) <{twoState}> : (i1, i1) -> i1
    %129 = "comb.mux"(%128, %arg12, %80) <{twoState}> : (i1, i64, i64) -> i64
    %130 = "comb.concat"(%23, %74, %3) {sv.namehint = "io_nasti_aw_bits_aw_addr"} : (i20, i8, i4) -> i32
    %131 = "comb.extract"(%83) <{lowBit = 0 : i32}> {sv.namehint = "_io_nasti_w_bits_T"} : (i128) -> i64
    %132 = "comb.extract"(%83) <{lowBit = 64 : i32}> {sv.namehint = "_io_nasti_w_bits_T_1"} : (i128) -> i64
    %133 = "comb.mux"(%53, %132, %131) <{twoState}> {sv.namehint = "io_nasti_w_bits_w_data"} : (i1, i64, i64) -> i64
    %134 = "comb.extract"(%85) <{lowBit = 0 : i32}> {sv.namehint = "_is_dirty_T_1"} : (i256) -> i1
    %135 = "comb.shru"(%21, %84) <{twoState}> {sv.namehint = "_is_dirty_T_2"} : (i256, i256) -> i256
    %136 = "comb.extract"(%135) <{lowBit = 0 : i32}> {sv.namehint = "_is_dirty_T_3"} : (i256) -> i1
    %137 = "comb.and"(%134, %136) <{twoState}> {sv.namehint = "is_dirty"} : (i1, i1) -> i1
    %138 = "comb.xor"(%57, %1) <{twoState}> : (i1, i1) -> i1
    %139 = "comb.icmp"(%arg6, %3) <{predicate = 1 : i64, twoState}> {sv.namehint = "_state_T"} : (i4, i4) -> i1
    %140 = "comb.mux"(%139, %15, %13) <{twoState}> {sv.namehint = "_state_T_1"} : (i1, i2, i2) -> i2
    %141 = "comb.concat"(%0, %140) : (i1, i2) -> i3
    %142 = "comb.mux"(%arg3, %141, %19) <{twoState}> : (i1, i3, i3) -> i3
    %143 = "comb.icmp"(%19, %6) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %144 = "comb.icmp"(%arg6, %3) <{predicate = 1 : i64, twoState}> {sv.namehint = "_state_T_2"} : (i4, i4) -> i1
    %145 = "comb.mux"(%144, %15, %13) <{twoState}> {sv.namehint = "_state_T_3"} : (i1, i2, i2) -> i2
    %146 = "comb.concat"(%0, %145) : (i1, i2) -> i3
    %147 = "comb.mux"(%arg3, %146, %14) <{twoState}> : (i1, i3, i3) -> i3
    %148 = "comb.xor"(%88, %1) : (i1, i1) -> i1
    %149 = "comb.and"(%148, %137) : (i1, i1) -> i1
    %150 = "comb.xor"(%137, %1) <{twoState}> {sv.namehint = "_io_nasti_ar_valid_T"} : (i1, i1) -> i1
    %151 = "comb.and"(%148, %150) : (i1, i1) -> i1
    %152 = "comb.and"(%arg7, %162) <{twoState}> : (i1, i1) -> i1
    %153 = "comb.and"(%arg10, %183) <{twoState}> : (i1, i1) -> i1
    %154 = "comb.mux"(%153, %18, %19) <{twoState}> : (i1, i3, i3) -> i3
    %155 = "comb.mux"(%152, %12, %154) <{twoState}> : (i1, i3, i3) -> i3
    %156 = "comb.mux"(%88, %147, %155) <{twoState}> : (i1, i3, i3) -> i3
    %157 = "comb.icmp"(%19, %5) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %158 = "comb.or"(%64, %arg2) <{twoState}> : (i1, i1) -> i1
    %159 = "comb.xor"(%158, %1) : (i1, i1) -> i1
    %160 = "comb.and"(%157, %159, %137) : (i1, i1, i1) -> i1
    %161 = "comb.mux"(%143, %149, %160) <{twoState}> : (i1, i1, i1) -> i1
    %162 = "comb.and"(%57, %161) {sv.namehint = "io_nasti_aw_valid"} : (i1, i1) -> i1
    %163 = "comb.xor"(%137, %1) <{twoState}> {sv.namehint = "_io_nasti_ar_valid_T_1"} : (i1, i1) -> i1
    %164 = "comb.and"(%159, %163) : (i1, i1) -> i1
    %165 = "comb.mux"(%158, %14, %155) <{twoState}> : (i1, i3, i3) -> i3
    %166 = "comb.icmp"(%19, %12) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %167 = "comb.or"(%138, %143, %157) <{twoState}> : (i1, i1, i1) -> i1
    %168 = "comb.xor"(%167, %1) : (i1, i1) -> i1
    %169 = "comb.and"(%168, %166) {sv.namehint = "io_nasti_w_valid"} : (i1, i1) -> i1
    %170 = "comb.mux"(%56, %16, %19) <{twoState}> : (i1, i3, i3) -> i3
    %171 = "comb.icmp"(%19, %16) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %172 = "comb.or"(%167, %166) <{twoState}> : (i1, i1) -> i1
    %173 = "comb.xor"(%172, %1) : (i1, i1) -> i1
    %174 = "comb.and"(%173, %171) {sv.namehint = "io_nasti_b_ready"} : (i1, i1) -> i1
    %175 = "comb.and"(%174, %arg9) <{twoState}> : (i1, i1) -> i1
    %176 = "comb.mux"(%175, %17, %19) <{twoState}> : (i1, i3, i3) -> i3
    %177 = "comb.icmp"(%19, %17) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %178 = "comb.or"(%166, %171) <{twoState}> : (i1, i1) -> i1
    %179 = "comb.xor"(%178, %1) : (i1, i1) -> i1
    %180 = "comb.and"(%179, %177) : (i1, i1) -> i1
    %181 = "comb.mux"(%157, %164, %180) <{twoState}> : (i1, i1, i1) -> i1
    %182 = "comb.mux"(%143, %151, %181) <{twoState}> : (i1, i1, i1) -> i1
    %183 = "comb.and"(%57, %182) {sv.namehint = "io_nasti_ar_valid"} : (i1, i1) -> i1
    %184 = "comb.icmp"(%19, %18) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %185 = "comb.concat"(%0, %96, %0) : (i1, i1, i1) -> i3
    %186 = "comb.and"(%184, %51) <{twoState}> : (i1, i1) -> i1
    %187 = "comb.mux"(%186, %185, %19) <{twoState}> : (i1, i3, i3) -> i3
    %188 = "hw.array_create"(%187, %187, %154, %176, %170, %165, %156, %187) : (i3, i3, i3, i3, i3, i3, i3, i3) -> !hw.array<8xi3>
    %189 = "hw.array_get"(%188, %19) : (!hw.array<8xi3>, i3) -> i3
    %190 = "comb.mux"(%57, %189, %142) <{twoState}> : (i1, i3, i3) -> i3
    "hw.output"(%99, %94, %162, %130, %169, %133, %56, %174, %183, %124, %61) : (i1, i32, i1, i32, i1, i64, i1, i1, i1, i32, i1) -> ()
  }) {module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_cpu_abort : i1, input io_cpu_req_valid : i1, input io_cpu_req_bits_addr : i32, input io_cpu_req_bits_data : i32, input io_cpu_req_bits_mask : i4, output io_cpu_resp_valid : i1, output io_cpu_resp_bits_data : i32, input io_nasti_aw_ready : i1, output io_nasti_aw_valid : i1, output io_nasti_aw_bits_addr : i32, input io_nasti_w_ready : i1, output io_nasti_w_valid : i1, output io_nasti_w_bits_data : i64, output io_nasti_w_bits_last : i1, output io_nasti_b_ready : i1, input io_nasti_b_valid : i1, input io_nasti_ar_ready : i1, output io_nasti_ar_valid : i1, output io_nasti_ar_bits_addr : i32, output io_nasti_r_ready : i1, input io_nasti_r_valid : i1, input io_nasti_r_bits_data : i64>, parameters = [], result_locs = [#loc41, #loc42, #loc43, #loc44, #loc45, #loc46, #loc47, #loc48, #loc49, #loc50, #loc51], sym_name = "Cache", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: !seq.clock, %arg1: i1, %arg2: i1, %arg3: i32, %arg4: i1, %arg5: i1, %arg6: i32, %arg7: i1, %arg8: i64, %arg9: i1, %arg10: i1, %arg11: i1, %arg12: i32, %arg13: i1, %arg14: i1, %arg15: i1, %arg16: i1, %arg17: i1, %arg18: i1, %arg19: i64, %arg20: i1):
    %0 = "hw.constant"() {value = 0 : i3} : () -> i3
    %1 = "hw.constant"() {value = 3 : i3} : () -> i3
    %2 = "hw.constant"() {value = 2 : i3} : () -> i3
    %3 = "hw.constant"() {value = 1 : i3} : () -> i3
    %4 = "hw.constant"() {value = true} : () -> i1
    %5 = "hw.constant"() {value = -4 : i3} : () -> i3
    %6 = "seq.firreg"(%50, %arg0, %arg1, %0) <{name = "state"}> {firrtl.random_init_start = 0 : ui64} : (i3, !seq.clock, i1, i3) -> i3
    %7 = "comb.icmp"(%6, %0) <{predicate = 1 : i64, twoState}> : (i3, i3) -> i1
    %8 = "comb.xor"(%7, %4) <{twoState}> {sv.namehint = "_io_dcache_ar_ready_T_2"} : (i1, i1) -> i1
    %9 = "comb.and"(%arg5, %8) <{twoState}> {sv.namehint = "io_nasti_aw_valid"} : (i1, i1) -> i1
    %10 = "comb.and"(%arg14, %8) <{twoState}> {sv.namehint = "io_dcache_aw_ready"} : (i1, i1) -> i1
    %11 = "comb.icmp"(%6, %1) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_dcache_w_ready_T"} : (i3, i3) -> i1
    %12 = "comb.and"(%arg7, %11) <{twoState}> {sv.namehint = "io_nasti_w_valid"} : (i1, i1) -> i1
    %13 = "comb.and"(%arg15, %11) <{twoState}> {sv.namehint = "io_dcache_w_ready"} : (i1, i1) -> i1
    %14 = "comb.icmp"(%6, %5) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_nasti_b_ready_T"} : (i3, i3) -> i1
    %15 = "comb.and"(%arg16, %14) <{twoState}> {sv.namehint = "io_dcache_b_valid"} : (i1, i1) -> i1
    %16 = "comb.and"(%arg10, %14) <{twoState}> {sv.namehint = "io_nasti_b_ready"} : (i1, i1) -> i1
    %17 = "comb.mux"(%arg11, %arg12, %arg3) <{twoState}> {sv.namehint = "io_nasti_ar_bits_aw_addr"} : (i1, i32, i32) -> i32
    %18 = "comb.or"(%arg2, %arg11) <{twoState}> {sv.namehint = "_io_nasti_ar_valid_T"} : (i1, i1) -> i1
    %19 = "comb.xor"(%9, %4) <{twoState}> {sv.namehint = "_io_dcache_ar_ready_T"} : (i1, i1) -> i1
    %20 = "comb.and"(%18, %19, %8) <{twoState}> {sv.namehint = "io_nasti_ar_valid"} : (i1, i1, i1) -> i1
    %21 = "comb.and"(%arg17, %19, %8) <{twoState}> {sv.namehint = "io_dcache_ar_ready"} : (i1, i1, i1) -> i1
    %22 = "comb.xor"(%arg11, %4) <{twoState}> {sv.namehint = "_io_icache_ar_ready_T"} : (i1, i1) -> i1
    %23 = "comb.and"(%21, %22) <{twoState}> {sv.namehint = "io_icache_ar_ready"} : (i1, i1) -> i1
    %24 = "comb.icmp"(%6, %3) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_nasti_r_ready_T"} : (i3, i3) -> i1
    %25 = "comb.and"(%arg18, %24) <{twoState}> {sv.namehint = "io_icache_r_valid"} : (i1, i1) -> i1
    %26 = "comb.icmp"(%6, %2) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_nasti_r_ready_T_2"} : (i3, i3) -> i1
    %27 = "comb.and"(%arg18, %26) <{twoState}> {sv.namehint = "io_dcache_r_valid"} : (i1, i1) -> i1
    %28 = "comb.and"(%arg4, %24) <{twoState}> {sv.namehint = "_io_nasti_r_ready_T_1"} : (i1, i1) -> i1
    %29 = "comb.and"(%arg13, %26) <{twoState}> {sv.namehint = "_io_nasti_r_ready_T_3"} : (i1, i1) -> i1
    %30 = "comb.or"(%28, %29) <{twoState}> {sv.namehint = "io_nasti_r_ready"} : (i1, i1) -> i1
    %31 = "comb.and"(%10, %arg5) <{twoState}> : (i1, i1) -> i1
    %32 = "comb.and"(%21, %arg11) <{twoState}> : (i1, i1) -> i1
    %33 = "comb.and"(%23, %arg2) <{twoState}> : (i1, i1) -> i1
    %34 = "comb.mux"(%33, %3, %6) <{twoState}> : (i1, i3, i3) -> i3
    %35 = "comb.mux"(%32, %2, %34) <{twoState}> : (i1, i3, i3) -> i3
    %36 = "comb.mux"(%31, %1, %35) <{twoState}> : (i1, i3, i3) -> i3
    %37 = "comb.icmp"(%6, %3) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %38 = "comb.and"(%30, %arg18, %arg20) <{twoState}> : (i1, i1, i1) -> i1
    %39 = "comb.mux"(%38, %0, %6) <{twoState}> : (i1, i3, i3) -> i3
    %40 = "comb.icmp"(%6, %2) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %41 = "comb.icmp"(%6, %1) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %42 = "comb.and"(%13, %arg7, %arg9) <{twoState}> : (i1, i1, i1) -> i1
    %43 = "comb.mux"(%42, %5, %6) <{twoState}> : (i1, i3, i3) -> i3
    %44 = "comb.icmp"(%6, %5) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %45 = "comb.and"(%44, %16, %arg16) <{twoState}> : (i1, i1, i1) -> i1
    %46 = "comb.mux"(%45, %0, %6) <{twoState}> : (i1, i3, i3) -> i3
    %47 = "comb.mux"(%41, %43, %46) <{twoState}> : (i1, i3, i3) -> i3
    %48 = "comb.or"(%37, %40) : (i1, i1) -> i1
    %49 = "comb.mux"(%48, %39, %47) <{twoState}> : (i1, i3, i3) -> i3
    %50 = "comb.mux"(%7, %49, %36) <{twoState}> : (i1, i3, i3) -> i3
    "hw.output"(%23, %25, %arg19, %10, %13, %15, %21, %27, %arg19, %9, %arg6, %12, %arg8, %arg9, %16, %20, %17, %30) : (i1, i1, i64, i1, i1, i1, i1, i1, i64, i1, i32, i1, i64, i1, i1, i1, i32, i1) -> ()
  }) {module_type = !hw.modty<input clock : !seq.clock, input reset : i1, output io_icache_ar_ready : i1, input io_icache_ar_valid : i1, input io_icache_ar_bits_addr : i32, input io_icache_r_ready : i1, output io_icache_r_valid : i1, output io_icache_r_bits_data : i64, output io_dcache_aw_ready : i1, input io_dcache_aw_valid : i1, input io_dcache_aw_bits_addr : i32, output io_dcache_w_ready : i1, input io_dcache_w_valid : i1, input io_dcache_w_bits_data : i64, input io_dcache_w_bits_last : i1, input io_dcache_b_ready : i1, output io_dcache_b_valid : i1, output io_dcache_ar_ready : i1, input io_dcache_ar_valid : i1, input io_dcache_ar_bits_addr : i32, input io_dcache_r_ready : i1, output io_dcache_r_valid : i1, output io_dcache_r_bits_data : i64, input io_nasti_aw_ready : i1, output io_nasti_aw_valid : i1, output io_nasti_aw_bits_addr : i32, input io_nasti_w_ready : i1, output io_nasti_w_valid : i1, output io_nasti_w_bits_data : i64, output io_nasti_w_bits_last : i1, output io_nasti_b_ready : i1, input io_nasti_b_valid : i1, input io_nasti_ar_ready : i1, output io_nasti_ar_valid : i1, output io_nasti_ar_bits_addr : i32, output io_nasti_r_ready : i1, input io_nasti_r_valid : i1, input io_nasti_r_bits_data : i64, input io_nasti_r_bits_last : i1>, parameters = [], result_locs = [#loc52, #loc53, #loc54, #loc55, #loc56, #loc57, #loc58, #loc59, #loc60, #loc61, #loc62, #loc63, #loc64, #loc65, #loc66, #loc67, #loc68, #loc69], sym_name = "MemArbiter", sym_visibility = "private"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: !seq.clock, %arg1: i1, %arg2: i1, %arg3: i32, %arg4: i1, %arg5: i1, %arg6: i1, %arg7: i5, %arg8: i2, %arg9: i1, %arg10: i1, %arg11: i5, %arg12: i64, %arg13: i2, %arg14: i1):
    %0 = "hw.constant"() {value = 0 : i32} : () -> i32
    %1 = "hw.constant"() {value = -1 : i8} : () -> i8
    %2 = "hw.constant"() {value = 0 : i5} : () -> i5
    %3 = "hw.constant"() {value = 1 : i8} : () -> i8
    %4 = "hw.constant"() {value = 3 : i3} : () -> i3
    %5 = "hw.constant"() {value = 1 : i2} : () -> i2
    %6 = "hw.constant"() {value = false} : () -> i1
    %7 = "hw.constant"() {value = 0 : i3} : () -> i3
    %8 = "hw.constant"() {value = 0 : i4} : () -> i4
    %9:8 = "hw.instance"(%arg0, %arg1, %arg2, %arg3, %10#0, %10#1, %11#0, %11#1) {argNames = ["clock", "reset", "io_host_fromhost_valid", "io_host_fromhost_bits", "io_icache_resp_valid", "io_icache_resp_bits_data", "io_dcache_resp_valid", "io_dcache_resp_bits_data"], instanceName = "core", moduleName = @Core, parameters = [], resultNames = ["io_host_tohost", "io_icache_req_valid", "io_icache_req_bits_addr", "io_dcache_abort", "io_dcache_req_valid", "io_dcache_req_bits_addr", "io_dcache_req_bits_data", "io_dcache_req_bits_mask"], sv.namehint = "io_host_tohost"} : (!seq.clock, i1, i1, i32, i1, i32, i1, i32) -> (i32, i1, i32, i1, i1, i32, i32, i4)
    %10:11 = "hw.instance"(%arg0, %arg1, %6, %9#1, %9#2, %0, %8, %6, %6, %6, %12#0, %12#1, %12#2) {argNames = ["clock", "reset", "io_cpu_abort", "io_cpu_req_valid", "io_cpu_req_bits_addr", "io_cpu_req_bits_data", "io_cpu_req_bits_mask", "io_nasti_aw_ready", "io_nasti_w_ready", "io_nasti_b_valid", "io_nasti_ar_ready", "io_nasti_r_valid", "io_nasti_r_bits_data"], instanceName = "icache", moduleName = @Cache, parameters = [], resultNames = ["io_cpu_resp_valid", "io_cpu_resp_bits_data", "io_nasti_aw_valid", "io_nasti_aw_bits_addr", "io_nasti_w_valid", "io_nasti_w_bits_data", "io_nasti_w_bits_last", "io_nasti_b_ready", "io_nasti_ar_valid", "io_nasti_ar_bits_addr", "io_nasti_r_ready"]} : (!seq.clock, i1, i1, i1, i32, i32, i4, i1, i1, i1, i1, i1, i64) -> (i1, i32, i1, i32, i1, i64, i1, i1, i1, i32, i1)
    %11:11 = "hw.instance"(%arg0, %arg1, %9#3, %9#4, %9#5, %9#6, %9#7, %12#3, %12#4, %12#5, %12#6, %12#7, %12#8) {argNames = ["clock", "reset", "io_cpu_abort", "io_cpu_req_valid", "io_cpu_req_bits_addr", "io_cpu_req_bits_data", "io_cpu_req_bits_mask", "io_nasti_aw_ready", "io_nasti_w_ready", "io_nasti_b_valid", "io_nasti_ar_ready", "io_nasti_r_valid", "io_nasti_r_bits_data"], instanceName = "dcache", moduleName = @Cache, parameters = [], resultNames = ["io_cpu_resp_valid", "io_cpu_resp_bits_data", "io_nasti_aw_valid", "io_nasti_aw_bits_addr", "io_nasti_w_valid", "io_nasti_w_bits_data", "io_nasti_w_bits_last", "io_nasti_b_ready", "io_nasti_ar_valid", "io_nasti_ar_bits_addr", "io_nasti_r_ready"]} : (!seq.clock, i1, i1, i1, i32, i32, i4, i1, i1, i1, i1, i1, i64) -> (i1, i32, i1, i32, i1, i64, i1, i1, i1, i32, i1)
    %12:18 = "hw.instance"(%arg0, %arg1, %10#8, %10#9, %10#10, %11#2, %11#3, %11#4, %11#5, %11#6, %11#7, %11#8, %11#9, %11#10, %arg4, %arg5, %arg6, %arg9, %arg10, %arg12, %arg14) {argNames = ["clock", "reset", "io_icache_ar_valid", "io_icache_ar_bits_addr", "io_icache_r_ready", "io_dcache_aw_valid", "io_dcache_aw_bits_addr", "io_dcache_w_valid", "io_dcache_w_bits_data", "io_dcache_w_bits_last", "io_dcache_b_ready", "io_dcache_ar_valid", "io_dcache_ar_bits_addr", "io_dcache_r_ready", "io_nasti_aw_ready", "io_nasti_w_ready", "io_nasti_b_valid", "io_nasti_ar_ready", "io_nasti_r_valid", "io_nasti_r_bits_data", "io_nasti_r_bits_last"], instanceName = "arb", moduleName = @MemArbiter, parameters = [], resultNames = ["io_icache_ar_ready", "io_icache_r_valid", "io_icache_r_bits_data", "io_dcache_aw_ready", "io_dcache_w_ready", "io_dcache_b_valid", "io_dcache_ar_ready", "io_dcache_r_valid", "io_dcache_r_bits_data", "io_nasti_aw_valid", "io_nasti_aw_bits_addr", "io_nasti_w_valid", "io_nasti_w_bits_data", "io_nasti_w_bits_last", "io_nasti_b_ready", "io_nasti_ar_valid", "io_nasti_ar_bits_addr", "io_nasti_r_ready"], sv.namehint = "io_nasti_r_ready"} : (!seq.clock, i1, i1, i32, i1, i1, i32, i1, i64, i1, i1, i1, i32, i1, i1, i1, i1, i1, i1, i64, i1) -> (i1, i1, i64, i1, i1, i1, i1, i1, i64, i1, i32, i1, i64, i1, i1, i1, i32, i1)
    "hw.output"(%9#0, %12#9, %2, %12#10, %3, %4, %5, %6, %8, %7, %8, %12#11, %12#12, %1, %12#13, %12#14, %12#15, %2, %12#16, %3, %4, %5, %6, %8, %7, %8, %12#17) : (i32, i1, i5, i32, i8, i3, i2, i1, i4, i3, i4, i1, i64, i8, i1, i1, i1, i5, i32, i8, i3, i2, i1, i4, i3, i4, i1) -> ()
  }) {module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_host_fromhost_valid : i1, input io_host_fromhost_bits : i32, output io_host_tohost : i32, input io_nasti_aw_ready : i1, output io_nasti_aw_valid : i1, output io_nasti_aw_bits_id : i5, output io_nasti_aw_bits_addr : i32, output io_nasti_aw_bits_len : i8, output io_nasti_aw_bits_size : i3, output io_nasti_aw_bits_burst : i2, output io_nasti_aw_bits_lock : i1, output io_nasti_aw_bits_cache : i4, output io_nasti_aw_bits_prot : i3, output io_nasti_aw_bits_qos : i4, input io_nasti_w_ready : i1, output io_nasti_w_valid : i1, output io_nasti_w_bits_data : i64, output io_nasti_w_bits_strb : i8, output io_nasti_w_bits_last : i1, output io_nasti_b_ready : i1, input io_nasti_b_valid : i1, input io_nasti_b_bits_id : i5, input io_nasti_b_bits_resp : i2, input io_nasti_ar_ready : i1, output io_nasti_ar_valid : i1, output io_nasti_ar_bits_id : i5, output io_nasti_ar_bits_addr : i32, output io_nasti_ar_bits_len : i8, output io_nasti_ar_bits_size : i3, output io_nasti_ar_bits_burst : i2, output io_nasti_ar_bits_lock : i1, output io_nasti_ar_bits_cache : i4, output io_nasti_ar_bits_prot : i3, output io_nasti_ar_bits_qos : i4, output io_nasti_r_ready : i1, input io_nasti_r_valid : i1, input io_nasti_r_bits_id : i5, input io_nasti_r_bits_data : i64, input io_nasti_r_bits_resp : i2, input io_nasti_r_bits_last : i1>, parameters = [], result_locs = [#loc70, #loc71, #loc72, #loc73, #loc74, #loc75, #loc76, #loc77, #loc78, #loc79, #loc80, #loc81, #loc82, #loc83, #loc84, #loc85, #loc86, #loc87, #loc88, #loc89, #loc90, #loc91, #loc92, #loc93, #loc94, #loc95, #loc96], sym_name = "Tile"} : () -> ()
  "om.class"() ({
  ^bb0(%arg0: !om.basepath):
  }) {formalParamNames = ["basepath"], sym_name = "Tile_Class"} : () -> ()
}) : () -> ()
