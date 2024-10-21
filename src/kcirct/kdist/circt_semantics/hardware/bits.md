# Bits

## Bits Syntax

```k
module BITS-SYNTAX
    imports INT-SYNTAX
    syntax Bits ::= "bits" "(" BitsValue "," Int ")"
    syntax BitsValue ::= Int | XZValue
    syntax XZValue ::= "#x" | "#z"
endmodule
```

## Bits Semantics

```k
module BITS
    imports BITS-SYNTAX
    imports INT
endmodule
```