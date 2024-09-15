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

    rule <k> circt </k>
        <circt-exec>
            "seq.firmem" ( .VarList ) { _:Map } : ( .Types ) -> ( !seq.firmem < N:Int x W:Int >  )
            => ListItem(TV(!seq.firmem < N x W >, seq.firmem(N, W, .Map)))
            ...
        </circt-exec>

    // seq.firmem.write_port
    rule <k> circt </k>
        <circt-exec>
            "seq.firmem.write_port" ( Mem:Var, Addr:Var, _Clk:Var, _Enable:Var, Data:Var ) { _:Map } : ( T1:SeqFirmemType, T2:IntegerType, #token("!seq.clock", "TypeAlias"), #token("i1", "SignlessIntegerType") , T3:Type ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <circt-locals>
            ...
            Mem |-> TV(T1, seq.firmem(_, _, M:Map => M[V1 <- V2]))
            Addr |-> TV(T2, V1:Int)
            Data |-> TV(T3, V2:Value)
            ...
        </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            "seq.firmem.read_port" (Mem:Var, Addr:Var, _Clk:Var) { .Map } : ( T1:SeqFirmemType, T2:IntegerType , #token("!seq.clock", "TypeAlias")) -> ( T3:IntegerType )
            => ListItem(TV(T3, SeqFirmemRead(V1, V2)))
            ...
        </circt-exec>
        <circt-locals>
            ...
            Mem |-> TV(T1, V1)
            Addr |-> TV(T2, V2:Int)
            ...
        </circt-locals>
endmodule