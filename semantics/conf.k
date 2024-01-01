requires "mlir.k"

module CONFIGURATION
    imports MLIR-SYNTAX
    imports LIST
    imports SET
    imports CTRL

    configuration
    <T>
        <k> mlir </k>
        <mlir>
            <mlir-program> $PGM:TopLevel ~> .K </mlir-program>
            // <standard-ops> .OperationList </standard-ops>
            <attr-alias> .Map </attr-alias> // key: AttributeAlias; value: AttributeValue
            <type-alias> .Map </type-alias> // key: TypeAlias; value: Type
            <symbol-table> .Map </symbol-table>
        </mlir>
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
            <trace> .List </trace>
            <observation>
                <ob-in> .Map </ob-in>
                <ob-out> .Map </ob-out>
            </observation>
        </circt>
    </T>
endmodule