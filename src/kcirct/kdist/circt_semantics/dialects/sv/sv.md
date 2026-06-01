# SV Dialect

```k
requires "sv-syntax.md"
requires "../../circt/circt.md"
requires "../../hardware/verification.md"
requires "../../hardware/hardware.md"
module SV
imports VERIFICATION
imports SV-SYNTAX
imports HARDWARE
imports CIRCT
```

## sv.initial

```k
rule 
<setup> 
   "HARDWARE#PROCEDURE" ~> "sv.initial" ( .List ) {_:Map} _SL ( R:StdRegion ) : _FT 
=> .K ... 
</setup>
(  .Bag
=> <current-info>
    <current-id> !_:Int </current-id>
    <current> R </current>
   </current-info>
)
```

## sv.always

```k
rule
<current> 
   ListItem(Clk:Bits) Clks:List
~> "sv.always" ( ListItem(ClkId:String) ClkIds:List ) { "events" |-> [ Event:Int : _:IntegerType , AL:AttributeValueList ] M:Map } SL:SuccessorList ( R:StdRegion ) : FT
=> #if checkEdge(Event, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits) 
   #then ( Clks ~> "sv.always" ( ClkIds ) { "events" |-> [ AL ] M } SL ( R ) : FT )
   #else .K #fi
... 
</current>
<history> H:Map </history>
[priority(35)]

rule
<current> 
   ListItem(Clk:Bits)
~> "sv.always" ( ListItem(ClkId:String) ) { "events" |-> [ Event:Int : _:IntegerType ] _:Map } _SL:SuccessorList ( R:StdRegion ) : _FT
=> #if checkEdge(Event, Clk, {H[ClkId] orDefault bits(#x, 1)}:>Bits) 
   #then R
   #else .K #fi
... 
</current>
<history> H:Map </history>
[priority(30)]
```

## sv.alwayscomb

```k
rule
<current> 
   "sv.alwayscomb" ( .List ) {_Attrs:Map} _SL:SuccessorList ( R:StdRegion ) : _FT
=>  R
... 
</current>
<history> H:Map </history>
[priority(30)]
```

## sv.for

### Stop Condition

```k
rule
<current>
   "sv.for" ( ListItem(bits(Start:Int, _:Int)) ListItem(bits(End:Int, _:Int)) ListItem(bits(_Step:Int, _:Int)) ) {_:Map} _SL:SuccessorList ( _R:StdRegion ) : _FT
=> .K
... 
</current>
requires Start >=Int End
```

### Loop Body

```k
rule
<current>
   "sv.for" ( ListItem(bits(Start:Int, W0:Int)) ListItem(bits(End:Int, W1:Int)) ListItem(bits(Step:Int, W2:Int)) ) {Attr:Map} SL:SuccessorList ( { BID ( ListItem(VID:String) ) : Ops:StdOps } ) : FT
=> ListItem(bits(Start, W0:Int)) ~> "HARDWARE#WRITE" ~> ListItem(VID)
~> Ops 
~> "sv.for" ( ListItem(bits(Start +Int Step, W0:Int)) ListItem(bits(End, W1:Int)) ListItem(bits(Step, W2:Int)) ) {Attr:Map} SL:SuccessorList ( { BID ( ListItem(VID:String) ) : Ops:StdOps } ) : FT
... 
</current>
requires Start <Int End
```

## sv.macro.decl

not found in rocket-small-master.generic.mlir

## sv.ifdef

not found in rocket-small-master.generic.mlir

## sv.reg

not found in rocket-small-master.generic.mlir

## sv.read_inout

not found in rocket-small-master.generic.mlir

## sv.passign

not found in rocket-small-master.generic.mlir

## Not Implemented But Quick Pass

### Messages

```k
rule
<current>
   "sv.error" ( .List ) { "message" |-> Msg:String _:Map} : _FT
=> svError(Msg)
... 
</current>
<sv-logs> 
   ... .List => ListItem("FATAL ERROR: " +String Msg) 
</sv-logs>

rule
<current>
   "sv.info" ( .List ) { "message" |-> Msg:String _:Map} : _FT
=> .K
... 
</current>
<sv-logs> 
   ... .List => ListItem("INFO: " +String Msg)
</sv-logs>

rule
<current>
   "sv.warning" ( .List ) { "message" |-> Msg:String _:Map} : _FT
=> .K
... 
</current>
<sv-logs> 
   ... .List => ListItem("WARNING: " +String Msg)
</sv-logs>

rule
<current>
   "sv.verbatim" ( .List ) { "format_string" |-> _F:String "symbols" |-> _S _:Map} : _FT
=> .K
... 
</current>
```

### Tasks

```k
rule
<current>
   "sv.finish" ( .List ) { "verbosity" |-> _V _:Map} : _FT
=> .K
... 
</current>

rule
<current>
   "sv.exit" ( .List ) {_:Map} : _FT
=> .K
... 
</current>

rule
<current>
   "sv.fatal" ( .List ) { "verbosity" |-> _V _:Map} : _FT
=> .K
... 
</current>
```

### Assertions

```k
rule
<current>
   "sv.assert" ( ListItem(Cond:Bits) ) { ("defer" |-> _D) ("label" |-> L:String) _:Map} : _FT
=> #verifyAssert(Cond, L)
... 
</current>
```

### sv.if

```k
rule
<current>
   "sv.if" ( ListItem(_Cond:Bits) ) {_:Map} _SL:SuccessorList ( _R1:StdRegion , _R2:StdRegion ) : _FT
=> .K
... 
</current>
```

```k
endmodule
```
