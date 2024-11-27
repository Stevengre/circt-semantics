hw.module @Foo(in %a: i8, in %b: i8, out res: i16) {
    %x = hw.struct_create (%a, %b) : !hw.struct<a: i8, b: i8>
    %out =  hw.bitcast %x : (!hw.struct<a: i8, b: i8>) -> (i16)
    hw.output %out : i16
}