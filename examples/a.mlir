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
    %2 = "sv.reg"() {name = "combWire", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i1>
    %3 = "sv.reg"() {name = "selReg", sv.attributes = [#sv.attribute<"dont_merge">, #sv.attribute<"dont_retime" = "true">]} : () -> !hw.inout<i10>
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
    %7 = "sv.reg"() {name = "regStruct23"} : () -> !hw.inout<struct<foo: i23>>
    %8 = "sv.reg"() {inner_sym = #hw<innerSym@regSym1>, name = "reg24"} : () -> !hw.inout<i23>
    %9 = "sv.wire"() {inner_sym = #hw<innerSym@wireSym1>, name = "wire25"} : () -> !hw.inout<i23>
    
    "hw.output"() : () -> ()
  }) {parameters = [], port_locs = [#loc, #loc1, #loc2], sym_name = "test1"} : () -> ()
  
  "sv.bind"() {instance = #hw.innerNameRef<@AB::@a1>} : () -> ()
  
  "sv.bind"() {instance = #hw.innerNameRef<@AB::@b1>} : () -> ()
  
}) : () -> ()
