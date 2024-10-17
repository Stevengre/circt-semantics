requires "mlir/mlir-syntax.md"
requires "dialects/comb/comb-syntax.md"
requires "dialects/hw/hw-syntax.md"
requires "dialects/seq/seq-syntax.md"
requires "dialects/sv/sv-syntax.md"

module TEST-SYNTAX-SYNTAX
    imports MLIR-SYNTAX
    imports HW-SYNTAX
    imports COMB-SYNTAX
    imports SEQ-SYNTAX
    imports SV-SYNTAX
endmodule

module TEST-SYNTAX
    imports TEST-SYNTAX-SYNTAX
configuration
<prog> $PGM:TopLevel ~> .K </prog>
endmodule