# Bits

## Bits Syntax

```k
module BITS-SYNTAX
    imports INT-SYNTAX
    imports LIST
    syntax Bits ::= "bits" "(" BitsValue "," Int ")"
    // TODO: bit-level X and Z
    syntax BitsValue ::= Int | XZValue
    syntax XZValue ::= "#x" | "#z"

    syntax Bits ::= BitsAdd(List)           [function]
                  | Bits "+Bits" Bits       [function]
                  | BitsAnd(List)           [function]
                  | Bits "&Bits" Bits       [function]
                  | BitsOr(List)            [function]
                  | Bits "|Bits" Bits       [function]
                  | BitsXor(List)           [function]
                  | Bits "^Bits" Bits       [function]
                  | BitsCast(Bits)          [function]
                  | BitsCast(Bits, Int)     [function]
                  | BitsMul(List)           [function]
                  | Bits "*Bits" Bits       [function]
                  | BitsConcat(List)        [function]
                  | Bits "concatBits" Bits  [function]
                  | BitsDivs(List)          [function]
                  | Bits "/sBits" Bits      [function]
                  | BitsDivu(List)          [function]
                  | Bits "/uBits" Bits      [function]
                  | BitsShrs(List)          [function]
                  | Bits ">>Bits" Bits      [function]
                  | BitsShru(List)          [function]
                  | Bits ">>>Bits" Bits     [function]
                  | BitsShl(List)           [function]
                  | Bits "<<Bits" Bits      [function]
                  | BitsSub(List)           [function]
                  | Bits "-Bits" Bits       [function]
                  | BitsParity(Bits)        [function]
                  | BitsCmp(Int, Bits, Bits) [function]
                  | BitsDup(Bits, Int)      [function]
                  | BitsMods(List)          [function]
                  | Bits "modsBits" Bits    [function]
                  | BitsModu(List)          [function]
                  | Bits "moduBits" Bits    [function]
                  | BitsSlice(Bits, Int, Int) [function]

    syntax List ::= Bits2BitList(Bits) [function]

    syntax Int ::= Bool2Int(Bool) [function]

    syntax Bool ::= Bits2Bool(Bits) [function]
endmodule
```

## Bits Semantics

```k
module BITS
    imports BITS-SYNTAX
    imports INT
    imports BOOL-COMMON
    imports K-EQUAL

    rule BitsAdd(ListItem(B:Bits) L:List) => B +Bits BitsAdd(L)
    rule BitsAdd(.List) => bits(0, 0)

    // bits binary add
    rule bits(X1:Int, W1:Int)   +Bits bits(X2:Int, W2:Int)  => BitsCast(bits((X1 +Int X2) &Int (2 ^Int maxInt(W1, W2) -Int 1), maxInt(W1, W2)))
    // TODO: optimize
    rule bits(_:XZValue, W1)  +Bits bits(_, W2)    => bits(#x, maxInt(W1, W2))
    rule bits(_, W1) +Bits bits(_:XZValue, W2) => bits(#x, maxInt(W1, W2))
    [owise]

    rule BitsAnd(ListItem(B:Bits) L:List) => B &Bits BitsAnd(L)
    rule BitsAnd(.List) => bits(0, 0)

    rule bits(X1:Int, W1:Int)   &Bits bits(X2:Int, W2:Int)  => bits(X1 &Int X2, maxInt(W1, W2))
    // #x
    rule bits(#x, W1) &Bits bits(_, W2)    => bits(#x, maxInt(W1, W2))
    rule bits(_, W1) &Bits bits(#x, W2) => bits(#x, maxInt(W1, W2))
    [owise]
    // #z
    rule bits(#z, W1) &Bits bits(#z, W2)    => bits(#z, maxInt(W1, W2))
    rule bits(_:Int, W1) &Bits bits(#z, W2) => bits(0, maxInt(W1, W2))
    rule bits(#z, W1) &Bits bits(_:Int, W2) => bits(0, maxInt(W1, W2))

    rule BitsOr(ListItem(B:Bits) L:List) => B |Bits BitsOr(L)
    rule BitsOr(.List) => bits(0, 0)

    rule bits(X1:Int, W1:Int)   |Bits bits(X2:Int, W2:Int)   => bits(X1 |Int X2, maxInt(W1, W2))
    rule bits(#x, W1) |Bits bits(_, W2)    => bits(#x, maxInt(W1, W2))
    rule bits(_, W1) |Bits bits(#x, W2) => bits(#x, maxInt(W1, W2))
    [owise]
    // TODO: optimize after bit-level z
    rule bits(#z, W1) |Bits bits(_:Int, W2) => bits(#z, maxInt(W1, W2))
    rule bits(_:Int, W1) |Bits bits(#z, W2) => bits(#z, maxInt(W1, W2))
    rule bits(#z, W1) |Bits bits(#z, W2) => bits(#z, maxInt(W1, W2))

    rule BitsXor(ListItem(B:Bits) L:List) => B ^Bits BitsXor(L)
    rule BitsXor(.List) => bits(0, 0)
    
    rule bits(X1:Int, W1:Int)   ^Bits bits(X2:Int, W2:Int)  => bits(X1 xorInt X2, maxInt(W1, W2))
    rule bits(#x, W1) ^Bits bits(_, W2)    => bits(#x, maxInt(W1, W2))
    rule bits(_, W1) ^Bits bits(#x, W2) => bits(#x, maxInt(W1, W2))
    [owise]
    // TODO: optimize after bit-level z
    rule bits(_:Int, W1) ^Bits bits(#z, W2) => bits(#z, maxInt(W1, W2))
    rule bits(#z, W1) ^Bits bits(_:Int, W2) => bits(#z, maxInt(W1, W2))
    rule bits(#z, W1) ^Bits bits(#z, W2)    => bits(0, maxInt(W1, W2))

    rule BitsCast(bits(X:Int, W:Int)) => bits(X &Int (2 ^Int W -Int 1), W) 
    requires X >=Int 0 andBool W >=Int 0
    rule BitsCast(bits(X:Int, W:Int)) => BitsCast(bits(2 ^Int W +Int X, W)) [owise]
    rule BitsCast(bits(X:XZValue, W:Int)) => bits(X, W)

    rule BitsCast(bits(X:Int, _W:Int), W1:Int) => BitsCast(bits(X, W1))

    rule BitsMul(ListItem(B:Bits) L:List) => B *Bits BitsMul(L)
    rule BitsMul(.List) => bits(0, 0)

    rule bits(X1:Int, W1:Int) *Bits bits(X2:Int, W2:Int) => BitsCast(bits(X1 *Int X2, W1 +Int W2))
    // TODO: optimize
    rule bits(_:XZValue, W1:Int) *Bits bits(_, W2:Int) => bits(#x, maxInt(W1, W2))
    rule bits(_, W1:Int) *Bits bits(_:XZValue, W2:Int) => bits(#x, maxInt(W1, W2))
    [owise]

    rule BitsConcat(ListItem(B:Bits) L:List) => B concatBits BitsConcat(L)
    rule BitsConcat(.List) => bits(0, 0)

    rule bits(X1:Int, W1:Int) concatBits bits(X2:Int, W2:Int)
        => bits((X1 <<Int W2) +Int X2, W1 +Int W2)
    rule bits(_:XZValue, W1:Int) concatBits bits(_, W2:Int) => bits(#x, W1 +Int W2)
    rule bits(_, W1:Int) concatBits bits(_:XZValue, W2:Int) => bits(#x, W1 +Int W2)
    [owise]


    rule BitsDivs(ListItem(B1:Bits) ListItem(B2:Bits)) => B1 /sBits B2
    rule bits(X1:Int, W1:Int) /sBits bits(X2:Int, _W2:Int) => BitsCast(bits(X1 /Int X2, W1)) requires X2 =/=Int 0
    rule bits(_:XZValue, W1:Int) /sBits bits(_, _W2:Int) => bits(#x, W1)
    rule bits(_, W1:Int) /sBits bits(_:XZValue, _W2:Int) => bits(#x, W1)
    [owise]

    rule BitsDivu(ListItem(B1:Bits) ListItem(B2:Bits)) => B1 /uBits B2
    rule bits(X1:Int, W1:Int) /uBits bits(X2:Int, _W2:Int) => BitsCast(bits(X1 /Int X2, W1)) requires X2 =/=Int 0
    rule bits(_:XZValue, W1:Int) /uBits bits(_, _W2:Int) => bits(#x, W1)
    rule bits(_, W1:Int) /uBits bits(_:XZValue, _W2:Int) => bits(#x, W1)
    [owise]

    rule BitsShrs(ListItem(B1:Bits) ListItem(B2:Bits)) => B1 >>Bits B2
    rule bits(X1:Int, W1:Int) >>Bits bits(X2:Int, _W2:Int) => bits(X1 >>Int X2, W1)
    rule bits(_:XZValue, W1:Int) >>Bits bits(_, _W2:Int) => bits(#x, W1)
    rule bits(_, W1:Int) >>Bits bits(_:XZValue, _W2:Int) => bits(#x, W1)
    [owise]

    rule BitsShru(ListItem(B1:Bits) ListItem(B2:Bits)) => B1 >>>Bits B2
    rule bits(X1:Int, W1:Int) >>>Bits bits(X2:Int, _W2:Int) => bits(X1 >>Int X2, W1)
    rule bits(_:XZValue, W1:Int) >>>Bits bits(_, _W2:Int) => bits(#x, W1)
    rule bits(_, W1:Int) >>>Bits bits(_:XZValue, _W2:Int) => bits(#x, W1)
    [owise]

    rule BitsShl(ListItem(B1:Bits) ListItem(B2:Bits))  => B1 <<Bits B2
    rule bits(X1:Int, W1:Int) <<Bits bits(X2:Int, _W2:Int) => BitsCast(bits(X1 <<Int X2, W1))
    rule bits(_:XZValue, W1:Int) <<Bits bits(_, _W2:Int) => bits(#x, W1)
    rule bits(_, W1:Int) <<Bits bits(_:XZValue, _W2:Int) => bits(#x, W1)
    [owise]

    rule BitsSub(ListItem(B1:Bits) ListItem(B2:Bits))  => B1 -Bits B2
    rule bits(X1:Int, W1:Int) -Bits bits(X2:Int, W2:Int) => BitsCast(bits(X1 +Int ((2 ^Int W2 -Int 1) xorInt X2) +Int 1, W1))
    rule bits(_:XZValue, W1:Int) -Bits bits(_, _W2:Int) => bits(#x, W1)
    rule bits(_, W1:Int) -Bits bits(_:XZValue, _W2:Int) => bits(#x, W1)
    [owise]

    rule Bits2BitList(bits(X:Int, W:Int)) => Bits2BitList(bits(X >>Int 1, W -Int 1)) ListItem(bits(X &Int 1, 1))
    rule Bits2BitList(bits(_:Int, 0)) => .List
    rule Bits2BitList(bits(_:XZValue, _:Int)) => .List

    rule BitsParity(bits(X:Int, W:Int)) => BitsCast(BitsXor(Bits2BitList(bits(X, W))), 1)
    rule BitsParity(bits(_:XZValue, _:Int)) => bits(#x, 1)

    rule Bool2Int(B:Bool) => #if B #then 1 #else 0 #fi

    rule BitsCmp(0, bits(X1:Int, _:Int), bits(X2:Int, _:Int)) => bits(Bool2Int(X1 ==Int X2), 1)
    rule BitsCmp(1, bits(X1:Int, _:Int), bits(X2:Int, _:Int)) => bits(Bool2Int(X1 =/=Int X2), 1)
    rule BitsCmp(2, bits(X1:Int, _:Int), bits(X2:Int, _:Int)) => bits(Bool2Int(X1 =/=Int X2), 1)
    rule BitsCmp(3, bits(X1:Int, _:Int), bits(X2:Int, _:Int)) => bits(Bool2Int(X1 <Int X2), 1)
    rule BitsCmp(4, bits(X1:Int, _:Int), bits(X2:Int, _:Int)) => bits(Bool2Int(X1 >Int X2), 1)
    rule BitsCmp(5, bits(X1:Int, _:Int), bits(X2:Int, _:Int)) => bits(Bool2Int(X1 >=Int X2), 1)
    rule BitsCmp(6, bits(X1:Int, _:Int), bits(X2:Int, _:Int)) => bits(Bool2Int(X1 <Int X2), 1)
    rule BitsCmp(7, bits(X1:Int, _:Int), bits(X2:Int, _:Int)) => bits(Bool2Int(X1 <=Int X2), 1)
    rule BitsCmp(8, bits(X1:Int, _:Int), bits(X2:Int, _:Int)) => bits(Bool2Int(X1 >Int X2), 1)
    rule BitsCmp(9, bits(X1:Int, _:Int), bits(X2:Int, _:Int)) => bits(Bool2Int(X1 >=Int X2), 1)
    rule BitsCmp(_:Int, bits(_:XZValue, _:Int), bits(_, _:Int)) => bits(0, 1)
    rule BitsCmp(_:Int, bits(_, _:Int), bits(_:XZValue, _:Int)) => bits(0, 1)
    [owise]

    rule BitsDup(B:Bits, N:Int) => B concatBits BitsDup(B, N -Int 1) requires N >Int 0
    rule BitsDup(_:Bits, 0) => bits(0, 0)

    rule BitsMods(ListItem(B1:Bits) ListItem(B2:Bits)) => B1 modsBits B2

    rule bits(X1:Int, W1:Int) modsBits bits(X2:Int, _W2:Int) => bits(X1 modInt X2, W1) requires X2 =/=Int 0
    rule bits(_:XZValue, W1:Int) modsBits bits(_, _W2:Int) => bits(#x, W1)
    rule bits(_, W1:Int) modsBits bits(_:XZValue, _W2:Int) => bits(#x, W1)
    [owise]

    rule BitsModu(ListItem(B1:Bits) ListItem(B2:Bits)) => B1 moduBits B2

    rule bits(X1:Int, W1:Int) moduBits bits(X2:Int, _W2:Int) => bits(X1 modInt X2, W1) requires X2 =/=Int 0
    rule bits(_:XZValue, W1:Int) moduBits bits(_, _W2:Int) => bits(#x, W1)
    rule bits(_, W1:Int) moduBits bits(_:XZValue, _W2:Int) => bits(#x, W1)
    [owise]

    rule Bits2Bool(bits(X:Int, _:Int)) => X =/=Int 0
    rule Bits2Bool(bits(_:XZValue, _:Int)) => false

    rule BitsSlice(bits(X:Int, W:Int), Begin:Int, End:Int) => bits((X >>Int (W -Int End)) &Int (2 ^Int (End -Int Begin) -Int 1), End -Int Begin)
    rule BitsSlice(bits(V:XZValue, _:Int), Begin:Int, End:Int) => bits(V, End -Int Begin)
endmodule
```