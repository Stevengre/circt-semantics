hw.module @Foo(out res: !hw.struct<a: i2, b: i2, c: i2>) {
    %a = hw.aggregate_constant [1 : i2, 2 : i2, 3 : i2] : !hw.struct<a: i2, b: i2, c: i2>
    hw.output %a : !hw.struct<a: i2, b: i2, c: i2>
}