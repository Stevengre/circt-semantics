#loc = loc("<stdin>":4:11)
#loc1 = loc("<stdin>":5:11)
#loc2 = loc("src/main/scala/Main.scala":14:16)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i1, %arg2: i8, %arg3: i8):
    %0 = "comb.add"(%arg2, %arg3) {sv.namehint = "_io_out_T_1"} : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {argLocs = [], argNames = ["clock", "reset", "io_a", "io_b"], comment = "", function_type = (i1, i1, i8, i8) -> i8, parameters = [], resultLocs = [], resultNames = ["io_out"], sym_name = "Adder"} : () -> ()
}) : () -> ()