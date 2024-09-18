requires "../../circt/circt.k"

module HW-INOUT-SYNTAX
    imports CIRCT-SYNTAX

    syntax HwInOutType ::= "!hw.inout" "<" Type ">"
    syntax Type ::= HwInOutType

    syntax HwInOut ::= "hw.inout" "(" String "," Type "," Value ")"
    syntax Value ::= HwInOut
endmodule


module HW-INOUT
    imports HW-INOUT-SYNTAX
endmodule

