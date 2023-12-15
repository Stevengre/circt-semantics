#loc = loc("sv_basic.mlir":8:21)
#loc1 = loc("sv_basic.mlir":8:35)
#loc2 = loc("sv_basic.mlir":8:49)
#loc3 = loc("sv_basic.mlir":295:36)
#loc4 = loc("sv_basic.mlir":295:47)
#loc5 = loc("sv_basic.mlir":296:31)
#loc6 = loc("sv_basic.mlir":296:42)
#loc7 = loc("sv_basic.mlir":301:18)
#loc8 = loc("sv_basic.mlir":301:29)
#loc9 = loc("sv_basic.mlir":307:23)
#loc10 = loc("sv_basic.mlir":316:29)
#loc11 = loc("sv_basic.mlir":316:43)
#loc12 = loc("sv_basic.mlir":316:58)
#loc13 = loc("sv_basic.mlir":316:70)
#loc14 = loc("sv_basic.mlir":340:27)
#loc15 = loc("sv_basic.mlir":352:30)
"builtin.module"() ({
  "sv.macro.decl"() {sym_name = "RANDOM"} : () -> ()
  "sv.macro.decl"() {sym_name = "PRINTF_COND_"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i1, %arg2: i8):
    %0 = "hw.constant"() {value = -2147483646 : i32} : () -> i32
    %1 = "sv.localparam"() {name = "param_x", value = 11 : i42} : () -> i42
    "sv.always"(%arg0) ({
      "sv.ifdef.procedural"() ({
      ^bb0:
      }, {
        %10 = "sv.macro.ref"() {macroName = @PRINTF_COND_} : () -> i1
        %11 = "sv.constantX"() : () -> i1
        %12 = "sv.constantZ"() : () -> i1
        %13 = "comb.and"(%10, %11, %12, %arg1) : (i1, i1, i1, i1) -> i1
        "sv.if"(%13) ({
          "sv.fwrite"(%0) {format_string = "Hi"} : (i32) -> ()
        }, {
        }) : (i1) -> ()
        "sv.if"(%13) ({
          "sv.fwrite"(%0, %13) {format_string = "%x"} : (i32, i1) -> ()
        }, {
          "sv.fwrite"(%0) {format_string = "There"} : (i32) -> ()
        }) : (i1) -> ()
      }) {cond = #sv<macro.ident "SYNTHESIS">} : () -> ()
    }) {events = [0 : i32]} : (i1) -> ()
    "sv.alwaysff"(%arg0) ({
      "sv.fwrite"(%0) {format_string = "Yo"} : (i32) -> ()
    }, {
    }) {clockEdge = 0 : i32, resetStyle = 0 : i32} : (i1) -> ()
    "sv.alwaysff"(%arg0, %arg1) ({
      "sv.fwrite"(%0) {format_string = "Sync Main Block"} : (i32) -> ()
    }, {
      "sv.fwrite"(%0) {format_string = "Sync Reset Block"} : (i32) -> ()
    }) {clockEdge = 0 : i32, resetEdge = 0 : i32, resetStyle = 1 : i32} : (i1, i1) -> ()
    "sv.alwaysff"(%arg0, %arg1) ({
      "sv.fwrite"(%0) {format_string = "Async Main Block"} : (i32) -> ()
    }, {
      "sv.fwrite"(%0) {format_string = "Async Reset Block"} : (i32) -> ()
    }) {clockEdge = 0 : i32, resetEdge = 1 : i32, resetStyle = 2 : i32} : (i1, i1) -> ()
    "sv.initial"() ({
      "sv.if"(%arg0) ({
      ^bb0:
      }, {
      }) : (i1) -> ()
    }) : () -> ()
    "sv.initial"() ({
      "sv.case"(%arg2) ({
        "sv.fwrite"(%0) {format_string = "x"} : (i32) -> ()
      }, {
        "sv.fwrite"(%0) {format_string = "y"} : (i32) -> ()
      }, {
        "sv.fwrite"(%0) {format_string = "z"} : (i32) -> ()
      }) {casePatterns = [6 : i16, 9 : i16, unit], caseStyle = 2 : i32, validationQualifier = #sv<validation_qualifier plain>} : (i8) -> ()
    }) : () -> ()
    "sv.initial"() ({
      "sv.case"(%arg1) ({
        "sv.fwrite"(%0) {format_string = "zero"} : (i32) -> ()
      }, {
        "sv.fwrite"(%0) {format_string = "one"} : (i32) -> ()
      }) {casePatterns = [0 : i2, 1 : i2], caseStyle = 0 : i32, validationQualifier = #sv<validation_qualifier plain>} : (i1) -> ()
      "sv.case"(%arg1) ({
        "sv.fwrite"(%0) {format_string = "zero"} : (i32) -> ()
      }, {
        "sv.fwrite"(%0) {format_string = "one"} : (i32) -> ()
      }) {casePatterns = [0 : i2, 1 : i2], caseStyle = 0 : i32, validationQualifier = #sv<validation_qualifier plain>} : (i1) -> ()
      "sv.case"(%arg1) ({
        "sv.fwrite"(%0) {format_string = "zero"} : (i32) -> ()
      }, {
        "sv.fwrite"(%0) {format_string = "one"} : (i32) -> ()
      }) {casePatterns = [0 : i2, 1 : i2], caseStyle = 1 : i32, validationQualifier = #sv<validation_qualifier plain>} : (i1) -> ()
      "sv.case"(%arg1) ({
        "sv.fwrite"(%0) {format_string = "zero"} : (i32) -> ()
      }, {
        "sv.fwrite"(%0) {format_string = "one"} : (i32) -> ()
      }) {casePatterns = [0 : i2, 1 : i2], caseStyle = 2 : i32, validationQualifier = #sv<validation_qualifier plain>} : (i1) -> ()
    }) : () -> ()
    
    %2 = "sv.reg"() {name = "combWire"} : () -> !hw.inout<i1>
    %3 = "sv.reg"() {name = "selReg"} : () -> !hw.inout<i10>
    %4 = "sv.wire"() {name = "combWire2"} : () -> !hw.inout<i1>
    %5 = "sv.reg"() {name = "regForce"} : () -> !hw.inout<i1>
    
    "sv.alwayscomb"() ({
      %10 = "sv.constantX"() : () -> i1
      "sv.passign"(%2, %10) : (!hw.inout<i1>, i1) -> ()
      %11 = "hw.constant"() {value = 2 : i3} : () -> i3
      %12 = "sv.indexed_part_select_inout"(%3, %11) {width = 1 : i32} : (!hw.inout<i10>, i3) -> !hw.inout<i1>
      "sv.passign"(%12, %10) : (!hw.inout<i1>, i1) -> ()
      "sv.force"(%4, %10) : (!hw.inout<i1>, i1) -> ()
      "sv.force"(%5, %10) : (!hw.inout<i1>, i1) -> ()
      "sv.release"(%4) : (!hw.inout<i1>) -> ()
      "sv.release"(%5) : (!hw.inout<i1>) -> ()
    }) : () -> ()
    %6 = "sv.reg"() {name = "reg23"} : () -> !hw.inout<i23>
    %7 = "sv.reg"() {name = "regStruct23"} : () -> !hw.inout<i23>
    %8 = "sv.reg"() {inner_sym = #hw<innerSym@regSym1>, name = "reg24"} : () -> !hw.inout<i23>
    %9 = "sv.wire"() {inner_sym = #hw<innerSym@wireSym1>, name = "wire25"} : () -> !hw.inout<i23>
    "sv.initial"() ({
      "sv.stop"() {verbosity = 1 : i8} : () -> ()
      "sv.finish"() {verbosity = 1 : i8} : () -> ()
      "sv.exit"() : () -> ()
    }) : () -> ()
    "sv.initial"() ({
      "sv.fatal"() {verbosity = 1 : i8} : () -> ()
      "sv.fatal"() {message = "hello", verbosity = 1 : i8} : () -> ()
      "sv.fatal"(%arg0) {message = "hello %d", verbosity = 1 : i8} : (i1) -> ()
      "sv.error"() : () -> ()
      "sv.error"() {message = "hello"} : () -> ()
      "sv.error"(%arg0) {message = "hello %d"} : (i1) -> ()
      "sv.warning"() : () -> ()
      "sv.warning"() {message = "hello"} : () -> ()
      "sv.warning"(%arg0) {message = "hello %d"} : (i1) -> ()
      "sv.info"() : () -> ()
      "sv.info"() {message = "hello"} : () -> ()
      "sv.info"(%arg0) {message = "hello %d"} : (i1) -> ()
    }) : () -> ()
    "sv.initial"() ({
      %10 = "sv.reg"() {inner_sym = #hw<innerSym@MemForReadMem>, name = "memForReadMem"} : () -> !hw.inout<uarray<8xi32>>
      "sv.readmem"(%10) {base = 0 : i32, filename = "file1.txt"} : (!hw.inout<uarray<8xi32>>) -> ()
      "sv.readmem"(%10) {base = 1 : i32, filename = "file2.txt"} : (!hw.inout<uarray<8xi32>>) -> ()
    }) : () -> ()
    "hw.output"() : () -> ()
  }) {module_type = !hw.modty<input arg0 : i1, input arg1 : i1, input arg8 : i8>, parameters = [], port_locs = [#loc, #loc1, #loc2], sym_name = "test1"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i2):
    "hw.output"() : () -> ()
  }) {module_type = !hw.modty<input a : i1, input b : i2>, parameters = [], port_locs = [#loc5, #loc6], sym_name = "InternalDestMod"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i2):
    "hw.instance"(%arg0, %arg1) {argNames = ["a", "b"], doNotPrint = 1 : i64, inner_sym = #hw<innerSym@a1>, instanceName = "whatever", moduleName = @ExternDestMod, parameters = [], resultNames = []} : (i1, i2) -> ()
    "hw.instance"(%arg0, %arg1) {argNames = ["a", "b"], doNotPrint = 1 : i64, inner_sym = #hw<innerSym@b1>, instanceName = "yo", moduleName = @InternalDestMod, parameters = [], resultNames = []} : (i1, i2) -> ()
    "hw.output"() : () -> ()
  }) {module_type = !hw.modty<input a : i1, input b : i2>, parameters = [], port_locs = [#loc7, #loc8], sym_name = "AB"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i23):
    %0 = "sv.xmr"() {isRooted, path = ["a", "b"], terminal = "c"} : () -> !hw.inout<i23>
    %1 = "sv.xmr"() {path = ["a", "b"], terminal = "c"} : () -> !hw.inout<i3>
    %2 = "sv.read_inout"(%0) : (!hw.inout<i23>) -> i23
    "sv.assign"(%0, %arg0) : (!hw.inout<i23>, i23) -> ()
    "hw.output"() : () -> ()
  }) {module_type = !hw.modty<input a : i23>, parameters = [], port_locs = [#loc9], sym_name = "XMR_src"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i4, %arg1: i8):
    %0 = "sv.reg"() {name = "myReg2"} : () -> !hw.inout<i18>
    %1 = "hw.constant"() {value = 7 : i4} : () -> i4
    %2 = "sv.indexed_part_select_inout"(%0, %1) {width = 8 : i32} : (!hw.inout<i18>, i4) -> !hw.inout<i8>
    "sv.assign"(%2, %arg1) : (!hw.inout<i8>, i8) -> ()
    %3 = "sv.indexed_part_select_inout"(%0, %1) {decrement, width = 8 : i32} : (!hw.inout<i18>, i4) -> !hw.inout<i8>
    "sv.assign"(%3, %arg1) : (!hw.inout<i8>, i8) -> ()
    %4 = "hw.constant"() {value = 3 : i4} : () -> i4
    %5 = "sv.read_inout"(%0) : (!hw.inout<i18>) -> i18
    %6 = "sv.indexed_part_select"(%5, %4) {width = 3 : i32} : (i18, i4) -> i3
    %7 = "sv.read_inout"(%0) : (!hw.inout<i18>) -> i18
    %8 = "sv.indexed_part_select"(%7, %arg0) {decrement, width = 5 : i32} : (i18, i4) -> i5
    "hw.output"(%6, %8) : (i3, i5) -> ()
  }) {module_type = !hw.modty<input in4 : i4, input in8 : i8, output a : i3, output b : i5>, parameters = [], port_locs = [#loc10, #loc11, #loc12, #loc13], sym_name = "part_select"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i1):
    "sv.ifdef"() ({
      %0 = "sv.wire"() {name = "wire"} : () -> !hw.inout<i1>
      "sv.assign"(%0, %arg0) : (!hw.inout<i1>, i1) -> ()
    }, {
    }) {cond = #sv<macro.ident "foo">} : () -> ()
    "hw.output"() : () -> ()
  }) {module_type = !hw.modty<input a : i1>, parameters = [], port_locs = [#loc14], sym_name = "nested_wire"} : () -> ()
  
  "hw.module"() ({
  ^bb0(%arg0: i1):
    "sv.ordered"() ({
      "sv.ifdef"() ({
        %0 = "sv.wire"() {name = "wire"} : () -> !hw.inout<i1>
        "sv.assign"(%0, %arg0) : (!hw.inout<i1>, i1) -> ()
      }, {
      }) {cond = #sv<macro.ident "foo">} : () -> ()
      "sv.ifdef"() ({
        %0 = "sv.wire"() {name = "wire"} : () -> !hw.inout<i1>
        "sv.assign"(%0, %arg0) : (!hw.inout<i1>, i1) -> ()
      }, {
      }) {cond = #sv<macro.ident "bar">} : () -> ()
    }) : () -> ()
    "hw.output"() : () -> ()
  }) {module_type = !hw.modty<input a : i1>, parameters = [], port_locs = [#loc15], sym_name = "ordered_region"} : () -> ()
  
  "hw.module"() ({
    %0 = "sv.wire"() {inner_sym = #hw<innerSym@a>, name = "a"} : () -> !hw.inout<i2>
    "hw.output"() : () -> ()
  }) {module_type = !hw.modty<>, parameters = [], sym_name = "XMRRefFoo"} : () -> ()

  "hw.module"() ({
    "hw.instance"() {argNames = [], inner_sym = #hw<innerSym@foo>, instanceName = "foo", moduleName = @XMRRefFoo, parameters = [], resultNames = []} : () -> ()
    "hw.instance"() {argNames = [], inner_sym = #hw<innerSym@bar>, instanceName = "bar", moduleName = @XMRRefBar, parameters = [], resultNames = []} : () -> ()
    %0 = "sv.xmr.ref"() {ref = @ref, verbatimSuffix = ""} : () -> !hw.inout<i2>
    %1 = "sv.xmr.ref"() {ref = @ref2, verbatimSuffix = ".x.y.z[42]"} : () -> !hw.inout<i8>
    "hw.output"() : () -> ()
  }) {module_type = !hw.modty<>, parameters = [], sym_name = "XMRRefOp"} : () -> ()
}) : () -> ()
