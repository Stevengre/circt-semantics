hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %arr = hw.array_create %a, %b, %a, %b : i8
    %reg = sv.reg : !hw.inout<array<4xi8>>
    sv.assign %reg, %arr : !hw.array<4xi8>

    %index = hw.constant 0 : i8
    %part = sv.indexed_part_select_inout %reg[%index:2] : !hw.inout<array<4xi8>>, i8
    %ab = sv.read_inout %part : !hw.inout<array<2xi8>>

    %0 = hw.constant 0 : i1
    %1 = hw.constant 1 : i1
    %aa = hw.array_get %ab[%0] : !hw.array<2xi8>, i1
    %bb = hw.array_get %ab[%1] : !hw.array<2xi8>, i1
    
    %out = comb.add %aa, %bb: i8
    hw.output %out : i8
}