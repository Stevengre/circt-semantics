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
endmodule