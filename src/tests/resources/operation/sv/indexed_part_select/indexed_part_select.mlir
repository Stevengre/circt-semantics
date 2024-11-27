hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %index = hw.constant 0 : i8
    %aa = sv.indexed_part_select %a[%index:8] : i8, i8
    %bb = sv.indexed_part_select %b[%index:8] : i8, i8
    
    %out = comb.add %aa, %bb: i8
    hw.output %out : i8
}