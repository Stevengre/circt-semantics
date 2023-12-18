hw.module @Adder(in %i0: i8, in %i1: i8, out res_add: i8, out res_sub: i8) {
    %out = comb.add %i0, %i1 : i8
    %out1 = comb.sub %i0, %i1 : i8
    hw.output %out, %out1 : i8, i8
}