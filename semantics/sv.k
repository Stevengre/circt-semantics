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
    
    // sv.initial
    rule <k> circt </k>
        <circt-exec> 
            "sv.initial" ( .ValueIdList ) ( _:Region ) { .Map } : ( .Types ) -> ( .Types )
            => .List
            ...
        </circt-exec>

    // sv.always
    rule <k> circt </k>
        <circt-exec> 
            "sv.always" ( .ValueIdList ) ( _:Region ) { .Map } : ( .Types ) -> ( .Types )
            => .List
            ...
        </circt-exec>
endmodule