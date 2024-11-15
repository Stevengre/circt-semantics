hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %fd = hw.constant 1: i32
    sv.initial {
        sv.fwrite %fd, "format string"
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}