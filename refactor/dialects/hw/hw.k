requires "../../circt/common.k"

module HW-SYNTAX
    imports COMMON-SYNTAX
    // # AttributeValue
    // ## EnumFieldAttr
    syntax DialectAttribute ::= "hw.enum" "(" BareIdList "," HwEnumType ")"
    // ## OutputFileAttr
    // ## ParamDeclAttr
    // ## ParamDeclRefAttr
    // ## ParamExprAttr
    // ## ParamVerbatimAttr
    // ## InnerRefAttr
    syntax DialectAttribute ::= "#hw" "<" "innerSym" SymbolRefId ">"

    // # Type
    syntax DialectType ::= HwEnumType
    // ## !hw.types_cope
    // ## !hw.typedecl
    // ## ArrayType
    syntax DialectType ::= "!hw.array" "<" ArraySizePrefix Type ">"
    // ## EnumType
    syntax HwEnumType ::= "!hw.enum" "<" BareIdList ">"
                         | "enum" "<" BareIdList ">"
    // ## InOutType
    // ## IntType
    // ## ModuleType
    syntax DialectType ::= "!hw.modty" "<" ModulePortList ">"
    syntax ModulePortList ::= List{ModulePort, ","}
    syntax ModulePort ::= "input" BareIdAndType
                        | "output" BareIdAndType
    // ## StructType
    syntax DialectType ::= "!hw.struct" "<" BareIdAndTypeList ">"
    // ## TypeAliasType
    // ## UnionType
    syntax DialectType ::= "!hw.union" "<" BareIdAndTypeList ">"
    // ## UnpackedArrayType
endmodule

module HW
    imports HW-SYNTAX
    imports COMMON

    // # Types
    // ## ArrayType
    syntax StdValues ::= HWArray2Std ( AttributeValue , Type ) [function]
    rule HWArray2Std([.AttributeValueList]:ArrayAttr, _:Type) => .StdValues
    rule HWArray2Std([V:AttributeValue, Vs:AttributeValueList]:ArrayAttr, T:Type) => AttributeValue2Bits(V, T) : T , HWArray2Std([Vs], T)
    // ## !hw.modty
    rule <k> !hw.modty<input ID : T, Ps:ModulePortList> => !hw.modty<Ps> ... </k>
         <in-ports> L:List => L ListItem(ID:T) </in-ports>
         <clock> 0 </clock>
    rule <k> !hw.modty<output ID : T, Ps:ModulePortList> => !hw.modty<Ps> ... </k>
         <out-ports> L:List => L ListItem(ID:T) </out-ports>
         <clock> 0 </clock>
    rule <k> !hw.modty< .ModulePortList > => #KHWSetupIns ... </k>
         <clock> 0 </clock>
    rule <k> !hw.modty<_:ModulePortList> => .K </k> 
         <clock> I:Int </clock>
        requires I >Int 0
        [owise]
    // -- I can add a rule to check the consistency between the module type and the module entry block.
    syntax KmdCIRCT ::= "#KHWSetupIns" | "#KHWSetupInsAUX"
    rule <k> #KHWSetupIns ~> BL:BlockLabel OL:OperationList => #KHWSetupInsAUX ~> BL ~> BL OL ... </k>
    rule <k> #KHWSetupInsAUX ~> _:CaretId ( VTs:ValueIdAndTypeList ) : => .K ... </k>
         <in-vars> _ => VTs </in-vars>

    // # Attributes
    // ## InnerRefAttr
    syntax KmdCIRCT ::= "#KHWSetupSymRef" String Operation
    rule <k> #KHWSetupSymRef S:String Op:Operation => .K ... </k>
         <hw-inner-sym> M => M[S <- Op]</hw-inner-sym>
    syntax String ::= getInnerSymString(DialectAttribute) [function]
    rule getInnerSymString((#hw < innerSym SymId:SymbolRefId >):DialectAttribute) 
        => SymbolRefId2String(SymId)

    // # Operations
    // - Operation Definitions - Structure
    // ## hw.generator.schema
    // ## hw.module.extern
    // ## hw.module.generated
    // ## hw.module
    rule <phase> #stimulating </phase>
         <k> "hw.module" (.ValueIdList) ({ .OperationList  B:Block .BlockList}, .Regions) {Attr:Map} : _ 
             => getAttr(Attr, "module_type") ~> B 
         ... </k>
    // ## hw.hierpath
    // ## hw.instance_choice
    // ## hw.instance
    rule <k> "hw.instance" ( Is:ValueIdList ) { Attr:Map } : T 
         => #if "inner_sym" in_keys(Attr) 
            #then #KHWSetupSymRef getInnerSymString({Attr["inner_sym"]}:>DialectAttribute) "hw.instance" ( Is ) { Attr } : T 
            #else .K
            #fi
            ~> #KReadCurr Is ~>  #KHWInstance SymbolRefIdList2String({Attr["moduleName"]}:>SymbolRefIdList) {Attr["instanceName"]}:>String 
         ... </k>
    syntax KmdCIRCT ::= "#KHWInstance" String String 
    rule 
    <cid> FID </cid>
    <k> TVs:StdValues ~> #KHWInstance MN IN => #Kstimulate MN ( TVs ) by FID as HWInstanceName(FID, IN) ... </k>
    syntax String ::= HWInstanceName ( String , String ) [function, total]
    rule HWInstanceName(FatherName, InstanceName) => FatherName +String "." +String InstanceName
    // ## hw.output
    rule <k> "hw.output" ( VIDs:ValueIdList ) { _:Map } : ( _:Types ) -> ( .Types ) => .K ... </k>
         <out-vars> _ => VIDs </out-vars>
    // ## hw.triggered
    // - Operation Definitions - Miscellaneous
    // ## hw.bitcast
    rule 
    <k> "hw.bitcast" ( I:ValueId ) { .Map } : ( T1:Type ) -> ( T2:Type )
        => #KReadCurr I ~> #HWBitCast T2 ... </k>
    syntax KmdCIRCT ::= "#HWBitCast" Type
    rule <k> (V:_):StdValue ~> #HWBitCast T => V : T ... </k>
    // ## hw.constant
    rule <k> "hw.constant" ( .ValueIdList ) { "value" |-> V:AttributeValue _:Map } : ( .Types ) -> ( T:Type )
         => AttributeValue2Bits(V,T) : T ... </k>
    // ## hw.enum.cmp
    // ## hw.enum.constant
    // ## hw.param.value
    // ## hw.wire
    rule <k> "hw.wire" (IN:ValueId) {M:Map} : (T:Type) -> (T) ~> #KWriteCurr OUT:ValueId
         => #KReadCurr IN ~> OUT ... </k>
         <wire> W => 
         #if "name" in_keys(M) 
         #then W[getAttr(M, "name") <- OUT]
         #else W
         #fi
         </wire>
    // - Operation Definitions - Aggregates
    // ## hw.aggregate_constant
//     rule
//     <k> "hw.aggregate_constant" ( .ValueIdList ) { "fields" |-> V:AttributeValue _:Map } : ( .Types ) -> ( T:Type )
//          => tv(T, V) ... </k>
    // ## hw.array_concat
    rule
    <k> "hw.array_concat" ( Vs:ValueIdList ) { _:Map } : ( _:Types ) -> ( T:Type )
         => #KReadCurr Vs ~> #HWArrayConcat T ... </k>
    syntax KmdCIRCT ::= "#HWArrayConcat" Type
    rule <k> TVs:StdValues ~> #HWArrayConcat T => StdValues2Bits(TVs):T ... </k>
    // ## hw.array_create
    rule
    <k> "hw.array_create" ( Vs:ValueIdList ) { _:Map } : ( _:Types ) -> ( T:Type )
         => #KReadCurr Vs ~> #HWArrayCreate T ... </k>
    syntax KmdCIRCT ::= "#HWArrayCreate" Type
    rule <k> TVs:StdValues ~> #HWArrayCreate T => StdValues2Bits(TVs):T ... </k>
    // ## hw.array_get
    rule
    <k> "hw.array_get" ( A:ValueId, I:ValueId ) { _:Map } : ( _:Types ) -> ( T:Type )
         => #KReadCurr A ~> #KReadCurr I ~> #HWArrayGet T ... </k>
    syntax KmdCIRCT ::= "#HWArrayGet" Type
    rule <k> (V:_):StdValue ~> (Idx,.BitsVec:_):StdValue ~> #HWArrayGet T => V ~> Bits2Int(Idx) ~> #HWArrayGet T ... </k>
    rule <k> V:Bits, _:BitsVec ~> Idx:Int ~> #HWArrayGet !hw.array < _ T:Type > => BitsMask(V, Type2BitSize(T), Type2BitSize(T) *Int Idx):T ... </k>
    // ## hw.array_slice
    // ## hw.struct_create
    // ## hw.struct_explode
    // ## hw.struct_extract
    // ## hw.struct_inject
    // ## hw.union_create
    // ## hw.union_extract
    // - Operation Definitions - Type Declarations
    // ## hw.type_scope
    // ## hw.typedecl
    
endmodule