sv.always
```mlir
#loc = loc("/tmp/tmph7zg1qix.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    "sv.always"(%arg0) ({
      "sv.error"() {message = "hello"} : () -> ()
    }) {events = [0 : i32]} : (i1) -> ()
    "sv.always"() ({
      "sv.error"() {message = "world"} : () -> ()
    }) {events = []} : () -> ()
    %0 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output result : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.alwayscomb
```mlir
#loc = loc("/tmp/tmpkk4hhywh.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    "sv.alwayscomb"() ({
      "sv.error"() {message = "hello"} : () -> ()
    }) : () -> ()
    %0 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output result : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.alwaysff
```mlir
#loc = loc("/tmp/tmp7_a9g5_6.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    "sv.alwaysff"(%arg0) ({
      "sv.error"() {message = "hello"} : () -> ()
    }, {
    }) {clockEdge = 0 : i32, resetStyle = 0 : i32} : (i1) -> ()
    %0 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output result : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.array_index_inout
```mlir
#loc = loc("/tmp/tmpdk7lmh4s.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.array_create"(%arg0, %arg1) : (i8, i8) -> !hw.array<2xi8>
    %1 = "sv.reg"() {name = "reg"} : () -> !hw.inout<array<2xi8>>
    "sv.assign"(%1, %0) : (!hw.inout<array<2xi8>>, !hw.array<2xi8>) -> ()
    %2 = "hw.constant"() {value = 0 : i8} : () -> i8
    %3 = "hw.constant"() {value = 1 : i8} : () -> i8
    %4 = "sv.array_index_inout"(%1, %2) : (!hw.inout<array<2xi8>>, i8) -> !hw.inout<i8>
    %5 = "sv.array_index_inout"(%1, %3) : (!hw.inout<array<2xi8>>, i8) -> !hw.inout<i8>
    %6 = "sv.read_inout"(%4) : (!hw.inout<i8>) -> i8
    %7 = "sv.read_inout"(%5) : (!hw.inout<i8>) -> i8
    %8 = "comb.add"(%6, %7) : (i8, i8) -> i8
    "hw.output"(%8) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.assert
```mlir
#loc = loc("/tmp/tmpigy9xg7k.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.initial"() ({
      "sv.assert"(%0) {defer = 0 : i32} : (i1) -> ()
    }) : () -> ()
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.assert.concurrent
```mlir
#loc = loc("/tmp/tmpwnyu354j.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.assert.concurrent"(%arg0, %0) {event = 0 : i32} : (i1, i1) -> ()
    %1 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.assign
```mlir
#loc = loc("/tmp/tmp2rifle7_.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.reg"() {name = "reg_a"} : () -> !hw.inout<i8>
    %1 = "sv.reg"() {name = "reg_b"} : () -> !hw.inout<i8>
    "sv.assign"(%0, %arg0) : (!hw.inout<i8>, i8) -> ()
    "sv.assign"(%1, %arg1) : (!hw.inout<i8>, i8) -> ()
    %2 = "sv.read_inout"(%0) : (!hw.inout<i8>) -> i8
    %3 = "sv.read_inout"(%1) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%2, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.assume
```mlir
#loc = loc("/tmp/tmp_ge0nfhd.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.initial"() ({
      "sv.assume"(%0) {defer = 0 : i32} : (i1) -> ()
    }) : () -> ()
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.assume.concurrent
```mlir
#loc = loc("/tmp/tmp_ikt2knd.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.assume.concurrent"(%arg0, %0) {event = 0 : i32} : (i1, i1) -> ()
    %1 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.bpassign
```mlir
#loc = loc("/tmp/tmpyxb5i9mu.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "sv.reg"() {name = "reg"} : () -> !hw.inout<i8>
    "sv.always"() ({
      "sv.bpassign"(%0, %arg1) : (!hw.inout<i8>, i8) -> ()
    }) {events = []} : () -> ()
    %1 = "sv.read_inout"(%0) : (!hw.inout<i8>) -> i8
    %2 = "comb.add"(%1, %arg2) : (i8, i8) -> i8
    "hw.output"(%2) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.case
```mlir
#loc = loc("/tmp/tmpo_7y1i_k.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    "sv.initial"() ({
      "sv.case"(%arg0) ({
        "sv.error"() {message = "zero"} : () -> ()
      }, {
        "sv.error"() {message = "one"} : () -> ()
      }) {casePatterns = [0 : i2, 1 : i2], caseStyle = 0 : i32, validationQualifier = #sv<validation_qualifier plain>} : (i1) -> ()
    }) : () -> ()
    %0 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.constantX
```mlir
#loc = loc("/tmp/tmph6wys47q.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "sv.constantX"() : () -> i8
    %1 = "comb.add"(%0, %arg2) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.constantZ
```mlir
#loc = loc("/tmp/tmpteap501k.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "sv.constantZ"() : () -> i8
    %1 = "comb.add"(%0, %arg2) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.cover
```mlir
#loc = loc("/tmp/tmpy2hrnaq3.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.initial"() ({
      "sv.cover"(%0) {defer = 0 : i32} : (i1) -> ()
    }) : () -> ()
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.cover.concurrent
```mlir
#loc = loc("/tmp/tmph5zmr2h8.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.cover.concurrent"(%arg0, %0) {event = 0 : i32} : (i1, i1) -> ()
    %1 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.error
```mlir
#loc = loc("/tmp/tmpt48e1y84.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.initial"() ({
      "sv.error"() {message = "error"} : () -> ()
    }) : () -> ()
    %1 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.exit
```mlir
#loc = loc("/tmp/tmptdfay1nq.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.initial"() ({
      "sv.exit"() : () -> ()
    }) : () -> ()
    %1 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.fatal
```mlir
#loc = loc("/tmp/tmpz9ijmhgi.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.initial"() ({
      "sv.fatal"() {verbosity = 2 : i8} : () -> ()
    }) : () -> ()
    %1 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.finish
```mlir
#loc = loc("/tmp/tmpix__vntr.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.initial"() ({
      "sv.finish"() {verbosity = 2 : i8} : () -> ()
    }) : () -> ()
    %1 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.for
```mlir
#loc = loc("/tmp/tmpuladmepl.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "hw.constant"() {value = 0 : i8} : () -> i8
    %1 = "hw.constant"() {value = 1 : i8} : () -> i8
    %2 = "sv.reg"() {name = "reg"} : () -> !hw.inout<i8>
    "sv.assign"(%2, %arg1) : (!hw.inout<i8>, i8) -> ()
    "sv.always"() ({
      "sv.for"(%0, %arg2, %1) ({
      ^bb0(%arg3: i8):
        %4 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
        %5 = "comb.add"(%4, %1) : (i8, i8) -> i8
        "sv.passign"(%2, %5) : (!hw.inout<i8>, i8) -> ()
      }) {inductionVarName = "i"} : (i8, i8, i8) -> ()
    }) {events = []} : () -> ()
    %3 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
    "hw.output"(%3) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.force
```mlir
#loc = loc("/tmp/tmp73zeh5hg.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "sv.reg"() {name = "reg_a"} : () -> !hw.inout<i8>
    %1 = "sv.reg"() {name = "reg_b"} : () -> !hw.inout<i8>
    "sv.initial"() ({
      "sv.force"(%0, %arg2) : (!hw.inout<i8>, i8) -> ()
      "sv.force"(%1, %arg1) : (!hw.inout<i8>, i8) -> ()
      "sv.release"(%0) : (!hw.inout<i8>) -> ()
      "sv.release"(%1) : (!hw.inout<i8>) -> ()
    }) : () -> ()
    %2 = "sv.read_inout"(%0) : (!hw.inout<i8>) -> i8
    %3 = "sv.read_inout"(%1) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%2, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.fwrite
```mlir
#loc = loc("/tmp/tmp94zvo700.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.constant"() {value = 1 : i32} : () -> i32
    "sv.initial"() ({
      "sv.fwrite"(%0) {format_string = "format string"} : (i32) -> ()
    }) : () -> ()
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.generate
sv.generate.case
```mlir
#loc = loc("/tmp/tmpi6poyt3f.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    "sv.generate"() ({
      "sv.generate.case"() {caseNames = [], casePatterns = [], cond = "case_1"} : () -> ()
      "sv.generate.case"() {caseNames = [], casePatterns = [], cond = "case_2"} : () -> ()
    }) {sym_name = "test"} : () -> ()
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.if
```mlir
#loc = loc("/tmp/tmporeqyf0x.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.constant"() {value = true} : () -> i1
    "sv.always"() ({
      "sv.if"(%0) ({
        "sv.error"() {message = "error"} : () -> ()
      }, {
      }) : (i1) -> ()
    }) {events = []} : () -> ()
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.ifdef
```mlir
#loc = loc("/tmp/tmpth7nni9t.mlir":2:42)
"builtin.module"() ({
  "sv.macro.decl"() {sym_name = "MACRO", verilogName = "1"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    "sv.ifdef"() ({
    ^bb0:
    }, {
      "sv.always"() ({
        "sv.error"() {message = "not defined"} : () -> ()
      }) {events = []} : () -> ()
    }) {cond = #sv<macro.ident @MACRO>} : () -> ()
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.ifdef.procedural
```mlir
#loc = loc("/tmp/tmpn2uq8ns_.mlir":2:42)
"builtin.module"() ({
  "sv.macro.decl"() {sym_name = "MACRO", verilogName = "1"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    "sv.always"() ({
      "sv.ifdef.procedural"() ({
      ^bb0:
      }, {
        "sv.error"() {message = "undefined"} : () -> ()
      }) {cond = #sv<macro.ident @MACRO>} : () -> ()
    }) {events = []} : () -> ()
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.indexed_part_select
```mlir
#loc = loc("/tmp/tmpdad045yf.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.constant"() {value = 0 : i8} : () -> i8
    %1 = "sv.indexed_part_select"(%arg0, %0) {width = 8 : i32} : (i8, i8) -> i8
    %2 = "sv.indexed_part_select"(%arg1, %0) {width = 8 : i32} : (i8, i8) -> i8
    %3 = "comb.add"(%1, %2) : (i8, i8) -> i8
    "hw.output"(%3) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.indexed_part_select_inout
```mlir
#loc = loc("/tmp/tmp_x63o6at.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.array_create"(%arg0, %arg1, %arg0, %arg1) : (i8, i8, i8, i8) -> !hw.array<4xi8>
    %1 = "sv.reg"() {name = "reg"} : () -> !hw.inout<array<4xi8>>
    "sv.assign"(%1, %0) : (!hw.inout<array<4xi8>>, !hw.array<4xi8>) -> ()
    %2 = "hw.constant"() {value = 0 : i8} : () -> i8
    %3 = "sv.indexed_part_select_inout"(%1, %2) {width = 2 : i32} : (!hw.inout<array<4xi8>>, i8) -> !hw.inout<array<2xi8>>
    %4 = "sv.read_inout"(%3) : (!hw.inout<array<2xi8>>) -> !hw.array<2xi8>
    %5 = "hw.constant"() {value = false} : () -> i1
    %6 = "hw.constant"() {value = true} : () -> i1
    %7 = "hw.array_get"(%4, %5) : (!hw.array<2xi8>, i1) -> i8
    %8 = "hw.array_get"(%4, %6) : (!hw.array<2xi8>, i1) -> i8
    %9 = "comb.add"(%7, %8) : (i8, i8) -> i8
    "hw.output"(%9) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.info
```mlir
#loc = loc("/tmp/tmp__7nkujt.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    "sv.initial"() ({
      "sv.info"() {message = "info"} : () -> ()
    }) : () -> ()
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.initial
```mlir
#loc = loc("/tmp/tmplkhyx2tt.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    "sv.initial"() ({
      "sv.info"() {message = "initial"} : () -> ()
    }) : () -> ()
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.interface
sv.interface.instance
sv.interface.modport
sv.interface.signal
sv.interface.signal.assign
sv.interface.signal.read
```mlir
"builtin.module"() ({
^bb0:
}) : () -> ()
```

sv.localparam
```mlir
"builtin.module"() ({
^bb0:
}) : () -> ()
```

sv.logic
```mlir
#loc = loc("/tmp/tmpuq34y89d.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.logic"() {name = "logic_a"} : () -> !hw.inout<i8>
    %1 = "sv.logic"() {name = "logic_b"} : () -> !hw.inout<i8>
    "sv.assign"(%0, %arg0) : (!hw.inout<i8>, i8) -> ()
    "sv.assign"(%1, %arg1) : (!hw.inout<i8>, i8) -> ()
    %2 = "sv.read_inout"(%0) : (!hw.inout<i8>) -> i8
    %3 = "sv.read_inout"(%1) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%2, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.macro.decl
```mlir
#loc = loc("/tmp/tmpmuj9ob3t.mlir":2:42)
"builtin.module"() ({
  "sv.macro.decl"() {sym_name = "MACRO", verilogName = "1"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.macro.ref"() {macroName = @MACRO} : () -> i1
    "sv.always"() ({
      "sv.assert"(%0) {defer = 0 : i32} : (i1) -> ()
    }) {events = []} : () -> ()
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.macro.def
sv.macro.ref
```mlir
#loc = loc("/tmp/tmpu9l312x9.mlir":2:42)
"builtin.module"() ({
  "sv.macro.decl"() {sym_name = "MACRO"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    "sv.macro.def"() {format_string = "1", macroName = @MACRO, symbols = []} : () -> ()
    %0 = "sv.macro.ref"() {macroName = @MACRO} : () -> i1
    "sv.always"() ({
      "sv.assert"(%0) {defer = 0 : i32} : (i1) -> ()
    }) {events = []} : () -> ()
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.macro.ref.se
```mlir
#loc = loc("/tmp/tmp8jf_k9ej.mlir":2:42)
"builtin.module"() ({
  "sv.macro.decl"() {sym_name = "MACRO"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    "sv.macro.def"() {format_string = "1", macroName = @MACRO, symbols = []} : () -> ()
    %0 = "sv.macro.ref.se"() {macroName = @MACRO} : () -> i1
    "sv.always"() ({
      "sv.assert"(%0) {defer = 0 : i32} : (i1) -> ()
    }) {events = []} : () -> ()
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.modport.get
```mlir
"builtin.module"() ({
^bb0:
}) : () -> ()
```

sv.nonstandard.deposit
```mlir
"builtin.module"() ({
^bb0:
}) : () -> ()
```

sv.ordered
```mlir
#loc = loc("/tmp/tmp5m8vc9s1.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.wire"() {name = "wire_a"} : () -> !hw.inout<i8>
    %1 = "sv.wire"() {name = "wire_b"} : () -> !hw.inout<i8>
    "sv.ordered"() ({
      "sv.assign"(%0, %arg0) : (!hw.inout<i8>, i8) -> ()
      "sv.assign"(%1, %arg1) : (!hw.inout<i8>, i8) -> ()
    }) : () -> ()
    %2 = "sv.read_inout"(%0) : (!hw.inout<i8>) -> i8
    %3 = "sv.read_inout"(%1) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%2, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.passign
sv.read_inout
```mlir
#loc = loc("/tmp/tmpmd5f_dmk.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.reg"() {name = "reg_a"} : () -> !hw.inout<i8>
    %1 = "sv.reg"() {name = "reg_b"} : () -> !hw.inout<i8>
    "sv.always"() ({
      "sv.passign"(%0, %arg0) : (!hw.inout<i8>, i8) -> ()
      "sv.passign"(%1, %arg1) : (!hw.inout<i8>, i8) -> ()
    }) {events = []} : () -> ()
    %2 = "sv.read_inout"(%0) : (!hw.inout<i8>) -> i8
    %3 = "sv.read_inout"(%1) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%2, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.readmem
sv.reg
```mlir
#loc = loc("/tmp/tmp4zji5bou.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.reg"() {name = "file"} : () -> !hw.inout<i8>
    "sv.initial"() ({
      "sv.readmem"(%0) {base = 0 : i32, filename = "input.txt"} : (!hw.inout<i8>) -> ()
    }) : () -> ()
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.release
```mlir
#loc = loc("/tmp/tmp7eseprzp.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    %0 = "sv.reg"() {name = "reg_a"} : () -> !hw.inout<i8>
    %1 = "sv.reg"() {name = "reg_b"} : () -> !hw.inout<i8>
    "sv.initial"() ({
      "sv.force"(%0, %arg2) : (!hw.inout<i8>, i8) -> ()
      "sv.force"(%1, %arg1) : (!hw.inout<i8>, i8) -> ()
      "sv.release"(%0) : (!hw.inout<i8>) -> ()
      "sv.release"(%1) : (!hw.inout<i8>) -> ()
    }) : () -> ()
    %2 = "sv.read_inout"(%0) : (!hw.inout<i8>) -> i8
    %3 = "sv.read_inout"(%1) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%2, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.stop
```mlir
#loc = loc("/tmp/tmp950k_elk.mlir":1:55)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i8, %arg2: i8):
    "sv.always"() ({
      "sv.stop"() {verbosity = 2 : i8} : () -> ()
    }) {events = []} : () -> ()
    %0 = "comb.add"(%arg1, %arg2) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input clk : i1, input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.struct_field_inout
```mlir
#loc = loc("/tmp/tmp9n108995.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.struct_create"(%arg0, %arg1) : (i8, i8) -> !hw.struct<a: i8, b: i8>
    %1 = "sv.reg"() {name = "reg"} : () -> !hw.inout<struct<a: i8, b: i8>>
    "sv.assign"(%1, %0) : (!hw.inout<struct<a: i8, b: i8>>, !hw.struct<a: i8, b: i8>) -> ()
    %2 = "sv.struct_field_inout"(%1) {field = "a"} : (!hw.inout<struct<a: i8, b: i8>>) -> !hw.inout<i8>
    %3 = "sv.struct_field_inout"(%1) {field = "b"} : (!hw.inout<struct<a: i8, b: i8>>) -> !hw.inout<i8>
    %4 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
    %5 = "sv.read_inout"(%3) : (!hw.inout<i8>) -> i8
    %6 = "comb.add"(%4, %5) : (i8, i8) -> i8
    "hw.output"(%6) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.system
sv.system.sampled
```mlir
"builtin.module"() ({
^bb0:
}) : () -> ()
```

sv.verbatim
```mlir
#loc = loc("/tmp/tmpb235xvqj.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    "sv.verbatim"() {format_string = "verbatim", symbols = []} : () -> ()
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.verbatim.expr
```mlir
#loc = loc("/tmp/tmpd9dplosp.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.verbatim.expr"() {format_string = "123", symbols = []} : () -> i8
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.verbatim.expr.se
```mlir
#loc = loc("/tmp/tmpdlus4xy4.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.verbatim.expr.se"() {format_string = "123", symbols = []} : () -> i8
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.warning
```mlir
#loc = loc("/tmp/tmpk4g87gn0.mlir":1:44)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    "sv.initial"() ({
      "sv.error"() {message = "error"} : () -> ()
      "sv.info"() {message = "info"} : () -> ()
      "sv.warning"() {message = "warning"} : () -> ()
      "sv.verbatim"() {format_string = "verbatim", symbols = []} : () -> ()
    }) : () -> ()
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output result : i8>, parameters = [], result_locs = [#loc], sym_name = "Adder"} : () -> ()
}) : () -> ()
```

sv.wire
```mlir
#loc = loc("/tmp/tmppe7gnf3l.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.wire"() {name = "wire_a"} : () -> !hw.inout<i8>
    %1 = "sv.wire"() {name = "wire_b"} : () -> !hw.inout<i8>
    "sv.assign"(%0, %arg0) : (!hw.inout<i8>, i8) -> ()
    "sv.assign"(%1, %arg1) : (!hw.inout<i8>, i8) -> ()
    %2 = "sv.read_inout"(%0) : (!hw.inout<i8>) -> i8
    %3 = "sv.read_inout"(%1) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%2, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.xmr
```mlir
#loc = loc("/tmp/tmp1af0j_ap.mlir":1:32)
#loc1 = loc("/tmp/tmp1af0j_ap.mlir":7:43)
#loc2 = loc("/tmp/tmp1af0j_ap.mlir":7:57)
#loc3 = loc("/tmp/tmp1af0j_ap.mlir":12:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "sv.reg"() {name = "y", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
    %1 = "sv.wire"() {name = "z", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
    "hw.output"(%arg0) : (i8) -> ()
  }) {module_type = !hw.modty<input x : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Wrap"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.instance"(%arg0) {argNames = ["x"], instanceName = "wrap", moduleName = @Wrap, parameters = [], resultNames = ["res"]} : (i8) -> i8
    "hw.output"(%arg1, %0) : (i8, i8) -> ()
  }) {module_type = !hw.modty<input x : i8, input y : i8, output res1 : i8, output res2 : i8>, parameters = [], result_locs = [#loc1, #loc2], sym_name = "Swap"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0:2 = "hw.instance"(%arg0, %arg1) {argNames = ["x", "y"], instanceName = "swap1", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
    %1:2 = "hw.instance"(%arg0, %arg1) {argNames = ["x", "y"], instanceName = "swap2", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
    %2 = "sv.xmr"() {isRooted, path = ["swap1", "wrap"], terminal = "y"} : () -> !hw.inout<i8>
    %3 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%1#1, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output result : i8>, parameters = [], result_locs = [#loc3], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

sv.xmr.ref
```mlir
#loc = loc("/tmp/tmpxq08y_ka.mlir":1:33)
#loc1 = loc("/tmp/tmpxq08y_ka.mlir":8:45)
#loc2 = loc("/tmp/tmpxq08y_ka.mlir":8:59)
#loc3 = loc("/tmp/tmpxq08y_ka.mlir":16:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "sv.reg"() {inner_sym = #hw<innerSym@sym_x>, name = "y", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
    %1 = "sv.wire"() {inner_sym = #hw<innerSym@sym_y>, name = "z", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
    "sv.assign"(%0, %arg0) : (!hw.inout<i8>, i8) -> ()
    "hw.output"(%arg0) : (i8) -> ()
  }) {module_type = !hw.modty<input xx : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Wrap"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.instance"(%arg0) {argNames = ["xx"], inner_sym = #hw<innerSym@sym_wrap>, instanceName = "wrap", moduleName = @Wrap, parameters = [], resultNames = ["res"]} : (i8) -> i8
    "hw.output"(%arg1, %0) : (i8, i8) -> ()
  }) {module_type = !hw.modty<input xx : i8, input yy : i8, output res1 : i8, output res2 : i8>, parameters = [], result_locs = [#loc1, #loc2], sym_name = "Swap"} : () -> ()
  "hw.hierpath"() {namepath = [#hw.innerNameRef<@Foo::@sym_swap1>, #hw.innerNameRef<@Swap::@sym_wrap>, #hw.innerNameRef<@Wrap::@sym_x>], sym_name = "ref1"} : () -> ()
  "hw.hierpath"() {namepath = [#hw.innerNameRef<@Foo::@sym_swap2>, #hw.innerNameRef<@Swap::@sym_wrap>, #hw.innerNameRef<@Wrap::@sym_y>], sym_name = "ref2"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0:2 = "hw.instance"(%arg0, %arg1) {argNames = ["xx", "yy"], inner_sym = #hw<innerSym@sym_swap1>, instanceName = "swap1", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
    %1:2 = "hw.instance"(%arg0, %arg1) {argNames = ["xx", "yy"], inner_sym = #hw<innerSym@sym_swap2>, instanceName = "swap2", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
    %2 = "sv.xmr.ref"() {ref = @ref1, verbatimSuffix = ""} : () -> !hw.inout<i8>
    %3 = "sv.xmr.ref"() {ref = @ref2, verbatimSuffix = ".x.y.z[42]"} : () -> !hw.inout<i8>
    %4 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
    %5 = "comb.add"(%1#0, %4) : (i8, i8) -> i8
    "hw.output"(%5) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc3], sym_name = "Foo"} : () -> ()
}) : () -> ()
```
