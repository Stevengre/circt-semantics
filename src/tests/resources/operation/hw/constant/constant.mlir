hw.module @Foo(in %a: i8, out res: i8) {
    %cos1 = hw.constant 42 : i8
    %res = comb.add %a, %cos1 : i8
    hw.output %res : i8
}