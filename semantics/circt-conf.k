requires "mlir.k"

module CIRCT-CONFIGURATION
    imports MLIR

    configuration
        <k/>
        <circt>
            <circt-control> $Control:K </circt-control>
            <circt-frames>
                <circt-frame multiplicity="*" type="List">
                    <circt-exec> .K </circt-exec>
                    <circt-locals> .Map </circt-locals>
                    <circt-output> .Map </circt-output>
                    <always>.Map</always>
                    <local-last>.Map</local-last>
                </circt-frame>
            </circt-frames>
            <registers> .Map </registers>
            <macros>.Map</macros>
        </circt>
        <mlir/>
endmodule