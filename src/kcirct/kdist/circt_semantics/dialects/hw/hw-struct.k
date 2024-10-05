module HW-STRUCT-SYNTAX
    imports CIRCT-SYNTAX
    // imports BITS

    syntax HwStructType ::= "!hw.struct" "<" StructFields ">"
    syntax StructFields ::= List{StructField, ","}
    syntax StructField ::= BareId ":" Type

    syntax Type ::= HwStructType

    // syntax HwStruct ::= Map
    // syntax Value ::= HwStruct

    // syntax Value ::= HwStructExtract(HwStruct, HwStructType, Int) [function]
    // rule HwStructExtract(M:Map, !hw.struct< _:StructField, Fs:StructFields >, Index:Int)
    //     => HwStructExtract(M, !hw.struct< Fs >, Index -Int 1)
    //     requires Index >Int 0
    // rule HwStructExtract(M:Map, !hw.struct< F:BareId : _:Type, _:StructFields >, 0) => {M[F]}:>Value

    // syntax Value ::= HwStructInject(HwStruct, Value, HwStructType, Int) [function]
    // rule HwStructInject(M:Map, V:Value, !hw.struct< _:StructField, Fs:StructFields >, Index:Int)
    //     => HwStructInject(M, V, !hw.struct< Fs >, Index -Int 1)
    //     requires Index >Int 0
    // rule HwStructInject(M:Map, V:Value, !hw.struct< F:BareId : _:Type, _:StructFields >, 0) => M[F <- V]

    // syntax Type ::= getFieldType(StructFields, Int) [function]
    // rule getFieldType(_:BareId : _:Type, Fs:StructFields, I:Int) => getFieldType(Fs, I -Int 1) requires I >Int 0
    // rule getFieldType(_:BareId : T:Type, _:StructFields, 0) => T

    // syntax Int ::= HwStructFindFieldOffs(HwStructType, BareId) [function]
    // syntax Int ::= HwStructGetFieldSize(HwStructType, BareId) [function]
    // syntax Type ::= HwStructGetFieldType(HwStructType, BareId) [function]

    syntax KmdCIRCT ::= "#HwStructExtract"
                      | "#HwStructCreate"
                      | "#HwStructExplode"
                      | "#HwStructInject"

    syntax Int ::= getStructFeildIndex(HwStructType, Int) [function]
    
    rule getStructFeildIndex(!hw.struct< _:BareId : T:Type, Fs:StructFields >, Idx:Int) 
        => getStructFeildIndex(!hw.struct< Fs >, Idx -Int 1) +Int getWidth(T)
        requires Idx >Int 0
    
    rule getStructFeildIndex(!hw.struct< _:StructField, _:StructFields >, 0) => 0

    syntax List ::= getTypesWidths(Types) [function]

    rule getTypesWidths(T:Type, Ts:Types) => ListItem(getWidth(T)) getTypesWidths(Ts)
    rule getTypesWidths(.Types) => .List

    syntax List ::= ListBits2StdValue(List, Types) [function]
    rule ListBits2StdValue(ListItem(B:Bits) L:List, T:Type, Ts:Types) => ListItem(B : T) ListBits2StdValue(L, Ts)
    rule ListBits2StdValue(.List, .Types) => .List
endmodule

module HW-STRUCT
    imports HW-STRUCT-SYNTAX


    rule <k> 
            "hw.struct_extract" ( V:ValueId ) { Attr:Map } : ( _:HwStructType ) -> ( T:Type ) 
            => V ~> #HwStructExtract ~> Attr["fieldIndex"] ~> T
            ...
        </k>

    rule <k> 
            "hw.struct_create" ( Vs:ValueIdList ) { .Map } : ( _:Types ) -> ( T:HwStructType ) 
            => Vs ~> #HwStructCreate ~> T
            ...
        </k>

    rule <k> 
            "hw.struct_explode" ( V:ValueId ) { .Map } : ( _:HwStructType ) -> ( Ts:Types ) 
            => V ~> #HwStructExplode ~> Ts
            ...
        </k>

    rule <k> 
            "hw.struct_inject" ( Vs:ValueIdList ) { Attr:Map } : ( ST:HwStructType , _:Type ) -> ( ST:HwStructType ) 
            => Vs ~> #HwStructInject ~> Attr["fieldIndex"] ~> ST
            ...
        </k>

    // hw.struct_create
    rule <k> L:List ~> #HwStructCreate ~> T:HwStructType => BitsConcat(ListStdValue2Bits(L)) : T ... </k>

    // hw.struct_extract
    rule <k> X:Bits : ST:HwStructType ~> #HwStructExtract ~> Idx:Int : _:IntegerType ~> T:Type 
            => BitsSlice(X, getStructFeildIndex(ST, Idx), getStructFeildIndex(ST, Idx) +Int getWidth(T)) : T
            ...
        </k>

    // hw.struct_explode
    rule <k> Struct:Bits : _:HwStructType ~> #HwStructExplode ~> Ts:Types 
            => ListBits2StdValue(BitsSplit(Struct, getTypesWidths(Ts)), Ts)
            ...
        </k>

    // hw.struct_inject
    rule <k> ListItem ( Struct:Bits : ST:HwStructType ) ListItem ( B:Bits : T:Type ) 
            ~> #HwStructInject ~> Idx:Int : _:IntegerType ~> ST:HwStructType
            => BitsConcat(
                BitsSlice(Struct, #none, getStructFeildIndex(ST, Idx)),
                B,
                BitsSlice(Struct, getStructFeildIndex(ST, Idx) +Int getWidth(T), #none)
            )
            ...
        </k>
endmodule