hw.module @Foo(in %clk: !seq.clock,in %a: i8,in %b: i8, out res: i8, out res2: i8, out res3: i8) {
    %reg_port = seq.firreg %next clock %clk {firrtl.random_init_start = 3 : ui64}: i8
    %c0 = hw.constant 0 : i8
    %c1 = hw.constant 1 : i8
    %next = comb.add %a, %b : i8
    %next2 = comb.add %reg_port, %c1 : i8
    %reg_port2 = seq.firreg %next2 clock %clk {firrtl.random_init_start = 3 : ui64}: i8

    hw.output %next, %reg_port, %reg_port2: i8, i8, i8
}