module {
  hw.module @TraceSimulation(in %clk : i1, in %reset : i1, out result : i8) {
    %clock = seq.to_clock %clk
    %zero = hw.constant 0 : i8
    %one = hw.constant 1 : i8
    %q = seq.firreg %next clock %clock reset sync %reset, %zero {name = "counter"} : i8
    %next = comb.add %q, %one : i8
    hw.output %q : i8
  }
}
