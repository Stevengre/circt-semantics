requires "../dialects/builtin.k"
requires "../dialects/hw/config.k"
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
                      | "#KWriteCurr" ValueIdList // Write the value to the current state

    syntax TypeValue ::= Bits ":" Type
    syntax TypeValues ::= List{TypeValue, ","}

    // # AttributeValue 2 Bits
    syntax Bits ::= AttributeValue2Bits ( AttributeValue, Type ) [function]
    rule AttributeValue2Bits(V,T) => bits(AttributeValue2BitValue(V), Type2BitSize(T)) [owise]
    syntax BitValue ::= AttributeValue2BitValue ( AttributeValue ) [function]
    rule AttributeValue2BitValue( AV:AttributeValue ) => {AV}:>BitValue [owise]
    syntax Int ::= Type2BitSize ( Type ) [function]
    // ## Get BitSize from BuiltinType
    rule Type2BitSize( T:IntegerType ) => getIntegerTypeSize(T)
    // ## If failed, it maybe caused by the uncovered types for Type2BitSize 

endmodule

module COMMON
    imports MLIR
    imports COMMON-HELPER
    imports HW-CONFIG

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
              <in> .Map </in>
              <out> .Map </out>
              <reg> .Map </reg>
              <wire> .Map </wire>
              <hw/>
          </ckt>
        </ckts>
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
    rule <phase> #stimulating => #toStimulate </phase> 
         <clock> I:Int => I +Int 1 </clock>
    [owise]

    // # Stimuate a circuit with arguments
    syntax CmdCIRCT ::=  "#CIRCTstimulate" SymbolRefId "(" AttributeValueList ")"
    syntax Control ::= "#stimulating"
    // - first stimulation
    rule <phase> #toStimulate </phase>
         <cmd> #CIRCTstimulate ID:SymbolRefId ( Vs:AttributeValueList ) 
               => #CIRCTgetOp ID
               ~> #CIRCTrefineOp
               ~> #CIRCTinitOp SymbolRefId2String(ID) Vs
         ... </cmd>
    [owise]
    // - Phase Change: subsequent stimulation
    rule <phase> #toStimulate => #stimulating </phase>
         <cmd> #CIRCTstimulate ID:SymbolRefId ( Vs:AttributeValueList ) => .K </cmd>
         <ckt>
           <cid> CID </cid>
           <module> CID </module>
           <ks> (_ => <kmap> <kkey> !_:Int </kkey> <k> Op ~> #KWArgs Vs </k> </kmap>)</ks>
           <circuit> Op:Operation ~> .K </circuit>
           ...
         </ckt>
    requires SymbolRefId2String(ID) ==K CID

    // # Get Operation From Symbol Table
    syntax CmdCIRCT ::= "#CIRCTgetOp" SymbolRefId
    rule <phase> #toStimulate </phase>
         <cmd> #CIRCTgetOp ID:SymbolRefId
               => 
               #if SymbolRefId2String(ID) in_keys(M)
               #then M [ SymbolRefId2String(ID) ]
               #else #CIRCThalt "cannot find operation from <table>"
               #fi 
         ... </cmd>
         <table> M:Map </table>
    
    // # Refine operations in hardware domain
    // - reduce the complexity of the operations for dialect semantics
    syntax CmdCIRCT ::= "#CIRCTrefineOp"
    rule <phase> #toStimulate </phase>
         <cmd> Op:Operation ~> #CIRCTrefineOp
               => CIRCTrefineOp(Op)
         ... </cmd>
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
             <ks> <kmap> <kkey> !_:Int </kkey> <k> Op ~> #KWArgs Vs </k> </kmap> </ks>
             <circuit> Op </circuit>
             <module> ID </module>
             ...
           </ckt>)
           ...
         </ckts>
         [owise]

    // # Write Arguments to the Entry Block in <k>
    syntax KmdCIRCT ::= "#KWArgs" AttributeValueList
    rule <k> _:CaretId ( VTs:ValueIdAndTypeList ) : OL:OperationList ~> #KWArgs Vs:AttributeValueList 
         => #KWArgs Vs:AttributeValueList ~> VTs ~> OL ...</k>
    rule <k> #KWArgs V:AttributeValue, Vs:AttributeValueList ~> (VID:T):ValueIdAndType, VTs:ValueIdAndTypeList 
         => #KWArgs Vs ~> VTs ... </k>
         <curr> M:Map => M[VID <- AttributeValue2Bits(V,T):T]</curr>
    rule <k> #KWArgs .AttributeValueList ~> .ValueIdAndTypeList => .K ... </k>
    rule <k> #KWArgs A:AttributeValueList ~> V:ValueIdAndTypeList => #Khalt "An error occurs in #KWArgs!" ~> #KWArgs A ~> V ... </k> [owise]

    // # Parallelize Operations
    rule <ks> ... 
              <kmap>
                <kkey> _ </kkey>
                <k> Op:Operation Ops:OperationList => Ops </k>
              </kmap>
              (.Bag =>
              <kmap>
                <kkey> !_:Int </kkey>
                <k> Op </k>
              </kmap>)
              ... 
         </ks>
    rule <ks> ... (<kmap> <kkey> _ </kkey> <k> .OperationList </k> </kmap> => .Bag) ... </ks>
    rule <ks> ... (<kmap> <kkey> _ </kkey> <k> .K </k> </kmap> => .Bag) ... </ks>

    // # Setup Trigger of Result Assignment
    rule <k> Rs = Op:GenericOperation => Op ~> #KWriteCurr OpResults2ValueIdList(Rs) ... </k>
    
    // # Effect Handlers
    // ## Write the current state
    rule <k> TV:TypeValue, Vs:TypeValues ~> #KWriteCurr VID:ValueId, VIDs:ValueIdList => Vs ~> #KWriteCurr VIDs </k>
         <curr> M => M[VID <- TV] </curr>
    rule <k> .TypeValues ~> #KWriteCurr .ValueIdList => .K ... </k>
    // -- may be failed, can cause some strange behaviors
    rule <k> _:TypeValues ~> #KWriteCurr _:ValueIdList => .K ...</k> [owise]
    
endmodule