module HW
    imports CIRCT-CONFIGURATION
    imports CIRCT-SYNTAX

    // hw.wire seems just returns the value
    rule <k> circt </k>
        <circt-exec> 
            "hw.wire" (I:ValueId) {_:Map} : (T:Type) -> T:Type
            => ListItem( TV(T, V) )
            ...
        </circt-exec>
        <circt-locals>
            ...
            I |-> TV(T, V)
            ...
        </circt-locals>

    rule <k> circt </k>
        <circt-exec> 
            "hw.output" ( (I:ValueId , Is:ValueIdList => Is) ) {_:Map} : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
        <circt-output> M:Map => M [I <- Locals [I]] </circt-output>
        <circt-locals> Locals:Map </circt-locals>
        requires I in_keys(Locals)
    
    rule <k> circt </k>
        <circt-exec> 
            "hw.output" ( .ValueIdList ) {_:Map} : ( _:Types ) -> ( .Types )
            => .List
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
        <circt-locals>
            ...
            I |-> TV(_:Type, V:Value)
            ...
        </circt-locals>
    
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
                            Vs ~> M [ ListItem(SymbolRefId2String(
                                {getAttr(Attr, #token("moduleName", "BareId"))}:>SymbolRefId
                            )) ] 
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
                        <circt-output> Out:Map </circt-output>
                        ...
                    </circt-frame>
                    => .Bag
                )
                <circt-frame>
                    ...
                    <circt-exec> 
                        (_:Values ~> "hw.instance" ( .ValueIdList ) { _:Map } : _:FunctionType)
                        => values(Out)
                        ...
                    </circt-exec>
                    ...
                </circt-frame>
                ...
            </circt-frames>
            ...
        </circt>

    rule <k> circt => done </k>
        <circt-frames>
            (
                <circt-frame>
                    ...
                    <circt-exec> .K </circt-exec>
                    <circt-output> Out:Map </circt-output>
                    ...
                </circt-frame>
                => .Bag
            )
        </circt-frames>
        <result> L:List => L ListItem(Out) </result>
    

    // hw.aggregate_constant
    rule <k> circt </k>
        <circt-exec> 
            "hw.aggregate_constant" ( .ValueIdList ) { M:Map } : ( .Types ) -> ( T:Type )
            => ListItem( TV(T, getAttrValue(M, #token("fields", "BareId"))) )
            ...
        </circt-exec>
    
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
            "hw.bitcast" ( I:ValueId , .ValueIdList ) { .Map } : ( T1:Type ) -> ( T2:Type )
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

    syntax List ::= IntSlice(Int, Int, Int, Int) [function]
    
    rule IntSlice(X:Int, Offs:Int, Step:Int, W:Int) 
        => IntSlice(2 ^Int W +Int X, Offs, Step, W)
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
        <circt-locals>
            ...
            I |-> TV(T, V)
            ...
        </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            (
                M:Map
                ~> .HwStructFields
                ~> "hw.struct_create" ( .ValueIdList ) { .Map } : ( .Types ) -> ( T:HwStructType )
            ) => ListItem( TV(T, M) )
            ...
        </circt-exec>


endmodule