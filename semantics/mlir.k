requires "ctrl.k"
requires "conf.k"

module MLIR-SYNTAX-CORE
    imports STRING
    imports INT
    imports MAP

    // ------------------------- Common Syntax ------------------------- //
    // ignore digit, hex_digit, letter, id-punct since k lacks combination of regex and token
    // digit     ::= [0-9]
    // hex_digit ::= [0-9a-fA-F]
    // letter    ::= [a-zA-Z]
    // id-punct  ::= [$._-]
    syntax IntegerLiteral ::= DecimalLiteral | HexaDecimalLiteral
    syntax DecimalLiteral ::= Int
    syntax HexaDecimalLiteral ::= r"0x[0-9a-fA-F]+" [prefer,token,prec(2)]
    syntax FloatLiteral ::= r"[\\+-]?[0-9]+\\.[0-9]*([eE][\\+-]?[0-9]+)?" [token,prec(1)]
    syntax StringLiteral ::= String

    syntax BareId ::= r"[a-zA-Z_][a-zA-Z0-9_$\\.]*" [token]
    syntax BareIdList ::= List{BareId, ","}
    // syntax BareIdList ::= BareId 
                        // | BareId "," BareIdList [prefer] // ambiguity with AffineExprList & No other use
    
    syntax Var ::= r"%[0-9]+(#[0-9]+)?" [prefer,token,prec(3)]
    syntax Var ::= r"%[a-zA-Z$\\._-][a-zA-Z0-9$\\._-]*(#[0-9]+)?" [token]
    syntax VarList ::= List{Var, ","}
    // syntax ValueUse ::= Var | Var "#" IntegerLiteral // fix the error in lang-ref
    // syntax ValueUseLit ::= ValueUse | ValueUse "," ValueUseLit
    syntax SymbolRefId ::= r"@[0-9]+" [token]
    syntax SymbolRefId ::= r"@[a-zA-Z$\\._-][a-zA-Z0-9$\\._-]*" [token]
    // syntax SymbolRefId ::= "@" StringLiteral [token]
    syntax SymbolRefIdList ::= SymbolRefId | SymbolRefId "::" SymbolRefIdList
    // syntax SymbolRefIdList ::= List{SymbolRefId, "::"}
    // syntax SymbolRefId ::= SymbolRefId "::" SymbolRefId [token]
    
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
endmodule


module MLIR-SYNTAX
    imports MLIR-ATTR
    // imports CTRL

    // ------------------------- Top-Level Productions ------------------------- //
    syntax TopLevel ::= List{TopLevelElement,""}
    syntax TopLevelElement ::= Operation | AttributeAliasDef | TypeAliasDef
    // syntax TopLevel ::= TopLevelElement | TopLevelElement TopLevel

    // ------------------------- Operations ------------------------- //
    // operation ::= op-result-list? (generic-operation | custom-operation) trailing-location?
    syntax Operation ::= OpResultList GenericOperation TrailingLocation // 11
                       | OpResultList CustomOperation TrailingLocation // 11
                       | GenericOperation TrailingLocation // 01
                       | CustomOperation TrailingLocation // 01
                       | OpResultList GenericOperation // 10
                       | OpResultList CustomOperation // 10
                       | GenericOperation // 00
                       | CustomOperation // 00
    
    syntax GenericOperation ::= StringLiteral "(" VarList ")" ":" FunctionType
                              | StringLiteral "(" VarList ")" DictionaryAttribute ":" FunctionType
                              | StringLiteral "(" VarList ")" RegionList ":" FunctionType
                              | StringLiteral "(" VarList ")" SuccessorList ":" FunctionType
                              | StringLiteral "(" VarList ")" RegionList DictionaryAttribute ":" FunctionType
                              | StringLiteral "(" VarList ")" SuccessorList DictionaryAttribute ":" FunctionType                        
                              | StringLiteral "(" VarList ")" SuccessorList RegionList ":" FunctionType                            
                              | StringLiteral "(" VarList ")" SuccessorList RegionList DictionaryAttribute ":" FunctionType
    
    // with DictionaryProperties
    syntax GenericOperation ::= StringLiteral "(" VarList ")" DictionaryProperties ":" FunctionType
                              | StringLiteral "(" VarList ")" DictionaryProperties DictionaryAttribute ":" FunctionType
                              | StringLiteral "(" VarList ")" DictionaryProperties RegionList ":" FunctionType
                              | StringLiteral "(" VarList ")" SuccessorList DictionaryProperties ":" FunctionType
                              | StringLiteral "(" VarList ")" DictionaryProperties RegionList DictionaryAttribute ":" FunctionType
                              | StringLiteral "(" VarList ")" SuccessorList DictionaryProperties DictionaryAttribute ":" FunctionType                        
                              | StringLiteral "(" VarList ")" SuccessorList DictionaryProperties RegionList ":" FunctionType                            
                              | StringLiteral "(" VarList ")" SuccessorList DictionaryProperties RegionList DictionaryAttribute ":" FunctionType

    syntax DictionaryProperties ::= "<" DictionaryAttribute ">"

    syntax OpResult ::= Var 
                      | Var ":" IntegerLiteral
    syntax OpResults ::= List{OpResult, ","}
    syntax OpResultList ::= OpResults "="

    syntax Successor ::= CaretId ":" BlockArgList
    syntax Successors ::= List{Successor, ","}
    syntax SuccessorList ::= "[" Successors "]"

    syntax Regions ::= List{Region, ","}
    syntax RegionList ::= "(" Regions ")"

    syntax DictionaryAttribute ::= "{" AttributeEntryList "}"
                                 | "{" Map "}"
    syntax TrailingLocation ::= "loc" "(" Location ")"

    // ------------------------- Blocks ------------------------- //
    syntax Block ::= BlockLabel OperationList
    syntax OperationList ::= List{Operation, ""} [prefer] // the prefer may not be used when there is configuration
    syntax BlockLabel ::= CaretId ":" | CaretId "(" VarAndTypeList ")" ":"
    // block-id        ::= caret-id
    syntax CaretId ::= r"\\^[0-9]+" [token]
    syntax CaretId ::= r"\\^[a-zA-Z$\\._-][a-zA-Z0-9$\\._-]*" [token]
    syntax VarAndType ::= Var ":" Type
    syntax VarAndTypeList ::= List{VarAndType, ","}
    syntax BlockArgList ::= "(" VarAndTypeList ")"

    // ------------------------- Regions ------------------------- //
    syntax Region ::= "{" OperationList BlockList "}"
                    // | "{" "}" [prefer]
                    // | "{" BlockList "}" 
                    // | "{" OperationList "}" 
                    
    syntax BlockList ::= List{Block, ""}


    // ------------------------- Type System ------------------------- //
    syntax Type ::= TypeAlias 
                //   | DialectType
                  | BuiltinType

    syntax Types ::= List{Type, ","}
    // 此处和文档是不一致的，但是可能是要
    syntax TypeListParens ::= "(" Types ")" //| "(" SsaUseAndTypeList ")"
    // syntax SsaUseAndType ::= Var ":" Type
    // // ssa-use ::= value-use
    // syntax SsaUseAndTypeList ::= SsaUseAndType | SsaUseAndType "," SsaUseAndTypeList
    syntax FunctionType ::= TypeListParens "->" TypeListParens [prefer]
                        | Type "->" TypeListParens
                        | TypeListParens "->" Type
                        | Type "->" Type

    // ------------------------- Type Aliases ------------------------- //
    syntax TypeAliasDef ::= TypeAlias "=" Type
    syntax TypeAlias ::= r"![a-zA-Z_][a-zA-Z0-9_$\\.]*" [token] // TODO: put into the top

    // ------------------------- Dialect Types ------------------------- //
    // dialect-namespace ::= bare-id

    syntax DialectType ::= TypeAlias DialectTypeBody [prefer]
                         | TypeAlias "." PrettyDialectTypeLeadIdent DialectTypeBody
                         | TypeAlias "." PrettyDialectTypeLeadIdent
    
    syntax PrettyDialectTypeLeadIdent ::= r"[A-Za-z][A-Za-z0-9\\._]*" [token]
    
    syntax DialectTypeBody ::= "<" ">"
                             | "<" DialectTypeContentsList ">"
    
    syntax DialectTypeContentsList ::= List{DialectTypeContents, ""}
    
    syntax DialectTypeContents ::= DialectTypeBody
                                 | "(" DialectTypeContentsList ")"
                                 | "[" DialectTypeContentsList "]"
                                 | "{" DialectTypeContentsList "}"
                                 | BareId
                                 | StringLiteral
                                 | "+"
                                 | "?"
                                 | ","
                                 | TypeAlias // solve bug
                                 | SymbolRefId
                                 | AttributeValue

    // DialectTypeContent ::= '[^\[<({\]>)}\0]+'
    // It's hard to define like this, we just use special characters to represent the content.
    // It may cause some problems, but it's not a big deal. 
    // We can add more special characters if needed.

    // ------------------------- Attributes ------------------------- //
    syntax AttributeEntryList ::= List{AttributeEntry, ","}

    syntax AttributeEntry ::= BareId "=" AttributeValue
                            | StringLiteral "=" AttributeValue
                            | BareId

    syntax AttributeValue ::= AttributeAlias
                            | DialectAttribute
                            | BuiltinAttribute
                            | StringLiteral

    // ------------------------- Attribute Value Aliases ------------------------- //
    // syntax AttributeAliasDef ::= "#" BareId "=" AttributeValue
    // syntax AttributeAlias ::= "#" BareId

    // // ------------------------- Dialect Attribute Values ------------------------- //
    // // dialect-namespace ::= bare-id
    // syntax DialectAttribute ::= "#" BareId DialectTypeBody
    //                      | "#" BareId "." PrettyDialectTypeLeadIdent DialectTypeBody
    //                      | "#" BareId "." PrettyDialectTypeLeadIdent
    // // DialectAttribute is the same as DialectType except that it starts with "#".

    syntax AttributeAliasDef ::= AttributeAlias "=" AttributeValue
    syntax AttributeAlias ::= r"#[a-zA-Z_][a-zA-Z0-9_$\\.]*" [token] // TODO: put into the top

    // ------------------------- Dialect Attribute Values ------------------------- //
    // dialect-namespace ::= bare-id
    syntax DialectAttribute ::= AttributeAlias DialectTypeBody
                              | AttributeAlias "." PrettyDialectTypeLeadIdent DialectTypeBody
                              | AttributeAlias "." PrettyDialectTypeLeadIdent
    // DialectAttribute is the same as DialectType except that it starts with "#".

    // ------------------------- Non-deterministic Opaque Syntax ------------------------- //
    // The following syntaxes are not deterministic. 
    // Builtin dialect specifies the following syntaxes, and other dialects must import them.
    syntax Location //::= "?"
    syntax CustomOperation // ::= BareId CustomOperationFormat
    syntax BuiltinType
    syntax BuiltinAttribute
    // syntax CustomOperationFormat
endmodule


module MLIR
    imports MLIR-SYNTAX
    imports SYNTAX-HELPER
    imports CONFIGURATION
    
    // rule <k> mlir </k>
    //     <mlir-program> E:TopLevelElement T:TopLevel => E ~> T ... </mlir-program>

    rule <k> mlir </k>
        <mlir-program> 
            Alias:AttributeAlias = Attr:AttributeValue T:TopLevel => T
            ...
        </mlir-program>
        <attr-alias> M:Map => M [Alias <- Attr] </attr-alias>

    rule <k> mlir </k>
        <mlir-program>
            Op:Operation T:TopLevel => operationStandarize(Op) ~> T
            ...
        </mlir-program>
    
    // rule <k> mlir </k>
    //     <mlir-program> .TopLevel => . ... </mlir-program>

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