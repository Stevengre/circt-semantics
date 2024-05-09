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
    configuration
    <hw>
      <hw-ins> .List </hw-ins>
      <hw-outs> .List </hw-outs>
    </hw>

    // # Types
    // ## !hw.modty
    rule <k> !hw.modty<input ID : T, Ps:ModulePortList> => !hw.modty<Ps> ... </k>
         <hw-ins> L:List => L ListItem(ID:T) </hw-ins>
         <clock> 0 </clock>
    rule <k> !hw.modty<output ID : T, Ps:ModulePortList> => !hw.modty<Ps> ... </k>
         <hw-outs> L:List => L ListItem(ID:T) </hw-outs>
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
    rule <k> #KHWSetupInsAUX ~> _:CaretId ( VTs:ValueIdAndTypeList ) : => #KHWSetupInsAUX ~> L ~> VTs ... </k>
         <hw-ins> L:List </hw-ins>
    rule <k> #KHWSetupInsAUX ~> ListItem((BID:T):BareIdAndType) L:List ~> (VID:T):ValueIdAndType, VTs:ValueIdAndTypeList 
         => #KHWSetupInsAUX ~> L ~> VTs ... </k>
         <in> M:Map => M[BID <- VID] </in>
    rule <k> #KHWSetupInsAUX ~> .List ~> .ValueIdAndTypeList => .K ...</k>
    rule <k> #KHWSetupInsAUX ~> _:List ~> _:ValueIdAndTypeList => #Khalt "unexpected situation about !hw.modty and SetupIns" </k> [owise]
    
    // # Operations
    // ## hw.module
    rule <phase> #stimulating </phase>
         <k> "hw.module" (.ValueIdList) ({ .OperationList  B:Block .BlockList}, .Regions) {Attr:Map} : _ 
             => getAttr(Attr, "module_type") ~> B 
         ... </k>
endmodule