# HW Helper

```k
requires "hw-syntax.md"
module HW-HELPER
imports HW-SYNTAX
imports LIST
imports CIRCT
```
## `!hw.modty` Helpers

### `getModuleInNames`

```k
syntax List ::= getModuleInNames(HwModty) [function]

rule getModuleInNames(!hw.modty < input Name:BareId : _:Type , L:ModulePortList >) 
    => ListItem(Name) getModuleInNames(!hw.modty < L >)

rule getModuleInNames(!hw.modty < output _:BareId : _:Type , L:ModulePortList >) 
    => getModuleInNames(!hw.modty < L >)

rule getModuleInNames(!hw.modty < .ModulePortList >) => .List
```

### `getModuleInTypes`

```k
syntax List ::= getModuleInTypes(HwModty) [function]

rule getModuleInTypes(!hw.modty < input _:BareId : T:Type , L:ModulePortList >) 
    => ListItem(T) getModuleInTypes(!hw.modty < L >)

rule getModuleInTypes(!hw.modty < output _:BareId : _:Type , L:ModulePortList >) 
    => getModuleInTypes(!hw.modty < L >)

rule getModuleInTypes(!hw.modty < .ModulePortList >) => .List
```

### `getModuleOutNames`

```k
syntax List ::= getModuleOutNames(HwModty) [function]

rule getModuleOutNames(!hw.modty < output Name:BareId : _:Type , L:ModulePortList >) 
    => ListItem(Name) getModuleOutNames(!hw.modty < L >)

rule getModuleOutNames(!hw.modty < input _:BareId : _:Type , L:ModulePortList >) 
    => getModuleOutNames(!hw.modty < L >)

rule getModuleOutNames(!hw.modty < .ModulePortList >) => .List
```

### `getModuleOutTypes`

```k
syntax List ::= getModuleOutTypes(HwModty) [function]

rule getModuleOutTypes(!hw.modty < output _:BareId : T:Type , L:ModulePortList >) 
    => ListItem(T) getModuleOutTypes(!hw.modty < L >)

rule getModuleOutTypes(!hw.modty < input _:BareId : _:Type , L:ModulePortList >) 
    => getModuleOutTypes(!hw.modty < L >)

rule getModuleOutTypes(!hw.modty < .ModulePortList >) => .List
```

### AttributeValueList -> List

```k
syntax List ::= AttrValueList2List(AttributeValueList) [function]
rule AttrValueList2List(V:AttributeValue : T:Type , AVL:AttributeValueList) => ListItem(ToBits(V, T)) AttrValueList2List(AVL)
rule AttrValueList2List(V:AttributeValue : T:Type) => ListItem(ToBits(V, T))
rule AttrValueList2List(.AttributeValueList) => .List
```

```k
endmodule
```
