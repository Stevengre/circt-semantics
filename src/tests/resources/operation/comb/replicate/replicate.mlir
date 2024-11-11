hw.module @Foo(in %a: i8, out res: i16) {
    %out = comb.replicate %a : (i8) -> i16
    hw.output %out : i16
}