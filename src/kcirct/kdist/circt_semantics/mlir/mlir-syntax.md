# MLIR Syntax

```k
module MLIR-SYNTAX
imports STRING-SYNTAX
imports INT-SYNTAX
imports MAP-SYNTAX
```

## Top Level Productions  

```k
syntax TopLevel ::= List{TopLevelElement,""}
syntax TopLevelElement ::= Operation | AttributeAliasDef | TypeAliasDef
```


## Operations

```k
syntax Operation ::= OpResultList GenericOperation | GenericOperation
```

### OpResultList

```k
syntax OpResultList ::= OpResults "="
syntax OpResults ::= List{OpResult, ","}
syntax OpResult ::= ValueId | ValueId ":" Int
```

### GenericOperation

SuccessorList, DictionaryProperties, RegionList, DictionaryAttribute are optional.
```k    
syntax GenericOperation ::= 
  StringLiteral "(" ValueIdList ")" ":" FunctionType // 0000
| StringLiteral "(" ValueIdList ")" DictionaryAttribute ":" FunctionType // 0001
| StringLiteral "(" ValueIdList ")" RegionList ":" FunctionType // 0010
| StringLiteral "(" ValueIdList ")" DictionaryProperties ":" FunctionType // 0100
| StringLiteral "(" ValueIdList ")" SuccessorList ":" FunctionType // 1000
| StringLiteral "(" ValueIdList ")" RegionList DictionaryAttribute ":" FunctionType // 0011
| StringLiteral "(" ValueIdList ")" DictionaryProperties DictionaryAttribute ":" FunctionType // 0101
| StringLiteral "(" ValueIdList ")" SuccessorList DictionaryAttribute ":" FunctionType // 1001
| StringLiteral "(" ValueIdList ")" DictionaryProperties RegionList ":" FunctionType // 0110
| StringLiteral "(" ValueIdList ")" SuccessorList RegionList ":" FunctionType // 1010
| StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties ":" FunctionType // 1100
| StringLiteral "(" ValueIdList ")" DictionaryProperties RegionList DictionaryAttribute ":" FunctionType // 0111
| StringLiteral "(" ValueIdList ")" SuccessorList RegionList DictionaryAttribute ":" FunctionType // 1011
| StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties DictionaryAttribute ":" FunctionType // 1101
| StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties RegionList ":" FunctionType // 1110
| StringLiteral "(" ValueIdList ")" SuccessorList DictionaryProperties RegionList DictionaryAttribute ":" FunctionType // 1111
```

#### SuccessorList

```k
syntax SuccessorList ::= "[" Successors "]"
syntax Successors ::= List{Successor, ","}
syntax Successor ::= CaretId ":" BlockArgList
```

#### DictionaryProperties

```k
syntax DictionaryProperties ::= "<" DictionaryAttribute ">"
```

#### RegionList: Region & Block

```k
syntax RegionList ::= "(" Regions ")"
syntax Regions ::= List{Region, ","}
syntax Region ::= "{" Operations Blocks "}"
syntax Operations ::= List{Operation, ""}
syntax Blocks ::= List{Block, ""}
syntax Block ::= BlockLabel Operations
syntax BlockLabel ::= CaretId ":" | CaretId "(" ValueIdAndTypeList ")" ":"
```

#### DictionaryAttribute

```k
syntax DictionaryAttribute ::= "{" AttributeEntryList "}"
syntax AttributeEntryList ::= List{AttributeEntry, ","}
syntax AttributeEntry ::= BareId "=" AttributeValue
                        | StringLiteral "=" AttributeValue
                        | BareId
```

## AttributeAliasDef & AttributeValue

```k
syntax AttributeAliasDef ::= AttributeAlias "=" AttributeValue
syntax AttributeValue ::= AttributeAlias
```

## TypeAliasDef & Type

```k
syntax TypeAliasDef ::= TypeAlias "=" Type
syntax Type ::= TypeAlias
syntax Types ::= List{Type, ","}
syntax FunctionType ::= "(" Types ")" "->" "(" Types ")" // [prefer]
                        | Type "->" "(" Types ")"
                        | "(" Types ")" "->" Type
                        | Type "->" Type
syntax Type ::= FunctionType
```

## Tokens

```k
syntax IntegerLiteral       ::= DecimalLiteral
syntax DecimalLiteral       ::= Int
syntax StringLiteral        ::= String
syntax BareId           ::= r"[a-zA-Z_][a-zA-Z0-9_$\\.]*" [token]
syntax BareIdList       ::= List{BareId, ","}
syntax ValueId          ::= r"%[a-zA-Z0-9$\\._\\-]+(#[0-9]+)?" [token] // indeed, value-use
syntax ValueIdList      ::= List{ValueId, ","}
syntax SymbolRefId      ::= r"@[a-zA-Z0-9$\\._\\-]+" [token]
syntax SymbolRefIdList  ::= List{SymbolRefId, "::"}
syntax CaretId          ::= r"\\^[a-zA-Z0-9$\\._\\-]+" [token]
syntax TypeAlias        ::= r"![a-zA-Z_][a-zA-Z0-9_$\\.]*" [token]
syntax AttributeAlias   ::= r"#[a-zA-Z_][a-zA-Z0-9_$\\.]*" [token]
syntax BareIdAndTypeList ::= List{BareIdAndType, ","}
syntax BareIdAndType ::= BareId ":" Type
syntax ValueIdAndTypeList ::= List{ValueIdAndType, ","}
syntax ValueIdAndType ::= ValueId ":" Type
```

```k
endmodule
```
