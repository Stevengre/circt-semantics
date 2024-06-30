requires "./bits.k"
requires "../mlir/mlir.k"

module STDVALUE-SYNTAX
    imports BITS
    imports MLIR

    syntax StdValue ::= Bits ":" Type
    syntax StdValues ::= List{StdValue, ","}

    syntax Bits ::= AV2Bits ( AttributeValue, Type ) [function]
    
    syntax BitsValue ::= AttributeValue2BitsValue ( AttributeValue ) [function]
    
    syntax StdValues ::= List2StdValues ( List ) [function]
 
    syntax Bits ::= StdValues2Bits ( StdValues ) [function]
    
    syntax BitsVec ::= StdValues2BitsVec ( StdValues ) [function]

    syntax Int ::= StdValue2Int(StdValue) [function]

    syntax StdValue ::= String2StdValue(String) [function]
    syntax StdValue ::= AV2StdValue(AttributeValue, Type) [function]
endmodule



module STDVALUE
    imports STDVALUE-SYNTAX

    rule StdValues2Bits( .StdValues ) => bits(0, 0)
    rule StdValues2Bits( B:Bits : _:Type, Vs:StdValues ) => B concatBits StdValues2Bits(Vs)

    rule StdValues2BitsVec( .StdValues ) => .BitsVec
    rule StdValues2BitsVec( B:Bits : _:Type, Vs:StdValues ) =>B, StdValues2BitsVec(Vs)

    rule List2StdValues( .List ) => .StdValues
    rule List2StdValues( ListItem(V:StdValue) L:List ) => V , List2StdValues(L)

    rule AttributeValue2BitsValue( V:Int ) => V
    rule AttributeValue2BitsValue( V:IntegerLiteral : _:IntegerType ) => {V}:>Int
    rule AttributeValue2BitsValue( V:IntegerLiteral : _:IndexType ) => {V}:>Int
    rule AttributeValue2BitsValue( true ) => {1}:>BitsValue
    rule AttributeValue2BitsValue( false ) => {0}:>BitsValue

    rule AV2Bits(V, T) => bits(AttributeValue2BitsValue(V), getWidth(T))
    rule AV2StdValue(V, T) => bits(AttributeValue2BitsValue(V), getWidth(T)) : T
endmodule