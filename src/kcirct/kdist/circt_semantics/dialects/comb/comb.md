# COMB Dialect

```k
requires "comb-syntax.md"
requires "../../hardware/bits.md"
requires "../../hardware/hardware-config.md"
requires "../../mlir/mlir-helper.md"
requires "../../mlir/builtin.md"
module COMB
imports COMB-SYNTAX
imports BITS
imports HARDWARE-CONFIG
imports MLIR-HELPER
imports BUILTIN
```

## comb.add


```k
rule
<current> "comb.add" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsAdd(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.and

```k
rule
<current> "comb.and" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsAnd(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.or

```k
rule
<current> "comb.or" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsOr(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.xor

```k
rule
<current> "comb.xor" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsXor(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.mul

```k
rule
<current> "comb.mul" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsMul(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.extract

```k
rule
<current> "comb.extract" ( ListItem(bits(B1:Int, _W1:Int)) ) {"lowBit" |-> Lowbit:Int : _:IntegerType _:Map} : (_:Types) -> (T:IntegerType) => ListItem(BitsCast(bits(B1 >>Int Lowbit, getWidth(T)))) ... </current>
```

## comb.replicate

```k
rule
<current> "comb.replicate" ( ListItem(bits(B:Int, _W:Int)) ) {_:Map} : (T1:IntegerType) -> (T2:IntegerType) => ListItem(BitsCast(BitsDup(bits(B, getWidth(T1)), getWidth(T2) divInt getWidth(T1)), getWidth(T2))) ... </current>
```

## comb.shrs

```k
rule
<current> "comb.shrs" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsShrs(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.shru

```k
rule
<current> "comb.shru" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsShru(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.shl

```k
rule
<current> "comb.shl" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsShl(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.sub

```k
rule
<current> "comb.sub" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsSub(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.concat

```k
rule
<current> "comb.concat" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsConcat(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.divs

```k
rule
<current> "comb.divs" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsDivs(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.divu

```k
rule
<current> "comb.divu" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsDivu(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.mods

```k
rule
<current> "comb.mods" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsMods(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.modu

```k
rule
<current> "comb.modu" ( ListItem(B:Bits) L:List ) {_:Map} : (_) -> (T:IntegerType) => ListItem(BitsCast(BitsModu(ListItem(B) L), getWidth(T))) ... </current>
```

## comb.parity

```k
rule
<current> "comb.parity" ( ListItem(B:Bits) ) {_:Map} : _ => ListItem(BitsParity(B)) ... </current>
```

## comb.mux

```k
rule
<current> "comb.mux" ( ListItem(B1:Bits) ListItem(B2:Bits) ListItem(B3:Bits) ) {_:Map} :  (_) -> (T:IntegerType) => #if Bits2Bool(B1) #then ListItem(BitsCast(B2, getWidth(T))) #else ListItem(BitsCast(B3, getWidth(T))) #fi
... </current>
```

## comb.icmp

```k
rule
<current> "comb.icmp" ( ListItem(B1:Bits) ListItem(B2:Bits) ) {"predicate" |-> Pred:Int : _:IntegerType _:Map} : _ => ListItem(BitsCmp(Pred, B1, B2)) ... </current>
```

```k
endmodule
```
