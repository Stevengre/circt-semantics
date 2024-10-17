requires "./builtin.k"
requires "./mlir-helper.k"
requires "./mlir-conf.k"
requires "./mlir-syntax.k"


module MLIR-PREPROCESS
    imports MLIR-SYNTAX
    imports MLIR-HELPER
    imports MLIR-CONF
    imports BOOL

    rule <phase> #preprocess </phase>
        <prog> Alias:AttributeAlias = Attr:AttributeValue T:TopLevel => T </prog>
        <attrs> M:Map => M [Alias <- Attr] </attrs>
    
    rule <phase> #preprocess </phase>
        <prog> Alias:TypeAlias = T:Type P:TopLevel => P </prog>
        <types> M:Map => M [Alias <- T] </types>

    rule <phase> #preprocess </phase>
        <prog> Op:Operation T:TopLevel => stdizeOp(Op) ~> T </prog>

    rule <phase> #preprocess </phase>
        <prog> .TopLevel => .K ... </prog>


    // ---------------- find sym_name ----------------
    rule <phase> #preprocess </phase>
        <prog> "builtin.module" ( .ValueIdList ) ( Rs:Regions ) : ( .Types ) -> ( .Types ) => Rs ... </prog>

    rule <phase> #preprocess </phase>
        <prog> R:Region, Rs:Regions => R ~> Rs ... </prog>
    
    rule <phase> #preprocess </phase>
        <prog> .Regions => .K ... </prog>
    
    rule <phase> #preprocess </phase>
        <prog> { OL:OperationList BL:BlockList } => OL ~> BL ... </prog>

    rule <phase> #preprocess </phase>
        <prog> Op:Operation OL:OperationList => Op ~> OL ... </prog>

    rule <phase> #preprocess </phase>
        <prog> .OperationList => .K ... </prog>


    rule <phase> #preprocess </phase>
        <prog> Op:String (VL:ValueIdList) (Rs:Regions) {Attr:Map} : FT:FunctionType => Rs ... </prog>
        <table> 
            M:Map => #if "sym_name" in_keys(Attr) 
            #then M [ Attr["sym_name"] <- Op (VL) (Rs) {Attr} : FT ] 
            #else M #fi
        </table>

    rule <phase> #preprocess </phase>
        <prog> _:OpResults = _:String (_:ValueIdList) {Attr:Map} : _:FunctionType => .K ... </prog>
        requires notBool "sym_name" in_keys(Attr)


    rule <phase> #preprocess </phase>
        <prog> _:OpResults = _:String (_:ValueIdList) : _:FunctionType => .K ... </prog>
   
    rule <phase> #preprocess </phase>
        <prog> _:String (_:ValueIdList) (Rs:Regions) : _:FunctionType => Rs ... </prog>

    rule <phase> #preprocess </phase>
        <prog> _:String (_:ValueIdList) : _:FunctionType => .K ... </prog>

    rule <phase> #preprocess </phase>
        <prog> _:String (_:ValueIdList) {_:Map} : _:FunctionType => .K ... </prog>


    rule <phase> #preprocess </phase>
        <prog> B:Block BL:BlockList => B ~> BL ... </prog>
    
    rule <phase> #preprocess </phase>
        <prog> .BlockList => .K ... </prog>
    
    rule <phase> #preprocess </phase>
        <prog> _:BlockLabel OL:OperationList => OL ... </prog>
endmodule



module MLIR
    imports MLIR-PREPROCESS
    imports BUILTIN
       
    // Assign Aliases
    

    // rule <phase> #preprocess </phase>
    //     <prog> Op:Operation => .K ... </prog>
    //     <table> M:Map => M GetSymbolTable(Op, .List) </table>
    //     requires getOpAttr(Op, "sym_name") =/=K #undefined
    
    // rule <phase> #preprocess </phase>
    //     <prog> Op:Operation => .K ... </prog>
    //     <table> M:Map => M GetSymbolTable(getRegions(Op), ListItem(getOpAttr(Op, "sym_name"))) </table>
    //     requires getOpName(Op) ==K "builtin.module"

    // Canonicalize Operations
    // rule <phase> #preprocess => #canonicalized </phase>
    //     <prog> Op:Operation P:TopLevel => Canonicalize(Op) P </prog>

    // Construct Symbol Table
    // rule <phase> #canonicalized => #preprocess </phase>
    //     <prog> Op:Operation P:TopLevel => P </prog>
    //     <table> M:Map => M GetSymbolTable(Op, .List) </table>
    //     requires getAttr(Op, "sym_name") =/=K #undefined
    
    // builtin.module
    // rule <phase> #canonicalized => #preprocess </phase>
    //     <prog> Op:Operation P:TopLevel => P </prog>
    //     <table> M:Map => M GetSymbolTable(getRegions(Op), ListItem(getAttr(Op, "sym_name"))) </table>
    //     requires getOpName(Op) ==K "builtin.module"

    // rule <phase> #preprocess </phase>
    //     <prog> "builtin.module" (.ValueIdList) ( Rs:Regions ) : (.Types) -> (.Types) => Rs ... </prog>

    // rule <phase> #preprocess </phase>
    //     <prog> R:Region, Rs:Regions => R ~> Rs ... </prog>

    // rule <phase> #preprocess </phase>
    //     <prog> { Op:Operation .BlockList } => Op ... </prog>

    
endmodule
