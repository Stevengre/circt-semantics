module HW-ENUM
    imports CIRCT-SYNTAX-CORE

    syntax HwEnumType ::= "!hw.enum" "<" HwEnumItems ">"
                        | "enum" "<" HwEnumItems ">"
    syntax HwEnumItems ::= List{HwEnumItem, ","}
    syntax HwEnumItem ::= BareId
    syntax Type ::= HwEnumType

    syntax HwEnum ::= "hw.enum" "(" HwEnumItem "," HwEnumType ")"
    syntax Value ::= HwEnum
endmodule