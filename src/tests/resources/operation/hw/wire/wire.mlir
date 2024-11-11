hw.module @Foo(out res: i8) {
    %0 = hw.constant 0: i8
    %out = hw.wire %0 sym @mySym name "myWire" : i8
    hw.output %out : i8
}