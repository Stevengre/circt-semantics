module STDVALUE-SYNTAX

    syntax StdValue ::= Bits ":" Type
    syntax StdValues ::= List{StdValue, ","}

    syntax Bits ::= AttributeValue2Bits ( AttributeValue, Type ) [function]
    
    syntax BitsValue ::= AttributeValue2BitsValue ( AttributeValue ) [function]
    
    syntax StdValues ::= List2StdValues ( List ) [function]
 
    syntax Bits ::= StdValues2Bits ( StdValues ) [function]
    
    syntax BitsVec ::= StdValues2BitsVec ( StdValues ) [function]

    syntax Int ::= StdValue2Int(StdValue) [function]

    syntax StdValue ::= String2StdValue(String) [function]

endmodule



module STDVALUE
    imports STDVALUE-SYNTAX

    rule StdValues2Bits( .StdValues ) => bits(0,0)
    rule StdValues2Bits( (bits(V,S):BitsValue) , Vs:StdValues ) => bits(V,S) concatBits StdValues2Bits(Vs)

    rule StdValues2BitsVec( .StdValues ) => .BitsVec
    rule StdValues2BitsVec( bits(V,S) , Vs:StdValues ) => bits(V,S), StdValues2BitsVec(Vs)

    rule List2StdValues( .List ) => .StdValues
    rule List2StdValues( ListItem(V:StdValue) L:List ) => V , List2StdValues(L)

    rule AttributeValue2BitsValue( AV:AttributeValue ) => {AV}:>BitsValue [owise]
    rule AttributeValue2BitsValue( V:IntegerLiteral : _:IntegerType ) => {V}:>BitsValue
    rule AttributeValue2BitsValue( V:IntegerLiteral : _:IndexType ) => {V}:>BitsValue
    rule AttributeValue2BitsValue( true ) => {1}:>BitsValue
    rule AttributeValue2BitsValue( false ) => {0}:>BitsValue

    rule AttributeValue2Bits(V,T) => bits(AttributeValue2BitsValue(V), getWidth(T)) [owise]
endmodule