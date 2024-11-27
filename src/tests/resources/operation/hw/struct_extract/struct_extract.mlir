hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %struct = hw.struct_create (%a, %b) : !hw.struct<a: i8, b: i8>

    %aa = hw.struct_extract %struct ["a"] : !hw.struct<a: i8, b: i8>
    %bb = hw.struct_extract %struct ["b"] : !hw.struct<a: i8, b: i8>

    %res = comb.add %aa, %bb : i8
    hw.output %res : i8
}