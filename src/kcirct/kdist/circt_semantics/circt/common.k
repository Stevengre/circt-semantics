requires "../mlir/mlir.k"
requires "../mlir/builtin.k"
requires "./bits.k"
requires "./stdvalue.k"
requires "./conf.k"
requires "../dialects/hw/hw-inout.k"

module COMMON-SYNTAX
    imports BITS
    imports STDVALUE
    imports BUILTIN

    syntax KmdCIRCT ::= "#KClockFinish" 
                      | "#KFinish"
    
    // - Return Values to the parent circuit
    syntax KmdCIRCT ::= "#KCallBack" String

    syntax CmdCIRCT ::= "#CIRCTstimulate" SymbolRefId "(" AttributeValueList ")"
    syntax KmdCIRCT ::= "#Kstimulate" String "(" StdValues ")" "by" String "as" String

    syntax CmdCIRCT ::= "#CirctGetOp" SymbolRefId
    syntax KmdCIRCT ::= "#KgetOp" String

    syntax KmdCIRCT ::= "#KReadOuts"

    syntax CmdCIRCT ::= "#CIRCTrefineOp"
    syntax KmdCIRCT ::= "#KrefineOp"

    syntax KmdCIRCT ::= "#KWArgs" AttributeValueList 
                      | "#KWArgs" StdValues
                      | "#KWArgs" List
    
    syntax CmdCIRCT ::= "#CIRCTinitOp" String "(" AttributeValueList ")"
    syntax KmdCIRCT ::= "#KinitOp" String StdValues "by" String "as" String

    syntax Ref ::= "#OutPortRef" "(" String "," Int ")"
                 | "#OutPortRef" "(" String "," Int "," Int ")"
                 | "#InPortRef" "(" String "," ValueId ")"
                 | "#ValueRef" "(" String "," ValueId ")"
                 | "#ArgRef" "(" Int ")"

    
    syntax KmdCIRCT ::= "#SvPassign"
                      | "#HwOutput"
                      | "#ValueIdIndexLookup"
                      | "#ValueRefLookup"
                      | "#Last"
                      | "#EdgeCheck"

    syntax KmdCIRCT ::= "#done"
    
    syntax CmdCIRCT ::= "#bootstrap"
                      | "#initial"
                      | "#always"
                      | "#end"
endmodule


module COMMON-HELPER
    imports COMMON-SYNTAX

    // Execute a CIRCT Command
    syntax CmdCIRCT ::= "#CIRCTpreprocess" // Do nothing, but just preprocess
                      | "#Stop" String
    
    // Effect Handlers used in <k>
    syntax KmdCIRCT ::= "#KHalt" String
                      | "#KReadCurr" ValueIdList // Read the value from the current state
                      | "#KWriteCurr" ValueIdList // Write the value to the current state

    syntax Int ::= Type2BitSize ( Type ) [function]
    rule Type2BitSize( T:IntegerType ) => getIntegerTypeSize(T)

    syntax List ::= ValueRefListWrapper(ValueIdList, String) [function]
    rule ValueRefListWrapper(V:ValueId, VL:ValueIdList, Inst:String) => ListItem(#ValueRef(Inst, V)) ValueRefListWrapper(VL, Inst)
    rule ValueRefListWrapper(.ValueIdList, _:String) => .List
endmodule


module COMMON
    imports COMMON-HELPER
    imports CIRCT-CONF
    imports HW-INOUT-SYNTAX
    imports COMB-SYNTAX

    // rule <phase> #preprocess => #toStimulate </phase>
    //     <prog> .K </prog>

    // bootstrap, entry module
    rule <phase> #toStimulate => #build </phase>
        <entry> ID:String </entry>
        <table> M:Map </table>
        <cmd> .K => #bootstrap ... </cmd>
        <ckts>
            (.Bag =>
            <ckt>
                <cid> ID </cid>
                <k> M [ID] orDefault "no such module: " +String ID </k> 
                <module> ID </module>
                // <args> toList(Vs) </args>
                ...
            </ckt>)
        </ckts>
        <running> L:List => L ListItem(ID) </running>
        <boot> Boot:List => Boot ListItem(ID) </boot>
    
    rule <ckt>
            <cid> Inst </cid>
            <k> .K </k> 
            ...
        </ckt>
        <cmd> #bootstrap ... </cmd>
        <running> L:List ListItem(Inst) => L </running>
    

    // bootstrap end
    // rule <cmd> #bootstrap => Boot ~> #initial ... </cmd>
    //     <running> .List </running>
    //     <boot> Boot:List </boot>
        

    // rule <k>
    //         "hw.module" ( .ValueIdList ) ( { .OperationList B:Block } ) { _:Map } : ( .Types ) -> ( .Types )
    //         => B
    //         ...
    //     </k>

    // rule <k>
    //         "hw.module" ( .ValueIdList ) ( { OL:OperationList B:Block } ) { _:Map } : ( .Types ) -> ( .Types )
    //         => OL ~> B
    //         ...
    //     </k>

    rule <k> OpName:String (VL:ValueIdList) [ .Successors ] ( Rs:Regions ) { Attr:Map } : FT:FunctionType 
            => OpName (VL) (Rs) {Attr} : FT
            ...
        </k>
        <cmd> #bootstrap ... </cmd>

    rule <k> .OpResults = OpName:String (VL:ValueIdList) [ .Successors ] ( Rs:Regions ) { Attr:Map } : FT:FunctionType 
            => OpName (VL) (Rs) {Attr} : FT
            ...
        </k>
        <cmd> #bootstrap ... </cmd>

    
    rule <k> { OL:OperationList B:BlockList } => OL ~> B ... </k>
        <cmd> #bootstrap ... </cmd>

    rule <k> B:Block BL:BlockList => B ~> BL ... </k>
        <cmd> #bootstrap ... </cmd>
    
    rule <k> .BlockList => .K ... </k>
        <cmd> #bootstrap ... </cmd>

    rule <k> Op:Operation Ops:OperationList => Op ~> Ops ... </k>
        <cmd> #bootstrap ... </cmd>

    rule <k> .OperationList => .K ... </k>
        <cmd> #bootstrap ... </cmd>

    rule <k> BL:BlockLabel OL:OperationList => 0 ~> BL ~> OL ... </k>
        <cmd> #bootstrap ... </cmd>

    rule <k> (Index:Int => Index +Int 1) ~> ^bb0 ( X:ValueId : _:Type , VTs:ValueIdAndTypeList => VTs ) : ... </k>
        <locals> Locals:Map => Locals [X <- #ArgRef(Index)] </locals>
        <cmd> #bootstrap ... </cmd>
    
    rule <k> _:Int ~> ^bb0 ( .ValueIdAndTypeList ) : => .K ... </k>
        <cmd> #bootstrap ... </cmd>

    rule <k> 0 ~> ^bb0 : => .K ... </k>
        <cmd> #bootstrap ... </cmd>

    // SSA statements
    rule <k> X:ValueId = Op:GenericOperation => .K ... </k>
        <locals> Locals:Map => Locals [X <- Op] </locals>
        <cmd> #bootstrap ... </cmd>
        [owise]

    rule <k> X:ValueId : _:IntegerLiteral = Op:GenericOperation => .K ... </k>
        <locals> Locals:Map => Locals [X <- Op] </locals>
        <cmd> #bootstrap ... </cmd>
        [owise]


    
    // lookup ValueId
    rule <k> X:ValueId => M [X] ... </k>
        <locals> M:Map </locals>
        requires X in_keys(M)


    // lookup ValueId with index: %foo#0, %foo#1
    rule <k> 
            X:ValueId => #ValueIdIndexLookup ~> ValueId2String(X) ~> findChar(ValueId2String(X), "#", 0)
            ... 
        </k>
        requires findChar(ValueId2String(X), "#", 0) >Int -1

    rule <k> #ValueIdIndexLookup ~> S:String ~> Idx:Int
            => String2ValueId(substrString(S, 0, Idx)) 
            ~> #ValueIdIndexLookup 
            ~> String2Int(substrString(S, Idx +Int 1, lengthString(S)))
            ... 
        </k>

    rule <k> L:List ~> #ValueIdIndexLookup ~> Idx:Int => L[Idx] ... </k>
    

    // lookup ValueIdList
    rule <k> VL:ValueIdList => .List ~> VL ... </k>
    rule <k> (.K => X) ~> _:List ~> (X:ValueId, VL:ValueIdList => VL) ... </k>
    rule <k> (V:StdValue => .K) ~> (L:List => L ListItem(V)) ... </k>
    rule <k> L:List ~> .ValueIdList => L ... </k>


    // ---------- value ref -----------
    // rule <k> #ArgRef ( Index:Int ) => Args[Index] ~> #ArgRef ( Index ) ... </k>
    //     <args> Args:List </args>

    rule <k> #ArgRef ( Index:Int ) => Args[Index] ... </k>
        <args> Args:List </args>
        requires Index <Int size(Args)

    // rule <k> V:StdValue ~> #ArgRef ( Index:Int ) => V ... </k>
    //     <in-ports> M:Map => M [ L[Index] <- V ] </in-ports>
    //     <in-names> L:List </in-names>

    // lookup args
    rule <ckt>
            <k> #OutPortRef (Inst:String, Index:Int) => Vs ~> #OutPortRef(Inst, Index) ... </k>
            ...
        </ckt> 
        <ckt>
            <cid> Inst </cid>
            <args> .List </args>
            <arg-vars> Vs:ValueIdList </arg-vars>
            ...
        </ckt>
        requires size(toList(Vs)) >Int 0

    rule <ckt>
            <k> #OutPortRef (Inst:String, Index:Int, End:Int) => Vs ~> #OutPortRef(Inst, Index, End) ... </k>
            ...
        </ckt> 
        <ckt>
            <cid> Inst </cid>
            <args> .List </args>
            <arg-vars> Vs:ValueIdList </arg-vars>
            ...
        </ckt>
        requires size(toList(Vs)) >Int 0

    // set args
    rule <ckt>
            <k> (L:List => .K) ~> #OutPortRef(Inst:String, _:Int) ... </k>
            ...
        </ckt> 
        <ckt>
            <cid> Inst </cid>
            <args> .List => L </args>
            <arg-vars> _:ValueIdList </arg-vars>
            ...
        </ckt>
    
    rule <ckt>
            <k> (L:List => .K) ~> #OutPortRef(Inst:String, _:Int, _:Int) ... </k>
            ...
        </ckt> 
        <ckt>
            <cid> Inst </cid>
            <args> .List => L </args>
            <arg-vars> _:ValueIdList </arg-vars>
            ...
        </ckt>


    // lookup outport
    rule <ckt>
            <k> #OutPortRef ( Inst:String , Index:Int ) => L[Index] ... </k>
            ...
        </ckt> 
        <ckt>
            <cid> Inst </cid>
            <k> .K </k>
            <out-ports> L:List </out-ports>
            ...
        </ckt>

    rule <ckt>
            <k> #OutPortRef ( Inst:String , Begin:Int, End:Int) => range(L, Begin, size(L) -Int End) ... </k>
            ...
        </ckt>
        <ckt>
            <cid> Inst </cid>
            <k> .K </k>
            <out-ports> L:List </out-ports>
            ...
        </ckt>

    // use new context, race risk?
    // rule <k> #ValueRef ( Inst:String , V:ValueId ) => #ValueRefLookup ~> Inst ... </k>
    //     <cid> Caller:String </cid>
    //     <ckt>
    //         <cid> Inst </cid>
    //         <k> .K => V ~> Caller ~> #ValueRefLookup ... </k>
    //         // <locals> M:Map </locals>
    //         ...
    //     </ckt>
    //     [priority(200)]

    // rule <k> #ValueRefLookup ~> Callee:String => V ... </k>
    //     <cid> Caller:String </cid>
    //     <ckt>
    //         <cid> Callee </cid>
    //         <k> V:StdValue ~> Caller ~> #ValueRefLookup => .K ... </k>
    //         ...
    //     </ckt>
    //     [priority(1)]


endmodule
