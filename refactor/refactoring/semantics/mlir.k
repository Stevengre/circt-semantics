requires "ctrl.k"
requires "conf.k"

module MLIR-SYNTAX-CORE
    imports STRING
    imports INT
    imports MAP

    syntax ArraySizePrefix ::= r"[1-9][0-9]*x" [token]
endmodule


module MLIR-ATTR
    imports MLIR-SYNTAX-CORE

    syntax Type

    syntax HwModty ::= "!hw.modty" "<" ModulePortList ">"
    syntax ModulePortList ::= List{ModulePort, ","}
    syntax ModulePort ::= "input" BareId ":" Type
                        | "output" BareId ":" Type
    
    syntax AttributeValue ::= HwModty
    syntax Value ::= HwModty

    syntax StructType ::= "struct" "<" StructFields ">"
    syntax StructField ::= BareId ":" Type
    syntax StructFields ::= List{StructField, ","}
    
    syntax UarrayType ::= "uarray" "<" ArraySizeX Type ">"
    syntax ArraySizeX ::= r"[1-9][0-9]*x" [token]

    syntax Type ::= StructType
                  | UarrayType
    syntax HwEnumType ::= "!hw.enum" "<" HwEnumItems ">"
                        | "enum" "<" HwEnumItems ">"
    syntax HwEnumItems ::= List{HwEnumItem, ","}
    syntax HwEnumItem ::= BareId
    syntax Type ::= HwEnumType

    syntax HwEnum ::= "hw.enum" "(" HwEnumItem "," HwEnumType ")"
    syntax Value ::= HwEnum
endmodule




module MLIR
    imports MLIR-SYNTAX
    imports SYNTAX-HELPER
    imports CONFIGURATION
    
    rule <k> mlir </k>
        <mlir-program>
            .OpResults = S:StringLiteral ( VL:VarList ) [ .Successors ] ( Rs:Regions ) { Attr:Map } : T:FunctionType
            => S ( VL ) ( Rs ) { Attr } : T
            ...
        </mlir-program>
    
    rule <k> mlir </k>
        <mlir-program>
            S:StringLiteral ( VL:VarList ) ( .Regions ) { Attr:Map } : T:FunctionType
            => S ( VL ) { Attr } : T
            ...
        </mlir-program>
    
    rule <k> mlir </k>
        <mlir-program> 
            "builtin.module" ( .VarList ) ( R:Region ) { _:Map } : (.Types) -> (.Types)
            => R
            ... 
        </mlir-program>

    rule <k> mlir </k>
        <mlir-program>
            { Ops:OperationList .BlockList } => Ops
            ...
        </mlir-program>
    
    rule <k> mlir </k>
        <mlir-program> 
            Op:Operation Ops:OperationList => Op ~> Ops
            ...
        </mlir-program>

    rule <k> mlir </k>
        <mlir-program> 
            (.K => Attr[#token("sym_name", "BareId")]) 
            ~> ("hw.module" ( .VarList ) (R:Region) { Attr:Map } : T:FunctionType => R)
            ...
        </mlir-program>
        <symbol-table>
            M:Map => M [ Attr[#token("sym_name", "BareId")] <- "hw.module" ( .VarList ) [ .Successors ] (R) { Attr } : T ]
        </symbol-table>

    rule <k> mlir </k>
        <mlir-program>
            _:String ~> ({ .OperationList B:Block } => B)
            ...
        </mlir-program>

    // sv.macro.decl
    rule <k> mlir </k>
        <mlir-program>
            "sv.macro.decl" ( .VarList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => .K 
            ... 
        </mlir-program>
        <macros> M:Map => M [ Attr[#token("sym_name", "BareId")] <- "" ] </macros>
    
    // sv.bind
    rule <k> mlir </k>
        <mlir-program>
            "sv.bind" ( .VarList ) { _:Map } : ( .Types ) -> ( .Types )
            => .K
            ... 
        </mlir-program>
    
    // sv.hierpath
    rule <k> mlir </k>
        <mlir-program>
            "hw.hierpath" ( .VarList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => .K
            ... 
        </mlir-program>
        <hw-hierpath>
            M:Map => M [ Attr[#token("sym_name", "BareId")] <- Attr[#token("namepath", "BareId")] ]
        </hw-hierpath>
        

    // block head
    rule <k> mlir </k>
        <mlir-program>
            _Module:String
            ~> (_:CaretId (_:VarAndTypeList) : Ops:OperationList => Ops)
            ...
        </mlir-program>
    
    // operation list
    rule <k> mlir </k>
        <mlir-program>
            _Module:String
            ~> (Op:Operation Ops:OperationList => Op ~> Ops)
            ...
        </mlir-program>

    // sv.always
    rule <k> mlir </k>
        <mlir-program>
            _Module:String
            ~> (.OpResults = "sv.always" ( _:VarList ) [ .Successors ] ( _:Region ) { _:Map } : _:FunctionType => .K)
            ...
        </mlir-program>
        // <initial> M:Map => M [Module <- R] </initial>
    
    // sv.initial
    rule <k> mlir </k>
        <mlir-program>
            _Module:String
            ~> (.OpResults = "sv.initial" ( .VarList ) [ .Successors ] ( _:Region ) { _:Map } : _:FunctionType => .K)
            ...
        </mlir-program>
        // <initial> M:Map => M [Module <- R] </initial>

    rule <k> mlir </k>
        <mlir-program>
            _Module:String ~> (_:Operation => .K) ...
        </mlir-program>
        [owise]

    rule  <k> mlir </k>
        <mlir-program> _Module:String ~> .OperationList => .K ... </mlir-program>
    
    rule <k> mlir </k>
        <mlir-program> .OperationList => .K ... </mlir-program>

    // rule <k> mlir => preprocess </k>
    //     <mlir-program> .TopLevel </mlir-program>

    rule <k> mlir => circt </k>
        <mlir-program> .TopLevel </mlir-program>
    
    
endmodule


module SYNTAX-HELPER
    imports MLIR-SYNTAX
    imports LIST
    imports K-EQUAL

    syntax Int ::= integerLiteral2Int ( IntegerLiteral ) [function]
    rule integerLiteral2Int(I:Int) => I
    // TODO: token2string, string拆开
    rule integerLiteral2Int(_:HexaDecimalLiteral) => 0

    syntax String ::= "Var2String" "(" Var ")" [function, total,hook(STRING.token2string)]
    syntax Var ::= "String2Var" "(" String ")" [function, total,hook(STRING.string2token)]

    syntax String ::= "SymbolRefId2StringHelper" "(" SymbolRefId ")" [function, total,hook(STRING.token2string)]
    syntax String ::= "SymbolRefId2String" "(" SymbolRefId ")" [function, total]
    rule SymbolRefId2String(ID) => substrString ( SymbolRefId2StringHelper(ID) , 1 , lengthString(SymbolRefId2StringHelper(ID)) )
    // TODO: 没有临时变量感觉写起来确实很麻烦。

    syntax SymbolRefId ::= "String2SymbolRefId" "(" String ")" [function, total,hook(STRING.string2token)]

    // syntax KItem ::= "FindNext" "(" KItem "," List ")" [function]
    // rule FindNext(_:KItem, .List) => .List
    // rule FindNext (X, ListItem(X) ListItem(Y) _:List) => Y
    // rule FindNext (X, ListItem(_) L:List) => FindNext(X, L)

    // syntax Controller ::= "#revealOperations" | 

    // OpId, Region, Block, order
    // syntax OperationId ::= "op" "(" K "," K "," K "," Int ")" 

    // syntax K ::= getAttributeValue(AttributeEntryList, BareId) [function]
    // rule getAttributeValue(.AttributeEntryList, _:BareId) => .K
    // rule getAttributeValue(ID:BareId = V:AttributeValue, AL:AttributeEntryList, ID) => V
    // rule getAttributeValue(_:AttributeEntry, AL:AttributeEntryList, ID:BareId) => getAttributeValue(AL, ID) [owise]

    syntax Operation ::= operationStandarize(Operation) [function]

    // rule operationStandarize(_:Operation) 
        // => .OpResults = "" (.VarList) [.Successors] (.Regions) {.Map} : (.Types) -> (.Types) [owise]

    // %31 = "comb.extract"(%arg1) <{lowBit = 0 : i32}> {sv.namehint = "shamt"} : (i32) -> i5
    rule operationStandarize(Rs:OpResults = N:StringLiteral (Vs:VarList) <{AEL:AttributeEntryList}> : FT:FunctionType)
        => Rs = N (Vs) [.Successors] (.Regions) {attributeEntryList2Map(AEL)} : functionTypeStandarize(FT)

    rule operationStandarize(Rs:OpResults = N:StringLiteral (Vs:VarList) <{AEL1:AttributeEntryList}> {AEL2:AttributeEntryList} : FT:FunctionType)
        => Rs = N (Vs) [.Successors] (.Regions) {attributeEntryList2Map(AEL1) attributeEntryList2Map(AEL2)} : functionTypeStandarize(FT)

    rule operationStandarize(GP:GenericOperation) => operationStandarize(.OpResults = GP)
    
    rule operationStandarize(Rs:OpResults = N:StringLiteral (Vs:VarList) : FT:FunctionType) 
        => Rs = N (Vs) [.Successors] (.Regions) {.Map} : functionTypeStandarize(FT)
    
    rule operationStandarize(Rs:OpResults = N:StringLiteral (Vs:VarList) {AEL:AttributeEntryList} : FT:FunctionType) 
        => Rs = N (Vs) [.Successors] (.Regions) {attributeEntryList2Map(AEL)} : functionTypeStandarize(FT)

    rule operationStandarize(Rs:OpResults = N:StringLiteral (Vs:VarList) (R:Regions) : FT:FunctionType) 
        => Rs = N (Vs) [.Successors] (regionListStandarize(R)) {.Map} : functionTypeStandarize(FT)

    rule operationStandarize(Rs:OpResults = N:StringLiteral (Vs:VarList) [Ss:Successors] : FT:FunctionType) 
        => Rs = N (Vs) [Ss] (.Regions) {.Map} : functionTypeStandarize(FT)

    rule operationStandarize(Rs:OpResults = N:StringLiteral (Vs:VarList) (R:Regions) {AEL:AttributeEntryList} : FT:FunctionType) 
        => Rs = N (Vs) [.Successors] (regionListStandarize(R)) {attributeEntryList2Map(AEL)} : functionTypeStandarize(FT)
    
    rule operationStandarize(Rs:OpResults = N:StringLiteral (Vs:VarList) [Ss:Successors] {AEL:AttributeEntryList} : FT:FunctionType) 
        => Rs = N (Vs) [Ss] (.Regions) {attributeEntryList2Map(AEL)} : functionTypeStandarize(FT)

    rule operationStandarize(Rs:OpResults = N:StringLiteral (Vs:VarList) [Ss:Successors] (R:Regions) : FT:FunctionType) 
        => Rs = N (Vs) [Ss] (regionListStandarize(R)) {.Map} : functionTypeStandarize(FT)

    rule operationStandarize(Rs:OpResults = N:StringLiteral (Vs:VarList) [Ss:Successors] (R:Regions) {AEL:AttributeEntryList} : FT:FunctionType) 
        => Rs = N (Vs) [Ss] (regionListStandarize(R)) {attributeEntryList2Map(AEL)} : functionTypeStandarize(FT)

    
    syntax FunctionType ::= functionTypeStandarize(FunctionType) [function]
    rule functionTypeStandarize((IT:Types)->(OT:Types)) => (IT) -> (OT)
    rule functionTypeStandarize( T:Type -> (OT:Types)) => (T) -> (OT)
    rule functionTypeStandarize((IT:Types) -> T:Type) => (IT) -> (T)
    rule functionTypeStandarize(IT:Type -> OT:Type) => (IT) -> (OT)

    syntax Regions ::= regionListStandarize(Regions) [function]
    rule regionListStandarize(.Regions) => .Regions
    rule regionListStandarize(R:Region, Rs:Regions) => regionStandarize(R), regionListStandarize(Rs)

    syntax Region ::= regionStandarize(Region) [function]
    rule regionStandarize({OPs:OperationList BL:BlockList}) => {operationListStandarize(OPs) blockListStandarize(BL)}

    syntax OperationList ::= operationListStandarize(OperationList) [function]
    rule operationListStandarize(.OperationList) => .OperationList
    rule operationListStandarize(OP:Operation OPs:OperationList) => operationStandarize(OP) operationListStandarize(OPs)

    syntax BlockList ::= blockListStandarize(BlockList) [function]
    rule blockListStandarize(.BlockList) => .BlockList
    rule blockListStandarize(B:Block BL:BlockList) => blockStandarize(B) blockListStandarize(BL)

    syntax Block ::= blockStandarize(Block) [function]
    rule blockStandarize(BL:BlockLabel OPs:OperationList) 
        => blockLabelStandarize(BL) operationListStandarize(OPs)

    syntax BlockLabel ::= blockLabelStandarize(BlockLabel) [function]
    rule blockLabelStandarize(C:CaretId : ) => C ( .VarAndTypeList ) :
    rule blockLabelStandarize(B:BlockLabel) => B [owise]

    syntax Map ::= attributeEntryList2Map(AttributeEntryList) [function]
    
    rule attributeEntryList2Map(.AttributeEntryList) => .Map

    rule attributeEntryList2Map(N:BareId = V:AttributeValue, AEs:AttributeEntryList) 
        => N |-> V attributeEntryList2Map(AEs)
    
    rule attributeEntryList2Map(N:StringLiteral = V:AttributeValue, AEs:AttributeEntryList)
        => N |-> V attributeEntryList2Map(AEs)
    
    rule attributeEntryList2Map(_:BareId, AEs:AttributeEntryList) 
        => attributeEntryList2Map(AEs)

    // ----------------------------
    // 2.2. Symbol Table
    // ----------------------------
    // operationStandarize(Rs:OpResults = N:StringLiteral (Vs:VarList) [Ss:Successors] (R:Regions) DA:DictionaryAttribute : FT:FunctionType) => Rs = N (Vs) [Ss] (regionListStandarize(R)) DA : functionTypeStandarize(FT)
    syntax Map ::= getSymbolTable(Operation, List) [function]

    rule getSymbolTable(Rs:OpResults = N:StringLiteral (Vs:VarList) [Ss:Successors] (R:Regions) {AL:Map} : FT:FunctionType, L:List)
        => ( L ListItem(AL[#token("sym_name","BareId")]) |-> (Rs = N (Vs) [Ss] (R) {AL} : FT):Operation) 
            getSymbolTableFromRegions(R, L ListItem(AL[#token("sym_name","BareId")]))
        requires AL[#token("sym_name","BareId")] orDefault "" =/=K ""

    rule getSymbolTable(_:OpResults = _:StringLiteral (_:VarList) [_:Successors] (R:Regions) {AL:Map} : _:FunctionType, L:List)
        => getSymbolTableFromRegions(R, L)
        requires AL[#token("sym_name","BareId")] orDefault "" ==K ""

    // OperationList BlockList
    syntax Map ::= getSymbolTableFromRegions(Regions, List) [function]

    rule getSymbolTableFromRegions(.Regions, _:List) => .Map

    rule getSymbolTableFromRegions({Ops:OperationList BL:BlockList}, L:List)
        => getSymbolTableFromOperationList(Ops, L) getSymbolTableFromBlockList(BL, L)

    rule getSymbolTableFromRegions(R:Region, Rs:Regions, L:List)
        => getSymbolTableFromRegions(R, L) getSymbolTableFromRegions(Rs, L) [owise]


    syntax Map ::= getSymbolTableFromOperationList(OperationList, List) [function]

    rule getSymbolTableFromOperationList(.OperationList, _:List) => .Map

    rule getSymbolTableFromOperationList(O:Operation OPs:OperationList, L:List)
        => getSymbolTable(O, L) getSymbolTableFromOperationList(OPs, L)

    
    syntax Map ::= getSymbolTableFromBlockList(BlockList, List) [function]
    
    rule getSymbolTableFromBlockList(.BlockList, _:List) => .Map

    rule getSymbolTableFromBlockList(_:BlockLabel Os:OperationList BL:BlockList, L:List) 
        => getSymbolTableFromOperationList(Os, L) getSymbolTableFromBlockList(BL, L)
endmodule