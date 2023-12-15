module {
  hw.module @Adder(%clock: i1, %reset: i1, %io_a: i8, %io_b: i8) -> (io_out: i8) {
    %0 = comb.add %io_a, %io_b {sv.namehint = "_io_out_T_1"} : i8
    hw.output %0 : i8
  }
}