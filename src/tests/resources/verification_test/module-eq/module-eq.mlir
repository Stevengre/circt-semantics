module {
  hw.module private @Add(in %a : i8, out res : i8) {
    %sum = comb.add %a, %a : i8
    hw.output %sum : i8
  }
  hw.module private @MulTwo(in %a : i8, out res : i8) {
    %two = hw.constant 2 : i8
    %product = comb.mul %a, %two : i8
    hw.output %product : i8
  }
  hw.module @Foo(in %a : i8, out res: i1) {
    %sum = hw.instance "Add_" @Add(a: %a: i8) -> (res: i8)
    %double = hw.instance "MulTwo_" @MulTwo(a: %a: i8) -> (res: i8)
    %out = comb.icmp bin eq %sum, %double : i8
    hw.output %out : i1
  }
}