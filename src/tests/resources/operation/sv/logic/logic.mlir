hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %logic_a = sv.logic : !hw.inout<i8>
    %logic_b = sv.logic : !hw.inout<i8>
    sv.assign %logic_a, %a : i8
    sv.assign %logic_b, %b : i8

    %aa = sv.read_inout %logic_a : !hw.inout<i8>
    %bb = sv.read_inout %logic_b : !hw.inout<i8>
    
    %out = comb.add %aa, %bb: i8
    hw.output %out : i8
}