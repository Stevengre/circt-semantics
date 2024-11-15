sv.macro.decl @MACRO ["1"]
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %macro = sv.macro.ref @MACRO() : () -> i1
    sv.always {
        sv.assert %macro, "immediate"
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}