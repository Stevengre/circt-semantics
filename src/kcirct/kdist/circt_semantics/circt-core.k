requires "mlir/mlir-syntax.md"
requires "mlir/mlir-config.md"
requires "mlir/mlir.md"
requires "hardware/hardware-config.md"
requires "hardware/hardware.md"
requires "circt/circt-config.md"
requires "circt/circt.md"
requires "dialects/comb/comb-syntax.md"
requires "dialects/hw/hw-syntax.md"
requires "dialects/hw/hw-config.md"
requires "dialects/hw/hw.md"
requires "dialects/seq/seq-syntax.md"
requires "dialects/sv/sv-syntax.md"

module CIRCT-CORE-SYNTAX
    imports MLIR-SYNTAX
    imports HW-SYNTAX
    imports COMB-SYNTAX
    imports SEQ-SYNTAX
    imports SV-SYNTAX
endmodule

module CIRCT-CORE-CONFIG
    imports MLIR-CONFIG
    imports HARDWARE-CONFIG
    imports CIRCT-CONFIG
    imports HW-CONFIG
configuration
<teq>
    <mlir/>
    <hardware/>
    <circt/>
    <hw/>
</teq>
endmodule

module CIRCT-CORE
    imports CIRCT-CORE-SYNTAX
    imports CIRCT-CORE-CONFIG
    imports MLIR
    imports HARDWARE
    imports CIRCT
    imports HW



endmodule
