hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    sv.always {
        sv.stop 2
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}