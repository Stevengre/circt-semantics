# Hardware Semantics

```k
requires "hardware-config.md"
requires "hardware-helper.md"
requires "bits.md"
requires "../mlir/builtin.md"
requires "../circt/circt.md"
module HARDWARE
imports HARDWARE-CONFIG
imports HARDWARE-HELPER
imports BUILTIN-SYNTAX
imports CIRCT
imports BUILTIN
imports INT
imports BITS
imports STRING
```

## Connect 

```k
rule
<setup> 
   "HARDWARE#CONNECT" ~> ListItem(Out) L0:List ~> ListItem(In) L1:List
=> "HARDWARE#CONNECT" ~> L0 ~> L1
...
</setup>
<connection> M => M [Out <- In] </connection>

rule
<setup> "HARDWARE#CONNECT" ~> .List ~> .List => .K ... </setup>
```

## Setup Procedures

```k
rule <setup> "HARDWARE#PROCEDURE" ~> Op => .K ... </setup>
<procedures> PROCS:List => ListItem(Op) PROCS </procedures>
```

## Read

```k
rule
<current> 
   "HARDWARE#READ" ~> L:List 
=> L ~> .List ~> "HARDWARE#READ_DIRECT" ~> L
... 
</current>

rule
<current> 
   READ:List ~> "HARDWARE#READ_DIRECT" ~> .List => READ ... 
</current>

rule
<current> 
   READ:List ~> "HARDWARE#READ_DIRECT" ~> ListItem(Port:String) L:List 
=> READ ListItem(Signal) ~> "HARDWARE#READ_DIRECT" ~> L
... 
</current>
<signals> ... Port |-> Signal:Bits ... </signals>
<register> Register:Map </register>
requires notBool (Port in_keys(Register))

rule
<current> 
   READ:List ~> "HARDWARE#READ_DIRECT" ~> ListItem(Port:String) L:List 
=> READ ListItem(H[Port] orDefault bits(0, T)) ~> "HARDWARE#READ_DIRECT" ~> L
... 
</current>
<history> H:Map </history>
<register> ... Port |-> (RegType:Int, T:Int, RL:Int, _:Int) ... </register>
requires RegType ==Int 0

rule
<current> 
   READ:List ~> "HARDWARE#READ_DIRECT" ~> ListItem(Port:String) L:List 
=> READ ListItem(H[Port] orDefault .Map) ~> "HARDWARE#READ_DIRECT" ~> L
... 
</current>
<history> H:Map </history>
<register> ... Port |-> (RegType:Int, T:Int, RL:Int, _:Int) ... </register>
requires RegType ==Int 1

```

## Read with Last Values

## Write

```k
rule
<current> 
   L0:List ListItem(Stimuli:Bits) ~> "HARDWARE#WRITE" ~> L1:List ListItem(Port:String)  
=> L0 ~> "HARDWARE#WRITE" ~> L1
...
</current>
<signals> M => M [Port <- Stimuli] </signals>

rule
<current> 
   L0:List ListItem("HARDWARE#KEEP") ~> "HARDWARE#WRITE" ~> L1:List ListItem(_:String)  
=> L0 ~> "HARDWARE#WRITE" ~> L1
...
</current>

rule
<current> .List ~> "HARDWARE#WRITE" ~> .List => .K ... </current>

rule
<current> "HARDWARE#WRITE" ~> .List => .K ... </current>
```

## New Current

```k
rule 
<current> 
   "HARDWARE#NEW_CURRENT" ~> ListItem(Op) L:List 
=> "HARDWARE#NEW_CURRENT" ~> L 
...
</current>
(  .Bag
=> <current-info>
    <current-id> !_:Int </current-id>
    <current> Op </current>
   </current-info>
)
[priority(195)]

rule
<current> "HARDWARE#NEW_CURRENT" ~> .List => .K ... </current>
[priority(195)]
```

## Join Currents

```k
rule
(
   <current-info>
      <current> .K </current>
      ...
   </current-info>
=> .Bag
)
```

## Read Evaluate Ports

- If the port connected to another port, then evaluate the other port.

```k
rule
<current> 
   ListItem(Port:String) L:List 
=> "HARDWARE#READ" ~> ListItem(Port1) 
~> "HARDWARE#WRITE" ~> ListItem(Port)
~> L
... 
</current>
<connection> ... Port |-> Port1:String ... </connection>
[priority(160)]

rule
<current>
   ListItem(Port:String) L:List 
=> L 
...
</current>
<signals> ... Port |-> _:Bits ... </signals>
[priority(170)]

rule
<current>
   ListItem(Port:String) L:List 
=> Comp ~> "HARDWARE#WRITE" ~> ListItem(Port) 
~> L 
...
</current>
<connection> ... Port |-> Comp ... </connection>
[priority(180)]

rule
<current> 
   .List 
=> .K ... 
</current>
[priority(190)]
```

```k
endmodule
```