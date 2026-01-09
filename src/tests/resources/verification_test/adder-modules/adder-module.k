requires "/home/zjh/proj/cym-circt-semantics/src/kcirct/kdist/circt_semantics/circt-core.k"
module ADDER-MODULE
    imports CIRCT-CORE
    
    claim [id]:
        <teq>
            <hardware>
                <setup>
                .K
                </setup>
                <connection>
                    "Foo/%0" |-> "comb.add" (  "Foo/%arg0" 
                    "Foo/%arg1"  ) { .Map } : (( i8 , i8 ) -> ( i8))
                </connection>
                <procedures>
                    .List
                </procedures>
                <register>
                    .Map
                </register>
                <register-proc>
                    .Map
                </register-proc>
                <signals>
                    ("Foo/%0" |-> bits ( 25 , 8 )
                    "Foo/%arg0" |-> bits ( 17 , 8 )
                    "Foo/%arg1" |-> bits ( 8 , 8 )) => 
                    ("Foo/%0" |-> bits ( A +Int B , 8 )
                    "Foo/%arg0" |-> bits ( A , 8 )
                    "Foo/%arg1" |-> bits ( B , 8 ))
                </signals>
                <history>
                    .Map
                </history>
                <currents>
                    .CurrentInfoCellMap
                </currents>
                <clock>
                    0
                </clock>
            </hardware>
            <circt>
                <cmd>
                   ("CIRCT#SIMULATE" ~> ListItem ( bits ( A:Int , 8 ) )
                    ListItem ( bits ( B:Int , 8 ) ) ~> .K) => .K
                </cmd>
                <top-module>
                    "Foo"
                </top-module>
                <top-ins>
                    ListItem ( "Foo/%arg0" )
                    ListItem ( "Foo/%arg1" )
                </top-ins>
            </circt>
            <hw>
                <hw-instances>
                    <hw-instance>
                    <hw-id>
                        "Foo"
                    </hw-id>
                    <hw-module>
                        "Foo"
                    </hw-module>
                    <hw-inputs>
                        ListItem ( a )
                        ListItem ( b )
                    </hw-inputs>
                    <hw-inports>
                        ListItem ( "Foo/%arg0" )
                        ListItem ( "Foo/%arg1" )
                    </hw-inports>
                    <hw-in-types>
                        ListItem ( i8 )
                        ListItem ( i8 )
                    </hw-in-types>
                    <hw-outputs>
                        ListItem ( res )
                    </hw-outputs>
                    <hw-outports>
                        ListItem ( "Foo/%0" )
                    </hw-outports>
                    <hw-out-types>
                        ListItem ( i8 )
                    </hw-out-types>
                    </hw-instance>
                    <hw-setup-inst>
                        .List
                    </hw-setup-inst>
                </hw-instances>
            </hw>
        </teq>
        requires (A +Int B) <Int 256
endmodule