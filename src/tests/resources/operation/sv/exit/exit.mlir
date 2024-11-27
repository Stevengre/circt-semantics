hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1 : i1
    sv.always posedge  %clk {
        sv.exit
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}