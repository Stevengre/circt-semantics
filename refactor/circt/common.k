requires "../dialects/builtin.k"
requires "../dialects/hw/config.k"
requires "../dialects/hw/config-g.k"
requires "../mlir.k"
requires "bits.k"

module COMMON-SYNTAX
    imports BUILTIN-SYNTAX
endmodule

module COMMON-HELPER
    imports COMMON-SYNTAX
    imports BITS
    imports BUILTIN

    // # Execute a CIRCT Command
    syntax CmdCIRCT ::= "#CIRCTpreprocess" // Do nothing, but just preprocess
                      | "#CIRCThalt" String
    // # Effect Handlers used in <k>
    syntax KmdCIRCT ::= "#Khalt" String
                      | "#KReadCurr" ValueIdList // Read the value from the current state
                      | "#KWriteCurr" ValueIdList // Write the value to the current state

    syntax StdValue ::= Bits ":" Type
    syntax StdValues ::= List{StdValue, ","}

    // # AttributeValue 2 Bits
    syntax Bits ::= AttributeValue2Bits ( AttributeValue, Type ) [function]
    rule AttributeValue2Bits(V,T) => bits(AttributeValue2BitValue(V), Type2BitSize(T)) [owise]
    syntax BitValue ::= AttributeValue2BitValue ( AttributeValue ) [function]
    rule AttributeValue2BitValue( AV:AttributeValue ) => {AV}:>BitValue [owise]
    rule AttributeValue2BitValue( V:IntegerLiteral : _:IntegerType ) => {V}:>BitValue
    rule AttributeValue2BitValue( V:IntegerLiteral : _:IndexType ) => {V}:>BitValue
    rule AttributeValue2BitValue( true ) => {1}:>BitValue
    rule AttributeValue2BitValue( false ) => {0}:>BitValue
    syntax Int ::= Type2BitSize ( Type ) [function]
    // ## Get BitSize from BuiltinType
    rule Type2BitSize( T:IntegerType ) => getIntegerTypeSize(T)
    // ## If failed, it maybe caused by the uncovered types for Type2BitSize
    
    // # List 2
    syntax StdValues ::= List2StdValues ( List ) [function]
    rule List2StdValues( .List ) => .StdValues
    rule List2StdValues( ListItem(V:StdValue) L:List ) => V , List2StdValues(L)
    // # StdValues 2
    syntax Bits ::= StdValues2Bits ( StdValues ) [function]
    rule StdValues2Bits( .StdValues ) => bits(0,0)
    rule StdValues2Bits( (bits(V,S):BitValue) , Vs:StdValues ) => bits(V,S) concatBits StdValues2Bits(Vs)
endmodule

module COMMON
    imports MLIR
    imports COMMON-HELPER
    imports HW-CONFIG
    imports HW-CONFIG-G

    configuration
      <circt> 
        <mlir/> 
        <cmd> $CMD:K </cmd>
        <clock> 0:Int </clock>
        <ckts>
          <ckt multiplicity="*" type="Map">
              <cid> "" </cid>
              <ks> 
                <kmap multiplicity="*" type="Map"> 
                  <kkey> 0:Int </kkey>
                  <k> .K </k>
                </kmap> 
              </ks>
              <circuit> .K </circuit>
              <parent> "" </parent>
              <last> .Map </last>
              <curr> .Map </curr>
              <module> "" </module>
              <in-ports> .List </in-ports>
              <in-vars> .ValueIdAndTypeList </in-vars>
              <out-ports> .List </out-ports>
              <out-vars> .ValueIdList </out-vars>
              <reg> .Map </reg>
              <wire> .Map </wire>
              <hw/>
          </ckt>
        </ckts>
        <hw-g/>
        // <exit>
        //   <exit-code exit=""> 0 </exit-code>
        //   <exit-info> "Success" </exit-info>
        // </exit>
      </circt>
    
    // # Phase Change: preprocess 2 toStimulate
    syntax Control ::= "#toStimulate"
    rule <phase> #preprocess => #toStimulate </phase>
         <prog> .TopLevel </prog>

    // # Phase Change: Stop/Finish Current Simulation
    syntax KmdCIRCT ::= "#KClockFinish" | "#KFinish"
    // - Return Values to the parent circuit
    syntax KmdCIRCT ::= "#KCallBack" String
    rule 
    <ks> <kmap> <kkey> _ </kkey> <k> #KClockFinish => .K ... </k> </kmap></ks>
    <clock> I:Int => I +Int 1 </clock>
    // todo: #CIRCTinitOp 以结束 和 #KinitOp 以 #KFinish结束
    rule
    <ks> <kmap> <kkey> _ </kkey> <k> #KFinish => #KReadOuts ~> #KFinish ... </k> </kmap> </ks>
    rule
    <ckt>
     <cid> CID </cid>
     <ks> <kmap> <kkey> _ </kkey> <k> TVs:StdValues ~> #KFinish => .K ... </k> </kmap> </ks>
     <curr> CURR => .Map </curr>
     <last> _ => CURR </last>
     <parent> FID </parent>
     ...
    </ckt>
    <ckt>
     <cid> FID </cid>
     <k> #KCallBack CID => TVs ... </k>
     ...
    </ckt>

    // # Stimuate a circuit with arguments
    syntax CmdCIRCT ::= "#CIRCTstimulate" SymbolRefId "(" AttributeValueList ")"
    syntax KmdCIRCT ::= "#Kstimulate" String "(" StdValues ")" "by" String "as" String
    syntax Control ::= "#stimulating"
    // - first stimulation
    rule <phase> #toStimulate </phase>
         <cmd> #CIRCTstimulate ID:SymbolRefId ( Vs:AttributeValueList ) 
               => #CIRCTgetOp ID
               ~> #CIRCTrefineOp
               ~> #CIRCTinitOp SymbolRefId2String(ID) Vs
         ... </cmd>
    [owise]
    rule <k> #Kstimulate ModuleName ( TVs ) by FID as CID
               => #KgetOp ModuleName
               ~> #KrefineOp
               ~> #KinitOp ModuleName ( TVs ) by FID as CID
         ... </k>
    [owise]
    // - Phase Change: subsequent stimulation
    rule <phase> #toStimulate => #stimulating </phase>
         <cmd> #CIRCTstimulate ID:SymbolRefId ( Vs:AttributeValueList ) => .K ... </cmd>
         <ckt>
           <cid> CID </cid>
           <module> CID </module>
           <ks> (_ => <kmap> <kkey> !_:Int </kkey> <k> Op ~> #KWArgs Vs ~> #KClockFinish </k> </kmap>)</ks>
           <circuit> Op:Operation ~> .K </circuit>
           ...
         </ckt>
    requires SymbolRefId2String(ID) ==K CID
    rule <k> #Kstimulate ModuleName ( TVs ) by FID as CID => #KCallBack CID ... </k>
         <ckt>
           <cid> CID </cid>
           <module> ModuleName </module>
           <ks> (_ => <kmap> <kkey> !_:Int </kkey> <k> Op ~> #KWArgs TVs ~> #KFinish </k> </kmap>)</ks>
           <circuit> Op:Operation ~> .K </circuit>
           <parent> FID </parent>
           ...
         </ckt>

    // # Get Operation From Symbol Table
    syntax CmdCIRCT ::= "#CIRCTgetOp" SymbolRefId 
    syntax KmdCIRCT ::= "#KgetOp" String
    rule <phase> #toStimulate </phase>
         <cmd> #CIRCTgetOp ID:SymbolRefId
               => 
               #if SymbolRefId2String(ID) in_keys(M)
               #then M [ SymbolRefId2String(ID) ]
               #else #CIRCThalt "cannot find operation from <table>"
               #fi 
         ... </cmd>
         <table> M:Map </table>
    rule <k> #KgetOp ID:String
               => 
               #if ID in_keys(M)
               #then M [ ID ]
               #else #CIRCThalt "cannot find operation from <table>"
               #fi 
         ... </k>
         <table> M:Map </table>
    
    // # Refine operations in hardware domain
    // - reduce the complexity of the operations for dialect semantics
    syntax CmdCIRCT ::= "#CIRCTrefineOp"
    syntax KmdCIRCT ::= "#KrefineOp"
    rule <phase> #toStimulate </phase>
         <cmd> Op:Operation ~> #CIRCTrefineOp
               => CIRCTrefineOp(Op)
         ... </cmd>
    rule <k> Op:Operation ~> #KrefineOp
               => CIRCTrefineOp(Op)
         ... </k>
    // ## refine operation
    syntax Operation ::= CIRCTrefineOp ( Operation ) [function]
    // - if generate values, but no id to consume them. just throw it away.
    rule CIRCTrefineOp( Rs = Op:GenericOperation) => CIRCTrefineGop(Op) requires Rs ==K .OpResults
    rule CIRCTrefineOp( Rs = Op:GenericOperation) => Rs = CIRCTrefineGop(Op) [owise]
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

    // # Phase Change: Initialize Operation with Arguments in <cmd>
    syntax CmdCIRCT ::= "#CIRCTinitOp" String AttributeValueList
    syntax KmdCIRCT ::= "#KinitOp" String StdValues "by" String "as" String
    // - First Stimulation
    rule <phase> #toStimulate => #stimulating </phase>
         <cmd> Op:Operation ~> #CIRCTinitOp ID:String Vs:AttributeValueList
               => .K
         ... </cmd>
         <ckts>
           ...
           (.Bag =>
           <ckt>
             <cid> ID </cid>
             <ks> <kmap> <kkey> !_:Int </kkey> <k> Op ~> #KWArgs Vs ~> #KClockFinish </k> </kmap> </ks>
             <circuit> Op </circuit>
             <module> ID </module>
             ...
           </ckt>)
           ...
         </ckts>
         [owise]
    rule <k> Op:Operation ~> #KinitOp ID ( TVs ) by FID as CID => #KCallBack CID ... </k>
         (.Bag =>
         <ckt>
           <cid> CID </cid>
           <ks> <kmap> <kkey> !_:Int </kkey> <k> Op ~> #KWArgs TVs ~> #KFinish</k> </kmap> </ks>
           <circuit> Op </circuit>
           <module> ID </module>
           <parent> FID </parent>
           ...
         </ckt>)

    // # Write Arguments to the Entry Block in <k>
    syntax KmdCIRCT ::= "#KWArgs" AttributeValueList | "#KWArgs" StdValues
    rule <k> _:CaretId ( VTs:ValueIdAndTypeList ) : OL:OperationList ~> #KWArgs Vs:AttributeValueList 
         => #KWArgs Vs:AttributeValueList ~> VTs ~> OL ...</k>
    rule <k> #KWArgs V:AttributeValue, Vs:AttributeValueList ~> (VID:T):ValueIdAndType, VTs:ValueIdAndTypeList 
         => #KWArgs Vs ~> VTs ... </k>
         <curr> M:Map => M[VID <- AttributeValue2Bits(V,T):T]</curr>
    rule <k> #KWArgs .AttributeValueList ~> .ValueIdAndTypeList => .K ... </k>
    rule <k> #KWArgs A:AttributeValueList ~> V:ValueIdAndTypeList => #Khalt "An error occurs in #KWArgs!" ~> #KWArgs A ~> V ... </k> [owise]
    rule <k> _:CaretId ( VTs:ValueIdAndTypeList ) : OL:OperationList ~> #KWArgs TVs:StdValues
         => #KWArgs TVs ~> VTs ~> OL ...</k>
    rule <k> #KWArgs TV:StdValue, TVs ~> (VID:_T):ValueIdAndType, VTs:ValueIdAndTypeList 
         => #KWArgs TVs ~> VTs ... </k>
         <curr> M:Map => M[VID <- TV] </curr>
    rule <k> #KWArgs .StdValues ~> .ValueIdAndTypeList => .K ... </k>

    // # Parallelize Operations
    rule <ks> ... 
              <kmap>
                <kkey> _ </kkey>
                <k> Op:Operation Ops:OperationList => Ops ... </k>
              </kmap>
              (.Bag =>
              <kmap>
                <kkey> !_:Int </kkey>
                <k> Op </k>
              </kmap>)
              ... 
         </ks>
    rule <ks> ... (<kmap> <kkey> _ </kkey> <k> .OperationList => .K </k> </kmap>) ... </ks>
    rule <ks> ... (<kmap> <kkey> _ </kkey> <k> .K </k> </kmap> => .Bag) ... </ks>

    // # Setup Trigger of Result Assignment
    rule <k> Rs = Op:GenericOperation => Op ~> #KWriteCurr OpResults2ValueIdList(Rs) ... </k>
    
    // # Effect Handlers
    // ## Read the current state
    // -- todo: add type-checking
    rule <k> #KReadCurr VID:ValueId, VIDs:ValueIdList => ListItem(M[VID]) ~> #KReadCurr VIDs ... </k>
         <curr> M </curr> 
         requires VID in_keys(M)
    rule <k> L:List ~> #KReadCurr VID:ValueId, VIDs:ValueIdList => L ListItem(M[VID]) ~> #KReadCurr VIDs ... </k>
         <curr> M </curr> 
         requires VID in_keys(M)
    rule <k> L:List ~> #KReadCurr .ValueIdList => List2StdValues(L) ... </k>
    // ## Write the current state
    // -- todo: add type-checking
    rule <k> TV:StdValue, Vs:StdValues ~> #KWriteCurr VID:ValueId, VIDs:ValueIdList => Vs ~> #KWriteCurr VIDs ... </k>
         <curr> M => M[VID <- TV] </curr>
    rule <k> TV:StdValue ~> #KWriteCurr VID:ValueId, .ValueIdList => .K ... </k>
         <curr> M => M[VID <- TV] </curr> 
    rule <k> .StdValues ~> #KWriteCurr .ValueIdList => .K ... </k>
    // -- may be failed, can cause some strange behaviors
    rule <k> _:StdValues ~> #KWriteCurr _:ValueIdList => .K ...</k> [owise]
    // ## Read the output ports
    syntax KmdCIRCT ::= "#KReadOuts"
    rule
    <k> #KReadOuts => #KReadCurr VIDs ... </k>
    <out-vars> VIDs </out-vars>
endmodule