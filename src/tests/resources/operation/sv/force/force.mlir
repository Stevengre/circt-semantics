hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %reg_a = sv.reg : !hw.inout<i8>
    %reg_b = sv.reg : !hw.inout<i8>

    sv.initial {
        sv.force %reg_a, %b: i8
        sv.force %reg_b, %a: i8
        
        sv.release %reg_a: !hw.inout<i8>
        sv.release %reg_b: !hw.inout<i8>
    }

    %aa = sv.read_inout %reg_a: !hw.inout<i8>
    %bb = sv.read_inout %reg_b: !hw.inout<i8>

    %out = comb.add %aa, %bb: i8

    hw.output %out : i8
}