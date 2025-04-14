hw.module @Foo(in %a: i8, out res: i8) {
    %cos1 = hw.constant -42 : i8
    %false = hw.constant false
    %true = hw.constant true
    %mos = comb.replicate %true : (i1) -> i8
    %mos2 = comb.add %mos, %a : i8
    %res = comb.add %mos2, %cos1 : i8
    hw.output %res : i8
}