hw.module @Foo(out res: i8) {
    %result = hw.constant 42 : i8
    hw.output %out : i8
}