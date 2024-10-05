requires "./dialects/comb/comb.k"
requires "./dialects/hw/hw.k"
requires "./dialects/sv/sv.k"
requires "./dialects/seq/seq.k"

module CORE-SYNTAX
    imports SV-SYNTAX
    imports CIRCT-SYNTAX
    imports COMB-SYNTAX
    imports HW-SYNTAX
    imports SEQ-SYNTAX
endmodule

module CORE
    imports SV
    imports CIRCT
    imports COMB
    imports HW
    imports SEQ
endmodule