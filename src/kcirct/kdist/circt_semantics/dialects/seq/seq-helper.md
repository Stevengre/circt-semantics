# SEQ Helper

```k
requires "seq-syntax.md"
requires "../../hardware/bits.md"
requires "../../hardware/hardware.md"
requires "../../mlir/builtin.md"
requires "../../mlir/mlir-helper.md"
module SEQ-HELPER
imports SEQ-SYNTAX
imports BITS
imports HARDWARE
imports LIST
imports MAP
imports BUILTIN
imports MLIR-HELPER
```

### `maskWrite`

```k
syntax Bits ::= maskWrite(Map, Bits, Bits, Bits, Int) [function]
rule maskWrite(Mem:Map, DataIn:Bits, Mask:Bits, Addr:Bits, W:Int) => 
((DataIn &Bits Mask) |Bits (({(Mem[Addr] orDefault bits(0, W))}:>Bits) &Bits (!Bits Mask)))
```

### buildRLList

```k
syntax List ::= buildRLList(Int, Bits) [function]
rule buildRLList(1:Int, bits(_:Int, W:Int)) => ListItem(bits(0, 1)) ListItem(bits(0, W)) ListItem(bits(0, 1))
rule buildRLList(RL:Int, bits(_:Int, W:Int)) => ListItem(bits(0, 1)) ListItem(bits(0, W)) ListItem(bits(0, 1)) buildRLList(RL -Int 1, bits(0, W)) [owise]
```

```k
endmodule
```