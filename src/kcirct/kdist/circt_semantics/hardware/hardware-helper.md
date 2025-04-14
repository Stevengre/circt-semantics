# Hardware Helper

```k
requires "hardware-config.md"
requires "bits.md"
requires "../mlir/mlir-helper.md"
module HARDWARE-HELPER
imports HARDWARE-CONFIG
imports BITS
imports STRING
imports MLIR-HELPER-SYNTAX
imports BOOL
```

### check in is a register

```k
// syntax Bool ::= checkRegister(In:StdOp) [function]
// rule checkRegister("seq.firreg" ...) => true 
// rule checkRegister("seq.firmem" ...) => true
// rule checkRegister(_:StdOp) => false
// ```
// // String "(" List ")" "{" Map "}" ":" StdFT
// //                | String "(" List ")" "{" Map "}" SuccessorList "(" StdRegions ")" ":" StdFT
// ### get latency config

// ```k
// syntax Name ::= ${} 
```

```k
endmodule
```