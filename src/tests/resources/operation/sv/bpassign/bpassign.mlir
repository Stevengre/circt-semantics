hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %reg = sv.reg : !hw.inout<i8>
    sv.always {
        sv.bpassign %reg, %a : i8
    }
    %aa = sv.read_inout %reg : !hw.inout<i8>
    %out = comb.add %aa, %b: i8
    hw.output %out : i8
}