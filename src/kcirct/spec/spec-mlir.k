requires "../src/mlir/mlir.k"

module SPEC-MLIR-SYNTAX
    syntax BareId ::= "value" [token]
                    | "name" [token]
                    | "res" [token]
                    | "parameters" [token]
    
    syntax AttributeAlias ::= "#loc" [token]
                            | "#loc1" [token]
endmodule

module VERIFICATION
    imports K-EQUAL
    imports SPEC-MLIR-SYNTAX
    imports MLIR

    // rule { M:Map [ K <- V ] #Equals M [ K <- V' ] } => { V #Equals V' } [simplification]
endmodule

module SPEC-MLIR
    imports VERIFICATION

    claim <prog> #loc = loc ( "tests/a.mlir" : 1 : 24 ) => .TopLevel </prog>
        <phase> #preprocess </phase>
        <attrs> _ => ?_ </attrs>
endmodule