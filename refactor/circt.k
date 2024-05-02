requires "dialects/hw.k"
requires "dialects/seq.k"
module CIRCT-SYNTAX
    imports HW-SYNTAX
    imports SEQ-SYNTAX
endmodule

module CIRCT
    imports CIRCT-SYNTAX
    configuration <k> $PGM:TopLevel </k>
endmodule