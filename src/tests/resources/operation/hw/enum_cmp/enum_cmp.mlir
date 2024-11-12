hw.module @Foo(out res: i1) {
    %a = hw.enum.constant A : !hw.enum<A, B, C>
    %b = hw.enum.constant A : !hw.enum<A, B, C>
    %out = hw.enum.cmp %a, %b : !hw.enum<A, B, C>, !hw.enum<A, B, C>
    hw.output %out : i1
}