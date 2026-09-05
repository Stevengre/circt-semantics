#loc = loc("riscinator.mlir":2:154)
#loc1 = loc("riscinator.mlir":2:175)
#loc2 = loc("riscinator.mlir":12:72)
#loc3 = loc("riscinator.mlir":12:235)
#loc4 = loc("riscinator.mlir":31:78)
#loc5 = loc("riscinator.mlir":89:90)
#loc6 = loc("riscinator.mlir":103:257)
#loc7 = loc("riscinator.mlir":103:278)
#loc8 = loc("riscinator.mlir":103:301)
#loc9 = loc("riscinator.mlir":103:328)
#loc10 = loc("riscinator.mlir":103:355)
#loc11 = loc("riscinator.mlir":103:377)
#loc12 = loc("riscinator.mlir":103:401)
#loc13 = loc("riscinator.mlir":103:422)
#loc14 = loc("riscinator.mlir":103:443)
#loc15 = loc("riscinator.mlir":103:468)
#loc16 = loc("riscinator.mlir":103:488)
#loc17 = loc("riscinator.mlir":174:233)
#loc18 = loc("riscinator.mlir":174:253)
#loc19 = loc("riscinator.mlir":174:275)
#loc20 = loc("riscinator.mlir":213:381)
#loc21 = loc("riscinator.mlir":213:404)
#loc22 = loc("riscinator.mlir":213:427)
#loc23 = loc("riscinator.mlir":447:53)
#loc24 = loc("riscinator.mlir":447:77)
#loc25 = loc("riscinator.mlir":447:100)
#loc26 = loc("riscinator.mlir":447:123)
#loc27 = loc("riscinator.mlir":447:148)
#loc28 = loc("riscinator.mlir":447:172)
#loc29 = loc("riscinator.mlir":447:197)
#loc30 = loc("riscinator.mlir":447:224)
#loc31 = loc("riscinator.mlir":447:249)
#loc32 = loc("riscinator.mlir":447:274)
#loc33 = loc("riscinator.mlir":447:298)
#loc34 = loc("riscinator.mlir":447:321)
#loc35 = loc("riscinator.mlir":447:346)
#loc36 = loc("riscinator.mlir":696:63)
#loc37 = loc("riscinator.mlir":696:85)
#loc38 = loc("riscinator.mlir":696:203)
#loc39 = loc("riscinator.mlir":696:225)
#loc40 = loc("riscinator.mlir":696:249)
#loc41 = loc("riscinator.mlir":696:270)
#loc42 = loc("riscinator.mlir":696:291)
"builtin.module"() ({
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input io_wen : i1, input io_raddr1 : i5, input io_raddr2 : i5, input io_waddr : i5, input io_wdata : i32, output io_rdata1 : i32, output io_rdata2 : i32>, parameters = [], result_locs = [#loc, #loc1], sym_name = "RegFile"}> ({
  ^bb0(%arg61: !seq.clock, %arg62: i1, %arg63: i5, %arg64: i5, %arg65: i5, %arg66: i32):
    %733 = "hw.constant"() <{value = 0 : i5}> : () -> i5
    %734 = "seq.firmem"() <{name = "regs", readLatency = 0 : i32, ruw = 0 : i32, writeLatency = 1 : i32, wuw = 1 : i32}> : () -> !seq.firmem<32 x 32>
    "seq.firmem.write_port"(%734, %arg65, %arg61, %738, %arg66) <{operandSegmentSizes = array<i32: 1, 1, 1, 1, 1, 0>}> : (!seq.firmem<32 x 32>, i5, !seq.clock, i1, i32) -> ()
    %735 = "seq.firmem.read_port"(%734, %arg63, %arg61) {sv.namehint = "io_rdata1"} : (!seq.firmem<32 x 32>, i5, !seq.clock) -> i32
    %736 = "seq.firmem.read_port"(%734, %arg64, %arg61) {sv.namehint = "io_rdata2"} : (!seq.firmem<32 x 32>, i5, !seq.clock) -> i32
    %737 = "comb.icmp"(%arg65, %733) <{predicate = 1 : i64, twoState}> : (i5, i5) -> i1
    %738 = "comb.and"(%arg62, %737) <{twoState}> : (i1, i1) -> i1
    "hw.output"(%735, %736) : (i32, i32) -> ()
  }) {sym_visibility = "private"} : () -> ()
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, output io_imem_addr : i32, input io_ctrl_pc_sel : i2, input io_ctrl_stall : i1, input io_epc_valid : i1, input io_epc_bits : i32, input io_br_taken : i1, input io_alu_out : i32, output io_pc : i32>, parameters = [], result_locs = [#loc2, #loc3], sym_name = "Fetch"}> ({
  ^bb0(%arg53: !seq.clock, %arg54: i1, %arg55: i2, %arg56: i1, %arg57: i1, %arg58: i32, %arg59: i1, %arg60: i32):
    %717 = "hw.constant"() <{value = 4 : i32}> : () -> i32
    %718 = "hw.constant"() <{value = false}> : () -> i1
    %719 = "hw.constant"() <{value = 1 : i2}> : () -> i2
    %720 = "hw.constant"() <{value = 1048576 : i32}> : () -> i32
    %721 = "hw.constant"() <{value = -2 : i2}> : () -> i2
    %722 = "seq.firreg"(%732, %arg53, %arg54, %720) <{name = "pc"}> {firrtl.random_init_start = 0 : ui64, sv.namehint = "pc"} : (i32, !seq.clock, i1, i32) -> i32
    %723 = "comb.icmp"(%arg55, %721) <{predicate = 0 : i64, twoState}> : (i2, i2) -> i1
    %724 = "comb.or"(%arg56, %723) <{twoState}> : (i1, i1) -> i1
    %725 = "comb.icmp"(%arg55, %719) <{predicate = 0 : i64, twoState}> : (i2, i2) -> i1
    %726 = "comb.or"(%725, %arg59) <{twoState}> : (i1, i1) -> i1
    %727 = "comb.extract"(%arg60) <{lowBit = 1 : i32}> : (i32) -> i31
    %728 = "comb.concat"(%727, %718) {sv.namehint = "_next_T_1"} : (i31, i1) -> i32
    %729 = "comb.add"(%722, %717) <{twoState}> {sv.namehint = "_next_T_2"} : (i32, i32) -> i32
    %730 = "comb.mux"(%726, %728, %729) <{twoState}> : (i1, i32, i32) -> i32
    %731 = "comb.mux"(%724, %722, %730) <{twoState}> : (i1, i32, i32) -> i32
    %732 = "comb.mux"(%arg57, %arg58, %731) <{twoState}> {sv.namehint = "next"} : (i1, i32, i32) -> i32
    "hw.output"(%732, %722) : (i32, i32) -> ()
  }) {sym_visibility = "private"} : () -> ()
  "hw.module"() <{module_type = !hw.modty<input io_a : i32, input io_b : i32, input io_op : i4, output io_out : i32>, parameters = [], result_locs = [#loc4], sym_name = "Alu"}> ({
  ^bb0(%arg50: i32, %arg51: i32, %arg52: i4):
    %662 = "hw.constant"() <{value = 0 : i32}> : () -> i32
    %663 = "hw.constant"() <{value = 7 : i4}> : () -> i4
    %664 = "hw.constant"() <{value = 6 : i4}> : () -> i4
    %665 = "hw.constant"() <{value = 5 : i4}> : () -> i4
    %666 = "hw.constant"() <{value = 4 : i4}> : () -> i4
    %667 = "hw.constant"() <{value = 3 : i4}> : () -> i4
    %668 = "hw.constant"() <{value = 2 : i4}> : () -> i4
    %669 = "hw.constant"() <{value = 1 : i4}> : () -> i4
    %670 = "hw.constant"() <{value = 0 : i27}> : () -> i27
    %671 = "hw.constant"() <{value = 0 : i58}> : () -> i58
    %672 = "hw.constant"() <{value = 0 : i31}> : () -> i31
    %673 = "hw.constant"() <{value = 0 : i4}> : () -> i4
    %674 = "hw.constant"() <{value = -8 : i4}> : () -> i4
    %675 = "hw.constant"() <{value = -7 : i4}> : () -> i4
    %676 = "hw.constant"() <{value = -5 : i4}> : () -> i4
    %677 = "comb.extract"(%arg51) <{lowBit = 0 : i32}> {sv.namehint = "shamt"} : (i32) -> i5
    %678 = "comb.icmp"(%arg52, %669) <{predicate = 0 : i64, twoState}> : (i4, i4) -> i1
    %679 = "comb.sub"(%662, %arg51) <{twoState}> {sv.namehint = "_b_T_1"} : (i32, i32) -> i32
    %680 = "comb.mux"(%678, %679, %arg51) <{twoState}> {sv.namehint = "b"} : (i1, i32, i32) -> i32
    %681 = "comb.add"(%arg50, %680) <{twoState}> {sv.namehint = "_sum_T"} : (i32, i32) -> i32
    %682 = "comb.icmp"(%arg52, %673) <{predicate = 0 : i64, twoState}> : (i4, i4) -> i1
    %683 = "comb.icmp"(%arg52, %668) <{predicate = 0 : i64, twoState}> : (i4, i4) -> i1
    %684 = "comb.and"(%arg50, %arg51) <{twoState}> {sv.namehint = "_io_out_T"} : (i32, i32) -> i32
    %685 = "comb.icmp"(%arg52, %667) <{predicate = 0 : i64, twoState}> : (i4, i4) -> i1
    %686 = "comb.or"(%arg50, %arg51) <{twoState}> {sv.namehint = "_io_out_T_1"} : (i32, i32) -> i32
    %687 = "comb.icmp"(%arg52, %666) <{predicate = 0 : i64, twoState}> : (i4, i4) -> i1
    %688 = "comb.xor"(%arg50, %arg51) <{twoState}> {sv.namehint = "_io_out_T_2"} : (i32, i32) -> i32
    %689 = "comb.icmp"(%arg52, %665) <{predicate = 0 : i64, twoState}> : (i4, i4) -> i1
    %690 = "comb.icmp"(%arg50, %arg51) <{predicate = 2 : i64, twoState}> {sv.namehint = "_io_out_T_5"} : (i32, i32) -> i1
    %691 = "comb.concat"(%672, %690) : (i31, i1) -> i32
    %692 = "comb.icmp"(%arg52, %664) <{predicate = 0 : i64, twoState}> : (i4, i4) -> i1
    %693 = "comb.concat"(%672, %arg50) : (i31, i32) -> i63
    %694 = "comb.concat"(%671, %677) : (i58, i5) -> i63
    %695 = "comb.shl"(%693, %694) <{twoState}> {sv.namehint = "_io_out_T_6"} : (i63, i63) -> i63
    %696 = "comb.extract"(%695) <{lowBit = 0 : i32}> : (i63) -> i32
    %697 = "comb.icmp"(%arg52, %663) <{predicate = 0 : i64, twoState}> : (i4, i4) -> i1
    %698 = "comb.icmp"(%arg50, %arg51) <{predicate = 6 : i64, twoState}> {sv.namehint = "_io_out_T_7"} : (i32, i32) -> i1
    %699 = "comb.concat"(%672, %698) : (i31, i1) -> i32
    %700 = "comb.icmp"(%arg52, %674) <{predicate = 0 : i64, twoState}> : (i4, i4) -> i1
    %701 = "comb.concat"(%670, %677) : (i27, i5) -> i32
    %702 = "comb.shru"(%arg50, %701) <{twoState}> {sv.namehint = "_io_out_T_8"} : (i32, i32) -> i32
    %703 = "comb.icmp"(%arg52, %675) <{predicate = 0 : i64, twoState}> : (i4, i4) -> i1
    %704 = "comb.shrs"(%arg50, %701) <{twoState}> {sv.namehint = "_io_out_T_10"} : (i32, i32) -> i32
    %705 = "comb.icmp"(%arg52, %676) <{predicate = 0 : i64, twoState}> : (i4, i4) -> i1
    %706 = "comb.mux"(%705, %arg51, %arg50) <{twoState}> : (i1, i32, i32) -> i32
    %707 = "comb.mux"(%703, %704, %706) <{twoState}> : (i1, i32, i32) -> i32
    %708 = "comb.mux"(%700, %702, %707) <{twoState}> : (i1, i32, i32) -> i32
    %709 = "comb.mux"(%697, %699, %708) <{twoState}> : (i1, i32, i32) -> i32
    %710 = "comb.mux"(%692, %696, %709) <{twoState}> : (i1, i32, i32) -> i32
    %711 = "comb.mux"(%689, %691, %710) <{twoState}> : (i1, i32, i32) -> i32
    %712 = "comb.mux"(%687, %688, %711) <{twoState}> : (i1, i32, i32) -> i32
    %713 = "comb.mux"(%685, %686, %712) <{twoState}> : (i1, i32, i32) -> i32
    %714 = "comb.mux"(%683, %684, %713) <{twoState}> : (i1, i32, i32) -> i32
    %715 = "comb.or"(%682, %678) <{twoState}> : (i1, i1) -> i1
    %716 = "comb.mux"(%715, %681, %714) <{twoState}> {sv.namehint = "io_out"} : (i1, i32, i32) -> i32
    "hw.output"(%716) : (i32) -> ()
  }) {sym_visibility = "private"} : () -> ()
  "hw.module"() <{module_type = !hw.modty<input io_rs1 : i32, input io_rs2 : i32, input io_br_type : i3, output io_taken : i1>, parameters = [], result_locs = [#loc5], sym_name = "Branch"}> ({
  ^bb0(%arg47: i32, %arg48: i32, %arg49: i3):
    %651 = "hw.constant"() <{value = -4 : i3}> : () -> i3
    %652 = "comb.icmp"(%arg47, %arg48) <{predicate = 0 : i64, twoState}> {sv.namehint = "eq"} : (i32, i32) -> i1
    %653 = "comb.icmp"(%arg47, %arg48) <{predicate = 2 : i64, twoState}> {sv.namehint = "lt"} : (i32, i32) -> i1
    %654 = "comb.icmp"(%arg47, %arg48) <{predicate = 6 : i64, twoState}> {sv.namehint = "ltu"} : (i32, i32) -> i1
    %655 = "comb.icmp"(%arg47, %arg48) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_taken_T"} : (i32, i32) -> i1
    %656 = "comb.icmp"(%arg47, %arg48) <{predicate = 5 : i64, twoState}> {sv.namehint = "_io_taken_T_1"} : (i32, i32) -> i1
    %657 = "comb.icmp"(%arg49, %651) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %658 = "comb.icmp"(%arg47, %arg48) <{predicate = 9 : i64, twoState}> {sv.namehint = "_io_taken_T_2"} : (i32, i32) -> i1
    %659 = "comb.and"(%657, %658) : (i1, i1) -> i1
    %660 = "hw.array_create"(%659, %655, %656, %659, %652, %653, %654, %659) : (i1, i1, i1, i1, i1, i1, i1, i1) -> !hw.array<8xi1>
    %661 = "hw.array_get"(%660, %arg49) {sv.namehint = "io_taken"} : (!hw.array<8xi1>, i3) -> i1
    "hw.output"(%661) : (i1) -> ()
  }) {sym_visibility = "private"} : () -> ()
  "hw.module"() <{module_type = !hw.modty<input io_ctrl_imm_sel : i3, input io_ctrl_ld_type : i3, input io_ctrl_st_type : i2, input io_ctrl_alu_op : i4, input io_ctrl_a_sel : i2, input io_ctrl_b_sel : i2, input io_ctrl_br_type : i3, input io_data_inst : i32, input io_data_pc : i32, output io_data_rd : i5, output io_data_csr : i12, output io_data_alu_out : i32, output io_data_br_taken : i1, output io_dmem_req : i1, output io_dmem_addr : i32, output io_dmem_we : i1, output io_dmem_be : i4, output io_dmem_wdata : i32, output io_rf_rs1 : i5, output io_rf_rs2 : i5, input io_rf_rs1r : i32, input io_rf_rs2r : i32>, parameters = [], result_locs = [#loc6, #loc7, #loc8, #loc9, #loc10, #loc11, #loc12, #loc13, #loc14, #loc15, #loc16], sym_name = "Execute"}> ({
  ^bb0(%arg36: i3, %arg37: i3, %arg38: i2, %arg39: i4, %arg40: i2, %arg41: i2, %arg42: i3, %arg43: i32, %arg44: i32, %arg45: i32, %arg46: i32):
    %583 = "hw.constant"() <{value = 0 : i27}> : () -> i27
    %584 = "hw.constant"() <{value = 1 : i4}> : () -> i4
    %585 = "hw.constant"() <{value = 3 : i5}> : () -> i5
    %586 = "hw.constant"() <{value = 0 : i58}> : () -> i58
    %587 = "hw.constant"() <{value = 0 : i31}> : () -> i31
    %588 = "hw.constant"() <{value = 0 : i5}> : () -> i5
    %589 = "hw.constant"() <{value = 0 : i3}> : () -> i3
    %590 = "hw.constant"() <{value = 0 : i2}> : () -> i2
    %591 = "hw.constant"() <{value = -2 : i2}> : () -> i2
    %592 = "hw.constant"() <{value = false}> : () -> i1
    %593 = "hw.constant"() <{value = -1 : i2}> : () -> i2
    %594 = "hw.constant"() <{value = 0 : i12}> : () -> i12
    %595 = "hw.constant"() <{value = -1 : i4}> : () -> i4
    %596 = "comb.extract"(%arg43) <{lowBit = 15 : i32}> {sv.namehint = "io_rf_rs1"} : (i32) -> i5
    %597 = "comb.extract"(%arg43) <{lowBit = 20 : i32}> {sv.namehint = "io_rf_rs2"} : (i32) -> i5
    %598 = "comb.extract"(%arg43) <{lowBit = 7 : i32}> {sv.namehint = "io_data_rd"} : (i32) -> i5
    %599 = "comb.extract"(%arg43) <{lowBit = 20 : i32}> {sv.namehint = "io_data_csr"} : (i32) -> i12
    %600 = "comb.extract"(%arg43) <{lowBit = 31 : i32}> : (i32) -> i1
    %601 = "comb.replicate"(%600) : (i1) -> i20
    %602 = "comb.concat"(%601, %599) : (i20, i12) -> i32
    %603 = "comb.extract"(%arg43) <{lowBit = 25 : i32}> {sv.namehint = "_sint_T_2"} : (i32) -> i7
    %604 = "comb.extract"(%arg43) <{lowBit = 31 : i32}> : (i32) -> i1
    %605 = "comb.replicate"(%604) : (i1) -> i20
    %606 = "comb.concat"(%605, %603, %598) : (i20, i7, i5) -> i32
    %607 = "comb.extract"(%arg43) <{lowBit = 31 : i32}> {sv.namehint = "_sint_T_6"} : (i32) -> i1
    %608 = "comb.extract"(%arg43) <{lowBit = 7 : i32}> {sv.namehint = "_sint_T_7"} : (i32) -> i1
    %609 = "comb.extract"(%arg43) <{lowBit = 25 : i32}> {sv.namehint = "_sint_T_8"} : (i32) -> i6
    %610 = "comb.extract"(%arg43) <{lowBit = 8 : i32}> {sv.namehint = "_sint_T_9"} : (i32) -> i4
    %611 = "comb.replicate"(%607) : (i1) -> i20
    %612 = "comb.concat"(%611, %608, %609, %610, %592) : (i20, i1, i6, i4, i1) -> i32
    %613 = "comb.extract"(%arg43) <{lowBit = 12 : i32}> {sv.namehint = "_sint_T_12"} : (i32) -> i20
    %614 = "comb.concat"(%613, %594) {sv.namehint = "_sint_T_13"} : (i20, i12) -> i32
    %615 = "comb.extract"(%arg43) <{lowBit = 31 : i32}> {sv.namehint = "_sint_T_15"} : (i32) -> i1
    %616 = "comb.extract"(%arg43) <{lowBit = 12 : i32}> {sv.namehint = "_sint_T_16"} : (i32) -> i8
    %617 = "comb.extract"(%arg43) <{lowBit = 20 : i32}> {sv.namehint = "_sint_T_17"} : (i32) -> i1
    %618 = "comb.extract"(%arg43) <{lowBit = 21 : i32}> {sv.namehint = "sint_lo_hi"} : (i32) -> i10
    %619 = "comb.replicate"(%615) : (i1) -> i12
    %620 = "comb.concat"(%619, %616, %617, %618, %592) : (i12, i8, i1, i10, i1) -> i32
    %621 = "comb.concat"(%583, %596) : (i27, i5) -> i32
    %622 = "hw.array_create"(%621, %621, %612, %620, %614, %606, %602, %621) : (i32, i32, i32, i32, i32, i32, i32, i32) -> !hw.array<8xi32>
    %623 = "hw.array_get"(%622, %arg36) {sv.namehint = "sint"} : (!hw.array<8xi32>, i3) -> i32
    %624 = "hw.instance"(%626, %628, %arg39) <{argNames = ["io_a", "io_b", "io_op"], instanceName = "alu", moduleName = @Alu, parameters = [], resultNames = ["io_out"]}> {sv.namehint = "io_data_alu_out"} : (i32, i32, i4) -> i32
    %625 = "comb.icmp"(%arg40, %591) <{predicate = 0 : i64, twoState}> {sv.namehint = "_alu_io_a_T"} : (i2, i2) -> i1
    %626 = "comb.mux"(%625, %arg45, %arg44) <{twoState}> {sv.namehint = "alu.io_a"} : (i1, i32, i32) -> i32
    %627 = "comb.icmp"(%arg41, %591) <{predicate = 0 : i64, twoState}> {sv.namehint = "_alu_io_b_T"} : (i2, i2) -> i1
    %628 = "comb.mux"(%627, %arg46, %623) <{twoState}> {sv.namehint = "alu.io_b"} : (i1, i32, i32) -> i32
    %629 = "comb.extract"(%624) <{lowBit = 2 : i32}> : (i32) -> i30
    %630 = "comb.concat"(%629, %590) {sv.namehint = "daddr"} : (i30, i2) -> i32
    %631 = "comb.extract"(%624) <{lowBit = 0 : i32}> : (i32) -> i2
    %632 = "comb.icmp"(%arg38, %590) <{predicate = 1 : i64, twoState}> {sv.namehint = "io_dmem_we"} : (i2, i2) -> i1
    %633 = "comb.concat"(%arg37, %arg38) : (i3, i2) -> i5
    %634 = "comb.icmp"(%633, %588) <{predicate = 1 : i64, twoState}> {sv.namehint = "io_dmem_req"} : (i5, i5) -> i1
    %635 = "comb.concat"(%587, %arg46) : (i31, i32) -> i63
    %636 = "comb.concat"(%586, %631, %589) : (i58, i2, i3) -> i63
    %637 = "comb.shl"(%635, %636) <{twoState}> {sv.namehint = "_io_dmem_wdata_T"} : (i63, i63) -> i63
    %638 = "comb.extract"(%637) <{lowBit = 0 : i32}> {sv.namehint = "io_dmem_wdata"} : (i63) -> i32
    %639 = "comb.icmp"(%arg38, %591) <{predicate = 0 : i64, twoState}> : (i2, i2) -> i1
    %640 = "comb.extract"(%624) <{lowBit = 0 : i32}> {sv.namehint = "_io_dmem_be_T"} : (i32) -> i2
    %641 = "comb.concat"(%589, %640) : (i3, i2) -> i5
    %642 = "comb.shl"(%585, %641) <{twoState}> {sv.namehint = "_io_dmem_be_T_1"} : (i5, i5) -> i5
    %643 = "comb.extract"(%642) <{lowBit = 0 : i32}> : (i5) -> i4
    %644 = "comb.icmp"(%arg38, %593) <{predicate = 0 : i64, twoState}> : (i2, i2) -> i1
    %645 = "comb.extract"(%624) <{lowBit = 0 : i32}> {sv.namehint = "_io_dmem_be_T_2"} : (i32) -> i2
    %646 = "comb.concat"(%590, %645) : (i2, i2) -> i4
    %647 = "comb.shl"(%584, %646) <{twoState}> {sv.namehint = "_io_dmem_be_T_3"} : (i4, i4) -> i4
    %648 = "comb.mux"(%644, %647, %595) <{twoState}> : (i1, i4, i4) -> i4
    %649 = "comb.mux"(%639, %643, %648) <{twoState}> {sv.namehint = "io_dmem_be"} : (i1, i4, i4) -> i4
    %650 = "hw.instance"(%arg45, %arg46, %arg42) <{argNames = ["io_rs1", "io_rs2", "io_br_type"], instanceName = "br", moduleName = @Branch, parameters = [], resultNames = ["io_taken"]}> {sv.namehint = "io_data_br_taken"} : (i32, i32, i3) -> i1
    "hw.output"(%598, %599, %624, %650, %634, %630, %632, %649, %638, %596, %597) : (i5, i12, i32, i1, i1, i32, i1, i4, i32, i5, i5) -> ()
  }) {sym_visibility = "private"} : () -> ()
  "hw.module"() <{module_type = !hw.modty<input io_ctrl_wb_sel : i2, input io_ctrl_wb_en : i1, input io_ctrl_ld_type : i3, input io_data_ld : i32, input io_data_pc : i32, input io_data_alu_out : i32, input io_data_csr_rdata : i32, input io_data_rd : i32, output io_rf_wen : i1, output io_rf_waddr : i5, output io_rf_wdata : i32>, parameters = [], result_locs = [#loc17, #loc18, #loc19], sym_name = "Writeback"}> ({
  ^bb0(%arg28: i2, %arg29: i1, %arg30: i3, %arg31: i32, %arg32: i32, %arg33: i32, %arg34: i32, %arg35: i32):
    %547 = "hw.constant"() <{value = 4 : i32}> : () -> i32
    %548 = "hw.constant"() <{value = 0 : i24}> : () -> i24
    %549 = "hw.constant"() <{value = 0 : i16}> : () -> i16
    %550 = "hw.constant"() <{value = 0 : i27}> : () -> i27
    %551 = "hw.constant"() <{value = 3 : i3}> : () -> i3
    %552 = "hw.constant"() <{value = 2 : i3}> : () -> i3
    %553 = "hw.constant"() <{value = 0 : i3}> : () -> i3
    %554 = "hw.constant"() <{value = -4 : i3}> : () -> i3
    %555 = "hw.constant"() <{value = -3 : i3}> : () -> i3
    %556 = "comb.extract"(%arg33) <{lowBit = 0 : i32}> : (i32) -> i2
    %557 = "comb.concat"(%550, %556, %553) : (i27, i2, i3) -> i32
    %558 = "comb.shru"(%arg31, %557) <{twoState}> {sv.namehint = "ldshift"} : (i32, i32) -> i32
    %559 = "comb.icmp"(%arg30, %552) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %560 = "comb.extract"(%558) <{lowBit = 0 : i32}> {sv.namehint = "_ld_T_1"} : (i32) -> i16
    %561 = "comb.extract"(%558) <{lowBit = 15 : i32}> : (i32) -> i1
    %562 = "comb.replicate"(%561) : (i1) -> i16
    %563 = "comb.concat"(%562, %560) : (i16, i16) -> i32
    %564 = "comb.icmp"(%arg30, %551) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %565 = "comb.extract"(%558) <{lowBit = 0 : i32}> {sv.namehint = "_ld_T_3"} : (i32) -> i8
    %566 = "comb.extract"(%558) <{lowBit = 7 : i32}> : (i32) -> i1
    %567 = "comb.replicate"(%566) : (i1) -> i24
    %568 = "comb.concat"(%567, %565) : (i24, i8) -> i32
    %569 = "comb.icmp"(%arg30, %554) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %570 = "comb.extract"(%558) <{lowBit = 0 : i32}> {sv.namehint = "_ld_T_5"} : (i32) -> i16
    %571 = "comb.concat"(%549, %570) : (i16, i16) -> i32
    %572 = "comb.icmp"(%arg30, %555) <{predicate = 0 : i64, twoState}> : (i3, i3) -> i1
    %573 = "comb.extract"(%558) <{lowBit = 0 : i32}> {sv.namehint = "_ld_T_7"} : (i32) -> i8
    %574 = "comb.concat"(%548, %573) : (i24, i8) -> i32
    %575 = "comb.mux"(%572, %574, %arg31) <{twoState}> : (i1, i32, i32) -> i32
    %576 = "comb.mux"(%569, %571, %575) <{twoState}> : (i1, i32, i32) -> i32
    %577 = "comb.mux"(%564, %568, %576) <{twoState}> : (i1, i32, i32) -> i32
    %578 = "comb.mux"(%559, %563, %577) <{twoState}> {sv.namehint = "ld"} : (i1, i32, i32) -> i32
    %579 = "comb.extract"(%arg35) <{lowBit = 0 : i32}> {sv.namehint = "io_rf_waddr"} : (i32) -> i5
    %580 = "comb.add"(%arg32, %547) <{twoState}> {sv.namehint = "_io_rf_wdata_T_1"} : (i32, i32) -> i32
    %581 = "hw.array_create"(%arg34, %580, %578, %arg33) : (i32, i32, i32, i32) -> !hw.array<4xi32>
    %582 = "hw.array_get"(%581, %arg28) {sv.namehint = "io_rf_wdata"} : (!hw.array<4xi32>, i2) -> i32
    "hw.output"(%arg29, %579, %582) : (i1, i5, i32) -> ()
  }) {sym_visibility = "private"} : () -> ()
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, input io_ctrl_csr_type : i3, input io_ctrl_illegal : i1, input io_imem_req : i1, input io_imem_addr : i32, input io_imem_rvalid : i1, input io_imem_err : i1, input io_dmem_req : i1, input io_dmem_addr : i32, input io_dmem_rvalid : i1, input io_dmem_err : i1, input io_pc : i32, input io_csr : i12, input io_rs1 : i5, input io_wdata : i32, output io_epc_valid : i1, output io_epc_bits : i32, output io_rdata : i32>, parameters = [], result_locs = [#loc20, #loc21, #loc22], sym_name = "Csr"}> ({
  ^bb0(%arg12: !seq.clock, %arg13: i1, %arg14: i3, %arg15: i1, %arg16: i1, %arg17: i32, %arg18: i1, %arg19: i1, %arg20: i1, %arg21: i32, %arg22: i1, %arg23: i1, %arg24: i32, %arg25: i12, %arg26: i5, %arg27: i32):
    %316 = "hw.constant"() <{value = 1 : i32}> : () -> i32
    %317 = "hw.constant"() <{value = 3 : i3}> : () -> i3
    %318 = "hw.constant"() <{value = 2 : i3}> : () -> i3
    %319 = "hw.constant"() <{value = 1 : i3}> : () -> i3
    %320 = "hw.constant"() <{value = 0 : i28}> : () -> i28
    %321 = "hw.constant"() <{value = 0 : i5}> : () -> i5
    %322 = "hw.constant"() <{value = -1 : i32}> : () -> i32
    %323 = "hw.constant"() <{value = false}> : () -> i1
    %324 = "hw.constant"() <{value = -1 : i2}> : () -> i2
    %325 = "hw.constant"() <{value = 0 : i32}> : () -> i32
    %326 = "hw.constant"() <{value = 0 : i3}> : () -> i3
    %327 = "hw.constant"() <{value = 0 : i19}> : () -> i19
    %328 = "hw.constant"() <{value = 0 : i20}> : () -> i20
    %329 = "hw.constant"() <{value = 1048576 : i32}> : () -> i32
    %330 = "hw.constant"() <{value = true}> : () -> i1
    %331 = "hw.constant"() <{value = 769 : i12}> : () -> i12
    %332 = "hw.constant"() <{value = 836 : i12}> : () -> i12
    %333 = "hw.constant"() <{value = -1022 : i12}> : () -> i12
    %334 = "hw.constant"() <{value = 835 : i12}> : () -> i12
    %335 = "hw.constant"() <{value = 772 : i12}> : () -> i12
    %336 = "hw.constant"() <{value = 834 : i12}> : () -> i12
    %337 = "hw.constant"() <{value = 774 : i12}> : () -> i12
    %338 = "hw.constant"() <{value = 832 : i12}> : () -> i12
    %339 = "hw.constant"() <{value = -896 : i12}> : () -> i12
    %340 = "hw.constant"() <{value = -895 : i12}> : () -> i12
    %341 = "hw.constant"() <{value = 833 : i12}> : () -> i12
    %342 = "hw.constant"() <{value = 768 : i12}> : () -> i12
    %343 = "hw.constant"() <{value = -1024 : i12}> : () -> i12
    %344 = "hw.constant"() <{value = -236 : i12}> : () -> i12
    %345 = "hw.constant"() <{value = -237 : i12}> : () -> i12
    %346 = "hw.constant"() <{value = 5000 : i32}> : () -> i32
    %347 = "hw.constant"() <{value = -1023 : i12}> : () -> i12
    %348 = "hw.constant"() <{value = -238 : i12}> : () -> i12
    %349 = "hw.constant"() <{value = 773 : i12}> : () -> i12
    %350 = "hw.constant"() <{value = -894 : i12}> : () -> i12
    %351 = "hw.constant"() <{value = -239 : i12}> : () -> i12
    %352 = "hw.constant"() <{value = -4 : i3}> : () -> i3
    %353 = "hw.constant"() <{value = -3 : i3}> : () -> i3
    %354 = "hw.constant"() <{value = -2 : i3}> : () -> i3
    %355 = "hw.constant"() <{value = -8 : i4}> : () -> i4
    %356 = "hw.constant"() <{value = -5 : i4}> : () -> i4
    %357 = "hw.constant"() <{value = 0 : i2}> : () -> i2
    %358 = "hw.constant"() <{value = 1074790656 : i32}> : () -> i32
    %359 = "hw.constant"() <{value = 4 : i4}> : () -> i4
    %360 = "hw.constant"() <{value = 0 : i4}> : () -> i4
    %361 = "hw.constant"() <{value = 5 : i4}> : () -> i4
    %362 = "hw.constant"() <{value = 1 : i4}> : () -> i4
    %363 = "seq.firreg"(%500, %arg12, %arg13, %323) <{name = "p"}> {firrtl.random_init_start = 0 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %364 = "seq.firreg"(%516, %arg12, %arg13, %323) <{name = "e"}> {firrtl.random_init_start = 1 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %365 = "seq.firreg"(%505, %arg12, %arg13, %323) <{name = "p_1"}> {firrtl.random_init_start = 2 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %366 = "seq.firreg"(%521, %arg12, %arg13, %323) <{name = "e_1"}> {firrtl.random_init_start = 3 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %367 = "seq.firreg"(%510, %arg12, %arg13, %323) <{name = "p_2"}> {firrtl.random_init_start = 4 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %368 = "seq.firreg"(%526, %arg12, %arg13, %323) <{name = "e_2"}> {firrtl.random_init_start = 5 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %369 = "seq.firreg"(%485, %arg12, %arg13, %324) <{name = "mpp"}> {firrtl.random_init_start = 6 : ui64} : (i2, !seq.clock, i1, i2) -> i2
    %370 = "seq.firreg"(%489, %arg12, %arg13, %323) <{name = "mpie"}> {firrtl.random_init_start = 8 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %371 = "seq.firreg"(%494, %arg12, %arg13, %323) <{name = "mie"}> {firrtl.random_init_start = 9 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %372 = "seq.firreg"(%478, %arg12, %arg13, %324) <{name = "priv"}> {firrtl.random_init_start = 10 : ui64} : (i2, !seq.clock, i1, i2) -> i2
    %373 = "seq.firreg"(%388, %arg12, %arg13, %325) <{name = "REG"}> {firrtl.random_init_start = 12 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %374 = "seq.firreg"(%384, %arg12, %arg13, %325) <{name = "REG_1"}> {firrtl.random_init_start = 44 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %375 = "seq.firreg"(%391, %arg12, %arg13, %325) <{name = "REG_3"}> {firrtl.random_init_start = 108 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %376 = "seq.firreg"(%387, %arg12, %arg13, %325) <{name = "REG_4"}> {firrtl.random_init_start = 140 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %377 = "comb.concat"(%327, %369, %326, %370, %326, %371, %326) : (i19, i2, i3, i1, i3, i1, i3) -> i32
    %378 = "comb.concat"(%328, %363, %326, %365, %326, %367, %326) : (i20, i1, i3, i1, i3, i1, i3) -> i32
    %379 = "comb.concat"(%328, %364, %326, %366, %326, %368, %326) : (i20, i1, i3, i1, i3, i1, i3) -> i32
    %380 = "seq.firreg"(%534, %arg12, %arg13, %329) <{name = "REG_6"}> {firrtl.random_init_start = 204 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %381 = "seq.firreg"(%530, %arg12, %arg13, %325) <{name = "REG_7"}> {firrtl.random_init_start = 236 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %382 = "seq.firreg"(%541, %arg12, %arg13, %325) <{name = "REG_8"}> {firrtl.random_init_start = 268 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %383 = "seq.firreg"(%546, %arg12, %arg13, %325) <{name = "REG_9"}> {firrtl.random_init_start = 300 : ui64} : (i32, !seq.clock, i1, i32) -> i32
    %384 = "comb.add"(%374, %316) <{twoState}> : (i32, i32) -> i32
    %385 = "comb.icmp"(%374, %322) <{predicate = 0 : i64, twoState}> : (i32, i32) -> i1
    %386 = "comb.add"(%376, %316) <{twoState}> : (i32, i32) -> i32
    %387 = "comb.mux"(%385, %386, %376) <{twoState}> : (i1, i32, i32) -> i32
    %388 = "comb.add"(%373, %316) <{twoState}> : (i32, i32) -> i32
    %389 = "comb.icmp"(%373, %322) <{predicate = 0 : i64, twoState}> : (i32, i32) -> i1
    %390 = "comb.add"(%375, %316) <{twoState}> : (i32, i32) -> i32
    %391 = "comb.mux"(%389, %390, %375) <{twoState}> : (i1, i32, i32) -> i32
    %392 = "comb.icmp"(%arg25, %331) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T"} : (i12, i12) -> i1
    %393 = "comb.mux"(%392, %358, %325) <{twoState}> {sv.namehint = "_io_rdata_T_1"} : (i1, i32, i32) -> i32
    %394 = "comb.icmp"(%arg25, %332) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_1"} : (i12, i12) -> i1
    %395 = "comb.mux"(%394, %378, %393) <{twoState}> {sv.namehint = "_io_rdata_T_3"} : (i1, i32, i32) -> i32
    %396 = "comb.icmp"(%arg25, %333) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_2"} : (i12, i12) -> i1
    %397 = "comb.icmp"(%arg25, %334) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_3"} : (i12, i12) -> i1
    %398 = "comb.or"(%397, %396) <{twoState}> : (i1, i1) -> i1
    %399 = "comb.mux"(%398, %325, %395) <{twoState}> {sv.namehint = "_io_rdata_T_7"} : (i1, i32, i32) -> i32
    %400 = "comb.icmp"(%arg25, %335) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_4"} : (i12, i12) -> i1
    %401 = "comb.mux"(%400, %379, %399) <{twoState}> {sv.namehint = "_io_rdata_T_9"} : (i1, i32, i32) -> i32
    %402 = "comb.icmp"(%arg25, %336) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_5"} : (i12, i12) -> i1
    %403 = "comb.mux"(%402, %383, %401) <{twoState}> {sv.namehint = "_io_rdata_T_11"} : (i1, i32, i32) -> i32
    %404 = "comb.icmp"(%arg25, %337) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_6"} : (i12, i12) -> i1
    %405 = "comb.mux"(%404, %325, %403) <{twoState}> {sv.namehint = "_io_rdata_T_13"} : (i1, i32, i32) -> i32
    %406 = "comb.icmp"(%arg25, %338) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_7"} : (i12, i12) -> i1
    %407 = "comb.mux"(%406, %381, %405) <{twoState}> {sv.namehint = "_io_rdata_T_15"} : (i1, i32, i32) -> i32
    %408 = "comb.icmp"(%arg25, %339) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_8"} : (i12, i12) -> i1
    %409 = "comb.mux"(%408, %375, %407) <{twoState}> {sv.namehint = "_io_rdata_T_17"} : (i1, i32, i32) -> i32
    %410 = "comb.icmp"(%arg25, %340) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_9"} : (i12, i12) -> i1
    %411 = "comb.mux"(%410, %376, %409) <{twoState}> {sv.namehint = "_io_rdata_T_19"} : (i1, i32, i32) -> i32
    %412 = "comb.icmp"(%arg25, %341) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_10"} : (i12, i12) -> i1
    %413 = "comb.mux"(%412, %382, %411) <{twoState}> {sv.namehint = "_io_rdata_T_21"} : (i1, i32, i32) -> i32
    %414 = "comb.icmp"(%arg25, %342) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_11"} : (i12, i12) -> i1
    %415 = "comb.mux"(%414, %377, %413) <{twoState}> {sv.namehint = "_io_rdata_T_23"} : (i1, i32, i32) -> i32
    %416 = "comb.icmp"(%arg25, %343) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_12"} : (i12, i12) -> i1
    %417 = "comb.mux"(%416, %373, %415) <{twoState}> {sv.namehint = "_io_rdata_T_25"} : (i1, i32, i32) -> i32
    %418 = "comb.icmp"(%arg25, %344) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_13"} : (i12, i12) -> i1
    %419 = "comb.mux"(%418, %325, %417) <{twoState}> {sv.namehint = "_io_rdata_T_27"} : (i1, i32, i32) -> i32
    %420 = "comb.icmp"(%arg25, %345) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_14"} : (i12, i12) -> i1
    %421 = "comb.mux"(%420, %346, %419) <{twoState}> {sv.namehint = "_io_rdata_T_29"} : (i1, i32, i32) -> i32
    %422 = "comb.icmp"(%arg25, %347) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_15"} : (i12, i12) -> i1
    %423 = "comb.mux"(%422, %374, %421) <{twoState}> {sv.namehint = "_io_rdata_T_31"} : (i1, i32, i32) -> i32
    %424 = "comb.icmp"(%arg25, %348) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_16"} : (i12, i12) -> i1
    %425 = "comb.mux"(%424, %325, %423) <{twoState}> {sv.namehint = "_io_rdata_T_33"} : (i1, i32, i32) -> i32
    %426 = "comb.icmp"(%arg25, %349) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_17"} : (i12, i12) -> i1
    %427 = "comb.mux"(%426, %380, %425) <{twoState}> {sv.namehint = "_io_rdata_T_35"} : (i1, i32, i32) -> i32
    %428 = "comb.icmp"(%arg25, %350) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_18"} : (i12, i12) -> i1
    %429 = "comb.icmp"(%arg25, %351) <{predicate = 0 : i64, twoState}> {sv.namehint = "_valid_T_19"} : (i12, i12) -> i1
    %430 = "comb.or"(%429, %428) <{twoState}> : (i1, i1) -> i1
    %431 = "comb.mux"(%430, %325, %427) <{twoState}> {sv.namehint = "io_rdata"} : (i1, i32, i32) -> i32
    %432 = "comb.icmp"(%arg14, %319) <{predicate = 0 : i64, twoState}> {sv.namehint = "_wdata_T"} : (i3, i3) -> i1
    %433 = "comb.icmp"(%arg14, %318) <{predicate = 0 : i64, twoState}> {sv.namehint = "_wdata_T_1"} : (i3, i3) -> i1
    %434 = "comb.icmp"(%arg14, %317) <{predicate = 0 : i64, twoState}> {sv.namehint = "_wdata_T_3"} : (i3, i3) -> i1
    %435 = "comb.icmp"(%arg26, %321) <{predicate = 1 : i64, twoState}> {sv.namehint = "_wen_T_4"} : (i5, i5) -> i1
    %436 = "comb.and"(%434, %435) <{twoState}> {sv.namehint = "_wen_T_5"} : (i1, i1) -> i1
    %437 = "comb.or"(%432, %433, %436) <{twoState}> {sv.namehint = "wen"} : (i1, i1, i1) -> i1
    %438 = "comb.or"(%431, %arg27) <{twoState}> {sv.namehint = "_wdata_T_2"} : (i32, i32) -> i32
    %439 = "comb.xor"(%arg27, %322) <{twoState}> {sv.namehint = "_wdata_T_4"} : (i32, i32) -> i32
    %440 = "comb.and"(%431, %439) <{twoState}> {sv.namehint = "_wdata_T_5"} : (i32, i32) -> i32
    %441 = "comb.mux"(%434, %440, %325) <{twoState}> {sv.namehint = "_wdata_T_6"} : (i1, i32, i32) -> i32
    %442 = "comb.mux"(%433, %438, %441) <{twoState}> {sv.namehint = "_wdata_T_7"} : (i1, i32, i32) -> i32
    %443 = "comb.mux"(%432, %arg27, %442) <{twoState}> {sv.namehint = "wdata"} : (i1, i32, i32) -> i32
    %444 = "comb.icmp"(%372, %324) <{predicate = 0 : i64, twoState}> {sv.namehint = "priv_valid"} : (i2, i2) -> i1
    %445 = "comb.icmp"(%arg14, %352) <{predicate = 0 : i64, twoState}> {sv.namehint = "_exception_T"} : (i3, i3) -> i1
    %446 = "comb.icmp"(%arg14, %353) <{predicate = 0 : i64, twoState}> {sv.namehint = "_exception_T_1"} : (i3, i3) -> i1
    %447 = "comb.icmp"(%arg14, %354) <{predicate = 0 : i64, twoState}> {sv.namehint = "_isE_T_3"} : (i3, i3) -> i1
    %448 = "comb.or"(%445, %446, %447) <{twoState}> {sv.namehint = "isE"} : (i1, i1, i1) -> i1
    %449 = "comb.xor"(%444, %330) <{twoState}> {sv.namehint = "_illegal_priv_T"} : (i1, i1) -> i1
    %450 = "comb.xor"(%448, %330) <{twoState}> {sv.namehint = "_illegal_priv_T_1"} : (i1, i1) -> i1
    %451 = "comb.and"(%449, %450) <{twoState}> {sv.namehint = "illegal_priv"} : (i1, i1) -> i1
    %452 = "comb.and"(%arg19, %arg18) <{twoState}> {sv.namehint = "ifault"} : (i1, i1) -> i1
    %453 = "comb.and"(%arg23, %arg22) <{twoState}> {sv.namehint = "dfault"} : (i1, i1) -> i1
    %454 = "comb.extract"(%arg17) <{lowBit = 0 : i32}> {sv.namehint = "_imisalign_T"} : (i32) -> i2
    %455 = "comb.icmp"(%454, %357) <{predicate = 1 : i64, twoState}> {sv.namehint = "_imisalign_T_1"} : (i2, i2) -> i1
    %456 = "comb.and"(%arg16, %455) <{twoState}> {sv.namehint = "imisalign"} : (i1, i1) -> i1
    %457 = "comb.extract"(%arg21) <{lowBit = 0 : i32}> {sv.namehint = "_dmisalign_T"} : (i32) -> i2
    %458 = "comb.icmp"(%457, %357) <{predicate = 1 : i64, twoState}> {sv.namehint = "_dmisalign_T_1"} : (i2, i2) -> i1
    %459 = "comb.and"(%arg20, %458) <{twoState}> {sv.namehint = "dmisalign"} : (i1, i1) -> i1
    %460 = "comb.or"(%445, %446, %arg15, %451, %452, %453, %456, %459) <{twoState}> {sv.namehint = "exception"} : (i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %461 = "comb.extract"(%arg24) <{lowBit = 2 : i32}> : (i32) -> i30
    %462 = "comb.concat"(%461, %357) : (i30, i2) -> i32
    %463 = "comb.and"(%445, %444) <{twoState}> : (i1, i1) -> i1
    %464 = "comb.icmp"(%372, %357) <{predicate = 0 : i64, twoState}> : (i2, i2) -> i1
    %465 = "comb.and"(%445, %464) <{twoState}> : (i1, i1) -> i1
    %466 = "comb.or"(%arg15, %451) <{twoState}> : (i1, i1) -> i1
    %467 = "comb.concat"(%466, %323) : (i1, i1) -> i2
    %468 = "comb.mux"(%446, %324, %467) <{twoState}> : (i1, i2, i2) -> i2
    %469 = "comb.concat"(%357, %468) : (i2, i2) -> i4
    %470 = "comb.mux"(%465, %355, %469) <{twoState}> : (i1, i4, i4) -> i4
    %471 = "comb.mux"(%463, %356, %470) <{twoState}> : (i1, i4, i4) -> i4
    %472 = "comb.mux"(%459, %359, %471) <{twoState}> : (i1, i4, i4) -> i4
    %473 = "comb.mux"(%456, %360, %472) <{twoState}> : (i1, i4, i4) -> i4
    %474 = "comb.mux"(%453, %361, %473) <{twoState}> : (i1, i4, i4) -> i4
    %475 = "comb.mux"(%452, %362, %474) <{twoState}> : (i1, i4, i4) -> i4
    %476 = "comb.concat"(%320, %475) : (i28, i4) -> i32
    %477 = "comb.mux"(%447, %369, %372) <{twoState}> : (i1, i2, i2) -> i2
    %478 = "comb.mux"(%460, %324, %477) <{twoState}> : (i1, i2, i2) -> i2
    %479 = "comb.or"(%460, %447) {sv.namehint = "io_epc_valid"} : (i1, i1) -> i1
    %480 = "comb.mux"(%460, %380, %382) <{twoState}> {sv.namehint = "io_epc_bits"} : (i1, i32, i32) -> i32
    %481 = "comb.extract"(%443) <{lowBit = 11 : i32}> {sv.namehint = "_mpp_T"} : (i32) -> i2
    %482 = "comb.and"(%437, %414) <{twoState}> : (i1, i1) -> i1
    %483 = "comb.mux"(%482, %481, %369) <{twoState}> : (i1, i2, i2) -> i2
    %484 = "comb.mux"(%447, %357, %483) <{twoState}> : (i1, i2, i2) -> i2
    %485 = "comb.mux"(%460, %372, %484) <{twoState}> : (i1, i2, i2) -> i2
    %486 = "comb.extract"(%443) <{lowBit = 7 : i32}> {sv.namehint = "_mpie_T"} : (i32) -> i1
    %487 = "comb.mux"(%482, %486, %370) <{twoState}> : (i1, i1, i1) -> i1
    %488 = "comb.or"(%447, %487) : (i1, i1) -> i1
    %489 = "comb.mux"(%460, %371, %488) <{twoState}> : (i1, i1, i1) -> i1
    %490 = "comb.extract"(%443) <{lowBit = 3 : i32}> {sv.namehint = "_mie_T"} : (i32) -> i1
    %491 = "comb.mux"(%482, %490, %371) <{twoState}> : (i1, i1, i1) -> i1
    %492 = "comb.mux"(%447, %370, %491) <{twoState}> : (i1, i1, i1) -> i1
    %493 = "comb.xor"(%460, %330) : (i1, i1) -> i1
    %494 = "comb.and"(%493, %492) : (i1, i1) -> i1
    %495 = "comb.extract"(%443) <{lowBit = 11 : i32}> {sv.namehint = "_p_T"} : (i32) -> i1
    %496 = "comb.xor"(%394, %330) : (i1, i1) -> i1
    %497 = "comb.xor"(%437, %330) : (i1, i1) -> i1
    %498 = "comb.or"(%460, %447) <{twoState}> : (i1, i1) -> i1
    %499 = "comb.or"(%498, %497, %414, %496) : (i1, i1, i1, i1) -> i1
    %500 = "comb.mux"(%499, %363, %495) <{twoState}> : (i1, i1, i1) -> i1
    %501 = "comb.extract"(%443) <{lowBit = 7 : i32}> {sv.namehint = "_p_T_1"} : (i32) -> i1
    %502 = "comb.xor"(%394, %330) : (i1, i1) -> i1
    %503 = "comb.xor"(%437, %330) : (i1, i1) -> i1
    %504 = "comb.or"(%498, %503, %414, %502) : (i1, i1, i1, i1) -> i1
    %505 = "comb.mux"(%504, %365, %501) <{twoState}> : (i1, i1, i1) -> i1
    %506 = "comb.extract"(%443) <{lowBit = 3 : i32}> {sv.namehint = "_p_T_2"} : (i32) -> i1
    %507 = "comb.xor"(%394, %330) : (i1, i1) -> i1
    %508 = "comb.xor"(%437, %330) : (i1, i1) -> i1
    %509 = "comb.or"(%498, %508, %414, %507) : (i1, i1, i1, i1) -> i1
    %510 = "comb.mux"(%509, %367, %506) <{twoState}> : (i1, i1, i1) -> i1
    %511 = "comb.extract"(%443) <{lowBit = 11 : i32}> {sv.namehint = "_e_T"} : (i32) -> i1
    %512 = "comb.or"(%414, %394) <{twoState}> : (i1, i1) -> i1
    %513 = "comb.xor"(%400, %330) : (i1, i1) -> i1
    %514 = "comb.xor"(%437, %330) : (i1, i1) -> i1
    %515 = "comb.or"(%498, %514, %512, %513) : (i1, i1, i1, i1) -> i1
    %516 = "comb.mux"(%515, %364, %511) <{twoState}> : (i1, i1, i1) -> i1
    %517 = "comb.extract"(%443) <{lowBit = 7 : i32}> {sv.namehint = "_e_T_1"} : (i32) -> i1
    %518 = "comb.xor"(%400, %330) : (i1, i1) -> i1
    %519 = "comb.xor"(%437, %330) : (i1, i1) -> i1
    %520 = "comb.or"(%498, %519, %512, %518) : (i1, i1, i1, i1) -> i1
    %521 = "comb.mux"(%520, %366, %517) <{twoState}> : (i1, i1, i1) -> i1
    %522 = "comb.extract"(%443) <{lowBit = 3 : i32}> {sv.namehint = "_e_T_2"} : (i32) -> i1
    %523 = "comb.xor"(%400, %330) : (i1, i1) -> i1
    %524 = "comb.xor"(%437, %330) : (i1, i1) -> i1
    %525 = "comb.or"(%498, %524, %512, %523) : (i1, i1, i1, i1) -> i1
    %526 = "comb.mux"(%525, %368, %522) <{twoState}> : (i1, i1, i1) -> i1
    %527 = "comb.xor"(%406, %330) : (i1, i1) -> i1
    %528 = "comb.xor"(%437, %330) : (i1, i1) -> i1
    %529 = "comb.or"(%498, %528, %414, %394, %400, %527) : (i1, i1, i1, i1, i1, i1) -> i1
    %530 = "comb.mux"(%529, %381, %443) <{twoState}> : (i1, i32, i32) -> i32
    %531 = "comb.xor"(%426, %330) : (i1, i1) -> i1
    %532 = "comb.xor"(%437, %330) : (i1, i1) -> i1
    %533 = "comb.or"(%498, %532, %414, %394, %400, %406, %531) : (i1, i1, i1, i1, i1, i1, i1) -> i1
    %534 = "comb.mux"(%533, %380, %443) <{twoState}> : (i1, i32, i32) -> i32
    %535 = "comb.extract"(%443) <{lowBit = 2 : i32}> : (i32) -> i30
    %536 = "comb.concat"(%535, %357) : (i30, i2) -> i32
    %537 = "comb.xor"(%412, %330) : (i1, i1) -> i1
    %538 = "comb.xor"(%437, %330) : (i1, i1) -> i1
    %539 = "comb.or"(%447, %538, %414, %394, %400, %406, %426, %537) : (i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %540 = "comb.mux"(%539, %382, %536) <{twoState}> : (i1, i32, i32) -> i32
    %541 = "comb.mux"(%460, %462, %540) <{twoState}> : (i1, i32, i32) -> i32
    %542 = "comb.xor"(%402, %330) : (i1, i1) -> i1
    %543 = "comb.xor"(%437, %330) : (i1, i1) -> i1
    %544 = "comb.or"(%447, %543, %414, %394, %400, %406, %426, %412, %542) : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i1
    %545 = "comb.mux"(%544, %383, %443) <{twoState}> : (i1, i32, i32) -> i32
    %546 = "comb.mux"(%460, %476, %545) <{twoState}> : (i1, i32, i32) -> i32
    "hw.output"(%479, %480, %431) : (i1, i32, i32) -> ()
  }) {sym_visibility = "private"} : () -> ()
  "hw.module"() <{module_type = !hw.modty<input io_inst : i32, output io_sig_pc_sel : i2, output io_sig_a_sel : i2, output io_sig_b_sel : i2, output io_sig_imm_sel : i3, output io_sig_alu_op : i4, output io_sig_br_type : i3, output io_sig_inst_kill : i1, output io_sig_st_type : i2, output io_sig_ld_type : i3, output io_sig_wb_sel : i2, output io_sig_wb_en : i1, output io_sig_illegal : i1, output io_sig_csr_type : i3>, parameters = [], result_locs = [#loc23, #loc24, #loc25, #loc26, #loc27, #loc28, #loc29, #loc30, #loc31, #loc32, #loc33, #loc34, #loc35], sym_name = "Control"}> ({
  ^bb0(%arg11: i32):
    %70 = "hw.constant"() <{value = 0 : i16}> : () -> i16
    %71 = "hw.constant"() <{value = 0 : i6}> : () -> i6
    %72 = "hw.constant"() <{value = 0 : i17}> : () -> i17
    %73 = "hw.constant"() <{value = 0 : i5}> : () -> i5
    %74 = "hw.constant"() <{value = 0 : i13}> : () -> i13
    %75 = "hw.constant"() <{value = 0 : i14}> : () -> i14
    %76 = "hw.constant"() <{value = 0 : i7}> : () -> i7
    %77 = "hw.constant"() <{value = 0 : i11}> : () -> i11
    %78 = "hw.constant"() <{value = 0 : i8}> : () -> i8
    %79 = "hw.constant"() <{value = 0 : i9}> : () -> i9
    %80 = "hw.constant"() <{value = 0 : i18}> : () -> i18
    %81 = "hw.constant"() <{value = 0 : i20}> : () -> i20
    %82 = "hw.constant"() <{value = 0 : i2}> : () -> i2
    %83 = "hw.constant"() <{value = 0 : i3}> : () -> i3
    %84 = "hw.constant"() <{value = -1 : i17}> : () -> i17
    %85 = "hw.constant"() <{value = -1 : i30}> : () -> i30
    %86 = "hw.constant"() <{value = -1 : i15}> : () -> i15
    %87 = "hw.constant"() <{value = -1 : i16}> : () -> i16
    %88 = "hw.constant"() <{value = -1 : i10}> : () -> i10
    %89 = "hw.constant"() <{value = -1 : i28}> : () -> i28
    %90 = "hw.constant"() <{value = -1 : i6}> : () -> i6
    %91 = "hw.constant"() <{value = -1 : i7}> : () -> i7
    %92 = "hw.constant"() <{value = -1 : i31}> : () -> i31
    %93 = "hw.constant"() <{value = -1 : i24}> : () -> i24
    %94 = "hw.constant"() <{value = -1 : i14}> : () -> i14
    %95 = "hw.constant"() <{value = -1 : i9}> : () -> i9
    %96 = "hw.constant"() <{value = -1 : i8}> : () -> i8
    %97 = "comb.extract"(%arg11) <{lowBit = 2 : i32}> : (i32) -> i30
    %98 = "comb.xor"(%97, %85) <{twoState}> {sv.namehint = "io_sig_invInputs"} : (i30, i30) -> i30
    %99 = "comb.extract"(%arg11) <{lowBit = 0 : i32}> {sv.namehint = "io_sig_andMatrixInput_0"} : (i32) -> i1
    %100 = "comb.extract"(%arg11) <{lowBit = 1 : i32}> {sv.namehint = "io_sig_andMatrixInput_1"} : (i32) -> i1
    %101 = "comb.extract"(%98) <{lowBit = 0 : i32}> {sv.namehint = "io_sig_andMatrixInput_2"} : (i30) -> i1
    %102 = "comb.extract"(%98) <{lowBit = 1 : i32}> {sv.namehint = "io_sig_andMatrixInput_3"} : (i30) -> i1
    %103 = "comb.extract"(%98) <{lowBit = 2 : i32}> {sv.namehint = "io_sig_andMatrixInput_4"} : (i30) -> i1
    %104 = "comb.extract"(%98) <{lowBit = 3 : i32}> {sv.namehint = "io_sig_andMatrixInput_5"} : (i30) -> i1
    %105 = "comb.extract"(%98) <{lowBit = 4 : i32}> {sv.namehint = "io_sig_andMatrixInput_6"} : (i30) -> i1
    %106 = "comb.extract"(%98) <{lowBit = 11 : i32}> {sv.namehint = "io_sig_andMatrixInput_7"} : (i30) -> i1
    %107 = "comb.concat"(%99, %100, %101, %102, %103, %104, %105, %106) {sv.namehint = "_io_sig_T"} : (i1, i1, i1, i1, i1, i1, i1, i1) -> i8
    %108 = "comb.icmp"(%107, %96) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_1"} : (i8, i8) -> i1
    %109 = "comb.extract"(%98) <{lowBit = 10 : i32}> {sv.namehint = "io_sig_andMatrixInput_7_1"} : (i30) -> i1
    %110 = "comb.concat"(%99, %100, %101, %102, %103, %104, %105, %109, %106) {sv.namehint = "_io_sig_T_2"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %111 = "comb.icmp"(%110, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_3"} : (i9, i9) -> i1
    %112 = "comb.extract"(%98) <{lowBit = 12 : i32}> {sv.namehint = "io_sig_andMatrixInput_14"} : (i30) -> i1
    %113 = "comb.concat"(%99, %100, %101, %102, %103, %105, %109, %112) {sv.namehint = "_io_sig_T_4"} : (i1, i1, i1, i1, i1, i1, i1, i1) -> i8
    %114 = "comb.icmp"(%113, %96) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_5"} : (i8, i8) -> i1
    %115 = "comb.concat"(%99, %100, %101, %102, %103, %104, %105, %109, %112) {sv.namehint = "_io_sig_T_6"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %116 = "comb.icmp"(%115, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_7"} : (i9, i9) -> i1
    %117 = "comb.concat"(%99, %100, %101, %102, %103, %104, %105, %106, %112) {sv.namehint = "_io_sig_T_8"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %118 = "comb.icmp"(%117, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_9"} : (i9, i9) -> i1
    %119 = "comb.concat"(%99, %100, %101, %102, %104, %105, %109, %106, %112) {sv.namehint = "_io_sig_T_10"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %120 = "comb.icmp"(%119, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_11"} : (i9, i9) -> i1
    %121 = "comb.extract"(%98) <{lowBit = 23 : i32}> {sv.namehint = "io_sig_andMatrixInput_24"} : (i30) -> i1
    %122 = "comb.extract"(%98) <{lowBit = 24 : i32}> {sv.namehint = "io_sig_andMatrixInput_9"} : (i30) -> i1
    %123 = "comb.extract"(%98) <{lowBit = 25 : i32}> {sv.namehint = "io_sig_andMatrixInput_10"} : (i30) -> i1
    %124 = "comb.extract"(%98) <{lowBit = 26 : i32}> {sv.namehint = "io_sig_andMatrixInput_11"} : (i30) -> i1
    %125 = "comb.extract"(%98) <{lowBit = 27 : i32}> {sv.namehint = "io_sig_andMatrixInput_12"} : (i30) -> i1
    %126 = "comb.extract"(%98) <{lowBit = 29 : i32}> {sv.namehint = "io_sig_andMatrixInput_13"} : (i30) -> i1
    %127 = "comb.concat"(%99, %100, %101, %102, %105, %109, %106, %112, %121, %122, %123, %124, %125, %126) {sv.namehint = "_io_sig_T_12"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i14
    %128 = "comb.icmp"(%127, %94) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_13"} : (i14, i14) -> i1
    %129 = "comb.extract"(%arg11) <{lowBit = 2 : i32}> {sv.namehint = "io_sig_andMatrixInput_2_7"} : (i32) -> i1
    %130 = "comb.extract"(%arg11) <{lowBit = 3 : i32}> {sv.namehint = "io_sig_andMatrixInput_3_7"} : (i32) -> i1
    %131 = "comb.extract"(%98) <{lowBit = 5 : i32}> {sv.namehint = "io_sig_andMatrixInput_7_7"} : (i30) -> i1
    %132 = "comb.extract"(%98) <{lowBit = 6 : i32}> {sv.namehint = "io_sig_andMatrixInput_8_5"} : (i30) -> i1
    %133 = "comb.extract"(%98) <{lowBit = 7 : i32}> {sv.namehint = "io_sig_andMatrixInput_9_1"} : (i30) -> i1
    %134 = "comb.extract"(%98) <{lowBit = 8 : i32}> {sv.namehint = "io_sig_andMatrixInput_9_6"} : (i30) -> i1
    %135 = "comb.extract"(%98) <{lowBit = 9 : i32}> {sv.namehint = "io_sig_andMatrixInput_11_1"} : (i30) -> i1
    %136 = "comb.extract"(%98) <{lowBit = 13 : i32}> {sv.namehint = "io_sig_andMatrixInput_15"} : (i30) -> i1
    %137 = "comb.extract"(%98) <{lowBit = 14 : i32}> {sv.namehint = "io_sig_andMatrixInput_16"} : (i30) -> i1
    %138 = "comb.extract"(%98) <{lowBit = 15 : i32}> {sv.namehint = "io_sig_andMatrixInput_17"} : (i30) -> i1
    %139 = "comb.extract"(%98) <{lowBit = 16 : i32}> {sv.namehint = "io_sig_andMatrixInput_18"} : (i30) -> i1
    %140 = "comb.extract"(%98) <{lowBit = 17 : i32}> {sv.namehint = "io_sig_andMatrixInput_19"} : (i30) -> i1
    %141 = "comb.extract"(%98) <{lowBit = 28 : i32}> {sv.namehint = "io_sig_andMatrixInput_22"} : (i30) -> i1
    %142 = "comb.concat"(%99, %100, %129, %130, %103, %104, %105, %131, %132, %133, %134, %135, %109, %106, %112, %136, %137, %138, %139, %140, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_14"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i24
    %143 = "comb.icmp"(%142, %93) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_15"} : (i24, i24) -> i1
    %144 = "comb.extract"(%98) <{lowBit = 18 : i32}> {sv.namehint = "io_sig_andMatrixInput_19_1"} : (i30) -> i1
    %145 = "comb.extract"(%98) <{lowBit = 19 : i32}> {sv.namehint = "io_sig_andMatrixInput_20_1"} : (i30) -> i1
    %146 = "comb.extract"(%98) <{lowBit = 20 : i32}> {sv.namehint = "io_sig_andMatrixInput_21_1"} : (i30) -> i1
    %147 = "comb.extract"(%98) <{lowBit = 21 : i32}> {sv.namehint = "io_sig_andMatrixInput_22_1"} : (i30) -> i1
    %148 = "comb.extract"(%98) <{lowBit = 22 : i32}> {sv.namehint = "io_sig_andMatrixInput_23_1"} : (i30) -> i1
    %149 = "comb.concat"(%99, %100, %129, %130, %103, %104, %105, %131, %132, %133, %134, %135, %106, %112, %136, %137, %138, %139, %140, %144, %145, %146, %147, %148, %121, %122, %123, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_16"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i31
    %150 = "comb.icmp"(%149, %92) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_17"} : (i31, i31) -> i1
    %151 = "comb.extract"(%arg11) <{lowBit = 4 : i32}> {sv.namehint = "io_sig_andMatrixInput_3_9"} : (i32) -> i1
    %152 = "comb.concat"(%99, %100, %102, %151, %104, %105, %109) {sv.namehint = "_io_sig_T_18"} : (i1, i1, i1, i1, i1, i1, i1) -> i7
    %153 = "comb.icmp"(%152, %91) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_19"} : (i7, i7) -> i1
    %154 = "comb.concat"(%99, %100, %101, %102, %151, %104, %105, %109) {sv.namehint = "_io_sig_T_20"} : (i1, i1, i1, i1, i1, i1, i1, i1) -> i8
    %155 = "comb.icmp"(%154, %96) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_21"} : (i8, i8) -> i1
    %156 = "comb.concat"(%99, %100, %101, %102, %151, %105, %109, %121, %122, %123, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_22"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i14
    %157 = "comb.icmp"(%156, %94) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_23"} : (i14, i14) -> i1
    %158 = "comb.concat"(%99, %100, %101, %102, %151, %105, %112, %121, %122, %123, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_24"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i14
    %159 = "comb.icmp"(%158, %94) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_25"} : (i14, i14) -> i1
    %160 = "comb.concat"(%99, %100, %129, %102, %151, %105) {sv.namehint = "_io_sig_T_26"} : (i1, i1, i1, i1, i1, i1) -> i6
    %161 = "comb.icmp"(%160, %90) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_27"} : (i6, i6) -> i1
    %162 = "comb.concat"(%99, %100, %129, %102, %151, %104, %105) {sv.namehint = "_io_sig_T_28"} : (i1, i1, i1, i1, i1, i1, i1) -> i7
    %163 = "comb.icmp"(%162, %91) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_29"} : (i7, i7) -> i1
    %164 = "comb.extract"(%arg11) <{lowBit = 5 : i32}> {sv.namehint = "io_sig_andMatrixInput_5_15"} : (i32) -> i1
    %165 = "comb.concat"(%99, %100, %101, %102, %103, %164, %105, %109, %112) {sv.namehint = "_io_sig_T_30"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %166 = "comb.icmp"(%165, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_11"} : (i9, i9) -> i1
    %167 = "comb.concat"(%99, %100, %101, %102, %103, %164, %106, %112) {sv.namehint = "_io_sig_T_32"} : (i1, i1, i1, i1, i1, i1, i1, i1) -> i8
    %168 = "comb.icmp"(%167, %96) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_33"} : (i8, i8) -> i1
    %169 = "comb.concat"(%99, %100, %101, %102, %103, %164, %105, %106, %112) {sv.namehint = "_io_sig_T_34"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %170 = "comb.icmp"(%169, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_12"} : (i9, i9) -> i1
    %171 = "comb.concat"(%99, %100, %101, %102, %151, %164, %105, %121, %122, %123, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_36"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i14
    %172 = "comb.icmp"(%171, %94) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_37"} : (i14, i14) -> i1
    %173 = "comb.concat"(%99, %100, %101, %102, %151, %164, %131, %132, %133, %134, %135, %112, %136, %137, %138, %139, %140, %145, %146, %147, %148, %121, %122, %123, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_38"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i28
    %174 = "comb.icmp"(%173, %89) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_39"} : (i28, i28) -> i1
    %175 = "comb.concat"(%99, %100, %129, %102, %151, %164, %105) {sv.namehint = "_io_sig_T_40"} : (i1, i1, i1, i1, i1, i1, i1) -> i7
    %176 = "comb.icmp"(%175, %91) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_41"} : (i7, i7) -> i1
    %177 = "comb.extract"(%arg11) <{lowBit = 6 : i32}> {sv.namehint = "io_sig_andMatrixInput_6_20"} : (i32) -> i1
    %178 = "comb.concat"(%99, %100, %101, %102, %103, %164, %177, %109, %106) {sv.namehint = "_io_sig_T_42"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %179 = "comb.icmp"(%178, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_43"} : (i9, i9) -> i1
    %180 = "comb.concat"(%99, %100, %102, %103, %164, %177, %109, %106, %112) {sv.namehint = "_io_sig_T_44"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %181 = "comb.icmp"(%180, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_45"} : (i9, i9) -> i1
    %182 = "comb.concat"(%99, %100, %101, %102, %103, %164, %177, %109, %106, %112) {sv.namehint = "_io_sig_T_46"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i10
    %183 = "comb.icmp"(%182, %88) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_47"} : (i10, i10) -> i1
    %184 = "comb.concat"(%99, %100, %129, %102, %103, %164, %177, %109, %106, %112) {sv.namehint = "_io_sig_T_48"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i10
    %185 = "comb.icmp"(%184, %88) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_49"} : (i10, i10) -> i1
    %186 = "comb.concat"(%99, %100, %129, %130, %103, %164, %177) {sv.namehint = "_io_sig_T_50"} : (i1, i1, i1, i1, i1, i1, i1) -> i7
    %187 = "comb.icmp"(%186, %91) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_51"} : (i7, i7) -> i1
    %188 = "comb.concat"(%99, %100, %101, %102, %151, %164, %177, %131, %132, %133, %134, %135, %109, %106, %112, %136, %137, %138, %139, %140, %145, %146, %147, %148, %121, %122, %123, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_52"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i31
    %189 = "comb.icmp"(%188, %92) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_53"} : (i31, i31) -> i1
    %190 = "comb.extract"(%arg11) <{lowBit = 12 : i32}> {sv.namehint = "io_sig_andMatrixInput_7_22"} : (i32) -> i1
    %191 = "comb.concat"(%99, %100, %101, %102, %151, %104, %105, %190, %112, %121, %122, %123, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_54"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i16
    %192 = "comb.icmp"(%191, %87) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_55"} : (i16, i16) -> i1
    %193 = "comb.concat"(%99, %100, %101, %102, %151, %164, %190, %112, %121, %122, %123, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_56"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i15
    %194 = "comb.icmp"(%193, %86) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_57"} : (i15, i15) -> i1
    %195 = "comb.concat"(%99, %100, %101, %102, %103, %164, %177, %190, %106, %112) {sv.namehint = "_io_sig_T_58"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i10
    %196 = "comb.icmp"(%195, %88) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_59"} : (i10, i10) -> i1
    %197 = "comb.concat"(%99, %100, %101, %102, %151, %164, %177, %190) {sv.namehint = "_io_sig_T_60"} : (i1, i1, i1, i1, i1, i1, i1, i1) -> i8
    %198 = "comb.icmp"(%197, %96) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_61"} : (i8, i8) -> i1
    %199 = "comb.concat"(%99, %100, %101, %102, %151, %164, %177, %190, %112) {sv.namehint = "_io_sig_T_62"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %200 = "comb.icmp"(%199, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_63"} : (i9, i9) -> i1
    %201 = "comb.extract"(%arg11) <{lowBit = 13 : i32}> {sv.namehint = "io_sig_andMatrixInput_6_31"} : (i32) -> i1
    %202 = "comb.concat"(%99, %100, %102, %151, %104, %105, %201) {sv.namehint = "_io_sig_T_64"} : (i1, i1, i1, i1, i1, i1, i1) -> i7
    %203 = "comb.icmp"(%202, %91) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_65"} : (i7, i7) -> i1
    %204 = "comb.concat"(%99, %100, %101, %102, %151, %104, %105, %109, %201) {sv.namehint = "_io_sig_T_66"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %205 = "comb.icmp"(%204, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_67"} : (i9, i9) -> i1
    %206 = "comb.concat"(%99, %100, %101, %102, %151, %105, %109, %201, %121, %122, %123, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_68"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i15
    %207 = "comb.icmp"(%206, %86) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_69"} : (i15, i15) -> i1
    %208 = "comb.concat"(%99, %100, %101, %102, %151, %105, %201, %112, %121, %122, %123, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_70"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i15
    %209 = "comb.icmp"(%208, %86) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_71"} : (i15, i15) -> i1
    %210 = "comb.concat"(%99, %100, %101, %102, %151, %164, %177, %201) {sv.namehint = "_io_sig_T_72"} : (i1, i1, i1, i1, i1, i1, i1, i1) -> i8
    %211 = "comb.icmp"(%210, %96) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_73"} : (i8, i8) -> i1
    %212 = "comb.concat"(%99, %100, %101, %102, %151, %164, %177, %201, %112) {sv.namehint = "_io_sig_T_74"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %213 = "comb.icmp"(%212, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_75"} : (i9, i9) -> i1
    %214 = "comb.concat"(%99, %100, %101, %102, %151, %104, %105, %190, %201, %112) {sv.namehint = "_io_sig_T_76"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i10
    %215 = "comb.icmp"(%214, %88) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_77"} : (i10, i10) -> i1
    %216 = "comb.extract"(%arg11) <{lowBit = 14 : i32}> {sv.namehint = "io_sig_andMatrixInput_8_27"} : (i32) -> i1
    %217 = "comb.concat"(%99, %100, %101, %102, %103, %104, %105, %106, %216) {sv.namehint = "_io_sig_T_78"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %218 = "comb.icmp"(%217, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_10"} : (i9, i9) -> i1
    %219 = "comb.concat"(%99, %100, %101, %102, %151, %104, %105, %216, %121, %122, %123, %124, %125, %126) {sv.namehint = "_io_sig_T_80"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i14
    %220 = "comb.icmp"(%219, %94) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_81"} : (i14, i14) -> i1
    %221 = "comb.concat"(%99, %100, %101, %102, %103, %164, %177, %216) {sv.namehint = "_io_sig_T_82"} : (i1, i1, i1, i1, i1, i1, i1, i1) -> i8
    %222 = "comb.icmp"(%221, %96) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_83"} : (i8, i8) -> i1
    %223 = "comb.concat"(%99, %100, %102, %151, %105, %190, %106, %216, %121, %122, %123, %124, %125, %126) {sv.namehint = "_io_sig_T_84"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i14
    %224 = "comb.icmp"(%223, %94) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_85"} : (i14, i14) -> i1
    %225 = "comb.concat"(%99, %100, %101, %102, %151, %164, %105, %190, %106, %216, %121, %122, %123, %124, %125, %126) {sv.namehint = "_io_sig_T_86"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i16
    %226 = "comb.icmp"(%225, %87) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_87"} : (i16, i16) -> i1
    %227 = "comb.concat"(%99, %100, %101, %102, %103, %164, %177, %190, %216) {sv.namehint = "_io_sig_T_88"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %228 = "comb.icmp"(%227, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_89"} : (i9, i9) -> i1
    %229 = "comb.concat"(%99, %100, %101, %102, %103, %164, %177, %190, %106, %216) {sv.namehint = "_io_sig_T_90"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i10
    %230 = "comb.icmp"(%229, %88) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_91"} : (i10, i10) -> i1
    %231 = "comb.concat"(%99, %100, %101, %102, %151, %164, %177, %190, %216) {sv.namehint = "_io_sig_T_92"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %232 = "comb.icmp"(%231, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_93"} : (i9, i9) -> i1
    %233 = "comb.concat"(%99, %100, %102, %151, %104, %105, %201, %216) {sv.namehint = "_io_sig_T_94"} : (i1, i1, i1, i1, i1, i1, i1, i1) -> i8
    %234 = "comb.icmp"(%233, %96) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_95"} : (i8, i8) -> i1
    %235 = "comb.concat"(%99, %100, %101, %102, %151, %104, %105, %201, %216) {sv.namehint = "_io_sig_T_96"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %236 = "comb.icmp"(%235, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_97"} : (i9, i9) -> i1
    %237 = "comb.concat"(%99, %100, %101, %102, %151, %105, %201, %216, %121, %122, %123, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_98"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i15
    %238 = "comb.icmp"(%237, %86) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_99"} : (i15, i15) -> i1
    %239 = "comb.concat"(%99, %100, %101, %102, %103, %164, %177, %109, %201, %216) {sv.namehint = "_io_sig_T_100"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i10
    %240 = "comb.icmp"(%239, %88) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_101"} : (i10, i10) -> i1
    %241 = "comb.concat"(%99, %100, %101, %102, %151, %164, %177, %201, %216) {sv.namehint = "_io_sig_T_102"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %242 = "comb.icmp"(%241, %95) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_103"} : (i9, i9) -> i1
    %243 = "comb.extract"(%arg11) <{lowBit = 20 : i32}> {sv.namehint = "io_sig_andMatrixInput_19_4"} : (i32) -> i1
    %244 = "comb.concat"(%99, %100, %101, %102, %151, %164, %177, %131, %132, %133, %134, %135, %106, %112, %136, %137, %138, %139, %140, %243, %145, %146, %147, %148, %121, %122, %123, %124, %125, %141, %126) {sv.namehint = "_io_sig_T_104"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i31
    %245 = "comb.icmp"(%244, %92) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_105"} : (i31, i31) -> i1
    %246 = "comb.extract"(%arg11) <{lowBit = 21 : i32}> {sv.namehint = "io_sig_andMatrixInput_19_5"} : (i32) -> i1
    %247 = "comb.concat"(%99, %100, %101, %102, %151, %164, %177, %131, %132, %133, %134, %135, %112, %136, %137, %138, %139, %140, %144, %246, %146, %147, %148, %121, %122, %123, %141, %126) {sv.namehint = "_io_sig_T_106"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i28
    %248 = "comb.icmp"(%247, %89) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_107"} : (i28, i28) -> i1
    %249 = "comb.concat"(%99, %100, %101, %102, %151, %164, %177, %131, %132, %133, %134, %135, %109, %106, %112, %136, %137, %138, %139, %140, %144, %246, %146, %147, %148, %121, %122, %123, %141, %126) {sv.namehint = "_io_sig_T_108"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i30
    %250 = "comb.icmp"(%249, %85) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_109"} : (i30, i30) -> i1
    %251 = "comb.extract"(%arg11) <{lowBit = 30 : i32}> {sv.namehint = "io_sig_andMatrixInput_15_9"} : (i32) -> i1
    %252 = "comb.concat"(%99, %100, %101, %102, %151, %164, %105, %109, %106, %112, %121, %122, %123, %124, %125, %251, %126) {sv.namehint = "_io_sig_T_110"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i17
    %253 = "comb.icmp"(%252, %84) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_111"} : (i17, i17) -> i1
    %254 = "comb.concat"(%99, %100, %101, %102, %151, %105, %190, %106, %216, %121, %122, %123, %124, %125, %251, %126) {sv.namehint = "_io_sig_T_112"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i16
    %255 = "comb.icmp"(%254, %87) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_T_113"} : (i16, i16) -> i1
    %256 = "comb.concat"(%200, %232, %245) {sv.namehint = "_io_sig_orMatrixOutputs_T"} : (i1, i1, i1) -> i3
    %257 = "comb.icmp"(%256, %83) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T"} : (i3, i3) -> i1
    %258 = "comb.concat"(%213, %242, %250) {sv.namehint = "_io_sig_orMatrixOutputs_T_2"} : (i1, i1, i1) -> i3
    %259 = "comb.icmp"(%258, %83) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_1"} : (i3, i3) -> i1
    %260 = "comb.concat"(%189, %250) {sv.namehint = "_io_sig_orMatrixOutputs_T_4"} : (i1, i1) -> i2
    %261 = "comb.icmp"(%260, %82) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_2"} : (i2, i2) -> i1
    %262 = "comb.concat"(%108, %114, %128, %143, %150, %153, %157, %159, %161, %168, %174, %181, %187, %198, %203, %211, %222, %224, %238, %248) {sv.namehint = "_io_sig_orMatrixOutputs_T_6"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i20
    %263 = "comb.concat"(%116, %118, %155, %161, %172, %185, %187, %192, %200, %213, %215, %218, %220, %226, %232, %236, %242, %253) {sv.namehint = "_io_sig_orMatrixOutputs_T_8"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i18
    %264 = "comb.icmp"(%263, %80) <{predicate = 1 : i64, twoState}> {sv.namehint = "io_sig_wb_en"} : (i18, i18) -> i1
    %265 = "comb.concat"(%116, %118, %189, %200, %213, %218, %232, %242, %250) {sv.namehint = "_io_sig_orMatrixOutputs_T_10"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %266 = "comb.icmp"(%265, %79) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_6"} : (i9, i9) -> i1
    %267 = "comb.concat"(%185, %187, %189, %200, %213, %232, %242, %250) {sv.namehint = "_io_sig_orMatrixOutputs_T_12"} : (i1, i1, i1, i1, i1, i1, i1, i1) -> i8
    %268 = "comb.icmp"(%267, %78) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_7"} : (i8, i8) -> i1
    %269 = "comb.concat"(%111, %116) {sv.namehint = "_io_sig_orMatrixOutputs_T_14"} : (i1, i1) -> i2
    %270 = "comb.icmp"(%269, %82) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_8"} : (i2, i2) -> i1
    %271 = "comb.concat"(%116, %118, %185, %187, %189, %200, %213, %218, %232, %242, %250) {sv.namehint = "_io_sig_orMatrixOutputs_T_20"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i11
    %272 = "comb.icmp"(%271, %77) <{predicate = 1 : i64, twoState}> {sv.namehint = "io_sig_inst_kill"} : (i11, i11) -> i1
    %273 = "comb.concat"(%183, %230, %240) {sv.namehint = "_io_sig_orMatrixOutputs_T_22"} : (i1, i1, i1) -> i3
    %274 = "comb.icmp"(%273, %83) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_14"} : (i3, i3) -> i1
    %275 = "comb.concat"(%179, %196) {sv.namehint = "_io_sig_orMatrixOutputs_T_24"} : (i1, i1) -> i2
    %276 = "comb.icmp"(%275, %82) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_15"} : (i2, i2) -> i1
    %277 = "comb.concat"(%196, %228) {sv.namehint = "io_sig_orMatrixOutputs_hi_lo_10"} : (i1, i1) -> i2
    %278 = "comb.icmp"(%277, %82) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_16"} : (i2, i2) -> i1
    %279 = "comb.concat"(%176, %205, %207, %209, %215, %253, %255) {sv.namehint = "_io_sig_orMatrixOutputs_T_28"} : (i1, i1, i1, i1, i1, i1, i1) -> i7
    %280 = "comb.icmp"(%279, %76) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_17"} : (i7, i7) -> i1
    %281 = "comb.concat"(%176, %192, %194, %200, %213, %215, %236, %238) {sv.namehint = "_io_sig_orMatrixOutputs_T_30"} : (i1, i1, i1, i1, i1, i1, i1, i1) -> i8
    %282 = "comb.icmp"(%281, %78) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_18"} : (i8, i8) -> i1
    %283 = "comb.concat"(%108, %114, %120, %128, %161, %168, %181, %187, %200, %213, %222, %224, %234, %238) {sv.namehint = "_io_sig_orMatrixOutputs_T_32"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i14
    %284 = "comb.concat"(%108, %114, %128, %153, %157, %159, %163, %168, %181, %187, %203, %222, %238) {sv.namehint = "_io_sig_orMatrixOutputs_T_34"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i13
    %285 = "comb.concat"(%116, %118, %155, %161, %179, %185, %192, %196, %215, %218, %220, %228, %236, %240) {sv.namehint = "_io_sig_orMatrixOutputs_T_36"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i14
    %286 = "comb.icmp"(%285, %75) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_23"} : (i14, i14) -> i1
    %287 = "comb.concat"(%161, %166, %170, %232, %242) {sv.namehint = "_io_sig_orMatrixOutputs_T_38"} : (i1, i1, i1, i1, i1) -> i5
    %288 = "comb.icmp"(%287, %73) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_24"} : (i5, i5) -> i1
    %289 = "comb.concat"(%179, %187, %196, %228, %232, %240, %242) {sv.namehint = "_io_sig_orMatrixOutputs_T_40"} : (i1, i1, i1, i1, i1, i1, i1) -> i7
    %290 = "comb.icmp"(%289, %76) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_25"} : (i7, i7) -> i1
    %291 = "comb.concat"(%116, %118, %155, %161, %166, %170, %179, %185, %187, %192, %196, %215, %218, %220, %228, %236, %240) {sv.namehint = "_io_sig_orMatrixOutputs_T_42"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i17
    %292 = "comb.icmp"(%291, %72) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_26"} : (i17, i17) -> i1
    %293 = "comb.concat"(%172, %226, %253) {sv.namehint = "_io_sig_orMatrixOutputs_T_44"} : (i1, i1, i1) -> i3
    %294 = "comb.icmp"(%293, %83) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_27"} : (i3, i3) -> i1
    %295 = "comb.concat"(%161, %179, %187, %196, %228, %240) {sv.namehint = "_io_sig_orMatrixOutputs_T_46"} : (i1, i1, i1, i1, i1, i1) -> i6
    %296 = "comb.icmp"(%295, %71) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_28"} : (i6, i6) -> i1
    %297 = "comb.concat"(%116, %118, %155, %166, %170, %172, %185, %192, %200, %213, %215, %218, %220, %226, %236, %253) {sv.namehint = "_io_sig_orMatrixOutputs_T_48"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i16
    %298 = "comb.icmp"(%297, %70) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_29"} : (i16, i16) -> i1
    %299 = "comb.concat"(%185, %187, %250) {sv.namehint = "_io_sig_orMatrixOutputs_T_50"} : (i1, i1, i1) -> i3
    %300 = "comb.icmp"(%299, %83) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_30"} : (i3, i3) -> i1
    %301 = "comb.concat"(%116, %118, %189, %200, %213, %218, %232, %242, %250) {sv.namehint = "_io_sig_orMatrixOutputs_T_52"} : (i1, i1, i1, i1, i1, i1, i1, i1, i1) -> i9
    %302 = "comb.icmp"(%301, %79) <{predicate = 1 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_31"} : (i9, i9) -> i1
    %303 = "comb.icmp"(%262, %81) <{predicate = 0 : i64, twoState}> {sv.namehint = "io_sig_illegal"} : (i20, i20) -> i1
    %304 = "comb.icmp"(%283, %75) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_20"} : (i14, i14) -> i1
    %305 = "comb.icmp"(%284, %74) <{predicate = 0 : i64, twoState}> {sv.namehint = "_io_sig_invMatrixOutputs_T_22"} : (i13, i13) -> i1
    %306 = "comb.concat"(%261, %259, %257) {sv.namehint = "io_sig_csr_type"} : (i1, i1, i1) -> i3
    %307 = "comb.concat"(%268, %266) {sv.namehint = "io_sig_wb_sel"} : (i1, i1) -> i2
    %308 = "comb.concat"(%218, %118, %270) {sv.namehint = "io_sig_ld_type"} : (i1, i1, i1) -> i3
    %309 = "comb.concat"(%170, %166) {sv.namehint = "io_sig_st_type"} : (i1, i1) -> i2
    %310 = "comb.concat"(%278, %276, %274) {sv.namehint = "io_sig_br_type"} : (i1, i1, i1) -> i3
    %311 = "comb.concat"(%305, %304, %282, %280) {sv.namehint = "io_sig_alu_op"} : (i1, i1, i1, i1) -> i4
    %312 = "comb.concat"(%290, %288, %286) {sv.namehint = "io_sig_imm_sel"} : (i1, i1, i1) -> i3
    %313 = "comb.concat"(%294, %292) {sv.namehint = "io_sig_b_sel"} : (i1, i1) -> i2
    %314 = "comb.concat"(%298, %296) {sv.namehint = "io_sig_a_sel"} : (i1, i1) -> i2
    %315 = "comb.concat"(%302, %300) {sv.namehint = "io_sig_pc_sel"} : (i1, i1) -> i2
    "hw.output"(%315, %314, %313, %312, %311, %310, %272, %309, %308, %307, %264, %303, %306) : (i2, i2, i2, i3, i4, i3, i1, i2, i3, i2, i1, i1, i3) -> ()
  }) {sym_visibility = "private"} : () -> ()
  "hw.module"() <{module_type = !hw.modty<input clock : !seq.clock, input reset : i1, output io_imem_req : i1, output io_imem_addr : i32, input io_imem_gnt : i1, input io_imem_rvalid : i1, input io_imem_err : i1, input io_imem_rdata : i32, output io_dmem_req : i1, output io_dmem_addr : i32, output io_dmem_we : i1, output io_dmem_be : i4, output io_dmem_wdata : i32, input io_dmem_gnt : i1, input io_dmem_rvalid : i1, input io_dmem_err : i1, input io_dmem_rdata : i32>, parameters = [], result_locs = [#loc36, #loc37, #loc38, #loc39, #loc40, #loc41, #loc42], sym_name = "Core"}> ({
  ^bb0(%arg1: !seq.clock, %arg2: i1, %arg3: i1, %arg4: i1, %arg5: i1, %arg6: i32, %arg7: i1, %arg8: i1, %arg9: i1, %arg10: i32):
    %0 = "hw.constant"() <{value = 0 : i3}> : () -> i3
    %1 = "hw.constant"() <{value = 0 : i5}> : () -> i5
    %2 = "hw.constant"() <{value = 0 : i27}> : () -> i27
    %3 = "hw.constant"() <{value = 0 : i2}> : () -> i2
    %4 = "hw.constant"() <{value = false}> : () -> i1
    %5 = "hw.constant"() <{value = 19 : i32}> : () -> i32
    %6 = "hw.constant"() <{value = true}> : () -> i1
    %7:2 = "hw.instance"(%arg1, %10#0, %9#9, %9#10, %10#1, %10#2) <{argNames = ["clock", "io_wen", "io_raddr1", "io_raddr2", "io_waddr", "io_wdata"], instanceName = "rf", moduleName = @RegFile, parameters = [], resultNames = ["io_rdata1", "io_rdata2"]}> : (!seq.clock, i1, i5, i5, i5, i32) -> (i32, i32)
    %8:2 = "hw.instance"(%arg1, %arg2, %12#0, %13, %11#0, %11#1, %9#3, %9#2) <{argNames = ["clock", "reset", "io_ctrl_pc_sel", "io_ctrl_stall", "io_epc_valid", "io_epc_bits", "io_br_taken", "io_alu_out"], instanceName = "fetch", moduleName = @Fetch, parameters = [], resultNames = ["io_imem_addr", "io_pc"]}> {sv.namehint = "io_imem_addr"} : (!seq.clock, i1, i2, i1, i1, i32, i1, i32) -> (i32, i32)
    %9:11 = "hw.instance"(%12#3, %12#8, %12#7, %12#4, %12#1, %12#2, %12#5, %18, %16, %64, %68) <{argNames = ["io_ctrl_imm_sel", "io_ctrl_ld_type", "io_ctrl_st_type", "io_ctrl_alu_op", "io_ctrl_a_sel", "io_ctrl_b_sel", "io_ctrl_br_type", "io_data_inst", "io_data_pc", "io_rf_rs1r", "io_rf_rs2r"], instanceName = "execute", moduleName = @Execute, parameters = [], resultNames = ["io_data_rd", "io_data_csr", "io_data_alu_out", "io_data_br_taken", "io_dmem_req", "io_dmem_addr", "io_dmem_we", "io_dmem_be", "io_dmem_wdata", "io_rf_rs1", "io_rf_rs2"]}> {sv.namehint = "rf.io_raddr2"} : (i3, i3, i2, i4, i2, i2, i3, i32, i32, i32, i32) -> (i5, i12, i32, i1, i1, i32, i1, i4, i32, i5, i5)
    %10:3 = "hw.instance"(%36, %38, %40, %arg10, %48, %50, %11#2, %58) <{argNames = ["io_ctrl_wb_sel", "io_ctrl_wb_en", "io_ctrl_ld_type", "io_data_ld", "io_data_pc", "io_data_alu_out", "io_data_csr_rdata", "io_data_rd"], instanceName = "writeback", moduleName = @Writeback, parameters = [], resultNames = ["io_rf_wen", "io_rf_waddr", "io_rf_wdata"]}> {sv.namehint = "rf.io_wen"} : (i2, i1, i3, i32, i32, i32, i32, i32) -> (i1, i5, i32)
    %11:3 = "hw.instance"(%arg1, %arg2, %42, %44, %28, %30, %32, %34, %24, %26, %arg8, %arg9, %48, %52, %54, %56) <{argNames = ["clock", "reset", "io_ctrl_csr_type", "io_ctrl_illegal", "io_imem_req", "io_imem_addr", "io_imem_rvalid", "io_imem_err", "io_dmem_req", "io_dmem_addr", "io_dmem_rvalid", "io_dmem_err", "io_pc", "io_csr", "io_rs1", "io_wdata"], instanceName = "csr", moduleName = @Csr, parameters = [], resultNames = ["io_epc_valid", "io_epc_bits", "io_rdata"]}> {sv.namehint = "fetch.io_epc_bits"} : (!seq.clock, i1, i3, i1, i1, i32, i1, i1, i1, i32, i1, i1, i32, i12, i5, i32) -> (i1, i32, i32)
    %12:13 = "hw.instance"(%18) <{argNames = ["io_inst"], instanceName = "control", moduleName = @Control, parameters = [], resultNames = ["io_sig_pc_sel", "io_sig_a_sel", "io_sig_b_sel", "io_sig_imm_sel", "io_sig_alu_op", "io_sig_br_type", "io_sig_inst_kill", "io_sig_st_type", "io_sig_ld_type", "io_sig_wb_sel", "io_sig_wb_en", "io_sig_illegal", "io_sig_csr_type"]}> {sv.namehint = "fetch.io_ctrl_pc_sel"} : (i32) -> (i2, i2, i2, i3, i4, i3, i1, i2, i3, i2, i1, i1, i3)
    %13 = "seq.firreg"(%arg2, %arg1, %arg2, %4) <{name = "started"}> {firrtl.random_init_start = 0 : ui64, sv.namehint = "started"} : (i1, !seq.clock, i1, i1) -> i1
    %14 = "comb.mux"(%69, %5, %arg6) <{twoState}> {sv.namehint = "finst"} : (i1, i32, i32) -> i32
    %15 = "comb.xor"(%13, %6) <{twoState}> {sv.namehint = "_rs1r_T"} : (i1, i1) -> i1
    %16 = "seq.firreg"(%17, %arg1) <{name = "pc"}> {firrtl.random_init_start = 4 : ui64, sv.namehint = "pc"} : (i32, !seq.clock) -> i32
    %17 = "comb.mux"(%13, %16, %8#1) <{twoState}> : (i1, i32, i32) -> i32
    %18 = "seq.firreg"(%19, %arg1, %arg2, %5) <{name = "inst"}> {firrtl.random_init_start = 36 : ui64, sv.namehint = "inst"} : (i32, !seq.clock, i1, i32) -> i32
    %19 = "comb.mux"(%13, %18, %14) <{twoState}> : (i1, i32, i32) -> i32
    %20 = "seq.firreg"(%21, %arg1, %arg2, %4) <{name = "imem_req"}> {firrtl.random_init_start = 68 : ui64} : (i1, !seq.clock, i1, i1) -> i1
    %21 = "comb.or"(%15, %20) : (i1, i1) -> i1
    %22 = "seq.firreg"(%23, %arg1) <{name = "imem_addr"}> {firrtl.random_init_start = 69 : ui64} : (i32, !seq.clock) -> i32
    %23 = "comb.mux"(%13, %22, %8#0) <{twoState}> : (i1, i32, i32) -> i32
    %24 = "seq.firreg"(%25, %arg1, %arg2, %4) <{name = "dmem_req"}> {firrtl.random_init_start = 101 : ui64, sv.namehint = "dmem_req"} : (i1, !seq.clock, i1, i1) -> i1
    %25 = "comb.mux"(%13, %24, %9#4) <{twoState}> : (i1, i1, i1) -> i1
    %26 = "seq.firreg"(%27, %arg1) <{name = "dmem_addr"}> {firrtl.random_init_start = 102 : ui64, sv.namehint = "dmem_addr"} : (i32, !seq.clock) -> i32
    %27 = "comb.mux"(%13, %26, %9#5) <{twoState}> : (i1, i32, i32) -> i32
    %28 = "seq.firreg"(%29, %arg1, %arg2, %4) <{name = "imem_req_1"}> {firrtl.random_init_start = 134 : ui64, sv.namehint = "imem_req_1"} : (i1, !seq.clock, i1, i1) -> i1
    %29 = "comb.mux"(%13, %28, %20) <{twoState}> : (i1, i1, i1) -> i1
    %30 = "seq.firreg"(%31, %arg1) <{name = "imem_addr_1"}> {firrtl.random_init_start = 135 : ui64, sv.namehint = "imem_addr_1"} : (i32, !seq.clock) -> i32
    %31 = "comb.mux"(%13, %30, %22) <{twoState}> : (i1, i32, i32) -> i32
    %32 = "seq.firreg"(%33, %arg1, %arg2, %4) <{name = "imem_rvalid"}> {firrtl.random_init_start = 167 : ui64, sv.namehint = "imem_rvalid"} : (i1, !seq.clock, i1, i1) -> i1
    %33 = "comb.mux"(%13, %32, %arg4) <{twoState}> : (i1, i1, i1) -> i1
    %34 = "seq.firreg"(%35, %arg1, %arg2, %4) <{name = "imem_err"}> {firrtl.random_init_start = 168 : ui64, sv.namehint = "imem_err"} : (i1, !seq.clock, i1, i1) -> i1
    %35 = "comb.mux"(%13, %34, %arg5) <{twoState}> : (i1, i1, i1) -> i1
    %36 = "seq.firreg"(%37, %arg1, %arg2, %3) <{name = "wb_sel"}> {firrtl.random_init_start = 169 : ui64, sv.namehint = "wb_sel"} : (i2, !seq.clock, i1, i2) -> i2
    %37 = "comb.mux"(%13, %36, %12#9) <{twoState}> : (i1, i2, i2) -> i2
    %38 = "seq.firreg"(%39, %arg1, %arg2, %4) <{name = "wb_en"}> {firrtl.random_init_start = 171 : ui64, sv.namehint = "wb_en"} : (i1, !seq.clock, i1, i1) -> i1
    %39 = "comb.mux"(%13, %38, %12#10) <{twoState}> : (i1, i1, i1) -> i1
    %40 = "seq.firreg"(%41, %arg1, %arg2, %0) <{name = "ld_type"}> {firrtl.random_init_start = 172 : ui64, sv.namehint = "ld_type"} : (i3, !seq.clock, i1, i3) -> i3
    %41 = "comb.mux"(%13, %40, %12#8) <{twoState}> : (i1, i3, i3) -> i3
    %42 = "seq.firreg"(%43, %arg1, %arg2, %0) <{name = "csr_type"}> {firrtl.random_init_start = 175 : ui64, sv.namehint = "csr_type"} : (i3, !seq.clock, i1, i3) -> i3
    %43 = "comb.mux"(%13, %42, %12#12) <{twoState}> : (i1, i3, i3) -> i3
    %44 = "seq.firreg"(%45, %arg1, %arg2, %4) <{name = "illegal"}> {firrtl.random_init_start = 182 : ui64, sv.namehint = "illegal"} : (i1, !seq.clock, i1, i1) -> i1
    %45 = "comb.mux"(%13, %44, %12#11) <{twoState}> : (i1, i1, i1) -> i1
    %46 = "seq.firreg"(%47, %arg1) <{name = "rd"}> {firrtl.random_init_start = 183 : ui64} : (i5, !seq.clock) -> i5
    %47 = "comb.mux"(%13, %46, %9#0) <{twoState}> : (i1, i5, i5) -> i5
    %48 = "seq.firreg"(%49, %arg1) <{name = "pc_1"}> {firrtl.random_init_start = 188 : ui64, sv.namehint = "pc_1"} : (i32, !seq.clock) -> i32
    %49 = "comb.mux"(%13, %48, %16) <{twoState}> : (i1, i32, i32) -> i32
    %50 = "seq.firreg"(%51, %arg1) <{name = "alu_out"}> {firrtl.random_init_start = 220 : ui64, sv.namehint = "alu_out"} : (i32, !seq.clock) -> i32
    %51 = "comb.mux"(%13, %50, %9#2) <{twoState}> : (i1, i32, i32) -> i32
    %52 = "seq.firreg"(%53, %arg1) <{name = "csr_1"}> {firrtl.random_init_start = 252 : ui64, sv.namehint = "csr_1"} : (i12, !seq.clock) -> i12
    %53 = "comb.mux"(%13, %52, %9#1) <{twoState}> : (i1, i12, i12) -> i12
    %54 = "seq.firreg"(%55, %arg1) <{name = "rs1"}> {firrtl.random_init_start = 264 : ui64, sv.namehint = "rs1"} : (i5, !seq.clock) -> i5
    %55 = "comb.mux"(%13, %54, %9#9) <{twoState}> : (i1, i5, i5) -> i5
    %56 = "seq.firreg"(%57, %arg1) <{name = "rs1r"}> {firrtl.random_init_start = 269 : ui64, sv.namehint = "rs1r"} : (i32, !seq.clock) -> i32
    %57 = "comb.mux"(%13, %56, %64) <{twoState}> : (i1, i32, i32) -> i32
    %58 = "comb.concat"(%2, %46) {sv.namehint = "writeback.io_data_rd"} : (i27, i5) -> i32
    %59 = "comb.icmp"(%36, %3) <{predicate = 0 : i64, twoState}> : (i2, i2) -> i1
    %60 = "comb.and"(%38, %59) <{twoState}> : (i1, i1) -> i1
    %61 = "comb.icmp"(%9#9, %1) <{predicate = 1 : i64, twoState}> : (i5, i5) -> i1
    %62 = "comb.icmp"(%9#9, %46) <{predicate = 0 : i64, twoState}> : (i5, i5) -> i1
    %63 = "comb.and"(%60, %61, %62) <{twoState}> : (i1, i1, i1) -> i1
    %64 = "comb.mux"(%63, %50, %7#0) <{twoState}> {sv.namehint = "execute.io_rf_rs1r"} : (i1, i32, i32) -> i32
    %65 = "comb.icmp"(%9#10, %1) <{predicate = 1 : i64, twoState}> : (i5, i5) -> i1
    %66 = "comb.icmp"(%9#10, %46) <{predicate = 0 : i64, twoState}> : (i5, i5) -> i1
    %67 = "comb.and"(%60, %65, %66) <{twoState}> : (i1, i1, i1) -> i1
    %68 = "comb.mux"(%67, %50, %7#1) <{twoState}> {sv.namehint = "execute.io_rf_rs2r"} : (i1, i32, i32) -> i32
    %69 = "comb.or"(%12#6, %9#3, %11#0, %13) <{twoState}> {sv.namehint = "flush"} : (i1, i1, i1, i1) -> i1
    "hw.output"(%6, %8#0, %9#4, %9#5, %9#6, %9#7, %9#8) : (i1, i32, i1, i32, i1, i4, i32) -> ()
  }) : () -> ()
  "om.class"() <{fieldNames = [], fieldTypes = {}, formalParamNames = ["basepath"], sym_name = "Core_Class"}> ({
  ^bb0(%arg0: !om.basepath):
    "om.class.fields"() : () -> ()
  }) : () -> ()
}) : () -> ()

