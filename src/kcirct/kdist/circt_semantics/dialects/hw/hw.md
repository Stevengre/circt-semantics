# HW Dialect

```k
requires "hw-syntax.md"
requires "../../mlir/mlir-config.md"
requires "../../mlir/mlir-helper.md"
requires "../../circt/circt-config.md"
requires "../../circt/circt.md"
requires "../../hardware/hardware-config.md"
requires "../../hardware/bits.md"
requires "../../mlir/builtin.md"
requires "hw-config.md"
requires "hw-helper.md"
requires "hw-layout.md"
module HW
  imports HW-SYNTAX
  imports MLIR-CONFIG
  imports CIRCT-CONFIG
  imports HARDWARE-CONFIG
  imports HW-CONFIG
  imports MLIR-HELPER
  imports MAP
  imports HW-HELPER
  imports HW-LAYOUT
  imports BOOL
  imports CIRCT
  imports BITS
  imports BUILTIN
```

## Helper Rules

### `HW#NEW_INSTANCE`

```k

rule 
<setup> .K ~> "HW#NEW_INSTANCE" => .K ... </setup>
<hw-setup-inst> Paths:List ListItem(_) => Paths </hw-setup-inst>
```

### Auto Connect

```k
rule
<setup> 
   ListItem(S:String) = Op (Args) {Attr:Map} : FT
=> "HARDWARE#CONNECT" 
~> Abs(P, ListItem(S))
~> ListItem(Op (Abs(P, Args)) {Attr:Map} : FT)
... 
</setup>
<hw-setup-inst> _:List ListItem(P:String) </hw-setup-inst>
[priority(170)]
```

### Auto Procedure

```k
rule <setup> Op:StdOp => "HARDWARE#PROCEDURE" ~> AbsOp(P, Op) ... </setup>
<hw-setup-inst> _:List ListItem(P:String) </hw-setup-inst>
[priority(160)]
```

### GET_INS_OUTS

```k

```

## hw.module

Top Module
```k
rule 
<setup> "hw.module" (.List) {Attr:Map} _ ({_ (VTs) : Ops:StdOps .StdBlocks}:StdRegion) : (.Types) -> (.Types) => Ops ~> "HW#NEW_INSTANCE" ... </setup>
<hw-setup-inst> .List => ListItem(Attr["sym_name"]) </hw-setup-inst>
<top-ins> .List => Abs(AbsSymbolName(ListItem(Attr["sym_name"])), VTs) </top-ins>
(
    .Bag
=>  <hw-instance>
        <hw-id> AbsSymbolName(ListItem(Attr["sym_name"])) </hw-id>
        <hw-module> AbsSymbolName(ListItem(Attr["sym_name"])) </hw-module>
        <hw-inputs> getModuleInNames({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-inputs>
        <hw-inports> Abs(AbsSymbolName(ListItem(Attr["sym_name"])), VTs) </hw-inports>
        <hw-in-types> getModuleInTypes({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-in-types>
        <hw-outputs> getModuleOutNames({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-outputs>
        <hw-out-types> getModuleOutTypes({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-out-types>
        ...
    </hw-instance>
)
```

```k
rule 
<setup>
   "hw.module" (.List) {Attr:Map} _ ({_ (VTs) : Ops:StdOps .StdBlocks}:StdRegion) : (.Types) -> (.Types)
~> "HARDWARE#CONNECT" ~> "HARDWARE#OUTS" ~> INS:List
=> "HARDWARE#CONNECT" ~> Abs(P, VTs) ~> INS
~> Ops
...
</setup>
<hw-setup-inst> _:List ListItem(P:String) </hw-setup-inst>
(
    .Bag
=>  <hw-instance>
        <hw-id> P </hw-id>
        <hw-module> AbsSymbolName(ListItem(Attr["sym_name"])) </hw-module>
        <hw-inputs> getModuleInNames({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-inputs>
        <hw-inports> Abs(P, VTs) </hw-inports>
        <hw-in-types> getModuleInTypes({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-in-types>
        <hw-outputs> getModuleOutNames({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-outputs>
        <hw-out-types> getModuleOutTypes({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-out-types>
        ...
    </hw-instance>
)
```

## hw.instance

```k
rule 
<setup> 
    Outs = "hw.instance" (Args) {Attr:Map} : (T1) -> (T2) 
=> "hw.instance" (Args) {Attr} : (T1) -> (T2)
~> "HARDWARE#CONNECT" ~> Abs(P, Outs) ~> "HARDWARE#INS"
...
</setup>
<hw-setup-inst> _:List ListItem(P:String) </hw-setup-inst>

rule 
<setup> 
   "hw.instance" (Args) {Attr:Map} : (_) -> (_) 
=> "CIRCT#GET_OP" ~> Attr["moduleName"]
~> "HARDWARE#CONNECT" ~> "HARDWARE#OUTS" ~> Abs(P, Args)
~> "HW#NEW_INSTANCE"
... 
</setup>
<hw-setup-inst>
  Paths:List ListItem(P:String)
  => Paths ListItem(P) ListItem(AbsSymbolName(ListItem(P) ListItem(Attr["instanceName"])))
</hw-setup-inst>
```

## hw.output

```k
rule
<setup>
   "hw.output" (Args) {_:Map} : _
~> .StdOps 
~> "HW#NEW_INSTANCE" 
~> "HARDWARE#CONNECT" ~> OUTS:List ~> "HARDWARE#INS"
=> .K ~> "HW#NEW_INSTANCE"
~> "HARDWARE#CONNECT" ~> OUTS ~> Abs(ABS_NAME, Args)
...
</setup>
<hw-setup-inst> _:List ListItem(P:String) </hw-setup-inst>
<hw-instance>
  <hw-id> ABS_NAME </hw-id>
  <hw-outports> .List => Abs(ABS_NAME, Args) </hw-outports>
  ...
</hw-instance>
requires ABS_NAME ==K P
[priority(45)]

rule
<setup>
   "hw.output" (Args) {_:Map} : _
~> .StdOps 
~> "HW#NEW_INSTANCE" 
=> .K ~> "HW#NEW_INSTANCE"
...
</setup>
<hw-setup-inst> _:List ListItem(P:String) </hw-setup-inst>
<hw-instance>
  <hw-id> ABS_NAME </hw-id>
  <hw-outports> .List => Abs(ABS_NAME, Args) </hw-outports>
  ...
</hw-instance>
requires ABS_NAME ==K P
```

## hw.aggregate_constant

```k
rule
<current> 
   "hw.aggregate_constant" ( .List ) { "fields" |-> [AVL:AttributeValueList] _:Map} : ( .Types ) -> ( !hw.array < _:SizeX T:Type > , _:Types ) 
=> ListItem(BitsConcat(AttrValueList2List(AVL,T)))
... 
</current>
```

## hw.constant

```k
rule
<current>
   "hw.constant" ( .List ) { "value" |-> V:AttributeValue _:Map } : ( .Types ) -> ( T:Type )
=> ListItem(ToBits(V, T))
...
</current>
```

## HW Operations for Array

### `hw.array_inject`

数组元素 0 位于最低位。注入返回新的打包值，不修改作为输入的数组或寄存器；
寄存器的状态更新仍由 seq.firreg 处理。当前只执行二态、索引有效的一维整数数组。
索引宽度和元素类型必须匹配。索引按自身位宽解释为无符号数，随后检查数组边界；
不对数组长度取模，也不为越界返回伪造的正常值。

```k
rule
<current> "hw.array_inject" ( ListItem(bits(A:Int, AW:Int)) ListItem(bits(Idx:Int, IW:Int)) ListItem(bits(V:Int, EW:Int)) ) {_:Map}
  : (!hw.array < N:SizeX T:IntegerType >, IT:SignlessIntegerType, T) -> (!hw.array < N T >)
  => ListItem(BitsReplace(bits(A, AW), (Idx &Int (2 ^Int IW -Int 1)) *Int EW, bits(V, EW)))
... </current>
requires AW ==Int packedWidth(!hw.array < N T >) andBool EW ==Int getWidth(T)
  andBool IW ==Int getWidth(IT) andBool validArrayIndexWidth(N, IW)
  andBool (Idx &Int (2 ^Int IW -Int 1)) <Int SizeX2Int(N)
```

### `hw.array_get`

```k
rule
<current> "hw.array_get" ( ListItem(Array:Bits) ListItem(bits(Idx:Int, _:Int)) ) {_:Map} : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( T:Type ) 
=> ListItem(BitsSlice(Array, Idx *Int getWidth(T), (Idx +Int 1) *Int getWidth(T))) ... </current>
requires Idx >=Int 0

rule
<current> "hw.array_get" ( ListItem(Array:Bits) ListItem(bits(Idx:Int, W:Int)) ) {_:Map} : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( T:Type ) 
=> ListItem(BitsSlice(Array, (Idx +Int (2 ^Int W)) *Int getWidth(T), (Idx +Int 1 +Int (2 ^Int W)) *Int getWidth(T))) ... </current>
requires Idx <Int 0

rule
<current> "hw.array_get" ( ListItem(_:Bits) ListItem(bits(_:XZValue, _:Int)) ) {_:Map} : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( T:Type ) 
=> ListItem(bits(#x, getWidth(T))) ... </current>
```

### `hw.array_create`

```k
rule
<current> "hw.array_create" ( ListItem(B:Bits) L:List ) {_:Map} : _FT => ListItem(BitsConcat(ListItem(B) L)) ... </current>
```

### `hw.array_slice`

```k
rule
<current> "hw.array_slice" ( ListItem(Arr:Bits) ListItem(bits(Idx:Int, _:Int)) ) {_:Map} : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( !hw.array < S:SizeX T > ) 
=> ListItem(BitsSlice(Arr, Idx *Int getWidth(T), (Idx +Int SizeX2Int(S)) *Int getWidth(T))) ... </current>
requires Idx >=Int 0

rule
<current> "hw.array_slice" ( ListItem(Arr:Bits) ListItem(bits(Idx:Int, W:Int)) ) {_:Map} : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( !hw.array < S:SizeX T > ) 
=> ListItem(BitsSlice(Arr, (Idx +Int (2 ^Int W)) *Int getWidth(T), ((Idx +Int (2 ^Int W)) +Int SizeX2Int(S)) *Int getWidth(T))) ... </current>
requires Idx <Int 0

rule
<current> "hw.array_slice" ( ListItem(_:Bits) ListItem(bits(_:XZValue, _:Int)) ) {_:Map} : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( !hw.array < S:SizeX T > ) 
=> ListItem(bits(#x, SizeX2Int(S) *Int getWidth(T))) ... </current>
```

### `hw.array_concat`

```k
rule
<current> "hw.array_concat" ( ListItem(Arr:Bits) L:List ) {_:Map} : _FT => ListItem(BitsConcat(ListItem(Arr) L)) ... </current>
```

## HW Operations for Enum

### `hw.enum.cmp`

```k
rule
<current> "hw.enum.cmp" ( ListItem(bits(X1:Int, _:Int)) ListItem(bits(X2:Int, _:Int)) ) {_:Map} : _FT => ListItem(bits(#if X1 ==Int X2 #then 1 #else 0 #fi, 1)) ... </current>
```

### `hw.enum.constant`

```k
rule
<current> "hw.enum.constant" ( .List ) { "field" |-> X:HwEnumField _:Map } : _ => HwEnum2Bits(X) ... </current>

syntax Bits ::= HwEnum2Bits(HwEnumField) [function]
rule HwEnum2Bits(#hw.enum.field < X:HwEnumItem, T:HwEnumType >) => bits(getEnumIndex(X, T), log2Int(getEnumSize(T) -Int 1) +Int 1)

syntax Int ::= getEnumIndex(HwEnumItem, HwEnumType) [function]
rule getEnumIndex(X:HwEnumItem, !hw.enum < X:HwEnumItem, _:HwEnumItems >) => 0
rule getEnumIndex(X:HwEnumItem, !hw.enum < Y:HwEnumItem, Ys:HwEnumItems >) => 1 +Int getEnumIndex(X, !hw.enum < Ys >) requires X =/=K Y

syntax Int ::= getEnumSize(HwEnumType) [function]
rule getEnumSize(!hw.enum < _:HwEnumItem, Xs:HwEnumItems >) => 1 +Int getEnumSize(!hw.enum < Xs >)
rule getEnumSize(!hw.enum < .HwEnumItems >) => 0
```

## HW Operations for Struct

```k
syntax Int ::= getStructFeildIndex(HwStructType, Int) [function]
rule getStructFeildIndex(!hw.struct< _:BareId : T:Type, BTS:BareIdAndTypeList >, Idx:Int) 
  => getStructFeildIndex(!hw.struct< BTS >, Idx -Int 1) +Int getWidth(T)
  requires Idx >Int 0
rule getStructFeildIndex(!hw.struct< _ >, 0) => 0
```

### `hw.struct_extract`

```k
rule
<current> "hw.struct_extract" ( ListItem(Struct:Bits) ) { "fieldIndex" |-> Idx:Int _:Map } : ( ST:HwStructType ) -> ( T:Type ) => ListItem(BitsSlice(Struct, getStructFeildIndex(ST, Idx), getStructFeildIndex(ST, Idx) +Int getWidth(T))) ... </current>
```

### `hw.struct_create`

```k
rule
<current> "hw.struct_create" ( ListItem(B:Bits) L:List ) {_:Map} : _FT => ListItem(BitsConcat(ListItem(B) L)) ... </current>
```

### `hw.struct_explode`

```k
rule
<current> "hw.struct_explode" ( ListItem(Struct:Bits) ) {_:Map} : ( _:HwStructType ) -> ( Ts:Types ) => HwStructExplode(Struct, Ts) ... </current>

syntax List ::= HwStructExplode(Bits, Types) [function]
rule HwStructExplode(bits(V, W), T:Type, Ts:Types) => ListItem(BitsSlice(bits(V, W), 0, getWidth(T))) HwStructExplode(BitsSlice(bits(V, W), getWidth(T), W), Ts)
rule HwStructExplode(_:Bits, .Types) => .List
```

### `hw.struct_inject`

```k
rule
<current> "hw.struct_inject" ( ListItem(bits(V, W)) ListItem(B:Bits) ) { "fieldIndex" |-> Idx:Int _:Map } : ( ST:HwStructType , T:Type ) -> ( _:HwStructType ) => BitsConcat(ListItem(BitsSlice(bits(V, W), 0, getStructFeildIndex(ST, Idx))) ListItem(B) ListItem(BitsSlice(bits(V, W), getStructFeildIndex(ST, Idx) +Int getWidth(T), W))) ... </current>
```

## HW Operations for Union

### `hw.union_extract`

```k
rule
<current> "hw.union_extract" ( ListItem(B:Bits) ) { "fieldIndex" |-> _Idx:Int _:Map } : _FT => ListItem(B) ... </current>
```

### `hw.union_create`

```k
rule
<current> "hw.union_create" ( ListItem(B:Bits) ) { "fieldIndex" |-> _Idx:Int _:Map } : _FT => ListItem(B) ... </current>
```

```k
endmodule
```
