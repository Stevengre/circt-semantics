hw.module @Foo(in %a: i8, out res: i4 ) {
    %out = comb.extract %a from 3 : (i8) -> i4
    hw.output %out : i4
}