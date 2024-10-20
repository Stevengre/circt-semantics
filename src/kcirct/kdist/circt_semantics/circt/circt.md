# CIRCT Semantics

```k
requires "circt-config.md"
requires "../mlir/mlir-config.md"
requires "../mlir/mlir-helper.md"
requires "../hardware/hardware-config.md"

module CIRCT
  imports STRING
  imports K-EQUAL
  imports MLIR-CONFIG
  imports HARDWARE-CONFIG
  imports CIRCT-CONFIG
  imports MLIR-HELPER
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

```k
endmodule
```
