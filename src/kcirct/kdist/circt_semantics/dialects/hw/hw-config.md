# HW Dialect Configuration

This config is an extension of `<circt>`.


- `<hw-instances>`: a list of hardware instances
- `<hw-id>`: the absolute id of the hardware instance
- `<hw-inputs>`: a list of module input names
- `<hw-inports>`: a list of the absolute port id in `<signals>`
- `<hw-outputs>`: a list of module output names
- `<hw-outports>`: a list of the absolute port id in `<signals>`
- `<hw-setup-inst>`: current setup instance

```k
module HW-CONFIG
imports MAP
imports STRING
imports LIST

configuration
<hw>
  <hw-instances>
    <hw-instance multiplicity="*" type="Map">
      <hw-id> "" </hw-id>
      <hw-module> "" </hw-module>
      <hw-inputs> .List </hw-inputs>
      <hw-inports> .List </hw-inports>
      <hw-in-types> .List </hw-in-types>
      <hw-outputs> .List </hw-outputs>
      <hw-outports> .List </hw-outports>
      <hw-out-types> .List </hw-out-types>
    </hw-instance>
    // auxiliary cells
    <hw-setup-inst> .List </hw-setup-inst>

    // <ckt multiplicity="*" type="Map">
    //             <cid> "" </cid>
    //         <always> .List </always>
    //         <initial> .List </initial>
    //         <k> .K </k>
    //         <parent> "" </parent>
    //         <last> .Map </last>
    //         <last-vars> .Set </last-vars>
    //         <locals> .Map </locals>
    //         <module> "" </module>
    //         <in-names> .List </in-names>
    //         <in-ports> .Map  </in-ports>
    //         <in-vars> .ValueIdAndTypeList </in-vars>
    //         <out-names> .List </out-names>
    //         <out-ports> .List </out-ports>
    //         <out-vars> .ValueIdList </out-vars>
    //         <args> .List </args>
    //         <regs> .Map </regs>
    //         <wires> .Map </wires>
    //         <firmem> .Map </firmem>
    //         // <lock> false </lock>
    //     </ckt>
  </hw-instances>
</hw>
endmodule
```