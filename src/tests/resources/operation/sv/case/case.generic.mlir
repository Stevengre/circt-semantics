#loc = loc("sv/case/case.mlir":1:55)
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

