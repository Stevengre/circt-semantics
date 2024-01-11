requires "circt.k"

module CIRCT-PREPROCESS
    imports CIRCT-SYNTAX

    rule <k> (.K => preprocess-1 ~> Ops) ~> preprocess ... </k>
        <standard-ops> Ops:OperationList </standard-ops>

    rule <k> (.K => preprocess-2 ~> Op) 
            ~> preprocess-1 
            ~> (Op:Operation Ops:OperationList => Ops)
            ...
        </k> 
    
    rule <k> (preprocess-1 ~> preprocess) => circt ... </k>
    
    rule <k> preprocess-1 ~> (.OperationList => .K) ... </k>
    
    rule <k> (preprocess-2 => .K) ~> preprocess-1 ... </k>
    
    rule <k> preprocess-2 
            ~> (
                .OpResults = "builtin.module" ( .VarList ) [ .Successors ] ( Rs:Regions ) { Attr:Map } : FT:FunctionType
                => "builtin.module" ( .VarList ) ( Rs ) { Attr } : FT
            )
            ...
        </k>
    
    rule <k> (.K => preprocess-3 ~> R) 
            ~> preprocess-2 
            ~> "builtin.module" ( .VarList ) ( (R:Region, Rs:Regions => Rs) ) {_:Map} : _:FunctionType
            ...
        </k>
    
    rule <k> preprocess-2 
            ~> ("builtin.module" ( .VarList ) ( .Regions ) {_:Map} : _:FunctionType => .K)
            ...
        </k>
    
    rule <k> (preprocess-3 => .K) ~> preprocess-2 ... </k>
    
    rule <k> preprocess-3 
            ~> (.K => Op)
            ~> { (Op:Operation Ops:OperationList => Ops) _:BlockList } 
            ...
        </k>
    
    rule <k>
            preprocess-3 
            ~> ({ .OperationList .BlockList } => .K )
            ...
        </k>
    
    rule <k> preprocess-3 ~>
            (
                .OpResults = "sv.verbatim" ( .VarList ) [ .Successors ] ( .Regions ) { _:Map } : _:FunctionType
                => .
            ) ...
        </k>
    
    rule <k> (.K => M[#token("cond", "BareId")] orDefault stop) ~>
            preprocess-3 ~>
            (
                .OpResults = "sv.ifdef" ( .VarList ) [ .Successors ] ( Rs:Regions ) { M:Map } : FT:FunctionType
                => "sv.ifdef" ( .VarList ) ( Rs ) { M } : FT
            )
            ...
        </k>
    
    rule <k> (B:Bool => .K) ~> 
            preprocess-3 ~> 
            (
                "sv.ifdef" ( .VarList ) ( R1:Region, R2:Region, .Regions ) { _:Map } : _:FunctionType
                => #if B #then R1 #else R2 #fi
            )
            ...
        </k>


    // rule <k> _:DialectAttribute => stop 1 ... </k>
    rule <k> 
            (#token("#sv", "AttributeAlias") < _:BareId S:StringLiteral >):DialectAttribute 
                => S in_keys(M)
            ... 
        </k>
        <macros> M:Map </macros>

    rule <k>
            preprocess-3 ~>
            (
                .OpResults = "hw.module" ( .VarList ) [ .Successors ] ( Rs:Regions ) { Attr:Map } : FT:FunctionType
                => "hw.module" ( .VarList ) ( Rs ) { Attr } : FT
            )
            ...
        </k>
    
    rule <k>
            preprocess-3 ~>
            (
                "hw.module" ( _:VarList ) ( _:Regions ) { _:Map } : _:FunctionType => .K
            )
            ...
        </k>
    
    rule <k> 
            preprocess-3 ~> 
            (
                .OpResults = "sv.macro.decl" ( .VarList ) [ .Successors ] ( .Regions ) { Attr:Map } : ( .Types ) -> ( .Types )
                => .K
            )
            ...
        </k>
        <macros> M:Map => M [ Attr [#token("sym_name", "BareId")] <- "" ] </macros>

endmodule