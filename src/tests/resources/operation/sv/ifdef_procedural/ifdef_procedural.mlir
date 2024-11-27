hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    sv.always {
        sv.ifdef.procedural "MACRO" {
        } else {
            sv.error "undefined"
        }
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}