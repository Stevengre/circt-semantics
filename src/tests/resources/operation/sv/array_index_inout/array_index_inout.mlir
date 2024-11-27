hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %arr = hw.array_create %a, %b : i8

    %reg = sv.reg : !hw.inout<!hw.array<2xi8>>
    sv.assign %reg, %arr : !hw.array<2xi8>

    %index_0 = hw.constant 0 : i8
    %index_1 = hw.constant 1 : i8

    %a1 = sv.array_index_inout %reg [%index_0]: !hw.inout<!hw.array<2xi8>>, i8
    %b1 = sv.array_index_inout %reg [%index_1]: !hw.inout<!hw.array<2xi8>>, i8

    %aa = sv.read_inout %a1 : !hw.inout<i8>
    %bb = sv.read_inout %b1 : !hw.inout<i8>

    %out = comb.add %aa, %bb : i8    
    hw.output %out : i8
}