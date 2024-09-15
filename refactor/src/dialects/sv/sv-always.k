requires "./sv.k"

module SV-INITIAL
    imports SV-SYNTAX

    // ----------------------------------- initial task ------------------------------------------

    // load initial blocks
    rule <ckt>
            <cid> Inst </cid>
            <k> .K => #SvInitial ~> Inits </k>
            <initial> Inits:List </initial>
            ...
        </ckt>
        <cmd> (ListItem(Inst) L:List => L) ~> #initial ... </cmd>
        <running> Running:List => Running ListItem(Inst) </running>

    // start initial blocks
    rule <cmd> .List ~> #initial => #initial ... </cmd>

    // initial block done
    rule <ckt>
            <cid> Inst </cid>
            <k> .K </k>
            ...
        </ckt>
        <cmd> #initial ... </cmd>
        <running> L:List ListItem(Inst) => L </running>

    // initial task done
    rule <cmd> #initial => ListItem(Entry) ~> Boot ... </cmd>
        <running> .List </running>
        <boot> ListItem(Entry) Boot:List </boot>
        

    rule <k> (.K => Op) ~> #SvInitial ~> (ListItem(Op:Operation) L:List => L) ... </k>
        <cmd> #initial ... </cmd>
    
    rule <k> #SvInitial ~> .List => .K ... </k>
        <cmd> #initial ... </cmd>

    rule <k> "sv.initial" ( .ValueIdList ) ( R:Region ) : ( .Types ) -> ( .Types ) => R ... </k>
        <cmd> #initial ... </cmd>

    rule <k> { OL:OperationList B:BlockList } => OL ~> B ... </k>
        <cmd> #initial ... </cmd>

    rule <k> B:Block BL:BlockList => B ~> BL ... </k>
        <cmd> #initial ... </cmd>
    
    rule <k> .BlockList => .K ... </k>
        <cmd> #initial ... </cmd>

    rule <k> Op:Operation Ops:OperationList => Op ~> Ops ... </k>
        <cmd> #initial ... </cmd>

    rule <k> .OperationList => .K ... </k>
        <cmd> #initial ... </cmd>

endmodule


module SV-ALWAYS
    imports SV-SYNTAX

    // -------------------------- bootstrap phase -----------------------------

    rule <k> "sv.initial" ( .ValueIdList ) ( R:Region ) : ( .Types ) -> ( .Types ) => .K ... </k>
        <initial> L:List => L ListItem("sv.initial" ( .ValueIdList ) ( R ) : ( .Types ) -> ( .Types )) </initial>
        <cmd> #bootstrap ... </cmd>
    
    rule <k> "sv.always" ( VL:ValueIdList ) ( R:Region ) { Attr:Map } : ( .Types ) -> ( .Types ) => .K ... </k>
        <always> L:List => L ListItem("sv.always" ( VL ) ( R ) { Attr } : ( .Types ) -> ( .Types )) </always>
        <cmd> #bootstrap ... </cmd>


    // ----------------------------------- always task ------------------------------------------

    // load always blocks, entry module
    rule <ckt>
            <cid> Inst </cid>
            <k> .K => #SvAlways ~> Bs ~> #HwOutput </k>
            <always> Bs:List </always>
            <args> _ => Args </args>
            ...
        </ckt>
        <cmd> (ListItem(Inst) => .K) ~> _:List ~> #always ... </cmd>
        <running> Running:List => Running ListItem(Inst) </running>
        <input> Args:List </input>

    // load always blocks, sub-modules
    rule <ckt>
            <cid> Inst </cid>
            <k> .K => #SvAlways ~> Bs ~> #HwOutput </k>
            <always> Bs:List </always>
            ...
        </ckt>
        <cmd> (ListItem(Inst) L:List => L) ~> #always ... </cmd>
        <running> Running:List => Running ListItem(Inst) </running>
        
    // start always blocks
    rule <cmd> .List ~> #always => #always ... </cmd>

    // always block done
    rule <ckt>
            <cid> Inst </cid>
            <k> .K </k>
            ...
        </ckt>
        <cmd> #always ... </cmd>
        <running> L:List ListItem(Inst) => L </running>

    // always task done
    rule <cmd> #always => #end ... </cmd>
        <running> .List </running>
        // <boot> Boot:List </boot>
        
    
    rule <k> (.K => Op) ~> #SvAlways ~> (ListItem(Op:Operation) L:List => L) ... </k>
        <cmd> #always ... </cmd>
    
     rule <k> #SvAlways ~> .List => .K ... </k>
        <cmd> #always ... </cmd>
    
    // rule <k> (.List => .K) ~> #HwOutput ... </k>
    //     <cmd> #always ... </cmd>

    rule <k> "sv.always" ( .ValueIdList ) ( R:Region ) { _:Map } : ( .Types ) -> ( .Types ) => R ... </k>
        <cmd> #always ... </cmd>

    rule <k> { OL:OperationList B:BlockList } => OL ~> B ... </k>
        <cmd> #always ... </cmd>

    rule <k> B:Block BL:BlockList => B ~> BL ... </k>
        <cmd> #always ... </cmd>
    
    rule <k> .BlockList => .K ... </k>
        <cmd> #always ... </cmd>

    rule <k> Op:Operation Ops:OperationList => Op ~> Ops ... </k>
        <cmd> #always ... </cmd>

    rule <k> .OperationList => .K ... </k>
        <cmd> #always ... </cmd>
endmodule