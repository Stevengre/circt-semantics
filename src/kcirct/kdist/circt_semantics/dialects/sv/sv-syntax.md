# SV Dialect Types and Attributes

```k
requires "../../mlir/mlir-syntax.md"
module SV-SYNTAX
  imports MLIR-SYNTAX
```

## Attributes

```k
syntax AttributeValue ::= SvMacroIdent
syntax SvMacroIdent ::= "#sv" "<" "macro.ident" SymbolRefId ">"
```

## Types

```k
endmodule
```

