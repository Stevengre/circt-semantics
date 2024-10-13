#loc = loc("a.mlir":1:54)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0(%clk: !seq.clock):
        %0 = "hw.constant"() {value = 0 : i8} : () -> i8
        %1 = "hw.constant"() {value = 1 : i8} : () -> i8
        %reg = "seq.firreg"(%next, %clk) <{name = "reg"}> {firrtl.random_init_start = 0 : i8} : (i8, !seq.clock) -> i8
        %next = "comb.add"(%reg, %1) : (i8, i8) -> i8
        "hw.output"(%reg) : (i8) -> ()
    }) {module_type = !hw.modty<input clk : !seq.clock,  output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()

// krun tests/firreg.mlir -cEntry='"Foo"' -cInput="ListItem( ListItem(bits(0, 1) : i1) ) ListItem( ListItem(bits(1, 1) : i1) )" -d main-llvm

// ListItem( ListItem(bits(0, 1) : i1) ListItem(bits(0, 1) : i1) )
// ListItem( ListItem(bits(1, 1) : i1) ListItem(bits(1, 1) : i1) )
// ListItem( ListItem(bits(0, 1) : i1) ListItem(bits(0, 1) : i1) )
// ListItem( ListItem(bits(1, 1) : i1) ListItem(bits(0, 1) : i1) )
// ListItem( ListItem(bits(0, 1) : i1) ListItem(bits(0, 1) : i1) )
// ListItem( ListItem(bits(1, 1) : i1) ListItem(bits(0, 1) : i1) )