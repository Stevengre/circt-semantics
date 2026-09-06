hw.module @Foo(in %clk: i1, out res: !seq.clock) {
    %clock = seq.to_clock %clk
    hw.output %clock : !seq.clock
}
