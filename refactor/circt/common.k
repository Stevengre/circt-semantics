requires "../dialects/builtin.k"
requires "../mlir.k"
module COMMON-SYNTAX
    imports BUILTIN-SYNTAX
endmodule

module COMMON
    imports MLIR
    imports BUILTIN
    configuration <mlir/>
endmodule