comb.add
```mlir
#loc = loc("/tmp/tmpstq97hea.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.and
```mlir
#loc = loc("/tmp/tmpw9otxmg1.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.and"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.concat
```mlir
#loc = loc("/tmp/tmpsmaqoii_.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.concat"(%arg0, %arg1) : (i8, i8) -> i16
    "hw.output"(%0) : (i16) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i16>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.divs
```mlir
#loc = loc("/tmp/tmpak7z1w2l.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.divs"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.divu
```mlir
#loc = loc("/tmp/tmps2pgdr0c.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.divu"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.extract
```mlir
#loc = loc("/tmp/tmpm8qbopsv.mlir":1:31)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "comb.extract"(%arg0) <{lowBit = 0 : i32}> : (i8) -> i4
    "hw.output"(%0) : (i4) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i4>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.icmp
```mlir
#loc = loc("/tmp/tmp41n761hh.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.icmp"(%arg0, %arg1) <{predicate = 0 : i64, twoState}> : (i8, i8) -> i1
    "hw.output"(%0) : (i1) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i1>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.mods
```mlir
#loc = loc("/tmp/tmpvx4iy241.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.mods"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.modu
```mlir
#loc = loc("/tmp/tmpjihmwctm.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.modu"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.mul
```mlir
#loc = loc("/tmp/tmpa4jhkdvb.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.mul"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.or
```mlir
#loc = loc("/tmp/tmpdguf_352.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.or"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.parity
```mlir
#loc = loc("/tmp/tmpfze6vhev.mlir":1:31)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "comb.parity"(%arg0) : (i8) -> i1
    "hw.output"(%0) : (i1) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i1>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.replicate
```mlir
#loc = loc("/tmp/tmpgs4lfwbk.mlir":1:31)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "comb.replicate"(%arg0) : (i8) -> i16
    "hw.output"(%0) : (i16) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i16>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.shrs
```mlir
#loc = loc("/tmp/tmpw7zin_hz.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.shrs"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.shru
```mlir
#loc = loc("/tmp/tmpn4hy94no.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.shru"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.sub
```mlir
#loc = loc("/tmp/tmptngfqbua.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.sub"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.truth_table (unsettled)
```mlir
#loc = loc("/tmp/tmp2y3823d8.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i1):
    %0 = "comb.truth_table"(%arg0, %arg1) <{lookupTable = [false, true, true, false]}> : (i1, i1) -> i1
    "hw.output"(%0) : (i1) -> ()
  }) {module_type = !hw.modty<input a : i1, input b : i1, output res : i1>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

comb.xor
```mlir
#loc = loc("/tmp/tmpho4pwp2e.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.xor"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```
