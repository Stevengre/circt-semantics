
comb.add
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %out = comb.add %a, %b: i8
    hw.output %out : i8
}
```

comb.and
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %out = comb.and %a, %b: i8
    hw.output %out : i8
}
```

comb.concat
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i16 ) {
    %out = comb.concat %a, %b: i8, i8
    hw.output %out : i16
}
```

comb.divs
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %out = comb.divs %a, %b: i8
    hw.output %out : i8
}
```

comb.divu
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8 ) {
    %out = comb.divu %a, %b: i8
    hw.output %out : i8
}
```

comb.extract
```mlir
hw.module @Foo(in %a: i8, out res: i4 ) {
    %out = comb.extract %a from 0 : (i8) -> i4
    hw.output %out : i4
}
```

comb.icmp
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i1) {
    %out = comb.icmp bin eq %a, %b : i8
    hw.output %out : i1
}
```

comb.mods
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = comb.mods %a, %b : i8
    hw.output %out : i8
}
```

comb.modu
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = comb.modu %a, %b : i8
    hw.output %out : i8
}
```

comb.mul
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = comb.mul %a, %b : i8
    hw.output %out : i8
}
```

comb.or
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = comb.or %a, %b : i8
    hw.output %out : i8
}
```

comb.parity
```mlir
hw.module @Foo(in %a: i8, out res: i1) {
    %out = comb.parity %a : i8
    hw.output %out : i1
}
```

comb.replicate
```mlir
hw.module @Foo(in %a: i8, out res: i16) {
    %out = comb.replicate %a : (i8) -> i16
    hw.output %out : i16
}
```

comb.shrs
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = comb.shrs %a, %b : i8
    hw.output %out : i8
}
```

comb.shru
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = comb.shru %a, %b : i8
    hw.output %out : i8
}
```

comb.sub
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = comb.sub %a, %b : i8
    hw.output %out : i8
}
```

comb.truth_table (unsettled)
```mlir
hw.module @Foo(in %a: i1, in %b: i1, out res: i1) {
    %0 = comb.truth_table %a, %b -> [false, true, true, false]
    hw.output %0: i1
}
```

comb.xor
```mlir
hw.module @Foo(in %a: i8, in %b: i8, out res: i8) {
    %out = comb.xor %a, %b : i8
    hw.output %out : i8
}
```