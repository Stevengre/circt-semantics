requires "../../circt/circt.k"
requires "./seq-firreg.k"
requires "./seq-firmem.k"


module SEQ-SYNTAX
    imports CIRCT-SYNTAX

    // syntax DialectType ::= SEQFirmemType | SEQClockType
    syntax SeqFirmemType ::= "!seq.firmem" "<" Int "x" Int ">"
                           | "!seq.firmem" "<" Int "x" Int "," "mask" Int ">"

    syntax SeqClockType ::= "!seq.clock"

    rule getWidth(_:SeqClockType) => 1

    syntax Type ::= SeqClockType
                  | SeqFirmemType

    // seq.firreg("name", %clk, %rst, %rst_value, value)
    syntax SeqFirreg ::= "seq.firreg" "(" String "," Type "," Value ")"
                       | "seq.firreg" "(" ValueId ")"
    
    syntax Value ::= SeqFirreg

    syntax KmdCIRCT ::= "#SeqFirreg"
                      | "#SeqFirmemRead"
                      | "#SeqFirmemWrite"
                      | "#SeqFirmemReadWrite"

endmodule



module SEQ
    imports SEQ-FIRREG
    imports SEQ-FIRREM
    
    // seq.from_clock
    rule <k> "seq.from_clock" ( X:ValueId ) : ( !seq.clock ) -> ( i1 ) => X ... </k>
endmodule
