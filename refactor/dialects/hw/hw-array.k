module HW-ARRAY
    imports CIRCT-SYNTAX-CORE

    // syntax HwArray ::= "[" Values "]"
    // syntax Value ::= HwArray

    // syntax HwArrayType ::= "!hw.array" "<" ArraySizePrefix Type ">"
    // syntax Type ::= HwArrayType


    // syntax Value ::= HwArrayGet(HwArray, Int) [function]
    syntax HwArray ::= HwArraySlice(HwArray, Int, Int) [function]
    
    // rule HwArrayGet(([ _:Value, Vs:Values ]):HwArray, I:Int) => HwArrayGet([ Vs ], I -Int 1) requires I >Int 0
    // rule HwArrayGet(([ V:Value, _:Values ]):HwArray, 0) => V

    rule HwArraySlice([_:Value, Vs:Values], LowIndex:Int, HighIndex:Int)
        => [ ValuesFromList(range(toList(Vs), LowIndex, size(toList(Vs)) -Int HighIndex)) ]
    
    syntax String ::= "ArraySizePrefix2String" "(" ArraySizePrefix ")" [function, hook(STRING.token2string)]
    syntax Int ::= HwArraySize(HwArrayType) [function]
    rule HwArraySize(!hw.array < S:ArraySizePrefix _:Type >)
        => String2Int(substrString(ArraySizePrefix2String(S), 0, lengthString(ArraySizePrefix2String(S)) -Int 1))

    // syntax List ::= toList(Values) [function]
    // rule toList(V:Value, Vs:Values) => ListItem(V) toList(Vs)
    // rule toList(.Values) => .List

    syntax Values ::= ValuesFromList(List) [function]
    rule ValuesFromList(ListItem(V:Value) L:List) => V, ValuesFromList(L)
    rule ValuesFromList(.List) => .Values
endmodule