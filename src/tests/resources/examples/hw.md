hw.module
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = comb.add %a, %b : i8
    hw.output %out : i8
}
```

hw.hierpath
```mlir
hw.module @Bar(in %a: i8, in %b: i8, out res: i8) {
    %reg = sv.reg sym @sym_reg {sv.attributes=[#sv.attribute<"dont_merge">]} : !hw.inout<i8>
    %out = comb.add %a, %b : i8
    hw.output %out : i8
}
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = hw.instance "bar" sym @sym_bar @Bar(a: %a: i8, b: %b: i8) -> (res:i8)
    hw.output %out : i8
}
hw.hierpath @ref [@Foo::@sym_bar, @Bar::@sym_reg]
hw.module @Top(){
    %xmr1 = sv.xmr.ref @ref : !hw.inout<i8>
}
```

hw.instance
```mlir
hw.module @Bar(in %a: i8, in %b: i8, out res: i8) {
    %out = comb.add %a, %b : i8
    hw.output %out : i8
}
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = hw.instance "bar" sym @sym_bar @Bar(a: %a: i8, b: %b: i8) -> (res:i8)
    hw.output %out : i8
}
```

hw.output
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = comb.add %a, %b : i8
    hw.output %out : i8
}
```

hw.triggered

hw.bitcast
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i16) {
    %x = hw.struct_create (%a, %b) : !hw.struct<a: i8, b: i8>
    %out =  hw.bitcast %x : (!hw.struct<a: i8, b: i8>) -> (i16)
    hw.output %out : i16
}
```

hw.constant
```mlir
hw.module @Foo(out res: i8) {
    %result = hw.constant 42 : i8
    hw.output %out : i8
}
```

hw.enum.constant
hw.enum.cmp
```mlir
hw.module @Foo(out res: i1) {
    %a = hw.enum.constant A : !hw.enum<A, B, C>
    %b = hw.enum.constant A : !hw.enum<A, B, C>
    %out = hw.enum.cmp %a, %b : !hw.enum<A, B, C>, !hw.enum<A, B, C>
    hw.output %out : i1
}
```

hw.param.value
```mlir
```


hw.wire
```mlir
hw.module @Foo(out res: i8) {
    %0 = hw.constant 0: i8
    %out = hw.wire %0 sym @mySym name "myWire" : i8
    hw.output %out : i8
}
```

hw.aggregate_constant
```mlir
hw.module @Foo(out res: !hw.struct<a: i2, b: i2, c: i2>) {
    %a = hw.aggregate.constant [1 : i1, 2 : i2, 3 : i2] : !hw.struct<a: i2, b: i2, c: i2>
    hw.output %a : !hw.struct<a: i2, b: i2, c: i2>
}
```

hw.array_create
hw.array_get
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %arr = hw.array_create %a, %b: i8

    %0 = hw.constant 0: i1
    %1 = hw.constant 1: i1
    
    %aa = hw.array_get %arr [%0] : !hw.array<2xi8>, i1
    %bb = hw.array_get %arr [%1] : !hw.array<2xi8>, i1

    %res = comb.add %aa, %bb : i8
    hw.output %res : i8
}
```

hw.array_concat
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %arr1 = hw.array_create %a: i8
    %arr2 = hw.array_create %b: i8

    %arr = hw.array_concat %arr1, %arr2 : !hw.array<1xi8>, !hw.array<1xi8>

    %0 = hw.constant 0: i1
    %1 = hw.constant 1: i1

    %aa = hw.array_get %arr [%0] : !hw.array<2xi8>, i1
    %bb = hw.array_get %arr [%1] : !hw.array<2xi8>, i1

    %res = comb.add %aa, %bb : i8
    hw.output %res : i8
}
```

hw.array_slice
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %arr0 = hw.array_create %a, %b, %a, %b : i8
    %index = hw.constant 2 : i2
    %arr = hw.array_slice %arr0 [%index] : (!hw.array<4xi8>) -> !hw.array<2xi8>

    %0 = hw.constant 0: i1
    %1 = hw.constant 1: i1

    %aa = hw.array_get %arr [%0] : !hw.array<2xi8>, i1
    %bb = hw.array_get %arr [%1] : !hw.array<2xi8>, i1

    %res = comb.add %aa, %bb : i8
    hw.output %res : i8
}
```

hw.struct_create
hw.struct_extract
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %struct = hw.struct_create (%a, %b) : !hw.struct<a: i8, b: i8>

    %aa = hw.struct_extract %struct ["a"] : !hw.struct<a: i8, b: i8>
    %bb = hw.struct_extract %struct ["b"] : !hw.struct<a: i8, b: i8>

    %res = comb.add %aa, %bb : i8
    hw.output %res : i8
}
```

hw.struct_explode
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %struct = hw.struct_create (%a, %b) : !hw.struct<a: i8, b: i8>
    %aa, %bb = hw.struct_explode %struct : !hw.struct<a: i8, b: i8>
    %res = comb.add %aa, %bb : i8
    hw.output %res : i8
}
```

hw.struct_inject
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %struct0 = hw.struct_create (%b, %a) : !hw.struct<a: i8, b: i8>
    %struct1 = hw.struct_inject %struct0["a"], %a : !hw.struct<a: i8, b: i8>
    %struct2 = hw.struct_inject %struct1["b"], %b : !hw.struct<a: i8, b: i8>

    %aa, %bb = hw.struct_explode %struct2 : !hw.struct<a: i8, b: i8>
    %res = comb.add %aa, %bb : i8
    hw.output %res : i8
}
```

hw.union_create
hw.union_extract
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %union_a = hw.union_create "foo", %a : !hw.union<foo: i8, bar: i8>
    %aa = hw.union_extract %union_a["foo"] : !hw.union<foo: i8, bar: i8>

    %union_b = hw.union_create "bar", %b : !hw.union<foo: i8, bar: i8>
    %bb = hw.union_extract %union_b["bar"] : !hw.union<foo: i8, bar: i8>

    %res = comb.add %aa, %bb : i8
    hw.output %res : i8
}
```

hw.type_scope
hw.typedecl