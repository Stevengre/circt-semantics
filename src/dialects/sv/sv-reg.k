requires "./sv.k"
requires "../hw/hw-inout.k"

module SV-REG-SYNTAX
    imports SV-SYNTAX
    imports HW-INOUT-SYNTAX
endmodule


module SV-REG
    imports SV-REG-SYNTAX

    rule <k> X:ValueId = "sv.reg" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < T:Type > ) => .K ... </k>
        <regs> Regs:Map => Regs [ X <- hw.inout({Attr["name"]}:>String , T , #x) ] </regs>
        <locals> Locals:Map => Locals [ X <- "sv.reg" ( .ValueIdList ) { Attr } : ( .Types ) -> ( !hw.inout < T > ) ] </locals>
        <cmd> #bootstrap ... </cmd>


    rule <k> "sv.read_inout" ( X:ValueId ) { .Map } : ( !hw.inout < T:Type > ) -> ( T:Type ) => V ... </k>
        <regs> ... X |-> hw.inout ( "reg" , T , V ) ... </regs>

    
    rule <k>
            "sv.passign" ( Dst:ValueId , Src:ValueId ) { .Map } : ( !hw.inout < T:Type > , T:Type ) -> ( .Types ) 
            => Src ~> #SvPassign ~> Dst
            ...
        </k>

    // sv.passign
    rule <k> V:StdValue ~> #SvPassign ~> Dst:ValueId => .K ... </k>
        <regs> ... Dst |-> hw.inout ( "reg" , i8 , _ => V ) ... </regs>
endmodule