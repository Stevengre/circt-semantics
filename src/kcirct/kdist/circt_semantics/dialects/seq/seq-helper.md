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

mask corresponds to each block of W/maskSize 
The data width is evenly divided into blocks, one for each mask bit.
A block is written only if the corresponding mask bit is 1.

```k
syntax Bits ::= maskWrite(Map, Bits, Bits, Bits, Int) [function]
syntax Bits ::= maskWrite2(Map, Bits, Bits, Bits, Int) [function]
syntax Bits ::= getMask(Bits, Bits, Int) [function]
syntax Int ::= getMask2(Int, Int, Int, Int) [function]

rule getMask(bits(BlockNum:Int, W1:Int):Bits, bits(Mask:Int, _:Int):Bits, W2:Int) =>
bits(getMask2(BlockNum:Int, Mask:Int, (W2 /Int W1):Int, 1:Int), W2)

rule getMask2(0:Int, Mask:Int, _:Int, _:Int) => Mask

rule getMask2(BlockNum:Int, Mask:Int, BlockSize:Int, Base:Int) => 
getMask2(BlockNum >>Int 1, Mask +Int (((1 <<Int BlockSize) -Int 1) *Int Base), BlockSize:Int, Base <<Int BlockSize)
requires (BlockNum modInt 2) ==Int 1 

rule getMask2(BlockNum:Int, Mask:Int, BlockSize:Int, Base:Int) => 
getMask2(BlockNum >>Int 1, Mask, BlockSize:Int, Base <<Int BlockSize)
requires ((BlockNum modInt 2) ==Int 0) andBool (BlockNum =/=Int 0)

rule maskWrite(Mem:Map, DataIn:Bits, Mask:Bits, Addr:Bits, W:Int) =>
maskWrite2(Mem:Map, DataIn:Bits, getMask(Mask:Bits, bits(0, W), W):Bits, Addr:Bits, W:Int)

rule maskWrite2(Mem:Map, DataIn:Bits, Mask:Bits, Addr:Bits, W:Int) => 
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