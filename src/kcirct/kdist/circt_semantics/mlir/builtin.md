# Builtin Syntax

```k
module BUILTIN-SYNTAX 
    imports INT-SYNTAX
    imports STRING-SYNTAX
    imports BOOL-SYNTAX
```

## Types

```k
syntax Type ::= IntegerType
```

### IntegerType

```k
syntax IntegerType ::= SignedIntegerType | UnsignedIntegerType | SignlessIntegerType
syntax SignedIntegerType ::= r"si[1-9][0-9]*" [token]
syntax UnsignedIntegerType ::= r"ui[1-9][0-9]*" [token]
syntax SignlessIntegerType ::= r"i[1-9][0-9]*" [token]
```

## AttributeValues

### TypeAttribute

```k
syntax AttributeValue ::= Type
```

### IntegerAttribute

```k
syntax AttributeValue ::= Int
```

### StringAttribute

```k
syntax AttributeValue ::= String
```

### LocationAttribute

```k
syntax AttributeValue ::= "loc" "(" String ":" Int ":" Int ")"
```

### Attribute with Type

```k
syntax AttributeValue ::= AttributeValue ":" Type
```

### Array Attribute

```k
syntax AttributeValue ::= "[" AttributeValueList "]"
syntax AttributeValueList ::= List{AttributeValue, ","}
```

### Dense Array Attribute

```k
syntax AttributeValue ::= "array" "<" Type ":" AttributeValueList ">"
```

### Bool Attribute

```k
syntax AttributeValue ::= Bool
```

## Tokens

```k
syntax SizeX ::= r"[1-9][0-9]*x" [token]
```

```k
endmodule
```



# Builtin

```k
module BUILTIN
    imports BUILTIN-SYNTAX
    imports STRING-COMMON
    imports INT
```

## IntegerType Helpers

```k
syntax Int ::= getWidth (IntegerType) [function]
rule getWidth (T:SignedIntegerType) => String2Int(substrString(IntegerType2String(T), 2, lengthString(IntegerType2String(T))))
rule getWidth (T:UnsignedIntegerType) => String2Int(substrString(IntegerType2String(T), 2, lengthString(IntegerType2String(T))))
rule getWidth (T:SignlessIntegerType) => String2Int(substrString(IntegerType2String(T), 1, lengthString(IntegerType2String(T))))
```

```k
syntax String ::= SignedIntegerType2String (SignedIntegerType) [function, total,hook(STRING.token2string)]
syntax String ::= UnsignedType2String (UnsignedIntegerType) [function, total,hook(STRING.token2string)]
syntax String ::= SignlessIntegerType2String (SignlessIntegerType) [function, total,hook(STRING.token2string)]
syntax String ::= IntegerType2String (IntegerType) [function, total]
rule IntegerType2String(SI:SignedIntegerType) => SignedIntegerType2String(SI)
rule IntegerType2String(II:UnsignedIntegerType) => UnsignedType2String(II)
rule IntegerType2String(LI:SignlessIntegerType) => SignlessIntegerType2String(LI)
```

### SizeX Helpers

```k
syntax Int ::= SizeX2Int (SizeX) [function]
rule SizeX2Int(S:SizeX) => String2Int(substrString(SizeX2String(S), 0, lengthString(SizeX2String(S)) -Int 1))
```

```k
syntax String ::= SizeX2String (SizeX) [function, total,hook(STRING.token2string)]
```

```k
endmodule
```
