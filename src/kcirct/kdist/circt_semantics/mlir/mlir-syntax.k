module MLIR-SYNTAX
    imports STRING
    imports INT
    imports MAP
    
    // Common Syntax
    syntax IntegerLiteral       ::= DecimalLiteral | HexaDecimalLiteral
    syntax DecimalLiteral       ::= Int
    syntax HexaDecimalLiteral   ::= r"0x[0-9a-fA-F]+" [prefer,token,prec(2)]
    syntax FloatLiteral         ::= r"[\\+\\-]?[0-9]+\\.[0-9]*([eE][\\+\\-]?[0-9]+)?" [token,prec(1)]
    syntax StringLiteral        ::= String

    // Identifiers and Keywords
    syntax BareId           ::= r"[a-zA-Z_][a-zA-Z0-9_$\\.]*" [token]
    syntax BareIdList       ::= List{BareId, ","}
    syntax ValueId          ::= r"%[a-zA-Z0-9$\\._\\-]+(#[0-9]+)?" [token] // indeed, value-use
    syntax ValueIdList      ::= List{ValueId, ","}
    syntax SymbolRefId      ::= r"@[a-zA-Z0-9$\\._\\-]+" [token]
    syntax SymbolRefIdList  ::= List{SymbolRefId, "::"}
    syntax CaretId          ::= r"\\^[a-zA-Z0-9$\\._\\-]+" [token]
    syntax TypeAlias        ::= r"![a-zA-Z_][a-zA-Z0-9_$\\.]*" [token]
    syntax AttributeAlias   ::= r"#[a-zA-Z_][a-zA-Z0-9_$\\.]*" [token]


    // Top Level Productions
    syntax TopLevel ::= List{TopLevelElement,""}
    syntax TopLevelElement ::= Operation | AttributeAliasDef | TypeAliasDef
    
    // # Operations
    syntax Operation ::= OpResultList GenericOperation TrailingLocation // 11
                       | OpResultList CustomOperation TrailingLocation // 11
                       | GenericOperation TrailingLocation // 01
                       | CustomOperation TrailingLocation // 01
                       | OpResultList GenericOperation // 10
                       | OpResultList CustomOperation // 10
                       | GenericOperation // 00
                       | CustomOperation // 00
    
    syntax GenericOperation ::= 
          StringLiteral "(" ValueIdList ")" ":" FunctionType
        | StringLiteral "(" ValueIdList ")" DictionaryAttribute ":" FunctionType
        | StringLiteral "(" ValueIdList ")" RegionList ":" FunctionType
        | StringLiteral "(" ValueIdList ")" SuccessorList ":" FunctionType
        | StringLiteral "(" ValueIdList ")" RegionList DictionaryAttribute ":" FunctionType
        | StringLiteral "(" ValueIdList ")" SuccessorList DictionaryAttribute ":" FunctionType                        
        | StringLiteral "(" ValueIdList ")" SuccessorList RegionList ":" FunctionType                            
        | StringLiteral "(" ValueIdList ")" SuccessorList RegionList DictionaryAttribute ":" FunctionType
    
    // with DictionaryProperties
    syntax GenericOperation ::= 
          StringLiteral "(" ValueIdList ")" DictionaryProperties ":" FunctionType
        | StringLiteral "(" ValueIdList ")" DictionaryProperties DictionaryAttribute ":" FunctionType
        | StringLiteral "(" ValueIdList ")" DictionaryProperties RegionList ":" FunctionType
        | StringLiteral "(" ValueIdList ")" DictionaryProperties RegionList DictionaryAttribute ":" FunctionType
        | StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties ":" FunctionType
        | StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties DictionaryAttribute ":" FunctionType                        
        | StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties RegionList ":" FunctionType                            
        | StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties RegionList DictionaryAttribute ":" FunctionType

    
    // syntax Operation ::= StdOperation
    //                    | OpResultList StdOperation

    syntax GenericOperation ::= 
          StringLiteral "(" ValueIdList ")" AttrMap ":" FunctionType
        | StringLiteral "(" ValueIdList ")" RegionList AttrMap ":" FunctionType
        | StringLiteral "(" ValueIdList ")" SuccessorList AttrMap ":" FunctionType
        | StringLiteral "(" ValueIdList ")" SuccessorList RegionList AttrMap ":" FunctionType
    
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
                                //  | "{" Map "}"

    syntax AttrMap ::= "{" Map "}"
    syntax TrailingLocation ::= "loc" "(" Location ")"
    syntax Location //::= "?"

    // Blocks
    syntax Block ::= BlockLabel OperationList
    syntax OperationList ::= List{Operation, ""} // [prefer] 
    // the prefer may not be used when there is configuration
    
    syntax BlockLabel ::= CaretId ":" 
                        | CaretId "(" ValueIdAndTypeList ")" ":"
                        
    syntax ValueIdAndType ::= ValueId ":" Type
    syntax ValueIdAndTypeList ::= List{ValueIdAndType, ","}
    syntax BlockArgList ::= "(" ValueIdAndTypeList ")"

    // Regions 
    syntax Region ::= "{" OperationList BlockList "}"
    syntax BlockList ::= List{Block, ""}


    // Type System 
    syntax Type ::= TypeAlias | DialectType | BuiltinType
    syntax Types ::= List{Type, ","}
    syntax TypeListParens ::= "(" Types ")" 
    syntax FunctionType ::= TypeListParens "->" TypeListParens [prefer]
                          | Type "->" TypeListParens
                          | TypeListParens "->" Type
                          | Type "->" Type

    // Type Aliases 
    syntax TypeAliasDef ::= TypeAlias "=" Type

    // Dialect Types 
    syntax DialectType

    // Builtin Types
    syntax BuiltinType

    // Attributes 
    syntax AttributeEntryList ::= List{AttributeEntry, ","}

    syntax AttributeEntry ::= BareId "=" AttributeValue
                            | StringLiteral "=" AttributeValue
                            | BareId

    syntax AttributeValue ::= AttributeAlias
                            | DialectAttribute
                            | BuiltinAttribute
                            | StringLiteral

    // Attribute Value Aliases 
    syntax AttributeAliasDef ::= AttributeAlias "=" AttributeValue

    // Dialect Attribute Values
    syntax DialectAttribute

    // Builtin Attribute Values
    syntax BuiltinAttribute
    
    // # More Syntax Helpers
    syntax BareIdAndType ::= BareId ":" Type
    syntax BareIdAndTypeList ::= List{BareIdAndType, ","}

    syntax DialectAttribute ::= DialectType

    syntax AttributeValue ::= AttributeValueHelper
    syntax AttributeValueHelper ::= "#undefined"

    syntax None ::= "#None" [token]
endmodule