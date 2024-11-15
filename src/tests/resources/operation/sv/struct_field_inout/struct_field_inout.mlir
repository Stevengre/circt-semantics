hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %struct = hw.struct_create (%a, %b) : !hw.struct<a: i8, b: i8>

    %reg = sv.reg : !hw.inout<!hw.struct<a: i8, b: i8>>
    sv.assign %reg, %struct : !hw.struct<a: i8, b: i8>

    %a1 = sv.struct_field_inout %reg ["a"]: !hw.inout<!hw.struct<a: i8, b: i8>>
    %b1 = sv.struct_field_inout %reg ["b"]: !hw.inout<!hw.struct<a: i8, b: i8>>

    %aa = sv.read_inout %a1: !hw.inout<i8>
    %bb = sv.read_inout %b1: !hw.inout<i8>

    %out = comb.add %aa, %bb: i8    
    hw.output %out : i8
}