requires "bits.k"

module HW
    imports CONFIGURATION
    imports CIRCT-SYNTAX
    imports BITS

    // hw.wire, how to express observablility
    rule <k> circt </k>
        <circt-exec> 
            "hw.wire" (I:ValueId) {_:Map} : (T:Type) -> (T:Type)
            => ListItem( TV(T, V) )
            ...
        </circt-exec>
        <circt-locals> ... I |-> TV(T, V) ... </circt-locals>

    // hw.output
    rule <k> circt </k>
        <circt-exec>
            (.K => L)
            ~> "hw.output" ( _:ValueIdList ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
        <ports> L:List </ports>
    
    rule <k> circt </k>
        <circt-exec>
            (ListItem(input _:BareId : _:Type) L:List => L)
            ~> "hw.output" ( _Is:ValueIdList ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (ListItem(output Name:BareId : _:Type) L:List => L)
            ~> "hw.output" ( I:ValueId, Is:ValueIdList => Is ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
        <circt-output> Out:List => Out ListItem(result(Name, {Locals[I]}:>TypeValue)) </circt-output>
        <circt-locals> Locals:Map </circt-locals>
        requires I in_keys(Locals)
    
    rule <k> circt </k>
        <circt-exec>
            .List ~> "hw.output" ( .ValueIdList ) {_:Map} : ( _:Types ) -> ( .Types ) => .List
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec> 
            "hw.constant" ( .ValueIdList ) { M:Map } : ( .Types ) -> ( T:Type , .Types )
            => ListItem( TV(T, getAttrValue(M, #token("value", "BareId"))) )
            ...
        </circt-exec>

    // todo
    rule <k> circt </k>
        <circt-exec> 
            (.K => .List) 
            ~> "hw.instance" ( _Is:ValueIdList ) { _M:Map } : _:FunctionType
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (L:List => L ListItem(V)) 
            ~> "hw.instance" ( (I:ValueId, Is:ValueIdList => Is) ) { _M:Map } : _:FunctionType
            ...
        </circt-exec>
        <circt-locals> ... I |-> TV(_:Type, V:Value) ... </circt-locals>
    
    rule <k> circt </k>
        <circt-exec> 
            (.K => .Values)
            ~> _:List
            ~> "hw.instance" ( .ValueIdList ) { _:Map } : _:FunctionType
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (Vs:Values => V, Vs)
            ~> (L:List ListItem(V:Value) => L)
            ~> "hw.instance" ( .ValueIdList ) { _:Map } : _:FunctionType
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            _:Values
            ~> (.List => .K)
            ~> "hw.instance" ( .ValueIdList ) { _:Map } : _:FunctionType
            ...
        </circt-exec>

    // hw.instance, new frame
    rule <k> circt </k>
        <symbol-table> M:Map </symbol-table>
        <circt>
            ...
            <circt-frames>
                (
                    .Bag =>
                    <circt-frame>
                        ...
                        <circt-exec> 
                            Vs ~> M [ SymbolRefId2String(
                                {Attr[#token("moduleName", "BareId")] orDefault #token("@_", "SymbolRefId")}:>SymbolRefId
                            ) ] orDefault (stop "no such module")
                        </circt-exec>
                        ...
                    </circt-frame>
                )
                <circt-frame>
                    ...
                    <circt-exec> 
                        Vs:Values ~> "hw.instance" ( .ValueIdList ) { Attr:Map } : _:FunctionType
                        ...
                    </circt-exec>
                    ...
                </circt-frame>
                ...
            </circt-frames>
            ...
        </circt>
    
    // hw.instance finish, clear frame
    rule <k> circt </k>
        <circt>
            ...
            <circt-frames>
                (
                    <circt-frame>
                        ...
                        <circt-exec> .K </circt-exec>
                        <circt-output> Out:List </circt-output>
                        ...
                    </circt-frame>
                    => .Bag
                )
                <circt-frame>
                    ...
                    <circt-exec>
                        (.K => .List)
                        ~> (.K => Out)
                        ~> _:Values 
                        ~> "hw.instance" ( .ValueIdList ) { _:Map } : _:FunctionType
                        ...
                    </circt-exec>
                    ...
                </circt-frame>
                ...
            </circt-frames>
            ...
        </circt>

    rule <k> circt </k>
        <circt-exec>
            (L1:List => L1 ListItem(V))
            ~> (ListItem(result(_:BareId, V:TypeValue)) L2:List => L2)
            ~> _:Values 
            ~> "hw.instance" ( .ValueIdList ) { _:Map } : _:FunctionType
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            _:List
            ~> (.List ~> _:Values ~> "hw.instance" ( .ValueIdList ) { _:Map } : _:FunctionType => .K)
            ...
        </circt-exec>

    // all done
    rule <k> circt => done </k>
        <circt-frames>
            (
                <circt-frame>
                    ...
                    <circt-exec> .K </circt-exec>
                    <circt-output> Out:List </circt-output>
                    ...
                </circt-frame>
                => .Bag
            )
        </circt-frames>
        <result> L:List => L ListItem(Out) </result>
    

    // hw.aggregate_constant
    // todo
    rule <k> circt </k>
        <circt-exec> 
            "hw.aggregate_constant" ( .ValueIdList ) { M:Map } : ( .Types ) -> ( T:Type )
            => ListItem( TV(T, getAttrValue(M, #token("fields", "BareId"))) )
            ...
        </circt-exec>
    
    // hw.array_get
    rule <k> circt </k>
        <circt-exec>
            "hw.array_get" ( A:ValueId , I:ValueId ) { _:Map } : ( _:Types ) -> ( T:Type )
            => ListItem( TV(T, HwArrayGet(Arr, Idx)) )
            ...
        </circt-exec>
        <circt-locals>
            ...
            A |-> TV(_, Arr:HwArray)
            I |-> TV(_, Idx:Int)
            ...
        </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            ( .K => .List ) 
            ~> ( 
                "hw.array_create" ( VL:ValueIdList ) { _:Map } : FT:FunctionType
                => "hw.array_create" ( VL ) : FT
            )
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec>
            ( L:List => L ListItem(V) ) 
            ~> "hw.array_create" ( (I:ValueId, Is:ValueIdList => Is) ) : ( _:Types ) -> ( _:Type )
            ...
        </circt-exec>
        <circt-locals>
            ...
            I |-> TV(_, V:Value)
            ...
        </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            ( .K => .Values )
            ~> _:List
            ~> "hw.array_create" ( .ValueIdList ) : ( _:Types ) -> ( _:Type )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            ( Vs:Values => V, Vs )
            ~> ( ListItem(V:Value) L:List => L )
            ~> "hw.array_create" ( .ValueIdList ) : ( _:Types ) -> ( _:Type )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            ( Vs:Values ~> .List ~> "hw.array_create" ( .ValueIdList ) : ( _:Types ) -> ( T:Type ) )
            => ListItem( TV(T, [ Vs ]) )
            ...
        </circt-exec>

    // "hw.bitcast" ( %0 , .ValueIdList ) { .Map } : ( i64 , .Types ) -> ( !hw.array < 64x i1 > , .Types )
    rule <k> circt </k>
        <circt-exec>
            "hw.bitcast" ( I:ValueId ) { .Map } : ( T1:Type ) -> ( T2:Type )
            => ListItem( TV(T2, HwBitcast(V, T1, T2)) )
            ...
        </circt-exec>
        <circt-locals>
            ...
            I |-> TV(T1, V)
            ...
        </circt-locals>

    syntax Value ::= HwBitcast(Value, Type, Type) [function]
    rule HwBitcast(X:Int, T1:IntegerType, (!hw.array< _:HwArraySizePrefix T2:IntegerType>):HwArrayType) 
        => [ List2Values(IntSlice(X, 0, getWidth(T2), getWidth(T1))) ]
    
    rule HwBitcast(X:Map, T1:HwStructType, T2:Type) => fromBits(toBits(X, T1), T2)
    
    syntax Bits ::= toBits(Value, Type) [function]
    rule toBits(M:Map, !hw.struct < F:BareId : T:Type, Fs:HwStructFields >)
        => toBits({M[F]}:>Value, T:Type) concatBits toBits(M:Map, !hw.struct < Fs >)
    rule toBits(_:Map, !hw.struct < .HwStructFields>) => bits(0, 0)
    rule toBits(X:Int, T:IntegerType) => Int2Bits(X, getWidth(T))

    syntax Value ::= fromBits(Bits, Type) [function]
    rule fromBits(X:Bits, T:IntegerType) => Bits2Int(bitsCast(X, getWidth(T)))


    syntax List ::= IntSlice(Int, Int, Int, Int) [function]
    
    rule IntSlice(X:Int, Offs:Int, Step:Int, W:Int) => IntSlice(2 ^Int W +Int X, Offs, Step, W)
        requires X <Int 0

    rule IntSlice(X:Int, Offs:Int, Step:Int, W:Int) 
        => ListItem(bitRangeInt(X, Offs, Step)) IntSlice(X, Offs +Int Step, Step, W)
        requires Offs <Int W andBool X >=Int 0
    
    rule IntSlice(_:Int, Offs:Int, _:Int, W:Int) => .List
        requires Offs >=Int W
    

    // "hw.array_concat" ( %4 , %3 , .ValueIdList ) { .Map } : ( !hw.array < 8x i1 > , !hw.array < 64x i1 > , .Types ) -> ( !hw.array < 72x i1 > , .Types )
    rule <k> circt </k>
        <circt-exec>
            (.K => .List)
            ~> "hw.array_concat" ( _:ValueIdList ) { .Map } : ( _:Types ) -> ( _:Type )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (L:List => L ListItem(V))
            ~> "hw.array_concat" ( (I:ValueId, Is:ValueIdList => Is) ) { .Map } : ( (T:Type, Ts:Types => Ts) ) -> ( _:Type )
            ...
        </circt-exec>
        <circt-locals>
            ...
            I |-> TV(T, V)
            ...
        </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            _:List
            ~> (.K => .List)
            ~> "hw.array_concat" ( .ValueIdList ) { .Map } : ( .Types ) -> ( _:Type )
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec>
            (ListItem([Vs:Values]) L1:List => L1)
            ~> (L:List => L Values2List(Vs))
            ~> "hw.array_concat" ( .ValueIdList ) { .Map } : ( .Types ) -> ( _:Type )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (
                .List ~> L:List 
                ~> "hw.array_concat" ( .ValueIdList ) { .Map } : ( .Types ) -> ( T:HwArrayType )
            )
            => ListItem( TV(T, [ List2Values(L) ]) )
            ...
        </circt-exec>

    // hw.array_slice
    rule <k> circt </k>
        <circt-exec>
            "hw.array_slice" ( A:ValueId, I:ValueId ) { .Map } : ( T1:HwArrayType, T2:IntegerType ) -> ( T3:HwArrayType )
            => ListItem( TV(T3, HwArraySlice(X, LowIndex, LowIndex +Int HwArraySize(T3))) )
            ...
        </circt-exec>
        <circt-locals> ... A |-> TV(T1, X) I |-> TV(T2, LowIndex) ... </circt-locals>
    
    
    // hw.struct_create
    rule <k> circt </k>
        <circt-exec>
            (.K => .Map)
            ~> (.K => Fs)
            ~> "hw.struct_create" ( _:ValueIdList ) { .Map } : ( _:Types ) -> ( !hw.struct < Fs:HwStructFields > )
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec>
            (M:Map => M [F <- V])
            ~> (F:BareId : T:Type, Fs:HwStructFields => Fs)
            ~> "hw.struct_create" ( (I:ValueId , Vs:ValueIdList => Vs) ) { .Map } : ( (T:Type, Ts:Types => Ts) ) -> ( _:HwStructType )
            ...
        </circt-exec>
        <circt-locals> ... I |-> TV(T, V) ... </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            (
                M:Map
                ~> .HwStructFields
                ~> "hw.struct_create" ( .ValueIdList ) { .Map } : ( .Types ) -> ( T:HwStructType )
            ) => ListItem( TV(T, M) )
            ...
        </circt-exec>

    // hw.struct_extract
    rule <k> circt </k>
        <circt-exec>
            "hw.struct_extract" ( A:ValueId ) { M:Map } : ( T1:HwStructType ) -> ( T2:Type )
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
            "hw.struct_inject" ( A1:ValueId, A2:ValueId ) { M:Map } : ( T1:HwStructType, T2:Type ) -> ( T1:HwStructType )
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
            ~> "hw.struct_explode" ( A:ValueId ) { _:Map } : ( T:HwStructType ) -> ( _:Types )
            ...
        </circt-exec>
        <circt-locals> ... A |-> TV(T, V) ... </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            (L:List => L ListItem(TV(T, {M[F]}:>Value)))
            ~> !hw.struct< (F:BareId : T:Type, Fs:HwStructFields => Fs) >
            ~> M:Map
            ~> "hw.struct_explode" ( _:ValueId ) { _:Map } : ( _:HwStructType ) -> ( T:Type, Ts:Types => Ts )
            ...
        </circt-exec>
        
    rule <k> circt </k>
        <circt-exec>
            _:List
            ~> (
                !hw.struct< .HwStructFields >
                ~> _:Map
                ~> "hw.struct_explode" ( _:ValueId ) { _:Map } : ( _:HwStructType ) -> ( .Types ) 
                => .K
            )
            ...
        </circt-exec>

    // hw.enum.constant
    rule <k> circt </k>
        <circt-exec>
            (.K => M[#token("field", "BareId")])
            ~> "hw.enum.constant" ( .ValueIdList ) { M:Map } : ( .Types ) -> ( _:HwEnumType )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            ((#token("#hw.enum.field", "AttributeAlias") D:DialectTypeBody):DialectAttribute => D)
            ~> "hw.enum.constant" ( .ValueIdList ) { _M:Map } : ( .Types ) -> ( _:HwEnumType )
            ...
        </circt-exec>

    // todo
    rule <k> circt </k>
        <circt-exec>
            (< X:BareId, _:DialectTypeContentsList >
            ~> "hw.enum.constant" ( .ValueIdList ) { _:Map } : ( .Types ) -> ( T:HwEnumType ))
            => ListItem(TV(T, hw.enum(X, T)))
            ...
        </circt-exec>
    
    // hw.enum.cmp
    rule <k> circt </k>
        <circt-exec>
            "hw.enum.cmp" ( A1:ValueId, A2:ValueId ) { .Map } : ( T:HwEnumType, T:HwEnumType ) -> ( T1:IntegerType )
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
            "hw.union_extract" ( A:ValueId ) { _:Map } : ( T1:HwUnionType ) -> ( T2:Type )
            =>  ListItem(TV(T2, HwUnionExtract(V, T2)))
            ...
        </circt-exec>
        <circt-locals> ... A |-> TV(T1, V) ... </circt-locals>

    // hw.union_create
    rule <k> circt </k>
        <circt-exec>
            "hw.union_create" ( A:ValueId ) { _:Map } : ( T1:Type ) -> ( T2:HwUnionType )
            =>  ListItem(TV(T2, V))
            ...
        </circt-exec>
        <circt-locals> ... A |-> TV(T1, V) ... </circt-locals>
endmodule