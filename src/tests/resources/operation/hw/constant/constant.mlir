hw.module @Foo(out res: i8) {
    %result = hw.constant 42 : i8
    hw.output %result : i8
}