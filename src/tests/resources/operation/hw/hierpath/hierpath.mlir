hw.module @Bar(in %a: i8, in %b: i8, out res: i8) {
    %reg = sv.reg sym @sym_reg {sv.attributes=[#sv.attribute<"dont_merge">]} : !hw.inout<i8>
    %out = comb.add %a, %b : i8
    hw.output %out : i8
}
hw.module @Fuu(in %a: i8, in %b: i8, out res: i8) {
    %out = hw.instance "bar" sym @sym_bar @Bar(a: %a: i8, b: %b: i8) -> (res:i8)
    hw.output %out : i8
}
hw.hierpath @ref [@Fuu::@sym_bar, @Bar::@sym_reg]
hw.module @Foo(){
    %xmr1 = sv.xmr.ref @ref : !hw.inout<i8>
}