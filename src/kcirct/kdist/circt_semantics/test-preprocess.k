requires "mlir/mlir-syntax.md"
requires "dialects/comb/comb-syntax.md"
requires "dialects/hw/hw-syntax.md"
requires "dialects/seq/seq-syntax.md"
requires "dialects/sv/sv-syntax.md"
requires "mlir/mlir.md"

module TEST-PREPROCESS-SYNTAX
    imports MLIR-SYNTAX
    imports HW-SYNTAX
    imports COMB-SYNTAX
    imports SEQ-SYNTAX
    imports SV-SYNTAX
endmodule

module TEST-PREPROCESS
    imports TEST-PREPROCESS-SYNTAX
    imports MLIR
endmodule