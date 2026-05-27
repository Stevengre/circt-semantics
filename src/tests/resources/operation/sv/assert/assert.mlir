hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %c1 = hw.constant 1 : i1
    %sum = comb.add %a, %b: i8
    %a_sign = comb.extract %a from 7 : (i8) -> i1
    %b_sign = comb.extract %b from 7 : (i8) -> i1
    %sum_sign = comb.extract %sum from 7 : (i8) -> i1
    
    %same_sign = comb.icmp eq %a_sign, %b_sign : i1
    %diff_sum_sign = comb.icmp ne %sum_sign, %a_sign : i1
    %cond_overflow = comb.and %same_sign, %diff_sum_sign : i1
    %cond_no_overflow = comb.xor %cond_overflow, %c1: i1
    sv.alwayscomb{
        sv.assert %cond_no_overflow, "immediate" label "overflow_assert"
    }
    hw.output %sum : i8
}
