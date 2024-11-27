#loc = loc("sv/readmem/readmem.mlir":1:42)
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

