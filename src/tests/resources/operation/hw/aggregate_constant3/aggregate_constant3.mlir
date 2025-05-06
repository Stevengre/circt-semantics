hw.module @Foo(in %a: i2, in %b: i64, out res: i64) {
    %0 = hw.aggregate_constant [-1, 0, 1, 2] : !hw.array<4xi64>
    %t = hw.constant -1:i2
    %1 = hw.array_get %0[%t] {sv.namehint = "add1"} : !hw.array<4xi64>, i2
    %out = comb.add %1, %b : i64
    hw.output %out : i64
}