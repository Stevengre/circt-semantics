# CIRCT Semantics

```k
requires "circt-config.md"
requires "../mlir/mlir-config.md"
requires "../mlir/mlir-helper.md"
requires "../hardware/hardware-config.md"
requires "../mlir/builtin.md"

module CIRCT
  imports STRING
  imports K-EQUAL
  imports MLIR-CONFIG
  imports HARDWARE-CONFIG
  imports CIRCT-CONFIG
  imports MLIR-HELPER
  imports BUILTIN
```

## Attribute Value to Bits Value

```k
syntax Bits ::= ToBits ( AttributeValue, Type ) [function]
rule ToBits(V, T) => bits(ToInt(V), getWidth(T))

syntax Int ::= ToInt ( AttributeValue ) [function]
rule ToInt( V:Int ) => V
rule ToInt( true  ) => 1
rule ToInt( false ) => 0
```

## Specify Top Module

```k
rule 
<prog> .K </prog>
<table> M </table>
<top-module> TM </top-module>
<cmd> "CIRCT#SETUP" => .K ... </cmd>
<setup> .K => M [TM] orDefault "CIRCT#ERROR: no such top module: " +String TM </setup>
```

## Start Hardware Simulation

```k
rule 
<prog> .K </prog>
<setup> .K </setup>
<cmd> 
   "CIRCT#SIMULATE" ~> STIMULI:List 
=> .K
... 
</cmd>
<connection> Conn:Map </connection>
<procedures> PROCS:List </procedures>
<top-ins> INS:List </top-ins>
(
   .Bag
=> <current-info>
    <current-id> !_:Int </current-id>
    <current> 
    STIMULI ~> "HARDWARE#WRITE" ~> INS 
    ~> "HARDWARE#NEW_CURRENT" ~> PROCS
    ~> keys_list(Conn)
    </current>
   </current-info>
)
```

## Get Op

```k
rule 
<setup> "CIRCT#GET_OP" ~> MID:SymbolRefId => "CIRCT#GET_OP" ~> SymbolRefId2String(MID) ... </setup>

rule 
<setup> "CIRCT#GET_OP" ~> MID:String => Op ... </setup>
<table> ... MID |-> Op ... </table>
```

## Unfolding Standard Operations for `<setup>`

```k
// rule <setup> R:StdRegion , Rs:StdRegions => R ~> Rs ... </setup>
// rule <setup> .StdRegions => .K ... </setup> [owise]
// rule <setup> { Bs:StdBlocks }:StdRegion => Bs ... </setup>
// rule <setup> _:StdBlockLabel Ops:StdOps Bs:StdBlocks => Ops ~> Bs ... </setup>
// rule <setup> .StdBlocks => .K ... </setup>
rule <setup> Op:StdOpL Ops:StdOps => Op ~> Ops ... </setup>
// rule <setup> .StdOps => .K ... </setup>
```

## Auto Connect for StdOp

```k
// String "(" List ")" "{" Map "}" ":" StdFT
              //  | String "(" List ")" "{" Map "}" SuccessorList "(" StdRegions ")" ":" StdFT
rule 
<current> 
   Op:String ( ListItem(Arg:String) Args:List ) { Attr:Map } : FT 
=> "HARDWARE#READ" ~> ListItem(Arg) Args ~> Op (ListItem(Arg) Args) {Attr} : FT
... 
</current>
[priority(40)]

rule 
<current> 
   ListItem(Arg:Bits) Args:List ~> Op ( _:List ) { Attr:Map } : FT
=> Op (ListItem(Arg) Args) {Attr} : FT
... 
</current>
[priority(40)]

rule
<current> 
   Op:String ( ListItem(Arg:String) Args:List ) { Attr:Map } SL:SuccessorList ( RS:StdRegions ) : FT 
=> "HARDWARE#READ" ~> ListItem(Arg) Args ~> Op (ListItem(Arg) Args) {Attr} SL (RS) : FT
... 
</current>
[priority(40)]

rule 
<current> 
   ListItem(Arg:Bits) Args:List ~> Op ( _:List ) { Attr:Map } SL:SuccessorList ( RS:StdRegions ) : FT 
=> Op (ListItem(Arg) Args) {Attr} SL (RS) : FT
... 
</current>
[priority(40)]
```


```k
endmodule
```
