hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    sv.ifdef "MACRO" {
    } else {
        sv.always{
            sv.error "not defined"
        }
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}