requires "bits.k"
// requires "circt-conf.k"

module COMB
    imports CIRCT-SYNTAX
    imports CONFIGURATION
    imports BITS
    imports MAP

    syntax Value ::= Bits
    // syntax Value ::= AttributeValue
    syntax ValueList ::= List{Value, ","}
    syntax BitsVec ::= lookupValuesAsBitsVec(ValueIdList) [function]
    syntax Bits ::= lookupValueAsBits(ValueId) [function]
                  | lookupValueAsBits(ValueId, Type) [function]

    rule [[ lookupValueAsBits(A:ValueId) => bits(V, getWidth(T)) ]]
        <circt-locals> ... A |-> TV(T, V) ... </circt-locals>
    
    rule [[ lookupValueAsBits(A:ValueId, T:Type) => bits(V, getWidth(T)) ]]
        <circt-locals> ... A |-> TV(T, V) ... </circt-locals>

    rule lookupValuesAsBitsVec(.ValueIdList) => .BitsVec
    rule [[ lookupValuesAsBitsVec(A:ValueId, As:ValueIdList) 
        => bits(V, getWidth(T)), lookupValuesAsBitsVec(As) ]]
        <circt-locals> ... A |-> TV(T, V) ... </circt-locals>
    
    // todo
    rule [[ lookupValuesAsBitsVec(A:ValueId, As:ValueIdList) 
        => bits(0, 1), lookupValuesAsBitsVec(As) ]]
        <circt-locals> M:Map </circt-locals>
    requires notBool A in_keys(M)

    syntax Bool ::= icmp(Int, Int, Int) [function]
                  | icmp(Int, Bits, Bits) [function]

    syntax Int ::= Bool2Int(Bool) [function]

    rule Bool2Int(B:Bool) => #if B #then 1 #else 0 #fi

    rule icmp(Pred:Int, bits(X1:Int, _:Int):Bits, bits(X2:Int, _:Int):Bits) 
        => icmp(Pred, X1:Int, X2:Int)

    rule icmp(Pred:Int, A:Int, B:Int) => A >=Int B  requires Pred ==Int 9
    rule icmp(Pred:Int, A:Int, B:Int) => A >Int B   requires Pred ==Int 8
    rule icmp(Pred:Int, A:Int, B:Int) => A <=Int B  requires Pred ==Int 7
    rule icmp(Pred:Int, A:Int, B:Int) => A <Int B   requires Pred ==Int 6
    rule icmp(Pred:Int, A:Int, B:Int) => A >=Int B  requires Pred ==Int 5
    rule icmp(Pred:Int, A:Int, B:Int) => A >Int B   requires Pred ==Int 4
    rule icmp(Pred:Int, A:Int, B:Int) => A <Int B   requires Pred ==Int 3
    rule icmp(Pred:Int, A:Int, B:Int) => A =/=Int B requires Pred ==Int 2
    rule icmp(Pred:Int, A:Int, B:Int) => A =/=Int B requires Pred ==Int 1
    rule icmp(Pred:Int, A:Int, B:Int) => A ==Int B  requires Pred ==Int 0

    // syntax BitsVec ::= ValueList2BitsVec(ValueList) [function]
    // rule ValueList2BitsVec(V:Value, Vs:ValueList) => {V}:>Bits, ValueList2BitsVec(Vs)
    // rule ValueList2BitsVec(.ValueList) => .BitsVec

    // comb.add
    rule <k> circt </k>
        <circt-exec> 
            "comb.add" (As:ValueIdList) {_:Map} : (_Ts:Types) -> (T2:Type) 
            => ListItem( TV(T2, Bits2Int(BitsAdd(lookupValuesAsBitsVec(As)))) )
            ...
        </circt-exec>
    
    // comb.and
    rule <circt-exec> 
            "comb.and" (As:ValueIdList) {_:Map} : (_Ts:Types) -> (T2:Type)
            => ListItem( TV(T2, Bits2Int(BitsAnd(lookupValuesAsBitsVec(As)))) )
            ...
        </circt-exec>

    // comb.or
    rule <circt-exec> 
            "comb.or" (As:ValueIdList) {_:Map} : (_Ts:Types) -> (T2:Type) 
            => ListItem( TV(T2, Bits2Int(BitsOr(lookupValuesAsBitsVec(As)))) )
            ...
        </circt-exec>
    
    // comb.xor
    rule <circt-exec> 
            "comb.xor" (As:ValueIdList) {_:Map} : (_Ts:Types) -> (T2:Type)
            => ListItem( TV(T2, Bits2Int(BitsXor(lookupValuesAsBitsVec(As)))) )
            ...
        </circt-exec>
    
    // comb.mul
    rule <circt-exec> 
            "comb.mul" (As:ValueIdList) { _:Map } : (_Ts:Types) -> (T2:Type) 
            => ListItem( TV(T2, Bits2Int(BitsMul(lookupValuesAsBitsVec(As)))) )
            ...
        </circt-exec>
        
    // comb.extract
    rule <circt-exec> 
            "comb.extract" (A:ValueId) {_:Map} : (_T:Type) -> (T2:Type)
            => ListItem( TV(
                T2, 
                Bits2Int(bitsCast(lookupValueAsBits(A), getWidth(T2)))
            ) )
            ...
        </circt-exec>

    // comb.replicate
    rule <circt-exec> 
            "comb.replicate" (A:ValueId) {_:Map} : (T:Type) -> (T2:Type)
            => ListItem( TV(
                T2,
                Bits2Int(BitsDup(
                    bitsCast(lookupValueAsBits(A), getWidth(T)),
                    getWidth(T2) divInt getWidth(T)
                ))
            ) )
            ...
        </circt-exec>

    // comb.shrs
    rule <circt-exec> 
            "comb.shrs" ( A0:ValueId, A1:ValueId ) {_:Map} : ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(
                T2, Bits2Int(
                    bits(V0, getWidth(T0)) >>Bits bits(V1, getWidth(T1))
                )
            ) )
            ...
        </circt-exec>
        <circt-locals> 
            ...
            A0 |-> TV(T0, V0)
            A1 |-> TV(T1, V1)
            ... 
        </circt-locals>
    
    // comb.shru
    rule <circt-exec> 
            "comb.shru" ( A0:ValueId, A1:ValueId ) {_:Map}: ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(
                T2, 
                Bits2Int( bits(V0, getWidth(T0)) >>>Bits bits(V1, getWidth(T1)) )
            ) )
            ...
        </circt-exec>
        <circt-locals> 
            ...
            A0 |-> TV(T0, V0)
            A1 |-> TV(T1, V1)
            ... 
        </circt-locals>
    
    // comb.shl
    rule <circt-exec> 
            "comb.shl" ( A0:ValueId, A1:ValueId ) {_:Map}: ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(
                T2, Bits2Int(
                    bits(V0, getWidth(T0)) <<Bits bits(V1, getWidth(T1))
                )
            ) )
            ...
        </circt-exec>
        <circt-locals> 
            ...
            A0 |-> TV(T0, V0)
            A1 |-> TV(T1, V1)
            ... 
        </circt-locals>
    
    // comb.concat
    rule <circt-exec> 
            "comb.concat" ( As:ValueIdList ) { _:Map } : ( _Ts:Types ) -> ( T2:Type )
            => ListItem( TV(T2, Bits2Int(BitsConcat(lookupValuesAsBitsVec(As)))) )
            ...
        </circt-exec>

    // comb.divs
    rule <circt-exec> 
            "comb.divs" ( A0:ValueId, A1:ValueId ) {_:Map} : ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(
                T2, 
                Bits2Int(bitsCast(
                    bits(V0, getWidth(T0)) divsBits bits(V1, getWidth(T1)),
                    getWidth(T2)
                ))
            ) )
            ...
        </circt-exec>
        <circt-locals> 
            ...
            A0 |-> TV(T0, V0)
            A1 |-> TV(T1, V1)
            ... 
        </circt-locals>
    
    // comb.divu
    rule <circt-exec> 
            "comb.divu" ( A0:ValueId, A1:ValueId ) {_:Map} : ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(
                T2, 
                Bits2Int(bitsCast(
                    bits(V0, getWidth(T0)) divuBits bits(V1, getWidth(T1)),
                    getWidth(T2)
                ))
            ) )
            ...
        </circt-exec>
        <circt-locals>
            ...
            A0 |-> TV(T0, V0)
            A1 |-> TV(T1, V1)
            ... 
        </circt-locals>
    
    // comb.mods
    rule <circt-exec>
            "comb.mods" ( A0:ValueId, A1:ValueId ) { _:Map } : ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(T2, Bits2Int(bitsCast(
                bits(V0, getWidth(T0)) modsBits bits(V1, getWidth(T1)),
                getWidth(T2)
            ))) )
            ...
        </circt-exec>
        <circt-locals> 
            ...
            A0 |-> TV(T0, V0)
            A1 |-> TV(T1, V1)
            ... 
        </circt-locals>

    // comb.modu
    rule <circt-exec>
            "comb.modu" ( A0:ValueId, A1:ValueId ) { _:Map } : ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(T2, Bits2Int(bitsCast(
                bits(V0, getWidth(T0)) moduBits bits(V1, getWidth(T1)),
                getWidth(T2)
            ))) )
            ...
        </circt-exec>
        <circt-locals> 
            ...
            A0 |-> TV(T0, V0)
            A1 |-> TV(T1, V1)
            ... 
        </circt-locals>

    // comb.sub
    rule <circt-exec>
            "comb.sub" ( A0:ValueId, A1:ValueId ) { _:Map } : ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(T2, Bits2Int(bitsCast(
                bits(V0, getWidth(T0)) -Bits bits(V1, getWidth(T1)),
                getWidth(T2)
            ))) )
            ...
        </circt-exec>
        <circt-locals> 
            ...
            A0 |-> TV(T0, V0)
            A1 |-> TV(T1, V1)
            ... 
        </circt-locals>
    
    // comb.parity
    rule <circt-exec>
            "comb.parity" ( A:ValueId ) { _:Map } : ( _T:Type ) -> ( T2:Type )
            => ListItem(TV(
                T2, 
                BitsParity(lookupValueAsBits(A))
            ) )
            ...
        </circt-exec>
    
    // comb.mux
    rule <circt-exec>
            (.K => .List)
            ~> "comb.mux" ( _:ValueId, _:ValueId, _:ValueId ) { _:Map } : ( _:Type, _:Type, _:Type ) -> ( _:Type )
            ...
        </circt-exec>
    
    rule <circt-exec>
            (L:List => L ListItem( TV(T, V) ))
            ~> "comb.mux" ( A:ValueId, As:ValueIdList => As ) { _:Map } : ( T:Type, Ts:Types => Ts ) -> ( _:Type )
            ...
        </circt-exec>
        <circt-locals> ... A |-> TV(T, V) ... </circt-locals>

    rule <circt-exec>
            ListItem( TV(_T0, V0) ) ListItem( TV(T, V1) ) ListItem( TV(T, V2) )
            ~> "comb.mux" ( .ValueIdList ) { _:Map } : ( .Types ) -> ( T:Type )
            => ListItem( TV(T, {#if V0 =/=Int 0 #then V1 #else V2 #fi}:>Value) )
            ...
        </circt-exec>

    // comb.icmp
    rule <circt-exec>
            "comb.icmp" ( A0:ValueId, A1:ValueId ) { M:Map } : ( _T0:Type, _T1:Type ) -> ( T2:Type ) 
            => ListItem( TV(T2, Bool2Int(
                icmp(
                    {getAttrValue(M, #token("predicate", "BareId"))}:>Int, 
                    lookupValueAsBits(A0), 
                    lookupValueAsBits(A1)
                )
            )) )
            ...
        </circt-exec>
endmodule