module SV-FOR
    imports SV-SYNTAX

    rule <k> "sv.for" ( Vs:ValueIdList ) ( R:Region ) { _:Map } : ( _:Type, _:Type, _:Type ) -> ( .Types ) 
            => Vs ~> #SvFor ~> R
            ...
        </k>

    // sv.for
    rule <k> 
            ListItem(bits(Start:Int, _:Int) :  _:Type) ListItem(bits(End:Int, _:Int) :  _:Type) ListItem(bits(Step:Int, _:Int) :  _:Type)
            ~> #SvFor ~> R:Region
            => #SvFor ~> Start ~> End ~> Step ~> R:Region
            ...
        </k>

    rule <k> (.K => OL)
            ~> #SvFor 
            ~> (Start:Int => Start +Int Step) ~> End:Int ~> Step:Int 
            ~> { .OperationList (#token("^bb0", "CaretId") ( X:ValueId : T:Type ) : OL:OperationList):Block }
            ... 
        </k>
        <locals> Locals:Map => Locals [X <- bits(Start, getWidth(T)) : T] </locals>
        requires Start <Int End
    

    rule <k> (X:ValueId = Op:GenericOperation => .K)
            ~> _:OperationList ~> #SvFor
            ...
        </k>
        <locals> Locals:Map => Locals [X <- Op] </locals>

    
    rule <k> #SvFor ~> Start:Int ~> End:Int ~> _Step:Int ~> _:Region => .K ... </k>
        requires Start >=Int End

endmodule