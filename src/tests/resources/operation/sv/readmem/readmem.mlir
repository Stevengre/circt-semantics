hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %file = sv.reg: !hw.inout<i8>
    sv.initial {
        sv.readmem %file, "input.txt", MemBaseBin : !hw.inout<i8>
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}