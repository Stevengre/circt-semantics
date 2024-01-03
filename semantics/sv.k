module SV
    imports CONFIGURATION
    imports CIRCT-SYNTAX

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

    // sv.macro.ref    
    rule <k> circt </k>
        <circt-exec> 
            ( .K => {M [#token("ident", "BareId")]}:>DialectAttribute ) 
            ~> "sv.macro.ref" ( .ValueIdList ) { M:Map } : ( .Types ) -> ( _T:Type )
            ...
        </circt-exec>

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
    
    rule <k> circt </k>
        <circt-exec> 
            ( .K => M [#token("macroName", "BareId")] ~> M [#token("format_string", "BareId")] )
            ~> "sv.macro.def" ( .ValueIdList ) { M:Map } : ( .Types ) -> ( .Types )
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
                MacroName:String ~> Fmt:String
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
    
    // sv.read_inout, where to read?
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
    
    // sv.initial
    rule <k> circt </k>
        <circt-exec> 
            "sv.initial" ( .ValueIdList ) ( R:Region ) { _:Map } : ( .Types ) -> ( .Types )
            => R
            ...
        </circt-exec>

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
    
    // todo
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

    syntax Bool ::= eventCheck(Int, Int, Int) [function]
    rule eventCheck(_:Int, _:Int, _:Int) => false
endmodule