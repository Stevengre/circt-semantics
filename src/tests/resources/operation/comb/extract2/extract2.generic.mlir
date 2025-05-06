"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i32):
    %1 = "hw.constant"() {value = 590331979893212971008 : i70} : () -> i70
    %2 = "hw.constant"() {value = 0 : i6} : () -> i6
    %4 = "comb.concat"(%arg0, %arg0, %2) : (i32, i32, i6) -> i70
    %5 = "comb.add"(%1, %4) : (i70, i70) -> i70
    %7 = "comb.extract"(%5) <{lowBit = 0 : i32}> {sv.namehint = "ram_io_deq_bits_MPORT_data_id"} : (i70) -> i4
    %8 = "comb.extract"(%5) <{lowBit = 4 : i32}> {sv.namehint = "ram_io_deq_bits_MPORT_data_addr"} : (i70) -> i32
    %9 = "comb.extract"(%5) <{lowBit = 36 : i32}> {sv.namehint = "ram_io_deq_bits_MPORT_data_len"} : (i70) -> i8
    %10 = "comb.extract"(%5) <{lowBit = 44 : i32}> {sv.namehint = "ram_io_deq_bits_MPORT_data_size"} : (i70) -> i3
    %11 = "comb.extract"(%5) <{lowBit = 47 : i32}> {sv.namehint = "ram_io_deq_bits_MPORT_data_burst"} : (i70) -> i2
    %12 = "comb.extract"(%5) <{lowBit = 49 : i32}> {sv.namehint = "ram_io_deq_bits_MPORT_data_lock"} : (i70) -> i1
    %13 = "comb.extract"(%5) <{lowBit = 50 : i32}> {sv.namehint = "ram_io_deq_bits_MPORT_data_cache"} : (i70) -> i4
    %14 = "comb.extract"(%5) <{lowBit = 54 : i32}> {sv.namehint = "ram_io_deq_bits_MPORT_data_prot"} : (i70) -> i3
    %15 = "comb.extract"(%5) <{lowBit = 57 : i32}> {sv.namehint = "ram_io_deq_bits_MPORT_data_qos"} : (i70) -> i4
    %16 = "comb.extract"(%5) <{lowBit = 61 : i32}> {sv.namehint = "ram_io_deq_bits_MPORT_data_echo_tl_state_size"} : (i70) -> i4
    %17 = "comb.extract"(%5) <{lowBit = 65 : i32}> {sv.namehint = "ram_io_deq_bits_MPORT_data_echo_tl_state_source"} : (i70) -> i4
    %18 = "comb.extract"(%5) <{lowBit = 69 : i32}> {sv.namehint = "ram_io_deq_bits_MPORT_data_wen"} : (i70) -> i1
    "hw.output"(%7, %8, %9, %10, %11, %12, %13, %14, %15, %16, %17, %18) : (i4, i32, i8, i3, i2, i1, i4, i3, i4, i4, i4, i1) -> ()
  }) {module_type = !hw.modty<input a : i32, output b7 : i4, output b8 : i32, output b9 : i8, output b10 : i3, output b11 : i2, output b12 : i1, output b13 : i4, output b14 : i3, output b15 : i4, output b16 : i4, output b17 : i4, output b18 : i1>, parameters = [], sym_name = "Foo"} : () -> ()
}) : () -> ()