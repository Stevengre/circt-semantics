#loc = loc("sv/generate/generate.mlir":1:42)
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

