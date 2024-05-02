requires "../circt/common.k"
module SEQ-SYNTAX
    imports COMMON-SYNTAX
    syntax DialectType ::= "!seq.firmem" "<" Int "x" Int ">"
                         | "!seq.firmem" "<" Int "x" Int "," "mask" Int ">"
endmodule