unknown:

- hw.uarray
- 带尖括号的attribute dict
- module type, hw.modty

```mlir
%3 = "sv.reg"() {name = "selReg", sv.attributes = [#sv.attribute<"dont_merge">, #sv.attribute<"dont_retime" = "true">]} : () -> !hw.inout<i10>
```

```mlir
!hw.inout<struct<foo: i23>>
!hw.inout<uarray<8xi32>>
```