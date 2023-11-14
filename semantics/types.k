// requires "builtin"

module HW-ARRAY
    // imports BUILTIN-DIALECT
    imports INT

    syntax HwArray ::= "[" Values "]"
    syntax Value ::= HwArray

    syntax HwArrayType ::= "!hw.array" "<" Int "x" IntegerType ">"
    syntax Type ::= HwArrayType

    syntax Value ::= HwArrayGet(HwArray, Int) [function]
    
    rule HwArrayGet(([ _:Value, Vs:Values ]):HwArray, I:Int) => HwArrayGet([ Vs ], I -Int 1) requires I >Int 0
    rule HwArrayGet(([ V:Value, _:Values ]):HwArray, 0) => V

    syntax Values
    syntax IntegerType
endmodule