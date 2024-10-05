requires "./mlir-syntax.k"

module MLIR-CONF
    imports MLIR-SYNTAX

    syntax PhaseControl ::= "#preprocess" 
                          | "#build"
                          | "#end"
                          | "#toStimulate"
                          | "#stimulating"

    configuration
    <mlir>
        <prog> $PGM:TopLevel ~> .K </prog>
        <phase> #preprocess </phase>
        <types> .Map </types>
        <attrs> .Map </attrs>
        <table> .Map </table>
    </mlir>
endmodule