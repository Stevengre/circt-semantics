requires "builtin.k"
requires "comb.k"
requires "hw.k"
requires "seq.k"
requires "sv.k"
requires "circt-conf.k"
// requires "types.k"

module CIRCT-SYNTAX-CORE
    imports BUILTIN-DIALECT-SYNTAX
    imports BOOL
    imports MAP
    imports K-EQUAL
    imports INT
    imports STRING
    imports LIST

    syntax Value ::= String
                   | Int
                   | Bool

    syntax TypeValue ::= "TV" "(" Type "," Value ")"

    syntax Values ::= List{Value, ","}

    syntax String ::= "IntType2String" "(" IntegerType ")" [function, hook(STRING.token2string)]
    
    syntax Int ::= getWidth(Type) [function]

    rule getWidth(T:IntegerType) => String2Int(substrString(IntType2String(T), 1, lengthString(IntType2String(T))))

    syntax Values ::= List2Values(List) [function]
    rule List2Values(ListItem(V:Value) L:List) => V, List2Values(L)
    rule List2Values(.List) => .Values

    syntax List ::= Values2List(Values) [function]
    rule Values2List(V:Value, Vs:Values) => ListItem(V) Values2List(Vs)
    rule Values2List(.Values) => .List
endmodule


module HW-INOUT
    imports CIRCT-SYNTAX-CORE

    syntax HwInOutType ::= "!hw.inout" "<" IntegerType ">"
    syntax Type ::= HwInOutType

    syntax HwInOut ::= "hw.inout" "(" String "," IntegerType "," Int ")"
    syntax Value ::= HwInOut
endmodule


module HW-ARRAY
    imports CIRCT-SYNTAX-CORE

    syntax HwArray ::= "[" Values "]"
    syntax Value ::= HwArray

    syntax HwArraySizePrefix ::= r"[1-9][0-9]*x" [token]
    syntax HwArrayType ::= "!hw.array" "<" HwArraySizePrefix Type ">"
    syntax Type ::= HwArrayType

    // syntax Int ::= getHwArrayElemWidth(HwArrayType)

    syntax Value ::= HwArrayGet(HwArray, Int) [function]
    syntax HwArray ::= HwArraySlice(HwArray, Int, Int) [function]
    
    rule HwArrayGet(([ _:Value, Vs:Values ]):HwArray, I:Int) => HwArrayGet([ Vs ], I -Int 1) requires I >Int 0
    rule HwArrayGet(([ V:Value, _:Values ]):HwArray, 0) => V

    rule HwArraySlice([_:Value, Vs:Values], LowIndex:Int, HighIndex:Int)
        => [ ValuesFromList(range(toList(Vs), LowIndex, size(toList(Vs)) -Int HighIndex)) ]
    
    syntax String ::= "HwArraySizePrefix2String" "(" HwArraySizePrefix ")" [function, hook(STRING.token2string)]
    syntax Int ::= HwArraySize(HwArrayType) [function]
    rule HwArraySize(!hw.array < S:HwArraySizePrefix _:Type >)
        => String2Int(substrString(HwArraySizePrefix2String(S), 0, lengthString(HwArraySizePrefix2String(S)) -Int 1))

    syntax List ::= toList(Values) [function]
    rule toList(V:Value, Vs:Values) => ListItem(V) toList(Vs)
    rule toList(.Values) => .List

    syntax Values ::= ValuesFromList(List) [function]
    rule ValuesFromList(ListItem(V:Value) L:List) => V, ValuesFromList(L)
    rule ValuesFromList(.List) => .Values

endmodule


module HW-STRUCT
    imports CIRCT-SYNTAX-CORE
    imports BITS

    syntax HwStructType ::= "!hw.struct" "<" HwStructFields ">"
    syntax HwStructFields ::= List{HwStructField, ","}
    syntax HwStructField ::= BareId ":" Type

    syntax Type ::= HwStructType

    syntax HwStruct ::= Map
    syntax Value ::= HwStruct

    syntax Value ::= HwStructExtract(HwStruct, HwStructType, Int) [function]
    rule HwStructExtract(M:Map, !hw.struct< _:HwStructField, Fs:HwStructFields >, Index:Int)
        => HwStructExtract(M, !hw.struct< Fs >, Index -Int 1)
        requires Index >Int 0
    rule HwStructExtract(M:Map, !hw.struct< F:BareId : _:Type, _:HwStructFields >, 0) => {M[F]}:>Value

    syntax Value ::= HwStructInject(HwStruct, Value, HwStructType, Int) [function]
    rule HwStructInject(M:Map, V:Value, !hw.struct< _:HwStructField, Fs:HwStructFields >, Index:Int)
        => HwStructInject(M, V, !hw.struct< Fs >, Index -Int 1)
        requires Index >Int 0
    rule HwStructInject(M:Map, V:Value, !hw.struct< F:BareId : _:Type, _:HwStructFields >, 0) => M[F <- V]

    
    syntax HwUnionType ::= "!hw.union" "<" HwStructFields ">"
    syntax Type ::= HwUnionType

    // syntax HwUnion ::= "hw.union" "(" Int "," HwUnionType ")"
    syntax HwUnion ::= Int
    syntax Value ::= HwUnion

    syntax Value ::= HwUnionExtract(Value, Type) [function]
    rule HwUnionExtract(X:Int, T:IntegerType) => Bits2UInt(bitsCast(X, getWidth(T)))

    syntax Type ::= getFieldType(HwStructFields, Int) [function]
    rule getFieldType(_:BareId : _:Type, Fs:HwStructFields, I:Int) => getFieldType(Fs, I -Int 1) requires I >Int 0
    rule getFieldType(_:BareId : T:Type, _:HwStructFields, 0) => T
endmodule


module HW-ENUM
    imports CIRCT-SYNTAX-CORE

    syntax HwEnumType ::= "!hw.enum" "<" HwEnumItems ">"
                        | "enum" "<" HwEnumItems ">"
    syntax HwEnumItems ::= List{HwEnumItem, ","}
    syntax HwEnumItem ::= BareId
    syntax Type ::= HwEnumType

    syntax HwEnum ::= "hw.enum" "(" HwEnumItem "," HwEnumType ")"
    syntax Value ::= HwEnum
endmodule



module CIRCT-SYNTAX
    imports HW-ARRAY
    imports HW-STRUCT
    imports HW-ENUM
    imports HW-INOUT

    syntax Control ::= "circtTest" SymbolRefId "(" Values ")"

    syntax AttributeValue ::= getAttr(Map, BareId) [function]
    rule getAttr(M:Map, I:BareId) => {M[I]}:>AttributeValue

    syntax Value ::= toValue(AttributeValue) [function]
    
    rule toValue(I:IntegerLiteral : _:IntegerType) => {I}:>Int
    rule toValue(B:Bool) => #if B #then 1 #else 0 #fi
    rule toValue([I:IntegerLiteral : _:IntegerType]) => {I}:>Int
    rule toValue([ L:AttributeValueList ]) => ([ toValues(L) ]):HwArray
    
    syntax Values ::= toValues(AttributeValueList) [function]
    rule toValues(I:IntegerLiteral : _:IntegerType , L:AttributeValueList) => {I}:>Int , toValues(L)
    rule toValues(B:Bool , L:AttributeValueList) => #if B #then 1 #else 0 #fi, toValues(L)
    rule toValues([Vs:AttributeValueList] , L:AttributeValueList) => [toValues(Vs)], toValues(L)
    rule toValues(S:String, L:AttributeValueList) => S, toValues(L)
    rule toValues(.AttributeValueList) => .Values

    syntax Value ::= getAttrValue(Map, BareId) [function]
    rule getAttrValue(M:Map, I:BareId) => toValue({M[I]}:>AttributeValue)

    // syntax Value ::= getAttrValue(Map, String) [function]
    // rule getAttrValue(M:Map, I:String) => toValue({M[#token(I, "BareId")]}:>AttributeValue)
endmodule


module CIRCT-PREPROCESS
    imports CIRCT-SYNTAX
    imports CIRCT-CONFIGURATION

    rule <k> (.K => preprocess-1 ~> Ops) ~> preprocess ... </k>
        <standard-ops> Ops:OperationList </standard-ops>

    rule <k> (.K => preprocess-2 ~> Op) 
            ~> preprocess-1 
            ~> (Op:Operation Ops:OperationList => Ops)
            ...
        </k> 
    
    rule <k> (preprocess-1 ~> preprocess) => circt ... </k>
    
    rule <k> preprocess-1 ~> (.OperationList => .K) ... </k>
    
    rule <k> (preprocess-2 => .K) ~> preprocess-1 ... </k>
    
    rule <k> preprocess-2 
            ~> (
                .OpResults = "builtin.module" ( .ValueIdList ) [ .Successors ] ( Rs:Regions ) { Attr:Map } : FT:FunctionType
                => "builtin.module" ( .ValueIdList ) ( Rs ) { Attr } : FT
            )
            ...
        </k>
    
    rule <k> (.K => preprocess-3 ~> R) 
            ~> preprocess-2 
            ~> "builtin.module" ( .ValueIdList ) ( (R:Region, Rs:Regions => Rs) ) {_:Map} : _:FunctionType
            ...
        </k>
    
    rule <k> preprocess-2 
            ~> ("builtin.module" ( .ValueIdList ) ( .Regions ) {_:Map} : _:FunctionType => .K)
            ...
        </k>
    
    rule <k> (preprocess-3 => .K) ~> preprocess-2 ... </k>
    
    rule <k> preprocess-3 
            ~> (.K => Op)
            ~> { (Op:Operation Ops:OperationList => Ops) _:BlockList } 
            ...
        </k>
    
    rule <k>
            preprocess-3 
            ~> ({ .OperationList .BlockList } => .K )
            ...
        </k>
    
    rule <k> preprocess-3 ~>
            (
                .OpResults = "sv.verbatim" ( .ValueIdList ) [ .Successors ] ( .Regions ) { _:Map } : _:FunctionType
                => .
            ) ...
        </k>
    
    rule <k> (.K => M[#token("cond", "BareId")] orDefault stop) ~>
            preprocess-3 ~>
            (
                .OpResults = "sv.ifdef" ( .ValueIdList ) [ .Successors ] ( Rs:Regions ) { M:Map } : FT:FunctionType
                => "sv.ifdef" ( .ValueIdList ) ( Rs ) { M } : FT
            )
            ...
        </k>
    
    rule <k> (B:Bool => .K) ~> 
            preprocess-3 ~> 
            (
                "sv.ifdef" ( .ValueIdList ) ( R1:Region, R2:Region, .Regions ) { _:Map } : _:FunctionType
                => #if B #then R1 #else R2 #fi
            )
            ...
        </k>


    // rule <k> _:DialectAttribute => stop 1 ... </k>
    rule <k> 
            (#token("#sv", "AttributeAlias") < _:BareId S:StringLiteral >):DialectAttribute 
                => S in_keys(M)
            ... 
        </k>
        <macros> M:Map </macros>

    rule <k>
            preprocess-3 ~>
            (
                .OpResults = "hw.module" ( .ValueIdList ) [ .Successors ] ( Rs:Regions ) { Attr:Map } : FT:FunctionType
                => "hw.module" ( .ValueIdList ) ( Rs ) { Attr } : FT
            )
            ...
        </k>
    
    rule <k>
            preprocess-3 ~>
            (
                "hw.module" ( _:ValueIdList ) ( _:Regions ) { _:Map } : _:FunctionType => .K
            )
            ...
        </k>
    
    rule <k> 
            preprocess-3 ~> 
            (
                .OpResults = "sv.macro.decl" ( .ValueIdList ) [ .Successors ] ( .Regions ) { Attr:Map } : ( .Types ) -> ( .Types )
                => .K
            )
            ...
        </k>
        <macros> M:Map => M [ Attr [#token("sym_name", "BareId")] <- "" ] </macros>

endmodule


module CIRCT
    imports CIRCT-PREPROCESS
    imports COMB
    imports HW
    imports SEQ
    imports SV

    // syntax AttributeValues ::= List{AttributeValue,","}

    rule
        <k> circt </k>
        <symbol-table> M:Map </symbol-table>
        <circt>
            <circt-control>
                circtTest ID:SymbolRefId ( Vs:Values ) => .
            </circt-control>
            <circt-frames>
                (
                    .Bag =>
                    <circt-frame>
                        ...
                        <circt-exec>
                            initial ~> always ~> Vs ~> M [ ListItem(SymbolRefId2String(ID)) ]
                        </circt-exec>
                        <module> ID </module>
                        ...
                    </circt-frame>
                )
            </circt-frames>
            ...
        </circt>
        requires ListItem(SymbolRefId2String(ID)) in_keys(M)
    
    rule
        <k> circt => stop "no such module" </k>
        <symbol-table> M:Map </symbol-table>
        <circt>
            <circt-control>
                circtTest ID:SymbolRefId ( _:Values ) => .
            </circt-control>
            ...
        </circt>
        requires notBool ListItem(SymbolRefId2String(ID)) in_keys(M)
    
    rule <k> circt </k>
        <circt-exec> 
            initial => #if notBool ID in S #then M [ID] orDefault .OperationList #else .K #fi
            ...
        </circt-exec>
        <module> ID:SymbolRefId </module>
        <initial> M:Map </initial>
        <initialized> S:Set </initialized>
    
    rule <k> circt </k>
        <circt-exec> 
            always => M [ID] orDefault .OperationList
            ...
        </circt-exec>
        <module> ID:SymbolRefId </module>
        <always> M:Map </always>

    rule <k> circt </k>
        <circt-exec> 
            _:Values ~> (
                .OpResults = "hw.module" (Vs:ValueIdList) [_:Successors] (Rs:Regions) {Attr:Map} : FT:FunctionType
                => "hw.module" (Vs) (Rs) {Attr} : FT
            )
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            _:Values
            ~> (
                "hw.module" (_:ValueIdList) ({.OperationList B:Block}, .Regions) {_:Map} : _:FunctionType
                => B
            )
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (V:Value, Vs:Values => Vs)
            ~> _:CaretId ((I:ValueId : T:Type, Is:ValueIdAndTypeList => Is)) : _:OperationList
        </circt-exec>
        <circt-locals> M:Map => M [I <- TV(T, V)] </circt-locals>
    
    rule <k> circt </k>
        <circt-exec> 
            (.Values ~> _:CaretId (.ValueIdAndTypeList) : Ops:OperationList) => Ops
        </circt-exec>

    rule <k> circt </k> 
        <circt-exec> 
            Op:Operation Ops:OperationList => Op ~> Ops 
            ...
        </circt-exec>
    
    rule <k> circt </k> 
        <circt-exec> 
            .OperationList => .K
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec> 
            Rs:OpResults = Op:GenericOperation => Op ~> Rs = 
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (ListItem( TV(T:Type, V:Value) ) L:List => L)
            ~> (I:ValueId, Rs:OpResults => Rs) =
            ...
        </circt-exec>
        <circt-locals> M:Map => M [I <- TV(T, V)] </circt-locals>
    
    // %35:2 = "hw.struct_explode"(%32) : (!hw.struct<foo: i19, bar: i7>) -> (i19, i7)
    rule <k> circt </k>
        <circt-exec> 
            (L:List => range(L, I, 0))
            ~> (A:ValueId : I:Int, Rs:OpResults => Rs) =
            ...
        </circt-exec>
        <circt-locals> M:Map => M [A <- range(L, 0, size(L) -Int I)] </circt-locals>
    
    rule <k> circt </k>
        <circt-exec> 
            (.List ~> .OpResults =) => .K
            ...
        </circt-exec>
    
    // rule <k> circt </k>
    //     <circt-exec> 
    //         S:StringLiteral ( VIL:ValueIdList ) [ .Successors ] ( .Regions ) { .Map } : FT:FunctionType
    //         => S ( VIL ) : FT
    //         ...
    //     </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            S:StringLiteral ( VIL:ValueIdList ) [ .Successors ] ( .Regions ) { Attr:Map } : FT:FunctionType
            => S ( VIL ) { Attr } : FT
            ...
        </circt-exec>
    // requires size(Attr) >Int 0

    rule <k> circt </k>
        <circt-exec> 
            S:StringLiteral ( VIL:ValueIdList ) [ .Successors ] ( R:Region, Rs:Regions ) { Attr:Map } : FT:FunctionType
            => S ( VIL ) (R, Rs) { Attr } : FT
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec> 
            { Op:Operation Ops:OperationList BL:BlockList } => Op ~> { Ops BL }
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            ({ .OperationList .BlockList } ~> .OpResults =) => .K
            ...
        </circt-exec>
    
    
endmodule