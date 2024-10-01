requires "./common.k"
requires "./conf.k"
requires "../dialects/hw/hw-inout.k"

module CIRCT-SYNTAX-CORE
    imports MLIR
    imports COMMON-SYNTAX
endmodule


module CIRCT-CONF
    imports CONF
endmodule

module CIRCT-SYNTAX
    imports CIRCT-CONF
endmodule


module CIRCT
    imports COMMON
    imports CIRCT-SYNTAX
endmodule