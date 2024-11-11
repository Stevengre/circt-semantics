hw.module @Bar(in %a: i8, in %b: i8, out res: i8) {
    %out = comb.add %a, %b : i8
    hw.output %out : i8
}
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = hw.instance "bar" sym @sym_bar @Bar(a: %a: i8, b: %b: i8) -> (res:i8)
    hw.output %out : i8
}