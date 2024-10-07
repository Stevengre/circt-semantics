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
                 | "#InPortRef" "(" String "," ValueId ")"
                 | "#ValueRef" "(" String "," ValueId ")"
                 | "#ArgRef" "(" Int ")"

    
    syntax KmdCIRCT ::= "#HwInstance"
                      | "#SvPassign"
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

    // refine operation
    // syntax Operation ::= CIRCTrefineOp ( Operation ) [function]
    
    // // - if generate values, but no id to consume them. just throw it away.
    // rule CIRCTrefineOp(Rs = Op:GenericOperation) => CIRCTrefineGop(Op) requires Rs ==K .OpResults
    // rule CIRCTrefineOp(Rs = Op:GenericOperation) => Rs = CIRCTrefineGop(Op) [owise]

    // // ## refine generic operation
    // syntax GenericOperation ::= CIRCTrefineGop ( GenericOperation ) [function]
    
    // // -- 11
    // rule CIRCTrefineGop( N (Vs) [.Successors] <{AL:Map}> (R:Regions) {AL2:Map} : FT )
    //     => N (Vs) <{AL}> (CIRCTrefineRegions(R)) {AL2} : FT
    //     requires AL =/=K .Map andBool R =/=K .Regions
    // // -- 01
    // rule CIRCTrefineGop( N (Vs) [.Successors] <{AL:Map}> (R:Regions) {AL2:Map} : FT )
    //     => N (Vs) (CIRCTrefineRegions(R)) {AL2} : FT
    //     requires AL ==K .Map andBool R =/=K .Regions
    // // -- 10
    // rule CIRCTrefineGop( N (Vs) [.Successors] <{AL:Map}> (R:Regions) {AL2:Map} : FT )
    //     => N (Vs) <{AL}> {AL2} : FT
    //     requires AL =/=K .Map andBool R ==K .Regions
    // // -- 00
    // rule CIRCTrefineGop( N (Vs) [.Successors] <{AL:Map}> (R:Regions) {AL2:Map} : FT )
    //     => N (Vs) {AL2} : FT
    //     requires AL ==K .Map andBool R ==K .Regions
    
    // // -- unexpected
    // rule CIRCTrefineGop(Op:GenericOperation) => Op [owise]
    
    // // refine regions
    // syntax Regions ::= CIRCTrefineRegions (Regions) [function]
    // rule CIRCTrefineRegions(.Regions) => .Regions 
    // rule CIRCTrefineRegions( R:Region, Rs:Regions ) => CIRCTrefine(R) , CIRCTrefineRegions(Rs) [owise]
    
    // // refine region
    // syntax Region ::= CIRCTrefine( Region ) [function]
    // rule CIRCTrefine( {OPs:OperationList BL:BlockList} ) => {CIRCTrefineOps(OPs) CIRCTrefineBlocks(BL)}
    
    // // refine OperationList
    // syntax OperationList ::= CIRCTrefineOps( OperationList ) [function]
    // rule CIRCTrefineOps( .OperationList ) => .OperationList
    // rule CIRCTrefineOps( OP:Operation OPs:OperationList ) => CIRCTrefineOp(OP) CIRCTrefineOps(OPs) [owise]
    
    // // refine BlockList
    // syntax BlockList ::= CIRCTrefineBlocks( BlockList ) [function]
    // rule CIRCTrefineBlocks( .BlockList ) => .BlockList
    // rule CIRCTrefineBlocks( B:Block BL:BlockList ) => CIRCTrefineBlock(B) CIRCTrefineBlocks(BL) [owise]
    
    // // refine Block
    // syntax Block ::= CIRCTrefineBlock( Block ) [function]
    // rule CIRCTrefineBlock( BL:BlockLabel OPs:OperationList ) => BL CIRCTrefineOps(OPs) 

    syntax List ::= toList(AttributeValueList) [function]
    rule toList(V:AttributeValue, VL:AttributeValueList) => ListItem(V) toList(VL)
    rule toList(.AttributeValueList) => .List

    syntax List ::= ValueRefListWrapper(ValueIdList, String) [function]
    rule ValueRefListWrapper(V:ValueId, VL:ValueIdList, Inst:String) => ListItem(#ValueRef(Inst, V)) ValueRefListWrapper(VL, Inst)
    rule ValueRefListWrapper(.ValueIdList, _:String) => .List
endmodule


module COMMON
    imports COMMON-HELPER
    imports CIRCT-CONF
    imports HW-INOUT-SYNTAX
    imports COMB-SYNTAX


    rule <phase> #preprocess => #toStimulate </phase>
        <prog> .K </prog>
        // <cmd> .K => Set2List(keys(M))  ... </cmd>
        // <table> M:Map </table>

    // # Phase Change: Stop/Finish Current Simulation
    // rule <ks>
    //         <kmap>
    //             <kkey> _ </kkey>
    //             <k> #KClockFinish => .K ... </k> 
    //         </kmap>
    //     </ks>
    //     <clock> I:Int => I +Int 1 </clock>
    // todo: #CIRCTinitOp 以结束 和 #KinitOp 以 #KFinish结束

    // rule <ks> 
    //         <kmap>
    //             <kkey> _ </kkey>
    //             <k> #KFinish => #KReadOuts ~> #KFinish ... </k>
    //         </kmap>
    //     </ks>
   
    // rule <ckt>
    //         <cid> CID </cid>
    //         <ks> 
    //             <kmap> 
    //                 <kkey> _ </kkey> 
    //                 <k> TVs:StdValues ~> #KFinish => .K ... </k>
    //             </kmap>
    //         </ks>
    //         <curr> CURR => .Map </curr>
    //         <last> _ => CURR </last>
    //         <parent> FID </parent>
    //         ...
    //     </ckt>
    //     <ckt>
    //         <cid> FID </cid>
    //         <k> #KCallBack CID => TVs ... </k>
    //         ...
    //     </ckt>

    // # Stimuate a circuit with arguments

    // rule <phase> #build => #building </phase>
    //     <cmd> ListItem(Module:) L:List => L ... </cmd>
    //     <table> M:Map </table>
        

   
    
    // - first stimulation
    // rule <phase> #toStimulate </phase>
    //     <cmd> .K => #CirctGetOp String2SymbolRefId(ID) ~> #CIRCTrefineOp ~> ID ~> #bootstrap ~> #initial ~> #always </cmd>
    //     <entry> ID:String </entry>
        
    // rule <phase> #toStimulate </phase>
    //     <cmd> 
    //         #CirctGetOp ID:SymbolRefId
    //         => #if SymbolRefId2String(ID) in_keys(M)
    //         #then M [ SymbolRefId2String(ID) ]
    //         #else #Stop "cannot find operation from <table>" ~> ID
    //         #fi
    //         ... 
    //     </cmd>
    //     <table> M:Map </table>

    
    // rule <phase> #toStimulate </phase>
    //     <cmd> Op:Operation ~> #CIRCTrefineOp => CIRCTrefineOp(Op) ... </cmd>
    
    // rule <k> Op:Operation ~> #KrefineOp => CIRCTrefineOp(Op) ... </k>
    
    
    
    
    // Phase Change: Initialize Operation with Arguments in <cmd>
   
    
    // build the circuit
    // rule <phase> #toStimulate => #build </phase>
    //     <cmd> ( Op:Operation ~> Mod:String => .K ) ~> #bootstrap ... </cmd>
    //     <ckts>
    //         ...
    //         (.Bag =>
    //         <ckt>
    //             <cid> Mod </cid>
    //             <k> Op </k> 
    //             <module> Mod </module>
    //             // <args> toList(Vs) </args>
    //             ...
    //         </ckt>)
    //         ...
    //     </ckts>
    //     <running> L:List => L ListItem(Mod) </running>
    //     <boot> Boot:List => Boot ListItem(Mod) </boot>

    rule <phase> #toStimulate => #build </phase>
        <entry> ID:String </entry>
        <table> M:Map </table>
        <cmd> .K => #bootstrap ... </cmd>
        <ckts>
            ...
            (.Bag =>
            <ckt>
                <cid> ID </cid>
                <k> M [ID] orDefault "no such module" </k> 
                <module> ID </module>
                // <args> toList(Vs) </args>
                ...
            </ckt>)
            ...
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
    rule <cmd> #bootstrap => Boot ~> #initial ... </cmd>
        <running> .List </running>
        <boot> Boot:List </boot>
        
    // rule <k> Op:Operation ~> #KinitOp ID ( TVs ) by FID as CID => #KCallBack CID ... </k>
    //     (.Bag =>
    //     <ckt>
    //        <cid> CID </cid>
    //        <ks> <kmap> <kkey> !_:Int </kkey> <k> Op ~> #KWArgs TVs ~> #KFinish</k> </kmap> </ks>
    //        <circuit> Op </circuit>
    //        <module> ID </module>
    //        <parent> FID </parent>
    //        ...
    //     </ckt>)

    // # Write Arguments to the Entry Block in <k>



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


    // rule <k> 
    //         #token("^bb0", "CaretId") ( VTs:ValueIdAndTypeList ) : OL:OperationList
    //         => #KWArgs Args ~> VTs ~> OL
    //         ...
    //     </k>
    //     <args> Args:List </args>

    rule <k> BL:BlockLabel OL:OperationList => 0 ~> BL ~> OL ... </k>
        <cmd> #bootstrap ... </cmd>

    rule <k> (Index:Int => Index +Int 1) ~> #token("^bb0", "CaretId") ( X:ValueId : _:Type , VTs:ValueIdAndTypeList => VTs ) : ... </k>
        <locals> Locals:Map => Locals [X <- #ArgRef(Index)] </locals>
        <cmd> #bootstrap ... </cmd>
    
    rule <k> _:Int ~> #token("^bb0", "CaretId") ( .ValueIdAndTypeList ) : => .K ... </k>
        <cmd> #bootstrap ... </cmd>


    // SSA statements
    rule <k> X:ValueId = Op:GenericOperation => .K ... </k>
        <locals> Locals:Map => Locals [X <- Op] </locals>
        <cmd> #bootstrap ... </cmd>
        [owise]

    rule <k> X:ValueId : _:IntegerLiteral = Op:GenericOperation => .K ... </k>
        <locals> Locals:Map => Locals [X <- Op] </locals>
        <cmd> #bootstrap ... </cmd>


    // hw.instance
    rule <k> 
            (.K => 0 ~> M["instanceName"]) ~>
            (
                Res:OpResults = "hw.instance" ( Vs:ValueIdList ) { M:Map } : ( T1:Types ) -> ( T2:Types )
                => Res
                ~> "hw.instance" ( Vs ) { M } : ( T1 ) -> ( T2 )
            )
            ... 
        </k>
        <cmd> #bootstrap ... </cmd>

    
    rule <k> (Index:Int => Index +Int 1) ~> Inst:String ~> (X:ValueId, Xs:OpResults => Xs) ... </k>
        <locals> Locals:Map => Locals [X <- #OutPortRef(Inst, Index) ] </locals>
        <cmd> #bootstrap ... </cmd>
    
    rule <k> _:Int ~> _:String ~> .OpResults => .K ... </k>
        <cmd> #bootstrap ... </cmd>

    rule <k> "hw.instance" ( VL:ValueIdList ) { Attr:Map } : ( _:Types ) -> ( _:Types )
            => Attr["instanceName"] ~> Attr ["moduleName"] ~> VL ~> #HwInstance
            ...
        </k>
        <cmd> #bootstrap ... </cmd>


    rule <ckts>
            ...
            <ckt>
                <cid> Parent:String </cid>
                <k> Inst:String ~> Mod:SymbolRefId :: .SymbolRefIdList ~> VL:ValueIdList ~> #HwInstance => .K ... </k>
                ...
            </ckt>
            (.Bag =>
            <ckt>
                <cid> Inst </cid>
                <k> Op </k>
                <module> SymbolRefId2String(Mod) </module>
                <args> ValueRefListWrapper(VL, Parent) </args>
                ...
            </ckt>)
            ...
        </ckts>
        <running> L:List => L ListItem(Inst) </running>
        <boot> Boot:List => Boot ListItem(Inst) </boot>
        <table> ... SymbolRefId2String(Mod) |-> Op ... </table>
        <cmd> #bootstrap ... </cmd>
    
    
    // rule <k> #KWArgs A:AttributeValueList ~> V:ValueIdAndTypeList
    //         => #KHalt "An error occurs in #KWArgs!" ~> #KWArgs A ~> V
    //         ...
    //     </k> 
    //     [owise]
    
    // rule <k> _:CaretId ( VTs:ValueIdAndTypeList ) : OL:OperationList ~> #KWArgs TVs:StdValues
    //         => #KWArgs TVs ~> VTs ~> OL
    //         ...
    //     </k>
    
    // rule <k> #KWArgs TV:StdValue, TVs ~> (VID:_T):ValueIdAndType, VTs:ValueIdAndTypeList 
    //         => #KWArgs TVs ~> VTs
    //         ...
    //     </k>
    //     <curr> M:Map => M[VID <- TV] </curr>
    
    // rule <k> #KWArgs .StdValues ~> .ValueIdAndTypeList => .K ... </k>

    // # Parallelize Operations
    // rule <ks> 
    //         ... 
    //         <kmap>
    //             <kkey> _ </kkey>
    //             <k> Op:Operation Ops:OperationList => Ops ... </k>
    //         </kmap>
    //         (
    //             .Bag => 
    //             <kmap>
    //                 <kkey> !_:Int </kkey>
    //                 <k> Op </k>
    //             </kmap>
    //         )
    //         ... 
    //     </ks>
    
    // rule <ks> 
    //         ... 
    //         (<kmap> 
    //             <kkey> _ </kkey> 
    //             <k> .OperationList => .K </k> 
    //         </kmap>) 
    //         ... 
    //     </ks>
    
    // rule <ks> 
    //         ... 
    //         (<kmap> 
    //             <kkey> _ </kkey> 
    //             <k> .K </k> 
    //         </kmap> => .Bag) 
    //         ... 
    //     </ks>

    // # Setup Trigger of Result Assignment
    // rule <k> Rs = Op:GenericOperation => Op ~> #KWriteCurr OpResults2ValueIdList(Rs) ... </k>
    
    // # Effect Handlers
    // ## Read the current state
    // -- todo: add type-checking
    
    // rule <k> 
    //         #KReadCurr VID:ValueId, VIDs:ValueIdList 
    //         => ListItem(M[VID]) ~> #KReadCurr VIDs 
    //         ... 
    //     </k>
    //     <curr> M </curr> 
    //     requires VID in_keys(M)
    
    // rule <k> 
    //         L:List ~> #KReadCurr VID:ValueId, VIDs:ValueIdList 
    //         => L ListItem(M[VID]) ~> #KReadCurr VIDs
    //         ... 
    //     </k>
    //     <curr> M </curr> 
    //     requires VID in_keys(M)
    
    // rule <k> L:List ~> #KReadCurr .ValueIdList => List2StdValues(L) ... </k>
    


    // Write the current state
    // rule <k> TV:StdValue, Vs:StdValues ~> #KWriteCurr VID:ValueId, VIDs:ValueIdList
    //         => Vs ~> #KWriteCurr VIDs
    //         ...
    //     </k>
    //     <curr> M => M[VID <- TV] </curr>

    // rule <k> TV:StdValue ~> #KWriteCurr VID:ValueId, .ValueIdList => .K ... </k>
    //     <curr> M => M[VID <- TV] </curr> 

    // rule <k> .StdValues ~> #KWriteCurr .ValueIdList => .K ... </k>
    
    // // -- may be failed, can cause some strange behaviors
    // rule <k> _:StdValues ~> #KWriteCurr _:ValueIdList => .K ...</k>
    //     [owise]
    
    // // ## Read the output ports
    // rule <k> #KReadOuts => #KReadCurr VIDs ... </k>
    //     <out-vars> VIDs </out-vars>
    
    
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

    // rule <k> (.K => X) ~> (X:ValueId, Xs:ValueIdList => Xs) ... </k>
    // rule <k> (V:StdValue => .K) ~> _:ValueIdList ~> (L:List => L ListItem(V)) ... </k>
    // rule <k> .ValueIdList => .K ... </k>



    // hw.output
    rule <k> (.K => VL) ~> #HwOutput ... </k>
        <out-vars> VL:ValueIdList </out-vars>
    
    rule <k> L:List ~> #HwOutput => .K ... </k>
        <out-ports> _ => L </out-ports>


    // ---------- value ref -----------
    rule <k> #ArgRef ( Index:Int ) => Args[Index] ~> #ArgRef ( Index ) ... </k>
        <args> Args:List </args>

    rule <k> V:StdValue ~> #ArgRef ( Index:Int ) => V ... </k>
        <in-ports> M:Map => M [ L[Index] <- V ] </in-ports>
        <in-names> L:List </in-names>

    rule <k> #OutPortRef ( Inst:String , Index:Int ) => L[Index] ... </k>
        <ckt>
            <cid> Inst </cid>
            <k> .K </k>
            <out-ports> L:List </out-ports>
            ...
        </ckt>

    // use new context, race risk?
    rule <k> #ValueRef ( Inst:String , V:ValueId ) => #ValueRefLookup ~> Inst ... </k>
        <cid> Caller:String </cid>
        <ckt>
            <cid> Inst </cid>
            <locals> M:Map </locals>
            <k> .K => M[V] orDefault "???" ~> Caller ~> #ValueRefLookup ... </k>
            ...
        </ckt>

    rule <k> #ValueRefLookup ~> Callee:String => V ... </k>
        <cid> Caller:String </cid>
        <ckt>
            <cid> Callee </cid>
            <k> V:StdValue ~> Caller ~> #ValueRefLookup => .K ... </k>
            ...
        </ckt>

endmodule