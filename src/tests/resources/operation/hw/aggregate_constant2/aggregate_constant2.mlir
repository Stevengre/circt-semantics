hw.module @Foo(in %a: i2, in %b: i8, out res: i8) {
    %0 = hw.aggregate_constant [-1 : i8, 0 : i8, 1 : i8, 2 : i8] : !hw.array<4xi8>
    %1 = hw.array_get %0[%a] {sv.namehint = "add1"} : !hw.array<4xi8>, i2
    %out = comb.add %1, %b : i8
    hw.output %out : i8
}