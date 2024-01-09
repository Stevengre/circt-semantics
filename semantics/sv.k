module SV
    imports CONFIGURATION
    imports CIRCT-SYNTAX

    // sv.constantX, todo
    rule <k> circt </k>
        <circt-exec> 
            "sv.constantX" ( .ValueIdList ) { .Map } : ( .Types ) -> ( T:Type )
            => ListItem(TV(T, 0))
            ...
        </circt-exec>


    // sv.constantZ, todo
    rule <k> circt </k>
        <circt-exec> 
            "sv.constantZ" ( .ValueIdList ) { .Map } : ( .Types ) -> ( T:Type )
            => ListItem(TV(T, 0))
            ...
        </circt-exec>

    
    // sv.case
    rule <k> circt </k>
        <circt-exec> 
            (.K => TV(T, V)) ~>
            (.K => Attr[#token("casePatterns", "BareId")]) ~>
            "sv.case" ( I:ValueId ) ( _:Regions ) { Attr:Map } : ( T:Type ) -> ( .Types )
            ...
        </circt-exec>
        <circt-locals> ... I |-> TV(T, V) ... </circt-locals>

    rule <k> circt </k>
        <circt-exec> 
            (
                TV(T, V:Int) ~>
                [ X:Int : _:IntegerType, L:AttributeValueList ] ~>
                "sv.case" ( I:ValueId ) ( R:Region, Rs:Regions ) { Attr:Map } : ( T:Type ) -> ( .Types )
            ) => #if V ==Int X 
                #then R 
                #else 
                    TV(T, V) ~>
                    [ L ] ~>
                    "sv.case" ( I ) ( Rs ) { Attr } : ( T ) -> ( .Types )
                #fi
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (
                TV(T, _:Int) ~>
                [ (unit, .AttributeValueList):AttributeValueList ] ~>
                "sv.case" ( _:ValueId ) ( R:Region ) { _:Map } : ( T:Type ) -> ( .Types )
            )
            => R
            ...
        </circt-exec>


    // sv.indexed_part_select, todo
    rule <k> circt </k>
        <circt-exec> 
            "sv.indexed_part_select" ( I1:ValueId , I2:ValueId ) { Attr:Map } : ( T1:Type , T2:Type ) -> ( T:Type )
            => ListItem( TV(
                T, 
                V1 &Int ((( 2 ^Int {getAttrValue(Attr, #token("width", "BareId"))}:>Int -Int 1 ) <<Int V2 ) >>Int V2)
            ) )
            ...
        </circt-exec>
        <circt-locals>
            ...
            I1 |-> TV(T1, V1:Int)
            I2 |-> TV(T2, V2:Int)
            ...
        </circt-locals>
    
    // sv.indexed_part_select_inout, todo
    rule <k> circt </k>
        <circt-exec> 
            "sv.indexed_part_select_inout" ( I1:ValueId , I2:ValueId ) { Attr:Map } : ( !hw.inout < T1:IntegerType > , T2:Type ) -> ( !hw.inout < T:IntegerType > )
            => ListItem( TV(
                !hw.inout < T >,
                hw.inout("", T, V1 &Int ((( 2 ^Int {getAttrValue(Attr, #token("width", "BareId"))}:>Int -Int 1 ) <<Int V2 ) >>Int V2))
            ) )
            ...
        </circt-exec>
        <circt-locals>
            ...
            I1 |-> TV(!hw.inout< T1 >, hw.inout(_:String, T1, V1:Int))
            I2 |-> TV(T2, V2:Int)
            ...
        </circt-locals>

    // sv.localparam
    rule <k> circt </k>
        <circt-exec> 
            "sv.localparam" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( T:Type )
            => ListItem( TV(T, getAttrValue(Attr, #token("value", "BareId"))) )
            ...
        </circt-exec>


    // sv.fwrite
    rule <k> circt </k>
        <circt-exec> 
            "sv.fwrite" ( I:ValueId ) { Attr:Map } : ( T:Type ) -> ( .Types ) => .List
            ...
        </circt-exec>
        <circt-locals> ... I |-> TV(T, V) ... </circt-locals>
        <fd> 
            M:Map => M [V <- {M[V] orDefault .List}:>List ListItem(Attr[#token("format_string", "BareId")]) ]
        </fd>


    // sv.if
    rule <k> circt </k>
        <circt-exec> 
            (.K => V) ~>
            "sv.if" ( I:ValueId ) ( _:Regions ) { .Map } : ( T:Type ) -> ( .Types )
            ...
        </circt-exec>
        <circt-locals> ... I |-> TV(T, V) ... </circt-locals>

    rule <k> circt </k>
        <circt-exec> 
            (
                X:Int ~>
                "sv.if" ( _:ValueId ) ( R1:Region , R2:Region ) { .Map } : ( _:Type ) -> ( .Types )
            ) => #if X ==Int 0 #then R2 #else R1 #fi
            ...
        </circt-exec>

    
    // sv.ifdef
    rule <k> circt </k>
        <circt-exec> 
            ( .K => M[#token("cond", "BareId")] orDefault stop )
            ~> "sv.ifdef" ( .ValueIdList ) ( _:Regions ) { M:Map } : _:FunctionType
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (B:Bool ~> "sv.ifdef" ( .ValueIdList ) ( R1:Region , R2:Region ) { _:Map } : _:FunctionType)
            => #if B #then R1 #else R2 #fi
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec> 
            (
                (#token("#sv", "AttributeAlias") < #token("macro.ident", "BareId") S:StringLiteral >):DialectAttribute
                => S in_keys(M)
            ) ~> "sv.ifdef" ( .ValueIdList ) ( _:Regions ) { _:Map } : _:FunctionType
            ...
        </circt-exec>
        <macros> M:Map </macros>
    

    // sv.ifdef.procedural
    rule <k> circt </k>
        <circt-exec> 
            ( .K => Attr[#token("cond", "BareId")] orDefault stop )
            ~> "sv.ifdef.procedural" ( .ValueIdList ) ( _:Regions ) { Attr:Map } : _:FunctionType
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (B:Bool ~> "sv.ifdef.procedural" ( .ValueIdList ) ( R1:Region , R2:Region ) { _:Map } : _:FunctionType)
            => #if B #then R1 #else R2 #fi
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (
                (#token("#sv", "AttributeAlias") < #token("macro.ident", "BareId") S:StringLiteral >):DialectAttribute
                => S in_keys(M)
            ) ~> "sv.ifdef.procedural" ( .ValueIdList ) ( _:Regions ) { _:Map } : _:FunctionType
            ...
        </circt-exec>
        <macros> M:Map </macros>


    // sv.macro.ref, ident
    rule <k> circt </k>
        <circt-exec> 
            ( .K => {M [#token("ident", "BareId")]}:>DialectAttribute ) 
            ~> "sv.macro.ref" ( .ValueIdList ) { M:Map } : ( .Types ) -> ( _:Type )
            ...
        </circt-exec>
        requires #token("ident", "BareId") in_keys(M)
    
    rule <k> circt </k>
        <circt-exec> 
            (
                (#token("#sv", "AttributeAlias") < #token("macro.ident", "BareId") S:StringLiteral >):DialectAttribute
                => M [S]
            ) ~> "sv.macro.ref" ( .ValueIdList ) { _:Map } : ( .Types ) -> ( _T:Type )
            ...
        </circt-exec>
        <macros> M:Map </macros>
    
    rule <k> circt </k>
        <circt-exec> 
            ( S:String ~> "sv.macro.ref" ( .ValueIdList ) { _:Map } : ( .Types ) -> ( T:Type ) )
            => ListItem( TV(T, String2Int(S)) )
            ...
        </circt-exec>
        requires lengthString(S) >Int 0
    
    rule <k> circt </k>
        <circt-exec> 
            ( S:String ~> "sv.macro.ref" ( .ValueIdList ) { _:Map } : ( .Types ) -> ( T:Type ) )
            => ListItem( TV(T, 0) )
            ...
        </circt-exec>
        requires lengthString(S) ==Int 0
    

    // sv.macro.ref, macroName
    rule <k> circt </k>
        <circt-exec> 
            ( .K => M [#token("macroName", "BareId")] ) 
            ~> "sv.macro.ref" ( .ValueIdList ) { M:Map } : ( .Types ) -> ( _:Type )
            ...
        </circt-exec>
        requires #token("macroName", "BareId") in_keys(M) andBool (notBool (#token("ident", "BareId") in_keys(M)))
    
    rule <k> circt </k>
        <circt-exec> 
            (
                S:SymbolRefId
                => M [SymbolRefId2String(S)] orDefault (stop SymbolRefId2String(S))
            ) ~> "sv.macro.ref" ( .ValueIdList ) { _:Map } : ( .Types ) -> ( _:Type )
            ...
        </circt-exec>
        <macros> M:Map </macros>
    

    // sv.macro.def
    rule <k> circt </k>
        <circt-exec> 
            ( .K => M [#token("macroName", "BareId")] ) ~>
            ( .K => M [#token("format_string", "BareId")] ) ~> 
            "sv.macro.def" ( .ValueIdList ) { M:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (S:SymbolRefId => SymbolRefId2String(S))
            ~> _Fmt:String
            ~> "sv.macro.def" ( .ValueIdList ) { _:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (
                MacroName:String 
                ~> Fmt:String
                ~> "sv.macro.def" ( .ValueIdList ) { _:Map } : ( .Types ) -> ( .Types )
            )
            => .List
            ...
        </circt-exec>
        <macros>
            M:Map => M [MacroName <- Fmt]
        </macros>
    

    // sv.wire, how to express a inout value?
    rule <k> circt </k>
        <circt-exec> 
            "sv.wire" ( .ValueIdList ) {M:Map} : ( .Types ) -> ( !hw.inout < T:IntegerType > )
            => ListItem( TV(
                !hw.inout< T >,
                hw.inout({M[#token("name", "BareId")]}:>String, T, 0)
            ) )
            ...
        </circt-exec>
    
    
    // sv.reg
    rule <k> circt </k>
        <circt-exec> 
            "sv.reg" ( .ValueIdList ) {M:Map} : ( .Types ) -> ( !hw.inout < T:IntegerType > )
            => ListItem( TV(
                !hw.inout< T >,
                hw.inout({M[#token("name", "BareId")]}:>String, T, 0)
            ) )
            ...
        </circt-exec>
    

    // sv.read_inout, but where to read?
    rule <k> circt </k>
        <circt-exec> 
            "sv.read_inout" ( I:ValueId ) { .Map } : ( !hw.inout < T:IntegerType > ) -> ( T:IntegerType )
            => ListItem(TV(T, V))
            ...
        </circt-exec>
        <circt-locals>
            ...
            I |-> TV(!hw.inout< T >, hw.inout(_:String, T, V:Int))
            ...
        </circt-locals>
    

    // sv.error
    rule <k> circt </k>
        <circt-exec> 
            "sv.error" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <sv-error>
            L:List => L ListItem(Attr[#token("message", "BareId")])
        </sv-error>
    

    // sv.warning
    rule <k> circt </k>
        <circt-exec> 
            "sv.warning" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <sv-warn>
            L:List => L ListItem(Attr[#token("message", "BareId")])
        </sv-warn>
    

    // sv.info
    rule <k> circt </k>
        <circt-exec> 
            "sv.info" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <sv-info>
            L:List => L ListItem(Attr[#token("message", "BareId")])
        </sv-info>


    // sv.fatal
    rule <k> circt => stop Attr[#token("verbosity", "BareId")] </k>
        <circt-exec> 
            "sv.fatal" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>
        <sv-fatal>
            L:List => L ListItem(Attr[#token("message", "BareId")])
        </sv-fatal>

    
    // sv.verbatim
    rule <k> circt </k>
        <circt-exec> 
            "sv.verbatim" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <sv-verbatim>
            L:List => L ListItem(Attr[#token("format_string", "BareId")])
        </sv-verbatim>


    // sv.finish
    rule <k> circt => stop Attr[#token("verbosity", "BareId")] </k>
        <circt-exec> 
            "sv.finish" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>
    

    // sv.stop
    rule <k> circt => stop Attr[#token("verbosity", "BareId")] </k>
        <circt-exec> 
            "sv.stop" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>
    

    // sv.exit
    rule <k> circt => stop </k>
        <circt-exec> 
            "sv.exit" ( .ValueIdList ) { _:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>
    

    // sv.initial
    rule <k> circt </k>
        <circt-exec> 
            "sv.initial" ( .ValueIdList ) ( R:Region ) { _:Map } : ( .Types ) -> ( .Types )
            => #if Inst in S #then .List #else R #fi
            ...
        </circt-exec>
        <instance> Inst:String </instance>
        <initialized> S:Set => S SetItem(Inst) </initialized>


    // sv.always
    rule <k> circt </k>
        <circt-exec> 
            "sv.always" ( .ValueIdList ) ( R:Region ) { _:Map } : ( .Types ) -> ( .Types )
            => R
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (.K => Vs) ~> 
            (.K => Attr[#token("events", "BareId")]) ~> 
            "sv.always" ( Vs:ValueIdList ) ( _:Region ) { Attr:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (.K => Old[V] orDefault false) ~>
            (.K => Locals[V] orDefault false) ~>
            (.K => {I}:>Int) ~> 
            (V:ValueId , Vs:ValueIdList => Vs) ~> 
            ([ I:IntegerLiteral : _:IntegerType , As:AttributeValueList ] => [ As ]) ~> 
            "sv.always" ( _:ValueIdList ) ( _:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
        <circt-locals> Locals:Map </circt-locals>
        <last-locals> Old:Map </last-locals>
        // requires size(Old) ==Int 0
    
    rule <k> circt </k>
        <circt-exec>
            (false ~> _:KItem ~> _:Int => false)
            ~> _:ValueIdList
            ~> [ _:AttributeValueList ]
            ~> "sv.always" ( _:ValueIdList ) ( _:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (
                TV ( _:IntegerType , Old:Int ) ~> 
                TV ( _:IntegerType , New:Int ) ~> 
                Event:Int
                => eventCheck(Old, New:Int, Event:Int)
            ) ~> 
            _:ValueIdList ~> 
            [ _:AttributeValueList ] ~> 
            "sv.always" ( _:ValueIdList ) ( _:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (false => .K) ~> 
            _:ValueIdList ~> 
            [ _:AttributeValueList ] ~> 
            "sv.always" ( _:ValueIdList ) ( _:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (
                true ~> 
                _:ValueIdList ~> 
                [ _:AttributeValueList ] ~> 
                "sv.always" ( _:ValueIdList ) ( R:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ) => R
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (
                .ValueIdList ~> 
                [ .AttributeValueList ] ~> 
                "sv.always" ( _:ValueIdList ) ( _:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ) => .List
            ...
        </circt-exec>

    syntax Int ::= signalEvent(Int, Int) [function]
    rule signalEvent(0, 1) => 1
    rule signalEvent(1, 0) => -1
    rule signalEvent(_:Int, _:Int) => 0 [owise]

    // check always events
    syntax Bool ::= eventCheck(Int, Int, Int) [function]
    rule eventCheck(Last:Int, Now:Int, 0) => true requires Last <Int Now
    rule eventCheck(Last:Int, Now:Int, 1) => true requires Last >Int Now
    rule eventCheck(_:Int, _:Int, _:Int) => false [owise]
endmodule