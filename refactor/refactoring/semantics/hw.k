requires "bits.k"

module HW
    imports CONFIGURATION
    imports CIRCT-SYNTAX
    imports BITS


    // hw.wire, how to express observablility
    rule <k> circt </k>
        <circt-exec> 
            "hw.wire" (I:Var) {_:Map} : (T:Type) -> (T:Type)
            => ListItem( TV(T, V) )
            ...
        </circt-exec>
        <circt-locals> ... I |-> TV(T, V) ... </circt-locals>

    // hw.output
    rule <k> circt </k>
        <circt-exec>
            (.K => L)
            ~> "hw.output" ( _:VarList ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
        <ports-out> L:List </ports-out>
        
    rule <k> circt </k>
        <circt-exec>
            (ListItem(X:BareId) L:List => L)
            ~> "hw.output" ( I:Var, Is:VarList => Is ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
        <circt-output> Out:List => Out ListItem(#result(X, {Locals[I]}:>TypeValue)) </circt-output>
        <circt-locals> Locals:Map </circt-locals>
        <name> Name:String </name>
        <instance>
            <inst-name> Name </inst-name>
            <inst-out> M:Map => M [X <- I] </inst-out>
            ...
        </instance>
        requires I in_keys(Locals)
    
    rule <k> circt </k>
        <circt-exec>
            .List ~> "hw.output" ( .VarList ) {_:Map} : ( _:Types ) -> ( .Types ) => .List
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec> 
            "hw.constant" ( .VarList ) { M:Map } : ( .Types ) -> ( T:Type , .Types )
            => ListItem( TV(T, getAttrValue(M, #token("value", "BareId"))) )
            ...
        </circt-exec>

    // hw.instance
    rule <k> circt </k>
        <circt-exec> 
            (.K => Attr[#token("inner_sym", "BareId")] orDefault "no inner_sym")
            ~> (.K => Attr[#token("instanceName", "BareId")]) 
            ~> "hw.instance" ( _Is:VarList ) { Attr:Map } : _:FunctionType
            ...
        </circt-exec>

    // hw.instance, no inner_sym
    rule <k> circt </k>
        <circt-exec>
            (
                "no inner_sym"
                ~> _Sym:String 
                => .List
            ) ~>
            "hw.instance" ( _Is:VarList ) { _:Map } : _:FunctionType
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (
                (#token("#hw", "AttributeAlias") < #token("innerSym", "BareId") SymId:SymbolRefId >):DialectAttribute 
                ~> Sym:String 
                => .List
            ) ~>
            "hw.instance" ( _Is:VarList ) { _:Map } : _:FunctionType
            ...
        </circt-exec>
        <symrefs> 
            M:Map => M [ SymbolRefId2String(Mod) +String "::" +String SymbolRefId2String(SymId) <- Sym ]
        </symrefs>
        <module> Mod:SymbolRefId </module>

    
    rule <k> circt </k>
        <circt-exec> 
            (L:List => L ListItem(V)) 
            ~> "hw.instance" ( (I:Var, Is:VarList => Is) ) { _:Map } : _:FunctionType
            ...
        </circt-exec>
        <circt-locals> ... I |-> TV(_:Type, V:Value) ... </circt-locals>
    
    rule <k> circt </k>
        <circt-exec> 
            (.K => .Values)
            ~> L:List
            ~> "hw.instance" ( .VarList ) { Attr:Map } : _:FunctionType
            ...
        </circt-exec>
        <trace> Trace:List </trace>
        <ob-in> M:Map => M [ getTrace(Trace ListItem(Attr[#token("instanceName", "BareId")])) <- L ] </ob-in>
    
    rule <k> circt </k>
        <circt-exec> 
            (Vs:Values => V, Vs)
            ~> (L:List ListItem(V:Value) => L)
            ~> "hw.instance" ( .VarList ) { _:Map } : _:FunctionType
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            _:Values
            ~> (.List => .K)
            ~> (.K => getTrace(L ListItem(Attr[#token("instanceName", "BareId")])))
            ~> "hw.instance" ( .VarList ) { Attr:Map } : _:FunctionType
            ...
        </circt-exec>
        <trace> L:List </trace>        
    
    // hw.instance, new frame, instance non-initialized
    rule <k> circt </k>
        <symbol-table> M:Map </symbol-table>
        <circt-frames>
            (.Bag =>
                <circt-frame>
                    ...
                    <circt-exec> 
                        Vs ~> M [ SymbolRefId2String(
                            {Attr[#token("moduleName", "BareId")] orDefault #token("@_", "SymbolRefId")}:>SymbolRefId
                        ) ] orDefault (stop "no such module")
                    </circt-exec>
                    <last-locals> Old </last-locals>
                    <name> Name </name>
                    <module> {Attr[#token("moduleName", "BareId")]}:>SymbolRefId </module>
                    ...
                </circt-frame>
            )
            <circt-frame>
                ...
                <circt-exec> 
                    Vs:Values ~> 
                    Name:String ~>
                    "hw.instance" ( .VarList ) { Attr:Map } : _:FunctionType
                    ...
                </circt-exec>
                ...
            </circt-frame>
            ...
        </circt-frames>
        <trace> L:List => L ListItem(Attr[#token("instanceName", "BareId")]) </trace>
        <instance>
            <inst-name> Name </inst-name>
            <inst-vars> Old:Map => .Map </inst-vars>
            <inst-in> _ => .Map </inst-in>
            <inst-out> _ => .Map </inst-out>
            <inst-regs> _ => .Map </inst-regs>
            <inst-wires> _ => .Map </inst-wires>
        </instance>
    
    // hw.instance, new frame, instance non-initialized
    rule <k> circt </k>
        <symbol-table> M:Map </symbol-table>
        <circt-frames>
            (.Bag =>
                <circt-frame>
                    <circt-exec> 
                        Vs ~> M [ SymbolRefId2String(
                            {Attr[#token("moduleName", "BareId")] orDefault #token("@_", "SymbolRefId")}:>SymbolRefId
                        ) ] orDefault (stop "no such module")
                    </circt-exec>
                    <last-locals> .Map </last-locals>
                    <name> Name </name>
                    <module> {Attr[#token("moduleName", "BareId")]}:>SymbolRefId </module>
                    ...
                </circt-frame>
            )
            <circt-frame>
                <circt-exec> 
                    Vs:Values ~> 
                    Name:String ~>
                    "hw.instance" ( .VarList ) { Attr:Map } : _:FunctionType
                    ...
                </circt-exec>
                ...
            </circt-frame>
            ...
        </circt-frames>
        <trace> L:List => L ListItem(Attr[#token("instanceName", "BareId")]) </trace>
        <state>
            ...
            (.Bag =>
                <instance>
                    <inst-name> Name </inst-name>
                    ...
                </instance>
            )
            ...
        </state>
        [owise]

    
    // hw.instance finish, clear frame
    rule <k> circt </k>
        <circt-frames>
            (
                <circt-frame>
                    <circt-exec> .K </circt-exec>
                    <circt-output> Out:List </circt-output>
                    <circt-locals> Locals:Map </circt-locals>
                    <name> Name:String </name>
                    ...
                </circt-frame>
                => .Bag
            )
            <circt-frame>
                <circt-exec>
                    (.K => .List)
                    ~> (.K => Out)
                    ~> _:Values 
                    ~> Name:String
                    ~> "hw.instance" ( .VarList ) { _Attr:Map } : _:FunctionType
                    ...
                </circt-exec>
                ...
            </circt-frame>
            ...
        </circt-frames>
        <ob-out> M:Map => M [ Name <- Out ] </ob-out>
        <trace> L:List ListItem(_:String) => L </trace>
        <instance>
            <inst-name> Name </inst-name>
            <inst-vars> _ => Locals </inst-vars>
            ...
        </instance>
            

    rule <k> circt </k>
        <circt-exec>
            (L1:List => L1 ListItem(V))
            ~> (ListItem(#result(_:BareId, V:TypeValue)) L2:List => L2)
            ~> _:Values 
            ~> _:String
            ~> "hw.instance" ( .VarList ) { _:Map } : _:FunctionType
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            _:List
            ~> (
                .List ~> _:Values ~> _:String ~> "hw.instance" ( .VarList ) { _:Map } : _:FunctionType
                => .K
            )
            ...
        </circt-exec>    


    // hw.aggregate_constant
    rule <k> circt </k>
        <circt-exec> 
            "hw.aggregate_constant" ( .VarList ) { M:Map } : ( .Types ) -> ( T:Type )
            => ListItem( TV(T, getAttrValue(M, #token("fields", "BareId"))) )
            ...
        </circt-exec>


    // hw.array_get
    rule <k> circt </k>
        <circt-exec>
            "hw.array_get" ( A:Var , I:Var ) { _:Map } : ( _:Types ) -> ( T:Type )
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
                "hw.array_create" ( VL:VarList ) { _:Map } : FT:FunctionType
                => "hw.array_create" ( VL ) : FT
            )
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec>
            ( L:List => L ListItem(V) ) 
            ~> "hw.array_create" ( (I:Var, Is:VarList => Is) ) : ( _:Types ) -> ( _:Type )
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
            ~> "hw.array_create" ( .VarList ) : ( _:Types ) -> ( _:Type )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            ( Vs:Values => V, Vs )
            ~> ( ListItem(V:Value) L:List => L )
            ~> "hw.array_create" ( .VarList ) : ( _:Types ) -> ( _:Type )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            ( Vs:Values ~> .List ~> "hw.array_create" ( .VarList ) : ( _:Types ) -> ( T:Type ) )
            => ListItem( TV(T, [ Vs ]) )
            ...
        </circt-exec>


    // "hw.bitcast" ( %0 ) { .Map } : ( i64 ) -> ( !hw.array < 64x i1 > )
    rule <k> circt </k>
        <circt-exec>
            "hw.bitcast" ( I:Var ) { .Map } : ( T1:Type ) -> ( T2:Type )
            => ListItem( TV(T2, HwBitcast(V, T1, T2)) )
            ...
        </circt-exec>
        <circt-locals>
            ...
            I |-> TV(T1, V)
            ...
        </circt-locals>


    syntax Value ::= HwBitcast(Value, Type, Type) [function]
    rule HwBitcast(X:Int, T1:IntegerType, (!hw.array< _:ArraySizePrefix T2:IntegerType>):HwArrayType) 
        => [ List2Values(IntSlice(X, 0, getWidth(T2), getWidth(T1))) ]
    
    rule HwBitcast(X:Map, T1:HwStructType, T2:Type) => fromBits(toBits(X, T1), T2)
    
    syntax Bits ::= toBits(Value, Type) [function]
    rule toBits(M:Map, !hw.struct < F:BareId : T:Type, Fs:StructFields >)
        => toBits({M[F]}:>Value, T:Type) concatBits toBits(M:Map, !hw.struct < Fs >)
    rule toBits(_:Map, !hw.struct < .StructFields>) => bits(0, 0)
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
    

    // "hw.array_concat" ( %4 , %3 , .VarList ) { .Map } : ( !hw.array < 8x i1 > , !hw.array < 64x i1 > ) -> ( !hw.array < 72x i1 > )
    rule <k> circt </k>
        <circt-exec>
            (.K => .List)
            ~> "hw.array_concat" ( _:VarList ) { .Map } : ( _:Types ) -> ( _:Type )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (L:List => L ListItem(V))
            ~> "hw.array_concat" ( (I:Var, Is:VarList => Is) ) { .Map } : ( (T:Type, Ts:Types => Ts) ) -> ( _:Type )
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
            ~> "hw.array_concat" ( .VarList ) { .Map } : ( .Types ) -> ( _:Type )
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec>
            (ListItem([Vs:Values]) L1:List => L1)
            ~> (L:List => L Values2List(Vs))
            ~> "hw.array_concat" ( .VarList ) { .Map } : ( .Types ) -> ( _:Type )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (
                .List ~> L:List 
                ~> "hw.array_concat" ( .VarList ) { .Map } : ( .Types ) -> ( T:HwArrayType )
            )
            => ListItem( TV(T, [ List2Values(L) ]) )
            ...
        </circt-exec>


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