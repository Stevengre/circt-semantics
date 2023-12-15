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
                    <circt-output> .List </circt-output>
                    <local-last> .Map </local-last>
                    <module> #token("@_", "SymbolRefId"):SymbolRefId </module>
                    <ports> .List </ports>
                </circt-frame>
            </circt-frames>
            <registers> .Map </registers>
            <macros> .Map </macros>
            <result> .List </result>
            <always> .Map </always>
            <initial> .Map </initial>
            <initialized> .Set </initialized>
            <sv-wires> .Map </sv-wires>
        </circt>
        <mlir/>
endmodule