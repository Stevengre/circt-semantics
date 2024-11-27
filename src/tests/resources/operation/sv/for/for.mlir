hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %0 = hw.constant 0 : i8
    %1 = hw.constant 1: i8

    sv.always {
        sv.for %i = %0 to %b step %1 : i8 {
            sv.info "This is a test"
        }
    }
    
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}