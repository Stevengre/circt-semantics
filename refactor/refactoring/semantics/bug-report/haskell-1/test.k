module TEST-SYNTAX

    syntax SignedIntegerType ::= r"si[1-9][0-9]*" [token,prefer,prec(3)]
    syntax UnsignedIntegerType ::= r"ui[1-9][0-9]*" [token,prefer,prec(3)]
    syntax SignlessIntegerType ::= r"i[1-9][0-9]*" [token,prefer,prec(3)]
    syntax IntegerType ::= SignedIntegerType | UnsignedIntegerType | SignlessIntegerType

endmodule

module TEST
    import TEST-SYNTAX
    import DOMAINS

    syntax Int ::= getIntegerTypeSize (IntegerType) [function]
    rule getIntegerTypeSize (T:SignedIntegerType) => String2Int(substrString(IntegerType2String(T), 2, lengthString(IntegerType2String(T))))
    rule getIntegerTypeSize (T:UnsignedIntegerType) => String2Int(substrString(IntegerType2String(T), 2, lengthString(IntegerType2String(T))))
    rule getIntegerTypeSize (T:SignlessIntegerType) => String2Int(substrString(IntegerType2String(T), 1, lengthString(IntegerType2String(T))))
    syntax String ::= "IntegerType2String" "(" IntegerType ")" [function, total,hook(STRING.token2string)]

endmodule