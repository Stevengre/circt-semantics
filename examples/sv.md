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
sv.macro.decl @MACRO ["1"]
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    sv.ifdef @MACRO {
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
sv.macro.decl @MACRO ["1"]
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    sv.always {
        sv.ifdef.procedural @MACRO {
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
    sv.initial {
        sv.info "info"
    }
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
```mlir

```

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
    %macro = sv.macro.ref.se @MACRO() : () -> i1
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
        sv.passign %reg_a, %a : i8
        sv.passign %reg_b, %b : i8
    }
    %aa = sv.read_inout %reg_a : !hw.inout<i8>
    %bb = sv.read_inout %reg_b : !hw.inout<i8>
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
    sv.initial {
        sv.error "error"
        sv.info "info"
        sv.warning "warning"
        sv.verbatim "verbatim"
    }

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
hw.module @Wrap(in %x: i8, out res: i8) {
    %y = sv.reg {sv.attributes=[#sv.attribute<"dont_merge">]} : !hw.inout<i8>
    %z = sv.wire {sv.attributes=[#sv.attribute<"dont_merge">]} : !hw.inout<i8>
    hw.output %x: i8
}

hw.module @Swap(in %x: i8, in %y: i8, out res1: i8, out res2: i8) {
    %a = hw.instance "wrap" @Wrap(x: %x: i8) -> (res:i8)
    hw.output %y, %a : i8, i8
}

hw.module @Foo(in %a: i8, in %b: i8, out result: i8 ) {
    %0, %1 = hw.instance "swap1" @Swap(x: %a: i8, y: %b: i8) -> (res1:i8, res2:i8)
    %2, %3 = hw.instance "swap2" @Swap(x: %a: i8, y: %b: i8) -> (res1:i8, res2:i8)

    %xmr1 = sv.xmr isRooted swap1,wrap,y : !hw.inout<i8>
    %t = sv.read_inout %xmr1 : !hw.inout<i8>

    %out = comb.add %3, %t: i8
    
    hw.output %out : i8
}
```

sv.xmr.ref
```mlir
hw.module @Wrap(in %xx: i8, out res: i8) {
    %y = sv.reg sym @sym_x {sv.attributes=[#sv.attribute<"dont_merge">]} : !hw.inout<i8>
    %z = sv.wire sym @sym_y {sv.attributes=[#sv.attribute<"dont_merge">]} : !hw.inout<i8>
    sv.assign %y, %xx : i8
    hw.output %xx: i8
}

hw.module @Swap(in %xx: i8, in %yy: i8, out res1: i8, out res2: i8) {
    %a = hw.instance "wrap" sym @sym_wrap @Wrap(xx: %xx: i8) -> (res:i8)
    hw.output %yy, %a : i8, i8
}

hw.hierpath @ref1 [@Foo::@sym_swap1, @Swap::@sym_wrap, @Wrap::@sym_x]
hw.hierpath @ref2 [@Foo::@sym_swap2, @Swap::@sym_wrap, @Wrap::@sym_y]

hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %0, %1 = hw.instance "swap1" sym @sym_swap1 @Swap(xx: %a: i8, yy: %b: i8) -> (res1:i8, res2:i8)
    %2, %3 = hw.instance "swap2" sym @sym_swap2 @Swap(xx: %a: i8, yy: %b: i8) -> (res1:i8, res2:i8)

    %xmr1 = sv.xmr.ref @ref1 : !hw.inout<i8>
    %xmr2 = sv.xmr.ref @ref2 ".x.y.z[42]" : !hw.inout<i8>
    
    %t = sv.read_inout %xmr1 : !hw.inout<i8>

    %out = comb.add %2, %t: i8
    
    hw.output %out : i8
}
```