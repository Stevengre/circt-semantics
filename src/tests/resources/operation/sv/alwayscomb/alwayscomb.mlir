hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out result: i8) {
    sv.alwayscomb {
        sv.info "hello"
    }
   
    %out = comb.add %a, %b: i8    
    hw.output %out : i8
}
