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

- `<register>`: Stores constant attributes of ports with "register" behavior 
— meaning that when the port is read, 
its value is retrieved from history rather than directly from the signal (e.g., firmem, firreg).
The structure is as follows (with 0 used as a placeholder if not otherwise specified):
port |-> (
  {1 for firmem, 0 for firreg},
  {if firreg: its size in bits — when first read, a bit-vector of this size filled with 0 is used to initialize history},
  {if firmem: read latency},
  {if firmem: write latency},
  {name — used for VCD output}
)
Since the write operation occurs at the end of the rising edge, in implementation, 
writes go into <signal> while reads come from <history>.
If a port exists in register, then its value must be read from the history during simulation.

- `<register-proc>`: Stores the procedure of delayed read behavior for firmem.
readLatency operates by delaying the enable, mode, and address signals of the current read port by x cycles.
If the readLatency is x, the structure is:
port |-> enable1, addr1, mode1, ... , enbalex, addrx, modex
Each time a read_port operation occurs, the current parameters (enable, address, mode) are appended to the end of the list,
and the parameters at the head of the list are popped.
The return value of the current read is determined by the parameters at the head of the list (i.e., those x cycles ago).
- `<sv-logs>`: SV logs

```k
  <setup> .K </setup>
  <connection> .Map </connection>
  <procedures> .List </procedures>
  <register> .Map </register>
  <register-proc> .Map </register-proc>
  <sv-logs> .List </sv-logs>
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
