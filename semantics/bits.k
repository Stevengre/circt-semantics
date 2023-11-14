module BITS
    imports INT
    imports BOOL
    imports K-EQUAL

    syntax Bits ::= bits(Int, Int)

    syntax BitsVec ::= List{Bits, ","}

    syntax Bits ::= BitsConcat(BitsVec)     [function]
                  | BitsAnd(BitsVec)        [function]
                  | BitsOr(BitsVec)         [function]
                  | BitsXor(BitsVec)        [function]
                  | BitsAdd(BitsVec)        [function]
                  | BitsMul(BitsVec)        [function]
                  | BitsDup(Bits, Int)      [function]
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
                  | Int2Bits(Int, Int)      [function]
                  | "~Bits" Bits            [function]
                  | "!Bits" Bits            [function]
                  | Bits "divuBits" Bits    [function]
                  | Bits "divsBits" Bits    [function]
                  | Bits "/Bits"    Bits    [function]
                  | Bits "%Bits"    Bits    [function]
                  | Bits "modsBits" Bits    [function]
                  | Bits "moduBits" Bits    [function]
                  | Bits "-Bits"    Bits    [function]
    
    syntax Bool ::= isNeg(Bits) [function]
                  | isPos(Bits) [function]
                  | isNeg(Int, Int) [function]
                  | isPos(Int, Int) [function]

    syntax Int ::= Bits2Int(Bits)           [function]
                 | Bits2UInt(Bits)          [function]
                 | Int "mask" Int           [function]
                 | IntComplement(Int, Int)  [function]
                 | BitsParity(Bits)        [function]

    rule X:Int mask W:Int => X &Int (2 ^Int W -Int 1)

    syntax Bits ::= bitsCast(Bits, Int) [function]
                  | bitsCast(Int, Int) [function]


    rule IntComplement(X:Int, W:Int) => (((2 ^Int W -Int 1) xorInt X) +Int 1) mask W requires X >=Int 0

    // is negative
    rule isNeg(bits(X:Int, W:Int):Bits) => X >>Int (W -Int 1) >Int 0
    rule isPos(bits(X:Int, W:Int):Bits) => X >>Int (W -Int 1) ==Int 0
    rule isNeg(X:Int, W:Int) => X >>Int (W -Int 1) >Int 0
    rule isPos(X:Int, W:Int) => X >>Int (W -Int 1) ==Int 0

    // bits complementation
    rule ~Bits bits(X:Int, W:Int) => bitsCast(((2 ^Int W -Int 1) xorInt X) +Int 1, W)

    // bits not
    rule !Bits bits(X:Int, W:Int) => bitsCast(X xorInt (2 ^Int W -Int 1), W)

    // bits to int
    rule Bits2Int(bits(X:Int, W:Int):Bits) => X requires isPos(X, W)
    rule Bits2Int(bits(X:Int, W:Int):Bits) => -1 -Int (X xorInt (2 ^Int W -Int 1)) [owise]

    rule Int2Bits(X:Int, W:Int) => bitsCast(X, W) requires X >=Int 0
    rule Int2Bits(X:Int, W:Int) => bitsCast(2 ^Int W +Int X, W) [owise]

    // bits to unsigned int
    rule Bits2UInt(bits(X:Int, W:Int):Bits) => X &Int (2 ^Int W -Int 1)

    rule Int2Bits(X:Int, W:Int) => bitsCast(X, W) requires W >=Int 0 andBool X >=Int 0
    rule Int2Bits(X:Int, W:Int) => bitsCast(0 -Int X, W) [owise]

    rule bitsCast(bits(X:Int, _:Int):Bits, W:Int) => bits(X &Int (2 ^Int W -Int 1), W)
    rule bitsCast(X:Int, W:Int) => bits(X &Int (2 ^Int W -Int 1), W) requires X >=Int 0 andBool W >=Int 0
    rule bitsCast(X:Int, W:Int) => bitsCast(0 -Int X, W) [owise]

    // bits concat
    rule BitsConcat(B:Bits, BV:BitsVec) => B concatBits BitsConcat(BV)
    rule BitsConcat(.BitsVec) => bits(0, 0)

    // bits and
    rule BitsAnd(B:Bits, BV:BitsVec) => B &Bits BitsAnd(BV)
    rule BitsAnd(.BitsVec) => bits(0, 0)

    // bits or
    rule BitsOr(B:Bits, BV:BitsVec) => B |Bits BitsOr(BV)
    rule BitsOr(.BitsVec) => bits(0, 0)

    // bits xor
    rule BitsXor(B:Bits, BV:BitsVec) => B ^Bits BitsXor(BV)
    rule BitsXor(.BitsVec) => bits(0, 0)

    // bits add
    rule BitsAdd(B:Bits, BV:BitsVec) => B +Bits BitsAdd(BV)
    rule BitsAdd(.BitsVec) => bits(0, 0)

    // bits mul
    rule BitsMul(B:Bits, BV:BitsVec) => B *Bits BitsMul(BV)
    rule BitsMul(.BitsVec) => bits(0, 0)

    // bits binary and
    rule (bits(_X1:Int, W1:Int)):Bits &Bits B2:Bits => B2 requires W1 ==Int 0 [priority(50)]
    rule B1:Bits &Bits (bits(_X2:Int, W2:Int)):Bits => B1 requires W2 ==Int 0 [priority(51)]
    rule (bits(X1:Int, W1:Int)):Bits &Bits (bits(X2:Int, W2:Int)):Bits => bits(X1 &Int X2, maxInt(W1, W2))

    // bits binary or
    rule (bits(_X1:Int, W1:Int)):Bits |Bits B2:Bits => B2 requires W1 ==Int 0 [priority(50)]
    rule B1:Bits |Bits (bits(_X2:Int, W2:Int)):Bits => B1 requires W2 ==Int 0 [priority(51)]
    rule (bits(X1:Int, W1:Int)):Bits |Bits (bits(X2:Int, W2:Int)):Bits => bits(X1 |Int X2, maxInt(W1, W2))

    // bits binary xor
    rule (bits(_X1:Int, W1:Int)):Bits ^Bits B2:Bits => B2 requires W1 ==Int 0 [priority(50)]
    rule B1:Bits ^Bits (bits(_X2:Int, W2:Int)):Bits => B1 requires W2 ==Int 0 [priority(51)]
    rule (bits(X1:Int, W1:Int)):Bits ^Bits (bits(X2:Int, W2:Int)):Bits => bits(X1 xorInt X2, maxInt(W1, W2))

    // bits binary add
    rule (bits(_X1:Int, W1:Int)):Bits +Bits B2:Bits => B2 requires W1 ==Int 0 [priority(50)]
    rule B1:Bits +Bits (bits(_X2:Int, W2:Int)):Bits => B1 requires W2 ==Int 0 [priority(51)]
    rule (bits(X1:Int, W1:Int)):Bits +Bits (bits(X2:Int, W2:Int)):Bits
        => bits((X1 +Int X2) &Int (2 ^Int maxInt(W1, W2) -Int 1), maxInt(W1, W2))

    // bits binary mul
    rule bits(X1:Int, W1:Int):Bits *Bits bits(X2:Int, W2:Int):Bits
        => #if W1 ==Int 0 #then bits(X2, W2) #else 
            #if W2 ==Int 0 #then bits(X1, W1) #else
                bitsCast(X1 *Int X2, maxInt(W1, W2))
            #fi
        #fi

    // bits shl <<
    rule bits(X1:Int, W1:Int):Bits concatBits bits(X2:Int, W2:Int):Bits
        => #if W1 ==Int 0 #then bits(X2, W2) #else
            #if W2 ==Int 0 #then bits(X1, W1) #else 
                bits((X1 <<Int W2) +Int X2, W1 +Int W2)
            #fi 
        #fi

    // bits duplicate / replicate
    rule BitsDup(B:Bits, N:Int) => B concatBits BitsDup(B, N -Int 1) requires N >Int 0
    rule BitsDup(_:Bits, _:Int) => bits(0, 0) [owise]

    // bits sra >>
    rule bits(X:Int, W:Int):Bits >>Bits W2:Int => bits(X >>Int W2, W) requires isPos(X, W)
    rule bits(X:Int, W:Int):Bits >>Bits W2:Int
        => bits((X >>Int W2) |Int ((2 ^Int W2 -Int 1) <<Int (W -Int W2)), W) [owise]

    // bits srl >>>
    rule bits(X:Int, W:Int):Bits >>>Bits W2:Int => bits(X >>Int W2, W)
    rule bits(X1:Int, W1:Int) >>>Bits bits(X2:Int, _:Int) => bits(X1 >>Int X2, W1)

    // bits shl <<
    rule bits(X:Int, W:Int):Bits <<Bits W2:Int => bitsCast(X <<Int W2, W)
    rule bits(X:Int, W:Int):Bits <<Bits B:Bits => bitsCast(X <<Int Bits2UInt(B), W)

    // bits div
    rule bits(X1:Int, W1:Int):Bits /Bits bits(X2:Int, _W2:Int):Bits
        => bits(X1 /Int X2, W1)

    // bits divu
    rule bits(X1:Int, W1:Int):Bits divuBits bits(X2:Int, _W2:Int):Bits
        => bits(X1 /Int X2, W1)

    // bits divs
    rule bits(X1:Int, W1:Int):Bits divsBits bits(X2:Int, _W2:Int):Bits
        => bits(X1 /Int X2, W1)

    // bits mods
    rule bits(X1:Int, W1:Int):Bits modsBits bits(X2:Int, _W2:Int):Bits
        => bits(X1 modInt X2, W1)

    // bits modu
    rule bits(X1:Int, W1:Int):Bits moduBits bits(X2:Int, _W2:Int):Bits
        => bits(X1 modInt X2, W1)

    // bits sub
    rule bits(X1:Int, W1:Int):Bits -Bits bits(X2:Int, W2:Int):Bits
        => bitsCast(X1 +Int ((2 ^Int W2 -Int 1) xorInt X2) +Int 1, W1)

    rule BitsParity(bits(X:Int, W:Int):Bits)
        => (X &Int 1) xorInt BitsParity(bits(X >>Int 1, W -Int 1)) requires W >=Int 0
    
    rule BitsParity(bits(_X:Int, _W:Int):Bits) => 0 [owise]

endmodule