requires "../src/mlir/mlir.k"

module SPEC-ALU-SYNTAX
    syntax BareId ::= "value" [token]
                    | "name" [token]
                    | "res" [token]
                    | "parameters" [token]
                    | "a" [token]
                    | "b" [token]
                    | "module_type" [token]
    
    syntax AttributeAlias ::= "#loc" [token]
                            | "#loc1" [token]
endmodule

module VERIFICATION
    imports K-EQUAL
    imports SPEC-ALU-SYNTAX
    imports MAIN

    // rule { M:Map [ K <- V ] #Equals M [ K <- V' ] } => { V #Equals V' } [simplification]

    rule { A:Int |Int ( B:Int |Int 0 ) #Equals A':Int |Int B':Int } => {A |Int B #Equals A' |Int B'} [simplification]
endmodule

module SPEC-ALU
    imports VERIFICATION

    claim
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "Adder" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt>
                <cid> "Adder" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %a |-> #ArgRef ( 0 )
                    %b |-> #ArgRef ( 1 )
                    %out |-> "comb.or" ( %a , %b , .ValueIdList ) : ( i8 , i8 , .Types ) -> ( i8 , .Types )
                </locals>
                <module> "Adder" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => ListItem ( bits ( ?C , 8 ) : i8 ) </out-ports>
                <out-vars> %out , .ValueIdList </out-vars>
                <args>
                    ListItem ( bits ( A:Int , 8 ) : i8 )
                    ListItem ( bits ( B:Int , 8 ) : i8 )
                </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        ensures ?C ==Int A |Int B
endmodule