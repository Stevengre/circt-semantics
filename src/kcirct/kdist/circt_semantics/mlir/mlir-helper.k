requires "./mlir-syntax.md"

module MLIR-HELPER-SYNTAX
endmodule

module MLIR-HELPER
    imports MLIR-SYNTAX
    imports MAP
    imports LIST
    imports K-EQUAL
    syntax AttrMap ::= "{" Map "}"
    syntax GenericOperation ::= 
          StringLiteral "(" ValueIdList ")" AttrMap ":" FunctionType
        | StringLiteral "(" ValueIdList ")" RegionList AttrMap ":" FunctionType
        | StringLiteral "(" ValueIdList ")" SuccessorList AttrMap ":" FunctionType
        | StringLiteral "(" ValueIdList ")" SuccessorList RegionList AttrMap ":" FunctionType
    // Get Attribute Value
    // syntax AttributeValue ::= getAttr(Operation, String) [function]
    // rule getAttr(_ = _ (_) [_:Successors] <{_:Map}> (_:Regions) {AL2:Map} : _, BID) => {AL2[BID] orDefault #undefined}:>AttributeValue
    // rule getAttr(_ = _ (_) (_:Regions) {AL2:Map} : _, BID) => {AL2[BID] orDefault #undefined}:>AttributeValue

    // syntax AttributeValue ::= getAttr(Map, String) [function]
    // rule getAttr(M:Map, BID:String) => {M[BID] orDefault #undefined}:>AttributeValue
    
    // getAttr ( .OpResults = "builtin.module" ( .ValueIdList ) [ .Successors ] ( Regions ) { .Map } : ( .Types ) -> ( .Types ) , "sym_name" )

    // syntax AttributeValue ::= getOpAttr(Map, String) [function]
    syntax AttributeValue ::= getOpAttr(Operation, String) [function]
    rule getOpAttr(_:OpResults = _:String ( _:ValueIdList ) [ .Successors ] ( _:Regions ) { Attr:Map } : _:FunctionType, A:String) => {Attr[A] orDefault #undefined}:>AttributeValue
    
    // ## Get Operation Name
    syntax String ::= getOpName(Operation) [function]
    rule getOpName(_ = Op:GenericOperation) => getOpName(Op)
    rule getOpName(OpName ( _ ) : _:FunctionType) => OpName
    rule getOpName(OpName ( _ ) _:DictionaryAttribute : _:FunctionType) => OpName
    rule getOpName(OpName ( _ ) _:RegionList : _:FunctionType) => OpName
    rule getOpName(OpName ( _ ) _:SuccessorList : _:FunctionType) => OpName
    rule getOpName(OpName ( _ ) _:RegionList _:DictionaryAttribute : _:FunctionType) => OpName
    rule getOpName(OpName ( _ ) _:SuccessorList _:DictionaryAttribute : _:FunctionType) => OpName
    rule getOpName(OpName ( _ ) _:SuccessorList _:RegionList : _:FunctionType) => OpName
    rule getOpName(OpName ( _ ) _:SuccessorList _:RegionList _:DictionaryAttribute : _:FunctionType) => OpName
    
    // ## Get Operation Results
    syntax Regions ::= getRegions(Operation) [function]
    rule getRegions(_ = Op:GenericOperation) => getRegions(Op)
    // rule getRegions(_ = Op:StdOperation)     => getRegions(Op)
    rule getRegions(_ (_) [_:Successors] (Rs:Regions) {_:Map} : _) => Rs
    rule getRegions(_ (_) [_:Successors] (Rs:Regions) {_:Map} : _) => Rs
     
    // # Tokens <-> Strings
    // ## BareId <-> String
    syntax String ::= BareId2String(BareId) [function, total, hook(STRING.token2string)]
    // ## SymbolRefId <-> String
    syntax String ::= "SymbolRefId2StringHelper" "(" SymbolRefId ")" [function, total,hook(STRING.token2string)]
    syntax String ::= "SymbolRefId2String" "(" SymbolRefId ")" [function, total]
    rule SymbolRefId2String(ID) => substrString ( SymbolRefId2StringHelper(ID) , 1 , lengthString(SymbolRefId2StringHelper(ID)) )

    syntax String ::= str(SymbolRefId) [function]
    rule str(S:SymbolRefId) => SymbolRefId2String(S)

    syntax SymbolRefId ::= "String2SymbolRefIdHelper" "(" String ")" [function, total, hook(STRING.string2token)]
    syntax SymbolRefId ::= "String2SymbolRefId" "(" String ")" [function, total]
    rule String2SymbolRefId(S:String) => String2SymbolRefIdHelper("@" +String S)

    // ## List of String (SymbolRefId) -> String
    syntax String ::= "SymbolRefIdList2String" "(" List ")" [function, total]
    rule SymbolRefIdList2String(.List) => ""
    rule SymbolRefIdList2String( ListItem( #undefined ) Ls:List ) => SymbolRefIdList2String(Ls)
    rule SymbolRefIdList2String( ListItem(S:String) Ls:List ) 
        => S +String "::" +String SymbolRefIdList2String(Ls) 
        requires Ls =/=K .List

    rule SymbolRefIdList2String( ListItem(S:String) Ls:List ) => S
        requires Ls ==K .List

    rule SymbolRefIdList2String( _:List ) => "unexpected" [owise]
    syntax String ::= "SymbolRefIdList2String" "(" SymbolRefIdList ")" [function, total]

    rule SymbolRefIdList2String( ID:SymbolRefId :: L:SymbolRefIdList ) 
        => SymbolRefId2String(ID) +String "::" +String SymbolRefIdList2String(L)
        requires L =/=K .SymbolRefIdList

    rule SymbolRefIdList2String( ID:SymbolRefId :: .SymbolRefIdList ) => SymbolRefId2String(ID)
    rule SymbolRefIdList2String( .SymbolRefIdList ) => ""

    // ## ValueId <-> String
    syntax String  ::= "ValueId2String" "(" ValueId ")" [function, total, hook(STRING.token2string)]
    syntax ValueId ::= "String2ValueId" "(" String ")" [function, total, hook(STRING.string2token)]

    syntax String ::= str(ValueId) [function]
    rule str(V:ValueId) => ValueId2String(V)

    // # Syntax Canicalization Helper
    // - it can be hexa-decimal, so this can be failed.
    syntax ValueIdList ::= OpResults2ValueIdList ( OpResults ) [function]
    rule OpResults2ValueIdList( Rs:OpResults) => List2ValueIdList(OpResults2List(Rs))
    
    syntax List ::= OpResults2List ( OpResults ) [function]
    rule OpResults2List( VID:ValueId, Rs:OpResults ) => ListItem(VID) OpResults2List(Rs)
    rule OpResults2List( VID:ValueId : I, Rs:OpResults ) 
        => OpResults2List(VID : I -Int 1, .OpResults) 
            ListItem(String2ValueId(ValueId2String(VID) +String "#" +String Int2String(I -Int 1))) 
            OpResults2List(Rs)
         requires I >Int 0

    rule OpResults2List( _:ValueId : 0, .OpResults ) => .List
    rule OpResults2List( .OpResults ) => .List
    
    syntax ValueIdList ::= List2ValueIdList ( List ) [function]
    rule List2ValueIdList( ListItem(V:ValueId) L:List ) => V, List2ValueIdList(L)
    rule List2ValueIdList(.List) => .ValueIdList

    // FunctionType Canonicalize
    // syntax FunctionType ::= Canonicalize(FunctionType) [function]
    // rule Canonicalize((T1:Types) -> (T2:Types)) => (T1) -> (T2)
    // rule Canonicalize(T1:Type    -> (T2:Types)) => (T1) -> (T2)
    // rule Canonicalize((T1:Types) -> T2:Type)    => (T1) -> (T2)
    // rule Canonicalize(T1:Type    -> T2:Type)    => (T1) -> (T2)
    
    // AttributeEntryList Canonicalize
    // syntax Map ::= Canonicalize(AttributeEntryList) [function]
    // rule Canonicalize(.AttributeEntryList) => .Map
    // rule Canonicalize(N:BareId = V:AttributeValue, AEs:AttributeEntryList) => Canonicalize(AEs) [ BareId2String(N) <- V ]
    // todo: check if there is a need for conflict avoidance
    // rule Canonicalize(N:StringLiteral = V:AttributeValue, AEs:AttributeEntryList) => Canonicalize(AEs) [ N <- V ]
    // rule Canonicalize(N:BareId, AEs:AttributeEntryList) => Canonicalize(AEs) [N <- ""]
    
    // Regions Canonicalize
    // syntax Regions ::= RegionsCanonicalize(Regions) [function]
    // rule RegionsCanonicalize(.Regions) => .Regions
    // rule RegionsCanonicalize(R:Region, Rs:Regions) => Canonicalize(R), RegionsCanonicalize(Rs)
    
    // Region Canonicalize
    // syntax Region ::= Canonicalize(Region) [function]
    // rule Canonicalize({OPs:OperationList BL:BlockList}) => {OpsCanonicalize(OPs) BlocksCanonicalize(BL)}
    
    // OperationList Canonicalize
    // syntax OperationList ::= OpsCanonicalize(OperationList) [function]
    // rule OpsCanonicalize(.OperationList) => .OperationList
    // rule OpsCanonicalize(OP:Operation OPs:OperationList) => Canonicalize(OP) OpsCanonicalize(OPs)
    
    // BlockList Canonicalize
    // syntax BlockList ::= BlocksCanonicalize(BlockList) [function]
    // rule BlocksCanonicalize(.BlockList) => .BlockList
    // rule BlocksCanonicalize(B:Block BL:BlockList) => Canonicalize(B) BlocksCanonicalize(BL)
    
    // // Block Canonicalize
    // syntax Block ::= Canonicalize(Block) [function]
    // rule Canonicalize(BL:BlockLabel OPs:OperationList) => Canonicalize(BL) OpsCanonicalize(OPs)
    
    // BlockLabel Canonicalize
    // syntax BlockLabel ::= Canonicalize(BlockLabel) [function]
    // rule Canonicalize(C:CaretId : ) => C ( .ValueIdAndTypeList ) :
    // rule Canonicalize(B:BlockLabel) => B [owise]

    // // ## Canonicalize Each Operation
    // syntax Operation ::= Canonicalize(Operation) [function]
    // rule Canonicalize(Op:Operation) => Canonicalize1((Canonicalize0(Op)))
    // Fill Operation's Missing Formats
    // --- Towards easy general operation matching for all domains
    // --- Without this process, the dialect-agnostic semantics should enumerate all possible formats of the operation.
    // --- Final Structure: StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties RegionList DictionaryAttribute ":" FunctionType
    
    // syntax Operation ::= Canonicalize0(Operation) [function]
    // rule Canonicalize0(GP:GenericOperation) => Canonicalize0(.OpResults = GP)
    // rule Canonicalize0(Rs = N (Vs) : FT)                            => Rs = N (Vs) [.Successors] <{.AttributeEntryList}> (.Regions) {.AttributeEntryList} : FT
    // rule Canonicalize0(Rs = N (Vs) {AL:AttributeEntryList} : FT)    => Rs = N (Vs) [.Successors] <{.AttributeEntryList}> (.Regions) {AL} : FT
    // rule Canonicalize0(Rs = N (Vs) (R:Regions) : FT)                => Rs = N (Vs) [.Successors] <{.AttributeEntryList}> (R) {.AttributeEntryList} : FT
    // rule Canonicalize0(Rs = N (Vs) <{AL:AttributeEntryList}> : FT)  => Rs = N (Vs) [.Successors] <{AL}> (.Regions) {.AttributeEntryList} : FT
    // rule Canonicalize0(Rs = N (Vs) [Ss:Successors] : FT)            => Rs = N (Vs) [Ss] <{.AttributeEntryList}> (.Regions) {.AttributeEntryList} : FT
    
    // rule Canonicalize0(Rs = N (Vs) (R:Regions) {AL:AttributeEntryList} : FT)               => Rs = N (Vs) [.Successors] <{.AttributeEntryList}> (R) {AL} : FT
    // rule Canonicalize0(Rs = N (Vs) <{AL:AttributeEntryList}> {AL2:AttributeEntryList} : FT) => Rs = N (Vs) [.Successors] <{AL}> (.Regions) {AL2} : FT
    // rule Canonicalize0(Rs = N (Vs) [Ss:Successors] {AL:AttributeEntryList} : FT)            => Rs = N (Vs) [Ss] <{.AttributeEntryList}> (.Regions) {AL} : FT
    // rule Canonicalize0(Rs = N (Vs) <{AL:AttributeEntryList}> (R:Regions) : FT)             => Rs = N (Vs) [.Successors] <{AL}> (R) {.AttributeEntryList} : FT
    // rule Canonicalize0(Rs = N (Vs) [Ss:Successors] (R:Regions) : FT)                       => Rs = N (Vs) [Ss] <{.AttributeEntryList}> (R) {.AttributeEntryList} : FT
    // rule Canonicalize0(Rs = N (Vs) [Ss:Successors] <{AL:AttributeEntryList}> : FT)          => Rs = N (Vs) [Ss] <{AL}> (.Regions) {.AttributeEntryList} : FT
    
    // rule Canonicalize0(Rs = N (Vs) <{AL:AttributeEntryList}> (R:Regions) {AL2:AttributeEntryList} : FT)    => Rs = N (Vs) [.Successors] <{AL}> (R) {AL2} : FT
    // rule Canonicalize0(Rs = N (Vs) [Ss:Successors] (R:Regions) {AL:AttributeEntryList} : FT)               => Rs = N (Vs) [Ss] <{.AttributeEntryList}> (R) {AL} : FT
    // rule Canonicalize0(Rs = N (Vs) [Ss:Successors] <{AL:AttributeEntryList}> {AL2:AttributeEntryList} : FT) => Rs = N (Vs) [Ss] <{AL}> (.Regions) {AL2} : FT
    // rule Canonicalize0(Rs = N (Vs) [Ss:Successors] <{AL:AttributeEntryList}> (R:Regions) : FT)              => Rs = N (Vs) [Ss] <{AL}> (R) {.AttributeEntryList} : FT
    
    // 1111 Rs = N (Vs) [Ss] <{AL}> (R) {AL2} : FT
    //  Canonicalize the Content of the Operation
    
    // syntax Operation ::= Canonicalize1(Operation) [function]
    // rule Canonicalize1(Rs = N (Vs) [Ss:Successors] <{AL1:AttributeEntryList}> (R:Regions) {AL2:AttributeEntryList} : FT) 
    //     => Rs = N (Vs) [Ss] (RegionsCanonicalize(R)) {updateMap(Canonicalize(AL1), Canonicalize(AL2))} : Canonicalize(FT)

    // Get Symbol Table of an Operation
    // syntax Map ::= GetSymbolTable(Operation, List) [function]
    
    // rule GetSymbolTable(Rs = N (Vs) [Ss:Successors] (R:Regions) {AL:Map} : FT, L:List)
    //     => (SymbolRefIdList2String(L ListItem(AL["sym_name"])) |-> (Rs = N (Vs) [Ss] (R) {AL} : FT):Operation) 
    //         GetSymbolTable(R, (L ListItem(AL["sym_name"])):List)
    //     [owise]

    // rule GetSymbolTable(Op, _:List) => .Map
    //     requires getOpAttr(Op, "sym_name") ==K #undefined
    
    // Get Symbol Table of Regions
    // syntax Map ::= GetSymbolTable(Regions, List) [function]
    
    // rule GetSymbolTable(.Regions, _:List) => .Map
    // rule GetSymbolTable({Ops:OperationList BL:BlockList}, L:List) => OpsGetSymbolTable(Ops, L) GetSymbolTable(BL, L)
    // rule GetSymbolTable(R:Region, Rs:Regions, L:List) => GetSymbolTable(R, L) GetSymbolTable(Rs, L) [owise]
    
    // Get Symbol Table of an Operation List
    // syntax Map ::= OpsGetSymbolTable(OperationList, List) [function]
    
    // rule OpsGetSymbolTable(.OperationList, _:List) => .Map
    // rule OpsGetSymbolTable(O:Operation OPs:OperationList, L:List) => GetSymbolTable(O, L) OpsGetSymbolTable(OPs, L)
    
    // Get Symbol Table of a Block List
    // syntax Map ::= GetSymbolTable(BlockList, List) [function]
    
    // rule GetSymbolTable(.BlockList, _:List) => .Map
    // rule GetSymbolTable(_:BlockLabel Os:OperationList BL:BlockList, L:List) => OpsGetSymbolTable(Os, L) GetSymbolTable(BL, L)



    syntax Map ::= attrEntryList2Map(AttributeEntryList) [function]
    rule attrEntryList2Map(.AttributeEntryList) => .Map
    rule attrEntryList2Map(N:BareId = V:AttributeValue, AEs:AttributeEntryList) => attrEntryList2Map(AEs) [ BareId2String(N) <- V ]
    rule attrEntryList2Map(N:String = V:AttributeValue, AEs:AttributeEntryList) => attrEntryList2Map(AEs) [ N <- V ]
    rule attrEntryList2Map(N:BareId, AEs:AttributeEntryList) => attrEntryList2Map(AEs) [N <- ""]
    syntax AttributeValue ::= AttributeValueHelper
    syntax AttributeValueHelper ::= "#undefined" | StringLiteral

    syntax None ::= "#None" [token]
    
    // ------------ standardize ------------
    
    syntax Operation ::= stdizeOp(Operation) [function]
    rule stdizeOp(ORL:OpResultList Op:GenericOperation) => ORL stdizeGenericOp(Op)
    rule stdizeOp(Op:GenericOperation) => stdizeGenericOp(Op)


    syntax GenericOperation ::= stdizeGenericOp(GenericOperation) [function]

    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) : FT:FunctionType) 
        => Op (VL) : stdize(FT)

    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) {AL:AttributeEntryList} : FT:FunctionType) 
        => Op (VL) {attrEntryList2Map(AL)} : stdize(FT)
    
    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) (Rs:Regions) : FT:FunctionType)
        => Op (VL) (stdize(Rs)) : stdize(FT)
    
    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) (Rs:Regions) { AL:AttributeEntryList } : FT:FunctionType)
        => Op (VL) (stdize(Rs)) {attrEntryList2Map(AL)} : stdize(FT)
    
    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) [Ss:Successors] : FT:FunctionType)
        => Op (VL) [Ss] : stdize(FT)
    
    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) [Ss:Successors] { AL:AttributeEntryList } : FT:FunctionType)
        => Op (VL) [Ss] {attrEntryList2Map(AL)} : stdize(FT)
    
    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) [Ss:Successors] (Rs:Regions) : FT:FunctionType)
        => Op (VL) [Ss] (stdize(Rs)) : stdize(FT)
    
    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) [Ss:Successors] (Rs:Regions) { AL:AttributeEntryList } : FT:FunctionType)
        => Op (VL) [Ss] (stdize(Rs)) {attrEntryList2Map(AL)} : stdize(FT)

    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) <{AL:AttributeEntryList}> : FT:FunctionType)
        => Op (VL) {attrEntryList2Map(AL)} : stdize(FT)

    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) <{AL1:AttributeEntryList}> {AL2:AttributeEntryList} : FT:FunctionType)
        => Op (VL) {updateMap(attrEntryList2Map(AL1), attrEntryList2Map(AL2))} : stdize(FT)
    
    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) <{AL:AttributeEntryList}> (Rs:Regions) : FT:FunctionType)
        => Op (VL) (stdize(Rs)) {attrEntryList2Map(AL)} : stdize(FT)
    
    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) <{AL1:AttributeEntryList}> (Rs:Regions) { AL2:AttributeEntryList } : FT:FunctionType)
        => Op (VL) (stdize(Rs)) {updateMap(attrEntryList2Map(AL1), attrEntryList2Map(AL2))} : stdize(FT)
    
    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) [Ss:Successors] <{AL:AttributeEntryList}> : FT:FunctionType)
        => Op (VL) [Ss] {attrEntryList2Map(AL)} : stdize(FT)
    
    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) [Ss:Successors] <{AL1:AttributeEntryList}> { AL2:AttributeEntryList } : FT:FunctionType)
        => Op (VL) [Ss] {updateMap(attrEntryList2Map(AL1), attrEntryList2Map(AL2))} : stdize(FT)
    
    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) [Ss:Successors] <{AL:AttributeEntryList}> (Rs:Regions) : FT:FunctionType)
        => Op (VL) [Ss] (stdize(Rs)) {attrEntryList2Map(AL)} : stdize(FT)
    
    rule stdizeGenericOp(Op:StringLiteral (VL:ValueIdList) [Ss:Successors] <{AL1:AttributeEntryList}> (Rs:Regions) { AL2:AttributeEntryList } : FT:FunctionType)
        => Op (VL) [Ss] (stdize(Rs)) {updateMap(attrEntryList2Map(AL1), attrEntryList2Map(AL2))} : stdize(FT)


    syntax Regions       ::= stdize(Regions) [function]
    syntax BlockList     ::= stdize(BlockList) [function]
    syntax FunctionType  ::= stdize(FunctionType) [function]

    syntax OperationList ::= stdizeOpList(OperationList) [function]

    rule stdize(.Regions) => .Regions
    rule stdize({ OL:OperationList BL:BlockList }, Rs:Regions) => {stdizeOpList(OL) stdize(BL)}, stdize(Rs)

    rule stdize(.BlockList) => .BlockList
    rule stdize(L:BlockLabel OL:OperationList BL:BlockList) => L stdizeOpList(OL) stdize(BL)

    rule stdizeOpList(.OperationList) => .OperationList
    rule stdizeOpList(Op:Operation OL:OperationList) => stdizeOp(Op) stdizeOpList(OL)

    rule stdize((T1:Types) -> (T2:Types)) => (T1) -> (T2)
    rule stdize(T1:Type    -> (T2:Types)) => (T1) -> (T2)
    rule stdize((T1:Types) -> T2:Type)    => (T1) -> (T2)
    rule stdize(T1:Type    -> T2:Type)    => (T1) -> (T2)
endmodule