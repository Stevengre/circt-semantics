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

    claim <prog>
            "builtin.module" ( .ValueIdList ) ( { 
                "hw.module" ( .ValueIdList ) ( { 
                    .OperationList 
                    ^bb0 ( %arg0 : i8 , %arg1 : i8 , .ValueIdAndTypeList ) : 
                        %0 , .OpResults = "comb.add" ( %arg0 , %arg1 , .ValueIdList ) : ( i8 , i8 , .Types ) -> i8  
                        "hw.output" ( %0 , .ValueIdList ) : ( i8 , .Types ) -> ( .Types )  
                        .OperationList  
                        .BlockList 
                } , .Regions ) { 
                    module_type = !hw.modty < input a : i8 , input b : i8 , output res : i8 , .ModulePortList > , 
                    parameters = [ ] , 
                    result_locs = [ #loc , .AttributeValueList ] , 
                    sym_name = "Foo" , 
                    .AttributeEntryList 
                } : ( .Types ) -> ( .Types )  
                .OperationList .BlockList 
            } , .Regions ) : ( .Types ) -> ( .Types ) 
            .TopLevel 
            ~> .K
        </prog>
        <phase> #preprocess </phase>
        <attrs> _ => ?_ </attrs>
endmodule