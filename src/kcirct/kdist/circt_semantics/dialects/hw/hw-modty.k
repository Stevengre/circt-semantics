module HW-MODTY-SYNTAX
    imports MLIR-SYNTAX

    syntax HwModty ::= "!hw.modty" "<" ModulePortList ">"
    
    syntax ModulePortList ::= List{ModulePort, ","}
    syntax ModulePort ::= "input" BareIdAndType
                        | "output" BareIdAndType

    syntax Type ::= HwModty
endmodule


module HW-MODTY
    imports HW-MODTY-SYNTAX

    syntax List ::= getModuleInNames(HwModty) [function]

    rule getModuleInNames(!hw.modty < input Name:BareId : _:Type , L:ModulePortList >) 
        => ListItem(Name) getModuleInNames(!hw.modty < L >)
    
    rule getModuleInNames(!hw.modty < output _:BareId : _:Type , L:ModulePortList >) 
        => getModuleInNames(!hw.modty < L >)
    
    rule getModuleInNames(!hw.modty < .ModulePortList >) => .List


    syntax List ::= getModuleOutNames(HwModty) [function]

    rule getModuleOutNames(!hw.modty < output Name:BareId : _:Type , L:ModulePortList >) 
        => ListItem(Name) getModuleOutNames(!hw.modty < L >)
    
    rule getModuleOutNames(!hw.modty < input _:BareId : _:Type , L:ModulePortList >) 
        => getModuleOutNames(!hw.modty < L >)
    
    rule getModuleOutNames(!hw.modty < .ModulePortList >) => .List
endmodule