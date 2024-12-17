hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out result: i8) {


    sv.always posedge  %clk{
        sv.info "world"
    }
   
    %out = comb.add %a, %b: i8    
    hw.output %out : i8
}