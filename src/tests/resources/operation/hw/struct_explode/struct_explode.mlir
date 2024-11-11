hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %struct = hw.struct_create (%a, %b) : !hw.struct<a: i8, b: i8>
    %aa, %bb = hw.struct_explode %struct : !hw.struct<a: i8, b: i8>
    %res = comb.add %aa, %bb : i8
    hw.output %res : i8
}