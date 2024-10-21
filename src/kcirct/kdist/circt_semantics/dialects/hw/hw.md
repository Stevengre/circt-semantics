# HW Dialect

```k
requires "hw-syntax.md"
requires "../../mlir/mlir-config.md"
requires "../../mlir/mlir-helper.md"
requires "../../circt/circt-config.md"
requires "../../hardware/hardware-config.md"
requires "hw-config.md"
requires "hw-helper.md"
module HW
  imports HW-SYNTAX
  imports MLIR-CONFIG
  imports CIRCT-CONFIG
  imports HARDWARE-CONFIG
  imports HW-CONFIG
  imports MLIR-HELPER
  imports MAP
  imports HW-HELPER
  imports BOOL
```

## Helper Rules

### `HW#NEW_INSTANCE`

```k
rule 
<setup> .K ~> "HW#NEW_INSTANCE" => .K ... </setup>
<hw-setup-inst> Insts:List ListItem(_) => Insts </hw-setup-inst>
```

### Auto Connect

```k
rule
<setup> 
   ListItem(S:String) = Op (Args) {Attr:Map} : FT
=> "HARDWARE#CONNECT" 
~> Abs(AbsSymbolName(L), ListItem(S)) 
~> ListItem(Op (Abs(AbsSymbolName(L), Args)) {Attr:Map} : FT)
... 
</setup>
<hw-setup-inst> L </hw-setup-inst>
[priority(170)]
```

### Auto Procedure

### GET_INS_OUTS

```k

rule
<cmd> TM:String => Ins ... </cmd>
<hw-instances>
<hw-instance>
    <hw-id> TM </hw-id>
    <hw-inports> Ins:List => Ins </hw-inports>
    <hw-outports> Outs:List => Outs </hw-outports>
    ...
</hw-instance>
...
</hw-instances>

// rule
// <currents>
// ...
// <current-info>
// <current-id> _ </current-id>
// <current>
// (   "HW#SIMULATE" ~> TM:String ~> STIMULI:List 
// => STIMULI ~> "HARDWARE#WRITE" ~> Ins 
// ~> Outs)
// ...
// </current>
// </current-info>
// ...
// </currents>
// // <hw-instances>
// // ...
// // <hw-instance>
//     <hw-id> TM </hw-id>
//     // <hw-module> _ </hw-module>
//     // <hw-inputs> _ </hw-inputs>
//     <hw-inports> Ins:List </hw-inports>
//     // <hw-in-types> _ </hw-in-types>
//     // <hw-outputs> _ </hw-outputs>
//     <hw-outports> Outs:List </hw-outports>
//     // <hw-out-types> _ </hw-out-types>
// // </hw-instance>
// // ...
// // </hw-instances>
// // requires Inports ==K Ins andBool Outports ==K Outs
```

## hw.module

Top Module
```k
rule 
<setup> "hw.module" (.List) {Attr:Map} _ ({_ (VTs) : Ops:StdOps .StdBlocks}:StdRegion) : (.Types) -> (.Types) => Ops ~> "HW#NEW_INSTANCE" ... </setup>
<hw-setup-inst> .List => ListItem(Attr["sym_name"]) </hw-setup-inst>
(
    .Bag
=>  <hw-instance>
        <hw-id> AbsSymbolName(ListItem(Attr["sym_name"])) </hw-id>
        <hw-module> AbsSymbolName(ListItem(Attr["sym_name"])) </hw-module>
        <hw-inputs> getModuleInNames({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-inputs>
        <hw-inports> Abs(AbsSymbolName(ListItem(Attr["sym_name"])), StringList(VTs)) </hw-inports>
        <hw-in-types> getModuleInTypes({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-in-types>
        <hw-outputs> getModuleOutNames({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-outputs>
        <hw-out-types> getModuleOutTypes({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-out-types>
        ...
    </hw-instance>
)
```

```k
rule 
<setup>
   "hw.module" (.List) {Attr:Map} _ ({_ (VTs) : Ops:StdOps .StdBlocks}:StdRegion) : (.Types) -> (.Types)
~> "HARDWARE#CONNECT" ~> "HARDWARE#OUTS" ~> INS:List
=> "HARDWARE#CONNECT" ~> Abs(AbsSymbolName(L), StringList(VTs)) ~> INS
~> Ops
...
</setup>
<hw-setup-inst> L </hw-setup-inst>
(
    .Bag
=>  <hw-instance>
        <hw-id> AbsSymbolName(L) </hw-id>
        <hw-module> AbsSymbolName(ListItem(Attr["sym_name"])) </hw-module>
        <hw-inputs> getModuleInNames({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-inputs>
        <hw-inports> Abs(AbsSymbolName(L), StringList(VTs)) </hw-inports>
        <hw-in-types> getModuleInTypes({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-in-types>
        <hw-outputs> getModuleOutNames({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-outputs>
        <hw-out-types> getModuleOutTypes({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </hw-out-types>
        ...
    </hw-instance>
)
```

## hw.instance

```k
rule 
<setup> 
    Outs = "hw.instance" (Args) {Attr:Map} : (T1) -> (T2) 
=> "hw.instance" (Args) {Attr} : (T1) -> (T2)
~> "HARDWARE#CONNECT" ~> Abs(AbsSymbolName(L), Outs) ~> "HARDWARE#INS"
...
</setup>
<hw-setup-inst> L </hw-setup-inst>

rule 
<setup> 
   "hw.instance" (Args) {Attr:Map} : (_) -> (_) 
=> "CIRCT#GET_OP" ~> Attr["moduleName"]
~> "HARDWARE#CONNECT" ~> "HARDWARE#OUTS" ~> Abs(AbsSymbolName(L), Args)
~> "HW#NEW_INSTANCE"
... 
</setup>
<hw-setup-inst> L => L ListItem(Attr["instanceName"]) </hw-setup-inst>
```

## hw.output

```k
rule
<setup>
   "hw.output" (Args) {_:Map} : _
~> .StdOps 
~> "HW#NEW_INSTANCE" 
~> "HARDWARE#CONNECT" ~> OUTS:List ~> "HARDWARE#INS"
=> .K ~> "HW#NEW_INSTANCE"
~> "HARDWARE#CONNECT" ~> OUTS ~> Abs(ABS_NAME, Args)
...
</setup>
<hw-setup-inst> L:List </hw-setup-inst>
<hw-instance>
  <hw-id> ABS_NAME </hw-id>
  <hw-outports> .List => Abs(ABS_NAME, Args) </hw-outports>
  ...
</hw-instance>
requires ABS_NAME ==K AbsSymbolName(L) andBool size(L) >Int 1

rule
<setup>
   "hw.output" (Args) {_:Map} : _
~> .StdOps 
~> "HW#NEW_INSTANCE" 
=> .K ~> "HW#NEW_INSTANCE"
...
</setup>
<hw-setup-inst> ListItem(S) </hw-setup-inst>
<hw-instance>
  <hw-id> ABS_NAME </hw-id>
  <hw-outports> .List => Abs(ABS_NAME, Args) </hw-outports>
  ...
</hw-instance>
requires ABS_NAME ==K AbsSymbolName(ListItem(S))
```

```k
endmodule
```
