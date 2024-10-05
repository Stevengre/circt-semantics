requires "../../circt/circt.k"

module SEQ-SYNTAX
    imports CIRCT-SYNTAX

    // syntax DialectType ::= SEQFirmemType | SEQClockType
    syntax SeqFirmemType ::= "!seq.firmem" "<" Int "x" Int ">"
                           | "!seq.firmem" "<" Int "x" Int "," "mask" Int ">"

    syntax SeqClockType ::= "!seq.clock"

    syntax Type ::= SeqClockType
                  | SeqFirmemType

    // seq.firreg("name", %clk, %rst, %rst_value, value)
    syntax SeqFirreg ::= "seq.firreg" "(" String "," Bool "," Value ")"
    
    syntax Value ::= SeqFirreg

    syntax KmdCIRCT ::= "#SeqFirreg"

endmodule


module SEQ
    imports SEQ-SYNTAX

    // ---------------- bootstrap phase --------------------

    rule <k> X:ValueId = "seq.firreg" ( Vs:ValueIdList ) { Attr:Map } : ( Ts:Types ) -> ( T:Type ) => .K ... </k>
        <locals> Locals:Map => Locals [ X <- "seq.firreg" ( Vs ) { Attr } : ( Ts ) -> ( T ) ] </locals>
        <regs> Regs:Map => Regs [ X <- seq.firreg({Attr["name"]}:>String, false, #x) ] </regs>
        <cmd> #bootstrap ... </cmd>

    // rule <k> X:ValueId = "sv.reg" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < T:Type > ) => .K ... </k>
    //     <regs> Regs:Map => Regs [ X <- hw.inout({Attr["name"]}:>String , T , #x) ] </regs>
    //     <locals> Locals:Map => Locals [ X <- "sv.reg" ( .ValueIdList ) { Attr } : ( .Types ) -> ( !hw.inout < T > ) ] </locals>
    //     <cmd> #bootstrap ... </cmd>

    
    // ----------------- clock phase ------------------

    // rule <k> "seq.firreg" ( Vs:ValueIdList ) { _:Map } : ( _:Types ) -> ( _:Type ) 
    //         => #SeqFirreg
    //         ...
    //     </k>
    
    // rule <k> </k>
endmodule