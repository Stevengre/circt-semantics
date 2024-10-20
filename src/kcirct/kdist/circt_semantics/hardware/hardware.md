# Hardware Semantics

```k
requires "hardware-config.md"
module HARDWARE
imports HARDWARE-CONFIG
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


```k
endmodule
```