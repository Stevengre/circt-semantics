hw.module @Foo(in %a: i8, in %b: i8, out res: i1, out res1: i1, out res6: i1, out res8: i1, out res9: i1, out res10: i1, out res11: i1) {
    %out = comb.icmp bin eq %a, %b : i8
    %out1 = comb.icmp bin ne %a, %b : i8
    %out6 = comb.icmp bin ult %a, %b : i8
    %out8 = comb.icmp bin ugt %a, %b : i8
    %out9 = comb.icmp bin uge %a, %b : i8
    %out10 = comb.icmp ceq %a, %b : i8
    %out11 = comb.icmp cne %a, %b : i8
    hw.output %out, %out1, %out6, %out8, %out9, %out10, %out11 : i1, i1, i1, i1, i1, i1, i1
}
