hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %union_a = hw.union_create "foo", %a : !hw.union<foo: i8, bar: i8>
    %aa = hw.union_extract %union_a["foo"] : !hw.union<foo: i8, bar: i8>

    %union_b = hw.union_create "bar", %b : !hw.union<foo: i8, bar: i8>
    %bb = hw.union_extract %union_b["bar"] : !hw.union<foo: i8, bar: i8>

    %res = comb.add %aa, %bb : i8
    hw.output %res : i8
}