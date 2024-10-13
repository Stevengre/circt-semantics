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

    rule icmp(Pred:Int, bits(X1:Int, _:Int), bits(X2:Int, _:Int)) => icmp(Pred, X1:Int, X2:Int)
    rule icmp(Pred:Int, bits(_:XZ, _:Int),   bits(_, _:Int))    => false
    rule icmp(Pred:Int, bits(X1:Int, _:Int), bits(_:XZ, _:Int)) => false

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

    rule <k> L:List ~> #CombAdd ~> T:Type => BitsAdd(ListStdValue2Bits(L)) : T ... </k>
    rule <k> L:List ~> #CombAnd ~> T:Type => BitsAnd(ListStdValue2Bits(L)) : T ... </k>
    rule <k> L:List ~> #CombOr  ~> T:Type => BitsOr (ListStdValue2Bits(L)) : T ... </k>
    rule <k> L:List ~> #CombXor ~> T:Type => BitsXor(ListStdValue2Bits(L)) : T ... </k>
    rule <k> L:List ~> #CombMul ~> T:Type => BitsMul(ListStdValue2Bits(L)) : T ... </k>

    rule <k> L:List ~> #CombConcat ~> T:Type => BitsConcat(ListStdValue2Bits(L)) : T ... </k>

    rule <k> L:List ~> #CombDivs ~> T:Type => BitsDivs(ListStdValue2Bits(L)) : T ... </k>
    rule <k> L:List ~> #CombDivu ~> T:Type => BitsDivu(ListStdValue2Bits(L)) : T ... </k>
    rule <k> L:List ~> #CombShrs ~> T:Type => BitsShrs(ListStdValue2Bits(L)) : T ... </k>
    rule <k> L:List ~> #CombShru ~> T:Type => BitsShru(ListStdValue2Bits(L)) : T ... </k>
    rule <k> L:List ~> #CombShl  ~> T:Type => BitsShl (ListStdValue2Bits(L)) : T ... </k>
    rule <k> L:List ~> #CombSub  ~> T:Type => BitsSub (ListStdValue2Bits(L)) : T ... </k>
    
    rule <k> V:StdValue ~> #CombParity ~> T:Type => BitsParity(StdValues2Bits(V)) : T ... </k>
    rule <k> V:StdValue ~> #CombExtract ~> T:Type => bitsCast(StdValues2Bits(V), getWidth(T)) : T ... </k>

    rule <k> ListItem(V1:StdValue) ListItem(V2:StdValue) ListItem(V3:StdValue) ~> #CombMux
            => #if notBool isZero(V1) #then V2 #else V3 #fi
            ... 
        </k>

    rule <k> ListItem(V1:StdValue) ListItem(V2:StdValue) ~> Pred:Int ~> #CombIcmp 
            => bits(Bool2Int(icmp(Pred, StdValues2Bits(V1), StdValues2Bits(V2))), 1) : i1
            ...
        </k>

    rule <k> ListItem(B1:Bits : _:Type) ListItem(B2:Bits : _:Type) 
            ~> Pred:Int : _:IntegerType ~> #CombIcmp 
            => bits(Bool2Int(icmp(Pred, B1, B2)), 1) : i1
            ...
        </k>

    rule <k> V:StdValue ~> #CombReplicate ~> ListItem(T1:Type) ListItem(T2:Type)
            => BitsDup(bitsCast(StdValues2Bits(V), getWidth(T1)), getWidth(T2) divInt getWidth(T1)) : T2
            ... 
        </k>


    // comb.add
    rule <k> "comb.add" (VL:ValueIdList)         : (_:Types) -> (T:Type) => VL ~> #CombAdd ~> T ... </k>
    rule <k> "comb.add" (VL:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => VL ~> #CombAdd ~> T ... </k>

    // comb.and
    rule <k> "comb.and" (VL:ValueIdList)         : (_:Types) -> (T:Type) => VL ~> #CombAnd ~> T ... </k>
    rule <k> "comb.and" (VL:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => VL ~> #CombAnd ~> T ... </k>

    // comb.or
    rule <k> "comb.or" (VL:ValueIdList)         : (_:Types) -> (T:Type) => VL ~> #CombOr ~> T ... </k>
    rule <k> "comb.or" (VL:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => VL ~> #CombOr ~> T ... </k>
    
    // comb.xor
    rule <k> "comb.xor" (VL:ValueIdList)         : (_:Types) -> (T:Type) => VL ~> #CombXor ~> T ... </k>
    rule <k> "comb.xor" (VL:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => VL ~> #CombXor ~> T ... </k>
       
    // comb.mul
    rule <k> "comb.mul" (VL:ValueIdList)         : (_:Types) -> (T:Type) => VL ~> #CombMul ~> T ... </k>
    rule <k> "comb.mul" (VL:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => VL ~> #CombMul ~> T ... </k>
    
    // comb.extract
    rule <k> "comb.extract" (V:ValueId)         : (_:Types) -> (T:Type) => V ~> #CombExtract ~> T ... </k>
    rule <k> "comb.extract" (V:ValueId) {_:Map} : (_:Types) -> (T:Type) => V ~> #CombExtract ~> T ... </k>


    // comb.replicate
    rule <k> 
            "comb.replicate" ( V:ValueId ) : ( T1:Type ) -> ( T2:Type )
            => V ~> #CombReplicate ~> ListItem(T1) ListItem(T2)
            ...
        </k>
    
    rule <k> 
            "comb.replicate" ( V:ValueId ) { _:Map } : ( T1:Type ) -> ( T2:Type )
            => V ~> #CombReplicate ~> ListItem(T1) ListItem(T2)
            ...
        </k>


    // comb.shrs
    rule <k> "comb.shrs" (Vs:ValueIdList)         : (_:Types) -> (T:Type) => Vs ~> #CombShrs ~> T ... </k>
    rule <k> "comb.shrs" (Vs:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => Vs ~> #CombShrs ~> T ... </k>

    // comb.shru
    rule <k> "comb.shru" (Vs:ValueIdList)         : (_:Types) -> (T:Type) => Vs ~> #CombShru ~> T ... </k>
    rule <k> "comb.shru" (Vs:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => Vs ~> #CombShru ~> T ... </k>

    // comb.shl
    rule <k> "comb.shl" (Vs:ValueIdList)         : (_:Types) -> (T:Type) => Vs ~> #CombShl ~> T ... </k>
    rule <k> "comb.shl" (Vs:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => Vs ~> #CombShl ~> T ... </k>

    // comb.concat
    rule <k> "comb.concat" (Vs:ValueIdList)         : (_:Types) -> (T:Type) => Vs ~> #CombConcat ~> T ... </k>
    rule <k> "comb.concat" (Vs:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => Vs ~> #CombConcat ~> T ... </k>

    // comb.divs
    rule <k> "comb.divs" (Vs:ValueIdList)         : (_:Types) -> (T:Type) => Vs ~> #CombDivs ~> T ... </k>
    rule <k> "comb.divs" (Vs:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => Vs ~> #CombDivs ~> T ... </k>

    // comb.divu
    rule <k> "comb.divu" (Vs:ValueIdList)         : (_:Types) -> (T:Type) => Vs ~> #CombDivu ~> T ... </k>
    rule <k> "comb.divu" (Vs:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => Vs ~> #CombDivu ~> T ... </k>

    // comb.mods
    rule <k> "comb.mods" (Vs:ValueIdList)         : (_:Types) -> (T:Type) => Vs ~> #CombMods ~> T ... </k>
    rule <k> "comb.mods" (Vs:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => Vs ~> #CombMods ~> T ... </k>

    // comb.modu
    rule <k> "comb.modu" (Vs:ValueIdList)         : (_:Types) -> (T:Type) => Vs ~> #CombModu ~> T ... </k>
    rule <k> "comb.modu" (Vs:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => Vs ~> #CombModu ~> T ... </k>

    // comb.sub
    rule <k> "comb.sub" (Vs:ValueIdList)         : (_:Types) -> (T:Type) => Vs ~> #CombSub ~> T ... </k>
    rule <k> "comb.sub" (Vs:ValueIdList) {_:Map} : (_:Types) -> (T:Type) => Vs ~> #CombSub ~> T ... </k>

    // comb.parity
    rule <k> "comb.parity" (V:ValueId)         : (_:Type) -> (T:Type) => V ~> #CombParity ~> T ... </k>
    rule <k> "comb.parity" (V:ValueId) {_:Map} : (_:Type) -> (T:Type) => V ~> #CombParity ~> T ... </k>

    // comb.mux
    rule <k> "comb.mux" (Vs:ValueIdList)         : (_:Types) -> (_:Type) => Vs ~> #CombMux ... </k>
    rule <k> "comb.mux" (Vs:ValueIdList) {_:Map} : (_:Types) -> (_:Type) => Vs ~> #CombMux ... </k>
    
    // comb.icmp
    rule <k> 
            "comb.icmp" ( Vs:ValueIdList ) {M:Map} : ( _:Types ) -> ( _:Type )
            => Vs ~> M["predicate"] ~> #CombIcmp 
            ...
        </k>

    // --------------------- todo ----------------------
    
endmodule
