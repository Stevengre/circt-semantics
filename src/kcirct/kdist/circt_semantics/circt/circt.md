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
  imports BOOL
```

## Attribute Value to Bits Value

```k
syntax Bits ::= ToBits ( AttributeValue, Type ) [function]
rule ToBits(V, T) => ReplaceNegative( ToInt(V), getWidth(T) )

syntax Int ::= ToInt ( AttributeValue ) [function]
rule ToInt( V:Int ) => V
rule ToInt( V:Int : T:Type) => V
rule ToInt( true  ) => 1
rule ToInt( false ) => 0
```

## Replace Negative To Positive

```k
syntax Bits ::= ReplaceNegative( Int, Int ) [function]
rule ReplaceNegative( V:Int, T:Int ) => bits(((2 ^Int T) -Int ((0 -Int V) &Int ((2 ^Int T) -Int 1))), T) requires V <Int 0
rule ReplaceNegative( V:Int, T:Int ) => bits(V &Int ((2 ^Int T) -Int 1) , T) requires V >=Int 0
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
<signals> Signals:Map => .Map </signals>
<history> _ => Signals </history>
(
   .Bag
=> <current-info>
    <current-id> !_:Int </current-id>
    <current> 
    STIMULI ~> "HARDWARE#WRITE" ~> INS 
    ~> "HARDWARE#NEW_CURRENT" ~> NewCurrentString(keys_list(Conn)) PROCS
    </current>
   </current-info>
)
```

```k
syntax List ::= NewCurrentString(List) [function]
rule NewCurrentString(ListItem(Str) L:List) => ListItem(ListItem(Str)) NewCurrentString(L)
rule NewCurrentString(.List) => .List
```

```k
// rule 
// <current> 
//    "HARDWARE#NEW_CURRENT" ~> ListItem(Port:String) L:List 
// => "HARDWARE#NEW_CURRENT" ~> L 
// ...
// </current>
// (  .Bag
// => <current-info>
//     <current-id> !_:Int </current-id>
//     <current> ListItem(Port) </current>
//    </current-info>
// )
// [priority(45)]
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

## Unfolding Standard Operations for `<current>`

```k
rule <current> { Bs:StdBlocks }:StdRegion => Bs ... </current>
rule <current> _Cid ( .List ) : Ops:StdOps Bs:StdBlocks => Ops ~> Bs ... </current>
rule <current> .StdBlocks => .K ... </current>
rule <current> Op:StdOpL Ops:StdOps => Op ~> Ops ... </current>
rule <current> .StdOps => .K ... </current>
```

## Auto Connect for StdOp

```k
// String "(" List ")" "{" Map "}" ":" StdFT
              //  | String "(" List ")" "{" Map "}" SuccessorList "(" StdRegions ")" ":" StdFT
rule 
<current> 
   Op:String ( ListItem(Arg:String) Args:List ) { Attr:Map } : FT 
=> "HARDWARE#READ" ~> ListItem(Arg) Args ~> Op (ListItem(Arg) Args) {Attr} : FT
// => .List ~> "HARDWARE#READ_DIRECT"  ~> ListItem(Arg) Args ~> Op (ListItem(Arg) Args) {Attr} : FT
... 
</current>
[priority(40)]

rule 
<current> 
   ListItem(Arg:Bits) Args:List ~> Op ( _:List ) { Attr:Map } : FT
=> Op (ListItem(Arg) Args) {Attr} : FT
... 
</current>
// requires CheckNotSeq(Op)
[priority(40)]

rule
<current> 
   Op:String ( ListItem(Arg:String) Args:List ) { Attr:Map } SL:SuccessorList ( RS:StdRegions ) : FT 
=> "HARDWARE#READ" ~> ListItem(Arg) Args ~> Op (ListItem(Arg) Args) {Attr} SL (RS) : FT
// => .List ~> "HARDWARE#READ_DIRECT"  ~> ListItem(Arg) Args ~> Op (ListItem(Arg) Args) {Attr} SL (RS) : FT
... 
</current>
[priority(40)]

rule 
<current> 
   ListItem(Arg:Bits) Args:List ~> Op ( _:List ) { Attr:Map } SL:SuccessorList ( RS:StdRegions ) : FT 
=> Op (ListItem(Arg) Args) {Attr} SL (RS) : FT
... 
</current>
// requires CheckNotSeq(Op)
[priority(40)]
```

// ```k
// syntax Bool ::= CheckNotSeq(String) [function]
// rule CheckNotSeq("seq.firreg") => false 
// rule CheckNotSeq("seq.firmem.write_port") => false
// rule CheckNotSeq("seq.firmem.read_write_port") => false
// rule CheckNotSeq(_) => true [owise]
// ```

```k
endmodule
```
