requires "../../circt/circt.k"

module COMB-SYNTAX
    imports CIRCT-SYNTAX

    syntax KmdCIRCT ::= "#CombAdd"
                      | "#CombAnd"
                      | "#CombOr"
                      | "#CombXor"
                      | "#CombMul"
                      | "#CombExtract"
                      | "#CombReplicate"
                      | "#CombShrs"
                      | "#CombShru "
                      | "#CombShl"
                      | "#CombConcat"
                      | "#CombDivs"
                      | "#CombDivu"
                      | "#CombMods"
                      | "#CombModu"
                      | "#CombSub"
                      | "#CombParity"
                      | "#CombMux"
                      | "#CombIcmp"
endmodule


module COMB-HELPER
    imports COMB-SYNTAX

    syntax Bool ::= icmp(Int, Int, Int) [function]
                  | icmp(Int, Bits, Bits) [function]

    rule icmp(Pred:Int, bits(X1:Int, _:Int):Bits, bits(X2:Int, _:Int):Bits) => icmp(Pred, X1:Int, X2:Int)
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


    syntax Int ::= Bool2Int(Bool) [function]
    rule Bool2Int(B:Bool) => #if B #then 1 #else 0 #fi

    // syntax BitsVec ::= lookupValuesAsBitsVec(VarList) [function]
    // syntax Bits ::= lookupValueAsBits(Var) [function]
    //               | lookupValueAsBits(Var, Type) [function]

    // rule [[ lookupValueAsBits(A:Var) => bits(V, getWidth(T)) ]]
    //     <circt-locals> ... A |-> TV(T, V) ... </circt-locals>
    
    // rule [[ lookupValueAsBits(A:Var, T:Type) => bits(V, getWidth(T)) ]]
    //     <circt-locals> ... A |-> TV(T, V) ... </circt-locals>

    // rule lookupValuesAsBitsVec(.VarList) => .BitsVec

    // rule [[ lookupValuesAsBitsVec(A:Var, As:VarList) 
    //     => bits(V, getWidth(T)), lookupValuesAsBitsVec(As) ]]
    //     <circt-locals> ... A |-> TV(T, V) ... </circt-locals>

    // rule <k> circt </k>
    //     <circt-exec> 
    //         do "lookupValuesAsBitsVec"
    //         ~> (V:Var, Vs:VarList => Vs):VarList
    //         ~> (T:Type, Ts:Types => Ts):Types
    //         ~> (L:List => L ListItem(bits({X}:>CirctInt, getWidth(T))))
    //         ...
    //     </circt-exec>
    //     <circt-locals> ... V |-> TV(T, X) ... </circt-locals>
    
    // rule <k> circt </k>
    //     <circt-exec> 
    //         do "lookupValuesAsBitsVec" ~> .VarList ~> .Types => .K
    //         ...
    //     </circt-exec>
endmodule


module COMB
    imports COMB-HELPER
    imports MAP

    // syntax Value ::= Bits
    // syntax Value ::= AttributeValue
    // syntax ValueList ::= List{Value, ","}

    // comb.add
    rule <k> 
            "comb.add" ( Vs:ValueIdList ) { _:Map } : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombAdd ... 
        </k>
    
    rule <k> TVs:StdValues ~> #CombAdd => BitsAdd(StdValues2BitsVec(TVs)) ... </k>
    
    // comb.and
    rule <k> 
            "comb.add" ( Vs:ValueIdList ) { _:Map } : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombAnd ... 
        </k>
    
    rule <k> TVs:StdValues ~> #CombAnd => BitsAnd(StdValues2BitsVec(TVs)) ... </k>

    // comb.or
    rule <k> 
            "comb.or" ( Vs:ValueIdList ) { _:Map } : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombOr ... 
        </k>
    
    rule <k> TVs:StdValues ~> #CombOr => BitsOr(StdValues2BitsVec(TVs)) ... </k>
    

    // comb.xor
    rule <k> 
            "comb.xor" ( Vs:ValueIdList ) { _:Map } : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombXor ... 
        </k>
    
    rule <k> TVs:StdValues ~> #CombXor => BitsXor(StdValues2BitsVec(TVs)) ... </k>

   
    // comb.mul
    rule <k> 
            "comb.mul" ( Vs:ValueIdList ) { _:Map } : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombMul ... 
        </k>
    
    rule <k> TVs:StdValues ~> #CombMul => BitsMul(StdValues2BitsVec(TVs)) ... </k>


    // comb.extract
    rule <k> 
            "comb.extract" (V:ValueId) {_:Map} : ( _:Types ) -> ( T:Type )
            => #KReadCurr A ~> T ~> #CombExtract
            ...
        </k>

    rule <k> TV:StdValue ~> T:Type ~> #CombExtract => bitsCast(StdValues2Bits(TV), getWidth(T)) ... </k>


    // comb.replicate
    rule <k> 
            "comb.replicate" ( V:ValueId ) {_:Map} : ( T1:Type ) -> ( T2:Type )
            => #KReadCurr V ~> T1, T2 ~> #CombReplicate ...
            ...
        </k>

    rule <k> TV:StdValue ~> T1:Type, T2:Type ~> #CombReplicate 
            => BitsDup(bitsCast(StdValues2Bits(TV), getWidth(T1)), getWidth(T2) divInt getWidth(T1))
            ... 
        </k>


    // comb.shrs
    rule <k> 
            "comb.shrs" ( Vs:ValueIdList ) {_:Map} : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombShrs ...
        </k>

    rule <k> V1:StdValue, V2:StdValue ~> #CombShrs 
            => StdValues2Bits(V1) >>Bits StdValues2Bits(V2)
            ... 
        </k>


    // comb.shru
    rule <k> 
            "comb.shru" ( Vs:ValueIdList ) {_:Map} : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombShru ...
        </k>

    rule <k> V1:StdValue, V2:StdValue ~> #CombShru 
            => StdValues2Bits(V1) >>>Bits StdValues2Bits(V2)
            ... 
        </k>

    
    // comb.shl
    rule <k> 
            "comb.shrs" ( Vs:ValueIdList ) {_:Map} : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombShl ...
        </k>

    rule <k> V1:StdValue, V2:StdValue ~> #CombShl 
            => StdValues2Bits(V1) <<Bits StdValues2Bits(V2)
            ... 
        </k>


    // comb.concat
    rule <k> 
            "comb.concat" ( Vs:VarList ) { _:Map } : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombConcat
            ...
        </k>

    rule <k> Vs:StdValues ~> #CombConcat => BitsConcat(StdValues2BitsVec(Vs)) ... </k>


    // comb.divs
    rule <k> 
            "comb.divs" ( Vs:ValueIdList ) {_:Map} : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombDivs ...
        </k>

    rule <k> V1:StdValue, V2:StdValue ~> #CombDivs 
            => StdValues2Bits(V1) divsBits StdValues2Bits(V2)
            ... 
        </k>

    
    // comb.divu
    rule <k> 
            "comb.divu" ( Vs:ValueIdList ) {_:Map} : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombDivu ...
        </k>

    rule <k> V1:StdValue, V2:StdValue ~> #CombDivu
            => StdValues2Bits(V1) divuBits StdValues2Bits(V2)
            ... 
        </k>


    // comb.mods
    rule <k> 
            "comb.mods" ( Vs:ValueIdList ) {_:Map} : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombMods ...
        </k>

    rule <k> V1:StdValue, V2:StdValue ~> #CombMods
            => StdValues2Bits(V1) modsBits StdValues2Bits(V2)
            ... 
        </k>
    

    // comb.modu
    rule <k> 
            "comb.modu" ( Vs:ValueIdList ) {_:Map} : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombModu ...
        </k>

    rule <k> V1:StdValue, V2:StdValue ~> #CombModu
            => StdValues2Bits(V1) moduBits StdValues2Bits(V2)
            ... 
        </k>


    // comb.sub
    rule <k> 
            "comb.sub" ( Vs:ValueIdList ) {_:Map} : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombSub ...
        </k>

    rule <k> V1:StdValue, V2:StdValue ~> #CombSub
            => StdValues2Bits(V1) -Bits StdValues2Bits(V2)
            ... 
        </k>

    
    // comb.parity
    rule <k> 
            "comb.parity" ( V:ValueId ) {_:Map} : ( _:Type ) -> ( _:Type )
            => #KReadCurr V ~> #CombParity ...
        </k>

    rule <k> V:StdValue ~> #CombParity => BitsParity(StdValues2Bits(V)) ... </k>



    // comb.mux
    rule <k> 
            "comb.mux" ( Vs:ValueIdList ) {_:Map} : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> #CombMux 
            ...
        </k>
    
    rule <k> V1:StdValue, V2:StdValue, V3:StdValue ~> #CombMux 
            => #if V1 =/=Int 0 #then V2 #else V3 #fi 
            ... 
        </k>



    // comb.icmp
    rule <k> 
            "comb.icmp" ( Vs:ValueIdList ) {M:Map} : ( _:Types ) -> ( _:Type )
            => #KReadCurr Vs ~> getAttrValue(M, #token("predicate", "BareId")) ~> #CombIcmp 
            ...
        </k>

    rule <k> V1:StdValue, V2:StdValue ~> Pred:Int ~> #CombIcmp 
            => icmp(Pred, StdValues2Bits(V1), StdValues2Bits(V2))
            ...
        </k>

    // --------------------- todo ----------------------
    
endmodule