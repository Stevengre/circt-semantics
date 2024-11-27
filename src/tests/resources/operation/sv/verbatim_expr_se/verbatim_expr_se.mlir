hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    sv.verbatim.expr.se "123" () : () -> i8
    %out = comb.add %a, %b: i8    
    hw.output %out : i8
}