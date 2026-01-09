hw.module @Foo(in %a: i8, in %b: i8, out res: i8, out overflow: i1) {
    %zero = hw.constant 0 : i1
    %wide_a = comb.concat %zero, %a : i1, i8
    %wide_b = comb.concat %zero, %b: i1, i8
    %wide_sum = comb.add %wide_a, %wide_b : i9
    %sum = comb.extract %wide_sum from 0: ( i9 ) -> i8
    %overflow = comb.extract %wide_sum from 4: ( i9 ) -> i1
    hw.output %sum, %overflow : i8, i1
}