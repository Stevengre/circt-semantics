# Bits

## Bits Syntax

```k
module BITS-SYNTAX
    imports INT-SYNTAX
    imports LIST
    syntax Bits ::= "bits" "(" BitsValue "," Int ")"
    syntax BitsValue ::= Int | XZValue
    syntax XZValue ::= "#x" | "#z"

    syntax Bits ::= BitsConcat(List)        [function]
                  | BitsAnd(List)           [function]
                  | BitsOr(List)            [function]
                  | BitsXor(List)           [function]
                  | BitsAdd(List)           [function]
                  | BitsMul(List)           [function]
                  | BitsDup(Bits, Int)      [function]
                  | BitsShrs(List)          [function]
                  | BitsShru(List)          [function]
                  | BitsShl(List)           [function]
                  | BitsDivs(List)          [function]
                  | BitsDivu(List)          [function]
                  | BitsMods(List)          [function]
                  | BitsModu(List)          [function]
                  | BitsSub(List)           [function]
                  | Bits "&Bits" Bits       [function]
                  | Bits "^Bits" Bits       [function]
                  | Bits "|Bits" Bits       [function]
                  | Bits "+Bits" Bits       [function]
                  | Bits "*Bits" Bits       [function]
                  | Bits "concatBits" Bits  [function]
                  | Bits "<<Bits" Int       [function]
                  | Bits "<<Bits" Bits      [function]
                  | Bits ">>Bits" Int       [function]
                  | Bits ">>>Bits" Int      [function]
                  | Bits ">>Bits" Bits      [function]
                  | Bits ">>>Bits" Bits     [function]
                  | "~Bits" Bits            [function]
                  | "!Bits" Bits            [function]
                  | Bits "/uBits" Bits      [function]
                  | Bits "/sBits" Bits      [function]
                  | Bits "/Bits"    Bits    [function]
                  | Bits "%Bits"    Bits    [function]
                  | Bits "modsBits" Bits    [function]
                  | Bits "moduBits" Bits    [function]
                  | Bits "-Bits"    Bits    [function]
                  | BitsMask(Bits, Int, Int)[function] 
                  | BitsParity(Bits)        [function]
endmodule
```

## Bits Semantics

```k
module BITS
    imports BITS-SYNTAX
    imports INT

    rule BitsAdd(ListItem(B:Bits) L:List) => B +Bits BitsAdd(L)
    rule BitsAdd(.List) => bits(0, 0)

    // bits binary add
    rule bits(_X1:Int, W1:Int)  +Bits B2:Bits               => B2 requires W1 ==Int 0 [priority(40)]
    rule B1:Bits                +Bits bits(_X2:Int, W2:Int) => B1 requires W2 ==Int 0 [priority(41)]
    rule bits(X1:Int, W1:Int)   +Bits bits(X2:Int, W2:Int)  => bits((X1 +Int X2) &Int (2 ^Int maxInt(W1, W2) -Int 1), maxInt(W1, W2))
    rule bits(Xz:XZValue, W1)  +Bits bits(_, W2)    => bits(Xz, maxInt(W1, W2))
    rule bits(_:Int, W1) +Bits bits(Xz:XZValue, W2) => bits(Xz, maxInt(W1, W2))
endmodule
```