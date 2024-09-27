requires "../src/main.k"

module SPEC-TEST-SYNTAX
    syntax BareId ::= "value" [token]
                    | "name" [token]
                    | "res" [token]
                    | "parameters" [token]
    
    syntax AttributeAlias ::= "#loc" [token]
                            | "#loc1" [token]
endmodule


module VERIFICATION
    imports K-EQUAL
    imports SPEC-TEST-SYNTAX
    imports MAIN

    // rule { M:Map [ K <- V ] #Equals M [ K <- V' ] } => { V #Equals V' } [simplification]
endmodule


module SPEC-TEST
    imports VERIFICATION

    claim
        <mlir>
            <prog> #loc = loc ( "tests/a.mlir" : 1 : 24 ) => .TopLevel </prog>
            <phase> #preprocess </phase>
            <attrs> _ => ?_ </attrs>
            <types> .Map </types>
            <table> .Map </table>
        </mlir>
        <cmd> .K </cmd>
        <entry> "Foo" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts> .Bag </ckts>

endmodule