module HW-ENUM-SYNTAX
    imports CIRCT-SYNTAX

    syntax HwEnumType ::= "!hw.enum" "<" HwEnumItems ">"
                        | "enum" "<" HwEnumItems ">"

    syntax HwEnumItems ::= List{HwEnumItem, ","}
    syntax HwEnumItem ::= BareId
    syntax Type ::= HwEnumType


    syntax HwEnumField ::= "#hw.enum.field" "<" HwEnumItem "," HwEnumType ">"
    syntax AttributeValue ::= HwEnumField

    
    // syntax HwEnum ::= "hw.enum" "(" HwEnumItem "," HwEnumType ")"
    // syntax Value ::= HwEnum

    syntax KmdCIRCT ::= "#HwEnumCmp"
                      | "#HwEnumConst"

    
    syntax Bits ::= HwEnum2Bits(HwEnumField) [function]
    rule HwEnum2Bits(#hw.enum.field < X:HwEnumItem, T:HwEnumType >) => bits(getEnumIndex(X, T), log2Int(getEnumSize(T) -Int 1) +Int 1)

    syntax Int ::= getEnumIndex(HwEnumItem, HwEnumType) [function]
    syntax Int ::= getEnumSize(HwEnumType) [function]

    rule getEnumIndex(X:HwEnumItem, !hw.enum < X:HwEnumItem, _:HwEnumItems >) => 0
    rule getEnumIndex(X:HwEnumItem, !hw.enum < Y:HwEnumItem, Ys:HwEnumItems >) => 1 +Int getEnumIndex(X, !hw.enum < Ys >) requires X =/=K Y

    rule getEnumSize(!hw.enum < _:HwEnumItem, Xs:HwEnumItems >) => 1 +Int getEnumSize(!hw.enum < Xs >)
    rule getEnumSize(!hw.enum < .HwEnumItems >) => 0
endmodule


module HW-ENUM
    imports HW-ENUM-SYNTAX

    rule <k> "hw.enum.cmp" ( Vs:ValueIdList ) : ( ET:HwEnumType, ET:HwEnumType ) -> ( #token("i1", "SignlessIntegerType") )
            => Vs ~> #HwEnumCmp ~> ET
            ...
        </k>

    rule <k> "hw.enum.constant" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( ET:HwEnumType )
            => #HwEnumConst ~> Attr["field"] ~> ET
            ...
        </k>

    // hw.enum.constant
    rule <k> #HwEnumConst ~> X:HwEnumField ~> T:HwEnumType => HwEnum2Bits(X) : T ... </k>

    // hw.enum.cmp
    rule <k> ListItem(bits(X1:Int, _:Int) : T:HwEnumType) ListItem(bits(X2:Int, _:Int) : T:HwEnumType) 
            ~> #HwEnumCmp ~> T:HwEnumType
            => bits(#if X1 ==Int X2 #then 1 #else 0 #fi, 1) : #token("i1", "SignlessIntegerType")
            ...
        </k>
endmodule