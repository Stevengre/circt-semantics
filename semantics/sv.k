module SV
    imports CONFIGURATION
    imports CIRCT-SYNTAX
    imports K-IO

    // sv.release
     rule <k> circt </k>
        <circt-exec>
            "sv.release" ( X:Var ) { .Map } : ( !hw.inout < T:Type > ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <circt-locals>
            ... 
            X |-> TV ( !hw.inout < T > , hw.inout( _:String , T , _ => V ) )
            ...
        </circt-locals>
        <forced> ... X |-> V ... </forced>


    // sv.force
    rule <k> circt </k>
        <circt-exec>
            "sv.force" ( X1:Var , X2:Var ) { .Map } : ( !hw.inout < T:Type > , T:Type ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <circt-locals>
            ... 
            X1 |-> TV ( !hw.inout < T > , hw.inout( _:String , T , V1 => V2 ) )
            X2 |-> TV ( T , V2 )
            ...
        </circt-locals>
        <forced> M:Map => M [X1 <- V1] </forced>


    // sv.struct_field_inout
    rule <k> circt </k>
        <circt-exec>
            (.K => V [String2BareId({Attr[#token("field", "BareId")]}:>String)]) ~>
            "sv.struct_field_inout" ( X:Var ) { Attr:Map } : ( !hw.inout < struct < Fs:StructFields > > ) -> ( !hw.inout < _T:IntegerType > )
            ...
        </circt-exec>
        <circt-locals>
            ... 
            X |-> TV(!hw.inout < !hw.struct < Fs:StructFields > >, hw.inout(_:String, !hw.struct < Fs:StructFields >, V:Map))
            ...
        </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            V:Value ~>
            "sv.struct_field_inout" ( _:Var ) { _:Map } : ( !hw.inout < struct < _:StructFields > > ) -> ( !hw.inout < T:IntegerType > )
            => ListItem( TV(!hw.inout < T >, hw.inout("", T, V)) )
            ...
        </circt-exec>


    // sv.array_index_inout
    rule <k> circt </k>
        <circt-exec>
            "sv.array_index_inout" ( Arr:Var , Index:Var ) { .Map } : ( !hw.inout < array < Size:ArraySizePrefix T1:IntegerType > > , T2:Type ) -> ( !hw.inout < T1:IntegerType > )
            => ListItem(TV( !hw.inout < T1 > , hw.inout("", T1, HwArrayGet(V1, V2)) ))
            ...
        </circt-exec>
        <circt-locals>
            ... 
            Arr |-> TV(!hw.inout < !hw.array < Size T1 > >, hw.inout(_:String, !hw.array < Size T1 >, V1:HwArray))
            Index |-> TV(T2, V2:Int)
            ...
        </circt-locals>

    
    // sv.readmem, read data from file
    rule <k> circt </k>
        <circt-exec>
            (.K => Attr[#token("base", "BareId")]) ~>
            (.K => Attr[#token("filename", "BareId")]) ~>
            "sv.readmem" ( _:Var ) { Attr:Map } : ( !hw.inout < _:IntegerType > ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (.K => #open(FileName)) ~>
            (_:Int : _:IntegerType):BuiltinAttribute ~>
            FileName:String ~>
            "sv.readmem" ( _:Var ) { _:Map } : ( !hw.inout < _:IntegerType > ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (.K => #if Base ==Int 0 
                #then #read(Fd, getWidth(T)) 
                #else #read(Fd, getWidth(T) /Int 4)  #fi
            ) ~>
            Fd:Int ~>
            (Base:Int : _:IntegerType):BuiltinAttribute ~>
            _:String ~>
            "sv.readmem" ( _:Var ) { _:Map } : ( !hw.inout < T:IntegerType > ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (
                Mem:String ~> Fd:Int ~>
                (_Base:Int : _:IntegerType):BuiltinAttribute ~>
                _:String
                => #close(Fd) ~> "fd closed"
            ) ~> 
            "sv.readmem" ( X:Var ) { _:Map } : ( !hw.inout < T:IntegerType > ) -> ( .Types )
            ...
        </circt-exec>
        <circt-locals>
            ... 
            X |-> TV(!hw.inout < T >, hw.inout(_:String, T, _ => String2Int(Mem)))
            ...
        </circt-locals>
    
     rule <k> circt </k>
        <circt-exec>
            "fd closed" ~> 
            "sv.readmem" ( _:Var ) { _:Map } : ( !hw.inout < _:IntegerType > ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        

    // sv.generate.case
    rule <k> circt </k>
        <circt-exec>
            "sv.generate.case" ( .VarList ) { _:Map } : ( .Types ) -> ( .Types )
            => .List
            ...
        </circt-exec>


    // sv.generate
    rule <k> circt </k>
        <circt-exec>
            "sv.generate" ( .VarList ) ( R:Region ) {_:Map } : ( .Types ) -> ( .Types )
            => R
            ...
        </circt-exec>


    // sv.ordered
    rule <k> circt </k>
        <circt-exec>
            "sv.ordered" ( .VarList ) ( R:Region ) { _:Map } : ( .Types ) -> ( .Types )
            => R
            ...
        </circt-exec>


    // sv.assert.concurrent
    rule <k> circt </k>
        <circt-exec>
            (.K => Old[Clk] orDefault false) ~>
            (.K => Locals [Clk] orDefault false) ~>
            (.K => Attr[#token("event", "BareId")]) ~>
            "sv.assert.concurrent" ( Clk:Var , _Cond:Var ) { Attr:Map } : ( _:Type , _:Type ) -> ( .Types )
            ...
        </circt-exec>
        <last-locals> Old:Map </last-locals>
        <circt-locals> Locals:Map </circt-locals>
    
    // sv.assert.concurrent, no last value (no event)
    rule <k> circt </k>
        <circt-exec>
            false ~> TV(_, _) ~> (_:IntegerLiteral : _:IntegerType):BuiltinAttribute ~>
            "sv.assert.concurrent" ( _Clk:Var , _Cond:Var ) { _:Map } : ( _:Type , _:Type ) -> ( .Types )
            => .List
            ...
        </circt-exec>
    
    // sv.assert.concurrent, event check
    rule <k> circt </k>
        <circt-exec>
            (
                TV(_, Old:Int) 
                ~> TV(_, New:Int) 
                ~> (Event:IntegerLiteral : _:IntegerType):BuiltinAttribute
                => eventCheck(Old, New, {Event}:>Int)
            ) ~>
            "sv.assert.concurrent" ( _:Var , _:Var ) { _:Map } : ( _:Type , _:Type ) -> ( .Types )
            ...
        </circt-exec>
    
    // sv.assert.concurrent, event hit
    rule <k> circt </k>
        <circt-exec>
            (.K => #if V ==Int 0 #then false #else true #fi) ~>
            true ~>
            "sv.assert.concurrent" ( _:Var , Cond:Var ) { _:Map } : ( _:Type , _:Type ) -> ( .Types )
            ...
        </circt-exec>
        <circt-locals>
            ... 
            Cond |-> TV(#token("i1", "SignlessIntegerType"), V:Int)
            ...
        </circt-locals>
    
    // sv.assert.concurrent, no event hit
    rule <k> circt </k>
        <circt-exec>
            false ~>
            "sv.assert.concurrent" ( _:Var , _Cond:Var ) { _:Map } : ( _:Type , _:Type ) -> ( .Types )
            => .List
            ...
        </circt-exec>
    
    // sv.assert.concurrent, condition true
    rule <k> circt </k>
        <circt-exec>
            true ~> true ~>
            "sv.assert.concurrent" ( _:Var , _:Var ) { _:Map } : ( _:Type , _:Type ) -> ( .Types )
            => .List
            ...
        </circt-exec>
    
    // sv.assert.concurrent, condition false
    rule <k> circt </k>
        <circt-exec>
            false ~> true ~>
            "sv.assert.concurrent" ( _:Var , _:Var ) { _:Map } : ( _:Type , _:Type ) -> ( .Types )
            => stop ~> "assertion error"
            ...
        </circt-exec>


    // sv.assert
    rule <k> circt </k>
        <circt-exec>
            (.K => #if V ==Int 0 #then false #else true #fi) ~>
            "sv.assert" ( X:Var ) { _:Map } : ( #token("i1", "SignlessIntegerType") ) -> ( .Types )
            ...
        </circt-exec>
        <circt-locals>
            ... 
            X |-> TV(#token("i1", "SignlessIntegerType"), V:Int)
            ...
        </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            B:Bool ~> 
            "sv.assert" ( _:Var ) { _:Map } : ( _:Type ) -> ( .Types )
            => #if B #then .List #else stop ~> "assertion error" #fi
            ...
        </circt-exec>

    
    // sv.assume
    rule <k> circt </k>
        <circt-exec>
            (.K => #if V ==Int 0 #then false #else true #fi) ~>
            "sv.assume" ( X:Var ) { _:Map } : ( #token("i1", "SignlessIntegerType") ) -> ( .Types )
            ...
        </circt-exec>
        <circt-locals>
            ... 
            X |-> TV(#token("i1", "SignlessIntegerType"), V:Int)
            ...
        </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            B:Bool ~> 
            "sv.assume" ( _:Var ) { _:Map } : ( _:Type ) -> ( .Types )
            => #if B #then .List #else stop ~> "assumption error" #fi
            ...
        </circt-exec>
    
    // sv.assume.concurrent
    rule <k> circt </k>
        <circt-exec>
            ("sv.assume.concurrent" => "sv.assert.concurrent") ( _Clk:Var , _Cond:Var ) { _:Map } : ( _:Type , _:Type ) -> ( .Types )
            ...
        </circt-exec>
    

    // sv.cover, meaningless
    rule <k> circt </k>
        <circt-exec>
            "sv.cover" ( _:Var ) { _:Map } : ( #token("i1", "SignlessIntegerType") ) -> ( .Types )
            => .List
            ...
        </circt-exec>


    // sv.cover.concurrent, meaningless
    rule <k> circt </k>
        <circt-exec>
            "sv.cover.concurrent" ( _Clk:Var , _Cond:Var ) { _:Map } : ( _:Type , _:Type ) -> ( .Types )
            => .List
            ...
        </circt-exec>


    // sv.bpassign
    rule <k> circt </k>
        <circt-exec>
            "sv.bpassign" ( Reg:Var , X:Var ) { _:Map } : ( !hw.inout < T:Type > , T:Type ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <circt-locals>
            ... 
            Reg |-> TV(!hw.inout < T >, hw.inout(_:String, T, _ => V))
            X |-> TV(T, V)
            ...
        </circt-locals>
    

    // sv.passign
    rule <k> circt </k>
        <circt-exec>
            "sv.passign" ( Reg:Var , X:Var ) { _:Map } : ( !hw.inout < T:Type > , T:Type ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <circt-locals>
            ... 
            Reg |-> TV(!hw.inout < T >, hw.inout(_:String, T, _ => V))
            X |-> TV(T, V)
            ...
        </circt-locals>


    // sv.for
    rule <k> circt </k>
        <circt-exec>
            (.K => V1 ~> V2 ~> V3 ~> B) ~>
            "sv.for" (Low:Var, High:Var, Step:Var) ( { .OperationList B:Block } ) { _:Map } : ( T:Type, T:Type, T:Type ) -> ( .Types )
            ...
        </circt-exec>
        <circt-locals>
            ... 
            Low |->  TV(T, V1)
            High |-> TV(T, V2)
            Step |-> TV(T, V3)
            ...
        </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            (.K => OPs) ~>
            (V1:Int => V1 +Int V3) ~> 
            V2:Int ~>
            V3:Int ~> 
            _:CaretId ( I:Var : T:Type ) : OPs:OperationList ~>
            "sv.for" (_:VarList) ( _:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
        <circt-locals> M:Map => M[I <- TV(T, V1)] </circt-locals>
        requires V1 <Int V2
    
    rule <k> circt </k>
        <circt-exec>
            (
                V1:Int ~> V2:Int ~> _V3:Int ~>
                _:CaretId ( _:Var : _:Type ) : _:OperationList ~>
                "sv.for" (_:VarList) ( _:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ) => .List
            ...
        </circt-exec>
        requires V1 >=Int V2


    // sv.assign
    rule <k> circt </k>
        <circt-exec>
            "sv.assign" ( X1:Var , X2:Var ) { .Map } : ( !hw.inout < T1:Type > , T2:Type ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <circt-locals>
            ... 
            X1 |-> TV(!hw.inout<T1>, hw.inout(_:String, T1, (_ => V2)))
            X2 |-> TV(T2, V2)
            ...
        </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            "sv.assign" ( X1:Var , X2:Var ) { .Map } : ( !hw.inout < array < Size:ArraySizePrefix T:IntegerType > >  , !hw.array < Size:ArraySizePrefix T:IntegerType > ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <circt-locals>
            ...
            X1 |-> TV( !hw.inout < !hw.array < Size T > > , hw.inout( _:String , !hw.array < Size T > , (_ => V2)) )
            X2 |-> TV( !hw.array < Size T >, V2:Value )
            ...
        </circt-locals>
    
    rule <k> circt </k>
        <circt-exec>
            "sv.assign" ( X1:Var , X2:Var ) { .Map } : ( !hw.inout < struct < Fs:StructFields > > , !hw.struct < Fs:StructFields > ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <circt-locals>
            ...
            X1 |-> TV( !hw.inout < !hw.struct < Fs > > , hw.inout( _:String , !hw.struct < Fs > , (_ => V2)) )
            X2 |-> TV( !hw.struct < Fs >, V2:Value)
            ...
        </circt-locals>

    
    // sv.xmr.ref
    rule <k> circt </k>
        <circt-exec>
            (.K => .List) ~>
            (.K => M [ SymbolRefId2String({Attr[#token("ref", "BareId")]}:>SymbolRefId) ]) ~>
            "sv.xmr.ref" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < _T:Type > )
            ...
        </circt-exec>
        <hw-hierpath> M:Map </hw-hierpath>
    
    rule <k> circt </k>
        <circt-exec>
            (L1:List => L1 ListItem(SymbolRefId2String(Mod) +String "::" +String SymbolRefId2String(Ins))) ~>
            [ #hw.innerNameRef < Mod:SymbolRefId :: Ins:SymbolRefId > , AL:AttributeValueList => AL ] ~>
            "sv.xmr.ref" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:Type > )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            _:List ~>
            ([.AttributeValueList] => .List) ~>
            "sv.xmr.ref" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:Type > )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (ListItem(Ref:String) L1:List => L1) ~>
            (L:List => L ListItem(M [Ref])) ~>
            "sv.xmr.ref" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:Type > )
            ...
        </circt-exec>
        <symrefs> M:Map </symrefs>
        requires Ref in_keys(M)
    
    rule <k> circt </k>
        <circt-exec>
            (
                .List ~>
                L:List ListItem(Terminal:String) ~>
                "sv.xmr.ref" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < T:Type > )
            ) => (
                getTrace(ListItem(Mod) L) ~>
                Terminal ~>
                "sv.xmr" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < T > )
            )
            ...
        </circt-exec>
        <trace> ListItem(Mod:String) _:List </trace>
        


    // sv.xmr
    rule <k> circt </k>
        <circt-exec>
            (.K => .List) ~>
            (.K => Attr[#token("path", "BareId")]) ~>
            "sv.xmr" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < _T:IntegerType > )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (L:List => L ListItem(S)) ~>
            [S:String , AL:AttributeValueList => AL] ~>
            "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:IntegerType > )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (L:List ~> [.AttributeValueList] => .K) ~>
            (.K => getTrace(L)) ~>
            (.K => Attr[#token("terminal", "BareId")]) ~>
            "sv.xmr" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < _T:IntegerType > )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (.K => M[String2BareId(Terminal)] orDefault "not port-in") ~>
            Path:String ~>
            Terminal:String ~>
            "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:IntegerType > )
            ...
        </circt-exec>
        <instance>
            <inst-name> Path </inst-name>
            <inst-in> M:Map </inst-in>
            ...
        </instance>
    
    rule <k> circt </k>
        <circt-exec>
            ("not port-in" => M[String2BareId(Terminal)] orDefault "not port-out") ~>
            Path:String ~>
            Terminal:String ~>
            "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:IntegerType > )
            ...
        </circt-exec>
        <instance>
            <inst-name> Path </inst-name>
            <inst-out> M:Map </inst-out>
            ...
        </instance>
    
    rule <k> circt </k>
        <circt-exec>
            ("not port-out" => M[Terminal] orDefault "not reg") ~>
            Path:String ~>
            Terminal:String ~>
            "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:IntegerType > )
            ...
        </circt-exec>
        <instance>
            <inst-name> Path </inst-name>
            <inst-regs> M:Map </inst-regs>
            ...
        </instance>

    rule <k> circt </k>
        <circt-exec>
            ("not reg" => M[Terminal] orDefault "not wire") ~>
            Path:String ~>
            Terminal:String ~>
            "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:IntegerType > )
            ...
        </circt-exec>
        <instance>
            <inst-name> Path </inst-name>
            <inst-wires> M:Map </inst-wires>
            ...
        </instance>
    
    rule <k> circt </k>
        <circt-exec>
            ("not wire" => "no such net") ~>
            _Path:String ~>
            _Terminal:String ~>
            "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _T:IntegerType > )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (.K => M[V] orDefault "no such var") ~>
            V:Var ~> Path:String ~> _Terminal:String ~>
            "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < _:IntegerType > )
            ...
        </circt-exec>
        <instance>
            <inst-name> Path </inst-name>
            <inst-vars> M:Map </inst-vars>
            ...
        </instance>
    
    rule <k> circt </k>
        <circt-exec>
            (
                TV(T, V) ~>
                _:Var ~>
                _:String ~>
                Terminal:String ~>
                "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < T:IntegerType > )
            ) => ListItem( TV(!hw.inout < T >, hw.inout(Terminal, T, V)) )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (
                TV(!hw.inout < T >, hw.inout(Terminal, T, V)) ~>
                _:Var ~>
                _:String ~>
                Terminal:String ~>
                "sv.xmr" ( .VarList ) { _:Map } : ( .Types ) -> ( !hw.inout < T:IntegerType > )
            ) => ListItem( TV(!hw.inout < T >, hw.inout(Terminal, T, V)) )
            ...
        </circt-exec>
    

    // sv.constantX
    rule <k> circt </k>
        <circt-exec> 
            "sv.constantX" ( .VarList ) { .Map } : ( .Types ) -> ( T:Type )
            => ListItem(TV(T, #x))
            ...
        </circt-exec>


    // sv.constantZ
    rule <k> circt </k>
        <circt-exec> 
            "sv.constantZ" ( .VarList ) { .Map } : ( .Types ) -> ( T:Type )
            => ListItem(TV(T, #z))
            ...
        </circt-exec>

    
    // sv.case
    rule <k> circt </k>
        <circt-exec> 
            (.K => TV(T, V)) ~>
            (.K => Attr[#token("casePatterns", "BareId")]) ~>
            "sv.case" ( I:Var ) ( _:Regions ) { Attr:Map } : ( T:Type ) -> ( .Types )
            ...
        </circt-exec>
        <circt-locals> ... I |-> TV(T, V) ... </circt-locals>

    rule <k> circt </k>
        <circt-exec> 
            (
                TV(T, V:Int) ~>
                [ X:Int : _:IntegerType, L:AttributeValueList ] ~>
                "sv.case" ( I:Var ) ( R:Region, Rs:Regions ) { Attr:Map } : ( T:Type ) -> ( .Types )
            ) => #if V ==Int X 
                #then R 
                #else 
                    TV(T, V) ~>
                    [ L ] ~>
                    "sv.case" ( I ) ( Rs ) { Attr } : ( T ) -> ( .Types )
                #fi
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (
                TV(T, _:Int) ~>
                [ (unit, .AttributeValueList):AttributeValueList ] ~>
                "sv.case" ( _:Var ) ( R:Region ) { _:Map } : ( T:Type ) -> ( .Types )
            )
            => R
            ...
        </circt-exec>


    // sv.indexed_part_select, todo
    rule <k> circt </k>
        <circt-exec> 
            "sv.indexed_part_select" ( I1:Var , I2:Var ) { Attr:Map } : ( T1:Type , T2:Type ) -> ( T:Type )
            => ListItem( TV(
                T, 
                V1 &Int ((( 2 ^Int {getAttrValue(Attr, #token("width", "BareId"))}:>Int -Int 1 ) <<Int V2 ) >>Int V2)
            ) )
            ...
        </circt-exec>
        <circt-locals>
            ...
            I1 |-> TV(T1, V1:Int)
            I2 |-> TV(T2, V2:Int)
            ...
        </circt-locals>
    
    // sv.indexed_part_select_inout, todo
    rule <k> circt </k>
        <circt-exec> 
            "sv.indexed_part_select_inout" ( I1:Var , I2:Var ) { Attr:Map } : ( !hw.inout < T1:IntegerType > , T2:Type ) -> ( !hw.inout < T:IntegerType > )
            => ListItem( TV(
                !hw.inout < T >,
                hw.inout("", T, V1 &Int ((( 2 ^Int {getAttrValue(Attr, #token("width", "BareId"))}:>Int -Int 1 ) <<Int V2 ) >>Int V2))
            ) )
            ...
        </circt-exec>
        <circt-locals>
            ...
            I1 |-> TV(!hw.inout< T1 >, hw.inout(_:String, T1, V1:Int))
            I2 |-> TV(T2, V2:Int)
            ...
        </circt-locals>

    // sv.localparam
    rule <k> circt </k>
        <circt-exec> 
            "sv.localparam" ( .VarList ) { Attr:Map } : ( .Types ) -> ( T:Type )
            => ListItem( TV(T, getAttrValue(Attr, #token("value", "BareId"))) )
            ...
        </circt-exec>


    // sv.fwrite
    rule <k> circt </k>
        <circt-exec> 
            "sv.fwrite" ( I:Var ) { Attr:Map } : ( T:Type ) -> ( .Types ) => .List
            ...
        </circt-exec>
        <circt-locals> ... I |-> TV(T, V) ... </circt-locals>
        <fd> 
            M:Map => M [V <- {M[V] orDefault .List}:>List ListItem(Attr[#token("format_string", "BareId")]) ]
        </fd>


    // sv.if
    rule <k> circt </k>
        <circt-exec> 
            (.K => V) ~>
            "sv.if" ( I:Var ) ( _:Regions ) { .Map } : ( T:Type ) -> ( .Types )
            ...
        </circt-exec>
        <circt-locals> ... I |-> TV(T, V) ... </circt-locals>

    rule <k> circt </k>
        <circt-exec> 
            (
                X:Int ~>
                "sv.if" ( _:Var ) ( R1:Region , R2:Region ) { .Map } : ( _:Type ) -> ( .Types )
            ) => #if X ==Int 0 #then R2 #else R1 #fi
            ...
        </circt-exec>

    
    // sv.ifdef
    rule <k> circt </k>
        <circt-exec> 
            ( .K => M[#token("cond", "BareId")] orDefault stop )
            ~> "sv.ifdef" ( .VarList ) ( _:Regions ) { M:Map } : _:FunctionType
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (B:Bool ~> "sv.ifdef" ( .VarList ) ( R1:Region , R2:Region ) { _:Map } : _:FunctionType)
            => #if B #then R1 #else R2 #fi
            ...
        </circt-exec>

    rule <k> circt </k>
        <circt-exec> 
            (
                (#token("#sv", "AttributeAlias") < #token("macro.ident", "BareId") S:StringLiteral >):DialectAttribute
                => S in_keys(M)
            ) ~> "sv.ifdef" ( .VarList ) ( _:Regions ) { _:Map } : _:FunctionType
            ...
        </circt-exec>
        <macros> M:Map </macros>
    

    // sv.ifdef.procedural
    rule <k> circt </k>
        <circt-exec> 
            ( .K => Attr[#token("cond", "BareId")] orDefault stop )
            ~> "sv.ifdef.procedural" ( .VarList ) ( _:Regions ) { Attr:Map } : _:FunctionType
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (B:Bool ~> "sv.ifdef.procedural" ( .VarList ) ( R1:Region , R2:Region ) { _:Map } : _:FunctionType)
            => #if B #then R1 #else R2 #fi
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (
                (#token("#sv", "AttributeAlias") < #token("macro.ident", "BareId") S:StringLiteral >):DialectAttribute
                => S in_keys(M)
            ) ~> "sv.ifdef.procedural" ( .VarList ) ( _:Regions ) { _:Map } : _:FunctionType
            ...
        </circt-exec>
        <macros> M:Map </macros>


    // sv.macro.ref.se
    rule <k> circt </k>
        <circt-exec> 
            ("sv.macro.ref.se" => "sv.macro.ref") ( .VarList ) { _:Map } : ( .Types ) -> ( _:Type )
            ...
        </circt-exec>


    // sv.macro.ref, ident
    rule <k> circt </k>
        <circt-exec> 
            ( .K => {M [#token("ident", "BareId")]}:>DialectAttribute ) 
            ~> "sv.macro.ref" ( .VarList ) { M:Map } : ( .Types ) -> ( _:Type )
            ...
        </circt-exec>
        requires #token("ident", "BareId") in_keys(M)
    
    rule <k> circt </k>
        <circt-exec> 
            (
                (#token("#sv", "AttributeAlias") < #token("macro.ident", "BareId") S:StringLiteral >):DialectAttribute
                => M [S]
            ) ~> "sv.macro.ref" ( .VarList ) { _:Map } : ( .Types ) -> ( _T:Type )
            ...
        </circt-exec>
        <macros> M:Map </macros>
    
    rule <k> circt </k>
        <circt-exec> 
            ( S:String ~> "sv.macro.ref" ( .VarList ) { _:Map } : ( .Types ) -> ( T:Type ) )
            => ListItem( TV(T, String2Int(S)) )
            ...
        </circt-exec>
        requires lengthString(S) >Int 0
    
    rule <k> circt </k>
        <circt-exec> 
            ( S:String ~> "sv.macro.ref" ( .VarList ) { _:Map } : ( .Types ) -> ( T:Type ) )
            => ListItem( TV(T, 0) )
            ...
        </circt-exec>
        requires lengthString(S) ==Int 0
    

    // sv.macro.ref, macroName
    rule <k> circt </k>
        <circt-exec> 
            ( .K => M [#token("macroName", "BareId")] ) 
            ~> "sv.macro.ref" ( .VarList ) { M:Map } : ( .Types ) -> ( _:Type )
            ...
        </circt-exec>
        requires #token("macroName", "BareId") in_keys(M) andBool (notBool (#token("ident", "BareId") in_keys(M)))
    
    rule <k> circt </k>
        <circt-exec> 
            (
                S:SymbolRefId
                => M [SymbolRefId2String(S)] orDefault (stop SymbolRefId2String(S))
            ) ~> "sv.macro.ref" ( .VarList ) { _:Map } : ( .Types ) -> ( _:Type )
            ...
        </circt-exec>
        <macros> M:Map </macros>
    

    // sv.macro.def
    rule <k> circt </k>
        <circt-exec> 
            ( .K => M [#token("macroName", "BareId")] ) ~>
            ( .K => M [#token("format_string", "BareId")] ) ~> 
            "sv.macro.def" ( .VarList ) { M:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (S:SymbolRefId => SymbolRefId2String(S))
            ~> _Fmt:String
            ~> "sv.macro.def" ( .VarList ) { _:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec> 
            (
                MacroName:String 
                ~> Fmt:String
                ~> "sv.macro.def" ( .VarList ) { _:Map } : ( .Types ) -> ( .Types )
            )
            => .List
            ...
        </circt-exec>
        <macros>
            M:Map => M [MacroName <- Fmt]
        </macros>
    

    // sv.wire
    rule <k> circt </k>
        <circt-exec>
            "sv.wire" ( .VarList ) {Attr:Map} : ( .Types ) -> ( !hw.inout < T:IntegerType > )
            => ListItem( TV(
                !hw.inout< T >,
                hw.inout({Attr[#token("name", "BareId")]}:>String, T, 0)
            ) ) ~> "wire"
            ...
        </circt-exec>
        <module> Mod:SymbolRefId </module>
        <symrefs> 
            M:Map => M [ 
                SymbolRefId2String(Mod) +String "::" 
                    +String getInnerSymString({Attr[#token("inner_sym", "BareId")]}:>DialectAttribute) 
                <- Attr[#token("name", "BareId")] 
            ]
        </symrefs>
        requires #token("inner_sym", "BareId") in_keys(Attr)
    
    rule <k> circt </k>
        <circt-exec> 
            "sv.wire" ( .VarList ) {Attr:Map} : ( .Types ) -> ( !hw.inout < T:IntegerType > )
            => ListItem( TV(
                !hw.inout< T >,
                hw.inout({Attr[#token("name", "BareId")]}:>String, T, 0)
            ) ) ~> "wire"
            ...
        </circt-exec>
        requires notBool (#token("inner_sym", "BareId") in_keys(Attr))
    

    // sv.logic
    rule <k> circt </k>
        <circt-exec> 
            "sv.logic" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < T:IntegerType > )
            => ListItem( TV(
                !hw.inout< T >,
                hw.inout({Attr[#token("name", "BareId")]}:>String, T, 0)
            ) ) ~> "reg"
            ...
        </circt-exec>

    
    // sv.reg
    rule <k> circt </k>
        <circt-exec> 
            "sv.reg" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < T:IntegerType > )
            => ListItem( TV(
                !hw.inout< T >,
                hw.inout({Attr[#token("name", "BareId")]}:>String, T, 0)
            ) ) ~> "reg"
            ...
        </circt-exec>
        <module> Mod:SymbolRefId </module>
        <symrefs> 
            M:Map => M [ 
                SymbolRefId2String(Mod) +String "::" 
                    +String getInnerSymString({Attr[#token("inner_sym", "BareId")]}:>DialectAttribute) 
                <- Attr[#token("name", "BareId")] 
            ]
        </symrefs>
        requires #token("inner_sym", "BareId") in_keys(Attr)
    
    rule <k> circt </k>
        <circt-exec> 
            "sv.reg" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < T:IntegerType > )
            => ListItem( TV(
                !hw.inout< T >,
                hw.inout({Attr[#token("name", "BareId")]}:>String, T, 0)
            ) ) ~> "reg"
            ...
        </circt-exec>
        requires notBool (#token("inner_sym", "BareId") in_keys(Attr))
    
    rule <k> circt </k>
        <circt-exec> 
            "sv.reg" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < array< Size:ArraySizePrefix T:IntegerType > > )
            => ListItem( TV(
                !hw.inout< !hw.array< Size T > >,
                hw.inout({Attr[#token("name", "BareId")]}:>String, !hw.array< Size T >, 0)
            ) ) ~> "reg"
            ...
        </circt-exec>
        requires notBool (#token("inner_sym", "BareId") in_keys(Attr))

    
    rule <k> circt </k>
        <circt-exec> 
            "sv.reg" ( .VarList ) { Attr:Map } : ( .Types ) -> ( !hw.inout < struct< Fs:StructFields > > )
            => ListItem( TV(
                !hw.inout < !hw.struct< Fs > >,
                hw.inout({Attr[#token("name", "BareId")]}:>String, !hw.struct < Fs >, 0)
            ) ) ~> "reg"
            ...
        </circt-exec>
        

    // sv.read_inout, but where to read?
    rule <k> circt </k>
        <circt-exec> 
            "sv.read_inout" ( I:Var ) { .Map } : ( !hw.inout < T:IntegerType > ) -> ( T:IntegerType )
            => ListItem(TV(T, V))
            ...
        </circt-exec>
        <circt-locals>
            ...
            I |-> TV(!hw.inout< T >, hw.inout(_:String, T, V:Int))
            ...
        </circt-locals>
    

    // sv.error
    rule <k> circt </k>
        <circt-exec> 
            "sv.error" ( .VarList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <sv-error>
            L:List => L ListItem(Attr[#token("message", "BareId")])
        </sv-error>
    

    // sv.warning
    rule <k> circt </k>
        <circt-exec> 
            "sv.warning" ( .VarList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <sv-warn>
            L:List => L ListItem(Attr[#token("message", "BareId")])
        </sv-warn>
    

    // sv.info
    rule <k> circt </k>
        <circt-exec> 
            "sv.info" ( .VarList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <sv-info>
            L:List => L ListItem(Attr[#token("message", "BareId")])
        </sv-info>


    // sv.fatal
    rule <k> circt => stop Attr[#token("verbosity", "BareId")] </k>
        <circt-exec> 
            "sv.fatal" ( .VarList ) { Attr:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>
        <sv-fatal>
            L:List => L ListItem(Attr[#token("message", "BareId")])
        </sv-fatal>

    
    // sv.verbatim
    rule <k> circt </k>
        <circt-exec> 
            "sv.verbatim" ( .VarList ) { Attr:Map } : ( .Types ) -> ( .Types )
            => .List
            ...
        </circt-exec>
        <sv-verbatim>
            L:List => L ListItem(Attr[#token("format_string", "BareId")])
        </sv-verbatim>


    // sv.finish
    rule <k> circt => stop Attr[#token("verbosity", "BareId")] </k>
        <circt-exec> 
            "sv.finish" ( .VarList ) { Attr:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>
    

    // sv.stop
    rule <k> circt => stop Attr[#token("verbosity", "BareId")] </k>
        <circt-exec> 
            "sv.stop" ( .VarList ) { Attr:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>
    

    // sv.exit
    rule <k> circt => stop </k>
        <circt-exec> 
            "sv.exit" ( .VarList ) { _:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>
    

    // sv.initial
    rule <k> circt </k>
        <circt-exec> 
            "sv.initial" ( .VarList ) ( R:Region ) { _:Map } : ( .Types ) -> ( .Types )
            => #if Inst in S #then .List #else R #fi
            ...
        </circt-exec>
        <name> Inst:String </name>
        <initialized> S:Set => S SetItem(Inst) </initialized>
    

    // sv.alwayscomb
    rule <k> circt </k>
        <circt-exec> 
            "sv.alwayscomb" ( .VarList ) ( R:Region ) { _:Map } : ( .Types ) -> ( .Types )
            => R
            ...
        </circt-exec>
    
    
    // sv.alwaysff
    rule <k> circt </k>
        <circt-exec> 
            ("sv.alwaysff" => "sv.always") ( _:Var, .VarList ) ( _R:Region ) { _:Map } : ( .Types ) -> ( .Types )
            ...
        </circt-exec>


    // sv.always
    rule <k> circt </k>
        <circt-exec> 
            "sv.always" ( .VarList ) ( R:Region ) { _:Map } : ( .Types ) -> ( .Types )
            => R
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (.K => V, Vs) ~> 
            (.K => Attr[#token("events", "BareId")]) ~> 
            "sv.always" ( V:Var, Vs:VarList ) ( _:Region ) { Attr:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (.K => Old[V] orDefault false) ~>
            (.K => Locals[V] orDefault false) ~>
            (.K => {I}:>Int) ~> 
            (V:Var , Vs:VarList => Vs) ~> 
            ([ I:IntegerLiteral : _:IntegerType , As:AttributeValueList ] => [ As ]) ~> 
            "sv.always" ( _:VarList ) ( _:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
        <circt-locals> Locals:Map </circt-locals>
        <last-locals> Old:Map </last-locals>
        // requires size(Old) ==Int 0
    
    rule <k> circt </k>
        <circt-exec>
            (false ~> _:KItem ~> _:Int => false)
            ~> _:VarList
            ~> [ _:AttributeValueList ]
            ~> "sv.always" ( _:VarList ) ( _:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (
                TV ( _:IntegerType , Old:Int ) ~> 
                TV ( _:IntegerType , New:Int ) ~> 
                Event:Int
                => eventCheck(Old, New:Int, Event:Int)
            ) ~> 
            _:VarList ~> 
            [ _:AttributeValueList ] ~> 
            "sv.always" ( _:VarList ) ( _:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (false => .K) ~> 
            _:VarList ~> 
            [ _:AttributeValueList ] ~> 
            "sv.always" ( _:VarList ) ( _:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (
                true ~> 
                _:VarList ~> 
                [ _:AttributeValueList ] ~> 
                "sv.always" ( _:VarList ) ( R:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ) => R
            ...
        </circt-exec>
    
    rule <k> circt </k>
        <circt-exec>
            (
                .VarList ~> 
                [ .AttributeValueList ] ~> 
                "sv.always" ( _:VarList ) ( _:Region ) { _:Map } : ( _:Types ) -> ( .Types )
            ) => .List
            ...
        </circt-exec>

    syntax Int ::= signalEvent(Int, Int) [function]
    rule signalEvent(0, 1) => 1
    rule signalEvent(1, 0) => -1
    rule signalEvent(_:Int, _:Int) => 0 [owise]

    // check always events
    syntax Bool ::= eventCheck(Int, Int, Int) [function]
    rule eventCheck(Last:Int, Now:Int, 0) => true requires Last <Int Now
    rule eventCheck(Last:Int, Now:Int, 1) => true requires Last >Int Now
    rule eventCheck(_:Int, _:Int, _:Int) => false [owise]
endmodule