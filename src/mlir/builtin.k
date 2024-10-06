requires "./mlir-syntax.k"

module BUILTIN-SYNTAX 
    imports MLIR-SYNTAX
    imports BOOL
    // imports LIST

    // ------------------------- Attributes ------------------------- //
    // AffineMapAttr
    syntax BuiltinAttribute ::= "affine_map" "<" AffineMap ">" 
    // ArrayAttr
    syntax BuiltinAttribute ::= ArrayAttr
    
    syntax ArrayAttr ::= "[" "]" [prefer]
                       | "[" AttributeValueList "]"
    
    syntax AttributeValueList ::= List{AttributeValue, ","}
    
    // DenseArrayAttr
    syntax BuiltinArray ::= "array" "<" IntegerType ">"
                          | "array" "<" SizeX IntegerType ">" // diff from official
                          | "array" "<" FloatType ">"
                          | "array" "<" IntegerType ":" TensorLiteral ">"
                          | "array" "<" FloatType ":" TensorLiteral ">"
                          | "array" "<" IntegerType ":" ">"
                          | "array" "<" FloatType ":" ">"
    syntax SizeX ::= r"[1-9][0-9]*x" [token]
    
    syntax Type ::= BuiltinArray
    
    // DenseIntOrFPElementsAttr
    syntax TensorLiteralElement ::= IntegerLiteral | FloatLiteral | BoolLiteral
    syntax TensorLiteral ::= TensorLiteralElement | TensorLiteralElement "," TensorLiteral
    syntax BuiltinAttribute ::= "dense" "<" TensorLiteral ">" ":" TensorType [prefer]
                              | "dense" "<" TensorLiteral ">" ":" VectorType [prefer]
                              | "dense" "<" ">" ":" TensorType 
                              | "dense" "<" ">" ":" VectorType
    // DenseResourceElementsAttr
    syntax BuiltinAttribute ::= "dense_resource" "<" ResourceHandle ">" ":" ShapedType
    // DenseStringElementsAttr
    syntax BuiltinAttribute ::= "dense" "<" AttributeValue ">" ":" TensorType
                              | "dense" "<" AttributeValue ">" ":" VectorType
    // DictionaryAttr
    syntax BuiltinAttribute ::= DictionaryAttribute
    // FloatAttr
    syntax BuiltinAttribute ::= FloatLiteral ":" FloatType
                              | FloatLiteral
                              | HexaDecimalLiteral ":" FloatType
    // IntegerAttr
    syntax BuiltinAttribute ::= IntegerLiteral ":" IndexType
                              | IntegerLiteral ":" IntegerType
                              | IntegerLiteral
                              | BoolLiteral
    // IntegerSetAttr
    syntax BuiltinAttribute ::= "affine_set" "<" IntegerSet ">"
    // OpaqueAttr
    syntax BuiltinAttribute ::= BareId "<" AttrData ">" 
    // SparseElementsAttr
    syntax BuiltinAttribute ::= "sparse" "<" AttributeValue "," AttributeValue ">" ":" TensorType
                              | "sparse" "<" AttributeValue "," AttributeValue ">" ":" VectorType
    // StringAttr
    syntax BuiltinAttribute ::= StringAttr
    syntax StringAttr ::= StringLiteral ":" Type
                        | StringLiteral
    // SymbolRefAttr
    syntax BuiltinAttribute ::= SymbolRefIdList
                            //   | SymbolRefId

    // TypeAttr
    syntax BuiltinAttribute ::= Type
    // UnitAttr
    syntax BuiltinAttribute ::= "unit"
    // StridedLayoutAttr
    syntax BuiltinAttribute ::= "strided" "<" "[" StrideList "]" "," "offset" ":" Dimension ">"
                              | "strided" "<" "[" StrideList "]" ">"
                              | "strided" "<" "[" "]" "," "offset" ":" Dimension ">"
                              | "strided" "<" "[" "]" ">"
    
    syntax StrideList ::= Dimension | Dimension "," StrideList
    syntax Dimension ::= DecimalLiteral | "?"

    // ------------------------- Location ------------------------- //
    // CallSiteLoc
    syntax Location ::= "callsite" "(" Location "at" Location ")"
    // FileLineColLoc
    syntax Location ::= StringLiteral ":" IntegerLiteral ":" IntegerLiteral
    // FusedLoc
    syntax Location ::= "fused" "[" LocationList "]"
                      | "fused" "<" AttributeValue ">" "[" LocationList "]"
    syntax LocationList ::= Location
                          | Location "," LocationList
    // NameLoc
    // name-location ::= string-literal (`(` location `)`)?
    syntax Location ::= StringLiteral "(" Location ")"
                      | StringLiteral
    // OpaqueLoc
    syntax Location ::= OpaqueLocation
    // UnknownLoc
    syntax Location ::= "?" //[avoid]

    syntax BuiltinAttribute ::= TrailingLocation

    // ------------------------- Operations ------------------------- //
    // Each Operation binds to several traits, interfaces, and attributes.
    // builtin.module
    // 官方文档给的很不严格，需要根据实际代码确认该syntax的正确性。
    // builtin的dialect-namespace似乎可以为空。
    // graph region with one region with one block.
    syntax CustomOperation ::= "module" "{" "}"
                             | "module" "{" OperationList "}"
                             | "module" "attributes" DictionaryAttribute "{" "}"
                             | "module" StringAttr "{" "}"
                             | "module" "attributes" DictionaryAttribute "{" OperationList "}"
                             | "module" StringAttr "{" OperationList "}"
                             | "module" StringAttr "attributes" DictionaryAttribute "{" "}"
                             | "module" StringAttr "attributes" DictionaryAttribute "{" OperationList "}"
    // builtin.unrealized_conversion_cast
    syntax CustomOperation ::= "unrealized_conversion_cast" "to" Types
                             | "unrealized_conversion_cast" "to" Types DictionaryAttribute
                             | "unrealized_conversion_cast" ValueIdList ":" Types "to" Types
                             | "unrealized_conversion_cast" ValueIdList ":" Types "to" Types DictionaryAttribute

    // ------------------------- Types -------------------------
    // FloatType
    syntax FloatType ::= "bf16" | "f16" | "f32" | "f64" | "f80" | "f128" 
    syntax FloatType ::= "f8E4M3FN" | "f8E4M3FNUZ" | "f8E5M2" | "f8E5M2FNUZ" 
    syntax BuiltinType ::= FloatType
    // ComplexType
    syntax BuiltinType ::= "complex" "<" Type ">"
    // FunctionType
    syntax BuiltinType ::= FunctionType // TypeListParens "->" TypeListParens
    // IndexType
    syntax IndexType ::= "index" [token]
    syntax BuiltinType ::= IndexType
    // IntegerType
    syntax SignedIntegerType ::= r"si[1-9][0-9]*" [token,prefer,prec(3)]
    syntax UnsignedIntegerType ::= r"ui[1-9][0-9]*" [token,prefer,prec(3)]
    syntax SignlessIntegerType ::= r"i[1-9][0-9]*" [token,prefer,prec(3)]
    syntax IntegerType ::= SignedIntegerType | UnsignedIntegerType | SignlessIntegerType //| "i32"
    syntax BuiltinType ::= IntegerType
    // MemRefType & UnrankedMemRefType
    // memref-type ::= `memref` `<` dimension-list-ranked type (`,` layout-specification)? (`,` memory-space)? `>`
    // layout-specification ::= attribute-value
    // memory-space ::= attribute-value
    syntax BuiltinType ::= "memref" "<" DimensionList Type ">" 
                         | "memref" "<" DimensionList Type "," AttributeValue ">"
                         | "memref" "<" DimensionList Type "," AttributeValue "," AttributeValue ">"
                         | "memref" "<" "*x" Type ">"
                         | "memref" "<" "*x" Type "," AttributeValue ">"
    
    syntax DimensionElement ::= Dimension "x" [token] 
                              | r"[0-9]+x" [token,prefer] 
                              | "?x" [token] // TODO: kind of weird
    syntax DimensionList ::= DimensionElement | DimensionElement DimensionList 
    // NoneType
    syntax BuiltinType ::= NoneType
    // OpaqueType
    syntax BuiltinType ::= "opaque" "<" Type ">"
    // RankedTensorType & UnrankedTensorType
    syntax BuiltinType ::= TensorType
    syntax TensorType ::= "tensor" "<" Type ">"
                        | "tensor" "<" Type "," AttributeValue ">"
                        | "tensor" "<" DimensionList Type ">"
                        | "tensor" "<" DimensionList Type "," AttributeValue ">"
                        | "tensor" "<" "*" "x" Type ">"
    // TupleType
    syntax BuiltinType ::= "tuple" "<" Types ">"
                         | "tuple" "<" ">"

    // VectorType
    syntax BuiltinType ::= VectorType
    syntax VectorType ::= "vector" "<" Type ">"
                        | "vector" "<" VectorDimList VectorElementType ">"
    syntax VectorElementType ::= FloatType | IntegerType | IndexType
    syntax StaticDimElement ::= DecimalLiteral "x" [token] | r"[0-9]+x" [token]
    syntax StaticDimList ::= StaticDimElement | StaticDimElement StaticDimList
    syntax VectorDimList ::= StaticDimList 
                           | "[" StaticDimList DecimalLiteral "]x"
                           | "[" DecimalLiteral "]x"
                           | StaticDimList "[" StaticDimList DecimalLiteral "]x"
                           | StaticDimList "[" DecimalLiteral "]x"

    // syntax VectorDimList ::= StaticDimList "x" | StaticDimList "x" "[" StaticDimList "]" "x"
    // syntax StaticDimList ::= DecimalLiteral | DecimalLiteral "x" StaticDimList //[avoid]


    // ------------------------- Not Mentioned ------------------------- //
    // syntax BoolLiteral ::= "true" | "false"
    syntax BoolLiteral ::= Bool
    // NoneType is a unit type, i.e. a type with exactly one possible value, 
    // where its value does not have a defined dynamic representation.
    syntax NoneType 
    syntax AttrData ::= String
    syntax ResourceHandle ::= BareId
    syntax ShapedType ::= TensorType 
                        | VectorType

    syntax DialectTypeContents ::= IntegerMultiply 
                                 | IntegerType
                                 | ":"
    syntax IntegerMultiply ::= r"[0-9]+x" [token]

    // ------------------------- Non-deterministic Opaque Syntax ------------------------- //
    // The following syntax are non-deterministic, 
    // which means users should also import the corresponding dialects to get the correct syntax.
    syntax AffineMap // imports AFFINE-DIALECT-SYNTAX
    syntax IntegerSet // imports AFFINE-DIALECT-SYNTAX
    syntax OpaqueLocation // customized by dialects

    // Maybe we should split the syntax and semantics into smaller pieces for better maintenance and reuse.
endmodule


module BUILTIN-HELPER
    imports BUILTIN-SYNTAX
    imports MLIR-CONF

    syntax Int ::= getIntegerTypeSize (IntegerType) [function]
    rule getIntegerTypeSize (T:SignedIntegerType) => String2Int(substrString(IntegerType2String(T), 2, lengthString(IntegerType2String(T))))
    rule getIntegerTypeSize (T:UnsignedIntegerType) => String2Int(substrString(IntegerType2String(T), 2, lengthString(IntegerType2String(T))))
    rule getIntegerTypeSize (T:SignlessIntegerType) => String2Int(substrString(IntegerType2String(T), 1, lengthString(IntegerType2String(T))))
    syntax String ::= "SignedIntegerType2String" "(" SignedIntegerType ")" [function, total,hook(STRING.token2string)]
    syntax String ::= "UnsignedType2String" "(" UnsignedIntegerType ")" [function, total,hook(STRING.token2string)]
    syntax String ::= "SignlessIntegerType2String" "(" SignlessIntegerType ")" [function, total,hook(STRING.token2string)]
    syntax String ::= "IntegerType2String" "(" IntegerType ")" [function, total]
    rule IntegerType2String(SI:SignedIntegerType) => SignedIntegerType2String(SI)
    rule IntegerType2String(II:UnsignedIntegerType) => UnsignedType2String(II)
    rule IntegerType2String(LI:SignlessIntegerType) => SignlessIntegerType2String(LI)

    syntax String ::= "IntType2String" "(" IntegerType ")" [function]
    rule IntType2String(SI:SignedIntegerType) => SignedIntegerType2String(SI)
    rule IntType2String(II:UnsignedIntegerType) => UnsignedType2String(II)
    rule IntType2String(LI:SignlessIntegerType) => SignlessIntegerType2String(LI)

    syntax Int ::= getWidth(Type) [function]
    rule getWidth(T:IntegerType) => String2Int(substrString(IntType2String(T), 1, lengthString(IntType2String(T))))
endmodule

module BUILTIN
    imports BUILTIN-SYNTAX
    imports BUILTIN-HELPER
    // imports MLIR

    // ------------------------- Operations ------------------------- //
    // builtin.module
    // rule <phase> #canonicalized => #preprocess </phase>
    //     <prog> Op:Operation P:TopLevel => P </prog>
    //     <table> M:Map => M GetSymbolTable(getRegions(Op), ListItem(getAttr(Op, "sym_name"))) </table>
    //     requires getOpName(Op) ==K "builtin.module"
endmodule
