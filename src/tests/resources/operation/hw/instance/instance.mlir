module {
  hw.module private @AddOne(in %io_a : i8, out res : i8) {
    %c1_i8 = hw.constant 1 : i8
    %0 = comb.add %io_a, %c1_i8 {sv.namehint = "_out_T"} : i8
    hw.output %0 : i8
  }
  hw.module private @AddTwo(in %io_a : i8, out res2 : i8) {
    %i0.out = hw.instance "i3" @AddOne(io_a: %io_a: i8) -> (res: i8)
    %i1.out = hw.instance "i1" @AddOne(io_a: %i0.out: i8) -> (res: i8)
    hw.output %i1.out : i8
  }
  hw.module @Foo(in %io_a : i8, out res_out2 : i8, out res_out1: i8) {
    %i3.out = hw.instance "i0" @AddTwo(io_a: %io_a: i8) -> (res2: i8)
    %i4.out = hw.instance "i2" @AddOne(io_a: %i3.out: i8) -> (res: i8)
    hw.output %i3.out, %i4.out : i8, i8
  }
}