hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    sv.initial {
        sv.case %clk : i1
        case b0: {
            sv.error "zero"
        }
        case b1: {
            sv.error "one"
        }
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}