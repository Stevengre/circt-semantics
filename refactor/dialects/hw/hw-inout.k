module HW-INOUT
    imports CIRCT-SYNTAX-CORE

    syntax HwInOutType ::= "!hw.inout" "<" Type ">"
    syntax Type ::= HwInOutType

    syntax HwInOut ::= "hw.inout" "(" String "," Type "," Value ")"
    syntax Value ::= HwInOut
endmodule
