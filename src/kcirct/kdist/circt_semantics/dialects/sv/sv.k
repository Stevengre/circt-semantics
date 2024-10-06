requires "../../circt/circt.k"
requires "./sv-always.k"
requires "./sv-for.k"
requires "./sv-reg.k"


module SV-SYNTAX
    imports CIRCT-SYNTAX

    syntax KmdCIRCT ::= "#SvError"
                      | "#SvInfo"
                      | "#SvWarning"
                      | "#SvVerbatim"
                      | "#SvFinish"
                      | "#SvExit"
                      | "#SvFatal"
                      | "#SvIf"
                      | "#SvFor"
                      | "#SvInitial"
                      | "#SvAlways"
                      | "#SvAssert"
endmodule


module SV-HELPER
    imports SV-SYNTAX

    // check edge events
    syntax Bool ::= eventCheck(Int, Int, Int) [function]

    rule eventCheck(0, 1, 0) => true
    rule eventCheck(1, 0, 1) => true
    rule eventCheck(_:Int, _:Int, _:Int) => false [owise]
endmodule


module SV-MSG
    imports SV-SYNTAX

    rule <k> "sv.error" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types ) 
            => #SvError ~> Attr["message"]
            ... 
        </k>
    
    rule <k> "sv.info" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => #SvInfo ~> Attr["message"]
            ...
        </k>
    
    rule <k> "sv.warning" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => #SvWarning ~> Attr["message"]
            ...
        </k>

    rule <k> "sv.verbatim" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => #SvVerbatim ~> Attr["format_string"] ~> Attr["symbols"]
            ...
        </k>

    rule <k> #SvError    ~> _Msg:String => .K ... </k>
    rule <k> #SvInfo     ~> _Msg:String => .K ... </k>
    rule <k> #SvWarning  ~> _Msg:String => .K ... </k>
    rule <k> #SvVerbatim ~> _Msg:String ~> _:ArrayAttr => .K ... </k>
endmodule



module SV-TASK
    imports SV-SYNTAX

    rule <k> "sv.finish" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types ) 
            => #SvFinish ~> Attr["verbosity"]
            ...
        </k>

    rule <k> "sv.exit" ( .ValueIdList ) { .Map } : ( .Types ) -> ( .Types )
            => #SvExit
            ...
        </k>

    rule <k> "sv.fatal" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => #SvFatal ~> Attr["verbosity"]
            ...
        </k>

    rule <k> #SvFinish ~> _Verbosity:Int : _:IntegerType => .K ... </k>
    rule <k> #SvExit => .K ... </k>
    rule <k> #SvFatal ~> _Verbosity:Int : _:IntegerType => .K ... </k>
endmodule


module SV-ASSERT
    imports SV-SYNTAX

    // sv.assert
    rule <k> "sv.assert" ( Cond:ValueId ) { Attr:Map } : ( i1 ) -> ( .Types ) 
            => Cond ~> #SvAssert ~> Attr["defer"] orDefault "???"
            ... 
        </k>
    
    rule <k> bits(1, 1) : i1 ~> #SvAssert ~> 0 : i32 => .K ... </k>
endmodule


module SV
    imports SV-MSG
    imports SV-TASK
    imports SV-INITIAL
    imports SV-ALWAYS
    imports SV-FOR
    imports SV-REG
    imports SV-ASSERT


    rule <k> "sv.if" ( X:ValueId ) ( R1:Region , R2:Region ) { .Map } : ( #token("i1", "SignlessIntegerType") ) -> ( .Types ) 
            => X ~> #SvIf ~> R1 ~> R2
            ...
        </k>

    // sv.if
    rule <k> B:Bits : #token("i1", "SignlessIntegerType") ~> #SvIf ~> R1:Region ~> R2:Region 
            => #if Bits2Bool(B) #then R1 #else R2 #fi
            ...
        </k>

endmodule