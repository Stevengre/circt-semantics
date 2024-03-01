module SEQ
    imports CONFIGURATION
    imports CIRCT-SYNTAX

    // todo
    // rule <k> circt </k>
    //     <circt-exec> 
    //         "seq.firreg" ( I:Var, _:Var, _:Var, _:Var ) { _:Map } : ( _:Types ) -> ( T:Type )
    //         => ListItem( TV(T, V) )
    //         ...
    //     </circt-exec>
    //     <circt-locals>
    //         ...
    //         I |-> TV(T, V)
    //         ...
    //     </circt-locals>

    rule <k> circt </k>
        <circt-exec> 
            "seq.firreg" ( Next:Var, _Clk:Var, _Rst:Var, _RstV:Var ) { _:Map } : ( _:Types ) -> ( T:Type )
            => ListItem( {M[Next] orDefault TV(T, 0)}:>TypeValue )
            ...
        </circt-exec>
        <circt-locals> M:Map </circt-locals>
    
    rule <k> circt </k>
        <circt-exec> 
            "seq.firreg" ( Next:Var, _Clk:Var ) { _:Map } : ( _:Types ) -> ( T:Type )
            => ListItem( {M[Next] orDefault TV(T, 0)}:>TypeValue )
            ...
        </circt-exec>
        <circt-locals> M:Map </circt-locals>
endmodule