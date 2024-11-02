requires "../circt-core.k"
module SETUP-SUMMARY
  imports CIRCT-CORE
  claim <cmd> .K </cmd>
        <prog>
            "builtin.module" ( .ValueIdList ) ( { 
                "hw.module" ( .ValueIdList ) ( { 
                    ^bb0 ( %arg0 : i8 , %arg1 : i8 , .ValueIdAndTypeList ) : 
                        %0 , .OpResults = "comb.add" ( %arg0 , %arg1 , .ValueIdList ) : ( i8 , i8 , .Types ) -> i8  
                        "hw.output" ( %0 , .ValueIdList ) : ( i8 , .Types ) -> ( .Types )  
                        .OperationList  
                        .BlockList 
                } , .Regions ) { 
                    module_type = !hw.modty < input a : i8 , input b : i8 , output res : i8 , .ModulePortList > , 
                    parameters = [ ] , 
                    result_locs = [ #loc , .AttributeValueList ] , 
                    sym_name = "Adder" , 
                    .AttributeEntryList 
                } : ( .Types ) -> ( .Types ) 
            } , .Regions ) : ( .Types ) -> ( .Types ) 
            .TopLevel 
            => .K
        </prog>
        <table>
            .Map => "Adder" |-> "hw.module" ( .List ) {
                ( "module_type" |-> !hw.modty < input a : i8 , input b : i8 , output res : i8 , .ModulePortList > )
                "parameters" |-> [ .AttributeValueList ]
                "result_locs" |-> [ #loc , .AttributeValueList ]
                ( "sym_name" |-> "Adder" ) } [ .Successors ] 
                ( { ^bb0 ( ListItem ( "%arg0" ) ListItem ( "%arg1" ) ) : 
                    ListItem ( "%0" ) = "comb.add" ( ListItem ( "%arg0" ) ListItem ( "%arg1" ) ) { .Map } : ( i8 , i8 , .Types ) -> ( i8 , .Types )  
                    "hw.output" ( ListItem ( "%0" ) ) { .Map } : ( i8 , .Types ) -> ( .Types )  .StdOps  .StdBlocks } , .StdRegions ) : ( .Types ) -> ( .Types )
        </table>
endmodule
