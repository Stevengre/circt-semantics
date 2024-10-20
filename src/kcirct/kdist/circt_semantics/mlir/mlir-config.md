# MLIR Configuration

```k
requires "mlir-syntax.md"
module MLIR-CONFIG
imports MLIR-SYNTAX
imports MAP
imports LIST
```

## MLIR Configuration Structure

- prog: The program to be processed.
- types: TypeAlias -> Type
- attrs: AttributeAlias -> AttributeValue
- table: SymbolRefId -> StdOp

- symbols: To store the parent symbols of the current operation.
    - `.List` is current hierarchical symbol name for symbol table construction.

```k
configuration
<mlir>
  <prog> $PGM:TopLevel ~> .K </prog>
  <types> .Map </types>
  <attrs> .Map </attrs>
  <table> .Map </table>
  // auxiliary cells
  <symbols> .List </symbols>
</mlir>
```

```k
endmodule
```