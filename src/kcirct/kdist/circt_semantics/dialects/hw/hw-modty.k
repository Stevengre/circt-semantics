requires "../../circt/circt.k"

module HW-MODTY-SYNTAX
    imports CIRCT-SYNTAX

    syntax DialectType ::= "!hw.modty" "<" ModulePortList ">"

    syntax ModulePortList ::= List{ModulePort, ","}
    syntax ModulePort ::= "input" BareIdAndType
                        | "output" BareIdAndType
endmodule


module HW-MODTY
    imports HW-MODTY-SYNTAX
endmodule