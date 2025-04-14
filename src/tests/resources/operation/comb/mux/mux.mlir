hw.module @Foo(in %a: i1, in %b: i8,in %c: i8, out res: i8 ) {
    %out = comb.mux %a, %b, %c: i8
    hw.output %out : i8
}