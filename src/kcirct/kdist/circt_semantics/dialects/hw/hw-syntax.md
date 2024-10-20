HW Dialect extends the MLIR syntaxs for its types and attribute values.

```k
requires "../../mlir/mlir-syntax.md"
module HW-SYNTAX
  imports MLIR-SYNTAX
```

# Types

```k
syntax Type ::= HwArrayType | HwEnumType | HwInOutType | HwModty | HwStructType
```

## HwArrayType

```k
syntax HwArrayType ::= "!hw.array" "<" SizeX Type ">"
```

## HwEnumType

```k
syntax HwEnumType ::= "!hw.enum" "<" HwEnumItems ">"
syntax HwEnumItems ::= List{HwEnumItem, ","}
syntax HwEnumItem ::= BareId
```

## HwInOutType

```k
syntax HwInOutType ::= "!hw.inout" "<" Type ">"
```

## HwModty

```k
syntax HwModty ::= "!hw.modty" "<" ModulePortList ">"
syntax ModulePortList ::= List{ModulePort, ","}
syntax ModulePort ::= "input" BareIdAndType
                    | "output" BareIdAndType
```

## HwStructType

```k
syntax HwStructType ::= "!hw.struct" "<" BareIdAndTypeList ">"
```

# Attributes

```k
syntax AttributeValue ::= HwEnumField
```

## HwEnumField

```k
syntax HwEnumField ::= "#hw.enum.field" "<" HwEnumItem "," HwEnumType ">"
```

```k
endmodule
```