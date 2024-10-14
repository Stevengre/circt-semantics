requires "./circt.k"

module CONF
    imports INT
    imports STRING
    imports LIST
    imports SET
    imports CIRCT-SYNTAX-CORE

    configuration
    <circt> 
        <mlir/> 
        <cmd> .K </cmd>
        <entry> "":String </entry>
        <input> .List </input>
        // <entry> $Entry:String </entry>
        // <input> ListItem(ListItem(bits (1 , 8) : i8) ListItem(bits (2 , 8) : i8)) </input>
        // <input> $Input:List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <macro> .Map </macro>
        <ckts>
            <ckt multiplicity="*" type="Map">
                <cid> "" </cid>
                <always> .List </always>
                <initial> .List </initial>
                // <k> .K </k>
                <ks>
                    <k-entry multiplicity="*" type="Map">
                        <k-id> 0 </k-id>
                        <k> .K </k>
                    </k-entry>
                </ks>
                <parent> "" </parent>
                <last> .Map </last>
                <last-vars> .Set </last-vars>
                <locals> .Map </locals>
                <module> "" </module>
                <in-names> .List </in-names>
                <in-ports> .Map  </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-names> .List </out-names>
                <out-ports> .List </out-ports>
                <out-vars> .ValueIdList </out-vars>
                <args> .List </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
                <firmem> .Map </firmem>
                // <lock> false </lock>
            </ckt>
        </ckts>
        <exit>
          <exit-code exit=""> 0 </exit-code>
          <exit-info> "Success" </exit-info>
        </exit>
    </circt>
endmodule
