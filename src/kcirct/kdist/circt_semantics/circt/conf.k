requires "./circt.k"

module CONF
    imports INT
    imports STRING
    imports LIST
    imports CIRCT-SYNTAX-CORE

    configuration
    <circt> 
        <mlir/> 
        <cmd> .K </cmd>
        // <entry> $Entry:String </entry>
        // <input> ListItem(bits ( 1 , 8 ) : i8) </input>
        // <input> $Input:List </input>
        <entry> "":String </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt multiplicity="*" type="Map">
                <cid> "" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                // <curr> .Map </curr>
                <locals> .Map </locals>
                <module> "" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> .List </out-ports>
                <out-vars> .ValueIdList </out-vars>
                <args> .List </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
                // <hw/>
            </ckt>
        </ckts>
        // <hw-g/>
        <exit>
          <exit-code exit=""> 0 </exit-code>
          <exit-info> "Success" </exit-info>
        </exit>
    </circt>
endmodule