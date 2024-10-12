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

    // initial task done, start always task
    rule <cmd> #initial => ListItem(Entry) ~> Boot ~> #always ... </cmd>
        <running> .List </running>
        <boot> ListItem(Entry) Boot:List </boot>
        
    // start an initial block
    rule <k> (.K => Op) ~> #SvInitial ~> (ListItem(Op:Operation) L:List => L) ... </k>
        <cmd> #initial ... </cmd>
    
    // all initial blocks done
    rule <k> #SvInitial ~> .List => #Last ~> S ... </k>
        <cmd> #initial ... </cmd>
        <last-vars> S:Set </last-vars>

    // evaluate last values
    rule <k> #Last ~> (SetItem(V:ValueId) S:Set => S) ... </k>
        <last> M:Map => M [V <- #None]</last>
        <cmd> #initial ... </cmd>

    rule <k> #Last ~> .Set => .K ... </k>
        <cmd> #initial ... </cmd>

    
    // sv.initial
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
    imports SV-HELPER

    // -------------------------- bootstrap phase -----------------------------

    rule <k> "sv.initial" ( .ValueIdList ) ( R:Region ) : ( .Types ) -> ( .Types ) => .K ... </k>
        <initial> L:List => L ListItem("sv.initial" ( .ValueIdList ) ( R ) : ( .Types ) -> ( .Types )) </initial>
        <cmd> #bootstrap ... </cmd>
    
    rule <k> "sv.always" ( VL:ValueIdList ) ( R:Region ) { Attr:Map } : ( Ts:Types ) -> ( .Types ) => .K ... </k>
        <always> L:List => L ListItem("sv.always" ( VL ) ( R ) { Attr } : ( Ts ) -> ( .Types )) </always>
        <last-vars> S:Set => S toSet(VL) </last-vars>
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
        <input> ListItem(Args:List) L:List => L </input>

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

    // instance always task done
    rule <ckt>
            <cid> Inst </cid>
            <k> .K </k>
            ...
        </ckt>
        <cmd> #always ... </cmd>
        <running> L:List ListItem(Inst) => L </running>

    // always task done, always again
    rule <cmd> #always => ListItem(Entry) ~> Boot ~> #always ... </cmd>
        <running> .List </running>
        <input> ListItem(_:List) _:List </input>
        <boot> ListItem(Entry) Boot:List </boot>
    
    // all input consumed, end
    rule <cmd> #always => #end ... </cmd>
        <running> .List </running>
        <input> .List </input>
        
    // fetch one always block
    rule <k> (.K => Op) ~> #SvAlways ~> (ListItem(Op:Operation) L:List => L) ... </k>
        <cmd> #always ... </cmd>
    
    // all always blocks done
    rule <k> #SvAlways ~> .List => #Last ~> S ... </k>
        <last-vars> S:Set </last-vars>
        <cmd> #always ... </cmd>

    // evaluate last values
    rule <k> (.K => V) ~> #Last ~> SetItem(V:ValueId) _:Set ... </k>
        <cmd> #always ... </cmd>

    rule <k> (X:StdValue => .K) ~> #Last ~> (SetItem(V:ValueId) S:Set => S) ... </k>
        <last> M:Map => M [V <- X] </last>

    rule <k> #Last ~> .Set => .K ... </k>
        <cmd> #always ... </cmd>

    
    // rule <k> (.List => .K) ~> #HwOutput ... </k>
    //     <cmd> #always ... </cmd>

    // sv.always
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


    rule <k> "sv.always" ( VL:ValueIdList ) ( R:Region ) { Attr:Map } : ( _:Types ) -> ( .Types ) 
            => #EdgeCheck ~> VL ~> Attr["events"] orDefault "??? no `events` attr" ~> R 
            ... 
        </k>
        <cmd> #always ... </cmd>
    
    rule <k> (.K => V ~> M[V] orDefault "??? " +String str(V) ~> Event) ~> #EdgeCheck 
            ~> (V:ValueId, VL:ValueIdList => VL) 
            ~> [Event:Int : _:IntegerType, AL:AttributeValueList => AL]
            ... 
        </k>
        <last> M:Map </last>
    
    rule <k> #EdgeCheck ~> .ValueIdList ~> [.AttributeValueList] ~> _:Region => .K ... </k>

    rule <k> (_:StdValue ~> #None ~> _Event:Int => false) ~> #EdgeCheck ... </k>

    rule <k> (
                bits(Right:Int, 1) : #token("i1", "SignlessIntegerType") 
                ~> bits(Left:Int, 1) : #token("i1", "SignlessIntegerType")
                ~> Event:Int => eventCheck(Left, Right, Event)
            ) ~> #EdgeCheck 
            ... 
        </k>

    rule <k> (false => .K) ~> #EdgeCheck ~> _:ValueIdList ~> [_:AttributeValueList] ~> _:Region  ... </k>
    rule <k> true ~> #EdgeCheck ~> _:ValueIdList ~> [_:AttributeValueList] ~> R:Region => R ... </k>
endmodule