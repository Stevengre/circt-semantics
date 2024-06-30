requires "../circt/common.k"

module SEQ-SYNTAX
    imports COMMON-SYNTAX
    syntax DialectType ::= SEQFirmemType | SEQClockType
    syntax SEQFirmemType ::= "!seq.firmem" "<" Int "x" Int ">"
                         | "!seq.firmem" "<" Int "x" Int "," "mask" Int ">"
    syntax SEQClockType ::= "!seq.clock"

endmodule

module SEQ
    imports COMMON
    imports SEQ-SYNTAX
    
    // # Get Bit Size of Types
    rule Type2BitSize(!seq.clock) => 1
endmodule