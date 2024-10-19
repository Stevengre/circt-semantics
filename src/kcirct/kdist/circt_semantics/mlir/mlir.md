

# MLIR Semantic Rules

```k
requires "mlir-conf.md"
requires "mlir-helper.md"
module MLIR
imports MLIR-CONF
imports MLIR-HELPER
imports LIST
imports BOOL
imports K-EQUAL
```

## Type Alias

```k
rule 
<prog> Alias:TypeAlias = T:Type Pgm:TopLevel => Pgm </prog>
<types> M:Map => M [Alias <- T] </types>
```

## Attribute Alias

```k
rule 
<prog> Alias:AttributeAlias = Attr:AttributeValue Pgm:TopLevel => Pgm </prog>
<attrs> M:Map => M [Alias <- Attr] </attrs>
```

## Standardize Operation

```k
rule 
<prog> Op:Operation Pgm:TopLevel => stdizeOp(Op) ~> Pgm </prog>
[priority(170)]
```

### Refine Standardize Operation

Template to provide your own semantic rules for standardize operation.

```kTemplate
rule 
<prog> Op:Operation Pgm:TopLevel => (Your Standardized Operation) ~> Pgm </prog>
```

## Construct Symbol Table

TODO: The rules are similar, is that any ways to simplify them?

```k
rule 
<prog> Op (VL) { Attr:Map } : FT => .K ... </prog>
<table> 
   M:Map 
=> #if "sym_name" in_keys(Attr) 
   #then M [ AbsSymbolName(ListItem(Attr["sym_name"]) Symbols) <- Op (VL) {Attr} : FT ] 
   #else M #fi
</table>
<symbols> Symbols </symbols>
[priority(170)]

rule
<prog> Res = Op (VL) { Attr:Map } : FT => .K ... </prog>
<table> 
   M:Map 
=> #if "sym_name" in_keys(Attr) 
   #then M [ AbsSymbolName(ListItem(Attr["sym_name"]) Symbols) <- Res = Op (VL) {Attr} : FT ] 
   #else M #fi
</table>
<symbols> Symbols </symbols>
[priority(170)]


rule
<prog> Op (VL) { Attr:Map } Ss (Rs) : FT => Rs ~> "MLIR#HAS_SYMBOL" ... </prog>
<table> 
   M:Map 
=> M [ AbsSymbolName(ListItem(Attr["sym_name"]) Symbols) <- Op (VL) {Attr} Ss (Rs) : FT ]
</table>
<symbols> Symbols => ListItem(Attr["sym_name"]) Symbols </symbols>
requires "sym_name" in_keys(Attr) 
[priority(170)]

rule
<prog> _ (_) { Attr:Map } _ (Rs) : _ => Rs ... </prog>
requires notBool "sym_name" in_keys(Attr) 
[priority(170)]

rule
<prog> Res = Op (VL) { Attr:Map } Ss (Rs) : FT => Rs ~> "MLIR#HAS_SYMBOL" ... </prog>
<table> 
   M:Map 
=> M [ AbsSymbolName(ListItem(Attr["sym_name"]) Symbols) <- Res = Op (VL) {Attr} Ss (Rs) : FT ]
</table>
<symbols> Symbols => ListItem(Attr["sym_name"]) Symbols </symbols>
requires "sym_name" in_keys(Attr) 
[priority(170)]

rule
<prog> _ = _ (_) { Attr:Map } _ (Rs) : _ => Rs ... </prog>
requires notBool "sym_name" in_keys(Attr) 
[priority(170)]
```

### Refine Construct Symbol Table & Preprocess Operation

TODO.

## Unfolding Operation's Nested Structure

```k
rule <prog> { Bs:StdBlocks }:StdRegion, Rs:StdRegions => Bs ~> Rs ... </prog>
rule 
<prog> .StdRegions ~> "MLIR#HAS_SYMBOL" => .K ... </prog>
<symbols> ListItem(_) Symbols => Symbols </symbols>
rule <prog> .StdRegions => .K ... </prog> [owise]

rule <prog> _:StdBlockLabel Ops:StdOps Bs:StdBlocks => Ops ~> Bs ... </prog>
rule <prog> .StdBlocks => .K ... </prog>

rule <prog> Op:StdOpL Ops:StdOps => Op ~> Ops ... </prog>
rule <prog> .StdOps => .K ... </prog>

rule <prog> .TopLevel => .K ... </prog>
```


```k
endmodule
```

# How to Refine MLIR Semantic Rules
