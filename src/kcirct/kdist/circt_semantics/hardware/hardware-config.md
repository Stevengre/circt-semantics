# Hardware Configuration

```k
module HARDWARE-CONFIG
  imports INT
  imports LIST
  imports MAP
configuration
<hardware>
```

## Hardware Structure

- `<setup>`: hardware setup through top module
- `<connection>`: out_port_id -> components + out_port_id 
- `<procedures>`: all the procedure blocks in the circuit

```k
  <setup> .K </setup>
  <connection> .Map </connection>
  <procedures> .List </procedures>
```

## Hardware Activity

- `<signals>`: port_id -> signal value
- `<historys>`: list of signals from old to new
- `<currents>`: current flows of circuit
- `<current>`: current flow of a hardware component
- `<clock>`: current clock cycle
- `<history-depth>`: number of clock cycles to keep in history

```k
  <signals> .Map </signals>
  <history> .Map </history>
  // <historys> <history multiplicity="*" type="List"> .Map </history> </historys>
  <currents>
    <current-info multiplicity="*" type="Map">
      <current-id> 0:Int  </current-id>
      <current> .K </current>
    </current-info>
  </currents>
  // auxiliary cells
  <clock> 0 </clock>
  // <history-depth> $HDepth:Int </history-depth>
```

```k
</hardware>
endmodule
```