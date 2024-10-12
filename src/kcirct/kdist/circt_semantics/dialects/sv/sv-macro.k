requires "./sv.k"

module SV-MACRO
    imports SV-SYNTAX

    rule <phase> #preprocess </phase>
        <prog> "sv.macro.decl"(.ValueIdList) {Attr:Map} : (.Types) -> (.Types) => .K ... </prog>
        <macro> M:Map => M [Attr["sym_name"] <- 1] </macro>
        requires "sym_name" in_keys(Attr)
        [priority(40)]

    
    rule <k> "sv.ifdef" (.ValueIdList) (R1:Region, R2:Region) {Attr:Map} : (.Types) -> (.Types) 
            => Attr["cond"] orDefault "??? no `cond` attr" ~> #SvIfDef ~> R1 ~> R2
            ...
        </k>
        <cmd> #bootstrap ... </cmd>
    
    
    rule <k> #sv < macro.ident Macro:SymbolRefId > 
            => M[str(Macro)] orDefault "??? no macro: " +String str(Macro) 
            ... 
        </k>
        <macro> M:Map </macro>


    rule <k> 1 ~> #SvIfDef ~> R1:Region ~> _R2:Region => R1 ... </k>
        
endmodule