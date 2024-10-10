requires "./seq.k"

module SEQ-FIRREM
    imports SEQ-SYNTAX

    rule <k> X:ValueId = "seq.firmem" ( .ValueIdList ) { _:Map } : ( .Types ) -> ( _:SeqFirmemType ) => .K ... </k>
        <firmem> M:Map => M [X <- .Map] </firmem>
        <cmd> #bootstrap ... </cmd>
    

    
    rule <k> "seq.firmem.read_port" ( Mem:ValueId , Addr:ValueId , Clk:ValueId ) : ( _:Types ) -> ( T:Type )
            => Clk ~> M[Clk] orDefault "???" ~> 0 ~> #EdgeCheck 
            ~> Addr ~> #SeqFirmemRead ~> Mem ~> T
            ... 
        </k>
        <last> M:Map </last>
    
    rule <k> (_:StdValue ~> "???" ~> _:Int ~> #EdgeCheck => .K) ~> _:ValueId ~> #SeqFirmemRead ... </k>
    
    rule <k> bits(Addr:Int, _) : _:IntegerType ~> #SeqFirmemRead ~> Mem:ValueId ~> T:Type 
            => M[Addr] orDefault bits(0, getWidth(T)) : T
            ... 
        </k>
        <firmem>... Mem |-> M:Map ...</firmem>

    
    rule <k> "seq.firmem.write_port" (Mem, Addr, Clk, Enable, X) {Attr:Map} : (Ts:Types) -> (.Types) => .K ... </k>
        <always> L:List => L ListItem("seq.firmem.write_port" (Mem, Addr, Clk, Enable, X) {Attr} : (Ts) -> (.Types)) </always>
        <last-vars> S:Set => S SetItem(Clk) </last-vars>
        <cmd> #bootstrap ... </cmd>

    rule <k> "seq.firmem.write_port" ( _:ValueIdList ) { _:Map } : ( _:Types ) -> ( .Types ) => .K ... </k>
        <cmd> #always ... </cmd>
endmodule