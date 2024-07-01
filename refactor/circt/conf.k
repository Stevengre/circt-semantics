requires "./circt.k"

module CONF
    imports INT
    imports STRING
    imports LIST
    imports CIRCT-SYNTAX

    configuration
    <circt> 
        <mlir/> 
        <cmd> .K </cmd>
        <entry> #token("@Foo", "SymbolRefId") </entry>
        <input> ListItem(bits ( 1 , 8 ) : i8) </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt multiplicity="*" type="Map">
                <cid> "" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> .K </k>
                // <ks> 
                //     <kmap multiplicity="*" type="Map"> 
                //         <kkey> 0:Int </kkey>
                //         <k> .K </k>
                //     </kmap> 
                // </ks>
                <circuit> .K </circuit>
                <parent> "" </parent>
                <last> .Map </last>
                <curr> .Map </curr>
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