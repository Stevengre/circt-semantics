module HW-UNION-SYNTAX
    imports CIRCT-SYNTAX
    imports HW-STRUCT-SYNTAX

     
    syntax HwUnionType ::= "!hw.union" "<" StructFields ">"
    syntax Type ::= HwUnionType

    // syntax HwUnion ::= "hw.union" "(" Int "," HwUnionType ")"
    // syntax HwUnion ::= Int
    // syntax Value ::= HwUnion

    // syntax Value ::= HwUnionExtract(Value, Type) [function]
    // // rule HwUnionExtract(X:Int, T:IntegerType) => Bits2UInt(bitsCast(X, getWidth(T)))
    // rule HwUnionExtract(X:Int, T:IntegerType) => X &Int (2 ^Int getWidth(T) -Int 1)

    syntax KmdCIRCT ::= "#HwUnionExtract"
                      | "#HwUnionCreate"
endmodule


module HW-UNION
    imports HW-UNION-SYNTAX

    rule <k> 
            "hw.union_extract" ( V:ValueId ) { Attr:Map } : ( _:HwUnionType ) -> ( T:Type )
            => V ~> #HwUnionExtract ~> Attr["fieldIndex"] ~> T
            ...
        </k>

    rule <k> 
            "hw.union_create" ( V:ValueId ) { Attr:Map } : ( _:Type ) -> ( UT:HwUnionType )
            => V ~> #HwUnionCreate ~> Attr["fieldIndex"] ~> UT
            ...
        </k>

    // hw.union_create
    rule <k> B:Bits : _:Type ~> #HwUnionCreate ~> _:Int : _:IntegerType ~> UT:HwUnionType
            => B : UT
            ...
        </k>

    // hw.union_extract
    rule <k> B:Bits : _:HwUnionType ~> #HwUnionExtract ~> _:Int : _:IntegerType ~> T:Type 
            => B : T
            ...
        </k>
endmodule