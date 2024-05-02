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
    
endmodule

