hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %arr1 = hw.array_create %a: i8
    %arr2 = hw.array_create %b: i8

    %arr = hw.array_concat %arr1, %arr2 : !hw.array<1xi8>, !hw.array<1xi8>

    %0 = hw.constant 0: i1
    %1 = hw.constant 1: i1

    %aa = hw.array_get %arr [%0] : !hw.array<2xi8>, i1
    %bb = hw.array_get %arr [%1] : !hw.array<2xi8>, i1

    %res = comb.add %aa, %bb : i8
    hw.output %res : i8
}