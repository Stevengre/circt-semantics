hw.module @Adder(in %io_a: i8, in %io_b: i8, out res_add: i8, out res_sub: i8) {
    %out = comb.add %io_a, %io_b : i8
    %out1 = comb.sub %io_a, %io_b : i8
    hw.output %out, %out1 : i8, i8
}