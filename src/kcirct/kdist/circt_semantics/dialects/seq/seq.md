# SEQ Dialect

```k
requires "seq-syntax.md"
requires "../../hardware/bits.md"
requires "../../hardware/hardware.md"
requires "../../mlir/builtin.md"
requires "../../mlir/mlir-helper.md"
module SEQ
imports SEQ-SYNTAX
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
(.K => ListItem(bits(V, getWidth(T))) ~> "HARDWARE#WRITE" ~> ListItem(Port)) 
~> "seq.firreg" ( ListItem(_:String) _:List ) { "firrtl.random_init_start" |-> V:Int : _:Type _:Map } : (_) -> (T:IntegerType) 
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

### Setup Current Signal Before Update

```k
rule
<current> 
(.K => ListItem(H[Port] orDefault .Map) ~> "HARDWARE#WRITE" ~> ListItem(Port)) 
~> "seq.firmem" ( .List ) { _:Map } : _FT 
~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<signals> Signals:Map </signals>
<history> H:Map </history>
requires notBool (Port in_keys(Signals))
[priority(35)]
```

### `seq.firmem.read_port`

#### Setup Current Signal Before Update

```k
rule
<current> 
(.K => ListItem(H[Port] orDefault bits(#x, getWidth(T))) ~> "HARDWARE#WRITE" ~> ListItem(Port)) 
~> "seq.firmem.read_port" ( _:List ) { _:Map } : (_) -> (T:IntegerType) 
~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<signals> Signals:Map </signals>
<history> H:Map </history>
requires notBool (Port in_keys(Signals))
[priority(35)]
```

#### Not Enabled

```k
rule
<current> 
   ListItem(_) ListItem(_) ListItem(_) ListItem(Enable:Bits)
~> "seq.firmem.read_port" ( _:List ) { _:Map } : _FT
=> ListItem("HARDWARE#KEEP")
</current>
requires notBool Bits2Bool(Enable)
[priority(30)]
```

#### Enabled

```k
rule
<current> 
   ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) _:List
~> "seq.firmem.read_port" ( ListItem(_) ListItem(_) ListItem(ClkId:String) _:List ) { _:Map } : (_) -> (T:IntegerType)
=> #if checkEdge(0, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits) 
   #then Mem[Addr] orDefault bits(#x, getWidth(T))
   #else ListItem("HARDWARE#KEEP") #fi
...
</current>
<history> H:Map </history>
[priority(35)]
```

### `seq.firmem.write_port`

```k
rule
<current> 
   ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) ListItem(Enable:Bits) ListItem(Data:Bits) _:List
~> "seq.firmem.write_port" ( ListItem(MemId:String) ListItem(_) ListItem(ClkId:String) _:List ) { _:Map } : _FT
=> .K
...
</current>
<signals> S:Map => 
   #if checkEdge(0, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits) andBool Bits2Bool(Enable) 
   #then S [MemId <- Mem[Addr <- Data]] 
   #else S #fi 
</signals>
<history> H:Map </history>
[priority(35)]
```

### `seq.firmem.read_write_port`

#### Setup Current Signal Before Update

```k
rule
<current> 
(.K => ListItem(H[Port] orDefault bits(#x, getWidth(T))) ~> "HARDWARE#WRITE" ~> ListItem(Port)) 
~> "seq.firmem.read_port" ( _:List ) { _:Map } : (_) -> (T:IntegerType) 
~> "HARDWARE#WRITE" ~> ListItem(Port)
...
</current>
<signals> Signals:Map </signals>
<history> H:Map </history>
requires notBool (Port in_keys(Signals))
[priority(35)]
```

#### Update

```k
rule
<current> 
   ListItem(Mem:Map) ListItem(Addr:Bits) ListItem(Clk:Bits) ListItem(Enable:Bits) ListItem(Data:Bits) ListItem(Mode:Bits)
~> "seq.firmem.read_write_port" ( ListItem(MemId:String) ListItem(_) ListItem(ClkId:String) _:List ) { _:Map } : _FT
=> #if Bits2Bool(Enable) andBool (notBool Bits2Bool(Mode)) andBool checkEdge(0, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits) 
   #then ListItem(Mem)
   #else ListItem("HARDWARE#KEEP") #fi
...
</current>
<signals> S:Map => 
   #if Bits2Bool(Enable) andBool Bits2Bool(Mode) andBool checkEdge(0, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits) 
   #then S [MemId <- Mem[Addr <- Data]] 
   #else S #fi 
</signals>
<history> H:Map </history>
[priority(35)]
```



```k
endmodule
```
