hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %reg_a = sv.reg : !hw.inout<i8>
    %reg_b = sv.reg : !hw.inout<i8>
    
    sv.assign %reg_a, %a : i8
    sv.assign %reg_b, %b : i8
    
    %aa = sv.read_inout %reg_a : !hw.inout<i8>
    %bb = sv.read_inout %reg_b : !hw.inout<i8>
    
    %out = comb.add %aa, %bb: i8
    hw.output %out : i8
}