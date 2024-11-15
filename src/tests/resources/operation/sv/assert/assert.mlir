hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1 : i1
    
    sv.always {
        sv.assert %cond, "immediate"
    }

    %out = comb.add %a, %b: i8
    hw.output %out : i8
}