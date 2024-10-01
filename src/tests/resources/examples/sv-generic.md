sv.alias
```
```

sv.always
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out result: i8) {
    sv.always posedge  %clk {
        sv.error "hello"
    }

    sv.always {
        sv.error "world"
    }
   
    %out = comb.add %a, %b: i8    
    hw.output %out : i8
}
```

sv.alwayscomb
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out result: i8) {
    sv.alwayscomb {
        sv.error "hello"
    }
   
    %out = comb.add %a, %b: i8    
    hw.output %out : i8
}
```

sv.alwaysff
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out result: i8) {
    sv.alwaysff(posedge %clk){
        sv.error "hello"
    }
   
    %out = comb.add %a, %b: i8    
    hw.output %out : i8
}
```

sv.array_index_inout
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %arr = hw.array_create %a, %b : i8

    %reg = sv.reg : !hw.inout<!hw.array<2xi8>>
    sv.assign %reg, %arr : !hw.array<2xi8>

    %index_0 = hw.constant 0 : i8
    %index_1 = hw.constant 1 : i8

    %a1 = sv.array_index_inout %reg [%index_0]: !hw.inout<!hw.array<2xi8>>, i8
    %b1 = sv.array_index_inout %reg [%index_1]: !hw.inout<!hw.array<2xi8>>, i8

    %aa = sv.read_inout %a1 : !hw.inout<i8>
    %bb = sv.read_inout %b1 : !hw.inout<i8>

    %out = comb.add %aa, %bb : i8    
    hw.output %out : i8
}
```

sv.assert
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1 : i1
    
    sv.initial {
        sv.assert %cond, "immediate"
    }

    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.assert.concurrent
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1 : i1
    sv.assert.concurrent posedge %clk, %cond
    
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.assign
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %reg_a = sv.reg : !hw.inout<i8>
    %reg_b = sv.reg : !hw.inout<i8>
    
    sv.assign %reg_a, %a : i8
    sv.assign %reg_b, %b : i8
    
    %aa = sv.read_inout %reg_a : !hw.inout<i8>
    %bb = sv.read_inout %reg_b : !hw.inout<i8>
    
    %out = comb.add %aa, %bb: i8
    hw.output %out : i8
}
```

sv.assume
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1 : i1
    
    sv.initial {
        sv.assume %cond, "immediate"
    }

    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.assume.concurrent
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1 : i1
    sv.assume.concurrent posedge %clk, %cond
    
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.bind
sv.bind.interface
```
```

sv.bpassign
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %reg = sv.reg : !hw.inout<i8>
    sv.always {
        sv.bpassign %reg, %a : i8
    }
    %aa = sv.read_inout %reg : !hw.inout<i8>
    %out = comb.add %aa, %b: i8
    hw.output %out : i8
}
```

sv.case
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    sv.initial {
        sv.case %clk : i1
        case b0: {
            sv.error "zero"
        }
        case b1: {
            sv.error "one"
        }
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.constantStr
```
```

sv.constantX
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %x = sv.constantX : i8
    %out = comb.add %x, %b: i8
    hw.output %out : i8
}
```

sv.constantZ
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %z = sv.constantZ : i8
    %out = comb.add %z, %b: i8
    hw.output %out : i8
}
```

sv.cover
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1 : i1
    
    sv.initial {
        sv.cover %cond, "immediate"
    }

    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.cover.concurrent
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1 : i1
    sv.cover.concurrent posedge %clk, %cond
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.error
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1 : i1
    sv.initial {
        sv.error "error"
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.exit
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1 : i1
    sv.initial {
        sv.exit
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.fatal
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1 : i1
    sv.initial {
        sv.fatal 2
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.finish
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1 : i1
    sv.initial {
        sv.finish 2
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.for
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %0 = hw.constant 0 : i8
    %1 = hw.constant 1: i8

    %reg = sv.reg : !hw.inout<i8>
    sv.assign %reg, %a : i8

    sv.always {
        sv.for %i = %0 to %b step %1 : i8 {
            %t1 = sv.read_inout %reg : !hw.inout<i8>
            %t2 = comb.add %t1, %1: i8
            sv.passign %reg, %t2 : i8
        }
    }
    
    %out = sv.read_inout %reg : !hw.inout<i8>
    hw.output %out : i8
}
```

sv.force
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %reg_a = sv.reg : !hw.inout<i8>
    %reg_b = sv.reg : !hw.inout<i8>

    sv.initial {
        sv.force %reg_a, %b: i8
        sv.force %reg_b, %a: i8
        
        sv.release %reg_a: !hw.inout<i8>
        sv.release %reg_b: !hw.inout<i8>
    }

    %aa = sv.read_inout %reg_a: !hw.inout<i8>
    %bb = sv.read_inout %reg_b: !hw.inout<i8>

    %out = comb.add %aa, %bb: i8

    hw.output %out : i8
}
```

sv.fwrite
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %fd = hw.constant 1: i32
    sv.initial {
        sv.fwrite %fd, "format string"
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.generate
sv.generate.case
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    sv.generate "test" : {
        sv.generate.case "case_1" []
        sv.generate.case "case_2" []
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.if
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %cond = hw.constant 1: i1
    sv.always{
        sv.if %cond {
            sv.error "error"
        }
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.ifdef
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    sv.ifdef "MACRO" {
    } else {
        sv.always{
            sv.error "not defined"
        }
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.ifdef.procedural
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    sv.always {
        sv.ifdef.procedural "MACRO" {
        } else {
            sv.error "undefined"
        }
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.indexed_part_select
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %index = hw.constant 0 : i8
    %aa = sv.indexed_part_select %a[%index:8] : i8, i8
    %bb = sv.indexed_part_select %b[%index:8] : i8, i8
    
    %out = comb.add %aa, %bb: i8
    hw.output %out : i8
}
```

sv.indexed_part_select_inout
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %arr = hw.array_create %a, %b, %a, %b : i8
    %reg = sv.reg : !hw.inout<array<4xi8>>
    sv.assign %reg, %arr : !hw.array<4xi8>

    %index = hw.constant 0 : i8
    %part = sv.indexed_part_select_inout %reg[%index:2] : !hw.inout<array<4xi8>>, i8
    %ab = sv.read_inout %part : !hw.inout<array<2xi8>>

    %0 = hw.constant 0 : i1
    %1 = hw.constant 1 : i1
    %aa = hw.array_get %ab[%0] : !hw.array<2xi8>, i1
    %bb = hw.array_get %ab[%1] : !hw.array<2xi8>, i1
    
    %out = comb.add %aa, %bb: i8
    hw.output %out : i8
}
```

sv.info
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    sv.info "info"
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.initial
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    sv.initial {
        sv.info "initial"
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.interface
sv.interface.instance
sv.interface.modport
sv.interface.signal
sv.interface.signal.assign
sv.interface.signal.read

sv.localparam
```mlir
```

sv.logic
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %logic_a = sv.logic : !hw.inout<i8>
    %logic_b = sv.logic : !hw.inout<i8>
    sv.assign %logic_a, %a : i8
    sv.assign %logic_b, %b : i8

    %aa = sv.read_inout %logic_a : !hw.inout<i8>
    %bb = sv.read_inout %logic_b : !hw.inout<i8>
    
    %out = comb.add %aa, %bb: i8
    hw.output %out : i8
}
```

sv.macro.decl
```mlir
sv.macro.decl @MACRO ["1"]
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %macro = sv.macro.ref @MACRO() : () -> i1
    sv.always {
        sv.assert %macro, "immediate"
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.macro.def
sv.macro.ref
```mlir
sv.macro.decl @MACRO
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    sv.macro.def @MACRO "1"
    %macro = sv.macro.ref @MACRO() : () -> i1
    sv.always {
        sv.assert %macro, "immediate"
    }

    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.macro.ref.se
```mlir
sv.macro.decl @MACRO
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    sv.macro.def @MACRO "1"
    %macro = sv.macro.ref.se @MACRO(%a) : () -> i1
    sv.always {
        sv.assert %macro, "immediate"
    }

    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.modport.get
```mlir
```

sv.nonstandard.deposit
```mlir
```

sv.ordered
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %wire_a = sv.wire : !hw.inout<i8>
    %wire_b = sv.wire : !hw.inout<i8>
    sv.ordered {
        sv.assign %wire_a, %a : i8
        sv.assign %wire_b, %b : i8
    }
    %aa = sv.read_inout %wire_a : !hw.inout<i8>
    %bb = sv.read_inout %wire_b : !hw.inout<i8>
    %out = comb.add %aa, %bb : i8
    hw.output %out : i8
}
```

sv.passign
sv.read_inout
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %reg_a = sv.reg : !hw.inout<i8>
    %reg_b = sv.reg : !hw.inout<i8>
    sv.always {
        sv.passign %wire_a, %a : i8
        sv.passign %wire_b, %b : i8
    }
    %aa = sv.read_inout %wire_a : !hw.inout<i8>
    %bb = sv.read_inout %wire_b : !hw.inout<i8>
    %out = comb.add %aa, %bb : i8
    hw.output %out : i8
}
```

sv.readmem
sv.reg
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %file = sv.reg: !hw.inout<i8>
    sv.initial {
        sv.readmem %file, "input.txt", MemBaseBin : !hw.inout<i8>
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.release
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    %reg_a = sv.reg : !hw.inout<i8>
    %reg_b = sv.reg : !hw.inout<i8>

    sv.initial {
        sv.force %reg_a, %b: i8
        sv.force %reg_b, %a: i8
        
        sv.release %reg_a: !hw.inout<i8>
        sv.release %reg_b: !hw.inout<i8>
    }

    %aa = sv.read_inout %reg_a: !hw.inout<i8>
    %bb = sv.read_inout %reg_b: !hw.inout<i8>

    %out = comb.add %aa, %bb: i8
    hw.output %out : i8
}
```

sv.stop
```mlir
hw.module @Foo(in %clk: i1, in %a: i8, in %b: i8, out res: i8 ) {
    sv.always {
        sv.stop 2
    }
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.struct_field_inout
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %struct = hw.struct_create (%a, %b) : !hw.struct<a: i8, b: i8>

    %reg = sv.reg : !hw.inout<!hw.struct<a: i8, b: i8>>
    sv.assign %reg, %struct : !hw.struct<a: i8, b: i8>

    %a1 = sv.struct_field_inout %reg ["a"]: !hw.inout<!hw.struct<a: i8, b: i8>>
    %b1 = sv.struct_field_inout %reg ["b"]: !hw.inout<!hw.struct<a: i8, b: i8>>

    %aa = sv.read_inout %a1: !hw.inout<i8>
    %bb = sv.read_inout %b1: !hw.inout<i8>

    %out = comb.add %aa, %bb: i8    
    hw.output %out : i8
}
```

sv.system
sv.system.sampled
```mlir
```

sv.verbatim
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    sv.verbatim "verbatim"

    %out = comb.add %a, %b: i8    
    hw.output %out : i8
}
```

sv.verbatim.expr
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    sv.verbatim.expr "123" () : () -> i8
    %out = comb.add %a, %b: i8    
    hw.output %out : i8
}
```

sv.verbatim.expr.se
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    sv.verbatim.expr.se "123" () : () -> i8
    %out = comb.add %a, %b: i8    
    hw.output %out : i8
}
```

sv.warning
```mlir
hw.module @Adder(in %a: i8, in %b: i8, out result: i8 ) {
    sv.error "error"
    sv.info "info"
    sv.warning "warning"
    sv.verbatim "verbatim"

    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

sv.wire
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %wire_a = sv.wire : !hw.inout<i8>
    %wire_b = sv.wire : !hw.inout<i8>
    sv.assign %wire_a, %a : i8
    sv.assign %wire_b, %b : i8
    %aa = sv.read_inout %wire_a : !hw.inout<i8>
    %bb = sv.read_inout %wire_b : !hw.inout<i8>
    %out = comb.add %aa, %bb : i8
    hw.output %out : i8
}
```


sv.xmr
```mlir
#loc = loc("foo.mlir":1:32)
#loc1 = loc("foo.mlir":7:43)
#loc2 = loc("foo.mlir":7:57)
#loc3 = loc("foo.mlir":12:42)
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
    }) {
        module_type = !hw.modty<input a : i8, input b : i8, output result : i8>,
        parameters = [],
        result_locs = [#loc3],
        sym_name = "Foo"
    } : () -> ()
}) : () -> ()
```

sv.xmr.ref
```mlir
#loc = loc("foo.mlir":1:33)
#loc1 = loc("foo.mlir":8:45)
#loc2 = loc("foo.mlir":8:59)
#loc3 = loc("foo.mlir":16:42)
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
  
    "hw.hierpath"() {
        namepath = [#hw.innerNameRef<@Foo::@sym_swap1>, #hw.innerNameRef<@Swap::@sym_wrap>, #hw.innerNameRef<@Wrap::@sym_x>], 
        sym_name = "ref1"
    } : () -> ()
    "hw.hierpath"() {
        namepath = [#hw.innerNameRef<@Foo::@sym_swap2>, #hw.innerNameRef<@Swap::@sym_wrap>, #hw.innerNameRef<@Wrap::@sym_y>],
        sym_name = "ref2"
    } : () -> ()
  
    "hw.module"() ({
    ^bb0(%arg0: i8, %arg1: i8):
        %0:2 = "hw.instance"(%arg0, %arg1) {argNames = ["xx", "yy"], inner_sym = #hw<innerSym@sym_swap1>, instanceName = "swap1", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
        %1:2 = "hw.instance"(%arg0, %arg1) {argNames = ["xx", "yy"], inner_sym = #hw<innerSym@sym_swap2>, instanceName = "swap2", moduleName = @Swap, parameters = [], resultNames = ["res1", "res2"]} : (i8, i8) -> (i8, i8)
        %2 = "sv.xmr.ref"() {ref = @ref1, verbatimSuffix = ""} : () -> !hw.inout<i8>
        %3 = "sv.read_inout"(%2) : (!hw.inout<i8>) -> i8
        %4 = "comb.add"(%1#0, %3) : (i8, i8) -> i8
        "hw.output"(%4) : (i8) -> ()
    }) {
        module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, 
        parameters = [], 
        result_locs = [#loc3], 
        sym_name = "Foo"
    } : () -> ()
}) : () -> ()
```