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

    // --- here, we change the phase control rules for partial evaluation ---

    // stop at #preprocess, and changed to #toStimulate to start hardware setup
    rule 
    <phase> #preprocess => #phaseStop ~> #toStimulate </phase>
    <prog> .K </prog>

    // bootstrap end
    rule 
    <cmd> #bootstrap => #end ~> Boot ~> #initial ... </cmd>
    <running> .List </running>
    <boot> Boot:List </boot>

endmodule