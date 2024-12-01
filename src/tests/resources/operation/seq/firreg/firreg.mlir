hw.module @Foo(in %clk: !seq.clock,in %reset: i1, out res: i8) {
    %reg_port = seq.firreg %next clock %clk reset sync %reset, %c0 {firrtl.random_init_start = 0 : ui64}: i8
    %c0 = hw.constant 0 : i8
    %c1 = hw.constant 1 : i8
    %next = comb.add %reg_port, %c1 : i8
    hw.output %reg_port : i8
}