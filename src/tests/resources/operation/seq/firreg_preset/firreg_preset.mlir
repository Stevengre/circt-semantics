// 显式非零初值、反馈保持、同步复位，以及无 preset 的二态零初值对照。
hw.module @Foo(in %clk: i1, in %reset: i1, in %enable: i1,
               in %d4: i4, in %d8: i8,
               out q4: i4, out q8: i8, out qneg: i8,
               out qbit: i1, out plain: i4, out next4: i4) {
  %clock = seq.to_clock %clk
  %one4 = hw.constant 1 : i4
  %reset4 = hw.constant 2 : i4
  %reset8 = hw.constant 60 : i8
  %next4 = comb.add %q4, %one4 : i4
  %enabled4 = comb.mux %enable, %next4, %q4 : i4
  %q4 = seq.firreg %enabled4 clock %clock reset sync %reset, %reset4 preset 5 : i4
  %enabled8 = comb.mux %enable, %d8, %q8 : i8
  %q8 = seq.firreg %enabled8 clock %clock reset sync %reset, %reset8 preset 165 : i8
  %qneg = seq.firreg %d8 clock %clock preset 255 : i8
  %qbit = seq.firreg %enable clock %clock preset 1 : i1
  %plain = seq.firreg %d4 clock %clock : i4
  hw.output %q4, %q8, %qneg, %qbit, %plain, %next4 : i4, i8, i8, i1, i4, i4
}
