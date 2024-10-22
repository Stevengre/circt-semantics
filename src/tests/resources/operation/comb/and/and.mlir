hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %out = comb.and %a, %b: i8
    hw.output %out : i8
}