hw.module @Foo(in %a: i8, in %b: i8, out res: i16 ) {
    %out = comb.concat %a, %b: i8, i8
    hw.output %out : i16
}