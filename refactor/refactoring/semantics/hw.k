requires "bits.k"

module HW
    imports CONFIGURATION
    imports CIRCT-SYNTAX
    imports BITS


   





    // // "hw.bitcast" ( %0 ) { .Map } : ( i64 ) -> ( !hw.array < 64x i1 > )
    // rule <k> circt </k>
    //     <circt-exec>
    //         "hw.bitcast" ( I:Var ) { .Map } : ( T1:Type ) -> ( T2:Type )
    //         => ListItem( TV(T2, HwBitcast(V, T1, T2)) )
    //         ...
    //     </circt-exec>
    //     <circt-locals>
    //         ...
    //         I |-> TV(T1, V)
    //         ...
    //     </circt-locals>


    // syntax Value ::= HwBitcast(Value, Type, Type) [function]
    // rule HwBitcast(X:Int, T1:IntegerType, (!hw.array< _:ArraySizePrefix T2:IntegerType>):HwArrayType) 
    //     => [ List2Values(IntSlice(X, 0, getWidth(T2), getWidth(T1))) ]
    
    // rule HwBitcast(X:Map, T1:HwStructType, T2:Type) => fromBits(toBits(X, T1), T2)
    
    // syntax Bits ::= toBits(Value, Type) [function]
    // rule toBits(M:Map, !hw.struct < F:BareId : T:Type, Fs:StructFields >)
    //     => toBits({M[F]}:>Value, T:Type) concatBits toBits(M:Map, !hw.struct < Fs >)
    // rule toBits(_:Map, !hw.struct < .StructFields>) => bits(0, 0)
    // rule toBits(X:Int, T:IntegerType) => Int2Bits(X, getWidth(T))

    // syntax Value ::= fromBits(Bits, Type) [function]
    // rule fromBits(X:Bits, T:IntegerType) => Bits2Int(bitsCast(X, getWidth(T)))


    syntax List ::= IntSlice(Int, Int, Int, Int) [function]
    
    rule IntSlice(X:Int, Offs:Int, Step:Int, W:Int) => IntSlice(2 ^Int W +Int X, Offs, Step, W)
        requires X <Int 0

    rule IntSlice(X:Int, Offs:Int, Step:Int, W:Int) 
        => ListItem(bitRangeInt(X, Offs, Step)) IntSlice(X, Offs +Int Step, Step, W)
        requires Offs <Int W andBool X >=Int 0
    
    rule IntSlice(_:Int, Offs:Int, _:Int, W:Int) => .List
        requires Offs >=Int W
    



    // hw.array_slice
    rule <k> circt </k>
        <circt-exec>
            "hw.array_slice" ( A:Var, I:Var ) { .Map } : ( T1:HwArrayType, T2:IntegerType ) -> ( T3:HwArrayType )
            => ListItem( TV(T3, HwArraySlice(X, LowIndex, LowIndex +Int HwArraySize(T3))) )
            ...
        </circt-exec>
        <circt-locals> ... A |-> TV(T1, X) I |-> TV(T2, LowIndex) ... </circt-locals>
    
    
    // hw.struct_create
    rule <k> circt </k>
        <circt-exec>
            (.K => .Map)
            ~> (.K => Fs)
            ~> "hw.struct_create" ( _:VarList ) { .Map } : ( _:Types ) -> ( !hw.struct < Fs:StructFields > )
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec>
            (M:Map => M [F <- V])
            ~> (F:BareId : T:Type, Fs:StructFields => Fs)
            ~> "hw.struct_create" ( (I:Var , Vs:VarList => Vs) ) { .Map } : ( (T:Type, Ts:Types => Ts) ) -> ( _:HwStructType )
            ...
        </circt-exec>
        <circt-locals> ... I |-> TV(T, V) ... </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            (
                M:Map
                ~> .StructFields
                ~> "hw.struct_create" ( .VarList ) { .Map } : ( .Types ) -> ( T:HwStructType )
            ) => ListItem( TV(T, M) )
            ...
        </circt-exec>


    // hw.struct_extract
    rule <k> circt </k>
        <circt-exec>
            "hw.struct_extract" ( A:Var ) { M:Map } : ( T1:HwStructType ) -> ( T2:Type )
            => ListItem(TV(
                T2,
                HwStructExtract(V, T1, {getAttrValue(M, #token("fieldIndex", "BareId"))}:>Int)
            ))
            ...
        </circt-exec>
        <circt-locals> ... A |-> TV(T1, V) ... </circt-locals>
    

    // hw.struct_inject
    rule <k> circt </k>
        <circt-exec>
            "hw.struct_inject" ( A1:Var, A2:Var ) { M:Map } : ( T1:HwStructType, T2:Type ) -> ( T1:HwStructType )
            => ListItem(TV(
                T1,
                HwStructInject(V1, V2, T1, {getAttrValue(M, #token("fieldIndex", "BareId"))}:>Int)
            ))
            ...
        </circt-exec>
        <circt-locals> ... A1 |-> TV(T1, V1) A2 |-> TV(T2, V2) ... </circt-locals>
    

    // hw.struct_explode
    rule <k> circt </k>
        <circt-exec>
            (.K => .List)
            ~> (.K => T)
            ~> (.K => V)
            ~> "hw.struct_explode" ( A:Var ) { _:Map } : ( T:HwStructType ) -> ( _:Types )
            ...
        </circt-exec>
        <circt-locals> ... A |-> TV(T, V) ... </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            (L:List => L ListItem(TV(T, {M[F]}:>Value)))
            ~> !hw.struct< (F:BareId : T:Type, Fs:StructFields => Fs) >
            ~> M:Map
            ~> "hw.struct_explode" ( _:Var ) { _:Map } : ( _:HwStructType ) -> ( T:Type, Ts:Types => Ts )
            ...
        </circt-exec>
        
    rule <k> circt </k>
        <circt-exec>
            _:List
            ~> (
                !hw.struct< .StructFields >
                ~> _:Map
                ~> "hw.struct_explode" ( _:Var ) { _:Map } : ( _:HwStructType ) -> ( .Types ) 
                => .K
            )
            ...
        </circt-exec>


    // hw.enum.constant
    rule <k> circt </k>
        <circt-exec>
            (.K => M[#token("field", "BareId")])
            ~> "hw.enum.constant" ( .VarList ) { M:Map } : ( .Types ) -> ( _:HwEnumType )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            ((#token("#hw.enum.field", "AttributeAlias") D:DialectTypeBody):DialectAttribute => D)
            ~> "hw.enum.constant" ( .VarList ) { _M:Map } : ( .Types ) -> ( _:HwEnumType )
            ...
        </circt-exec>

    // todo
    rule <k> circt </k>
        <circt-exec>
            (< X:BareId, _:DialectTypeContentsList >
            ~> "hw.enum.constant" ( .VarList ) { _:Map } : ( .Types ) -> ( T:HwEnumType ))
            => ListItem(TV(T, hw.enum(X, T)))
            ...
        </circt-exec>
    

    // hw.enum.cmp
    rule <k> circt </k>
        <circt-exec>
            "hw.enum.cmp" ( A1:Var, A2:Var ) { .Map } : ( T:HwEnumType, T:HwEnumType ) -> ( T1:IntegerType )
            => ListItem(TV(T1, #if V1 ==K V2 #then 0 #else 1 #fi))
            ...
        </circt-exec>
        <circt-locals>
            ...
            A1 |-> TV(T, hw.enum(V1:BareId , T))
            A2 |-> TV(T, hw.enum(V2:BareId , T))
            ...
        </circt-locals>


    // hw.union_extract
    rule <k> circt </k>
        <circt-exec>
            "hw.union_extract" ( A:Var ) { _:Map } : ( T1:HwUnionType ) -> ( T2:Type )
            =>  ListItem(TV(T2, HwUnionExtract(V, T2)))
            ...
        </circt-exec>
        <circt-locals> ... A |-> TV(T1, V) ... </circt-locals>


    // hw.union_create
    rule <k> circt </k>
        <circt-exec>
            "hw.union_create" ( A:Var ) { _:Map } : ( T1:Type ) -> ( T2:HwUnionType )
            =>  ListItem(TV(T2, V))
            ...
        </circt-exec>
        <circt-locals> ... A |-> TV(T1, V) ... </circt-locals>
endmodule