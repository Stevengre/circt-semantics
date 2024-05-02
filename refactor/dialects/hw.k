requires "../circt/common.k"
module HW-SYNTAX
    imports COMMON-SYNTAX
    syntax DialectType ::= "!hw.modty" "<" ModulePortList ">"
    syntax ModulePortList ::= List{ModulePort, ","}
    syntax ModulePort ::= "input" BareId ":" Type
                        | "output" BareId ":" Type
    
    syntax DialectType ::= "!hw.array" "<" ArraySizePrefix Type ">"
endmodule