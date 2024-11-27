hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %z = sv.constantZ : i8
    %out = comb.add %z, %b: i8
    hw.output %out : i8
}