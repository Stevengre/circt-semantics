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
=> #if checkEdge("posedge", Clk, ClkLast) #then ListItem(Next) #else ListItem("HARDWARE#KEEP") #fi
... 
</current>
<history> ... ClkId |-> ClkLast:Bits ... </history>
[priority(35)]

rule
<current> 
   ListItem(Next:Bits) ListItem(Clk:Bits) ListItem(Rst:Bits) ListItem(RstValue:Bits)
~> "seq.firreg" ( ListItem(_:String) ListItem(ClkId:String) _:List ) { _:Map } : _FT
=> #if checkEdge("posedge", Clk, ClkLast) 
   #then ( #if Bits2Bool(Rst) #then ListItem(RstValue) #else ListItem(Next) #fi )
   #else ListItem("HARDWARE#KEEP") #fi
... 
</current>
<history> ... ClkId |-> ClkLast:Bits ... </history>
[priority(35)]
```

## `seq.firmem`

### `seq.firmem.read_port`

### `seq.firmem.write_port`

### `seq.firmem.read_write_port`


```k
endmodule
```
