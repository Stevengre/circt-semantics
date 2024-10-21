# CIRCT Configuration

- This config is an extension of `<mlir>` and `<hardware>`.

```k
module CIRCT-CONFIG
imports STRING
```

```k
configuration
<circt>
```

- `<cmd>`: commands for CIRCT
    - `CIRCT#SETUP`: hardware setup through top module
- `<top-module>`: top module name

```k
  <cmd> $Cmd:K </cmd>
  <top-module> $TopModule:String </top-module>
  <top-inputs> .List </top-inputs>
  <top-outputs> .List </top-outputs>
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