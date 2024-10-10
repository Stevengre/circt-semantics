module {
  hw.module @Foo(in %clk : !seq.clock, out res : i8) {
    %mem = seq.firmem 1, 1, undefined, port_order {prefix = ""} : <512 x 8>
    %c3_i9 = hw.constant 3 : i9
    %x = hw.constant 2 : i8
    %enable = hw.constant 1 : i1
    seq.firmem.write_port %mem[%c3_i9] = %x, clock %clk enable %enable : <512 x 8>
    %0 = seq.firmem.read_port %mem[%c3_i9], clock %clk : <512 x 8>
    hw.output %0 : i8
  }
}