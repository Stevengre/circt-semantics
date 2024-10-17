# SEQ Dialect Types and Attributes
```k
requires "../../mlir/mlir-syntax.md"
module SEQ-SYNTAX
  imports MLIR-SYNTAX
```

## Types

```k
syntax Type ::= SeqClockType | SeqFirmemType
```

### SeqFirmemType


```k
syntax SeqFirmemType ::= "!seq.firmem" "<" Int "x" Int ">"
                       | "!seq.firmem" "<" Int "x" Int "," "mask" Int ">"
```

### SeqClockType

```k
syntax SeqClockType ::= "!seq.clock"
```

```k
endmodule
```
