requires "builtin.k"
requires "comb.k"

requires "seq.k"
requires "sv.k"
// requires "circt-conf.k"
// requires "types.k"

module CIRCT-SYNTAX-CORE
    imports BUILTIN-DIALECT-SYNTAX
    imports BOOL
    imports MAP
    imports K-EQUAL
    imports INT
    imports STRING
    imports LIST
    imports MLIR

    syntax ConstX ::= "#x" [token]
    syntax ConstZ ::= "#z" [token]

    syntax CirctInt ::= Int | ConstX | ConstZ
    syntax Value ::= CirctInt

    syntax Value ::= String
                   | Bool
                //    | Int
                //    | ConstX
                //    | ConstZ

    syntax TypeValue ::= "TV" "(" Type "," Value ")"

    syntax Values ::= List{Value, ","}

    syntax String ::= "SignedIntegerType2String" "(" SignedIntegerType ")" [function, total,hook(STRING.token2string)]
    syntax String ::= "UnsignedType2String" "(" UnsignedIntegerType ")" [function, total,hook(STRING.token2string)]
    syntax String ::= "SignlessIntegerType2String" "(" SignlessIntegerType ")" [function, total,hook(STRING.token2string)]
    syntax String ::= "IntType2String" "(" IntegerType ")" [function]
    rule IntType2String(SI:SignedIntegerType) => SignedIntegerType2String(SI)
    rule IntType2String(II:UnsignedIntegerType) => UnsignedType2String(II)
    rule IntType2String(LI:SignlessIntegerType) => SignlessIntegerType2String(LI)
    
    syntax Values ::= List2Values(List) [function]
    rule List2Values(ListItem(V:Value) L:List) => V, List2Values(L)
    rule List2Values(.List) => .Values

    syntax List ::= Values2List(Values) [function]
    rule Values2List(V:Value, Vs:Values) => ListItem(V) Values2List(Vs)
    rule Values2List(.Values) => .List

    syntax Result ::= "#result" "(" BareId "," TypeValue ")"

    syntax String ::= getTrace(List) [function]
    rule getTrace(ListItem(S1:String) ListItem(S2:String) L:List) => S1 +String "/" +String getTrace(ListItem(S2:String) L)
    rule getTrace(ListItem(S:String) .List) => S
    rule getTrace(.List) => ""

    syntax String ::= getInnerSymString(DialectAttribute) [function]
    rule getInnerSymString(#token("#hw", "AttributeAlias") < #token("innerSym", "BareId") SymId:SymbolRefId >) 
        => SymbolRefId2String(SymId)

endmodule


module SEQ-FIRMEM
    imports CIRCT-SYNTAX-CORE

    syntax SeqFirmemType ::= "!seq.firmem" "<" Int "x" Int ">"
    syntax SeqFirmem ::= "seq.firmem" "("Int "," Int "," Map ")"

    syntax Type ::= SeqFirmemType
    syntax Value ::= SeqFirmem

    syntax Int ::= SeqFirmemRead(SeqFirmem, Int) [function]
    syntax Int ::= SeqFirmemWrite(SeqFirmem, Int, Int) [function]

    rule SeqFirmemRead(seq.firmem ( _:Int , _:Int , M:Map ) , Addr:Int) => {M[Addr] orDefault 0}:>Int
endmodule



module CIRCT-SYNTAX
    imports HW-ARRAY
    imports HW-STRUCT
    imports HW-ENUM
    imports HW-INOUT
    imports SEQ-FIRMEM

    syntax Control ::= "circtTest" SymbolRefId "(" Values ")"

    syntax AttributeValue ::= getAttr(Map, BareId) [function]
    rule getAttr(M:Map, I:BareId) => {M[I]}:>AttributeValue

    syntax Value ::= toValue(AttributeValue) [function]
    
    rule toValue(I:IntegerLiteral : _:IntegerType) => {I}:>Int
    rule toValue(B:Bool) => #if B #then 1 #else 0 #fi
    rule toValue([I:IntegerLiteral : _:IntegerType]) => {I}:>Int
    rule toValue([ L:AttributeValueList ]) => ([ toValues(L) ]):HwArray
    rule toValue(V:HwModty) => V
    
    syntax Values ::= toValues(AttributeValueList) [function]
    rule toValues(I:IntegerLiteral : _:IntegerType , L:AttributeValueList) => {I}:>Int , toValues(L)
    rule toValues(B:Bool , L:AttributeValueList) => #if B #then 1 #else 0 #fi, toValues(L)
    rule toValues([Vs:AttributeValueList] , L:AttributeValueList) => [toValues(Vs)], toValues(L)
    rule toValues(S:String, L:AttributeValueList) => S, toValues(L)
    rule toValues(.AttributeValueList) => .Values

    syntax Value ::= getAttrValue(Map, BareId) [function]
    rule getAttrValue(M:Map, I:BareId) => toValue({M[I]}:>AttributeValue)

    // syntax Value ::= getAttrValue(Map, String) [function]
    // rule getAttrValue(M:Map, I:String) => toValue({M[#token(I, "BareId")]}:>AttributeValue)

    syntax BareId ::= String2BareId(String) [function, total, hook(STRING.string2token)]
endmodule



module CIRCT
    // imports CIRCT-PREPROCESS
    imports COMB
    imports HW
    imports SEQ
    imports SV

    // single test
    rule <k> circt </k>
        <symbol-table> M:Map </symbol-table>
        <circt-control>
            circtTest ID:SymbolRefId ( Vs:Values ) => .K
            ...
        </circt-control>
        <circt-frames>
            .Bag =>
            <circt-frame>
                <circt-exec>
                    // initial ~> always ~> 
                    #if SymbolRefId2String(ID) in_keys(M) 
                    #then  Vs ~> M [ SymbolRefId2String(ID) ]
                    #else stop "no such module"
                    #fi
                </circt-exec>
                <name> SymbolRefId2String(ID) </name>
                <last-locals> .Map </last-locals>
                <module> ID </module>
                ...
            </circt-frame>
        </circt-frames>
        <state>
            .Bag =>
            <instance>
                <inst-name> SymbolRefId2String(ID) </inst-name>
                ...
            </instance>
        </state>
        [owise]
    
    // test list, first clock
    rule <k> circt </k>
        <symbol-table> M:Map </symbol-table>
        <circt-control>
            ListItem(circtTest ID:SymbolRefId (Vs:Values)) L:List => L
            ...
        </circt-control>
        <circt-frames>
            .Bag =>
            <circt-frame>
                <circt-exec>
                    // initial ~> always ~> 
                    #if SymbolRefId2String(ID) in_keys(M) 
                    #then  Vs ~> M [ SymbolRefId2String(ID) ]
                    #else stop "no such module"
                    #fi
                </circt-exec>
                <name> SymbolRefId2String(ID) </name>
                <last-locals> .Map </last-locals>
                <module> ID </module>
                ...
            </circt-frame>
        </circt-frames>
        <trace> .List => ListItem(SymbolRefId2String(ID)) </trace>
        <state>
            ...
            (.Bag => 
                <instance>
                    <inst-name> SymbolRefId2String(ID) </inst-name>
                    ...
                </instance>
            )
        </state>
        [owise]

    // test list, subsequent clocks
    rule <k> circt </k>
        <symbol-table> M:Map </symbol-table>
        <circt-control>
            ListItem(circtTest ID:SymbolRefId (Vs:Values)) L:List => L
            ...
        </circt-control>
        <circt-frames>
            .Bag =>
            <circt-frame>
                ...
                <circt-exec>
                    // initial ~> always ~> 
                    #if SymbolRefId2String(ID) in_keys(M) 
                    #then  Vs ~> M [ SymbolRefId2String(ID) ]
                    #else stop "no such module"
                    #fi
                </circt-exec>
                <name> SymbolRefId2String(ID) </name>
                <last-locals> Old </last-locals>
                <module> ID </module>
                ...
            </circt-frame>
        </circt-frames>
        <trace> .List => ListItem(SymbolRefId2String(ID)) </trace>
        <instance>
            <inst-name> Name:String </inst-name>
            <inst-vars> Old:Map => .Map </inst-vars>
            <inst-in> _ => .Map </inst-in>
            <inst-out> _ => .Map </inst-out>
            <inst-regs> _ => .Map </inst-regs>
            <inst-wires> _ => .Map </inst-wires>
        </instance>
        requires Name ==String SymbolRefId2String(ID)
    

    rule <k> circt </k>
        <circt-exec> 
            (ListItem(X:BareId) L:List => L) ~>
            (V:Value, Vs:Values => Vs) ~>
            _:CaretId (I:Var : T:Type, Is:VarAndTypeList => Is) : _:OperationList
        </circt-exec>
        <circt-locals> M:Map => M [I <- TV(T, V)] </circt-locals>
        <name> Name:String </name>
        <instance>
            <inst-name> Name </inst-name>
            <inst-in> M1:Map => M1 [X <- I] </inst-in>
            ...
        </instance>
        
    
    rule <k> circt </k>
        <circt-exec> 
            (
                .List ~>
                .Values ~> 
                _:CaretId (.VarAndTypeList) : Ops:OperationList
            ) => Ops
        </circt-exec>

    rule <k> circt </k> 
        <circt-exec> 
            Op:Operation Ops:OperationList => Op ~> Ops 
            ...
        </circt-exec>
    
    rule <k> circt </k> 
        <circt-exec> 
            .OperationList => .K
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec> 
            Rs:OpResults = Op:GenericOperation => Op ~> Rs = 
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (ListItem( TV(T:Type, V:Value) ) L:List => L)
            ~> (I:Var, Rs:OpResults => Rs) =
            ...
        </circt-exec>
        <circt-locals> M:Map => M [I <- TV(T, V)] </circt-locals>
    
    rule <k> circt </k>
        <circt-exec> 
            (
                ListItem( TV(!hw.inout< T >, hw.inout(Reg:String, T, V)) )
                ~> "reg"
                ~> I:Var =
            ) => .K
            ...
        </circt-exec>
        <circt-locals> 
            Locals:Map => Locals [I <- {Old[I] orDefault TV(!hw.inout< T >, hw.inout(Reg, T, V))}:>TypeValue]
        </circt-locals>
        <last-locals> Old:Map </last-locals>
        <name> Name:String </name>
        <instance>
            <inst-name> Name </inst-name>
            <inst-regs> M:Map => M [Reg <- I] </inst-regs>
            ...
        </instance>
    
    rule <k> circt </k>
        <circt-exec> 
            (
                ListItem( TV(!hw.inout< T >, hw.inout(Wire, T, V)) )
                ~> "wire"
                ~> I:Var =
            ) => .K
            ...
        </circt-exec>
        <circt-locals> 
            Locals:Map => Locals [I <- TV(!hw.inout< T >, hw.inout(Wire, T, V))]
        </circt-locals>
        <name> Name:String </name>
        <instance>
            <inst-name> Name </inst-name>
            <inst-wires> M:Map => M [Wire <- I] </inst-wires>
            ...
        </instance>
    
    // %35:2 = "hw.struct_explode"(%32) : (!hw.struct<foo: i19, bar: i7>) -> (i19, i7)
    rule <k> circt </k>
        <circt-exec> 
            (L:List => range(L, I, 0))
            ~> (A:Var : I:Int, Rs:OpResults => Rs) =
            ...
        </circt-exec>
        <circt-locals> M:Map => M [A <- range(L, 0, size(L) -Int I)] </circt-locals>
    
    rule <k> circt </k>
        <circt-exec> 
            (.List ~> .OpResults =) => .K
            ...
        </circt-exec>
    
    // rule <k> circt </k>
    //     <circt-exec> 
    //         S:StringLiteral ( VIL:VarList ) [ .Successors ] ( .Regions ) { .Map } : FT:FunctionType
    //         => S ( VIL ) : FT
    //         ...
    //     </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            S:StringLiteral ( VIL:VarList ) [ .Successors ] ( .Regions ) { Attr:Map } : FT:FunctionType
            => S ( VIL ) { Attr } : FT
            ...
        </circt-exec>
    // requires size(Attr) >Int 0

    rule <k> circt </k>
        <circt-exec> 
            S:StringLiteral ( VIL:VarList ) [ .Successors ] ( R:Region, Rs:Regions ) { Attr:Map } : FT:FunctionType
            => S ( VIL ) (R, Rs) { Attr } : FT
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec> 
            { Op:Operation Ops:OperationList BL:BlockList } => Op ~> { Ops BL }
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            ({ .OperationList .BlockList } ~> .OpResults =) => .K
            ...
        </circt-exec>
    
    // one clock done
    rule <k> circt </k>
        <circt-frames>
            (
                <circt-frame>
                    <circt-exec> .K </circt-exec>
                    <circt-output> Out:List </circt-output>
                    <circt-locals> Locals:Map </circt-locals>
                    <name> Name:String </name>
                    ...
                </circt-frame>
                => .Bag
            )
        </circt-frames>
        <result> L:List => L ListItem(Out) </result>
        <trace> Trace:List ListItem(_) => Trace </trace>
        <instance>
            <inst-name> Name </inst-name>
            <inst-vars> _ => Locals </inst-vars>
            ...
        </instance>

    // all clock done
    rule <k> circt => done </k>
        <circt-control> .List </circt-control>
        <circt-frames> .Bag </circt-frames>
endmodule