hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %x = sv.constantX : i8
    %out = comb.add %x, %b: i8
    hw.output %out : i8
}