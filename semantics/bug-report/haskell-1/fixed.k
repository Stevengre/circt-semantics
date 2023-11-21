module FIXED-SYNTAX

    syntax SignedIntegerType ::= r"si[1-9][0-9]*" [token,prefer,prec(3)]
    syntax UnsignedIntegerType ::= r"ui[1-9][0-9]*" [token,prefer,prec(3)]
    syntax SignlessIntegerType ::= r"i[1-9][0-9]*" [token,prefer,prec(3)]
    syntax IntegerType ::= SignedIntegerType | UnsignedIntegerType | SignlessIntegerType

endmodule

module FIXED
    import FIXED-SYNTAX
    import DOMAINS

    syntax Int ::= getIntegerTypeSize (IntegerType) [function]
    rule getIntegerTypeSize (T:SignedIntegerType) => String2Int(substrString(IntegerType2String(T), 2, lengthString(IntegerType2String(T))))
    rule getIntegerTypeSize (T:UnsignedIntegerType) => String2Int(substrString(IntegerType2String(T), 2, lengthString(IntegerType2String(T))))
    rule getIntegerTypeSize (T:SignlessIntegerType) => String2Int(substrString(IntegerType2String(T), 1, lengthString(IntegerType2String(T))))
    syntax String ::= "SignedIntegerType2String" "(" SignedIntegerType ")" [function, total,hook(STRING.token2string)]
    syntax String ::= "UnsignedType2String" "(" UnsignedIntegerType ")" [function, total,hook(STRING.token2string)]
    syntax String ::= "SignlessIntegerType2String" "(" SignlessIntegerType ")" [function, total,hook(STRING.token2string)]
    syntax String ::= "IntegerType2String" "(" IntegerType ")" [function, total]
    rule IntegerType2String(SI:SignedIntegerType) => SignedIntegerType2String(SI)
    rule IntegerType2String(II:UnsignedIntegerType) => UnsignedType2String(II)
    rule IntegerType2String(LI:SignlessIntegerType) => SignlessIntegerType2String(LI)

endmodule