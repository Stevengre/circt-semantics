hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    
    sv.verbatim ";"
    %out = comb.add %a, %b: i8    
    hw.output %out : i8
}