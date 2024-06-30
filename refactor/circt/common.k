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

    syntax Control ::= "#toStimulate"
                     | "#stimulating"

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
                 | "ValueRef" "(" String "," ValueId ")"

    
    syntax KmdCIRCT ::= "#HwInstance"
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
    syntax Operation ::= CIRCTrefineOp ( Operation ) [function]
    
    // - if generate values, but no id to consume them. just throw it away.
    rule CIRCTrefineOp(Rs = Op:GenericOperation) => CIRCTrefineGop(Op) requires Rs ==K .OpResults
    rule CIRCTrefineOp(Rs = Op:GenericOperation) => Rs = CIRCTrefineGop(Op) [owise]

    // ## refine generic operation
    syntax GenericOperation ::= CIRCTrefineGop ( GenericOperation ) [function]
    
    // -- 11
    rule CIRCTrefineGop( N (Vs) [.Successors] <{AL:Map}> (R:Regions) {AL2:Map} : FT )
        => N (Vs) <{AL}> (CIRCTrefineRegions(R)) {AL2} : FT
        requires AL =/=K .Map andBool R =/=K .Regions
    // -- 01
    rule CIRCTrefineGop( N (Vs) [.Successors] <{AL:Map}> (R:Regions) {AL2:Map} : FT )
        => N (Vs) (CIRCTrefineRegions(R)) {AL2} : FT
        requires AL ==K .Map andBool R =/=K .Regions
    // -- 10
    rule CIRCTrefineGop( N (Vs) [.Successors] <{AL:Map}> (R:Regions) {AL2:Map} : FT )
        => N (Vs) <{AL}> {AL2} : FT
        requires AL =/=K .Map andBool R ==K .Regions
    // -- 00
    rule CIRCTrefineGop( N (Vs) [.Successors] <{AL:Map}> (R:Regions) {AL2:Map} : FT )
        => N (Vs) {AL2} : FT
        requires AL ==K .Map andBool R ==K .Regions
    
    // -- unexpected
    rule CIRCTrefineGop(Op:GenericOperation) => Op [owise]
    
    // ## refine regions
    syntax Regions ::= CIRCTrefineRegions (Regions) [function]
    rule CIRCTrefineRegions(.Regions) => .Regions 
    rule CIRCTrefineRegions( R:Region, Rs:Regions ) => CIRCTrefine(R) , CIRCTrefineRegions(Rs) [owise]
    
    // ## refine region
    syntax Region ::= CIRCTrefine( Region ) [function]
    rule CIRCTrefine( {OPs:OperationList BL:BlockList} ) => {CIRCTrefineOps(OPs) CIRCTrefineBlocks(BL)}
    
    // ## refine OperationList
    syntax OperationList ::= CIRCTrefineOps( OperationList ) [function]
    rule CIRCTrefineOps( .OperationList ) => .OperationList
    rule CIRCTrefineOps( OP:Operation OPs:OperationList ) => CIRCTrefineOp(OP) CIRCTrefineOps(OPs) [owise]
    
    // ## refine BlockList
    syntax BlockList ::= CIRCTrefineBlocks( BlockList ) [function]
    rule CIRCTrefineBlocks( .BlockList ) => .BlockList
    rule CIRCTrefineBlocks( B:Block BL:BlockList ) => CIRCTrefineBlock(B) CIRCTrefineBlocks(BL) [owise]
    
    // ## refine Block
    syntax Block ::= CIRCTrefineBlock( Block ) [function]
    rule CIRCTrefineBlock( BL:BlockLabel OPs:OperationList ) => BL CIRCTrefineOps(OPs) 

    syntax List ::= toList(AttributeValueList) [function]
    rule toList(V:AttributeValue, VL:AttributeValueList) => ListItem(V) toList(VL)
    rule toList(.AttributeValueList) => .List

    syntax List ::= ValueRefListWrapper(ValueIdList, String) [function]
    rule ValueRefListWrapper(V:ValueId, VL:ValueIdList, Inst:String) => ListItem(V) ValueRefListWrapper(VL, Inst)
    rule ValueRefListWrapper(.ValueIdList, _:String) => .List
endmodule


module COMMON
    imports COMMON-HELPER
    imports CIRCT-CONF
    imports HW-INOUT-SYNTAX

    // # Phase Change: preprocess 2 toStimulate


    rule <phase> #preprocess => #toStimulate </phase>
        <prog> .TopLevel </prog>
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
    rule <phase> #toStimulate </phase>
        <cmd> #CIRCTstimulate ID:SymbolRefId ( Vs:AttributeValueList ) 
            => #CirctGetOp ID ~> #CIRCTrefineOp 
            ~> #CIRCTinitOp SymbolRefId2String(ID) ( Vs )
            ...
        </cmd>
        // [owise]

    // rule <k> #Kstimulate ModuleName ( TVs ) by FID as CID
    //         => #KgetOp ModuleName
    //         ~> #KrefineOp
    //         ~> #KinitOp ModuleName ( TVs ) by FID as CID
    //         ... 
    //     </k>
    //     [owise]
    
    // - Phase Change: subsequent stimulation
    // rule <phase> #toStimulate => #stimulating </phase>
    //     <cmd> #CIRCTstimulate ID:SymbolRefId ( Vs:AttributeValueList ) => .K ... </cmd>
    //     <ckt>
    //         <cid> CID </cid>
    //         <module> CID </module>
    //         <ks> 
    //             (_ => <kmap> 
    //                 <kkey> !_:Int </kkey> 
    //                 <k> Op ~> #KWArgs Vs ~> #KClockFinish </k>
    //             </kmap>)
    //         </ks>
    //         <circuit> Op:Operation ~> .K </circuit>
    //         ...
    //     </ckt>
    //     requires SymbolRefId2String(ID) ==K CID
    
    // rule <k> #Kstimulate ModuleName ( TVs ) by FID as CID => #KCallBack CID ... </k>
    //     <ckt>
    //         <cid> CID </cid>
    //         <module> ModuleName </module>
    //         <ks> (_ => <kmap> <kkey> !_:Int </kkey> <k> Op ~> #KWArgs TVs ~> #KFinish </k> </kmap>)</ks>
    //         <circuit> Op:Operation ~> .K </circuit>
    //         <parent> FID </parent>
    //         ...
    //     </ckt>

    // # Get Operation From Symbol Table
   
    rule <phase> #toStimulate </phase>
        <cmd> 
            #CirctGetOp ID:SymbolRefId
            => #if SymbolRefId2String(ID) in_keys(M)
            #then M [ SymbolRefId2String(ID) ]
            #else #Stop "cannot find operation from <table>"
            #fi
            ... 
        </cmd>
        <table> M:Map </table>

    // rule <k> 
    //         #KgetOp ID:String
    //         => #if ID in_keys(M)
    //         #then M [ ID ]
    //         #else ##Stop "cannot find operation from <table>"
    //         #fi 
    //         ... 
    //     </k>
    //     <table> M:Map </table>
    
    // Refine operations in hardware domain
    // reduce the complexity of the operations for dialect semantics
    

    
    rule <phase> #toStimulate </phase>
        <cmd> Op:Operation ~> #CIRCTrefineOp => CIRCTrefineOp(Op) ... </cmd>
    
    // rule <k> Op:Operation ~> #KrefineOp => CIRCTrefineOp(Op) ... </k>
    
    
    
    
    // # Phase Change: Initialize Operation with Arguments in <cmd>
   
    
    // - First Stimulation
    rule <phase> #toStimulate => #stimulating </phase>
        <cmd> Op:Operation ~> #CIRCTinitOp ID:String (Vs:AttributeValueList) => .K ... </cmd>
        <ckts>
            ...
            (.Bag =>
            <ckt>
                <cid> ID </cid>
                <k> Op </k> 
                // <circuit> Op </circuit>
                <module> ID </module>
                <args> toList(Vs) </args>
                ...
            </ckt>)
            ...
        </ckts>
        
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
    
    rule <k>
            "hw.module" ( .ValueIdList ) ( R:Region ) { _:Map } : ( .Types ) -> ( .Types )
            => R
            ...
        </k>
    
    rule <k> { OL:OperationList B:BlockList } => OL ~> B ... </k>

    rule <k> B:Block BL:BlockList => B ~> BL ... </k>
    rule <k> .BlockList => .K ... </k>

    rule <k> Op:Operation Ops:OperationList => Op ~> Ops ... </k>
    rule <k> .OperationList => .K ... </k>


    rule <k> 
            #token("^bb0", "CaretId") ( VTs:ValueIdAndTypeList ) : OL:OperationList
            => #KWArgs Args ~> VTs ~> OL
            ...
        </k>
        <args> Args:List </args>

    
    rule <k> #KWArgs (ListItem(V:Int) Vs:List => Vs)
            ~> (X:ValueId : T:Type , VTs:ValueIdAndTypeList => VTs)
            ...
        </k>
        <locals> Locals:Map => Locals [X <- AV2Bits(V, T) : T] </locals>
    
    rule <k> #KWArgs .List ~> .ValueIdAndTypeList => .K ... </k>

    rule <k> X:ValueId = Op:GenericOperation => .K ... </k>
        <locals> Locals:Map => Locals [X <- Op] </locals>
        [owise]

    rule <k> "hw.output" ( Vs:ValueIdList ) { .Map } : ( _:Types ) -> ( .Types ) => .K ... </k>
        <out-vars> _ => Vs </out-vars>


    rule <k> 
            (.K => 0 ~> M["instanceName"]) ~>
            (
                Res:OpResults = "hw.instance" ( Vs:ValueIdList ) { M:Map } : ( T1:Types ) -> ( T2:Types )
                => Res
                ~> "hw.instance" ( Vs ) { M } : ( T1 ) -> ( T2 )
            )
            ... 
        </k>

    
    rule <k> (Index:Int => Index +Int 1) ~> Inst:String ~> (X:ValueId, Xs:OpResults => Xs) ... </k>
        <locals> Locals:Map => Locals [X <- #OutPortRef(Inst, Index +Int 1) ] </locals>
    
    rule <k> _:Int ~> _:String ~> .OpResults => .K ... </k>

    rule <k> "hw.instance" ( VL:ValueIdList ) { Attr:Map } : ( _:Types ) -> ( _:Types )
            => Attr["instanceName"] ~> Attr ["moduleName"] ~> VL ~> #HwInstance
            ...
        </k>


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
                <k> CIRCTrefineOp(Op) </k> 
                // <circuit> Op </circuit>
                <module> SymbolRefId2String(Mod) </module>
                <args> ValueRefListWrapper(VL, Parent) </args>
                ...
            </ckt>)
            ...
        </ckts>
        <table> ... SymbolRefId2String(Mod) |-> Op ... </table>
    

    rule <k> "sv.initial" ( .ValueIdList ) ( R:Region ) { .Map } : ( .Types ) -> ( .Types ) => .K ... </k>
        <initial> L:List => L ListItem("sv.initial" ( .ValueIdList ) ( R ) { .Map } : ( .Types ) -> ( .Types )) </initial>
    
    rule <k> "sv.always" ( VL:ValueIdList ) ( R:Region ) { Attr:Map } : ( .Types ) -> ( .Types ) => .K ... </k>
        <always> L:List => L ListItem("sv.always" ( VL ) ( R ) { Attr } : ( .Types ) -> ( .Types )) </always>

    rule <k> X:ValueId = "hw.constant" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( T:Type ) => .K ... </k>
        <locals> Locals:Map => Locals [X <- AV2StdValue({Attr["value"]}:>AttributeValue, T)] </locals>
    
    rule <k> X:ValueId = "sv.reg" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < T:Type > ) => .K ... </k>
        <regs> Regs:Map => Regs [ X <- hw.inout({Attr["name"]}:>String , T , #x) ] </regs>
        <locals> Locals:Map => Locals [ X <- "sv.reg" ( .ValueIdList ) { Attr } : ( .Types ) -> ( !hw.inout < T > ) ] </locals>

    
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
endmodule