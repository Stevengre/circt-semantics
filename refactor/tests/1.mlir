#loc = loc("tests/a.mlir":1:24)
#loc1 = loc("tests/a.mlir":19:31)
"builtin.module"() ({
  "hw.module"() ({
    %0 = "hw.constant"() {value = 0 : i8} : () -> i8
    %1 = "hw.constant"() {value = 1 : i8} : () -> i8
    %2 = "sv.reg"() {name = "reg"} : () -> !hw.inout<i8>
    %3 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
    %4 = "comb.add"(%3, %1) : (i8, i8) -> i8

    %end = "hw.constant"() {value = 4 : i8} : () -> i8
    
    "sv.initial"() ({
      
     "sv.for"(%0, %end, %1) ({
        %tmp = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
        %next = "comb.add"(%tmp, %i) : (i8, i8) -> i8
        "sv.passign"(%2, %next) : (!hw.inout<i8>, i8) -> ()
      }) {inductionVarName = "i"} : (i8, i8, i8) -> ()

      "sv.passign"(%2, %0) : (!hw.inout<i8>, i8) -> ()
    }) : () -> ()
    
    "sv.always"() ({
      "sv.passign"(%2, %4) : (!hw.inout<i8>, i8) -> ()
    }) {events = []} : () -> ()
    
    "hw.output"(%3) : (i8) -> ()
  }) {module_type = !hw.modty<output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Counter"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i8):
    %0 = "hw.instance"() {argNames = [], instanceName = "counter", moduleName = @Counter, parameters = [], resultNames = ["res"]} : () -> i8
    %1 = "comb.add"(%arg0, %0) : (i8, i8) -> i8
    // %arr1 = "hw.array_create"(%1, %1) : (i8, i8) -> !hw.array<2xi8>
    // %arr2 = "hw.array_create"(%1, %1) : (i8, i8) -> !hw.array<2xi8>
    %2 = "hw.constant"() {value = 5 : i8} : () -> i8

    %e1 = "hw.enum.constant"() {field = #hw.enum.field<A, !hw.enum<A, B, C>>} : () -> !hw.enum<A, B, C>
    %e2 = "hw.enum.constant"() {field = #hw.enum.field<A, !hw.enum<A, B, C>>} : () -> !hw.enum<A, B, C>
    %out = "hw.enum.cmp"(%e1, %e2) : (!hw.enum<A, B, C>, !hw.enum<A, B, C>) -> i1

    "hw.output"(%out) : (i1) -> ()
  }) {module_type = !hw.modty<input a : i8, output res : i1>, parameters = [], result_locs = [#loc1], sym_name = "Foo"} : () -> ()
}) : () -> ()
