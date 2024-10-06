module UTILS
    syntax Value ::= typeCast(Value, Type, Type) [function]

    syntax Int ::= signalEvent(Int, Int) [function]
    
    rule signalEvent(0, 1) => 1
    rule signalEvent(1, 0) => -1
    rule signalEvent(_:Int, _:Int) => 0 [owise]

    rule <k> #KSkip (N:Int => N -Int 1) ~> (_ => .K) ... </k> requires N >Int 0
    rule <k> #KSkip 0 => .K ... </k>

    rule <k> V:StdValue ~> #KUpdateReg X:ValueId ... </k>


    rule <k> 
            (.K => Last[V] orDefault false ~> Curr[V] orDefault false ~> {I}:>Int)
            ~> ([ I:IntegerLiteral : _:IntegerType , As:AttributeValueList ] => [ As ])
            ~> #KEventCheck (V:ValueId, Vs:ValueIdList => Vs)
            ...
        <k>
        <curr> Curr:Map </curr>
        <last> Last:Map </last>
    
    // no last value
    rule <k> 
            (false ~> _:KItem ~> _:Int => false)
            ~> [ _:AttributeValueList ]
            ~> #KEventCheck _Vs:ValueIdList
            ...
        </k>
    
    // event check
    rule <k> circt </k>
        <circt-exec>
            (
                Last:StdValue ~> 
                Curr:StdValue ~> 
                Event:Int
                => eventCheck(StdValue2Int(Last), StdValue2Int(Curr), Event)
            ) ~> [ _:AttributeValueList ]
            ~> #KEventCheck _Vs:ValueIdList
            ...
        </circt-exec>
    
    rule <k> 
            [ .AttributeValueList ] ~> #KEventCheck .ValueIdList => false
            ...
        </k>
    
    rule <k> 
            (false => .K) ~> [ _:AttributeValueList ] ~> #KEventCheck _Vs:ValueIdList
            ...
        </k>

    rule <k> 
            true ~> ([ _:AttributeValueList ] ~> #KEventCheck _Vs:ValueIdList => .K)
            ...
        </k>
endmodule