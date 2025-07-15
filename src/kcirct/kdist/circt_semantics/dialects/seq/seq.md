# SEQ Dialect

```k
requires "seq-syntax.md"
requires "seq-helper.md"
requires "../../hardware/bits.md"
requires "../../hardware/hardware.md"
requires "../../mlir/builtin.md"
requires "../../mlir/mlir-helper.md"
module SEQ
imports SEQ-SYNTAX
imports SEQ-HELPER
imports BITS
imports HARDWARE
imports LIST
imports MAP
imports BUILTIN
imports MLIR-HELPER
```

## `seq.from_clock`

```k
rule
<current> "seq.from_clock" ( ListItem(B:Bits) ) { _:Map } : ( !seq.clock ) -> ( _:Type ) => ListItem(B) ... </current>
```

## `seq.firreg`

### Setup Current Signal Before Update

```k
rule
<current> 
(.K => ListItem(V) ~> "HARDWARE#WRITE" ~> ListItem(Port)) 
~> "seq.firreg" ( ListItem(_:String) _:List ) { _:Map } : _FT 
~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<signals> Signals:Map </signals>
<history> ... Port |-> V:Bits ... </history>
requires notBool (Port in_keys(Signals))
[priority(30)]

rule
<current> 
(.K => ListItem(bits(0, getWidth(T))) ~> "HARDWARE#WRITE" ~> ListItem(Port)) 
~> "seq.firreg" ( ListItem(_:String) _:List ) { "firrtl.random_init_start" |-> V:Int : _:Type _:Map } : (_) -> (T:IntegerType) 
~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<signals> Signals:Map </signals>
requires notBool (Port in_keys(Signals))
[priority(34)]

rule
<current> 
(.K => ListItem(bits(0, getWidth(T))) ~> "HARDWARE#WRITE" ~> ListItem(Port)) 
~> "seq.firreg" ( ListItem(_:String) _:List ) { _:Map } : (_) -> (T:IntegerType) 
~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<signals> Signals:Map </signals>
requires notBool (Port in_keys(Signals))
[priority(35)]
```

### Register Update

```k
rule
<current> 
   ListItem(Next:Bits) ListItem(Clk:Bits)
~> "seq.firreg" ( ListItem(_:String) ListItem(ClkId:String) ) { _:Map } : _FT
=> #if checkEdge(0, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits) 
   #then ListItem(Next) 
   #else ListItem("HARDWARE#KEEP") #fi
... 
</current>
<history> H:Map </history>
[priority(35)]

rule
<current> 
   ListItem(Next:Bits) ListItem(Clk:Bits) ListItem(Rst:Bits) ListItem(RstValue:Bits)
~> "seq.firreg" ( ListItem(_:String) ListItem(ClkId:String) _:List ) { _:Map } : _FT
=> #if checkEdge(0, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits) 
   #then ( #if Bits2Bool(Rst) #then ListItem(RstValue) #else ListItem(Next) #fi )
   #else ListItem("HARDWARE#KEEP") #fi
... 
</current>
<history> H:Map </history>
[priority(35)]
```

## `seq.firmem`


### build register

0 is used as a placeholder if not otherwise specified.
The structure of reg is a mapping from port to a tuple:
port |->
({1 indicates firmem, 0 indicates firreg}, 
{if firreg, this is its size},
{if firmem, this is the readlatency}, 
{if firmem, this is the writelatency}, 
{name})

```k
rule
<setup> 
   "HARDWARE#CONNECT" ~> ListItem(Out) L0:List ~> ListItem( "seq.firreg" ( L:List ) { Config:Map } : (T1:Types) -> (T:IntegerType) ) L1:List
=> "HARDWARE#CONNECT" ~> L0 ~> L1
...
</setup>
<connection> M => M [Out <- "seq.firreg" ( L ) { Config } : (T1) -> (T)] </connection>
<register> REG => REG [Out <- (0, getWidth(T), 0, 0, {Config["name"] orDefault "default_firreg"}:>String)] </register>
[priority(40)]

rule
<setup> 
   "HARDWARE#CONNECT" ~> ListItem(Out) L0:List ~> ListItem( "seq.firmem" ( L:List ) { Config:Map } : Ft:StdFT ) L1:List
=> "HARDWARE#CONNECT" ~> L0 ~> L1
...
</setup>
<connection> M => M [Out <- "seq.firmem" ( L ) { Config } : Ft] </connection>
<register> REG => REG [Out <- (1, 0, ToInt({Config["readLatency"] orDefault 0}:>AttributeValue), 
ToInt({Config["writeLatency"] orDefault 0}:>AttributeValue), {Config["name"] orDefault "default_firmem"}:>String)] </register>
[priority(40)]
```

### Setup Current Signal Before Update

```k
rule
<current> 
  ("seq.firmem" ( .List ) { _:Map } : _FT => ListItem(H[Port] orDefault .Map)) 
~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<signals> Signals:Map </signals>
<history> H:Map </history>
requires notBool (Port in_keys(Signals))
[priority(35)]

rule
<current> 
  ("seq.firmem" ( .List ) { _:Map } : _FT => ListItem(Signals[Port] orDefault .Map)) 
~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<signals> Signals:Map </signals>
requires (Port in_keys(Signals))
[priority(35)]

rule
<current> 
   L0:List ListItem(Stimuli:Map) ~> "HARDWARE#WRITE" ~> L1:List ListItem(Port:String)  
=> L0 ~> "HARDWARE#WRITE" ~> L1
...
</current>
<signals> M => M [Port <- Stimuli] </signals>

rule
<current> 
   READ:List ~> "HARDWARE#READ_DIRECT" ~> ListItem(Port:String) L:List 
=> READ ListItem(Signal) ~> "HARDWARE#READ_DIRECT" ~> L
... 
</current>
<signals> ... Port |-> Signal:Map ... </signals>
```

### `seq.firmem.read_port`

add enable

```k
rule
<current> 
   (ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) 
~> "seq.firmem.read_port" ( ListItem(MemId) ListItem(AddrId) ListItem(ClkId) ) { M1:Map } : FT
 => ListItem(Mem) ListItem(Addr) ListItem(Clk) ListItem(bits(1, 1))
~> "seq.firmem.read_port" ( ListItem(MemId) ListItem(AddrId) ListItem(ClkId) ListItem("READENABLE")  ) { M1 } : FT
 ) ~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
[priority(30)]
```

add mode 

```k
rule
<current> 
   (ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) ListItem(Enable:Bits)
~> "seq.firmem.read_port" ( ListItem(MemId) ListItem(AddrId) ListItem(ClkId) ListItem(EnableId) ) { M1:Map } : FT
 => ListItem(Mem) ListItem(Addr) ListItem(Clk) ListItem(Enable) ListItem(bits(0, 1))
~> "seq.firmem.read_port" ( ListItem(MemId) ListItem(AddrId) ListItem(ClkId) ListItem(EnableId) ListItem("MODEREAD") ) { M1 } : FT
 ) ~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
[priority(30)]
```

if Rl == 0 missing checkEdge

```k
rule
<current> 
   (ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) ListItem(Enable:Bits) ListItem(Mode:Bits)
~> "seq.firmem.read_port" ( ListItem(MemId:String) ListItem(_) ListItem(ClkId:String) _:List ) { _:Map } :  (_) -> (T:IntegerType)
 => "seq.firmem.read_port.RL0" ( ListItem(Mem) ListItem(Addr) ListItem(Enable) ListItem(Mode) ) { .Map } : (.Types) -> (T) 
 ) ~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<signals> Signals:Map </signals>
<register> ... MemId |-> (_:Int, _:Int, 0:Int, _:Int, _:String) ... </register>
<history> H:Map </history>
[priority(30)]
```

#### Not Enabled

```k
rule
<current>
   ("seq.firmem.read_port.RL0" ( ListItem(_:Map) ListItem(_:Bits) ListItem(Enable:Bits) ListItem(Mode:Bits)) { _:Map } : (_) -> (T:IntegerType) 
   => ListItem(bits(0, getWidth(T)))) ~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<history> H:Map </history>
requires (notBool Bits2Bool(Enable)) orBool Bits2Bool(Mode)
[priority(30)]
```

#### Enabled

```k
rule
<current> 
  ("seq.firmem.read_port.RL0" ( ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(_Enable:Bits) ListItem(_Mode:Bits)) { _:Map } : (_) -> (T:IntegerType) 
=> ListItem(Mem[Addr] orDefault bits(0, getWidth(T)))) ~> "HARDWARE#WRITE" ~> ListItem(Port) 
...
</current>
<history> H:Map </history>
[priority(35)]
```

build RL processList
第一次进行read_port时RL processList没有在<register-proc>中，先初始化创建

```k
rule
<current> 
   ListItem(_) ListItem(Addr:Bits) _:List
~> "seq.firmem.read_port" ( ListItem(MemId:String) ListItem(_) ListItem(_) _:List ) { _:Map } :  (_) -> (T:IntegerType)
 ~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<signals> Signals:Map </signals>
<register> ... MemId |-> (_:Int, _:Int, RL:Int, _:Int, _:String) ... </register>
<register-proc> RegProc:Map => RegProc [Port <- buildRLList(RL, Addr)] </register-proc>
<history> H:Map </history>
requires notBool (Port in_keys(RegProc))
[priority(34)]
```


```k
rule
<current> 
   (ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) ListItem(Enable:Bits) ListItem(Mode:Bits)
~> "seq.firmem.read_port" ( ListItem(_) ListItem(_) ListItem(ClkId:String) _:List ) { _:Map } :  (_) -> (T:IntegerType)
 => "seq.firmem.read_port.stage2" ( ListItem(Mem) ListItem(checkEdge(0, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits)) 
 ListItem(Enable) ListItem(Addr) ListItem(Mode) ) { .Map } : (.Types) -> (T) 
 ) ~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<register-proc> ... Port |-> _:List ... </register-proc>
<history> H:Map </history>
[priority(35)]
```


use proprocessList Head to read
after 
if postive edge clk, write now aggr to processList tail and pop head

```k
rule
<current> 
   ("seq.firmem.read_port.stage2" ( ListItem(Mem:Map) ListItem(PosEdge:Bool) ListItem(EnableNew:Bits)
   ListItem(AddrNew:Bits) ListItem(ModeNew:Bits) ) { _:Map } : (_) -> (T:IntegerType)
 => ListItem(Mem[Addr] orDefault bits(0, getWidth(T)))) ~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<register-proc> ... ( Port |-> ListItem(Enable:Bits) ListItem(Addr:Bits) ListItem(Mode:Bits) L1:List => 
#if PosEdge #then Port |-> L1 ListItem(EnableNew) ListItem(AddrNew) ListItem(ModeNew)
#else  Port |-> ListItem(Enable) ListItem(Addr) ListItem(Mode) L1 #fi)
... </register-proc>
<history> H:Map </history>
requires (Bits2Bool(Enable)) andBool (notBool Bits2Bool(Mode))
[priority(35)]
```


```k
rule
<current> 
   ("seq.firmem.read_port.stage2" ( ListItem(Mem:Map) ListItem(PosEdge:Bool)  ListItem(EnableNew:Bits) 
   ListItem(AddrNew:Bits) ListItem(ModeNew:Bits) ) { _:Map } : (_) -> (T:IntegerType)
 => ListItem(bits(0, getWidth(T))))~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<register-proc> ... ( Port |-> ListItem(Enable:Bits) ListItem(Addr:Bits) ListItem(Mode:Bits) L1:List => 
#if PosEdge #then Port |-> L1 ListItem(EnableNew) ListItem(AddrNew) ListItem(ModeNew)
#else  Port |-> ListItem(Enable) ListItem(Addr) ListItem(Mode) L1 #fi)
... </register-proc>
<history> H:Map </history>
requires (notBool Bits2Bool(Enable)) orBool Bits2Bool(Mode)
[priority(35)]
```

### `seq.firmem.write_port`

```k
rule
<current> 
   ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) ListItem(Enable:Bits) ListItem(Data:Bits) L1:List
~> "seq.firmem.write_port" ( ListItem(MemId:String) L2:List ) { M1:Map } : FT
=> ListItem(S[MemId]) ListItem(Addr) ListItem(Clk) ListItem(Enable) ListItem(Data) L1
~> "seq.firmem.write_port.stage_write" ( ListItem(MemId) L2 ) { M1 } : FT
...
</current>
<signals> S:Map  </signals>
<history> _H:Map </history>
[priority(35)]
```

#### firmem without mask


```k
rule
<current> 
   ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) ListItem(Enable:Bits) ListItem(Data:Bits) _:List
~> "seq.firmem.write_port.stage_write" ( ListItem(MemId:String) ListItem(_) ListItem(ClkId:String) _:List ) { _:Map } : _FT
=> .K
...
</current>
<signals> S:Map => 
   #if checkEdge(0, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits) andBool Bits2Bool(Enable) 
   #then S [MemId <- Mem [Addr <- Data]] 
   #else S #fi 
</signals>
<history> H:Map </history>
[priority(35)]
```

#### firmem with mask

```k
rule
<current> 
   ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) ListItem(Enable:Bits) ListItem(Data:Bits) ListItem(Mask:Bits) _:List
~> "seq.firmem.write_port.stage_write" ( ListItem(MemId:String) ListItem(_) ListItem(ClkId:String) _:List ) { _:Map } : 
( !seq.firmem < _:Int x T1:Int , mask _MaskLength:Int > , _) -> (_) 
=> .K
...
</current>
<signals> S:Map => 
   #if checkEdge(0, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits) andBool Bits2Bool(Enable) 
   #then S [MemId <- Mem [Addr <- maskWrite(Mem, Data, Mask, Addr, T1)]] 
   #else S #fi 
</signals>
<history> H:Map </history>
[priority(35)]
```

### `seq.firmem.read_write_port`

#### checkMod

is writemode

```k
rule
<current> 
   ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) ListItem(Enable:Bits) ListItem(Data:Bits) ListItem(Mode:Bits) L1:List
~> "seq.firmem.read_write_port" ( ListItem(MemId:String) ListItem(AddrId:String) ListItem(ClkId:String) ListItem(EnableId:String) 
  ListItem(DataId:String) ListItem(ModeId:String) L2:List ) { M1:Map } : FT
 ~> "HARDWARE#WRITE" ~> ListItem(Port)
 => ListItem(S[MemId]) ListItem(Addr) ListItem(Clk) ListItem(Enable) ListItem(Data) ListItem(Mode) L1
~> "seq.firmem.read_write_port.stage_write" ( ListItem(MemId) ListItem(AddrId:String) ListItem(ClkId:String) ListItem(EnableId:String) 
 ListItem(DataId) ListItem(ModeId) L2 ) { M1 } : FT
 ~> ListItem(Mem) ListItem(Addr) ListItem(Clk) ListItem(Enable) ListItem(Mode) 
~> "seq.firmem.read_port" ( ListItem(MemId) ListItem(AddrId:String) ListItem(ClkId:String) ListItem(EnableId:String) ListItem(ModeId) ) { M1 } : FT
 ~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<signals> S:Map </signals>
<history> H:Map </history>
requires Bits2Bool(Mode)
[priority(30)]
```

readmode can change to read_port

```k
rule
<current> 
   ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) ListItem(Enable:Bits) ListItem(Data:Bits) ListItem(Mode:Bits) L1:List
~> "seq.firmem.read_write_port" ( ListItem(MemId:String) ListItem(AddrId:String) ListItem(ClkId:String) ListItem(EnableId:String) 
   ListItem(DataId:String) ListItem(ModeId:String) L2:List ) { M1:Map } : FT
 ~> "HARDWARE#WRITE" ~> ListItem(Port)
 => ListItem(Mem) ListItem(Addr) ListItem(Clk) ListItem(Enable) ListItem(Mode:Bits)
~> "seq.firmem.read_port" ( ListItem(MemId) ListItem(AddrId:String) ListItem(ClkId:String) ListItem(EnableId:String) ListItem(ModeId:String) ) { M1 } : FT
 ~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<signals> S:Map </signals>
<history> H:Map </history>
requires notBool Bits2Bool(Mode)
[priority(30)]
```

#### writemode

```k
rule
<current> 
   ListItem(_) ListItem(_) ListItem(_) ListItem(Enable:Bits) _:List
~> "seq.firmem.read_write_port.stage_write" ( _:List ) { _:Map } :  (_) -> (T:IntegerType)
=> .K
...
</current>
<signals> Signals:Map </signals>
<history> H:Map </history>
requires notBool Bits2Bool(Enable)
[priority(35)]
```

#### without mask

```k
rule
<current> 
   ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) ListItem(Enable:Bits) ListItem(Data:Bits) ListItem(Mode:Bits)
~> "seq.firmem.read_write_port.stage_write" ( ListItem(MemId:String) ListItem(_) ListItem(ClkId:String) _:List ) { _:Map } : (_) -> (T:IntegerType)
=> .K
...
</current>
<signals> S:Map => 
   #if checkEdge(0, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits) 
   #then S [MemId <- Mem [Addr <- Data]] 
   #else S #fi 
</signals>
<history> H:Map </history>
[priority(35)]
```

#### with mask

```k
rule
<current> 
   ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) ListItem(Enable:Bits) ListItem(Data:Bits) ListItem(Mode:Bits) 
   ListItem(Mask:Bits)
~> "seq.firmem.read_write_port.stage_write" ( ListItem(MemId:String) ListItem(_) ListItem(ClkId:String) _:List ) { _:Map } : 
( !seq.firmem < _:Int x T1:Int , mask _MaskLength:Int > , _) -> (T:IntegerType)
=> .K
...
</current>
<signals> S:Map => 
   #if checkEdge(0, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits) 
   #then S [MemId <- Mem [Addr <- maskWrite(Mem, Data, Mask, Addr, T1)]] 
   #else S #fi 
</signals>
<history> H:Map </history>
[priority(35)]
```

```k
endmodule
```
