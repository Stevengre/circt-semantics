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
module HW
  imports HW-SYNTAX
  imports MLIR-CONFIG
  imports CIRCT-CONFIG
  imports HARDWARE-CONFIG
  imports HW-CONFIG
  imports MLIR-HELPER
  imports MAP
  imports HW-HELPER
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
<hw-setup-inst> Insts:List ListItem(_) => Insts </hw-setup-inst>
```

### Auto Connect

```k
rule
<setup> 
   ListItem(S:String) = Op (Args) {Attr:Map} : FT
=> "HARDWARE#CONNECT" 
~> Abs(AbsSymbolName(L), ListItem(S)) 
~> ListItem(Op (Abs(AbsSymbolName(L), Args)) {Attr:Map} : FT)
... 
</setup>
<hw-setup-inst> L </hw-setup-inst>
[priority(170)]
```

### Auto Procedure

```k
rule <setup> Op:StdOp => "HARDWARE#PROCEDURE" ~> AbsOp(AbsSymbolName(L), Op) ... </setup>
<hw-setup-inst> L </hw-setup-inst>
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
=> "HARDWARE#CONNECT" ~> Abs(AbsSymbolName(L), VTs) ~> INS
~> Ops
...
</setup>
<hw-setup-inst> L </hw-setup-inst>
(
    .Bag
=>  <hw-instance>
        <hw-id> AbsSymbolName(L) </hw-id>
        <hw-module> AbsSymbolName(ListItem(Attr["sym_name"])) </hw-module>
        <hw-inputs> getModuleInNames({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-inputs>
        <hw-inports> Abs(AbsSymbolName(L), VTs) </hw-inports>
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
~> "HARDWARE#CONNECT" ~> Abs(AbsSymbolName(L), Outs) ~> "HARDWARE#INS"
...
</setup>
<hw-setup-inst> L </hw-setup-inst>

rule 
<setup> 
   "hw.instance" (Args) {Attr:Map} : (_) -> (_) 
=> "CIRCT#GET_OP" ~> Attr["moduleName"]
~> "HARDWARE#CONNECT" ~> "HARDWARE#OUTS" ~> Abs(AbsSymbolName(L), Args)
~> "HW#NEW_INSTANCE"
... 
</setup>
<hw-setup-inst> L => L ListItem(Attr["instanceName"]) </hw-setup-inst>
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
<hw-setup-inst> L:List </hw-setup-inst>
<hw-instance>
  <hw-id> ABS_NAME </hw-id>
  <hw-outports> .List => Abs(ABS_NAME, Args) </hw-outports>
  ...
</hw-instance>
requires ABS_NAME ==K AbsSymbolName(L) andBool size(L) >Int 1

rule
<setup>
   "hw.output" (Args) {_:Map} : _
~> .StdOps 
~> "HW#NEW_INSTANCE" 
=> .K ~> "HW#NEW_INSTANCE"
...
</setup>
<hw-setup-inst> ListItem(S) </hw-setup-inst>
<hw-instance>
  <hw-id> ABS_NAME </hw-id>
  <hw-outports> .List => Abs(ABS_NAME, Args) </hw-outports>
  ...
</hw-instance>
requires ABS_NAME ==K AbsSymbolName(ListItem(S))
```

## hw.aggregate_constant

```k
rule
<current> 
   "hw.aggregate_constant" ( .List ) { "fields" |-> [AVL:AttributeValueList] _:Map} : _FT
=> ListItem(BitsConcat(AttrValueList2List(AVL)))
... 
</current>
```

## hw.constant

```k
rule
<current>
   "hw.constant" ( .List ) { "value" |-> V : T _:Map } : ( .Types ) -> ( T:Type )
=> ListItem(ToBits(V, T))
...
</current>

rule
<current>
   "hw.constant" ( .List ) { "value" |-> V:AttributeValue _:Map } : ( .Types ) -> ( T:Type )
=> ListItem(ToBits(V, T))
...
</current>
[owise]
```

## HW Operations for Array

### `hw.array_get`

```k
rule
<current> "hw.array_get" ( ListItem(Array:Bits) ListItem(bits(Idx:Int, _:Int)) ) {_:Map} : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( T:Type ) => ListItem(BitsSlice(Array, Idx *Int getWidth(T), (Idx +Int 1) *Int getWidth(T))) ... </current>

rule
<current> "hw.array_get" ( ListItem(_:Bits) ListItem(bits(_:XZValue, _:Int)) ) {_:Map} : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( T:Type ) => ListItem(bits(#x, getWidth(T))) ... </current>
```

### `hw.array_create`

```k
rule
<current> "hw.array_create" ( ListItem(B:Bits) L:List ) {_:Map} : _FT => ListItem(BitsConcat(ListItem(B) L)) ... </current>
```

### `hw.array_slice`

```k
rule
<current> "hw.array_slice" ( ListItem(Arr:Bits) ListItem(bits(Idx:Int, _:Int)) ) {_:Map} : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( !hw.array < S:SizeX T > ) => ListItem(BitsSlice(Arr, Idx *Int getWidth(T), (Idx +Int SizeX2Int(S)) *Int getWidth(T))) ... </current>

rule
<current> "hw.array_slice" ( ListItem(_:Bits) ListItem(bits(_:XZValue, _:Int)) ) {_:Map} : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( !hw.array < S:SizeX T > ) => ListItem(bits(#x, SizeX2Int(S) *Int getWidth(T))) ... </current>
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
