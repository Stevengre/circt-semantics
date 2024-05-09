requires "dialects/hw/hw.k"
requires "dialects/seq.k"
requires "circt/common.k"
module CIRCT-SYNTAX
    imports HW-SYNTAX
    imports SEQ-SYNTAX
endmodule

module CIRCT
    imports CIRCT-SYNTAX
    imports COMMON
    imports HW
    imports SEQ
endmodule