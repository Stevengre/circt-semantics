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
                    <local-last> .Map </local-last>
                    <module> @_:SymbolRefId </module>
                </circt-frame>
            </circt-frames>
            <registers> .Map </registers>
            <macros> .Map </macros>
            <result> .List </result>
            <always> .Map </always>
            <initial> .Map </initial>
            <initalized> .Set </initialized>
        </circt>
        <mlir/>
endmodule