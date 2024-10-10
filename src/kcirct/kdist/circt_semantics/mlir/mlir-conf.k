requires "./mlir-syntax.k"

module MLIR-CONF
    imports MLIR-SYNTAX

    syntax PhaseControl ::= "#preprocess" 
                          | "#build"
                          | "#toStimulate"
                          | "#stimulating"
                          | "#phaseStop"

    configuration
    <mlir>
        <prog> $PGM:TopLevel ~> .K </prog>
        <phase> #preprocess ~> .K </phase>
        <types> .Map </types>
        <attrs> .Map </attrs>
        <table> .Map </table>
    </mlir>
endmodule