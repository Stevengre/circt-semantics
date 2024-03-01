requires "bits.k"
// requires "circt-conf.k"

module COMB
    imports CIRCT-SYNTAX
    imports BITS
    imports MAP

    syntax Value ::= Bits
    // syntax Value ::= AttributeValue
    // syntax ValueList ::= List{Value, ","}
    syntax BitsVec ::= lookupValuesAsBitsVec(VarList) [function]
    syntax Bits ::= lookupValueAsBits(Var) [function]
                  | lookupValueAsBits(Var, Type) [function]

    rule [[ lookupValueAsBits(A:Var) => bits(V, getWidth(T)) ]]
        <circt-locals> ... A |-> TV(T, V) ... </circt-locals>
    
    rule [[ lookupValueAsBits(A:Var, T:Type) => bits(V, getWidth(T)) ]]
        <circt-locals> ... A |-> TV(T, V) ... </circt-locals>

    rule lookupValuesAsBitsVec(.VarList) => .BitsVec

    rule [[ lookupValuesAsBitsVec(A:Var, As:VarList) 
        => bits(V, getWidth(T)), lookupValuesAsBitsVec(As) ]]
        <circt-locals> ... A |-> TV(T, V) ... </circt-locals>
    
    // rule [[ lookupValuesAsBitsVec(A:Var, As:VarList) 
    //     => bits(0, 1), lookupValuesAsBitsVec(As) ]]
    //     <circt-locals> M:Map </circt-locals>
    // requires notBool A in_keys(M)

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
    // rule <k> circt </k>
    //     <circt-exec> 
    //         "comb.add" (As:VarList) {_:Map} : (_Ts:Types) -> (T2:Type) 
    //         => ListItem( TV(T2, Bits2Int(BitsAdd(lookupValuesAsBitsVec(As)))) )
    //         ...
    //     </circt-exec>

    rule <k> circt </k>
        <circt-exec> 
            do "lookupValuesAsBitsVec"
            ~> (V:Var, Vs:VarList => Vs):VarList
            ~> (T:Type, Ts:Types => Ts):Types
            ~> (L:List => L ListItem(bits({X}:>CirctInt, getWidth(T))))
            ...
        </circt-exec>
        <circt-locals> ... V |-> TV(T, X) ... </circt-locals>
    
    rule <k> circt </k>
        <circt-exec> 
            do "lookupValuesAsBitsVec" ~> .VarList ~> .Types => .K
            ...
        </circt-exec>
    
    // comb.add
    rule <k> circt </k>
        <circt-exec>
            (.K => do "lookupValuesAsBitsVec") ~>
            (.K => Vs) ~>
            (.K => Ts) ~>
            (.K => .List) ~>
            "comb.add" (Vs:VarList) {_:Map} : (Ts:Types) -> (_:Type)
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            L:List ~> "comb.add" (_:VarList) {_:Map} : (_:Types) -> (T:Type)
            => ListItem(TV(T, Bits2Int(BitsAdd(L))))
            ...
        </circt-exec>
    
    // comb.and
    rule <k> circt </k>
        <circt-exec>  
            "comb.and" (As:VarList) {_:Map} : (_Ts:Types) -> (T2:Type)
            => ListItem( TV(T2, Bits2Int(BitsAnd(lookupValuesAsBitsVec(As)))) )
            ...
        </circt-exec>

    // comb.or
    rule <k> circt </k>
        <circt-exec> 
            "comb.or" (As:VarList) {_:Map} : (_Ts:Types) -> (T2:Type) 
            => ListItem( TV(T2, Bits2Int(BitsOr(lookupValuesAsBitsVec(As)))) )
            ...
        </circt-exec>
    
    // comb.xor
    rule <k> circt </k>
        <circt-exec> 
            "comb.xor" (As:VarList) {_:Map} : (_Ts:Types) -> (T2:Type)
            => ListItem( TV(T2, Bits2Int(BitsXor(lookupValuesAsBitsVec(As)))) )
            ...
        </circt-exec>
    
    // comb.mul
    rule <k> circt </k>
        <circt-exec> 
            "comb.mul" (As:VarList) { _:Map } : (_Ts:Types) -> (T2:Type) 
            => ListItem( TV(T2, Bits2Int(BitsMul(lookupValuesAsBitsVec(As)))) )
            ...
        </circt-exec>
        
    // comb.extract
    rule <k> circt </k>
        <circt-exec> 
            "comb.extract" (A:Var) {_:Map} : (_T:Type) -> (T2:Type)
            => ListItem( TV(
                T2, 
                Bits2Int(bitsCast(lookupValueAsBits(A), getWidth(T2)))
            ) )
            ...
        </circt-exec>

    // comb.replicate
    rule <k> circt </k>
        <circt-exec> 
            "comb.replicate" (A:Var) {_:Map} : (T:Type) -> (T2:Type)
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
    rule <k> circt </k>
        <circt-exec> 
            "comb.shrs" ( A0:Var, A1:Var ) {_:Map} : ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(
                T2, Bits2Int(
                    bits({V0}:>CirctInt, getWidth(T0)) >>Bits bits({V1}:>CirctInt, getWidth(T1))
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
    rule <k> circt </k>
        <circt-exec> 
            "comb.shru" ( A0:Var, A1:Var ) {_:Map}: ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(
                T2, 
                Bits2Int( bits({V0}:>CirctInt, getWidth(T0)) >>>Bits bits({V1}:>CirctInt, getWidth(T1)) )
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
    rule <k> circt </k>
        <circt-exec> 
            "comb.shl" ( A0:Var, A1:Var ) {_:Map}: ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(
                T2, Bits2Int(
                    bits({V0}:>CirctInt, getWidth(T0)) <<Bits bits({V1}:>CirctInt, getWidth(T1))
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
    rule <k> circt </k>
        <circt-exec> 
            "comb.concat" ( As:VarList ) { _:Map } : ( _Ts:Types ) -> ( T2:Type )
            => ListItem( TV(T2, Bits2Int(BitsConcat(lookupValuesAsBitsVec(As)))) )
            ...
        </circt-exec>

    // comb.divs
    rule <k> circt </k>
        <circt-exec> 
            "comb.divs" ( A0:Var, A1:Var ) {_:Map} : ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(
                T2, 
                Bits2Int(bitsCast(
                    bits({V0}:>CirctInt, getWidth(T0)) divsBits bits({V1}:>CirctInt, getWidth(T1)),
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
    rule <k> circt </k>
        <circt-exec> 
            "comb.divu" ( A0:Var, A1:Var ) {_:Map} : ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(
                T2, 
                Bits2Int(bitsCast(
                    bits({V0}:>CirctInt, getWidth(T0)) divuBits bits({V1}:>CirctInt, getWidth(T1)),
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
    rule <k> circt </k>
        <circt-exec>
            "comb.mods" ( A0:Var, A1:Var ) { _:Map } : ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(T2, Bits2Int(bitsCast(
                bits({V0}:>CirctInt, getWidth(T0)) modsBits bits({V1}:>CirctInt, getWidth(T1)),
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

    rule <k> circt </k>
        <circt-exec>
            "comb.modu" ( A0:Var, A1:Var ) { _:Map } : ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(T2, Bits2Int(bitsCast(
                bits({V0}:>CirctInt, getWidth(T0)) moduBits bits({V1}:>CirctInt, getWidth(T1)),
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
    rule <k> circt </k>
        <circt-exec>
            "comb.sub" ( A0:Var, A1:Var ) { _:Map } : ( T0:Type, T1:Type ) -> ( T2:Type )
            => ListItem( TV(T2, Bits2Int(bitsCast(
                bits({V0}:>CirctInt, getWidth(T0)) -Bits bits({V1}:>CirctInt, getWidth(T1)),
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
            "comb.parity" ( A:Var ) { _:Map } : ( _:Type ) -> ( T2:Type )
            => ListItem(TV(
                T2, 
                BitsParity(lookupValueAsBits(A))
            ) )
            ...
        </circt-exec>
    
    // comb.mux
    rule <circt-exec>
            (.K => .List)
            ~> "comb.mux" ( _:Var, _:Var, _:Var ) { _:Map } : ( _:Type, _:Type, _:Type ) -> ( _:Type )
            ...
        </circt-exec>
    
    rule <circt-exec>
            (L:List => L ListItem( TV(T, V) ))
            ~> "comb.mux" ( A:Var, As:VarList => As ) { _:Map } : ( T:Type, Ts:Types => Ts ) -> ( _:Type )
            ...
        </circt-exec>
        <circt-locals> ... A |-> TV(T, V) ... </circt-locals>

    rule <circt-exec>
            ListItem( TV(_T0, V0) ) ListItem( TV(T, V1) ) ListItem( TV(T, V2) )
            ~> "comb.mux" ( .VarList ) { _:Map } : ( .Types ) -> ( T:Type )
            => ListItem( TV(T, {#if V0 =/=Int 0 #then V1 #else V2 #fi}:>Value) )
            ...
        </circt-exec>

    // comb.icmp
    rule <circt-exec>
            "comb.icmp" ( A0:Var, A1:Var ) { M:Map } : ( _T0:Type, _T1:Type ) -> ( T2:Type ) 
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