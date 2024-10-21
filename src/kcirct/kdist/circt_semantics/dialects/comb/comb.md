# COMB Dialect

```k
requires "comb-syntax.md"
requires "../../hardware/bits.md"
requires "../../hardware/hardware-config.md"
requires "../../mlir/mlir-helper.md"
module COMB
imports COMB-SYNTAX
imports BITS
imports HARDWARE-CONFIG
imports MLIR-HELPER
```

## comb.add


```k
rule
<current> "comb.add" ( ListItem(B:Bits) L:List ) {_:Map} : _ => ListItem(BitsAdd(ListItem(B) L)) ... </current>
```

```k
endmodule
```
