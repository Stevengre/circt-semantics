requires "./seq.k"

module SEQ-FIRREG
    imports SEQ-SYNTAX

    // ---------------- bootstrap phase --------------------

    rule <k> X:ValueId = "seq.firreg" (Next, Clk, Rst, RstValue) {Attr:Map} : (Ts:Types) -> (T:Type) => .K ... </k>
        <locals> Locals:Map => Locals [ X <- seq.firreg({Attr["name"]}:>String, T, bits(#x, getWidth(T)) : T) ] </locals>
        // <regs> Regs:Map => Regs [ X <- seq.firreg({Attr["name"]}:>String, false, #x) ] </regs>
        <always> L:List => L ListItem(X = "seq.firreg" (Next, Clk, Rst, RstValue) {Attr} : (Ts) -> (T)) </always>
        <last-vars> S:Set => S SetItem(Clk) </last-vars>
        <cmd> #bootstrap ... </cmd>



    // ----------------- clock phase ------------------

    // firreg lookup
    rule <k> seq.firreg ( _:String , _:Type , V:StdValue ) => V ... </k>
    
    rule <k> X:ValueId = "seq.firreg" (Next, Clk, Rst, RstValue) {_:Map} : (_:Types) -> (_:Type) 
            => Clk ~> M[Clk] orDefault "???" ~> 0 ~> #EdgeCheck 
            ~> (Next, Rst, RstValue):ValueIdList ~>#SeqFirreg ~> X
            ... 
        </k>
        <last> M:Map </last>
        <cmd> #always ... </cmd>
    
    // edge check failed
    rule <k> #EdgeCheck ~> _:ValueIdList ~> #SeqFirreg ~> _:ValueId => .K ... </k>

    // edge check success
    rule <k> (true ~> #EdgeCheck => .K) ~> _:ValueIdList ~> #SeqFirreg ~> _:ValueId ... </k>

    rule <k> 
            (
                ListItem ( Next:StdValue )
                ListItem ( bits ( Rst:Int , 1 ) : #token("i1", "SignlessIntegerType") )
                ListItem ( RstValue:StdValue ) 
                => #if Rst ==Int 0 #then Next #else RstValue #fi
            )
            ~> #SeqFirreg ~> _:ValueId
            ...
        </k>
    
    rule <k> V:StdValue ~> #SeqFirreg ~> X:ValueId => .K ... </k>
        <locals> ... X |-> seq.firreg(_:String , _:Type , _ => V ) ... </locals>
endmodule