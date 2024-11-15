hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    sv.generate "test" : {
        sv.generate.case "case_1" []
        sv.generate.case "case_2" []
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}