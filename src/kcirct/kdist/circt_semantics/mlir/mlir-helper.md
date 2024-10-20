# MLIR Helper Syntax and Semantics

```k
requires "mlir-syntax.md"
```

## Helper Syntax

```k
module MLIR-HELPER-SYNTAX
imports MLIR-SYNTAX
imports MAP
imports LIST
```

### Standardized Operation

- StdOpL: Standardized Operation with Left Values
- StdOp: 
    - Standardized Operation only has two formats. with or without region.
    - It integrates `DictionaryProperties` and `DictionaryAttribute` into the one accessible `Map`, assuming no duplicate keys.
- List: List of Strings

```k
syntax StdOpL ::= List "=" StdOp | StdOp
syntax StdOp ::= String "(" List ")" "{" Map "}" ":" StdFT
               | String "(" List ")" "{" Map "}" SuccessorList "(" StdRegions ")" ":" StdFT
syntax StdRegions ::= List{StdRegion, ","}
syntax StdRegion ::= "{" StdBlocks "}"
syntax StdBlocks ::= List{StdBlock, ""}
syntax StdBlock ::= StdBlockLabel StdOps
syntax StdOps ::= List{StdOpL, ""}
```

```k
endmodule
```

## Helper Semantics

```k
module MLIR-HELPER
imports MLIR-HELPER-SYNTAX
imports INT
imports STRING
imports K-EQUAL
```

### Standardize Operation

```k
syntax StdOpL ::= stdizeOp(Operation) [function]
rule stdizeOp(ORs:OpResults = Op:GenericOperation) => stdizeORs(ORs) = stdizeGenericOp(Op)
rule stdizeOp(Op:GenericOperation) => stdizeGenericOp(Op)
```

### Standardize OpResults

```k
syntax List ::= stdizeORs ( OpResults ) [function]
rule stdizeORs( VID:ValueId, Rs:OpResults ) => ListItem(ValueId2String(VID)) stdizeORs(Rs)
rule stdizeORs( VID:ValueId : I, Rs:OpResults ) 
    => stdizeORs(VID : I -Int 1, .OpResults) 
       ListItem(ValueId2String(VID) +String "#" +String Int2String(I -Int 1))
       stdizeORs(Rs)
       requires I >Int 0
rule stdizeORs( _:ValueId : 0, .OpResults ) => .List
rule stdizeORs( .OpResults ) => .List
```

### Standardize Generic Operation

```k
syntax StdOp ::= stdizeGenericOp(GenericOperation) [function]
// 0000
rule stdizeGenericOp(Op:String (VL:ValueIdList) : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {.Map} : stdize(FT)
// 0001
rule stdizeGenericOp(Op:String (VL:ValueIdList) {AL:AttributeEntryList} : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {attrEntryList2Map(AL)} : stdize(FT)
// 0010
rule stdizeGenericOp(Op:String (VL:ValueIdList) (Rs:Regions) : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {.Map} [.Successors] (stdize(Rs)) : stdize(FT)
// 0100
rule stdizeGenericOp(Op:String (VL:ValueIdList) <{AL:AttributeEntryList}> : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {attrEntryList2Map(AL)} : stdize(FT)
// 1000
rule stdizeGenericOp(Op:String (VL:ValueIdList) [SL:Successors] : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {.Map} [SL] (.StdRegions) : stdize(FT)
// 0011
rule stdizeGenericOp(Op:String (VL:ValueIdList) (Rs:Regions) {AL:AttributeEntryList} : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {attrEntryList2Map(AL)} [.Successors] (stdize(Rs)) : stdize(FT)
// 0101
rule stdizeGenericOp(Op:String (VL:ValueIdList) <{AL:AttributeEntryList}> {AL1:AttributeEntryList} : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {updateMap(attrEntryList2Map(AL), attrEntryList2Map(AL1))} : stdize(FT)
// 1001
rule stdizeGenericOp(Op:String (VL:ValueIdList) [SL:Successors] {AL:AttributeEntryList} : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {attrEntryList2Map(AL)} [SL] (.StdRegions) : stdize(FT)
// 0110
rule stdizeGenericOp(Op:String (VL:ValueIdList) <{AL:AttributeEntryList}> (Rs:Regions) : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {attrEntryList2Map(AL)} [.Successors] (stdize(Rs)) : stdize(FT)
// 1010
rule stdizeGenericOp(Op:String (VL:ValueIdList) [SL:Successors] (Rs:Regions) : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {.Map} [SL] (stdize(Rs)) : stdize(FT)
// 1100
rule stdizeGenericOp(Op:String (VL:ValueIdList) [SL:Successors] <{AL1:AttributeEntryList}> : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {attrEntryList2Map(AL1)} [SL] (.StdRegions) : stdize(FT)
// 0111
rule stdizeGenericOp(Op:String (VL:ValueIdList) <{AL:AttributeEntryList}> (Rs:Regions) {AL1:AttributeEntryList} : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {updateMap(attrEntryList2Map(AL), attrEntryList2Map(AL1))} [.Successors] (stdize(Rs)) : stdize(FT)
// 1011
rule stdizeGenericOp(Op:String (VL:ValueIdList) [SL:Successors] (Rs:Regions) {AL:AttributeEntryList} : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {attrEntryList2Map(AL)} [SL] (stdize(Rs)) : stdize(FT)
// 1101
rule stdizeGenericOp(Op:String (VL:ValueIdList) [SL:Successors] <{AL1:AttributeEntryList}> {AL2:AttributeEntryList} : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {updateMap(attrEntryList2Map(AL1), attrEntryList2Map(AL2))} [SL] (.StdRegions) : stdize(FT)
// 1110
rule stdizeGenericOp(Op:String (VL:ValueIdList) [SL:Successors] <{AL1:AttributeEntryList}> (Rs:Regions) : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {attrEntryList2Map(AL1)} [SL] (stdize(Rs)) : stdize(FT)
// 1111
rule stdizeGenericOp(Op:String (VL:ValueIdList) [SL:Successors] <{AL1:AttributeEntryList}> (Rs:Regions) {AL2:AttributeEntryList} : FT:FunctionType) 
=> Op (stdizeVIDs(VL)) {updateMap(attrEntryList2Map(AL1), attrEntryList2Map(AL2))} [SL] (stdize(Rs)) : stdize(FT)
```

### Standardize ValueIdList

```k
syntax List ::= stdizeVIDs(ValueIdList) [function]
rule stdizeVIDs(V, VTs:ValueIdList) => ListItem(ValueId2String(V)) stdizeVIDs(VTs)
rule stdizeVIDs(.ValueIdList) => .List
```

### Standardize FunctionType

```k
syntax StdFT  ::= stdize(FunctionType) [function]
rule stdize((T1:Types) -> (T2:Types)) => (T1) -> (T2)
rule stdize(T1:Type    -> (T2:Types)) => (T1) -> (T2)
rule stdize((T1:Types) -> T2:Type)    => (T1) -> (T2)
rule stdize(T1:Type    -> T2:Type)    => (T1) -> (T2)
```

### Standardize Regions

```k
syntax StdRegions ::= stdize(Regions) [function]
rule stdize(.Regions) => .StdRegions
rule stdize({.Operations Bs:Blocks}, Rs:Regions) => {stdize(Bs)}, stdize(Rs)
rule stdize({ OL:Operations Bs:Blocks }, Rs:Regions) 
=> {^kgenbb0 (.ValueIdAndTypeList) : stdizeOps(OL) stdize(Bs)}, stdize(Rs)
requires OL =/=K .Operations
```

### Standardize BlockList

```k
syntax StdBlocks ::= stdize(Blocks) [function]
rule stdize(.Blocks) => .StdBlocks
rule stdize(Bid:BlockLabel OL:Operations Bs:Blocks) 
=> stdize(Bid) stdizeOps(OL) stdize(Bs)
```

### Standardize BlockLabel

```k
syntax StdBlockLabel ::= stdize(BlockLabel) [function]
rule stdize(Bid:CaretId : ) => Bid (.ValueIdAndTypeList) :
rule stdize(Bid:StdBlockLabel) => Bid
```

### Standardize Operations

```k
syntax StdOps ::= stdizeOps(Operations) [function]
rule stdizeOps(.Operations) => .StdOps
rule stdizeOps(Op:Operation Ops:Operations) => stdizeOp(Op) stdizeOps(Ops)
```

### attrEntryList2Map

```k
syntax Map ::= attrEntryList2Map(AttributeEntryList) [function]
rule attrEntryList2Map(.AttributeEntryList) => .Map
rule attrEntryList2Map(N:BareId = V:AttributeValue, AEs:AttributeEntryList) 
=> attrEntryList2Map(AEs) [ BareId2String(N) <- V ]
rule attrEntryList2Map(N:String = V:AttributeValue, AEs:AttributeEntryList) 
=> attrEntryList2Map(AEs) [ N <- V ]
rule attrEntryList2Map(N:BareId, AEs:AttributeEntryList) 
=> attrEntryList2Map(AEs) [ BareId2String(N) <- "" ]
```

### ValueId <-> String

```k
syntax String  ::= ValueId2String(ValueId) [function, total, hook(STRING.token2string)]
syntax ValueId ::= String2ValueId(String) [function, total, hook(STRING.string2token)]
```

### BareId <-> String

```k
syntax String ::= BareId2String(BareId) [function, total, hook(STRING.token2string)]
syntax BareId ::= String2BareId(String) [function, total, hook(STRING.string2token)]
```

### Get Abosolute Symbol Name

```k
syntax String ::= AbsSymbolName(List) [function]
rule AbsSymbolName(ListItem(S:String) L:List) => S +String "/" +String AbsSymbolName(L)
rule AbsSymbolName(ListItem(S:String)) => S
rule AbsSymbolName(.List) => ""
```

### Connect AbsPath and StringList

```k
syntax List ::= Abs(String, List) [function]
rule Abs(S, ListItem(S1:String) L:List) => ListItem(S +String "/" +String S1) Abs(S, L)
rule Abs(_, .List) => .List
``` 

### Cast ValueIdAndTypes to StringList

```k
syntax List ::= StringList(ValueIdAndTypeList) [function]
rule StringList(V : _, VTs:ValueIdAndTypeList) => ListItem(ValueId2String(V)) StringList(VTs)
rule StringList(.ValueIdAndTypeList) => .List
```

### Cast ValueIdList to StringList

```k
syntax List ::= StringList(ValueIdList) [function]
rule StringList(V, VTs:ValueIdList) => ListItem(ValueId2String(V)) StringList(VTs)
rule StringList(.ValueIdList) => .List
```

### SymbolRefId <-> String

```k
syntax String ::= "SymbolRefId2StringHelper" "(" SymbolRefId ")" [function, total,hook(STRING.token2string)]
syntax String ::= "SymbolRefId2String" "(" SymbolRefId ")" [function, total]
rule SymbolRefId2String(ID) => substrString ( SymbolRefId2StringHelper(ID) , 1 , lengthString(SymbolRefId2StringHelper(ID)) )
```

### Std

```k
endmodule
```