requires "./seq.k"

module SEQ-FIRREM
    imports SEQ-SYNTAX

    rule <k> X:ValueId = "seq.firmem" ( .ValueIdList ) { _:Map } : ( .Types ) -> ( _:SeqFirmemType ) => .K ... </k>
        <firmem> M:Map => M [X <- .Map] </firmem>
        <cmd> #bootstrap ... </cmd>
    


    // seq.firmem.read_port
    rule <k> X:ValueId = "seq.firmem.read_port" (Mem:ValueId, Addr:ValueId, Clk:ValueId) : ( Ts:Types ) -> ( T:Type ) => .K ... </k>
        <always> L:List => L ListItem(X = "seq.firmem.read_port" (Mem, Addr, Clk) : (Ts) -> (T)) </always>
        <locals> M:Map => M [ X <- bits(#x, getWidth(T)) : T ] </locals>
        <last-vars> S:Set => S SetItem(Clk) </last-vars>
        <cmd> #bootstrap ... </cmd>

    rule <k> X:ValueId = "seq.firmem.read_port" (Mem:ValueId, Addr:ValueId, Clk:ValueId) : ( _:Types ) -> ( _:Type )
            => Clk ~> M[Clk] orDefault "???" ~> 0 ~> #EdgeCheck 
            ~> Addr ~> #SeqFirmemRead ~> Mem ~> X
            ... 
        </k>
        <last> M:Map </last>
        <cmd> #always ... </cmd>
    
    // rule <k> (_:StdValue ~> "???" ~> _:Int ~> #EdgeCheck => .K) ~> _:ValueId ~> #SeqFirmemRead ... </k>
    // rule <k> (false ~> #EdgeCheck => .K) ~> _:ValueId ~> #SeqFirmemRead ... </k>
    // rule <k> (true  ~> #EdgeCheck => .K) ~> _:ValueId ~> #SeqFirmemRead ... </k>

    rule <k> false ~> #EdgeCheck ~> _:ValueId ~> #SeqFirmemRead ~> _:ValueId ~> _:ValueId => .K ... </k>
    rule <k> (true ~> #EdgeCheck => .K) ~> _:ValueId ~> #SeqFirmemRead ~> _:ValueId ~> _:ValueId ... </k>

    // update firmem ref
    rule <k> bits(Addr:Int, _) : _:IntegerType 
            ~> #SeqFirmemRead ~> Mem:ValueId ~> X:ValueId
            => .K
            ... 
        </k>
        <locals> Locals:Map => Locals [ X <- M [Addr] ] </locals>
        <firmem>... Mem |-> M:Map ...</firmem>
        requires Addr in_keys(M)

    

    // seq.firmem.write_port
    rule <k> "seq.firmem.write_port" (Mem, Addr, Clk, Enable, Data) {Attr:Map} : (Ts:Types) -> (.Types) 
            => .K 
            ... 
        </k>
        <always> 
            L:List => L ListItem(
                "seq.firmem.write_port" (Mem, Addr, Clk, Enable, Data) {Attr} : (Ts) -> (.Types)
            ) 
        </always>
        <last-vars> S:Set => S SetItem(Clk) </last-vars>
        <cmd> #bootstrap ... </cmd>

    rule <k> "seq.firmem.write_port" (Mem, Addr, Clk, Enable, Data) {_:Map} : (_:Types) -> (.Types)
            => Clk ~> M[Clk] orDefault "???" ~> 0 ~> #EdgeCheck 
            ~> (Addr, Data, Enable):ValueIdList ~> #SeqFirmemWrite ~> Mem
            ... 
        </k>
        <last> M:Map </last>
        <cmd> #always ... </cmd>

    rule <k> false ~> #EdgeCheck ~> _:ValueIdList ~> #SeqFirmemWrite ~> _:ValueId => .K ... </k>
    rule <k> (true ~> #EdgeCheck => .K) ~> _:ValueIdList ~> #SeqFirmemWrite ~> _:ValueId ... </k>

    // enable == true
    rule <k> ListItem(bits(Addr:Int, _) : _:IntegerType) ListItem(Data:StdValue) ListItem(bits(1, 1) : i1) 
            ~> #SeqFirmemWrite ~> Mem:ValueId => .K
            ...
        </k>
        <firmem> ... Mem |-> (M:Map => M[Addr <- Data]) ... </firmem>

    // enable == false
    rule <k> ListItem(_:StdValue) ListItem(_:StdValue) ListItem(bits(0, 1) : i1) 
            ~> #SeqFirmemWrite ~> _Mem:ValueId => .K
            ...
        </k>



    // seq.firmem.read_write_port
    rule <k> X:ValueId = "seq.firmem.read_write_port" (Mem, Addr, Clk, Enable, Data, Mode) {Attr:Map} : (Ts:Types) -> (T:Type) 
            => .K
            ... 
        </k>
        <always> 
            L:List => L ListItem(
                X = "seq.firmem.read_write_port" (Mem, Addr, Clk, Enable, Data, Mode) {Attr} : (Ts) -> (T)
            ) 
        </always>
        <locals> M:Map => M [ X <- bits(#x, getWidth(T)) : T ] </locals>
        <last-vars> S:Set => S SetItem(Clk) </last-vars>
        <cmd> #bootstrap ... </cmd>

    rule <k> X:ValueId = "seq.firmem.read_write_port" (Mem, Addr, Clk, Enable, Data, Mode) {_:Map} : (_:Types) -> (_:Type)
            => Clk ~> M[Clk] orDefault "???" ~> 0 ~> #EdgeCheck 
            ~> (Addr, Data, Enable, Mode):ValueIdList ~> #SeqFirmemReadWrite ~> Mem ~> X
            ...
        </k>
        <last> M:Map </last>
        <cmd> #always ... </cmd>
    
    rule <k> false ~> #EdgeCheck ~> _:ValueIdList ~> #SeqFirmemReadWrite ~> _:ValueId ~> _:ValueId => .K ... </k>
    rule <k> (true ~> #EdgeCheck => .K) ~> _:ValueIdList ~> #SeqFirmemReadWrite ~> _:ValueId ~> _:ValueId ... </k>

    // enable == true, mode == 1 (write)
    rule <k> 
            ListItem(bits(Addr, _:Int) : _:IntegerType) 
            ListItem(Data:StdValue) 
            ListItem(bits(1, 1) : i1) ListItem(bits(1, 1) : i1) 
            ~> #SeqFirmemReadWrite ~> Mem:ValueId ~> _X:ValueId => .K
            ...
        </k>
        <firmem> ... Mem |-> (M:Map => M[Addr <- Data]) ... </firmem>
    
    // enable == true, mode == 0 (read)
    rule <k> 
            ListItem(bits(Addr, _:Int) : _:IntegerType) 
            ListItem(_Data:StdValue) 
            ListItem(bits(1, 1) : i1) ListItem(bits(0, 1) : i1) 
            ~> #SeqFirmemReadWrite ~> Mem:ValueId ~> X:ValueId => .K
            ...
        </k>
        <locals> Locals:Map => Locals [ X <- M [Addr] ] </locals>
        <firmem> ... Mem |-> M:Map ... </firmem>
        requires Addr in_keys(M)

    // enable == false
    rule <k> 
            ListItem(_:StdValue) ListItem(_:StdValue) 
            ListItem(bits(0, 1) : i1) ListItem(bits(_:Int, 1) : i1) 
            ~> #SeqFirmemReadWrite ~> _Mem:ValueId ~> _X:ValueId => .K
            ...
        </k>
endmodule