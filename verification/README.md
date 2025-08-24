# K-CIRCT Verification Framework

This directory contains a comprehensive verification framework for K-CIRCT, demonstrating formal verification of hardware designs using the K framework for CIRCT IR languages.

## Overview

The verification framework implements two key verification cases that showcase the power of K-CIRCT for formal hardware verification:

1. **Constant Folding Equivalence**: Proves that compiler optimizations preserve semantic equivalence
2. **Arithmetic Safety**: Verifies overflow detection properties in hardware arithmetic operations

## Directory Structure

```
verification/
├── cases/                          # MLIR hardware designs to verify
│   ├── constant_folding_original.mlir    # Original: %c5 = 5, %c3 = 3, %sum = add %c5, %c3
│   ├── constant_folding_optimized.mlir   # Optimized: %c8 = 8
│   └── adder_4bit_overflow.mlir          # 4-bit adder with overflow detection
├── specs/                          # K framework specifications
│   ├── constant_folding_spec.k          # Equivalence verification claims
│   └── arithmetic_safety_spec.k         # Overflow detection claims
├── scripts/                        # Verification automation scripts
│   ├── verify_constant_folding.sh       # Run constant folding verification
│   ├── verify_arithmetic_safety.sh      # Run arithmetic safety verification
│   └── run_all_verifications.sh         # Run complete verification suite
├── results/                        # Generated verification results
│   └── verification_summary.md          # Master verification report
└── README.md                       # This file
```

## Verification Cases

### Case 1: Constant Folding Equivalence

**Property**: Constant folding optimizations preserve semantic equivalence.

**Original MLIR**:
```mlir
%c5 = hw.constant 5 : i8
%c3 = hw.constant 3 : i8  
%sum = comb.add %c5, %c3 : i8
hw.output %sum : i8
```

**Optimized MLIR**:
```mlir
%c8 = hw.constant 8 : i8
hw.output %c8 : i8
```

**Verification Claims**:
- Both versions produce the same output: `?OriginalResult ==Int ?OptimizedResult`
- Original computation is correct: `5 + 3 = 8`
- Optimized constant is correct: `8 = 8`

### Case 2: Arithmetic Safety (Overflow Detection)

**Property**: For 4-bit addition, overflow flag is true iff the arithmetic sum ≥ 16.

**MLIR Design**: 4-bit adder with overflow detection
```mlir
^bb0(%a: i4, %b: i4):
    %sum_ext = comb.add %a_ext, %b_ext : i5
    %sum = comb.extract %sum_ext {lowBit = 0} : i5 -> i4
    %overflow = comb.extract %sum_ext {lowBit = 4} : i5 -> i1
    hw.output %sum, %overflow : i4, i1
```

**Verification Claims**:
- General overflow property: `(?Overflow ==Int 1) ==Bool ((A +Int B) >=Int 16)`
- No overflow case: When `A + B < 16`, then `overflow = 0` and `sum = A + B`
- Overflow case: When `A + B ≥ 16`, then `overflow = 1` and `sum = (A + B) mod 16`

## K Framework Claim Structure

The verification uses K's reachability logic with the following structure:

```k
claim
    <mlir>
        <prog> .K </prog>
        <phase> #build </phase>
        <types> .Map </types>
        <attrs> .Map </attrs>
        <table> .Map </table>
    </mlir>
    <cmd> #always => #end </cmd>
    <entry> "ModuleName" </entry>
    <ckts>
        <ckt>
            <cid> "ModuleName" </cid>
            <locals> ... MLIR operations ... </locals>
            <args> ListItem ( bits ( A:Int , 4 ) : i4 ) ... </args>
            <out-ports> _ => ListItem ( bits ( ?Result , 4 ) : i4 ) </out-ports>
            <out-vars> %output , .ValueIdList </out-vars>
        </ckt>
    </ckts>
    requires A >=Int 0 andBool A <=Int 15  // Input constraints
    ensures ?Result ==Int (A +Int B) mod 16  // Property to verify
```

### Key Components

1. **Symbolic Variables**: `A:Int`, `B:Int` - represent symbolic inputs with constraints
2. **Output Variables**: `?Result`, `?Overflow` - capture symbolic outputs for verification
3. **Cell Structure**: Mirrors MLIR execution state with circuit information
4. **Type Constraints**: `bits(Value, Width)` represents bit-vectors with precise semantics
5. **Property Specification**: `ensures` clauses define the properties to be verified

## Usage

### Prerequisites

1. **K Framework**: Install K framework with `kprove` and `kompile` in PATH
2. **K-CIRCT**: Ensure K-CIRCT semantics are compiled and available
3. **MLIR**: MLIR files should be syntactically valid

### Running Verification

#### Individual Verification Cases

```bash
# Verify constant folding equivalence
cd verification/scripts
./verify_constant_folding.sh

# Verify arithmetic safety (overflow detection)  
./verify_arithmetic_safety.sh
```

#### Complete Verification Suite

```bash
# Run all verifications with comprehensive reporting
./run_all_verifications.sh
```

### Expected Output

#### Successful Verification
```
=== K-CIRCT Verification Suite ===
✅ K framework found: K version 6.0.0
✅ CONSTANT FOLDING VERIFICATION: PASSED
✅ ARITHMETIC SAFETY VERIFICATION: PASSED

🎉 ALL VERIFICATIONS PASSED!
- Constant Folding Equivalence: VERIFIED
- Arithmetic Safety (Overflow): VERIFIED

📊 Complete verification report: verification/results/verification_summary.md
```

#### Verification Failure
If verification fails, detailed logs will be generated:
- `results/constant_folding/original_verification.log`
- `results/arithmetic_safety/overflow_case_verification.log`
- Error traces and counterexamples (if any)

## Technical Details

### Verification Methodology

1. **Symbolic Execution**: K explores all possible execution paths symbolically
2. **Bit-vector Arithmetic**: Hardware semantics with precise bit-width handling
3. **Reachability Analysis**: Proves that initial states reach desired final states
4. **Property Checking**: Ensures clauses must hold for all valid inputs

### Supported MLIR Operations

The verification framework handles these CIRCT operations:

- `hw.constant`: Hardware constants with bit-vector values
- `hw.module`: Module definitions with typed inputs/outputs
- `hw.output`: Module output operations
- `comb.add`: Combinational addition with overflow semantics
- `comb.extract`: Bit-slice extraction operations  
- `comb.concat`: Bit concatenation operations
- `comb.icmp`: Integer comparison operations

### Bit-Vector Semantics

The K framework models hardware bit-vectors precisely:

```k
// 4-bit unsigned arithmetic with overflow
bits(X:Int, 4)  // X ∈ [0, 15]
X +Bits Y => bits((X +Int Y) &Int 15, 4)  // Modular arithmetic
```

### Symbolic Variable Patterns

- `A:Int`, `B:Int`: Symbolic integer inputs with constraints
- `?Result`, `?Overflow`: Symbolic outputs for property verification
- Constraints: `requires A >=Int 0 andBool A <=Int 15`
- Properties: `ensures ?Result ==Int (A +Int B) mod 16`

## Extending the Framework

### Adding New Verification Cases

1. **Create MLIR Design**: Add `.mlir` file to `cases/` directory
2. **Write K Specification**: Create `.k` file in `specs/` with claims
3. **Add Verification Script**: Create bash script in `scripts/`
4. **Update Master Script**: Add new case to `run_all_verifications.sh`

### Example: Verifying a Multiplier

```mlir
// cases/multiplier_4bit.mlir
hw.module @Multiplier4Bit(%a: i4, %b: i4) -> (product: i8) {
    %product = comb.mul %a, %b : i4
    hw.output %product : i8
}
```

```k
// specs/multiplier_spec.k
claim
    <mlir> ... </mlir>
    <ckts>
        <ckt>
            <args>
                ListItem ( bits ( A:Int , 4 ) : i4 )
                ListItem ( bits ( B:Int , 4 ) : i4 )
            </args>
            <out-ports> _ => ListItem ( bits ( ?Product , 8 ) : i8 ) </out-ports>
        </ckt>
    </ckts>
    requires A >=Int 0 andBool A <=Int 15 andBool B >=Int 0 andBool B <=Int 15
    ensures ?Product ==Int A *Int B
```

## Verification Scope

### Current Capabilities
- ✅ Combinational logic verification
- ✅ Constant folding optimization correctness
- ✅ Arithmetic overflow detection
- ✅ Bit-vector semantics
- ✅ Symbolic execution with constraints

### Future Extensions
- 🔄 Sequential logic (clocks, registers)
- 🔄 Memory operations (firmem, firreg) 
- 🔄 SystemVerilog constructs (sv dialect)
- 🔄 Temporal logic properties (LTL/CTL)
- 🔄 Large-scale hardware designs (processors)

## Troubleshooting

### Common Issues

1. **K Framework Not Found**
   - Install K framework: https://github.com/runtimeverification/k
   - Ensure `kprove` and `kompile` are in PATH

2. **Compilation Errors**
   - Check MLIR syntax is valid
   - Verify K specification syntax
   - Ensure all required modules are imported

3. **Verification Timeouts**
   - Reduce symbolic input ranges
   - Add more specific constraints
   - Break complex claims into smaller parts

4. **Counterexample Analysis**
   - Review generated counterexamples
   - Check input constraints are sufficient
   - Verify property specification is correct

### Debug Mode

Run verification with additional debugging:
```bash
# Enable verbose K output
export K_OPTS="--verbose"
./run_all_verifications.sh

# Check intermediate compilation
kompile --verbose specs/constant_folding_spec.k
```

## Related Work

This verification framework demonstrates the application of K-CIRCT to formal hardware verification, complementing:

- Traditional hardware verification (SystemVerilog assertions, PSL)
- Model checking tools (NuSMV, CBMC)
- Theorem provers (Coq, Isabelle/HOL)
- Industry verification flows (Cadence JasperGold, Synopsys VC)

The advantage of K-CIRCT is its direct integration with MLIR compiler infrastructure, enabling verification throughout the compilation pipeline from high-level hardware description to optimized implementations.