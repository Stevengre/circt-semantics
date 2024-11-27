hw.module @Foo(in %a: i8, in %b: i8, out res: i1) {
    %out = comb.icmp bin eq %a, %b : i8
    hw.output %out : i1
}