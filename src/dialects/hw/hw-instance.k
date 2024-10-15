requires "../../circt/circt.k"


module HW-INSTANCE-SYNTAX
    imports CIRCT-SYNTAX

    syntax String ::= pathJoin(String, String) [function]

    rule pathJoin(Base:String, Dst:String) => Base +String "/" +String Dst

    syntax KmdCIRCT ::= "#HwInstance"
endmodule



module HW-INSTANCE
    imports HW-INSTANCE-SYNTAX
    
    // hw.instance
    // rule <k> 
    //         (.K => 0 ~> M["instanceName"]) ~>
    //         (
    //             Res:OpResults = "hw.instance" ( Vs:ValueIdList ) { M:Map } : ( T1:Types ) -> ( T2:Types )
    //             => Res ~> "hw.instance" ( Vs ) { M } : ( T1 ) -> ( T2 )
    //         )
    //         ... 
    //     </k>
    //     <cmd> #bootstrap ... </cmd>
    
    // rule <k> (Index:Int => Index +Int 1) ~> Inst:String ~> (X:ValueId, Xs:OpResults => Xs) ... </k>
    //     <cid> Base:String </cid>
    //     <locals> Locals:Map => Locals [X <- #OutPortRef(Base +String "/" +String Inst, Index) ] </locals>
    //     <cmd> #bootstrap ... </cmd>
    
    // rule <k> (Index:Int => Index +Int Size) ~> Inst:String ~> (X:ValueId : Size:IntegerLiteral, Xs:OpResults => Xs) ... </k>
    //     <cid> Base:String </cid>
    //     <locals> Locals:Map => Locals [X <- #OutPortRef(Base +String "/" +String Inst, Index, Index +Int Size) ] </locals>
    //     <cmd> #bootstrap ... </cmd>
    
    // rule <k> _:Int ~> _:String ~> .OpResults => .K ... </k>
        // <cmd> #bootstrap ... </cmd>

    // rule <k> "hw.instance" ( VL:ValueIdList ) { Attr:Map } : ( _:Types ) -> ( _:Types )
    //         => Attr["instanceName"] ~> Attr ["moduleName"] ~> VL ~> #HwInstance
    //         ...
    //     </k>
    //     <cmd> #bootstrap ... </cmd>

    // rule <ckts>
    //         ...
    //         <ckt>
    //             <cid> Parent:String </cid>
    //             <k> Inst:String ~> Mod:SymbolRefId :: .SymbolRefIdList ~> VL:ValueIdList ~> #HwInstance => .K ... </k>
    //             ...
    //         </ckt>
    //         (.Bag =>
    //         <ckt>
    //             <cid> Parent +String "/" +String Inst </cid>
    //             <k> Op </k>
    //             <module> SymbolRefId2String(Mod) </module>
    //             <args> ValueRefListWrapper(VL, Parent) </args>
    //             ...
    //         </ckt>)
    //         ...
    //     </ckts>
    //     <running> L:List => L ListItem(Parent +String "/" +String Inst) </running>
    //     <boot> Boot:List => Boot ListItem(Parent +String "/" +String Inst) </boot>
    //     <table> ... SymbolRefId2String(Mod) |-> Op ... </table>
    //     <cmd> #bootstrap ... </cmd>

    rule <k> "hw.instance" (_:ValueIdList) {_:Map} : (_:Types) -> (_:Types) => .K ... </k>

    rule <k> Res:OpResults = "hw.instance" ( Vs:ValueIdList ) { Attr:Map } : ( _:Types ) -> ( _:Types ) 
            => 0 ~> Res ~> #HwInstance ~> Attr["instanceName"] ~> Attr["moduleName"] ~> Vs
            ... 
        </k>
        <cmd> #bootstrap ... </cmd>
        requires "instanceName" in_keys(Attr) andBool "moduleName" in_keys(Attr)

    // build OutPortRef
    rule <k> (Idx:Int => Idx +Int 1) ~> (X:ValueId, Xs:OpResults => Xs) ~> #HwInstance ~> Inst:String ... </k>
        <cid> Base:String </cid>
        <locals> M:Map => M [X <- #OutPortRef(pathJoin(Base, Inst), Idx) ] </locals>
        <cmd> #bootstrap ... </cmd>

    rule <k> (Idx:Int => Idx +Int S) ~> (X:ValueId : S:IntegerLiteral, Xs:OpResults => Xs) ~> #HwInstance ~> Inst:String ... </k>
        <cid> Base:String </cid>
        <locals> Locals:Map => Locals [X <- #OutPortRef(pathJoin(Base, Inst), Idx, Idx +Int S) ] </locals>
        <cmd> #bootstrap ... </cmd>

    rule <k> (_:Int ~> .OpResults => .K) ~> #HwInstance ... </k>
        <cmd> #bootstrap ... </cmd>


    // build ckt cell
    rule <ckts> 
            ...
            <ckt>
                <cid> Parent:String </cid>
                <k> #HwInstance ~> Inst:String ~> Module:SymbolRefId :: .SymbolRefIdList ~> Vs:ValueIdList => .K ... </k>
                ...
            </ckt>
            (.Bag =>
                <ckt>
                    <cid> pathJoin(Parent, Inst) </cid>
                    <k> Body </k>
                    <module> SymbolRefId2String(Module) </module>
                    // <args> ValueRefListWrapper(Vs, Parent) </args>
                    <arg-vars> Vs </arg-vars>
                    ...
                </ckt>)
            ...
        </ckts>
        <running> L:List => L ListItem(pathJoin(Parent, Inst)) </running>
        <boot> Boot:List => Boot ListItem(pathJoin(Parent, Inst)) </boot>
        <table> ... SymbolRefId2String(Module) |-> Body ... </table>
        <cmd> #bootstrap ... </cmd>

endmodule