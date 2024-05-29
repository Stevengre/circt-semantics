module HW-STRUCT-SYNTAX
    imports CIRCT-SYNTAX-CORE
    // imports BITS

    syntax HwStructType ::= "!hw.struct" "<" StructFields ">"
    // syntax HwStructFields ::= List{HwStructField, ","}
    // syntax HwStructField ::= BareId ":" Type

    syntax Type ::= HwStructType

    syntax HwStruct ::= Map
    syntax Value ::= HwStruct

    syntax Value ::= HwStructExtract(HwStruct, HwStructType, Int) [function]
    rule HwStructExtract(M:Map, !hw.struct< _:StructField, Fs:StructFields >, Index:Int)
        => HwStructExtract(M, !hw.struct< Fs >, Index -Int 1)
        requires Index >Int 0
    rule HwStructExtract(M:Map, !hw.struct< F:BareId : _:Type, _:StructFields >, 0) => {M[F]}:>Value

    syntax Value ::= HwStructInject(HwStruct, Value, HwStructType, Int) [function]
    rule HwStructInject(M:Map, V:Value, !hw.struct< _:StructField, Fs:StructFields >, Index:Int)
        => HwStructInject(M, V, !hw.struct< Fs >, Index -Int 1)
        requires Index >Int 0
    rule HwStructInject(M:Map, V:Value, !hw.struct< F:BareId : _:Type, _:StructFields >, 0) => M[F <- V]

    
    syntax HwUnionType ::= "!hw.union" "<" StructFields ">"
    syntax Type ::= HwUnionType

    // syntax HwUnion ::= "hw.union" "(" Int "," HwUnionType ")"
    syntax HwUnion ::= Int
    syntax Value ::= HwUnion

    syntax Value ::= HwUnionExtract(Value, Type) [function]
    // rule HwUnionExtract(X:Int, T:IntegerType) => Bits2UInt(bitsCast(X, getWidth(T)))
    rule HwUnionExtract(X:Int, T:IntegerType) => X &Int (2 ^Int getWidth(T) -Int 1)

    syntax Type ::= getFieldType(StructFields, Int) [function]
    rule getFieldType(_:BareId : _:Type, Fs:StructFields, I:Int) => getFieldType(Fs, I -Int 1) requires I >Int 0
    rule getFieldType(_:BareId : T:Type, _:StructFields, 0) => T

    syntax Int ::= HwStructFindFieldOffs(HwStructType, BareId) [function]
    syntax Int ::= HwStructGetFieldSize(HwStructType, BareId) [function]
    syntax Type ::= HwStructGetFieldType(HwStructType, BareId) [function]
endmodule

module HW-STRUCT
endmodule