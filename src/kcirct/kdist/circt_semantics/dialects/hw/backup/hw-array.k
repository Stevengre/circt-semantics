module HW-ARRAY
    imports HW-ARRAY-SYNTAX

    syntax KmdCIRCT ::= "#HwArrayGet"
                      | "#HwArrayCreate"
                      | "#HwArraySlice"
                      | "#HwArrayConcat"

    syntax Int ::= SizeX2Size(SizeX) [function]

    rule SizeX2Size(S:SizeX) => String2Int(substrString(SizeX2String(S), 0, lengthString(SizeX2String(S)) -Int 1))

    syntax String ::= "SizeX2String" "(" SizeX ")" [function, hook(STRING.token2string)]
    syntax Int ::= HwArraySize(HwArrayType) [function]
    rule HwArraySize(!hw.array < S:SizeX _:Type >)
        => String2Int(substrString(SizeX2String(S), 0, lengthString(SizeX2String(S)) -Int 1))
    // syntax HwArray ::= "[" Values "]"
    // syntax Value ::= HwArray

    // syntax Value ::= HwArrayGet(HwArray, Int) [function]
    // syntax HwArray ::= HwArraySlice(HwArray, Int, Int) [function]
    
    // rule HwArrayGet(([ _:Value, Vs:Values ]):HwArray, I:Int) => HwArrayGet([ Vs ], I -Int 1) requires I >Int 0
    // rule HwArrayGet(([ V:Value, _:Values ]):HwArray, 0) => V

    // rule HwArraySlice([_:Value, Vs:Values], LowIndex:Int, HighIndex:Int)
    //     => [ ValuesFromList(range(toList(Vs), LowIndex, size(toList(Vs)) -Int HighIndex)) ]
    
    

    // syntax List ::= toList(Values) [function]
    // rule toList(V:Value, Vs:Values) => ListItem(V) toList(Vs)
    // rule toList(.Values) => .List

    // syntax Values ::= ValuesFromList(List) [function]
    // rule ValuesFromList(ListItem(V:Value) L:List) => V, ValuesFromList(L)
    // rule ValuesFromList(.List) => .Values

    rule <k> 
            "hw.array_get" ( Vs:ValueIdList ) { _:Map } : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( T:Type ) 
            => Vs ~> #HwArrayGet
            ... 
        </k>

    rule <k> 
            "hw.array_get" ( Vs:ValueIdList ) : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( T:Type ) 
            => Vs ~> #HwArrayGet
            ... 
        </k>

    rule <k> "hw.array_create" ( Vs:ValueIdList ) { _:Map } : ( _:Types ) -> ( T:HwArrayType )
            => Vs ~> #HwArrayCreate ~> T
            ...
        </k>
    
    rule <k> "hw.array_create" ( Vs:ValueIdList ) : ( _:Types ) -> ( T:HwArrayType )
            => Vs ~> #HwArrayCreate ~> T
            ...
        </k>

    rule <k> "hw.array_slice" ( Vs:ValueIdList ) { _:Map } : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( !hw.array < S:SizeX T:Type > ) 
            => Vs ~> #HwArraySlice ~> !hw.array < S T >
            ...
        </k>
    
    rule <k> "hw.array_slice" ( Vs:ValueIdList ) : ( !hw.array < _:SizeX T:Type > , _:IntegerType ) -> ( !hw.array < S:SizeX T:Type > ) 
            => Vs ~> #HwArraySlice ~> !hw.array < S T >
            ...
        </k>

    rule <k> "hw.array_concat" ( Vs:ValueIdList ) { _:Map } : ( _:Types ) -> ( T:HwArrayType )
            => Vs ~> #HwArrayConcat ~> T
            ...
        </k>
    
    rule <k> "hw.array_concat" ( Vs:ValueIdList ) : ( _:Types ) -> ( T:HwArrayType )
            => Vs ~> #HwArrayConcat ~> T
            ...
        </k>

    
    // hw.array_concat
    rule <k> L:List ~> #HwArrayConcat ~> T:HwArrayType => BitsConcat(ListStdValue2Bits(L)) : T ... </k>

    // hw.array_create
    rule <k> L:List ~> #HwArrayCreate ~> T:HwArrayType => BitsConcat(ListStdValue2Bits(L)) : T ... </k>

    // hw.array_get
    rule <k> ListItem(Arr:Bits : !hw.array < _:SizeX T:Type >) ListItem(bits(Idx:Int, _:Int) : _:IntegerType) ~> #HwArrayGet 
            => BitsSlice(Arr, Idx *Int getWidth(T), (Idx +Int 1) *Int getWidth(T)) : T
            ... 
        </k>
    
    rule <k> ListItem(_:Bits : !hw.array < _:SizeX T:Type >) ListItem(bits(_:XZ, _:Int) : _:IntegerType) ~> #HwArrayGet 
            => bits(#x, getWidth(T)) : T
            ... 
        </k>
    

    // hw.array_slice
    rule <k> ListItem(Arr:Bits : !hw.array < _:SizeX T:Type >) ListItem(bits(Idx:Int, _:Int) : _:IntegerType)
            ~> #HwArraySlice ~> !hw.array < S:SizeX T:Type > 
            => BitsSlice(Arr, Idx *Int getWidth(T), (Idx +Int SizeX2Size(S)) *Int getWidth(T)) : !hw.array < S T > 
            ...
        </k>
    
    rule <k> ListItem(_:Bits : !hw.array < _:SizeX T:Type >) ListItem(bits(_:XZ, _:Int) : _:IntegerType) 
            ~> #HwArraySlice ~> !hw.array < S:SizeX T:Type > 
            => bits(#x, SizeX2Size(S) *Int getWidth(T)) : !hw.array < S T > 
            ...
        </k>


endmodule