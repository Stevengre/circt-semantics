hw.module @Foo(in %a: i1, in %b: i1, out res: i1) {
    %0 = comb.truth_table %a, %b -> [false, true, true, false]
    hw.output %0: i1
}