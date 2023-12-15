module {
  hw.module @Adder(in %io_a: i8, in %io_b: i8, out %out: i8 ) {
    %0 = comb.add %io_a, %io_b : i8
    hw.output %0 : i8
  }
}