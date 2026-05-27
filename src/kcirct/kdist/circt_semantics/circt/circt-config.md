# CIRCT Configuration

- This config is an extension of `<mlir>` and `<hardware>`.

```k
requires "../hardware/bits.md"
module CIRCT-CONFIG
imports STRING
imports LIST
imports BITS-SYNTAX
```

```k
configuration
<circt>
```

- `<cmd>`: commands for CIRCT
    - `CIRCT#SETUP`: hardware setup through top module
- `<top-module>`: top module name

```k
  <cmd> .K </cmd>
  // <cmd> "CIRCT#SETUP" ~> "CIRCT#SIMULATE" ~> ListItem(bits(1,8)) ListItem(bits(2,8)) </cmd>
  // <cmd> $Cmd:K </cmd>
  // <top-module> $TopModule:String </top-module>
  <top-module> "":String </top-module>
  <top-ins> .List </top-ins>
```

## Auxiliary Cells

```k

```

```k
</circt>
```

```k
endmodule
```
