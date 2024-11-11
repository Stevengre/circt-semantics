hw.module @Foo(in %a: i8, out res: i1) {
    %out = comb.parity %a : i8
    hw.output %out : i1
}