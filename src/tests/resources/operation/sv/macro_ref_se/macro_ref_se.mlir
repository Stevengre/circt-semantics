sv.macro.decl @MACRO
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    sv.macro.def @MACRO "1"
    %macro = sv.macro.ref.se @MACRO(%a) : () -> i1
    sv.always {
        sv.assert %macro, "immediate"
    }

    %out = comb.add %a, %b: i8
    hw.output %out : i8
}