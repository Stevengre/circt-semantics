hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %wire_a = sv.wire : !hw.inout<i8>
    %wire_b = sv.wire : !hw.inout<i8>
    sv.assign %wire_a, %a : i8
    sv.assign %wire_b, %b : i8
    %aa = sv.read_inout %wire_a : !hw.inout<i8>
    %bb = sv.read_inout %wire_b : !hw.inout<i8>
    %out = comb.add %aa, %bb : i8
    hw.output %out : i8
}