seq.from_clock
```mlir

```


seq.firmem.read_write_port
```mlir
hw.module @Foo(in %clk: !seq.clock, out res: i8) {
    %mem = seq.firmem 1, 1, undefined, port_order {prefix = ""} : <512 x 8>
    %addr = hw.constant 9 : i9
    %data = hw.constant 2 : i8
    %mode = hw.constant 1 : i1
    %enable = hw.constant 1 : i1
    %out = seq.firmem.read_write_port %mem [%addr] = %data if %mode, clock %clk enable %enable : <512 x 8>
    hw.output %out : i8
}
```