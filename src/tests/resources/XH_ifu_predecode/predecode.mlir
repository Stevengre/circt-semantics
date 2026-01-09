hw.module private @PreDecode(in %io_in_bits_data_0 : i16, in %io_in_bits_data_1 : i16, in %io_in_bits_data_2 : i16, in %io_in_bits_data_3 : i16, in %io_in_bits_data_4 : i16, in %io_in_bits_data_5 : i16, in %io_in_bits_data_6 : i16, in %io_in_bits_data_7 : i16, in %io_in_bits_data_8 : i16, in %io_in_bits_data_9 : i16, in %io_in_bits_data_10 : i16, in %io_in_bits_data_11 : i16, in %io_in_bits_data_12 : i16, in %io_in_bits_data_13 : i16, in %io_in_bits_data_14 : i16, in %io_in_bits_data_15 : i16, in %io_in_bits_data_16 : i16, out io_out_pd_0_isRVC : i1, out io_out_pd_1_valid : i1, out io_out_pd_1_isRVC : i1, out io_out_pd_2_valid : i1, out io_out_pd_2_isRVC : i1, out io_out_pd_3_valid : i1, out io_out_pd_3_isRVC : i1, out io_out_pd_4_valid : i1, out io_out_pd_4_isRVC : i1, out io_out_pd_5_valid : i1, out io_out_pd_5_isRVC : i1, out io_out_pd_6_valid : i1, out io_out_pd_6_isRVC : i1, out io_out_pd_7_valid : i1, out io_out_pd_7_isRVC : i1, out io_out_pd_8_valid : i1, out io_out_pd_8_isRVC : i1, out io_out_pd_9_valid : i1, out io_out_pd_9_isRVC : i1, out io_out_pd_10_valid : i1, out io_out_pd_10_isRVC : i1, out io_out_pd_11_valid : i1, out io_out_pd_11_isRVC : i1, out io_out_pd_12_valid : i1, out io_out_pd_12_isRVC : i1, out io_out_pd_13_valid : i1, out io_out_pd_13_isRVC : i1, out io_out_pd_14_valid : i1, out io_out_pd_14_isRVC : i1, out io_out_pd_15_valid : i1, out io_out_pd_15_isRVC : i1, out io_out_hasHalfValid_2 : i1, out io_out_hasHalfValid_3 : i1, out io_out_hasHalfValid_4 : i1, out io_out_hasHalfValid_5 : i1, out io_out_hasHalfValid_6 : i1, out io_out_hasHalfValid_7 : i1, out io_out_hasHalfValid_8 : i1, out io_out_hasHalfValid_9 : i1, out io_out_hasHalfValid_10 : i1, out io_out_hasHalfValid_11 : i1, out io_out_hasHalfValid_12 : i1, out io_out_hasHalfValid_13 : i1, out io_out_hasHalfValid_14 : i1, out io_out_hasHalfValid_15 : i1, out io_out_instr_0 : i32, out io_out_instr_1 : i32, out io_out_instr_2 : i32, out io_out_instr_3 : i32, out io_out_instr_4 : i32, out io_out_instr_5 : i32, out io_out_instr_6 : i32, out io_out_instr_7 : i32, out io_out_instr_8 : i32, out io_out_instr_9 : i32, out io_out_instr_10 : i32, out io_out_instr_11 : i32, out io_out_instr_12 : i32, out io_out_instr_13 : i32, out io_out_instr_14 : i32, out io_out_instr_15 : i32, out io_out_jumpOffset_0 : i64, out io_out_jumpOffset_1 : i64, out io_out_jumpOffset_2 : i64, out io_out_jumpOffset_3 : i64, out io_out_jumpOffset_4 : i64, out io_out_jumpOffset_5 : i64, out io_out_jumpOffset_6 : i64, out io_out_jumpOffset_7 : i64, out io_out_jumpOffset_8 : i64, out io_out_jumpOffset_9 : i64, out io_out_jumpOffset_10 : i64, out io_out_jumpOffset_11 : i64, out io_out_jumpOffset_12 : i64, out io_out_jumpOffset_13 : i64, out io_out_jumpOffset_14 : i64, out io_out_jumpOffset_15 : i64) {
    %c-29_i7 = hw.constant -29 : i7
    %c103_i10 = hw.constant 103 : i10
    %c-17_i7 = hw.constant -17 : i7
    %c-3_i4 = hw.constant -3 : i4
    %c-510_i10 = hw.constant -510 : i10
    %c-11_i5 = hw.constant -11 : i5
    %c-16382_i15 = hw.constant -16382 : i15
    %c-1_i2 = hw.constant -1 : i2
    %c-2_i2 = hw.constant -2 : i2
    %false = hw.constant false
    %true = hw.constant true
    %c1_i2 = hw.constant 1 : i2
    %c0_i2 = hw.constant 0 : i2
    %0 = comb.concat %io_in_bits_data_1, %io_in_bits_data_0 {sv.namehint = "inst"} : i16, i16
    %1 = comb.concat %io_in_bits_data_2, %io_in_bits_data_1 {sv.namehint = "inst_1"} : i16, i16
    %2 = comb.concat %io_in_bits_data_3, %io_in_bits_data_2 {sv.namehint = "inst_2"} : i16, i16
    %3 = comb.concat %io_in_bits_data_4, %io_in_bits_data_3 {sv.namehint = "inst_3"} : i16, i16
    %4 = comb.concat %io_in_bits_data_5, %io_in_bits_data_4 {sv.namehint = "inst_4"} : i16, i16
    %5 = comb.concat %io_in_bits_data_6, %io_in_bits_data_5 {sv.namehint = "inst_5"} : i16, i16
    %6 = comb.concat %io_in_bits_data_7, %io_in_bits_data_6 {sv.namehint = "inst_6"} : i16, i16
    %7 = comb.concat %io_in_bits_data_8, %io_in_bits_data_7 {sv.namehint = "inst_7"} : i16, i16
    %8 = comb.concat %io_in_bits_data_9, %io_in_bits_data_8 {sv.namehint = "inst_8"} : i16, i16
    %9 = comb.concat %io_in_bits_data_10, %io_in_bits_data_9 {sv.namehint = "inst_9"} : i16, i16
    %10 = comb.concat %io_in_bits_data_11, %io_in_bits_data_10 {sv.namehint = "inst_10"} : i16, i16
    %11 = comb.concat %io_in_bits_data_12, %io_in_bits_data_11 {sv.namehint = "inst_11"} : i16, i16
    %12 = comb.concat %io_in_bits_data_13, %io_in_bits_data_12 {sv.namehint = "inst_12"} : i16, i16
    %13 = comb.concat %io_in_bits_data_14, %io_in_bits_data_13 {sv.namehint = "inst_13"} : i16, i16
    %14 = comb.concat %io_in_bits_data_15, %io_in_bits_data_14 {sv.namehint = "inst_14"} : i16, i16
    %15 = comb.concat %io_in_bits_data_16, %io_in_bits_data_15 {sv.namehint = "inst_15"} : i16, i16
    %16 = comb.extract %io_in_bits_data_0 from 0 {sv.namehint = "_isCall_T_1"} : (i16) -> i2
    %17 = comb.icmp bin ne %16, %c-1_i2 {sv.namehint = "currentIsRVC_0"} : i2
    %18 = comb.extract %io_in_bits_data_0 from 13 : (i16) -> i3
    %19 = comb.extract %io_in_bits_data_0 from 0 : (i16) -> i12
    %20 = comb.concat %18, %19 : i3, i12
    %21 = comb.icmp bin eq %20, %c-16382_i15 {sv.namehint = "_brType_T_1"} : i15
    %22 = comb.extract %io_in_bits_data_0 from 13 : (i16) -> i3
    %23 = comb.extract %io_in_bits_data_0 from 0 : (i16) -> i2
    %24 = comb.concat %22, %23 : i3, i2
    %25 = comb.icmp bin eq %24, %c-11_i5 {sv.namehint = "_brType_T_3"} : i5
    %26 = comb.extract %io_in_bits_data_0 from 13 : (i16) -> i3
    %27 = comb.extract %io_in_bits_data_0 from 0 : (i16) -> i7
    %28 = comb.concat %26, %27 : i3, i7
    %29 = comb.icmp bin eq %28, %c-510_i10 {sv.namehint = "_brType_T_5"} : i10
    %30 = comb.extract %io_in_bits_data_0 from 14 : (i16) -> i2
    %31 = comb.extract %io_in_bits_data_0 from 0 : (i16) -> i2
    %32 = comb.concat %30, %31 : i2, i2
    %33 = comb.icmp bin eq %32, %c-3_i4 {sv.namehint = "_brType_T_7"} : i4
    %34 = comb.extract %io_in_bits_data_0 from 0 : (i16) -> i7
    %35 = comb.icmp bin eq %34, %c-17_i7 {sv.namehint = "_brType_T_9"} : i7
    %36 = comb.extract %io_in_bits_data_0 from 12 : (i16) -> i3
    %37 = comb.extract %io_in_bits_data_0 from 0 : (i16) -> i7
    %38 = comb.concat %36, %37 : i3, i7
    %39 = comb.icmp bin eq %38, %c103_i10 {sv.namehint = "_brType_T_11"} : i10
    %40 = comb.icmp bin eq %34, %c-29_i7 {sv.namehint = "_brType_T_14"} : i7
    %41 = comb.concat %false, %40 : i1, i1
    %42 = comb.mux bin %39, %c-1_i2, %41 {sv.namehint = "_brType_T_15"} : i2
    %43 = comb.mux bin %35, %c-2_i2, %42 {sv.namehint = "_brType_T_16"} : i2
    %44 = comb.mux bin %33, %c1_i2, %43 {sv.namehint = "_brType_T_17"} : i2
    %45 = comb.mux bin %29, %c-1_i2, %44 {sv.namehint = "_brType_T_18"} : i2
    %46 = comb.mux bin %25, %c-2_i2, %45 {sv.namehint = "_brType_T_19"} : i2
    %47 = comb.mux bin %21, %c0_i2, %46 {sv.namehint = "brType"} : i2
    %48 = comb.extract %io_in_bits_data_0 from 12 {sv.namehint = "_brOffset_rvc_offset_T"} : (i16) -> i1
    %49 = comb.extract %io_in_bits_data_0 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_1"} : (i16) -> i1
    %50 = comb.extract %io_in_bits_data_0 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_2"} : (i16) -> i2
    %51 = comb.extract %io_in_bits_data_0 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_3"} : (i16) -> i1
    %52 = comb.extract %io_in_bits_data_0 from 7 {sv.namehint = "_brOffset_rvi_offset_T_1"} : (i16) -> i1
    %53 = comb.extract %io_in_bits_data_0 from 2 {sv.namehint = "_brOffset_rvc_offset_T_2"} : (i16) -> i1
    %54 = comb.extract %io_in_bits_data_0 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_6"} : (i16) -> i1
    %55 = comb.extract %io_in_bits_data_0 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_7"} : (i16) -> i3
    %56 = comb.extract %io_in_bits_data_1 from 15 {sv.namehint = "_brOffset_rvi_offset_T"} : (i16) -> i1
    %57 = comb.extract %io_in_bits_data_0 from 12 : (i16) -> i4
    %58 = comb.extract %io_in_bits_data_1 from 0 : (i16) -> i4
    %59 = comb.extract %io_in_bits_data_1 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_2"} : (i16) -> i1
    %60 = comb.extract %io_in_bits_data_1 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_3"} : (i16) -> i10
    %61 = comb.replicate %48 : (i1) -> i10
    %62 = comb.concat %61, %49, %50, %51, %52, %53, %54, %55 : i10, i1, i2, i1, i1, i1, i1, i3
    %63 = comb.concat %56, %58, %57, %59, %60 : i1, i4, i4, i1, i10
    %64 = comb.mux bin %17, %62, %63 : i20
    %65 = comb.extract %64 from 19 {sv.namehint = "jalOffset_signBit_2"} : (i20) -> i1
    %66 = comb.extract %io_in_bits_data_0 from 5 {sv.namehint = "_brOffset_rvc_offset_T_1"} : (i16) -> i2
    %67 = comb.extract %io_in_bits_data_0 from 10 {sv.namehint = "_brOffset_rvc_offset_T_3"} : (i16) -> i2
    %68 = comb.extract %io_in_bits_data_0 from 3 {sv.namehint = "_brOffset_rvc_offset_T_4"} : (i16) -> i2
    %69 = comb.extract %io_in_bits_data_1 from 9 {sv.namehint = "_brOffset_rvi_offset_T_2"} : (i16) -> i6
    %70 = comb.extract %io_in_bits_data_0 from 8 {sv.namehint = "_brOffset_rvi_offset_T_3"} : (i16) -> i4
    %71 = comb.replicate %48 : (i1) -> i5
    %72 = comb.concat %71, %66, %53, %67, %68 : i5, i2, i1, i2, i2
    %73 = comb.concat %56, %52, %69, %70 : i1, i1, i6, i4
    %74 = comb.mux bin %17, %72, %73 : i12
    %75 = comb.extract %74 from 11 {sv.namehint = "brOffset_signBit_2"} : (i12) -> i1
    %76 = comb.icmp bin eq %47, %c1_i2 {sv.namehint = "_io_out_jumpOffset_0_T"} : i2
    %77 = comb.replicate %75 : (i1) -> i51
    %78 = comb.concat %77, %74 : i51, i12
    %79 = comb.replicate %65 : (i1) -> i43
    %80 = comb.concat %79, %64 : i43, i20
    %81 = comb.mux bin %76, %78, %80 : i63
    %82 = comb.concat %81, %false {sv.namehint = "io_out_jumpOffset_0"} : i63, i1
    %83 = comb.extract %io_in_bits_data_1 from 0 {sv.namehint = "_isCall_T_11"} : (i16) -> i2
    %84 = comb.icmp bin ne %83, %c-1_i2 {sv.namehint = "currentIsRVC_1"} : i2
    %85 = comb.extract %io_in_bits_data_1 from 13 : (i16) -> i3
    %86 = comb.extract %io_in_bits_data_1 from 0 : (i16) -> i12
    %87 = comb.concat %85, %86 : i3, i12
    %88 = comb.icmp bin eq %87, %c-16382_i15 {sv.namehint = "_brType_T_21"} : i15
    %89 = comb.extract %io_in_bits_data_1 from 13 : (i16) -> i3
    %90 = comb.extract %io_in_bits_data_1 from 0 : (i16) -> i2
    %91 = comb.concat %89, %90 : i3, i2
    %92 = comb.icmp bin eq %91, %c-11_i5 {sv.namehint = "_brType_T_23"} : i5
    %93 = comb.extract %io_in_bits_data_1 from 13 : (i16) -> i3
    %94 = comb.extract %io_in_bits_data_1 from 0 : (i16) -> i7
    %95 = comb.concat %93, %94 : i3, i7
    %96 = comb.icmp bin eq %95, %c-510_i10 {sv.namehint = "_brType_T_25"} : i10
    %97 = comb.extract %io_in_bits_data_1 from 14 : (i16) -> i2
    %98 = comb.extract %io_in_bits_data_1 from 0 : (i16) -> i2
    %99 = comb.concat %97, %98 : i2, i2
    %100 = comb.icmp bin eq %99, %c-3_i4 {sv.namehint = "_brType_T_27"} : i4
    %101 = comb.extract %io_in_bits_data_1 from 0 : (i16) -> i7
    %102 = comb.icmp bin eq %101, %c-17_i7 {sv.namehint = "_brType_T_29"} : i7
    %103 = comb.extract %io_in_bits_data_1 from 12 : (i16) -> i3
    %104 = comb.extract %io_in_bits_data_1 from 0 : (i16) -> i7
    %105 = comb.concat %103, %104 : i3, i7
    %106 = comb.icmp bin eq %105, %c103_i10 {sv.namehint = "_brType_T_31"} : i10
    %107 = comb.icmp bin eq %101, %c-29_i7 {sv.namehint = "_brType_T_34"} : i7
    %108 = comb.concat %false, %107 : i1, i1
    %109 = comb.mux bin %106, %c-1_i2, %108 {sv.namehint = "_brType_T_35"} : i2
    %110 = comb.mux bin %102, %c-2_i2, %109 {sv.namehint = "_brType_T_36"} : i2
    %111 = comb.mux bin %100, %c1_i2, %110 {sv.namehint = "_brType_T_37"} : i2
    %112 = comb.mux bin %96, %c-1_i2, %111 {sv.namehint = "_brType_T_38"} : i2
    %113 = comb.mux bin %92, %c-2_i2, %112 {sv.namehint = "_brType_T_39"} : i2
    %114 = comb.mux bin %88, %c0_i2, %113 {sv.namehint = "brType_1"} : i2
    %115 = comb.extract %io_in_bits_data_1 from 12 {sv.namehint = "_brOffset_rvc_offset_T_5"} : (i16) -> i1
    %116 = comb.extract %io_in_bits_data_1 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_9"} : (i16) -> i1
    %117 = comb.extract %io_in_bits_data_1 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_10"} : (i16) -> i2
    %118 = comb.extract %io_in_bits_data_1 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_11"} : (i16) -> i1
    %119 = comb.extract %io_in_bits_data_1 from 7 {sv.namehint = "_brOffset_rvi_offset_T_5"} : (i16) -> i1
    %120 = comb.extract %io_in_bits_data_1 from 2 {sv.namehint = "_brOffset_rvc_offset_T_7"} : (i16) -> i1
    %121 = comb.extract %io_in_bits_data_1 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_14"} : (i16) -> i1
    %122 = comb.extract %io_in_bits_data_1 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_15"} : (i16) -> i3
    %123 = comb.extract %io_in_bits_data_2 from 15 {sv.namehint = "_brOffset_rvi_offset_T_4"} : (i16) -> i1
    %124 = comb.extract %io_in_bits_data_1 from 12 : (i16) -> i4
    %125 = comb.extract %io_in_bits_data_2 from 0 : (i16) -> i4
    %126 = comb.extract %io_in_bits_data_2 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_6"} : (i16) -> i1
    %127 = comb.extract %io_in_bits_data_2 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_7"} : (i16) -> i10
    %128 = comb.replicate %115 : (i1) -> i10
    %129 = comb.concat %128, %116, %117, %118, %119, %120, %121, %122 : i10, i1, i2, i1, i1, i1, i1, i3
    %130 = comb.concat %123, %125, %124, %126, %127 : i1, i4, i4, i1, i10
    %131 = comb.mux bin %84, %129, %130 : i20
    %132 = comb.extract %131 from 19 {sv.namehint = "jalOffset_signBit_5"} : (i20) -> i1
    %133 = comb.extract %io_in_bits_data_1 from 5 {sv.namehint = "_brOffset_rvc_offset_T_6"} : (i16) -> i2
    %134 = comb.extract %io_in_bits_data_1 from 10 {sv.namehint = "_brOffset_rvc_offset_T_8"} : (i16) -> i2
    %135 = comb.extract %io_in_bits_data_1 from 3 {sv.namehint = "_brOffset_rvc_offset_T_9"} : (i16) -> i2
    %136 = comb.extract %io_in_bits_data_2 from 9 {sv.namehint = "_brOffset_rvi_offset_T_6"} : (i16) -> i6
    %137 = comb.extract %io_in_bits_data_1 from 8 {sv.namehint = "_brOffset_rvi_offset_T_7"} : (i16) -> i4
    %138 = comb.replicate %115 : (i1) -> i5
    %139 = comb.concat %138, %133, %120, %134, %135 : i5, i2, i1, i2, i2
    %140 = comb.concat %123, %119, %136, %137 : i1, i1, i6, i4
    %141 = comb.mux bin %84, %139, %140 : i12
    %142 = comb.extract %141 from 11 {sv.namehint = "brOffset_signBit_5"} : (i12) -> i1
    %143 = comb.icmp bin eq %114, %c1_i2 {sv.namehint = "_io_out_jumpOffset_1_T"} : i2
    %144 = comb.replicate %142 : (i1) -> i51
    %145 = comb.concat %144, %141 : i51, i12
    %146 = comb.replicate %132 : (i1) -> i43
    %147 = comb.concat %146, %131 : i43, i20
    %148 = comb.mux bin %143, %145, %147 : i63
    %149 = comb.concat %148, %false {sv.namehint = "io_out_jumpOffset_1"} : i63, i1
    %150 = comb.extract %io_in_bits_data_2 from 0 {sv.namehint = "_isCall_T_21"} : (i16) -> i2
    %151 = comb.icmp bin ne %150, %c-1_i2 {sv.namehint = "currentIsRVC_2"} : i2
    %152 = comb.extract %io_in_bits_data_2 from 13 : (i16) -> i3
    %153 = comb.extract %io_in_bits_data_2 from 0 : (i16) -> i12
    %154 = comb.concat %152, %153 : i3, i12
    %155 = comb.icmp bin eq %154, %c-16382_i15 {sv.namehint = "_brType_T_41"} : i15
    %156 = comb.extract %io_in_bits_data_2 from 13 : (i16) -> i3
    %157 = comb.extract %io_in_bits_data_2 from 0 : (i16) -> i2
    %158 = comb.concat %156, %157 : i3, i2
    %159 = comb.icmp bin eq %158, %c-11_i5 {sv.namehint = "_brType_T_43"} : i5
    %160 = comb.extract %io_in_bits_data_2 from 13 : (i16) -> i3
    %161 = comb.extract %io_in_bits_data_2 from 0 : (i16) -> i7
    %162 = comb.concat %160, %161 : i3, i7
    %163 = comb.icmp bin eq %162, %c-510_i10 {sv.namehint = "_brType_T_45"} : i10
    %164 = comb.extract %io_in_bits_data_2 from 14 : (i16) -> i2
    %165 = comb.extract %io_in_bits_data_2 from 0 : (i16) -> i2
    %166 = comb.concat %164, %165 : i2, i2
    %167 = comb.icmp bin eq %166, %c-3_i4 {sv.namehint = "_brType_T_47"} : i4
    %168 = comb.extract %io_in_bits_data_2 from 0 : (i16) -> i7
    %169 = comb.icmp bin eq %168, %c-17_i7 {sv.namehint = "_brType_T_49"} : i7
    %170 = comb.extract %io_in_bits_data_2 from 12 : (i16) -> i3
    %171 = comb.extract %io_in_bits_data_2 from 0 : (i16) -> i7
    %172 = comb.concat %170, %171 : i3, i7
    %173 = comb.icmp bin eq %172, %c103_i10 {sv.namehint = "_brType_T_51"} : i10
    %174 = comb.icmp bin eq %168, %c-29_i7 {sv.namehint = "_brType_T_54"} : i7
    %175 = comb.concat %false, %174 : i1, i1
    %176 = comb.mux bin %173, %c-1_i2, %175 {sv.namehint = "_brType_T_55"} : i2
    %177 = comb.mux bin %169, %c-2_i2, %176 {sv.namehint = "_brType_T_56"} : i2
    %178 = comb.mux bin %167, %c1_i2, %177 {sv.namehint = "_brType_T_57"} : i2
    %179 = comb.mux bin %163, %c-1_i2, %178 {sv.namehint = "_brType_T_58"} : i2
    %180 = comb.mux bin %159, %c-2_i2, %179 {sv.namehint = "_brType_T_59"} : i2
    %181 = comb.mux bin %155, %c0_i2, %180 {sv.namehint = "brType_2"} : i2
    %182 = comb.extract %io_in_bits_data_2 from 12 {sv.namehint = "_brOffset_rvc_offset_T_10"} : (i16) -> i1
    %183 = comb.extract %io_in_bits_data_2 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_17"} : (i16) -> i1
    %184 = comb.extract %io_in_bits_data_2 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_18"} : (i16) -> i2
    %185 = comb.extract %io_in_bits_data_2 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_19"} : (i16) -> i1
    %186 = comb.extract %io_in_bits_data_2 from 7 {sv.namehint = "_brOffset_rvi_offset_T_9"} : (i16) -> i1
    %187 = comb.extract %io_in_bits_data_2 from 2 {sv.namehint = "_brOffset_rvc_offset_T_12"} : (i16) -> i1
    %188 = comb.extract %io_in_bits_data_2 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_22"} : (i16) -> i1
    %189 = comb.extract %io_in_bits_data_2 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_23"} : (i16) -> i3
    %190 = comb.extract %io_in_bits_data_3 from 15 {sv.namehint = "_brOffset_rvi_offset_T_8"} : (i16) -> i1
    %191 = comb.extract %io_in_bits_data_2 from 12 : (i16) -> i4
    %192 = comb.extract %io_in_bits_data_3 from 0 : (i16) -> i4
    %193 = comb.extract %io_in_bits_data_3 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_10"} : (i16) -> i1
    %194 = comb.extract %io_in_bits_data_3 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_11"} : (i16) -> i10
    %195 = comb.replicate %182 : (i1) -> i10
    %196 = comb.concat %195, %183, %184, %185, %186, %187, %188, %189 : i10, i1, i2, i1, i1, i1, i1, i3
    %197 = comb.concat %190, %192, %191, %193, %194 : i1, i4, i4, i1, i10
    %198 = comb.mux bin %151, %196, %197 : i20
    %199 = comb.extract %198 from 19 {sv.namehint = "jalOffset_signBit_8"} : (i20) -> i1
    %200 = comb.extract %io_in_bits_data_2 from 5 {sv.namehint = "_brOffset_rvc_offset_T_11"} : (i16) -> i2
    %201 = comb.extract %io_in_bits_data_2 from 10 {sv.namehint = "_brOffset_rvc_offset_T_13"} : (i16) -> i2
    %202 = comb.extract %io_in_bits_data_2 from 3 {sv.namehint = "_brOffset_rvc_offset_T_14"} : (i16) -> i2
    %203 = comb.extract %io_in_bits_data_3 from 9 {sv.namehint = "_brOffset_rvi_offset_T_10"} : (i16) -> i6
    %204 = comb.extract %io_in_bits_data_2 from 8 {sv.namehint = "_brOffset_rvi_offset_T_11"} : (i16) -> i4
    %205 = comb.replicate %182 : (i1) -> i5
    %206 = comb.concat %205, %200, %187, %201, %202 : i5, i2, i1, i2, i2
    %207 = comb.concat %190, %186, %203, %204 : i1, i1, i6, i4
    %208 = comb.mux bin %151, %206, %207 : i12
    %209 = comb.extract %208 from 11 {sv.namehint = "brOffset_signBit_8"} : (i12) -> i1
    %210 = comb.icmp bin eq %181, %c1_i2 {sv.namehint = "_io_out_jumpOffset_2_T"} : i2
    %211 = comb.replicate %209 : (i1) -> i51
    %212 = comb.concat %211, %208 : i51, i12
    %213 = comb.replicate %199 : (i1) -> i43
    %214 = comb.concat %213, %198 : i43, i20
    %215 = comb.mux bin %210, %212, %214 : i63
    %216 = comb.concat %215, %false {sv.namehint = "io_out_jumpOffset_2"} : i63, i1
    %217 = comb.extract %io_in_bits_data_3 from 0 {sv.namehint = "_isCall_T_31"} : (i16) -> i2
    %218 = comb.icmp bin ne %217, %c-1_i2 {sv.namehint = "currentIsRVC_3"} : i2
    %219 = comb.extract %io_in_bits_data_3 from 13 : (i16) -> i3
    %220 = comb.extract %io_in_bits_data_3 from 0 : (i16) -> i12
    %221 = comb.concat %219, %220 : i3, i12
    %222 = comb.icmp bin eq %221, %c-16382_i15 {sv.namehint = "_brType_T_61"} : i15
    %223 = comb.extract %io_in_bits_data_3 from 13 : (i16) -> i3
    %224 = comb.extract %io_in_bits_data_3 from 0 : (i16) -> i2
    %225 = comb.concat %223, %224 : i3, i2
    %226 = comb.icmp bin eq %225, %c-11_i5 {sv.namehint = "_brType_T_63"} : i5
    %227 = comb.extract %io_in_bits_data_3 from 13 : (i16) -> i3
    %228 = comb.extract %io_in_bits_data_3 from 0 : (i16) -> i7
    %229 = comb.concat %227, %228 : i3, i7
    %230 = comb.icmp bin eq %229, %c-510_i10 {sv.namehint = "_brType_T_65"} : i10
    %231 = comb.extract %io_in_bits_data_3 from 14 : (i16) -> i2
    %232 = comb.extract %io_in_bits_data_3 from 0 : (i16) -> i2
    %233 = comb.concat %231, %232 : i2, i2
    %234 = comb.icmp bin eq %233, %c-3_i4 {sv.namehint = "_brType_T_67"} : i4
    %235 = comb.extract %io_in_bits_data_3 from 0 : (i16) -> i7
    %236 = comb.icmp bin eq %235, %c-17_i7 {sv.namehint = "_brType_T_69"} : i7
    %237 = comb.extract %io_in_bits_data_3 from 12 : (i16) -> i3
    %238 = comb.extract %io_in_bits_data_3 from 0 : (i16) -> i7
    %239 = comb.concat %237, %238 : i3, i7
    %240 = comb.icmp bin eq %239, %c103_i10 {sv.namehint = "_brType_T_71"} : i10
    %241 = comb.icmp bin eq %235, %c-29_i7 {sv.namehint = "_brType_T_74"} : i7
    %242 = comb.concat %false, %241 : i1, i1
    %243 = comb.mux bin %240, %c-1_i2, %242 {sv.namehint = "_brType_T_75"} : i2
    %244 = comb.mux bin %236, %c-2_i2, %243 {sv.namehint = "_brType_T_76"} : i2
    %245 = comb.mux bin %234, %c1_i2, %244 {sv.namehint = "_brType_T_77"} : i2
    %246 = comb.mux bin %230, %c-1_i2, %245 {sv.namehint = "_brType_T_78"} : i2
    %247 = comb.mux bin %226, %c-2_i2, %246 {sv.namehint = "_brType_T_79"} : i2
    %248 = comb.mux bin %222, %c0_i2, %247 {sv.namehint = "brType_3"} : i2
    %249 = comb.extract %io_in_bits_data_3 from 12 {sv.namehint = "_brOffset_rvc_offset_T_15"} : (i16) -> i1
    %250 = comb.extract %io_in_bits_data_3 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_25"} : (i16) -> i1
    %251 = comb.extract %io_in_bits_data_3 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_26"} : (i16) -> i2
    %252 = comb.extract %io_in_bits_data_3 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_27"} : (i16) -> i1
    %253 = comb.extract %io_in_bits_data_3 from 7 {sv.namehint = "_brOffset_rvi_offset_T_13"} : (i16) -> i1
    %254 = comb.extract %io_in_bits_data_3 from 2 {sv.namehint = "_brOffset_rvc_offset_T_17"} : (i16) -> i1
    %255 = comb.extract %io_in_bits_data_3 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_30"} : (i16) -> i1
    %256 = comb.extract %io_in_bits_data_3 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_31"} : (i16) -> i3
    %257 = comb.extract %io_in_bits_data_4 from 15 {sv.namehint = "_brOffset_rvi_offset_T_12"} : (i16) -> i1
    %258 = comb.extract %io_in_bits_data_3 from 12 : (i16) -> i4
    %259 = comb.extract %io_in_bits_data_4 from 0 : (i16) -> i4
    %260 = comb.extract %io_in_bits_data_4 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_14"} : (i16) -> i1
    %261 = comb.extract %io_in_bits_data_4 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_15"} : (i16) -> i10
    %262 = comb.replicate %249 : (i1) -> i10
    %263 = comb.concat %262, %250, %251, %252, %253, %254, %255, %256 : i10, i1, i2, i1, i1, i1, i1, i3
    %264 = comb.concat %257, %259, %258, %260, %261 : i1, i4, i4, i1, i10
    %265 = comb.mux bin %218, %263, %264 : i20
    %266 = comb.extract %265 from 19 {sv.namehint = "jalOffset_signBit_11"} : (i20) -> i1
    %267 = comb.extract %io_in_bits_data_3 from 5 {sv.namehint = "_brOffset_rvc_offset_T_16"} : (i16) -> i2
    %268 = comb.extract %io_in_bits_data_3 from 10 {sv.namehint = "_brOffset_rvc_offset_T_18"} : (i16) -> i2
    %269 = comb.extract %io_in_bits_data_3 from 3 {sv.namehint = "_brOffset_rvc_offset_T_19"} : (i16) -> i2
    %270 = comb.extract %io_in_bits_data_4 from 9 {sv.namehint = "_brOffset_rvi_offset_T_14"} : (i16) -> i6
    %271 = comb.extract %io_in_bits_data_3 from 8 {sv.namehint = "_brOffset_rvi_offset_T_15"} : (i16) -> i4
    %272 = comb.replicate %249 : (i1) -> i5
    %273 = comb.concat %272, %267, %254, %268, %269 : i5, i2, i1, i2, i2
    %274 = comb.concat %257, %253, %270, %271 : i1, i1, i6, i4
    %275 = comb.mux bin %218, %273, %274 : i12
    %276 = comb.extract %275 from 11 {sv.namehint = "brOffset_signBit_11"} : (i12) -> i1
    %277 = comb.icmp bin eq %248, %c1_i2 {sv.namehint = "_io_out_jumpOffset_3_T"} : i2
    %278 = comb.replicate %276 : (i1) -> i51
    %279 = comb.concat %278, %275 : i51, i12
    %280 = comb.replicate %266 : (i1) -> i43
    %281 = comb.concat %280, %265 : i43, i20
    %282 = comb.mux bin %277, %279, %281 : i63
    %283 = comb.concat %282, %false {sv.namehint = "io_out_jumpOffset_3"} : i63, i1
    %284 = comb.extract %io_in_bits_data_4 from 0 {sv.namehint = "_isCall_T_41"} : (i16) -> i2
    %285 = comb.icmp bin ne %284, %c-1_i2 {sv.namehint = "currentIsRVC_4"} : i2
    %286 = comb.extract %io_in_bits_data_4 from 13 : (i16) -> i3
    %287 = comb.extract %io_in_bits_data_4 from 0 : (i16) -> i12
    %288 = comb.concat %286, %287 : i3, i12
    %289 = comb.icmp bin eq %288, %c-16382_i15 {sv.namehint = "_brType_T_81"} : i15
    %290 = comb.extract %io_in_bits_data_4 from 13 : (i16) -> i3
    %291 = comb.extract %io_in_bits_data_4 from 0 : (i16) -> i2
    %292 = comb.concat %290, %291 : i3, i2
    %293 = comb.icmp bin eq %292, %c-11_i5 {sv.namehint = "_brType_T_83"} : i5
    %294 = comb.extract %io_in_bits_data_4 from 13 : (i16) -> i3
    %295 = comb.extract %io_in_bits_data_4 from 0 : (i16) -> i7
    %296 = comb.concat %294, %295 : i3, i7
    %297 = comb.icmp bin eq %296, %c-510_i10 {sv.namehint = "_brType_T_85"} : i10
    %298 = comb.extract %io_in_bits_data_4 from 14 : (i16) -> i2
    %299 = comb.extract %io_in_bits_data_4 from 0 : (i16) -> i2
    %300 = comb.concat %298, %299 : i2, i2
    %301 = comb.icmp bin eq %300, %c-3_i4 {sv.namehint = "_brType_T_87"} : i4
    %302 = comb.extract %io_in_bits_data_4 from 0 : (i16) -> i7
    %303 = comb.icmp bin eq %302, %c-17_i7 {sv.namehint = "_brType_T_89"} : i7
    %304 = comb.extract %io_in_bits_data_4 from 12 : (i16) -> i3
    %305 = comb.extract %io_in_bits_data_4 from 0 : (i16) -> i7
    %306 = comb.concat %304, %305 : i3, i7
    %307 = comb.icmp bin eq %306, %c103_i10 {sv.namehint = "_brType_T_91"} : i10
    %308 = comb.icmp bin eq %302, %c-29_i7 {sv.namehint = "_brType_T_94"} : i7
    %309 = comb.concat %false, %308 : i1, i1
    %310 = comb.mux bin %307, %c-1_i2, %309 {sv.namehint = "_brType_T_95"} : i2
    %311 = comb.mux bin %303, %c-2_i2, %310 {sv.namehint = "_brType_T_96"} : i2
    %312 = comb.mux bin %301, %c1_i2, %311 {sv.namehint = "_brType_T_97"} : i2
    %313 = comb.mux bin %297, %c-1_i2, %312 {sv.namehint = "_brType_T_98"} : i2
    %314 = comb.mux bin %293, %c-2_i2, %313 {sv.namehint = "_brType_T_99"} : i2
    %315 = comb.mux bin %289, %c0_i2, %314 {sv.namehint = "brType_4"} : i2
    %316 = comb.extract %io_in_bits_data_4 from 12 {sv.namehint = "_brOffset_rvc_offset_T_20"} : (i16) -> i1
    %317 = comb.extract %io_in_bits_data_4 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_33"} : (i16) -> i1
    %318 = comb.extract %io_in_bits_data_4 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_34"} : (i16) -> i2
    %319 = comb.extract %io_in_bits_data_4 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_35"} : (i16) -> i1
    %320 = comb.extract %io_in_bits_data_4 from 7 {sv.namehint = "_brOffset_rvi_offset_T_17"} : (i16) -> i1
    %321 = comb.extract %io_in_bits_data_4 from 2 {sv.namehint = "_brOffset_rvc_offset_T_22"} : (i16) -> i1
    %322 = comb.extract %io_in_bits_data_4 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_38"} : (i16) -> i1
    %323 = comb.extract %io_in_bits_data_4 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_39"} : (i16) -> i3
    %324 = comb.extract %io_in_bits_data_5 from 15 {sv.namehint = "_brOffset_rvi_offset_T_16"} : (i16) -> i1
    %325 = comb.extract %io_in_bits_data_4 from 12 : (i16) -> i4
    %326 = comb.extract %io_in_bits_data_5 from 0 : (i16) -> i4
    %327 = comb.extract %io_in_bits_data_5 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_18"} : (i16) -> i1
    %328 = comb.extract %io_in_bits_data_5 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_19"} : (i16) -> i10
    %329 = comb.replicate %316 : (i1) -> i10
    %330 = comb.concat %329, %317, %318, %319, %320, %321, %322, %323 : i10, i1, i2, i1, i1, i1, i1, i3
    %331 = comb.concat %324, %326, %325, %327, %328 : i1, i4, i4, i1, i10
    %332 = comb.mux bin %285, %330, %331 : i20
    %333 = comb.extract %332 from 19 {sv.namehint = "jalOffset_signBit_14"} : (i20) -> i1
    %334 = comb.extract %io_in_bits_data_4 from 5 {sv.namehint = "_brOffset_rvc_offset_T_21"} : (i16) -> i2
    %335 = comb.extract %io_in_bits_data_4 from 10 {sv.namehint = "_brOffset_rvc_offset_T_23"} : (i16) -> i2
    %336 = comb.extract %io_in_bits_data_4 from 3 {sv.namehint = "_brOffset_rvc_offset_T_24"} : (i16) -> i2
    %337 = comb.extract %io_in_bits_data_5 from 9 {sv.namehint = "_brOffset_rvi_offset_T_18"} : (i16) -> i6
    %338 = comb.extract %io_in_bits_data_4 from 8 {sv.namehint = "_brOffset_rvi_offset_T_19"} : (i16) -> i4
    %339 = comb.replicate %316 : (i1) -> i5
    %340 = comb.concat %339, %334, %321, %335, %336 : i5, i2, i1, i2, i2
    %341 = comb.concat %324, %320, %337, %338 : i1, i1, i6, i4
    %342 = comb.mux bin %285, %340, %341 : i12
    %343 = comb.extract %342 from 11 {sv.namehint = "brOffset_signBit_14"} : (i12) -> i1
    %344 = comb.icmp bin eq %315, %c1_i2 {sv.namehint = "_io_out_jumpOffset_4_T"} : i2
    %345 = comb.replicate %343 : (i1) -> i51
    %346 = comb.concat %345, %342 : i51, i12
    %347 = comb.replicate %333 : (i1) -> i43
    %348 = comb.concat %347, %332 : i43, i20
    %349 = comb.mux bin %344, %346, %348 : i63
    %350 = comb.concat %349, %false {sv.namehint = "io_out_jumpOffset_4"} : i63, i1
    %351 = comb.extract %io_in_bits_data_5 from 0 {sv.namehint = "_isCall_T_51"} : (i16) -> i2
    %352 = comb.icmp bin ne %351, %c-1_i2 {sv.namehint = "currentIsRVC_5"} : i2
    %353 = comb.extract %io_in_bits_data_5 from 13 : (i16) -> i3
    %354 = comb.extract %io_in_bits_data_5 from 0 : (i16) -> i12
    %355 = comb.concat %353, %354 : i3, i12
    %356 = comb.icmp bin eq %355, %c-16382_i15 {sv.namehint = "_brType_T_101"} : i15
    %357 = comb.extract %io_in_bits_data_5 from 13 : (i16) -> i3
    %358 = comb.extract %io_in_bits_data_5 from 0 : (i16) -> i2
    %359 = comb.concat %357, %358 : i3, i2
    %360 = comb.icmp bin eq %359, %c-11_i5 {sv.namehint = "_brType_T_103"} : i5
    %361 = comb.extract %io_in_bits_data_5 from 13 : (i16) -> i3
    %362 = comb.extract %io_in_bits_data_5 from 0 : (i16) -> i7
    %363 = comb.concat %361, %362 : i3, i7
    %364 = comb.icmp bin eq %363, %c-510_i10 {sv.namehint = "_brType_T_105"} : i10
    %365 = comb.extract %io_in_bits_data_5 from 14 : (i16) -> i2
    %366 = comb.extract %io_in_bits_data_5 from 0 : (i16) -> i2
    %367 = comb.concat %365, %366 : i2, i2
    %368 = comb.icmp bin eq %367, %c-3_i4 {sv.namehint = "_brType_T_107"} : i4
    %369 = comb.extract %io_in_bits_data_5 from 0 : (i16) -> i7
    %370 = comb.icmp bin eq %369, %c-17_i7 {sv.namehint = "_brType_T_109"} : i7
    %371 = comb.extract %io_in_bits_data_5 from 12 : (i16) -> i3
    %372 = comb.extract %io_in_bits_data_5 from 0 : (i16) -> i7
    %373 = comb.concat %371, %372 : i3, i7
    %374 = comb.icmp bin eq %373, %c103_i10 {sv.namehint = "_brType_T_111"} : i10
    %375 = comb.icmp bin eq %369, %c-29_i7 {sv.namehint = "_brType_T_114"} : i7
    %376 = comb.concat %false, %375 : i1, i1
    %377 = comb.mux bin %374, %c-1_i2, %376 {sv.namehint = "_brType_T_115"} : i2
    %378 = comb.mux bin %370, %c-2_i2, %377 {sv.namehint = "_brType_T_116"} : i2
    %379 = comb.mux bin %368, %c1_i2, %378 {sv.namehint = "_brType_T_117"} : i2
    %380 = comb.mux bin %364, %c-1_i2, %379 {sv.namehint = "_brType_T_118"} : i2
    %381 = comb.mux bin %360, %c-2_i2, %380 {sv.namehint = "_brType_T_119"} : i2
    %382 = comb.mux bin %356, %c0_i2, %381 {sv.namehint = "brType_5"} : i2
    %383 = comb.extract %io_in_bits_data_5 from 12 {sv.namehint = "_brOffset_rvc_offset_T_25"} : (i16) -> i1
    %384 = comb.extract %io_in_bits_data_5 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_41"} : (i16) -> i1
    %385 = comb.extract %io_in_bits_data_5 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_42"} : (i16) -> i2
    %386 = comb.extract %io_in_bits_data_5 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_43"} : (i16) -> i1
    %387 = comb.extract %io_in_bits_data_5 from 7 {sv.namehint = "_brOffset_rvi_offset_T_21"} : (i16) -> i1
    %388 = comb.extract %io_in_bits_data_5 from 2 {sv.namehint = "_brOffset_rvc_offset_T_27"} : (i16) -> i1
    %389 = comb.extract %io_in_bits_data_5 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_46"} : (i16) -> i1
    %390 = comb.extract %io_in_bits_data_5 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_47"} : (i16) -> i3
    %391 = comb.extract %io_in_bits_data_6 from 15 {sv.namehint = "_brOffset_rvi_offset_T_20"} : (i16) -> i1
    %392 = comb.extract %io_in_bits_data_5 from 12 : (i16) -> i4
    %393 = comb.extract %io_in_bits_data_6 from 0 : (i16) -> i4
    %394 = comb.extract %io_in_bits_data_6 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_22"} : (i16) -> i1
    %395 = comb.extract %io_in_bits_data_6 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_23"} : (i16) -> i10
    %396 = comb.replicate %383 : (i1) -> i10
    %397 = comb.concat %396, %384, %385, %386, %387, %388, %389, %390 : i10, i1, i2, i1, i1, i1, i1, i3
    %398 = comb.concat %391, %393, %392, %394, %395 : i1, i4, i4, i1, i10
    %399 = comb.mux bin %352, %397, %398 : i20
    %400 = comb.extract %399 from 19 {sv.namehint = "jalOffset_signBit_17"} : (i20) -> i1
    %401 = comb.extract %io_in_bits_data_5 from 5 {sv.namehint = "_brOffset_rvc_offset_T_26"} : (i16) -> i2
    %402 = comb.extract %io_in_bits_data_5 from 10 {sv.namehint = "_brOffset_rvc_offset_T_28"} : (i16) -> i2
    %403 = comb.extract %io_in_bits_data_5 from 3 {sv.namehint = "_brOffset_rvc_offset_T_29"} : (i16) -> i2
    %404 = comb.extract %io_in_bits_data_6 from 9 {sv.namehint = "_brOffset_rvi_offset_T_22"} : (i16) -> i6
    %405 = comb.extract %io_in_bits_data_5 from 8 {sv.namehint = "_brOffset_rvi_offset_T_23"} : (i16) -> i4
    %406 = comb.replicate %383 : (i1) -> i5
    %407 = comb.concat %406, %401, %388, %402, %403 : i5, i2, i1, i2, i2
    %408 = comb.concat %391, %387, %404, %405 : i1, i1, i6, i4
    %409 = comb.mux bin %352, %407, %408 : i12
    %410 = comb.extract %409 from 11 {sv.namehint = "brOffset_signBit_17"} : (i12) -> i1
    %411 = comb.icmp bin eq %382, %c1_i2 {sv.namehint = "_io_out_jumpOffset_5_T"} : i2
    %412 = comb.replicate %410 : (i1) -> i51
    %413 = comb.concat %412, %409 : i51, i12
    %414 = comb.replicate %400 : (i1) -> i43
    %415 = comb.concat %414, %399 : i43, i20
    %416 = comb.mux bin %411, %413, %415 : i63
    %417 = comb.concat %416, %false {sv.namehint = "io_out_jumpOffset_5"} : i63, i1
    %418 = comb.extract %io_in_bits_data_6 from 0 {sv.namehint = "_isCall_T_61"} : (i16) -> i2
    %419 = comb.icmp bin ne %418, %c-1_i2 {sv.namehint = "currentIsRVC_6"} : i2
    %420 = comb.extract %io_in_bits_data_6 from 13 : (i16) -> i3
    %421 = comb.extract %io_in_bits_data_6 from 0 : (i16) -> i12
    %422 = comb.concat %420, %421 : i3, i12
    %423 = comb.icmp bin eq %422, %c-16382_i15 {sv.namehint = "_brType_T_121"} : i15
    %424 = comb.extract %io_in_bits_data_6 from 13 : (i16) -> i3
    %425 = comb.extract %io_in_bits_data_6 from 0 : (i16) -> i2
    %426 = comb.concat %424, %425 : i3, i2
    %427 = comb.icmp bin eq %426, %c-11_i5 {sv.namehint = "_brType_T_123"} : i5
    %428 = comb.extract %io_in_bits_data_6 from 13 : (i16) -> i3
    %429 = comb.extract %io_in_bits_data_6 from 0 : (i16) -> i7
    %430 = comb.concat %428, %429 : i3, i7
    %431 = comb.icmp bin eq %430, %c-510_i10 {sv.namehint = "_brType_T_125"} : i10
    %432 = comb.extract %io_in_bits_data_6 from 14 : (i16) -> i2
    %433 = comb.extract %io_in_bits_data_6 from 0 : (i16) -> i2
    %434 = comb.concat %432, %433 : i2, i2
    %435 = comb.icmp bin eq %434, %c-3_i4 {sv.namehint = "_brType_T_127"} : i4
    %436 = comb.extract %io_in_bits_data_6 from 0 : (i16) -> i7
    %437 = comb.icmp bin eq %436, %c-17_i7 {sv.namehint = "_brType_T_129"} : i7
    %438 = comb.extract %io_in_bits_data_6 from 12 : (i16) -> i3
    %439 = comb.extract %io_in_bits_data_6 from 0 : (i16) -> i7
    %440 = comb.concat %438, %439 : i3, i7
    %441 = comb.icmp bin eq %440, %c103_i10 {sv.namehint = "_brType_T_131"} : i10
    %442 = comb.icmp bin eq %436, %c-29_i7 {sv.namehint = "_brType_T_134"} : i7
    %443 = comb.concat %false, %442 : i1, i1
    %444 = comb.mux bin %441, %c-1_i2, %443 {sv.namehint = "_brType_T_135"} : i2
    %445 = comb.mux bin %437, %c-2_i2, %444 {sv.namehint = "_brType_T_136"} : i2
    %446 = comb.mux bin %435, %c1_i2, %445 {sv.namehint = "_brType_T_137"} : i2
    %447 = comb.mux bin %431, %c-1_i2, %446 {sv.namehint = "_brType_T_138"} : i2
    %448 = comb.mux bin %427, %c-2_i2, %447 {sv.namehint = "_brType_T_139"} : i2
    %449 = comb.mux bin %423, %c0_i2, %448 {sv.namehint = "brType_6"} : i2
    %450 = comb.extract %io_in_bits_data_6 from 12 {sv.namehint = "_brOffset_rvc_offset_T_30"} : (i16) -> i1
    %451 = comb.extract %io_in_bits_data_6 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_49"} : (i16) -> i1
    %452 = comb.extract %io_in_bits_data_6 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_50"} : (i16) -> i2
    %453 = comb.extract %io_in_bits_data_6 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_51"} : (i16) -> i1
    %454 = comb.extract %io_in_bits_data_6 from 7 {sv.namehint = "_brOffset_rvi_offset_T_25"} : (i16) -> i1
    %455 = comb.extract %io_in_bits_data_6 from 2 {sv.namehint = "_brOffset_rvc_offset_T_32"} : (i16) -> i1
    %456 = comb.extract %io_in_bits_data_6 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_54"} : (i16) -> i1
    %457 = comb.extract %io_in_bits_data_6 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_55"} : (i16) -> i3
    %458 = comb.extract %io_in_bits_data_7 from 15 {sv.namehint = "_brOffset_rvi_offset_T_24"} : (i16) -> i1
    %459 = comb.extract %io_in_bits_data_6 from 12 : (i16) -> i4
    %460 = comb.extract %io_in_bits_data_7 from 0 : (i16) -> i4
    %461 = comb.extract %io_in_bits_data_7 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_26"} : (i16) -> i1
    %462 = comb.extract %io_in_bits_data_7 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_27"} : (i16) -> i10
    %463 = comb.replicate %450 : (i1) -> i10
    %464 = comb.concat %463, %451, %452, %453, %454, %455, %456, %457 : i10, i1, i2, i1, i1, i1, i1, i3
    %465 = comb.concat %458, %460, %459, %461, %462 : i1, i4, i4, i1, i10
    %466 = comb.mux bin %419, %464, %465 : i20
    %467 = comb.extract %466 from 19 {sv.namehint = "jalOffset_signBit_20"} : (i20) -> i1
    %468 = comb.extract %io_in_bits_data_6 from 5 {sv.namehint = "_brOffset_rvc_offset_T_31"} : (i16) -> i2
    %469 = comb.extract %io_in_bits_data_6 from 10 {sv.namehint = "_brOffset_rvc_offset_T_33"} : (i16) -> i2
    %470 = comb.extract %io_in_bits_data_6 from 3 {sv.namehint = "_brOffset_rvc_offset_T_34"} : (i16) -> i2
    %471 = comb.extract %io_in_bits_data_7 from 9 {sv.namehint = "_brOffset_rvi_offset_T_26"} : (i16) -> i6
    %472 = comb.extract %io_in_bits_data_6 from 8 {sv.namehint = "_brOffset_rvi_offset_T_27"} : (i16) -> i4
    %473 = comb.replicate %450 : (i1) -> i5
    %474 = comb.concat %473, %468, %455, %469, %470 : i5, i2, i1, i2, i2
    %475 = comb.concat %458, %454, %471, %472 : i1, i1, i6, i4
    %476 = comb.mux bin %419, %474, %475 : i12
    %477 = comb.extract %476 from 11 {sv.namehint = "brOffset_signBit_20"} : (i12) -> i1
    %478 = comb.icmp bin eq %449, %c1_i2 {sv.namehint = "_io_out_jumpOffset_6_T"} : i2
    %479 = comb.replicate %477 : (i1) -> i51
    %480 = comb.concat %479, %476 : i51, i12
    %481 = comb.replicate %467 : (i1) -> i43
    %482 = comb.concat %481, %466 : i43, i20
    %483 = comb.mux bin %478, %480, %482 : i63
    %484 = comb.concat %483, %false {sv.namehint = "io_out_jumpOffset_6"} : i63, i1
    %485 = comb.extract %io_in_bits_data_7 from 0 {sv.namehint = "_isCall_T_71"} : (i16) -> i2
    %486 = comb.icmp bin ne %485, %c-1_i2 {sv.namehint = "currentIsRVC_7"} : i2
    %487 = comb.extract %io_in_bits_data_7 from 13 : (i16) -> i3
    %488 = comb.extract %io_in_bits_data_7 from 0 : (i16) -> i12
    %489 = comb.concat %487, %488 : i3, i12
    %490 = comb.icmp bin eq %489, %c-16382_i15 {sv.namehint = "_brType_T_141"} : i15
    %491 = comb.extract %io_in_bits_data_7 from 13 : (i16) -> i3
    %492 = comb.extract %io_in_bits_data_7 from 0 : (i16) -> i2
    %493 = comb.concat %491, %492 : i3, i2
    %494 = comb.icmp bin eq %493, %c-11_i5 {sv.namehint = "_brType_T_143"} : i5
    %495 = comb.extract %io_in_bits_data_7 from 13 : (i16) -> i3
    %496 = comb.extract %io_in_bits_data_7 from 0 : (i16) -> i7
    %497 = comb.concat %495, %496 : i3, i7
    %498 = comb.icmp bin eq %497, %c-510_i10 {sv.namehint = "_brType_T_145"} : i10
    %499 = comb.extract %io_in_bits_data_7 from 14 : (i16) -> i2
    %500 = comb.extract %io_in_bits_data_7 from 0 : (i16) -> i2
    %501 = comb.concat %499, %500 : i2, i2
    %502 = comb.icmp bin eq %501, %c-3_i4 {sv.namehint = "_brType_T_147"} : i4
    %503 = comb.extract %io_in_bits_data_7 from 0 : (i16) -> i7
    %504 = comb.icmp bin eq %503, %c-17_i7 {sv.namehint = "_brType_T_149"} : i7
    %505 = comb.extract %io_in_bits_data_7 from 12 : (i16) -> i3
    %506 = comb.extract %io_in_bits_data_7 from 0 : (i16) -> i7
    %507 = comb.concat %505, %506 : i3, i7
    %508 = comb.icmp bin eq %507, %c103_i10 {sv.namehint = "_brType_T_151"} : i10
    %509 = comb.icmp bin eq %503, %c-29_i7 {sv.namehint = "_brType_T_154"} : i7
    %510 = comb.concat %false, %509 : i1, i1
    %511 = comb.mux bin %508, %c-1_i2, %510 {sv.namehint = "_brType_T_155"} : i2
    %512 = comb.mux bin %504, %c-2_i2, %511 {sv.namehint = "_brType_T_156"} : i2
    %513 = comb.mux bin %502, %c1_i2, %512 {sv.namehint = "_brType_T_157"} : i2
    %514 = comb.mux bin %498, %c-1_i2, %513 {sv.namehint = "_brType_T_158"} : i2
    %515 = comb.mux bin %494, %c-2_i2, %514 {sv.namehint = "_brType_T_159"} : i2
    %516 = comb.mux bin %490, %c0_i2, %515 {sv.namehint = "brType_7"} : i2
    %517 = comb.extract %io_in_bits_data_7 from 12 {sv.namehint = "_brOffset_rvc_offset_T_35"} : (i16) -> i1
    %518 = comb.extract %io_in_bits_data_7 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_57"} : (i16) -> i1
    %519 = comb.extract %io_in_bits_data_7 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_58"} : (i16) -> i2
    %520 = comb.extract %io_in_bits_data_7 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_59"} : (i16) -> i1
    %521 = comb.extract %io_in_bits_data_7 from 7 {sv.namehint = "_brOffset_rvi_offset_T_29"} : (i16) -> i1
    %522 = comb.extract %io_in_bits_data_7 from 2 {sv.namehint = "_brOffset_rvc_offset_T_37"} : (i16) -> i1
    %523 = comb.extract %io_in_bits_data_7 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_62"} : (i16) -> i1
    %524 = comb.extract %io_in_bits_data_7 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_63"} : (i16) -> i3
    %525 = comb.extract %io_in_bits_data_8 from 15 {sv.namehint = "_brOffset_rvi_offset_T_28"} : (i16) -> i1
    %526 = comb.extract %io_in_bits_data_7 from 12 : (i16) -> i4
    %527 = comb.extract %io_in_bits_data_8 from 0 : (i16) -> i4
    %528 = comb.extract %io_in_bits_data_8 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_30"} : (i16) -> i1
    %529 = comb.extract %io_in_bits_data_8 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_31"} : (i16) -> i10
    %530 = comb.replicate %517 : (i1) -> i10
    %531 = comb.concat %530, %518, %519, %520, %521, %522, %523, %524 : i10, i1, i2, i1, i1, i1, i1, i3
    %532 = comb.concat %525, %527, %526, %528, %529 : i1, i4, i4, i1, i10
    %533 = comb.mux bin %486, %531, %532 : i20
    %534 = comb.extract %533 from 19 {sv.namehint = "jalOffset_signBit_23"} : (i20) -> i1
    %535 = comb.extract %io_in_bits_data_7 from 5 {sv.namehint = "_brOffset_rvc_offset_T_36"} : (i16) -> i2
    %536 = comb.extract %io_in_bits_data_7 from 10 {sv.namehint = "_brOffset_rvc_offset_T_38"} : (i16) -> i2
    %537 = comb.extract %io_in_bits_data_7 from 3 {sv.namehint = "_brOffset_rvc_offset_T_39"} : (i16) -> i2
    %538 = comb.extract %io_in_bits_data_8 from 9 {sv.namehint = "_brOffset_rvi_offset_T_30"} : (i16) -> i6
    %539 = comb.extract %io_in_bits_data_7 from 8 {sv.namehint = "_brOffset_rvi_offset_T_31"} : (i16) -> i4
    %540 = comb.replicate %517 : (i1) -> i5
    %541 = comb.concat %540, %535, %522, %536, %537 : i5, i2, i1, i2, i2
    %542 = comb.concat %525, %521, %538, %539 : i1, i1, i6, i4
    %543 = comb.mux bin %486, %541, %542 : i12
    %544 = comb.extract %543 from 11 {sv.namehint = "brOffset_signBit_23"} : (i12) -> i1
    %545 = comb.icmp bin eq %516, %c1_i2 {sv.namehint = "_io_out_jumpOffset_7_T"} : i2
    %546 = comb.replicate %544 : (i1) -> i51
    %547 = comb.concat %546, %543 : i51, i12
    %548 = comb.replicate %534 : (i1) -> i43
    %549 = comb.concat %548, %533 : i43, i20
    %550 = comb.mux bin %545, %547, %549 : i63
    %551 = comb.concat %550, %false {sv.namehint = "io_out_jumpOffset_7"} : i63, i1
    %552 = comb.extract %io_in_bits_data_8 from 0 {sv.namehint = "_isCall_T_81"} : (i16) -> i2
    %553 = comb.icmp bin ne %552, %c-1_i2 {sv.namehint = "currentIsRVC_8"} : i2
    %554 = comb.extract %io_in_bits_data_8 from 13 : (i16) -> i3
    %555 = comb.extract %io_in_bits_data_8 from 0 : (i16) -> i12
    %556 = comb.concat %554, %555 : i3, i12
    %557 = comb.icmp bin eq %556, %c-16382_i15 {sv.namehint = "_brType_T_161"} : i15
    %558 = comb.extract %io_in_bits_data_8 from 13 : (i16) -> i3
    %559 = comb.extract %io_in_bits_data_8 from 0 : (i16) -> i2
    %560 = comb.concat %558, %559 : i3, i2
    %561 = comb.icmp bin eq %560, %c-11_i5 {sv.namehint = "_brType_T_163"} : i5
    %562 = comb.extract %io_in_bits_data_8 from 13 : (i16) -> i3
    %563 = comb.extract %io_in_bits_data_8 from 0 : (i16) -> i7
    %564 = comb.concat %562, %563 : i3, i7
    %565 = comb.icmp bin eq %564, %c-510_i10 {sv.namehint = "_brType_T_165"} : i10
    %566 = comb.extract %io_in_bits_data_8 from 14 : (i16) -> i2
    %567 = comb.extract %io_in_bits_data_8 from 0 : (i16) -> i2
    %568 = comb.concat %566, %567 : i2, i2
    %569 = comb.icmp bin eq %568, %c-3_i4 {sv.namehint = "_brType_T_167"} : i4
    %570 = comb.extract %io_in_bits_data_8 from 0 : (i16) -> i7
    %571 = comb.icmp bin eq %570, %c-17_i7 {sv.namehint = "_brType_T_169"} : i7
    %572 = comb.extract %io_in_bits_data_8 from 12 : (i16) -> i3
    %573 = comb.extract %io_in_bits_data_8 from 0 : (i16) -> i7
    %574 = comb.concat %572, %573 : i3, i7
    %575 = comb.icmp bin eq %574, %c103_i10 {sv.namehint = "_brType_T_171"} : i10
    %576 = comb.icmp bin eq %570, %c-29_i7 {sv.namehint = "_brType_T_174"} : i7
    %577 = comb.concat %false, %576 : i1, i1
    %578 = comb.mux bin %575, %c-1_i2, %577 {sv.namehint = "_brType_T_175"} : i2
    %579 = comb.mux bin %571, %c-2_i2, %578 {sv.namehint = "_brType_T_176"} : i2
    %580 = comb.mux bin %569, %c1_i2, %579 {sv.namehint = "_brType_T_177"} : i2
    %581 = comb.mux bin %565, %c-1_i2, %580 {sv.namehint = "_brType_T_178"} : i2
    %582 = comb.mux bin %561, %c-2_i2, %581 {sv.namehint = "_brType_T_179"} : i2
    %583 = comb.mux bin %557, %c0_i2, %582 {sv.namehint = "brType_8"} : i2
    %584 = comb.extract %io_in_bits_data_8 from 12 {sv.namehint = "_brOffset_rvc_offset_T_40"} : (i16) -> i1
    %585 = comb.extract %io_in_bits_data_8 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_65"} : (i16) -> i1
    %586 = comb.extract %io_in_bits_data_8 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_66"} : (i16) -> i2
    %587 = comb.extract %io_in_bits_data_8 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_67"} : (i16) -> i1
    %588 = comb.extract %io_in_bits_data_8 from 7 {sv.namehint = "_brOffset_rvi_offset_T_33"} : (i16) -> i1
    %589 = comb.extract %io_in_bits_data_8 from 2 {sv.namehint = "_brOffset_rvc_offset_T_42"} : (i16) -> i1
    %590 = comb.extract %io_in_bits_data_8 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_70"} : (i16) -> i1
    %591 = comb.extract %io_in_bits_data_8 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_71"} : (i16) -> i3
    %592 = comb.extract %io_in_bits_data_9 from 15 {sv.namehint = "_brOffset_rvi_offset_T_32"} : (i16) -> i1
    %593 = comb.extract %io_in_bits_data_8 from 12 : (i16) -> i4
    %594 = comb.extract %io_in_bits_data_9 from 0 : (i16) -> i4
    %595 = comb.extract %io_in_bits_data_9 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_34"} : (i16) -> i1
    %596 = comb.extract %io_in_bits_data_9 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_35"} : (i16) -> i10
    %597 = comb.replicate %584 : (i1) -> i10
    %598 = comb.concat %597, %585, %586, %587, %588, %589, %590, %591 : i10, i1, i2, i1, i1, i1, i1, i3
    %599 = comb.concat %592, %594, %593, %595, %596 : i1, i4, i4, i1, i10
    %600 = comb.mux bin %553, %598, %599 : i20
    %601 = comb.extract %600 from 19 {sv.namehint = "jalOffset_signBit_26"} : (i20) -> i1
    %602 = comb.extract %io_in_bits_data_8 from 5 {sv.namehint = "_brOffset_rvc_offset_T_41"} : (i16) -> i2
    %603 = comb.extract %io_in_bits_data_8 from 10 {sv.namehint = "_brOffset_rvc_offset_T_43"} : (i16) -> i2
    %604 = comb.extract %io_in_bits_data_8 from 3 {sv.namehint = "_brOffset_rvc_offset_T_44"} : (i16) -> i2
    %605 = comb.extract %io_in_bits_data_9 from 9 {sv.namehint = "_brOffset_rvi_offset_T_34"} : (i16) -> i6
    %606 = comb.extract %io_in_bits_data_8 from 8 {sv.namehint = "_brOffset_rvi_offset_T_35"} : (i16) -> i4
    %607 = comb.replicate %584 : (i1) -> i5
    %608 = comb.concat %607, %602, %589, %603, %604 : i5, i2, i1, i2, i2
    %609 = comb.concat %592, %588, %605, %606 : i1, i1, i6, i4
    %610 = comb.mux bin %553, %608, %609 : i12
    %611 = comb.extract %610 from 11 {sv.namehint = "brOffset_signBit_26"} : (i12) -> i1
    %612 = comb.icmp bin eq %583, %c1_i2 {sv.namehint = "_io_out_jumpOffset_8_T"} : i2
    %613 = comb.replicate %611 : (i1) -> i51
    %614 = comb.concat %613, %610 : i51, i12
    %615 = comb.replicate %601 : (i1) -> i43
    %616 = comb.concat %615, %600 : i43, i20
    %617 = comb.mux bin %612, %614, %616 : i63
    %618 = comb.concat %617, %false {sv.namehint = "io_out_jumpOffset_8"} : i63, i1
    %619 = comb.extract %io_in_bits_data_9 from 0 {sv.namehint = "_isCall_T_91"} : (i16) -> i2
    %620 = comb.icmp bin ne %619, %c-1_i2 {sv.namehint = "currentIsRVC_9"} : i2
    %621 = comb.extract %io_in_bits_data_9 from 13 : (i16) -> i3
    %622 = comb.extract %io_in_bits_data_9 from 0 : (i16) -> i12
    %623 = comb.concat %621, %622 : i3, i12
    %624 = comb.icmp bin eq %623, %c-16382_i15 {sv.namehint = "_brType_T_181"} : i15
    %625 = comb.extract %io_in_bits_data_9 from 13 : (i16) -> i3
    %626 = comb.extract %io_in_bits_data_9 from 0 : (i16) -> i2
    %627 = comb.concat %625, %626 : i3, i2
    %628 = comb.icmp bin eq %627, %c-11_i5 {sv.namehint = "_brType_T_183"} : i5
    %629 = comb.extract %io_in_bits_data_9 from 13 : (i16) -> i3
    %630 = comb.extract %io_in_bits_data_9 from 0 : (i16) -> i7
    %631 = comb.concat %629, %630 : i3, i7
    %632 = comb.icmp bin eq %631, %c-510_i10 {sv.namehint = "_brType_T_185"} : i10
    %633 = comb.extract %io_in_bits_data_9 from 14 : (i16) -> i2
    %634 = comb.extract %io_in_bits_data_9 from 0 : (i16) -> i2
    %635 = comb.concat %633, %634 : i2, i2
    %636 = comb.icmp bin eq %635, %c-3_i4 {sv.namehint = "_brType_T_187"} : i4
    %637 = comb.extract %io_in_bits_data_9 from 0 : (i16) -> i7
    %638 = comb.icmp bin eq %637, %c-17_i7 {sv.namehint = "_brType_T_189"} : i7
    %639 = comb.extract %io_in_bits_data_9 from 12 : (i16) -> i3
    %640 = comb.extract %io_in_bits_data_9 from 0 : (i16) -> i7
    %641 = comb.concat %639, %640 : i3, i7
    %642 = comb.icmp bin eq %641, %c103_i10 {sv.namehint = "_brType_T_191"} : i10
    %643 = comb.icmp bin eq %637, %c-29_i7 {sv.namehint = "_brType_T_194"} : i7
    %644 = comb.concat %false, %643 : i1, i1
    %645 = comb.mux bin %642, %c-1_i2, %644 {sv.namehint = "_brType_T_195"} : i2
    %646 = comb.mux bin %638, %c-2_i2, %645 {sv.namehint = "_brType_T_196"} : i2
    %647 = comb.mux bin %636, %c1_i2, %646 {sv.namehint = "_brType_T_197"} : i2
    %648 = comb.mux bin %632, %c-1_i2, %647 {sv.namehint = "_brType_T_198"} : i2
    %649 = comb.mux bin %628, %c-2_i2, %648 {sv.namehint = "_brType_T_199"} : i2
    %650 = comb.mux bin %624, %c0_i2, %649 {sv.namehint = "brType_9"} : i2
    %651 = comb.extract %io_in_bits_data_9 from 12 {sv.namehint = "_brOffset_rvc_offset_T_45"} : (i16) -> i1
    %652 = comb.extract %io_in_bits_data_9 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_73"} : (i16) -> i1
    %653 = comb.extract %io_in_bits_data_9 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_74"} : (i16) -> i2
    %654 = comb.extract %io_in_bits_data_9 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_75"} : (i16) -> i1
    %655 = comb.extract %io_in_bits_data_9 from 7 {sv.namehint = "_brOffset_rvi_offset_T_37"} : (i16) -> i1
    %656 = comb.extract %io_in_bits_data_9 from 2 {sv.namehint = "_brOffset_rvc_offset_T_47"} : (i16) -> i1
    %657 = comb.extract %io_in_bits_data_9 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_78"} : (i16) -> i1
    %658 = comb.extract %io_in_bits_data_9 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_79"} : (i16) -> i3
    %659 = comb.extract %io_in_bits_data_10 from 15 {sv.namehint = "_brOffset_rvi_offset_T_36"} : (i16) -> i1
    %660 = comb.extract %io_in_bits_data_9 from 12 : (i16) -> i4
    %661 = comb.extract %io_in_bits_data_10 from 0 : (i16) -> i4
    %662 = comb.extract %io_in_bits_data_10 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_38"} : (i16) -> i1
    %663 = comb.extract %io_in_bits_data_10 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_39"} : (i16) -> i10
    %664 = comb.replicate %651 : (i1) -> i10
    %665 = comb.concat %664, %652, %653, %654, %655, %656, %657, %658 : i10, i1, i2, i1, i1, i1, i1, i3
    %666 = comb.concat %659, %661, %660, %662, %663 : i1, i4, i4, i1, i10
    %667 = comb.mux bin %620, %665, %666 : i20
    %668 = comb.extract %667 from 19 {sv.namehint = "jalOffset_signBit_29"} : (i20) -> i1
    %669 = comb.extract %io_in_bits_data_9 from 5 {sv.namehint = "_brOffset_rvc_offset_T_46"} : (i16) -> i2
    %670 = comb.extract %io_in_bits_data_9 from 10 {sv.namehint = "_brOffset_rvc_offset_T_48"} : (i16) -> i2
    %671 = comb.extract %io_in_bits_data_9 from 3 {sv.namehint = "_brOffset_rvc_offset_T_49"} : (i16) -> i2
    %672 = comb.extract %io_in_bits_data_10 from 9 {sv.namehint = "_brOffset_rvi_offset_T_38"} : (i16) -> i6
    %673 = comb.extract %io_in_bits_data_9 from 8 {sv.namehint = "_brOffset_rvi_offset_T_39"} : (i16) -> i4
    %674 = comb.replicate %651 : (i1) -> i5
    %675 = comb.concat %674, %669, %656, %670, %671 : i5, i2, i1, i2, i2
    %676 = comb.concat %659, %655, %672, %673 : i1, i1, i6, i4
    %677 = comb.mux bin %620, %675, %676 : i12
    %678 = comb.extract %677 from 11 {sv.namehint = "brOffset_signBit_29"} : (i12) -> i1
    %679 = comb.icmp bin eq %650, %c1_i2 {sv.namehint = "_io_out_jumpOffset_9_T"} : i2
    %680 = comb.replicate %678 : (i1) -> i51
    %681 = comb.concat %680, %677 : i51, i12
    %682 = comb.replicate %668 : (i1) -> i43
    %683 = comb.concat %682, %667 : i43, i20
    %684 = comb.mux bin %679, %681, %683 : i63
    %685 = comb.concat %684, %false {sv.namehint = "io_out_jumpOffset_9"} : i63, i1
    %686 = comb.extract %io_in_bits_data_10 from 0 {sv.namehint = "_isCall_T_101"} : (i16) -> i2
    %687 = comb.icmp bin ne %686, %c-1_i2 {sv.namehint = "currentIsRVC_10"} : i2
    %688 = comb.extract %io_in_bits_data_10 from 13 : (i16) -> i3
    %689 = comb.extract %io_in_bits_data_10 from 0 : (i16) -> i12
    %690 = comb.concat %688, %689 : i3, i12
    %691 = comb.icmp bin eq %690, %c-16382_i15 {sv.namehint = "_brType_T_201"} : i15
    %692 = comb.extract %io_in_bits_data_10 from 13 : (i16) -> i3
    %693 = comb.extract %io_in_bits_data_10 from 0 : (i16) -> i2
    %694 = comb.concat %692, %693 : i3, i2
    %695 = comb.icmp bin eq %694, %c-11_i5 {sv.namehint = "_brType_T_203"} : i5
    %696 = comb.extract %io_in_bits_data_10 from 13 : (i16) -> i3
    %697 = comb.extract %io_in_bits_data_10 from 0 : (i16) -> i7
    %698 = comb.concat %696, %697 : i3, i7
    %699 = comb.icmp bin eq %698, %c-510_i10 {sv.namehint = "_brType_T_205"} : i10
    %700 = comb.extract %io_in_bits_data_10 from 14 : (i16) -> i2
    %701 = comb.extract %io_in_bits_data_10 from 0 : (i16) -> i2
    %702 = comb.concat %700, %701 : i2, i2
    %703 = comb.icmp bin eq %702, %c-3_i4 {sv.namehint = "_brType_T_207"} : i4
    %704 = comb.extract %io_in_bits_data_10 from 0 : (i16) -> i7
    %705 = comb.icmp bin eq %704, %c-17_i7 {sv.namehint = "_brType_T_209"} : i7
    %706 = comb.extract %io_in_bits_data_10 from 12 : (i16) -> i3
    %707 = comb.extract %io_in_bits_data_10 from 0 : (i16) -> i7
    %708 = comb.concat %706, %707 : i3, i7
    %709 = comb.icmp bin eq %708, %c103_i10 {sv.namehint = "_brType_T_211"} : i10
    %710 = comb.icmp bin eq %704, %c-29_i7 {sv.namehint = "_brType_T_214"} : i7
    %711 = comb.concat %false, %710 : i1, i1
    %712 = comb.mux bin %709, %c-1_i2, %711 {sv.namehint = "_brType_T_215"} : i2
    %713 = comb.mux bin %705, %c-2_i2, %712 {sv.namehint = "_brType_T_216"} : i2
    %714 = comb.mux bin %703, %c1_i2, %713 {sv.namehint = "_brType_T_217"} : i2
    %715 = comb.mux bin %699, %c-1_i2, %714 {sv.namehint = "_brType_T_218"} : i2
    %716 = comb.mux bin %695, %c-2_i2, %715 {sv.namehint = "_brType_T_219"} : i2
    %717 = comb.mux bin %691, %c0_i2, %716 {sv.namehint = "brType_10"} : i2
    %718 = comb.extract %io_in_bits_data_10 from 12 {sv.namehint = "_brOffset_rvc_offset_T_50"} : (i16) -> i1
    %719 = comb.extract %io_in_bits_data_10 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_81"} : (i16) -> i1
    %720 = comb.extract %io_in_bits_data_10 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_82"} : (i16) -> i2
    %721 = comb.extract %io_in_bits_data_10 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_83"} : (i16) -> i1
    %722 = comb.extract %io_in_bits_data_10 from 7 {sv.namehint = "_brOffset_rvi_offset_T_41"} : (i16) -> i1
    %723 = comb.extract %io_in_bits_data_10 from 2 {sv.namehint = "_brOffset_rvc_offset_T_52"} : (i16) -> i1
    %724 = comb.extract %io_in_bits_data_10 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_86"} : (i16) -> i1
    %725 = comb.extract %io_in_bits_data_10 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_87"} : (i16) -> i3
    %726 = comb.extract %io_in_bits_data_11 from 15 {sv.namehint = "_brOffset_rvi_offset_T_40"} : (i16) -> i1
    %727 = comb.extract %io_in_bits_data_10 from 12 : (i16) -> i4
    %728 = comb.extract %io_in_bits_data_11 from 0 : (i16) -> i4
    %729 = comb.extract %io_in_bits_data_11 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_42"} : (i16) -> i1
    %730 = comb.extract %io_in_bits_data_11 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_43"} : (i16) -> i10
    %731 = comb.replicate %718 : (i1) -> i10
    %732 = comb.concat %731, %719, %720, %721, %722, %723, %724, %725 : i10, i1, i2, i1, i1, i1, i1, i3
    %733 = comb.concat %726, %728, %727, %729, %730 : i1, i4, i4, i1, i10
    %734 = comb.mux bin %687, %732, %733 : i20
    %735 = comb.extract %734 from 19 {sv.namehint = "jalOffset_signBit_32"} : (i20) -> i1
    %736 = comb.extract %io_in_bits_data_10 from 5 {sv.namehint = "_brOffset_rvc_offset_T_51"} : (i16) -> i2
    %737 = comb.extract %io_in_bits_data_10 from 10 {sv.namehint = "_brOffset_rvc_offset_T_53"} : (i16) -> i2
    %738 = comb.extract %io_in_bits_data_10 from 3 {sv.namehint = "_brOffset_rvc_offset_T_54"} : (i16) -> i2
    %739 = comb.extract %io_in_bits_data_11 from 9 {sv.namehint = "_brOffset_rvi_offset_T_42"} : (i16) -> i6
    %740 = comb.extract %io_in_bits_data_10 from 8 {sv.namehint = "_brOffset_rvi_offset_T_43"} : (i16) -> i4
    %741 = comb.replicate %718 : (i1) -> i5
    %742 = comb.concat %741, %736, %723, %737, %738 : i5, i2, i1, i2, i2
    %743 = comb.concat %726, %722, %739, %740 : i1, i1, i6, i4
    %744 = comb.mux bin %687, %742, %743 : i12
    %745 = comb.extract %744 from 11 {sv.namehint = "brOffset_signBit_32"} : (i12) -> i1
    %746 = comb.icmp bin eq %717, %c1_i2 {sv.namehint = "_io_out_jumpOffset_10_T"} : i2
    %747 = comb.replicate %745 : (i1) -> i51
    %748 = comb.concat %747, %744 : i51, i12
    %749 = comb.replicate %735 : (i1) -> i43
    %750 = comb.concat %749, %734 : i43, i20
    %751 = comb.mux bin %746, %748, %750 : i63
    %752 = comb.concat %751, %false {sv.namehint = "io_out_jumpOffset_10"} : i63, i1
    %753 = comb.extract %io_in_bits_data_11 from 0 {sv.namehint = "_isCall_T_111"} : (i16) -> i2
    %754 = comb.icmp bin ne %753, %c-1_i2 {sv.namehint = "currentIsRVC_11"} : i2
    %755 = comb.extract %io_in_bits_data_11 from 13 : (i16) -> i3
    %756 = comb.extract %io_in_bits_data_11 from 0 : (i16) -> i12
    %757 = comb.concat %755, %756 : i3, i12
    %758 = comb.icmp bin eq %757, %c-16382_i15 {sv.namehint = "_brType_T_221"} : i15
    %759 = comb.extract %io_in_bits_data_11 from 13 : (i16) -> i3
    %760 = comb.extract %io_in_bits_data_11 from 0 : (i16) -> i2
    %761 = comb.concat %759, %760 : i3, i2
    %762 = comb.icmp bin eq %761, %c-11_i5 {sv.namehint = "_brType_T_223"} : i5
    %763 = comb.extract %io_in_bits_data_11 from 13 : (i16) -> i3
    %764 = comb.extract %io_in_bits_data_11 from 0 : (i16) -> i7
    %765 = comb.concat %763, %764 : i3, i7
    %766 = comb.icmp bin eq %765, %c-510_i10 {sv.namehint = "_brType_T_225"} : i10
    %767 = comb.extract %io_in_bits_data_11 from 14 : (i16) -> i2
    %768 = comb.extract %io_in_bits_data_11 from 0 : (i16) -> i2
    %769 = comb.concat %767, %768 : i2, i2
    %770 = comb.icmp bin eq %769, %c-3_i4 {sv.namehint = "_brType_T_227"} : i4
    %771 = comb.extract %io_in_bits_data_11 from 0 : (i16) -> i7
    %772 = comb.icmp bin eq %771, %c-17_i7 {sv.namehint = "_brType_T_229"} : i7
    %773 = comb.extract %io_in_bits_data_11 from 12 : (i16) -> i3
    %774 = comb.extract %io_in_bits_data_11 from 0 : (i16) -> i7
    %775 = comb.concat %773, %774 : i3, i7
    %776 = comb.icmp bin eq %775, %c103_i10 {sv.namehint = "_brType_T_231"} : i10
    %777 = comb.icmp bin eq %771, %c-29_i7 {sv.namehint = "_brType_T_234"} : i7
    %778 = comb.concat %false, %777 : i1, i1
    %779 = comb.mux bin %776, %c-1_i2, %778 {sv.namehint = "_brType_T_235"} : i2
    %780 = comb.mux bin %772, %c-2_i2, %779 {sv.namehint = "_brType_T_236"} : i2
    %781 = comb.mux bin %770, %c1_i2, %780 {sv.namehint = "_brType_T_237"} : i2
    %782 = comb.mux bin %766, %c-1_i2, %781 {sv.namehint = "_brType_T_238"} : i2
    %783 = comb.mux bin %762, %c-2_i2, %782 {sv.namehint = "_brType_T_239"} : i2
    %784 = comb.mux bin %758, %c0_i2, %783 {sv.namehint = "brType_11"} : i2
    %785 = comb.extract %io_in_bits_data_11 from 12 {sv.namehint = "_brOffset_rvc_offset_T_55"} : (i16) -> i1
    %786 = comb.extract %io_in_bits_data_11 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_89"} : (i16) -> i1
    %787 = comb.extract %io_in_bits_data_11 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_90"} : (i16) -> i2
    %788 = comb.extract %io_in_bits_data_11 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_91"} : (i16) -> i1
    %789 = comb.extract %io_in_bits_data_11 from 7 {sv.namehint = "_brOffset_rvi_offset_T_45"} : (i16) -> i1
    %790 = comb.extract %io_in_bits_data_11 from 2 {sv.namehint = "_brOffset_rvc_offset_T_57"} : (i16) -> i1
    %791 = comb.extract %io_in_bits_data_11 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_94"} : (i16) -> i1
    %792 = comb.extract %io_in_bits_data_11 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_95"} : (i16) -> i3
    %793 = comb.extract %io_in_bits_data_12 from 15 {sv.namehint = "_brOffset_rvi_offset_T_44"} : (i16) -> i1
    %794 = comb.extract %io_in_bits_data_11 from 12 : (i16) -> i4
    %795 = comb.extract %io_in_bits_data_12 from 0 : (i16) -> i4
    %796 = comb.extract %io_in_bits_data_12 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_46"} : (i16) -> i1
    %797 = comb.extract %io_in_bits_data_12 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_47"} : (i16) -> i10
    %798 = comb.replicate %785 : (i1) -> i10
    %799 = comb.concat %798, %786, %787, %788, %789, %790, %791, %792 : i10, i1, i2, i1, i1, i1, i1, i3
    %800 = comb.concat %793, %795, %794, %796, %797 : i1, i4, i4, i1, i10
    %801 = comb.mux bin %754, %799, %800 : i20
    %802 = comb.extract %801 from 19 {sv.namehint = "jalOffset_signBit_35"} : (i20) -> i1
    %803 = comb.extract %io_in_bits_data_11 from 5 {sv.namehint = "_brOffset_rvc_offset_T_56"} : (i16) -> i2
    %804 = comb.extract %io_in_bits_data_11 from 10 {sv.namehint = "_brOffset_rvc_offset_T_58"} : (i16) -> i2
    %805 = comb.extract %io_in_bits_data_11 from 3 {sv.namehint = "_brOffset_rvc_offset_T_59"} : (i16) -> i2
    %806 = comb.extract %io_in_bits_data_12 from 9 {sv.namehint = "_brOffset_rvi_offset_T_46"} : (i16) -> i6
    %807 = comb.extract %io_in_bits_data_11 from 8 {sv.namehint = "_brOffset_rvi_offset_T_47"} : (i16) -> i4
    %808 = comb.replicate %785 : (i1) -> i5
    %809 = comb.concat %808, %803, %790, %804, %805 : i5, i2, i1, i2, i2
    %810 = comb.concat %793, %789, %806, %807 : i1, i1, i6, i4
    %811 = comb.mux bin %754, %809, %810 : i12
    %812 = comb.extract %811 from 11 {sv.namehint = "brOffset_signBit_35"} : (i12) -> i1
    %813 = comb.icmp bin eq %784, %c1_i2 {sv.namehint = "_io_out_jumpOffset_11_T"} : i2
    %814 = comb.replicate %812 : (i1) -> i51
    %815 = comb.concat %814, %811 : i51, i12
    %816 = comb.replicate %802 : (i1) -> i43
    %817 = comb.concat %816, %801 : i43, i20
    %818 = comb.mux bin %813, %815, %817 : i63
    %819 = comb.concat %818, %false {sv.namehint = "io_out_jumpOffset_11"} : i63, i1
    %820 = comb.extract %io_in_bits_data_12 from 0 {sv.namehint = "_isCall_T_121"} : (i16) -> i2
    %821 = comb.icmp bin ne %820, %c-1_i2 {sv.namehint = "currentIsRVC_12"} : i2
    %822 = comb.extract %io_in_bits_data_12 from 13 : (i16) -> i3
    %823 = comb.extract %io_in_bits_data_12 from 0 : (i16) -> i12
    %824 = comb.concat %822, %823 : i3, i12
    %825 = comb.icmp bin eq %824, %c-16382_i15 {sv.namehint = "_brType_T_241"} : i15
    %826 = comb.extract %io_in_bits_data_12 from 13 : (i16) -> i3
    %827 = comb.extract %io_in_bits_data_12 from 0 : (i16) -> i2
    %828 = comb.concat %826, %827 : i3, i2
    %829 = comb.icmp bin eq %828, %c-11_i5 {sv.namehint = "_brType_T_243"} : i5
    %830 = comb.extract %io_in_bits_data_12 from 13 : (i16) -> i3
    %831 = comb.extract %io_in_bits_data_12 from 0 : (i16) -> i7
    %832 = comb.concat %830, %831 : i3, i7
    %833 = comb.icmp bin eq %832, %c-510_i10 {sv.namehint = "_brType_T_245"} : i10
    %834 = comb.extract %io_in_bits_data_12 from 14 : (i16) -> i2
    %835 = comb.extract %io_in_bits_data_12 from 0 : (i16) -> i2
    %836 = comb.concat %834, %835 : i2, i2
    %837 = comb.icmp bin eq %836, %c-3_i4 {sv.namehint = "_brType_T_247"} : i4
    %838 = comb.extract %io_in_bits_data_12 from 0 : (i16) -> i7
    %839 = comb.icmp bin eq %838, %c-17_i7 {sv.namehint = "_brType_T_249"} : i7
    %840 = comb.extract %io_in_bits_data_12 from 12 : (i16) -> i3
    %841 = comb.extract %io_in_bits_data_12 from 0 : (i16) -> i7
    %842 = comb.concat %840, %841 : i3, i7
    %843 = comb.icmp bin eq %842, %c103_i10 {sv.namehint = "_brType_T_251"} : i10
    %844 = comb.icmp bin eq %838, %c-29_i7 {sv.namehint = "_brType_T_254"} : i7
    %845 = comb.concat %false, %844 : i1, i1
    %846 = comb.mux bin %843, %c-1_i2, %845 {sv.namehint = "_brType_T_255"} : i2
    %847 = comb.mux bin %839, %c-2_i2, %846 {sv.namehint = "_brType_T_256"} : i2
    %848 = comb.mux bin %837, %c1_i2, %847 {sv.namehint = "_brType_T_257"} : i2
    %849 = comb.mux bin %833, %c-1_i2, %848 {sv.namehint = "_brType_T_258"} : i2
    %850 = comb.mux bin %829, %c-2_i2, %849 {sv.namehint = "_brType_T_259"} : i2
    %851 = comb.mux bin %825, %c0_i2, %850 {sv.namehint = "brType_12"} : i2
    %852 = comb.extract %io_in_bits_data_12 from 12 {sv.namehint = "_brOffset_rvc_offset_T_60"} : (i16) -> i1
    %853 = comb.extract %io_in_bits_data_12 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_97"} : (i16) -> i1
    %854 = comb.extract %io_in_bits_data_12 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_98"} : (i16) -> i2
    %855 = comb.extract %io_in_bits_data_12 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_99"} : (i16) -> i1
    %856 = comb.extract %io_in_bits_data_12 from 7 {sv.namehint = "_brOffset_rvi_offset_T_49"} : (i16) -> i1
    %857 = comb.extract %io_in_bits_data_12 from 2 {sv.namehint = "_brOffset_rvc_offset_T_62"} : (i16) -> i1
    %858 = comb.extract %io_in_bits_data_12 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_102"} : (i16) -> i1
    %859 = comb.extract %io_in_bits_data_12 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_103"} : (i16) -> i3
    %860 = comb.extract %io_in_bits_data_13 from 15 {sv.namehint = "_brOffset_rvi_offset_T_48"} : (i16) -> i1
    %861 = comb.extract %io_in_bits_data_12 from 12 : (i16) -> i4
    %862 = comb.extract %io_in_bits_data_13 from 0 : (i16) -> i4
    %863 = comb.extract %io_in_bits_data_13 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_50"} : (i16) -> i1
    %864 = comb.extract %io_in_bits_data_13 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_51"} : (i16) -> i10
    %865 = comb.replicate %852 : (i1) -> i10
    %866 = comb.concat %865, %853, %854, %855, %856, %857, %858, %859 : i10, i1, i2, i1, i1, i1, i1, i3
    %867 = comb.concat %860, %862, %861, %863, %864 : i1, i4, i4, i1, i10
    %868 = comb.mux bin %821, %866, %867 : i20
    %869 = comb.extract %868 from 19 {sv.namehint = "jalOffset_signBit_38"} : (i20) -> i1
    %870 = comb.extract %io_in_bits_data_12 from 5 {sv.namehint = "_brOffset_rvc_offset_T_61"} : (i16) -> i2
    %871 = comb.extract %io_in_bits_data_12 from 10 {sv.namehint = "_brOffset_rvc_offset_T_63"} : (i16) -> i2
    %872 = comb.extract %io_in_bits_data_12 from 3 {sv.namehint = "_brOffset_rvc_offset_T_64"} : (i16) -> i2
    %873 = comb.extract %io_in_bits_data_13 from 9 {sv.namehint = "_brOffset_rvi_offset_T_50"} : (i16) -> i6
    %874 = comb.extract %io_in_bits_data_12 from 8 {sv.namehint = "_brOffset_rvi_offset_T_51"} : (i16) -> i4
    %875 = comb.replicate %852 : (i1) -> i5
    %876 = comb.concat %875, %870, %857, %871, %872 : i5, i2, i1, i2, i2
    %877 = comb.concat %860, %856, %873, %874 : i1, i1, i6, i4
    %878 = comb.mux bin %821, %876, %877 : i12
    %879 = comb.extract %878 from 11 {sv.namehint = "brOffset_signBit_38"} : (i12) -> i1
    %880 = comb.icmp bin eq %851, %c1_i2 {sv.namehint = "_io_out_jumpOffset_12_T"} : i2
    %881 = comb.replicate %879 : (i1) -> i51
    %882 = comb.concat %881, %878 : i51, i12
    %883 = comb.replicate %869 : (i1) -> i43
    %884 = comb.concat %883, %868 : i43, i20
    %885 = comb.mux bin %880, %882, %884 : i63
    %886 = comb.concat %885, %false {sv.namehint = "io_out_jumpOffset_12"} : i63, i1
    %887 = comb.extract %io_in_bits_data_13 from 0 {sv.namehint = "_isCall_T_131"} : (i16) -> i2
    %888 = comb.icmp bin ne %887, %c-1_i2 {sv.namehint = "currentIsRVC_13"} : i2
    %889 = comb.extract %io_in_bits_data_13 from 13 : (i16) -> i3
    %890 = comb.extract %io_in_bits_data_13 from 0 : (i16) -> i12
    %891 = comb.concat %889, %890 : i3, i12
    %892 = comb.icmp bin eq %891, %c-16382_i15 {sv.namehint = "_brType_T_261"} : i15
    %893 = comb.extract %io_in_bits_data_13 from 13 : (i16) -> i3
    %894 = comb.extract %io_in_bits_data_13 from 0 : (i16) -> i2
    %895 = comb.concat %893, %894 : i3, i2
    %896 = comb.icmp bin eq %895, %c-11_i5 {sv.namehint = "_brType_T_263"} : i5
    %897 = comb.extract %io_in_bits_data_13 from 13 : (i16) -> i3
    %898 = comb.extract %io_in_bits_data_13 from 0 : (i16) -> i7
    %899 = comb.concat %897, %898 : i3, i7
    %900 = comb.icmp bin eq %899, %c-510_i10 {sv.namehint = "_brType_T_265"} : i10
    %901 = comb.extract %io_in_bits_data_13 from 14 : (i16) -> i2
    %902 = comb.extract %io_in_bits_data_13 from 0 : (i16) -> i2
    %903 = comb.concat %901, %902 : i2, i2
    %904 = comb.icmp bin eq %903, %c-3_i4 {sv.namehint = "_brType_T_267"} : i4
    %905 = comb.extract %io_in_bits_data_13 from 0 : (i16) -> i7
    %906 = comb.icmp bin eq %905, %c-17_i7 {sv.namehint = "_brType_T_269"} : i7
    %907 = comb.extract %io_in_bits_data_13 from 12 : (i16) -> i3
    %908 = comb.extract %io_in_bits_data_13 from 0 : (i16) -> i7
    %909 = comb.concat %907, %908 : i3, i7
    %910 = comb.icmp bin eq %909, %c103_i10 {sv.namehint = "_brType_T_271"} : i10
    %911 = comb.icmp bin eq %905, %c-29_i7 {sv.namehint = "_brType_T_274"} : i7
    %912 = comb.concat %false, %911 : i1, i1
    %913 = comb.mux bin %910, %c-1_i2, %912 {sv.namehint = "_brType_T_275"} : i2
    %914 = comb.mux bin %906, %c-2_i2, %913 {sv.namehint = "_brType_T_276"} : i2
    %915 = comb.mux bin %904, %c1_i2, %914 {sv.namehint = "_brType_T_277"} : i2
    %916 = comb.mux bin %900, %c-1_i2, %915 {sv.namehint = "_brType_T_278"} : i2
    %917 = comb.mux bin %896, %c-2_i2, %916 {sv.namehint = "_brType_T_279"} : i2
    %918 = comb.mux bin %892, %c0_i2, %917 {sv.namehint = "brType_13"} : i2
    %919 = comb.extract %io_in_bits_data_13 from 12 {sv.namehint = "_brOffset_rvc_offset_T_65"} : (i16) -> i1
    %920 = comb.extract %io_in_bits_data_13 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_105"} : (i16) -> i1
    %921 = comb.extract %io_in_bits_data_13 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_106"} : (i16) -> i2
    %922 = comb.extract %io_in_bits_data_13 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_107"} : (i16) -> i1
    %923 = comb.extract %io_in_bits_data_13 from 7 {sv.namehint = "_brOffset_rvi_offset_T_53"} : (i16) -> i1
    %924 = comb.extract %io_in_bits_data_13 from 2 {sv.namehint = "_brOffset_rvc_offset_T_67"} : (i16) -> i1
    %925 = comb.extract %io_in_bits_data_13 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_110"} : (i16) -> i1
    %926 = comb.extract %io_in_bits_data_13 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_111"} : (i16) -> i3
    %927 = comb.extract %io_in_bits_data_14 from 15 {sv.namehint = "_brOffset_rvi_offset_T_52"} : (i16) -> i1
    %928 = comb.extract %io_in_bits_data_13 from 12 : (i16) -> i4
    %929 = comb.extract %io_in_bits_data_14 from 0 : (i16) -> i4
    %930 = comb.extract %io_in_bits_data_14 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_54"} : (i16) -> i1
    %931 = comb.extract %io_in_bits_data_14 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_55"} : (i16) -> i10
    %932 = comb.replicate %919 : (i1) -> i10
    %933 = comb.concat %932, %920, %921, %922, %923, %924, %925, %926 : i10, i1, i2, i1, i1, i1, i1, i3
    %934 = comb.concat %927, %929, %928, %930, %931 : i1, i4, i4, i1, i10
    %935 = comb.mux bin %888, %933, %934 : i20
    %936 = comb.extract %935 from 19 {sv.namehint = "jalOffset_signBit_41"} : (i20) -> i1
    %937 = comb.extract %io_in_bits_data_13 from 5 {sv.namehint = "_brOffset_rvc_offset_T_66"} : (i16) -> i2
    %938 = comb.extract %io_in_bits_data_13 from 10 {sv.namehint = "_brOffset_rvc_offset_T_68"} : (i16) -> i2
    %939 = comb.extract %io_in_bits_data_13 from 3 {sv.namehint = "_brOffset_rvc_offset_T_69"} : (i16) -> i2
    %940 = comb.extract %io_in_bits_data_14 from 9 {sv.namehint = "_brOffset_rvi_offset_T_54"} : (i16) -> i6
    %941 = comb.extract %io_in_bits_data_13 from 8 {sv.namehint = "_brOffset_rvi_offset_T_55"} : (i16) -> i4
    %942 = comb.replicate %919 : (i1) -> i5
    %943 = comb.concat %942, %937, %924, %938, %939 : i5, i2, i1, i2, i2
    %944 = comb.concat %927, %923, %940, %941 : i1, i1, i6, i4
    %945 = comb.mux bin %888, %943, %944 : i12
    %946 = comb.extract %945 from 11 {sv.namehint = "brOffset_signBit_41"} : (i12) -> i1
    %947 = comb.icmp bin eq %918, %c1_i2 {sv.namehint = "_io_out_jumpOffset_13_T"} : i2
    %948 = comb.replicate %946 : (i1) -> i51
    %949 = comb.concat %948, %945 : i51, i12
    %950 = comb.replicate %936 : (i1) -> i43
    %951 = comb.concat %950, %935 : i43, i20
    %952 = comb.mux bin %947, %949, %951 : i63
    %953 = comb.concat %952, %false {sv.namehint = "io_out_jumpOffset_13"} : i63, i1
    %954 = comb.extract %io_in_bits_data_14 from 0 {sv.namehint = "_isCall_T_141"} : (i16) -> i2
    %955 = comb.icmp bin ne %954, %c-1_i2 {sv.namehint = "currentIsRVC_14"} : i2
    %956 = comb.extract %io_in_bits_data_14 from 13 : (i16) -> i3
    %957 = comb.extract %io_in_bits_data_14 from 0 : (i16) -> i12
    %958 = comb.concat %956, %957 : i3, i12
    %959 = comb.icmp bin eq %958, %c-16382_i15 {sv.namehint = "_brType_T_281"} : i15
    %960 = comb.extract %io_in_bits_data_14 from 13 : (i16) -> i3
    %961 = comb.extract %io_in_bits_data_14 from 0 : (i16) -> i2
    %962 = comb.concat %960, %961 : i3, i2
    %963 = comb.icmp bin eq %962, %c-11_i5 {sv.namehint = "_brType_T_283"} : i5
    %964 = comb.extract %io_in_bits_data_14 from 13 : (i16) -> i3
    %965 = comb.extract %io_in_bits_data_14 from 0 : (i16) -> i7
    %966 = comb.concat %964, %965 : i3, i7
    %967 = comb.icmp bin eq %966, %c-510_i10 {sv.namehint = "_brType_T_285"} : i10
    %968 = comb.extract %io_in_bits_data_14 from 14 : (i16) -> i2
    %969 = comb.extract %io_in_bits_data_14 from 0 : (i16) -> i2
    %970 = comb.concat %968, %969 : i2, i2
    %971 = comb.icmp bin eq %970, %c-3_i4 {sv.namehint = "_brType_T_287"} : i4
    %972 = comb.extract %io_in_bits_data_14 from 0 : (i16) -> i7
    %973 = comb.icmp bin eq %972, %c-17_i7 {sv.namehint = "_brType_T_289"} : i7
    %974 = comb.extract %io_in_bits_data_14 from 12 : (i16) -> i3
    %975 = comb.extract %io_in_bits_data_14 from 0 : (i16) -> i7
    %976 = comb.concat %974, %975 : i3, i7
    %977 = comb.icmp bin eq %976, %c103_i10 {sv.namehint = "_brType_T_291"} : i10
    %978 = comb.icmp bin eq %972, %c-29_i7 {sv.namehint = "_brType_T_294"} : i7
    %979 = comb.concat %false, %978 : i1, i1
    %980 = comb.mux bin %977, %c-1_i2, %979 {sv.namehint = "_brType_T_295"} : i2
    %981 = comb.mux bin %973, %c-2_i2, %980 {sv.namehint = "_brType_T_296"} : i2
    %982 = comb.mux bin %971, %c1_i2, %981 {sv.namehint = "_brType_T_297"} : i2
    %983 = comb.mux bin %967, %c-1_i2, %982 {sv.namehint = "_brType_T_298"} : i2
    %984 = comb.mux bin %963, %c-2_i2, %983 {sv.namehint = "_brType_T_299"} : i2
    %985 = comb.mux bin %959, %c0_i2, %984 {sv.namehint = "brType_14"} : i2
    %986 = comb.extract %io_in_bits_data_14 from 12 {sv.namehint = "_brOffset_rvc_offset_T_70"} : (i16) -> i1
    %987 = comb.extract %io_in_bits_data_14 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_113"} : (i16) -> i1
    %988 = comb.extract %io_in_bits_data_14 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_114"} : (i16) -> i2
    %989 = comb.extract %io_in_bits_data_14 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_115"} : (i16) -> i1
    %990 = comb.extract %io_in_bits_data_14 from 7 {sv.namehint = "_brOffset_rvi_offset_T_57"} : (i16) -> i1
    %991 = comb.extract %io_in_bits_data_14 from 2 {sv.namehint = "_brOffset_rvc_offset_T_72"} : (i16) -> i1
    %992 = comb.extract %io_in_bits_data_14 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_118"} : (i16) -> i1
    %993 = comb.extract %io_in_bits_data_14 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_119"} : (i16) -> i3
    %994 = comb.extract %io_in_bits_data_15 from 15 {sv.namehint = "_brOffset_rvi_offset_T_56"} : (i16) -> i1
    %995 = comb.extract %io_in_bits_data_14 from 12 : (i16) -> i4
    %996 = comb.extract %io_in_bits_data_15 from 0 : (i16) -> i4
    %997 = comb.extract %io_in_bits_data_15 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_58"} : (i16) -> i1
    %998 = comb.extract %io_in_bits_data_15 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_59"} : (i16) -> i10
    %999 = comb.replicate %986 : (i1) -> i10
    %1000 = comb.concat %999, %987, %988, %989, %990, %991, %992, %993 : i10, i1, i2, i1, i1, i1, i1, i3
    %1001 = comb.concat %994, %996, %995, %997, %998 : i1, i4, i4, i1, i10
    %1002 = comb.mux bin %955, %1000, %1001 : i20
    %1003 = comb.extract %1002 from 19 {sv.namehint = "jalOffset_signBit_44"} : (i20) -> i1
    %1004 = comb.extract %io_in_bits_data_14 from 5 {sv.namehint = "_brOffset_rvc_offset_T_71"} : (i16) -> i2
    %1005 = comb.extract %io_in_bits_data_14 from 10 {sv.namehint = "_brOffset_rvc_offset_T_73"} : (i16) -> i2
    %1006 = comb.extract %io_in_bits_data_14 from 3 {sv.namehint = "_brOffset_rvc_offset_T_74"} : (i16) -> i2
    %1007 = comb.extract %io_in_bits_data_15 from 9 {sv.namehint = "_brOffset_rvi_offset_T_58"} : (i16) -> i6
    %1008 = comb.extract %io_in_bits_data_14 from 8 {sv.namehint = "_brOffset_rvi_offset_T_59"} : (i16) -> i4
    %1009 = comb.replicate %986 : (i1) -> i5
    %1010 = comb.concat %1009, %1004, %991, %1005, %1006 : i5, i2, i1, i2, i2
    %1011 = comb.concat %994, %990, %1007, %1008 : i1, i1, i6, i4
    %1012 = comb.mux bin %955, %1010, %1011 : i12
    %1013 = comb.extract %1012 from 11 {sv.namehint = "brOffset_signBit_44"} : (i12) -> i1
    %1014 = comb.icmp bin eq %985, %c1_i2 {sv.namehint = "_io_out_jumpOffset_14_T"} : i2
    %1015 = comb.replicate %1013 : (i1) -> i51
    %1016 = comb.concat %1015, %1012 : i51, i12
    %1017 = comb.replicate %1003 : (i1) -> i43
    %1018 = comb.concat %1017, %1002 : i43, i20
    %1019 = comb.mux bin %1014, %1016, %1018 : i63
    %1020 = comb.concat %1019, %false {sv.namehint = "io_out_jumpOffset_14"} : i63, i1
    %1021 = comb.extract %io_in_bits_data_15 from 0 {sv.namehint = "_isCall_T_151"} : (i16) -> i2
    %1022 = comb.icmp bin ne %1021, %c-1_i2 {sv.namehint = "currentIsRVC_15"} : i2
    %1023 = comb.extract %io_in_bits_data_15 from 13 : (i16) -> i3
    %1024 = comb.extract %io_in_bits_data_15 from 0 : (i16) -> i12
    %1025 = comb.concat %1023, %1024 : i3, i12
    %1026 = comb.icmp bin eq %1025, %c-16382_i15 {sv.namehint = "_brType_T_301"} : i15
    %1027 = comb.extract %io_in_bits_data_15 from 13 : (i16) -> i3
    %1028 = comb.extract %io_in_bits_data_15 from 0 : (i16) -> i2
    %1029 = comb.concat %1027, %1028 : i3, i2
    %1030 = comb.icmp bin eq %1029, %c-11_i5 {sv.namehint = "_brType_T_303"} : i5
    %1031 = comb.extract %io_in_bits_data_15 from 13 : (i16) -> i3
    %1032 = comb.extract %io_in_bits_data_15 from 0 : (i16) -> i7
    %1033 = comb.concat %1031, %1032 : i3, i7
    %1034 = comb.icmp bin eq %1033, %c-510_i10 {sv.namehint = "_brType_T_305"} : i10
    %1035 = comb.extract %io_in_bits_data_15 from 14 : (i16) -> i2
    %1036 = comb.extract %io_in_bits_data_15 from 0 : (i16) -> i2
    %1037 = comb.concat %1035, %1036 : i2, i2
    %1038 = comb.icmp bin eq %1037, %c-3_i4 {sv.namehint = "_brType_T_307"} : i4
    %1039 = comb.extract %io_in_bits_data_15 from 0 : (i16) -> i7
    %1040 = comb.icmp bin eq %1039, %c-17_i7 {sv.namehint = "_brType_T_309"} : i7
    %1041 = comb.extract %io_in_bits_data_15 from 12 : (i16) -> i3
    %1042 = comb.extract %io_in_bits_data_15 from 0 : (i16) -> i7
    %1043 = comb.concat %1041, %1042 : i3, i7
    %1044 = comb.icmp bin eq %1043, %c103_i10 {sv.namehint = "_brType_T_311"} : i10
    %1045 = comb.icmp bin eq %1039, %c-29_i7 {sv.namehint = "_brType_T_314"} : i7
    %1046 = comb.concat %false, %1045 : i1, i1
    %1047 = comb.mux bin %1044, %c-1_i2, %1046 {sv.namehint = "_brType_T_315"} : i2
    %1048 = comb.mux bin %1040, %c-2_i2, %1047 {sv.namehint = "_brType_T_316"} : i2
    %1049 = comb.mux bin %1038, %c1_i2, %1048 {sv.namehint = "_brType_T_317"} : i2
    %1050 = comb.mux bin %1034, %c-1_i2, %1049 {sv.namehint = "_brType_T_318"} : i2
    %1051 = comb.mux bin %1030, %c-2_i2, %1050 {sv.namehint = "_brType_T_319"} : i2
    %1052 = comb.mux bin %1026, %c0_i2, %1051 {sv.namehint = "brType_15"} : i2
    %1053 = comb.extract %io_in_bits_data_15 from 12 {sv.namehint = "_brOffset_rvc_offset_T_75"} : (i16) -> i1
    %1054 = comb.extract %io_in_bits_data_15 from 8 {sv.namehint = "_jalOffset_rvc_offset_T_121"} : (i16) -> i1
    %1055 = comb.extract %io_in_bits_data_15 from 9 {sv.namehint = "_jalOffset_rvc_offset_T_122"} : (i16) -> i2
    %1056 = comb.extract %io_in_bits_data_15 from 6 {sv.namehint = "_jalOffset_rvc_offset_T_123"} : (i16) -> i1
    %1057 = comb.extract %io_in_bits_data_15 from 7 {sv.namehint = "_brOffset_rvi_offset_T_61"} : (i16) -> i1
    %1058 = comb.extract %io_in_bits_data_15 from 2 {sv.namehint = "_brOffset_rvc_offset_T_77"} : (i16) -> i1
    %1059 = comb.extract %io_in_bits_data_15 from 11 {sv.namehint = "_jalOffset_rvc_offset_T_126"} : (i16) -> i1
    %1060 = comb.extract %io_in_bits_data_15 from 3 {sv.namehint = "_jalOffset_rvc_offset_T_127"} : (i16) -> i3
    %1061 = comb.extract %io_in_bits_data_16 from 15 {sv.namehint = "_brOffset_rvi_offset_T_60"} : (i16) -> i1
    %1062 = comb.extract %io_in_bits_data_15 from 12 : (i16) -> i4
    %1063 = comb.extract %io_in_bits_data_16 from 0 : (i16) -> i4
    %1064 = comb.extract %io_in_bits_data_16 from 4 {sv.namehint = "_jalOffset_rvi_offset_T_62"} : (i16) -> i1
    %1065 = comb.extract %io_in_bits_data_16 from 5 {sv.namehint = "_jalOffset_rvi_offset_T_63"} : (i16) -> i10
    %1066 = comb.replicate %1053 : (i1) -> i10
    %1067 = comb.concat %1066, %1054, %1055, %1056, %1057, %1058, %1059, %1060 : i10, i1, i2, i1, i1, i1, i1, i3
    %1068 = comb.concat %1061, %1063, %1062, %1064, %1065 : i1, i4, i4, i1, i10
    %1069 = comb.mux bin %1022, %1067, %1068 : i20
    %1070 = comb.extract %1069 from 19 {sv.namehint = "jalOffset_signBit_47"} : (i20) -> i1
    %1071 = comb.extract %io_in_bits_data_15 from 5 {sv.namehint = "_brOffset_rvc_offset_T_76"} : (i16) -> i2
    %1072 = comb.extract %io_in_bits_data_15 from 10 {sv.namehint = "_brOffset_rvc_offset_T_78"} : (i16) -> i2
    %1073 = comb.extract %io_in_bits_data_15 from 3 {sv.namehint = "_brOffset_rvc_offset_T_79"} : (i16) -> i2
    %1074 = comb.extract %io_in_bits_data_16 from 9 {sv.namehint = "_brOffset_rvi_offset_T_62"} : (i16) -> i6
    %1075 = comb.extract %io_in_bits_data_15 from 8 {sv.namehint = "_brOffset_rvi_offset_T_63"} : (i16) -> i4
    %1076 = comb.replicate %1053 : (i1) -> i5
    %1077 = comb.concat %1076, %1071, %1058, %1072, %1073 : i5, i2, i1, i2, i2
    %1078 = comb.concat %1061, %1057, %1074, %1075 : i1, i1, i6, i4
    %1079 = comb.mux bin %1022, %1077, %1078 : i12
    %1080 = comb.extract %1079 from 11 {sv.namehint = "brOffset_signBit_47"} : (i12) -> i1
    %1081 = comb.icmp bin eq %1052, %c1_i2 {sv.namehint = "_io_out_jumpOffset_15_T"} : i2
    %1082 = comb.replicate %1080 : (i1) -> i51
    %1083 = comb.concat %1082, %1079 : i51, i12
    %1084 = comb.replicate %1070 : (i1) -> i43
    %1085 = comb.concat %1084, %1069 : i43, i20
    %1086 = comb.mux bin %1081, %1083, %1085 : i63
    %1087 = comb.concat %1086, %false {sv.namehint = "io_out_jumpOffset_15"} : i63, i1
    %1088 = comb.and bin %17, %84 {sv.namehint = "_validEnd_1_T"} : i1
    %1089 = comb.xor bin %17, %true {sv.namehint = "_validEnd_1_T_1"} : i1
    %1090 = comb.or bin %1088, %1089 {sv.namehint = "validEnd_1"} : i1
    %1091 = comb.and bin %1090, %151 {sv.namehint = "_validEnd_2_T"} : i1
    %1092 = comb.xor bin %1090, %true {sv.namehint = "_validEnd_2_T_1"} : i1
    %1093 = comb.or bin %1091, %1092 {sv.namehint = "validEnd_2"} : i1
    %1094 = comb.and bin %84, %151 {sv.namehint = "_h_validEnd_2_T"} : i1
    %1095 = comb.xor bin %84, %true {sv.namehint = "_h_validEnd_2_T_1"} : i1
    %1096 = comb.or bin %1094, %1095 {sv.namehint = "h_validEnd_2"} : i1
    %1097 = comb.and bin %1093, %218 {sv.namehint = "_validEnd_3_T"} : i1
    %1098 = comb.xor bin %1093, %true {sv.namehint = "_validEnd_3_T_1"} : i1
    %1099 = comb.or bin %1097, %1098 {sv.namehint = "validEnd_3"} : i1
    %1100 = comb.and bin %1096, %218 {sv.namehint = "_h_validEnd_3_T"} : i1
    %1101 = comb.xor bin %1096, %true {sv.namehint = "_h_validEnd_3_T_1"} : i1
    %1102 = comb.or bin %1100, %1101 {sv.namehint = "h_validEnd_3"} : i1
    %1103 = comb.and bin %1099, %285 {sv.namehint = "_validEnd_4_T"} : i1
    %1104 = comb.xor bin %1099, %true {sv.namehint = "_validEnd_4_T_1"} : i1
    %1105 = comb.or bin %1103, %1104 {sv.namehint = "validEnd_4"} : i1
    %1106 = comb.and bin %1102, %285 {sv.namehint = "_h_validEnd_4_T"} : i1
    %1107 = comb.xor bin %1102, %true {sv.namehint = "_h_validEnd_4_T_1"} : i1
    %1108 = comb.or bin %1106, %1107 {sv.namehint = "h_validEnd_4"} : i1
    %1109 = comb.and bin %1105, %352 {sv.namehint = "_validEnd_5_T"} : i1
    %1110 = comb.xor bin %1105, %true {sv.namehint = "_validEnd_5_T_1"} : i1
    %1111 = comb.or bin %1109, %1110 {sv.namehint = "validEnd_5"} : i1
    %1112 = comb.and bin %1108, %352 {sv.namehint = "_h_validEnd_5_T"} : i1
    %1113 = comb.xor bin %1108, %true {sv.namehint = "_h_validEnd_5_T_1"} : i1
    %1114 = comb.or bin %1112, %1113 {sv.namehint = "h_validEnd_5"} : i1
    %1115 = comb.and bin %1111, %419 {sv.namehint = "_validEnd_6_T"} : i1
    %1116 = comb.xor bin %1111, %true {sv.namehint = "_validEnd_6_T_1"} : i1
    %1117 = comb.or bin %1115, %1116 {sv.namehint = "validEnd_6"} : i1
    %1118 = comb.and bin %1114, %419 {sv.namehint = "_h_validEnd_6_T"} : i1
    %1119 = comb.xor bin %1114, %true {sv.namehint = "_h_validEnd_6_T_1"} : i1
    %1120 = comb.or bin %1118, %1119 {sv.namehint = "h_validEnd_6"} : i1
    %1121 = comb.and bin %1117, %486 {sv.namehint = "_validEnd_7_T"} : i1
    %1122 = comb.xor bin %1117, %true {sv.namehint = "_validEnd_7_T_1"} : i1
    %1123 = comb.or bin %1121, %1122 {sv.namehint = "validEnd_7"} : i1
    %1124 = comb.and bin %1120, %486 {sv.namehint = "_h_validEnd_7_T"} : i1
    %1125 = comb.xor bin %1120, %true {sv.namehint = "_h_validEnd_7_T_1"} : i1
    %1126 = comb.or bin %1124, %1125 {sv.namehint = "h_validEnd_7"} : i1
    %1127 = comb.and bin %553, %620 {sv.namehint = "_validEnd_half_9_T"} : i1
    %1128 = comb.xor bin %553, %true {sv.namehint = "_validEnd_half_9_T_1"} : i1
    %1129 = comb.or bin %1127, %1128 {sv.namehint = "lastIsValidEnd_23"} : i1
    %1130 = comb.and bin %553, %620 {sv.namehint = "_h_validEnd_half_9_T"} : i1
    %1131 = comb.xor bin %553, %true {sv.namehint = "_h_validEnd_half_9_T_1"} : i1
    %1132 = comb.or bin %1130, %1131 {sv.namehint = "h_lastIsValidEnd_23"} : i1
    %1133 = comb.and bin %1129, %687 {sv.namehint = "_validEnd_half_10_T"} : i1
    %1134 = comb.xor bin %1129, %true {sv.namehint = "_validEnd_half_10_T_1"} : i1
    %1135 = comb.or bin %1133, %1134 {sv.namehint = "lastIsValidEnd_24"} : i1
    %1136 = comb.and bin %1132, %687 {sv.namehint = "_h_validEnd_half_10_T"} : i1
    %1137 = comb.xor bin %1132, %true {sv.namehint = "_h_validEnd_half_10_T_1"} : i1
    %1138 = comb.or bin %1136, %1137 {sv.namehint = "h_lastIsValidEnd_24"} : i1
    %1139 = comb.and bin %1135, %754 {sv.namehint = "_validEnd_half_11_T"} : i1
    %1140 = comb.xor bin %1135, %true {sv.namehint = "_validEnd_half_11_T_1"} : i1
    %1141 = comb.or bin %1139, %1140 {sv.namehint = "lastIsValidEnd_25"} : i1
    %1142 = comb.and bin %1138, %754 {sv.namehint = "_h_validEnd_half_11_T"} : i1
    %1143 = comb.xor bin %1138, %true {sv.namehint = "_h_validEnd_half_11_T_1"} : i1
    %1144 = comb.or bin %1142, %1143 {sv.namehint = "h_lastIsValidEnd_25"} : i1
    %1145 = comb.and bin %1141, %821 {sv.namehint = "_validEnd_half_12_T"} : i1
    %1146 = comb.xor bin %1141, %true {sv.namehint = "_validEnd_half_12_T_1"} : i1
    %1147 = comb.or bin %1145, %1146 {sv.namehint = "lastIsValidEnd_26"} : i1
    %1148 = comb.and bin %1144, %821 {sv.namehint = "_h_validEnd_half_12_T"} : i1
    %1149 = comb.xor bin %1144, %true {sv.namehint = "_h_validEnd_half_12_T_1"} : i1
    %1150 = comb.or bin %1148, %1149 {sv.namehint = "h_lastIsValidEnd_26"} : i1
    %1151 = comb.and bin %1147, %888 {sv.namehint = "_validEnd_half_13_T"} : i1
    %1152 = comb.xor bin %1147, %true {sv.namehint = "_validEnd_half_13_T_1"} : i1
    %1153 = comb.or bin %1151, %1152 {sv.namehint = "lastIsValidEnd_27"} : i1
    %1154 = comb.and bin %1150, %888 {sv.namehint = "_h_validEnd_half_13_T"} : i1
    %1155 = comb.xor bin %1150, %true {sv.namehint = "_h_validEnd_half_13_T_1"} : i1
    %1156 = comb.or bin %1154, %1155 {sv.namehint = "h_lastIsValidEnd_27"} : i1
    %1157 = comb.and bin %1153, %955 {sv.namehint = "_validEnd_half_14_T"} : i1
    %1158 = comb.xor bin %1153, %true {sv.namehint = "_validEnd_half_14_T_1"} : i1
    %1159 = comb.or bin %1157, %1158 {sv.namehint = "lastIsValidEnd_28"} : i1
    %1160 = comb.and bin %1156, %955 {sv.namehint = "_h_validEnd_half_14_T"} : i1
    %1161 = comb.xor bin %1156, %true {sv.namehint = "_h_validEnd_half_14_T_1"} : i1
    %1162 = comb.or bin %1160, %1161 {sv.namehint = "h_lastIsValidEnd_28"} : i1
    %1163 = comb.and bin %620, %687 {sv.namehint = "_validEnd_halfPlus1_10_T"} : i1
    %1164 = comb.xor bin %620, %true {sv.namehint = "_validEnd_halfPlus1_10_T_1"} : i1
    %1165 = comb.or bin %1163, %1164 {sv.namehint = "lastIsValidEnd_30"} : i1
    %1166 = comb.and bin %620, %687 {sv.namehint = "_h_validEnd_halfPlus1_10_T"} : i1
    %1167 = comb.xor bin %620, %true {sv.namehint = "_h_validEnd_halfPlus1_10_T_1"} : i1
    %1168 = comb.or bin %1166, %1167 {sv.namehint = "h_lastIsValidEnd_30"} : i1
    %1169 = comb.and bin %1165, %754 {sv.namehint = "_validEnd_halfPlus1_11_T"} : i1
    %1170 = comb.xor bin %1165, %true {sv.namehint = "_validEnd_halfPlus1_11_T_1"} : i1
    %1171 = comb.or bin %1169, %1170 {sv.namehint = "lastIsValidEnd_31"} : i1
    %1172 = comb.and bin %1168, %754 {sv.namehint = "_h_validEnd_halfPlus1_11_T"} : i1
    %1173 = comb.xor bin %1168, %true {sv.namehint = "_h_validEnd_halfPlus1_11_T_1"} : i1
    %1174 = comb.or bin %1172, %1173 {sv.namehint = "h_lastIsValidEnd_31"} : i1
    %1175 = comb.and bin %1171, %821 {sv.namehint = "_validEnd_halfPlus1_12_T"} : i1
    %1176 = comb.xor bin %1171, %true {sv.namehint = "_validEnd_halfPlus1_12_T_1"} : i1
    %1177 = comb.or bin %1175, %1176 {sv.namehint = "lastIsValidEnd_32"} : i1
    %1178 = comb.and bin %1174, %821 {sv.namehint = "_h_validEnd_halfPlus1_12_T"} : i1
    %1179 = comb.xor bin %1174, %true {sv.namehint = "_h_validEnd_halfPlus1_12_T_1"} : i1
    %1180 = comb.or bin %1178, %1179 {sv.namehint = "h_lastIsValidEnd_32"} : i1
    %1181 = comb.and bin %1177, %888 {sv.namehint = "_validEnd_halfPlus1_13_T"} : i1
    %1182 = comb.xor bin %1177, %true {sv.namehint = "_validEnd_halfPlus1_13_T_1"} : i1
    %1183 = comb.or bin %1181, %1182 {sv.namehint = "lastIsValidEnd_33"} : i1
    %1184 = comb.and bin %1180, %888 {sv.namehint = "_h_validEnd_halfPlus1_13_T"} : i1
    %1185 = comb.xor bin %1180, %true {sv.namehint = "_h_validEnd_halfPlus1_13_T_1"} : i1
    %1186 = comb.or bin %1184, %1185 {sv.namehint = "h_lastIsValidEnd_33"} : i1
    %1187 = comb.and bin %1183, %955 {sv.namehint = "_validEnd_halfPlus1_14_T"} : i1
    %1188 = comb.xor bin %1183, %true {sv.namehint = "_validEnd_halfPlus1_14_T_1"} : i1
    %1189 = comb.or bin %1187, %1188 {sv.namehint = "lastIsValidEnd_34"} : i1
    %1190 = comb.and bin %1186, %955 {sv.namehint = "_h_validEnd_halfPlus1_14_T"} : i1
    %1191 = comb.xor bin %1186, %true {sv.namehint = "_h_validEnd_halfPlus1_14_T_1"} : i1
    %1192 = comb.or bin %1190, %1191 {sv.namehint = "h_lastIsValidEnd_34"} : i1
    %1193 = comb.xor %1123, %true : i1
    %1194 = comb.or %1193, %553 {sv.namehint = "validStart_9"} : i1
    %1195 = comb.xor %1126, %true : i1
    %1196 = comb.or %1195, %553 {sv.namehint = "h_validStart_9"} : i1
    %1197 = comb.mux bin %1123, %1129, %620 {sv.namehint = "validStart_10"} : i1
    %1198 = comb.mux bin %1126, %1132, %620 {sv.namehint = "h_validStart_10"} : i1
    %1199 = comb.mux bin %1123, %1135, %1165 {sv.namehint = "validStart_11"} : i1
    %1200 = comb.mux bin %1126, %1138, %1168 {sv.namehint = "h_validStart_11"} : i1
    %1201 = comb.mux bin %1123, %1141, %1171 {sv.namehint = "validStart_12"} : i1
    %1202 = comb.mux bin %1126, %1144, %1174 {sv.namehint = "h_validStart_12"} : i1
    %1203 = comb.mux bin %1123, %1147, %1177 {sv.namehint = "validStart_13"} : i1
    %1204 = comb.mux bin %1126, %1150, %1180 {sv.namehint = "h_validStart_13"} : i1
    %1205 = comb.mux bin %1123, %1153, %1183 {sv.namehint = "validStart_14"} : i1
    %1206 = comb.mux bin %1126, %1156, %1186 {sv.namehint = "h_validStart_14"} : i1
    %1207 = comb.mux bin %1123, %1159, %1189 {sv.namehint = "validStart_15"} : i1
    %1208 = comb.mux bin %1126, %1162, %1192 {sv.namehint = "h_validStart_15"} : i1
    hw.output %17, %17, %84, %1090, %151, %1093, %218, %1099, %285, %1105, %352, %1111, %419, %1117, %486, %1123, %553, %1194, %620, %1197, %687, %1199, %754, %1201, %821, %1203, %888, %1205, %955, %1207, %1022, %84, %1096, %1102, %1108, %1114, %1120, %1126, %1196, %1198, %1200, %1202, %1204, %1206, %1208, %0, %1, %2, %3, %4, %5, %6, %7, %8, %9, %10, %11, %12, %13, %14, %15, %82, %149, %216, %283, %350, %417, %484, %551, %618, %685, %752, %819, %886, %953, %1020, %1087 : i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64
  }