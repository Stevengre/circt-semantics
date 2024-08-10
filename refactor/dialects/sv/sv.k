requires "../../circt/circt.k"
requires "./sv-always.k"

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



module SV
    imports SV-MSG
    imports SV-TASK
    imports SV-INITIAL
    imports SV-ALWAYS

    rule <k> "sv.if" ( X:ValueId ) ( R1:Region , R2:Region ) { .Map } : ( #token("i1", "SignlessIntegerType") ) -> ( .Types ) 
            => X ~> #SvIf ~> R1 ~> R2
            ...
        </k>

    rule <k> "sv.for" ( Vs:ValueIdList ) ( R:Region ) { _:Map } : ( _:Type, _:Type, _:Type ) -> ( .Types ) 
            => Vs ~> #SvFor ~> R
            ...
        </k>


    // sv.if
    rule <k> B:Bits : #token("i1", "SignlessIntegerType") ~> #SvIf ~> R1:Region ~> R2:Region 
            => #if Bits2Bool(B) #then R1 #else R2 #fi
            ...
        </k>

    // sv.for
    rule <k> 
            ListItem(bits(Start:Int, _:Int) :  _:Type) ListItem(bits(End:Int, _:Int) :  _:Type) ListItem(bits(Step:Int, _:Int) :  _:Type)
            ~> #SvFor ~> R:Region
            => Start ~> End ~> Step ~> #SvFor ~> R:Region
            ...
        </k>

    rule <k> (.K => R)
            ~> (Start:Int => Start +Int Step) ~> End:Int ~> Step:Int 
            ~> #SvFor ~> R:Region 
            ... 
        </k>
        requires Start <Int End
endmodule