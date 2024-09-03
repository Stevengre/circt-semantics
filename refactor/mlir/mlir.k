requires "./builtin.k"

module MLIR-SYNTAX
    imports STRING
    imports INT
    imports MAP
    // # Notation

    // ## Common Syntax
    syntax IntegerLiteral       ::= DecimalLiteral | HexaDecimalLiteral
    syntax DecimalLiteral       ::= Int
    syntax HexaDecimalLiteral   ::= r"0x[0-9a-fA-F]+" [prefer,token,prec(2)]
    syntax FloatLiteral         ::= r"[\\+-]?[0-9]+\\.[0-9]*([eE][\\+-]?[0-9]+)?" [token,prec(1)]
    syntax StringLiteral        ::= String

    // ## Top Level Productions
    syntax TopLevel ::= List{TopLevelElement,""}
    syntax TopLevelElement ::= Operation | AttributeAliasDef | TypeAliasDef

    // ## Identifiers and Keywords
    syntax BareId           ::= r"[a-zA-Z_][a-zA-Z0-9_$\\.]*" [token]
    syntax BareIdList       ::= List{BareId, ","}
    syntax ValueId          ::= r"%[a-zA-Z0-9$\\._-]+(#[0-9]+)?" [token] // indeed, value-use
    syntax ValueIdList      ::= List{ValueId, ","}
    syntax SymbolRefId      ::= r"@[a-zA-Z0-9$\\._-]+" [token]
    syntax SymbolRefIdList  ::= List{SymbolRefId, "::"}
    syntax CaretId          ::= r"\\^[a-zA-Z0-9$\\._-]+" [token]
    syntax TypeAlias        ::= r"![a-zA-Z_][a-zA-Z0-9_$\\.]*" [token]
    syntax AttributeAlias   ::= r"#[a-zA-Z_][a-zA-Z0-9_$\\.]*" [token]
    
    // # Operations
    syntax Operation ::= OpResultList GenericOperation TrailingLocation // 11
                       | OpResultList CustomOperation TrailingLocation // 11
                       | GenericOperation TrailingLocation // 01
                       | CustomOperation TrailingLocation // 01
                       | OpResultList GenericOperation // 10
                       | OpResultList CustomOperation // 10
                       | GenericOperation // 00
                       | CustomOperation // 00
    
    syntax GenericOperation ::= StringLiteral "(" ValueIdList ")" ":" FunctionType
                              | StringLiteral "(" ValueIdList ")" DictionaryAttribute ":" FunctionType
                              | StringLiteral "(" ValueIdList ")" RegionList ":" FunctionType
                              | StringLiteral "(" ValueIdList ")" SuccessorList ":" FunctionType
                              | StringLiteral "(" ValueIdList ")" RegionList DictionaryAttribute ":" FunctionType
                              | StringLiteral "(" ValueIdList ")" SuccessorList DictionaryAttribute ":" FunctionType                        
                              | StringLiteral "(" ValueIdList ")" SuccessorList RegionList ":" FunctionType                            
                              | StringLiteral "(" ValueIdList ")" SuccessorList RegionList DictionaryAttribute ":" FunctionType
    
    // with DictionaryProperties
    syntax GenericOperation ::= StringLiteral "(" ValueIdList ")" DictionaryProperties ":" FunctionType
                              | StringLiteral "(" ValueIdList ")" DictionaryProperties DictionaryAttribute ":" FunctionType
                              | StringLiteral "(" ValueIdList ")" DictionaryProperties RegionList ":" FunctionType
                              | StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties ":" FunctionType
                              | StringLiteral "(" ValueIdList ")" DictionaryProperties RegionList DictionaryAttribute ":" FunctionType
                              | StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties DictionaryAttribute ":" FunctionType                        
                              | StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties RegionList ":" FunctionType                            
                              | StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties RegionList DictionaryAttribute ":" FunctionType
    
    syntax CustomOperation // ::= BareId CustomOperationFormat

    syntax DictionaryProperties ::= "<" DictionaryAttribute ">"

    syntax OpResult ::= ValueId 
                      | ValueId ":" IntegerLiteral
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
    syntax Location //::= "?"

    // # Blocks
    syntax Block ::= BlockLabel OperationList
    syntax OperationList ::= List{Operation, ""} [prefer] // the prefer may not be used when there is configuration
    syntax BlockLabel ::= CaretId ":" | CaretId "(" ValueIdAndTypeList ")" ":"
    syntax ValueIdAndType ::= ValueId ":" Type
    syntax ValueIdAndTypeList ::= List{ValueIdAndType, ","}
    syntax BlockArgList ::= "(" ValueIdAndTypeList ")"

    // # Regions 
    syntax Region ::= "{" OperationList BlockList "}"
    syntax BlockList ::= List{Block, ""}


    // # Type System 
    syntax Type ::= TypeAlias | DialectType | BuiltinType
    syntax Types ::= List{Type, ","}
    syntax TypeListParens ::= "(" Types ")" 
    syntax FunctionType ::= TypeListParens "->" TypeListParens [prefer]
                        | Type "->" TypeListParens
                        | TypeListParens "->" Type
                        | Type "->" Type

    // ## Type Aliases 
    syntax TypeAliasDef ::= TypeAlias "=" Type

    // ## Dialect Types 
    syntax DialectType

    // ## Builtin Types
    syntax BuiltinType

    // # Attributes 
    syntax AttributeEntryList ::= List{AttributeEntry, ","}

    syntax AttributeEntry ::= BareId "=" AttributeValue
                            | StringLiteral "=" AttributeValue
                            | BareId

    syntax AttributeValue ::= AttributeAlias
                            | DialectAttribute
                            | BuiltinAttribute
                            | StringLiteral

    // ## Attribute Value Aliases 
    syntax AttributeAliasDef ::= AttributeAlias "=" AttributeValue

    // ## Dialect Attribute Values
    syntax DialectAttribute

    // ## Builtin Attribute Values
    syntax BuiltinAttribute
    
    // # More Syntax Helpers
    syntax BareIdAndType ::= BareId ":" Type
    syntax BareIdAndTypeList ::= List{BareIdAndType, ","}

    syntax DialectAttribute ::= DialectType
endmodule


module MLIR-HELPER
    imports MLIR-SYNTAX
    imports MAP
    imports LIST
    imports K-EQUAL
    // # Predefined Status
    
    // # Attribute Value Helpers
    syntax AttributeValue ::= AttributeValueHelper
    syntax AttributeValueHelper ::= "#undefined"

    // # Gets
    // ## Get Attribute Value
    syntax AttributeValue ::= getAttr(Operation, String) [function]
    rule getAttr(_ = _ (_) [_:Successors] <{_:Map}> (_:Regions) {AL2:Map} : _, BID)
         => {AL2[BID] orDefault #undefined}:>AttributeValue

    syntax AttributeValue ::= getAttr(Map, String) [function]
    rule getAttr(M:Map, BID:String) => {M[BID] orDefault #undefined}:>AttributeValue
    
    // ## Get Operation Name
    syntax String ::= getOpName(Operation) [function]
    rule getOpName(_ = Op:GenericOperation) => getOpName(Op)
    rule getOpName(OpName (_) [_:Successors] <{_:Map}> (_:Regions) {_:Map} : _) 
         => OpName
    
    // ## Get Operation Results
    syntax Regions ::= getRegions(Operation) [function]
    rule getRegions(_ = Op:GenericOperation) => getRegions(Op)
    rule getRegions(_ (_) [_:Successors] <{_:Map}> (R:Regions) {_:Map} : _) => R
     
    // # Tokens <-> Strings
    // ## BareId <-> String
    syntax String ::= BareId2String(BareId) [function, total, hook(STRING.token2string)]
    // ## SymbolRefId <-> String
    syntax String ::= "SymbolRefId2StringHelper" "(" SymbolRefId ")" [function, total,hook(STRING.token2string)]
    syntax String ::= "SymbolRefId2String" "(" SymbolRefId ")" [function, total]
    rule SymbolRefId2String(ID) => substrString ( SymbolRefId2StringHelper(ID) , 1 , lengthString(SymbolRefId2StringHelper(ID)) ) // TODO: 没有临时变量感觉写起来确实很麻烦。

    syntax SymbolRefId ::= "String2SymbolRefIdHelper" "(" String ")" [function, total, hook(STRING.string2token)]
    syntax SymbolRefId ::= "String2SymbolRefId" "(" String ")" [function, total]
    rule String2SymbolRefId(S:String) => String2SymbolRefIdHelper("@" +String S)

    // ## List of String (SymbolRefId) -> String
    syntax String ::= "SymbolRefIdList2String" "(" List ")" [function, total]
    rule SymbolRefIdList2String(.List) => ""
    rule SymbolRefIdList2String( ListItem( #undefined ) Ls:List ) => SymbolRefIdList2String(Ls)
    rule SymbolRefIdList2String( ListItem(S:String) Ls:List ) => S +String "::" +String SymbolRefIdList2String(Ls) 
         requires Ls =/=K .List
    rule SymbolRefIdList2String( ListItem(S:String) Ls:List ) => S
         requires Ls ==K .List
    rule SymbolRefIdList2String( _:List ) => "unexpected" [owise]
    syntax String ::= "SymbolRefIdList2String" "(" SymbolRefIdList ")" [function, total]
    rule SymbolRefIdList2String( ID:SymbolRefId :: L:SymbolRefIdList ) => SymbolRefId2String(ID) +String "::" +String SymbolRefIdList2String(L)
    requires L =/=K .SymbolRefIdList
    rule SymbolRefIdList2String( ID:SymbolRefId :: .SymbolRefIdList ) => SymbolRefId2String(ID)
    rule SymbolRefIdList2String( .SymbolRefIdList ) => ""

    // ## ValueId <-> String
    syntax String ::= "ValueId2String" "(" ValueId ")" [function, total, hook(STRING.token2string)]
    syntax ValueId ::= "String2ValueId" "(" String ")" [function, total, hook(STRING.string2token)]

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

    // #### FunctionType Canonicalize
    syntax FunctionType ::= Canonicalize(FunctionType) [function]
    rule Canonicalize((IT:Types)->(OT:Types))   => (IT) -> (OT)
    rule Canonicalize( T:Type -> (OT:Types))    => (T) -> (OT)
    rule Canonicalize((IT:Types) -> T:Type)     => (IT) -> (T)
    rule Canonicalize(IT:Type -> OT:Type)       => (IT) -> (OT)
    
    // #### AttributeEntryList Canonicalize
    syntax Map ::= Canonicalize(AttributeEntryList) [function]
    rule Canonicalize(.AttributeEntryList) => .Map
    rule Canonicalize(N:BareId = V:AttributeValue, AEs:AttributeEntryList) => BareId2String(N) |-> V Canonicalize(AEs)
    // todo: check if there is a need for conflict avoidance
    rule Canonicalize(N:StringLiteral = V:AttributeValue, AEs:AttributeEntryList) => N |-> V Canonicalize(AEs)
    rule Canonicalize(_:BareId, AEs:AttributeEntryList) => Canonicalize(AEs)
    
    // #### Regions Canonicalize
    syntax Regions ::= RegionsCanonicalize(Regions) [function]
    rule RegionsCanonicalize(.Regions) => .Regions
    rule RegionsCanonicalize(R:Region, Rs:Regions) => Canonicalize(R), RegionsCanonicalize(Rs)
    
    // #### Region Canonicalize
    syntax Region ::= Canonicalize(Region) [function]
    rule Canonicalize({OPs:OperationList BL:BlockList}) => {OpsCanonicalize(OPs) BlocksCanonicalize(BL)}
    
    // #### OperationList Canonicalize
    syntax OperationList ::= OpsCanonicalize(OperationList) [function]
    rule OpsCanonicalize(.OperationList) => .OperationList
    rule OpsCanonicalize(OP:Operation OPs:OperationList) => Canonicalize(OP) OpsCanonicalize(OPs)
    
    // #### BlockList Canonicalize
    syntax BlockList ::= BlocksCanonicalize(BlockList) [function]
    rule BlocksCanonicalize(.BlockList) => .BlockList
    rule BlocksCanonicalize(B:Block BL:BlockList) => Canonicalize(B) BlocksCanonicalize(BL)
    
    // #### Block Canonicalize
    syntax Block ::= Canonicalize(Block) [function]
    rule Canonicalize(BL:BlockLabel OPs:OperationList) => Canonicalize(BL) OpsCanonicalize(OPs)
    
    // #### BlockLabel Canonicalize
    syntax BlockLabel ::= Canonicalize(BlockLabel) [function]
    rule Canonicalize(C:CaretId : ) => C ( .ValueIdAndTypeList ) :
    rule Canonicalize(B:BlockLabel) => B [owise]

      // ## Canonicalize Each Operation
    syntax Operation ::= Canonicalize(Operation) [function]
    rule Canonicalize(Op:Operation) => Canonicalize1((Canonicalize0(Op)))
    // ### Fill Operation's Missing Formats
    // --- Towards easy general operation matching for all domains
    // --- Without this process, the dialect-agnostic semantics should enumerate all possible formats of the operation.
    // --- Final Structure: StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties RegionList DictionaryAttribute ":" FunctionType
    
    syntax Operation ::= Canonicalize0(Operation) [function]
    rule Canonicalize0(GP:GenericOperation) => Canonicalize0(.OpResults = GP)
    // 0000
    rule Canonicalize0(Rs = N (Vs) : FT)                            => Rs = N (Vs) [.Successors] <{.AttributeEntryList}> (.Regions) {.AttributeEntryList} : FT
    // 0001
    rule Canonicalize0(Rs = N (Vs) {AL:AttributeEntryList} : FT)    => Rs = N (Vs) [.Successors] <{.AttributeEntryList}> (.Regions) {AL} : FT
    // 0010
    rule Canonicalize0(Rs = N (Vs) (R:Regions) : FT)                => Rs = N (Vs) [.Successors] <{.AttributeEntryList}> (R) {.AttributeEntryList} : FT
    // 0100
    rule Canonicalize0(Rs = N (Vs) <{AL:AttributeEntryList}> : FT)  => Rs = N (Vs) [.Successors] <{AL}> (.Regions) {.AttributeEntryList} : FT
    // 1000
    rule Canonicalize0(Rs = N (Vs) [Ss:Successors] : FT)            => Rs = N (Vs) [Ss] <{.AttributeEntryList}> (.Regions) {.AttributeEntryList} : FT
    // 0011
    rule Canonicalize0(Rs = N (Vs) (R:Regions) {AL:AttributeEntryList} : FT) => Rs = N (Vs) [.Successors] <{.AttributeEntryList}> (R) {AL} : FT
    // 0101
    rule Canonicalize0(Rs = N (Vs) <{AL:AttributeEntryList}> {AL2:AttributeEntryList} : FT) => Rs = N (Vs) [.Successors] <{AL}> (.Regions) {AL2} : FT
    // 1001
    rule Canonicalize0(Rs = N (Vs) [Ss:Successors] {AL:AttributeEntryList} : FT) => Rs = N (Vs) [Ss] <{.AttributeEntryList}> (.Regions) {AL} : FT
    // 0110
    rule Canonicalize0(Rs = N (Vs) <{AL:AttributeEntryList}> (R:Regions) : FT) => Rs = N (Vs) [.Successors] <{AL}> (R) {.AttributeEntryList} : FT
    // 1010
    rule Canonicalize0(Rs = N (Vs) [Ss:Successors] (R:Regions) : FT) => Rs = N (Vs) [Ss] <{.AttributeEntryList}> (R) {.AttributeEntryList} : FT
    // 1100
    rule Canonicalize0(Rs = N (Vs) [Ss:Successors] <{AL:AttributeEntryList}> : FT) => Rs = N (Vs) [Ss] <{AL}> (.Regions) {.AttributeEntryList} : FT
    // 0111
    rule Canonicalize0(Rs = N (Vs) <{AL:AttributeEntryList}> (R:Regions) {AL2:AttributeEntryList} : FT) => Rs = N (Vs) [.Successors] <{AL}> (R) {AL2} : FT
    // 1011
    rule Canonicalize0(Rs = N (Vs) [Ss:Successors] (R:Regions) {AL:AttributeEntryList} : FT) => Rs = N (Vs) [Ss] <{.AttributeEntryList}> (R) {AL} : FT
    // 1101
    rule Canonicalize0(Rs = N (Vs) [Ss:Successors] <{AL:AttributeEntryList}> {AL2:AttributeEntryList} : FT) => Rs = N (Vs) [Ss] <{AL}> (.Regions) {AL2} : FT
    // 1110
    rule Canonicalize0(Rs = N (Vs) [Ss:Successors] <{AL:AttributeEntryList}> (R:Regions) : FT) => Rs = N (Vs) [Ss] <{AL}> (R) {.AttributeEntryList} : FT
    // 1111 Rs = N (Vs) [Ss] <{AL}> (R) {AL2} : FT
    // ### Canonicalize the Content of the Operation
    
    syntax Operation ::= Canonicalize1(Operation) [function]
    rule Canonicalize1(Rs = N (Vs) [Ss:Successors] <{AL1:AttributeEntryList}> (R:Regions) {AL2:AttributeEntryList} : FT) 
        => Rs = N (Vs) [Ss] <{.Map}> (RegionsCanonicalize(R)) {updateMap(Canonicalize(AL1), Canonicalize(AL2))} : Canonicalize(FT)
        // => Rs = N (Vs) [Ss] <{Canonicalize(AL1)}> (RegionsCanonicalize(R)) {Canonicalize(AL2)} : Canonicalize(FT)

    // Get Symbol Table of an Operation
    syntax Map ::= GetSymbolTable(Operation, List) [function]
    rule GetSymbolTable(Rs = N (Vs) [Ss:Successors] <{AL:Map}> (R:Regions) {AL1:Map} : FT, L:List)
        => (SymbolRefIdList2String(L ListItem(AL1["sym_name"])) |-> (Rs = N (Vs) [Ss] <{AL}> (R) {AL1} : FT):Operation) GetSymbolTable(R, (L ListItem(AL1["sym_name"])):List)
        [owise]
    rule GetSymbolTable(Op, _:List) => .Map requires getAttr(Op, "sym_name") ==K #undefined
    
    // Get Symbol Table of Regions
    syntax Map ::= GetSymbolTable(Regions, List) [function]
    rule GetSymbolTable(.Regions, _:List) => .Map
    rule GetSymbolTable({Ops:OperationList BL:BlockList}, L:List) => OpsGetSymbolTable(Ops, L) GetSymbolTable(BL, L)
    rule GetSymbolTable(R:Region, Rs:Regions, L:List) => GetSymbolTable(R, L) GetSymbolTable(Rs, L) [owise]
    
    // Get Symbol Table of an Operation List
    syntax Map ::= OpsGetSymbolTable(OperationList, List) [function]
    rule OpsGetSymbolTable(.OperationList, _:List) => .Map
    rule OpsGetSymbolTable(O:Operation OPs:OperationList, L:List) => GetSymbolTable(O, L) OpsGetSymbolTable(OPs, L)
    
    // Get Symbol Table of a Block List
    syntax Map ::= GetSymbolTable(BlockList, List) [function]
    rule GetSymbolTable(.BlockList, _:List) => .Map
    rule GetSymbolTable(_:BlockLabel Os:OperationList BL:BlockList, L:List) => OpsGetSymbolTable(Os, L) GetSymbolTable(BL, L)
endmodule


module MLIR-CONF
    imports MLIR-SYNTAX

    syntax Control ::= "#preprocess" 
                     | "#canonicalized"
                     | "#build"
                     | "#end"

    configuration
    <mlir>
        <prog> $PGM:TopLevel </prog>
        <phase> #preprocess </phase>
        <types> .Map </types>
        <attrs> .Map </attrs>
        <table> .Map </table>
    </mlir>
endmodule


module MLIR
    imports MLIR-SYNTAX
    imports MLIR-HELPER
    imports MLIR-CONF
    imports BUILTIN
   
    
    // # Assign Aliases
    rule <phase> #preprocess </phase>
        <prog> Alias:AttributeAlias = Attr:AttributeValue T:TopLevel => T </prog>
        <attrs> M:Map => M [Alias <- Attr] </attrs>
    
    rule <phase> #preprocess </phase>
        <prog> Alias:TypeAlias = T:Type P:TopLevel => P </prog>
        <types> M:Map => M [Alias <- T] </types>

    // # Canonicalize Operations
    rule <phase> #preprocess => #canonicalized </phase>
        <prog> Op:Operation P:TopLevel => Canonicalize(Op) P </prog>

  
    // # Construct Symbol Table
    rule <phase> #canonicalized => #preprocess </phase>
        <prog> Op:Operation P:TopLevel => P </prog>
        <table> M:Map => M GetSymbolTable(Op, .List) </table>
        requires getAttr(Op, "sym_name") =/=K #undefined
    
    // builtin.module
    rule <phase> #canonicalized => #preprocess </phase>
        <prog> Op:Operation P:TopLevel => P </prog>
        <table> M:Map => M GetSymbolTable(getRegions(Op), ListItem(getAttr(Op, "sym_name"))) </table>
        requires getOpName(Op) ==K "builtin.module"
endmodule
