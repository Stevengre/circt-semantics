requires "mlir.k"

module CONFIGURATION
    imports MLIR-SYNTAX
    imports LIST
    imports SET
    imports CTRL

    configuration
    <T>
        <k> mlir </k>
        <circt>
            <circt-control> $Control:K </circt-control>
            <circt-frames>
                <circt-frame multiplicity="*" type="List">
                    <circt-exec> .K </circt-exec>
                    <circt-locals> .Map </circt-locals>
                    <circt-output> .List </circt-output>
                    <last-locals> .Map </last-locals>
                    <name> "_" </name>
                    <ports-in> .List </ports-in>
                    <ports-out> .List </ports-out>
                    <module> #token("@_", "SymbolRefId") </module>
                    <forced> .Map </forced>
                </circt-frame>
            </circt-frames>
            <state>
                <instance multiplicity="*" type="Map">
                    <inst-name> "" </inst-name>
                    <inst-vars> .Map </inst-vars>
                    <inst-in> .Map </inst-in>
                    <inst-out> .Map </inst-out>
                    <inst-regs> .Map </inst-regs>
                    <inst-wires> .Map </inst-wires>
                </instance>
            </state>
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
            <sv-log>
                <sv-error> .List </sv-error>
                <sv-warn> .List </sv-warn>
                <sv-info> .List </sv-info>
                <sv-fatal> .List </sv-fatal>
                <sv-verbatim> .List </sv-verbatim>
            </sv-log>
            <hw-hierpath> .Map </hw-hierpath>
            <fd> .Map </fd>
            <symrefs> .Map </symrefs>
        </circt>
        <mlir>
            <mlir-program> $PGM:TopLevel ~> .K </mlir-program>
            <attr-alias> .Map </attr-alias> // key: AttributeAlias; value: AttributeValue
            <type-alias> .Map </type-alias> // key: TypeAlias; value: Type
            <symbol-table> .Map </symbol-table>
        </mlir>
    </T>
endmodule