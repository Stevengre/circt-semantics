requires "../circt-core.k"
module SIMULATE-SUMMARY
  imports CIRCT-CORE
  claim 
  <prog> .K </prog>
  <types> .Map </types>
  <attrs> .Map </attrs>
  <setup> .K </setup>
  <currents> .Bag </currents>
  <cmd> "CIRCT#SIMULATE" ~> ListItem(bits(Arg0:Int, 8)) ListItem(bits(Arg1:Int, 8)) => .K </cmd>
  <connection> 
    "Adder/%0" |-> "comb.add" ( ListItem ( "Adder/%arg0" ) ListItem ( "Adder/%arg1" ) ) { .Map } : _FT
  </connection>
  <procedures> .List </procedures>
  <top-module> "Adder" </top-module>
  <top-ins> ListItem ( "Adder/%arg0" ) ListItem ( "Adder/%arg1" ) </top-ins>
  <signals> PrevSignals:Map => 
      "Adder/%0" |-> bits ( Arg0:Int , 8 ) +Bits BitsCast ( bits ( Arg1 &Int (2 ^Int 8 -Int 1) , 8 ) )
      "Adder/%arg0" |-> bits ( Arg0 , 8 )
      "Adder/%arg1" |-> bits ( Arg1 , 8 )
  </signals>
  <history> _ => PrevSignals </history>
  <hw>
    <hw-instances>
        <hw-instance>
        <hw-id>
          "Adder"
        </hw-id>
        <hw-module>
          "Adder"
        </hw-module>
        <hw-inputs>
          ListItem ( _A:BareId )
          ListItem ( _B:BareId )
        </hw-inputs>
        <hw-inports>
          ListItem ( "Adder/%arg0" )
          ListItem ( "Adder/%arg1" )
        </hw-inports>
        <hw-in-types>
          ListItem ( _T0:IntegerType )
          ListItem ( _T1:IntegerType )
        </hw-in-types>
        <hw-outputs>
          ListItem ( _Res:BareId )
        </hw-outputs>
        <hw-outports>
          ListItem ( "Adder/%0" )
        </hw-outports>
        <hw-out-types>
          ListItem ( _T2:IntegerType )
        </hw-out-types>
      </hw-instance>
    <hw-setup-inst> .List </hw-setup-inst>
    </hw-instances>
  </hw>
endmodule
