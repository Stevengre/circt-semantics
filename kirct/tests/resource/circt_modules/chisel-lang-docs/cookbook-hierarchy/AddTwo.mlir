module {
  hw.module private @AddOne(in %in : i8, out out : i8) {
    %c1_i8 = hw.constant 1 : i8
    %0 = comb.add %in, %c1_i8 {sv.namehint = "_out_T"} : i8
    hw.output %0 : i8
  }
  hw.module @AddTwo(in %clock : !seq.clock, in %reset : i1, in %in : i8, out out : i8) {
    %i0.out = hw.instance "i0" @AddOne(in: %in: i8) -> (out: i8)
    %i1.out = hw.instance "i1" @AddOne(in: %i0.out: i8) -> (out: i8)
    hw.output %i1.out : i8
  }
  om.class @AddTwo_Class(%basepath: !om.basepath) {
  }
}
