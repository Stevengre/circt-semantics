requires "./dialects/comb/comb.k"
requires "./dialects/hw/hw.k"
requires "./dialects/sv/sv.k"
requires "./dialects/seq/seq.k"

module MAIN-SYNTAX
    imports SV-SYNTAX
    imports CIRCT-SYNTAX
    imports COMB-SYNTAX
    imports HW-SYNTAX
    imports SEQ-SYNTAX
    
    // syntax HWParamDecl ::= "#hw.param.decl" "<" StringAttr ">"
    //                     |  "#hw.param.decl" "<" StringAttr "=" AttributeValue ">"
    // syntax HWParamDeclWithType ::= HWParamDecl ":" Type
    // syntax Type ::= "none"
    // // syntax AttributeValue ::= AttributeValue " : " Type [owise]

    // syntax DialectAttribute ::= HWParamDecl | HWParamDeclWithType
endmodule

module MAIN
    imports SV
    imports CIRCT
    imports COMB
    imports HW
    imports SEQ
endmodule