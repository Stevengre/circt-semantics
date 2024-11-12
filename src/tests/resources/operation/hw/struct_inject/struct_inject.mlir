hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %struct0 = hw.struct_create (%b, %a) : !hw.struct<a: i8, b: i8>
    %struct1 = hw.struct_inject %struct0["a"], %a : !hw.struct<a: i8, b: i8>
    %struct2 = hw.struct_inject %struct1["b"], %b : !hw.struct<a: i8, b: i8>

    %aa, %bb = hw.struct_explode %struct2 : !hw.struct<a: i8, b: i8>
    %res = comb.add %aa, %bb : i8
    hw.output %res : i8
}