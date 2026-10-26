"builtin.module"() ({
 "hw.module"() <{module_type = !hw.modty<input ca : i1, input cb : i1, input da : i8, input db : i8, output only_a : i8, output both : i8>, parameters = [], sym_name = "GeneratedClockProbe"}> ({
 ^bb0(%ca: i1, %cb: i1, %da: i8, %db: i8):
  %clock_a = "seq.to_clock"(%ca) : (i1) -> !seq.clock
  %gated = "comb.and"(%ca, %cb) : (i1, i1) -> i1
  %clock_b = "seq.to_clock"(%gated) : (i1) -> !seq.clock
  %reset = "hw.constant"() <{value = false}> : () -> i1
  %zero = "hw.constant"() <{value = 0 : i8}> : () -> i8
  %qa = "seq.firreg"(%da, %clock_a, %reset, %zero) <{name = "qa", preset = 0 : i8}> : (i8, !seq.clock, i1, i8) -> i8
  %qb = "seq.firreg"(%db, %clock_b, %reset, %zero) <{name = "qb", preset = 0 : i8}> : (i8, !seq.clock, i1, i8) -> i8
  %sum = "comb.add"(%qa, %qb) : (i8, i8) -> i8
  "hw.output"(%qa, %sum) : (i8, i8) -> ()
 }) : () -> ()
}) : () -> ()
