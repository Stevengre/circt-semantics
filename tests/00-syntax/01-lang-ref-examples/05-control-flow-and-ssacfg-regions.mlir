// : krun -d %kdir %s
func.func @accelerator_compute(i64, i1) -> i64 { // An SSACFG region
^bb0(%a: i64, %cond: i1): // Code dominated by ^bb0 may refer to %a
  cf.cond_br %cond, ^bb1, ^bb2

^bb1:
  // This def for %value does not dominate ^bb2
  %value = "op.convert"(%a) : (i64) -> i64
  cf.br ^bb3(%a: i64)    // Branch passes %a as the argument

^bb2:
  accelerator.launch() { // An SSACFG region
    ^bb0:
      // Region of code nested under "accelerator.launch", it can reference %a but
      // not %value.
      %new_value = "accelerator.do_something"(%a) : (i64) -> ()
  }
  // %new_value cannot be referenced outside of the region

^bb3:
  ...
}