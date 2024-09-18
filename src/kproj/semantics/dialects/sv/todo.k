module SV-TODO

    // sv.cover
    rule <k> "sv.cover" ( _:Var ) { _:Map } : ( _:Type ) -> ( .Types ) => .K ... </k>

    // sv.cover.concurrent, meaningless
    rule <k> 
            "sv.cover.concurrent" ( _Clk:Var , _Cond:Var ) { _:Map } : ( _:Type , _:Type ) -> ( .Types )
            => .K
            ...
        </k>


    // sv.generate
    rule <k> "sv.generate" ( .VarList ) ( R:Region ) {_:Map } : ( .Types ) -> ( .Types )
            => #SvGenerate R
            ...
        </k>

    // sv.generate.case
    rule <k> "sv.generate.case" ( .VarList ) { _:Map } : ( .Types ) -> ( .Types )
            => .K
            ...
        </k>

    // sv.localparam
    rule <k> circt </k>
        <circt-exec> 
            "sv.localparam" ( .VarList ) { Attr:Map } : ( .Types ) -> ( T:Type )
            => ListItem( TV(T, getAttrValue(Attr, #token("value", "BareId"))) )
            ...
        </circt-exec>

    
    // // sv.xmr.ref
    // rule <k> circt </k>
    //     <circt-exec>
    //         (.K => .List) ~>
    //         (.K => M [ SymbolRefId2String({Attr[#token("ref", "BareId")]}:>SymbolRefId) ]) ~>
    //         "sv.xmr.ref" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < _T:Type > )
    //         ...
    //     </circt-exec>
    //     <hw-hierpath> M:Map </hw-hierpath>
    
    // rule <k> circt </k>
    //     <circt-exec>
    //         (L1:List => L1 ListItem(SymbolRefId2String(Mod) +String "::" +String SymbolRefId2String(Ins))) ~>
    //         [ #hw.innerNameRef < Mod:SymbolRefId :: Ins:SymbolRefId > , AL:AttributeValueList => AL ] ~>
    //         "sv.xmr.ref" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:Type > )
    //         ...
    //     </circt-exec>
    
    // rule <k> circt </k>
    //     <circt-exec>
    //         _:List ~>
    //         ([.AttributeValueList] => .List) ~>
    //         "sv.xmr.ref" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:Type > )
    //         ...
    //     </circt-exec>
    
    // rule <k> circt </k>
    //     <circt-exec>
    //         (ListItem(Ref:String) L1:List => L1) ~>
    //         (L:List => L ListItem(M [Ref])) ~>
    //         "sv.xmr.ref" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:Type > )
    //         ...
    //     </circt-exec>
    //     <symrefs> M:Map </symrefs>
    //     requires Ref in_keys(M)
    
    // rule <k> circt </k>
    //     <circt-exec>
    //         (
    //             .List ~>
    //             L:List ListItem(Terminal:String) ~>
    //             "sv.xmr.ref" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < T:Type > )
    //         ) => (
    //             getTrace(ListItem(Mod) L) ~>
    //             Terminal ~>
    //             "sv.xmr" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < T > )
    //         )
    //         ...
    //     </circt-exec>
    //     <trace> ListItem(Mod:String) _:List </trace>
        

       
    // rule <k> circt </k>
    //     <circt-exec>
    //         ("not port-in" => M[String2BareId(Terminal)] orDefault "not port-out") ~>
    //         Path:String ~>
    //         Terminal:String ~>
    //         "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:IntegerType > )
    //         ...
    //     </circt-exec>
    //     <instance>
    //         <inst-name> Path </inst-name>
    //         <inst-out> M:Map </inst-out>
    //         ...
    //     </instance>
    
    // rule <k> circt </k>
    //     <circt-exec>
    //         ("not port-out" => M[Terminal] orDefault "not reg") ~>
    //         Path:String ~>
    //         Terminal:String ~>
    //         "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:IntegerType > )
    //         ...
    //     </circt-exec>
    //     <instance>
    //         <inst-name> Path </inst-name>
    //         <inst-regs> M:Map </inst-regs>
    //         ...
    //     </instance>

    // rule <k> circt </k>
    //     <circt-exec>
    //         ("not reg" => M[Terminal] orDefault "not wire") ~>
    //         Path:String ~>
    //         Terminal:String ~>
    //         "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:IntegerType > )
    //         ...
    //     </circt-exec>
    //     <instance>
    //         <inst-name> Path </inst-name>
    //         <inst-wires> M:Map </inst-wires>
    //         ...
    //     </instance>
    
    // rule <k> circt </k>
    //     <circt-exec>
    //         ("not wire" => "no such net") ~>
    //         _Path:String ~>
    //         _Terminal:String ~>
    //         "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:IntegerType > )
    //         ...
    //     </circt-exec>
    
    // rule <k> circt </k>
    //     <circt-exec>
    //         (.K => M[V] orDefault "no such var") ~>
    //         V:Var ~> Path:String ~> _Terminal:String ~>
    //         "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _:IntegerType > )
    //         ...
    //     </circt-exec>
    //     <instance>
    //         <inst-name> Path </inst-name>
    //         <inst-vars> M:Map </inst-vars>
    //         ...
    //     </instance>
    
    // rule <k> circt </k>
    //     <circt-exec>
    //         (
    //             TV(T, V) ~>
    //             _:Var ~>
    //             _:String ~>
    //             Terminal:String ~>
    //             "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < T:IntegerType > )
    //         ) => ListItem( TV(!hw.inout < T >, hw.inout(Terminal, T, V)) )
    //         ...
    //     </circt-exec>
    
    // rule <k> circt </k>
    //     <circt-exec>
    //         (
    //             TV(!hw.inout < T >, hw.inout(Terminal, T, V)) ~>
    //             _:Var ~>
    //             _:String ~>
    //             Terminal:String ~>
    //             "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < T:IntegerType > )
    //         ) => ListItem( TV(!hw.inout < T >, hw.inout(Terminal, T, V)) )
    //         ...
    //     </circt-exec>

endmodule