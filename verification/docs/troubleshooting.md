# K-CIRCT Verification Troubleshooting Guide

**Complete Guide to Debugging and Resolving Common Issues**

## Table of Contents

1. [Quick Diagnosis](#quick-diagnosis)
2. [Installation Issues](#installation-issues)
3. [Compilation Errors](#compilation-errors)
4. [Verification Runtime Errors](#verification-runtime-errors)
5. [Performance Issues](#performance-issues)
6. [MLIR-Specific Problems](#mlir-specific-problems)
7. [K Framework Issues](#k-framework-issues)
8. [SMT Solver Problems](#smt-solver-problems)
9. [Debugging Strategies](#debugging-strategies)
10. [Frequently Asked Questions](#frequently-asked-questions)

---

## Quick Diagnosis

### Is My Setup Working?

**Run this 30-second diagnostic**:

```bash
# 1. Check K framework
k --version                    # Should show K version 6.0+

# 2. Check verification tools
kprove --help >/dev/null 2>&1 && echo "✓ kprove OK" || echo "✗ kprove failed"
kompile --help >/dev/null 2>&1 && echo "✓ kompile OK" || echo "✗ kompile failed"

# 3. Run basic verification
cd verification/
./scripts/run_all_verifications.sh
```

**Expected output if everything works**:
```
K version 6.0.0
✓ kprove OK
✓ kompile OK
✅ K framework found: K version 6.0.0
✅ CONSTANT FOLDING VERIFICATION: PASSED
✅ ARITHMETIC SAFETY VERIFICATION: PASSED
🎉 ALL VERIFICATIONS PASSED!
```

### Common Symptoms and Quick Fixes

| Symptom | Likely Cause | Quick Fix |
|---------|--------------|-----------|
| `k: command not found` | K not installed/in PATH | [Install K Framework](#k-framework-not-found) |
| `Module not found: MAIN` | K compilation issue | [Check K installation](#k-framework-issues) |
| `kompile failed` | Syntax error in K spec | [Check K syntax](#compilation-errors) |
| `Verification timeout` | Complex symbolic execution | [Reduce complexity](#performance-issues) |
| `SMT solver error` | Backend solver issue | [Check SMT configuration](#smt-solver-problems) |

---

## Installation Issues

### K Framework Not Found

**Error**:
```bash
$ k --version
bash: k: command not found
```

**Solutions**:

#### Option 1: Install via Official Installer
```bash
curl -sSL https://install.k-framework.org | bash
export PATH="$PATH:$HOME/.local/bin"
```

#### Option 2: Manual Installation
```bash
# Download K release
wget https://github.com/runtimeverification/k/releases/download/v6.0.0/k-6.0.0-linux-x86_64.tar.gz
tar xzf k-6.0.0-linux-x86_64.tar.gz
export PATH="$PATH:$(pwd)/k-6.0.0-linux-x86_64/bin"
```

#### Option 3: Build from Source
```bash
git clone https://github.com/runtimeverification/k.git
cd k
mvn package -DskipTests
export PATH="$PATH:$(pwd)/k-distribution/target/release/k/bin"
```

**Verification**:
```bash
k --version                    # Should show version 6.0+
which k                        # Should show installation path
kprove --help | head -5        # Should show kprove usage
```

### Permission Issues

**Error**:
```bash
./scripts/verify_constant_folding.sh: Permission denied
```

**Solution**:
```bash
# Make scripts executable
chmod +x verification/scripts/*.sh

# Or run with bash explicitly
bash verification/scripts/verify_constant_folding.sh
```

### Missing Dependencies

**Error**:
```bash
java: command not found
```

**Solution**:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install openjdk-11-jdk

# macOS  
brew install openjdk@11

# Verify Java installation
java -version
```

---

## Compilation Errors

### K Syntax Errors

#### Error: Undefined Module

**Error**:
```
[Error] Critical: Module CONSTANT-FOLDING-SYNTAX not found
        at specs/constant_folding_spec.k:20:12
```

**Cause**: Module name mismatch between definition and import

**Solution**:
```k
// Ensure module names match exactly
module CONSTANT-FOLDING-SYNTAX          // Definition
    // ... content ...
endmodule

module CONSTANT-FOLDING-SPEC
    imports CONSTANT-FOLDING-SYNTAX      // Import matches definition
endmodule
```

#### Error: Undefined Token

**Error**:
```
[Error] Critical: Token 'overflow' not declared in syntax
        at specs/arithmetic_safety_spec.k:45:17
```

**Cause**: Missing token declaration in syntax module

**Solution**:
```k
module ARITHMETIC-SAFETY-SYNTAX
    syntax BareId ::= "a" [token] | "b" [token] 
                    | "overflow" [token]        // Add missing token
                    | "sum" [token]
endmodule
```

#### Error: Invalid Claim Structure

**Error**:
```
[Error] Critical: Expected <mlir> cell in claim configuration
        at specs/your_spec.k:32:5
```

**Cause**: Incorrect claim configuration structure

**Solution**:
```k
claim [claim-name]
    // Must start with <mlir> configuration
    <mlir>
        <prog> .K </prog>
        <phase> #build </phase>
        <types> .Map </types>
        <attrs> .Map </attrs>
        <table> .Map </table>
    </mlir>
    // ... rest of claim
```

### MLIR Operation Mapping Errors

#### Error: Operation Not Found

**Error**:
```
[Error] Runtime: Operation 'comb.add' not found in locals
        at symbolic execution step 147
```

**Cause**: MLIR operation not properly mapped in `<locals>` section

**Solution**:
```k
<locals>
    // Ensure exact operation mapping from MLIR
    %sum |-> "comb.add" ( %a , %b , .ValueIdList ) 
             : ( i4 , i4 , .Types ) -> ( i4 , .Types )
    //       ^^^^^^^^^^ Must match MLIR operation exactly
</locals>
```

#### Error: Type Mismatch

**Error**:
```
[Error] Runtime: Type mismatch in operation evaluation
        Expected: i4, Got: i8
```

**Cause**: Inconsistent bit-widths between MLIR and K specification

**Solution**:
```mlir
// In MLIR file
%a: i4                         // 4-bit input

// In K specification  
ListItem ( bits ( A:Int , 4 ) : i4 )   // Must match MLIR bit-width
//                         ^
//                    Must be 4, not 8
```

---

## Verification Runtime Errors

### Symbolic Execution Failures

#### Error: Unsatisfiable Constraints

**Error**:
```
[Error] Verification failed: Constraints are unsatisfiable
        Claim: arithmetic-safety-overflow
        Constraints: A >= 0 ∧ A <= 15 ∧ B >= 0 ∧ B <= 15 ∧ A + B < 0
```

**Cause**: Contradictory requirements in claim specification

**Solution**:
```k
// Check for logical contradictions
requires isValid4Bit(A) andBool isValid4Bit(B)    // A,B ∈ [0,15]
     andBool (A +Int B) >=Int 16                  // A+B ≥ 16
// This is satisfiable: e.g., A=8, B=8 → A+B=16

// Avoid contradictions like:
requires (A +Int B) <Int 16 andBool (A +Int B) >=Int 16  // CONTRADICTION!
```

#### Error: Property Violation

**Error**:
```
[Error] Claim failed: Property violation found
        Counterexample: A = 15, B = 15
        Expected: ?Sum == 30
        Actual:   ?Sum == 14
```

**Cause**: Incorrect property specification (not accounting for modular arithmetic)

**Solution**:
```k
// Wrong: expecting arithmetic sum
ensures ?Sum ==Int (A +Int B)

// Correct: accounting for 4-bit modular arithmetic  
ensures ?Sum ==Int ((A +Int B) &Int 15)  // Modulo 16 for 4-bit
```

### SMT Solver Timeouts

#### Error: Verification Timeout

**Error**:
```
[Error] Verification timeout after 300 seconds
        Claim: complex-property
        SMT queries: 15,847
```

**Solutions**:

#### Option 1: Increase Timeout
```bash
kprove --timeout 1800 specs/your_spec.k  # 30 minutes
```

#### Option 2: Simplify Constraints
```k
// Instead of complex constraints:
requires complexCondition(A, B, C, D)

// Break into simpler parts:
requires simpleCondition1(A, B) andBool simpleCondition2(C, D)
```

#### Option 3: Decompose Claims
```k
// Instead of one complex claim:
claim [complex-property]
    requires A >=Int 0 andBool ... andBool complexCondition
    ensures property1 andBool property2 andBool property3

// Split into multiple simpler claims:
claim [property-1] requires ... ensures property1
claim [property-2] requires ... ensures property2  
claim [property-3] requires ... ensures property3
```

---

## Performance Issues

### Slow Verification Times

#### Diagnosis: Identify Bottlenecks

```bash
# Run with profiling
time kprove --verbose specs/your_spec.k

# Check SMT solver statistics  
kprove --debug specs/your_spec.k 2>&1 | grep "SMT"
```

#### Solution 1: Reduce Symbolic Variable Range

```k
// Instead of large ranges:
requires A >=Int 0 andBool A <=Int 255    // 256 possible values

// Use targeted ranges:
requires A >=Int 0 andBool A <=Int 15     // 16 possible values  
     andBool A =/=Int 7                   // Exclude problematic values
```

#### Solution 2: Use Concrete Values When Possible

```k
// Instead of fully symbolic:
requires A >=Int 0 andBool A <=Int 15
     andBool B >=Int 0 andBool B <=Int 15

// Use specific concrete cases:
requires A ==Int 15 andBool B ==Int 15    // Test maximum case only
```

#### Solution 3: Optimize SMT Queries

```k
// Group related constraints
requires (A >=Int 0 andBool A <=Int 15)           // Range constraint
     andBool (B >=Int 0 andBool B <=Int 15)       // Range constraint  
     andBool ((A +Int B) <Int 32)                 // Derived constraint

// Instead of scattered constraints throughout claim
```

### Memory Consumption Issues

#### Error: Out of Memory

**Error**:
```
java.lang.OutOfMemoryError: Java heap space
        at symbolic execution step 45,231
```

**Solutions**:

#### Option 1: Increase JVM Memory
```bash
export JAVA_OPTS="-Xmx8g -Xms2g"          # 8GB max heap, 2GB initial
kprove specs/your_spec.k
```

#### Option 2: Reduce Symbolic State Size
```k
// Minimize symbolic variables in <args>
<args>
    ListItem ( bits ( A:Int , 4 ) : i4 )   // Only necessary variables
    // Don't add unused symbolic variables
</args>
```

#### Option 3: Use Bounded Verification
```k
// Add bounds to infinite verification spaces
requires A >=Int 0 andBool A <=Int 15     // Explicit bounds
     andBool verificationDepth <Int 10    // Limit exploration depth
```

---

## MLIR-Specific Problems

### MLIR Syntax Issues

#### Error: Invalid MLIR Operation

**Error**:
```
error: 'comb.add' op requires the same type for all operands and results
```

**Cause**: Type mismatch in MLIR operation

**Solution**:
```mlir
// Wrong: mismatched types
%sum = "comb.add"(%a, %b) : (i4, i8) -> i4   // i4 + i8 → error

// Correct: matching types
%sum = "comb.add"(%a, %b) : (i4, i4) -> i4   // i4 + i4 → OK
```

#### Error: Missing Module Type

**Error**:
```
error: 'hw.module' op requires a 'module_type' attribute
```

**Solution**:
```mlir
"hw.module"() ({
    // ... module body ...
}) {
    module_type = !hw.modty<input a : i4, input b : i4, output sum : i4>,
    parameters = [],
    result_locs = [#loc1],
    sym_name = "ModuleName"
} : () -> ()
```

### MLIR to K Mapping Issues

#### Error: Operation Translation Failure

**Error**:
```
[Error] Runtime: Cannot translate MLIR operation 'comb.extract'
        Operation: %low = "comb.extract"(%full) {lowBit = 0} : (i8) -> i4
```

**Cause**: Complex MLIR operation not yet supported in K semantics

**Temporary Solution**:
```mlir
// Use simpler equivalent operations
%mask = "hw.constant"() {value = 15 : i8} : () -> i8    // 0x0F mask
%low = "comb.and"(%full, %mask) : (i8, i8) -> i8       // Extract lower 4 bits  
%low_i4 = "hw.bitcast"(%low) : (i8) -> i4              // Cast to i4
```

**Long-term Solution**: Extend K semantics to support the operation
```k
// Add to K semantic rules
rule <k> evalOp("comb.extract", ListItem(bits(X:Int, W:Int))) => 
         bits((X >>Int LOWBIT) &Int ((2 ^Int EXTRACTWIDTH) -Int 1), EXTRACTWIDTH) </k>
     <attrs> ... "lowBit" |-> LOWBIT ... </attrs>
```

---

## K Framework Issues

### K Installation Problems

#### Error: K Framework Version Mismatch

**Error**:
```
[Error] K version 5.6.0 found, but version 6.0+ required
```

**Solution**:
```bash
# Uninstall old K version
rm -rf ~/.local/share/kframework

# Install latest K version  
curl -sSL https://install.k-framework.org | bash
```

#### Error: Java Version Compatibility

**Error**:
```
Exception in thread "main" java.lang.UnsupportedClassVersionError
```

**Cause**: K requires Java 11+, but older Java version is installed

**Solution**:
```bash
# Check Java version
java -version                   # Should be 11+

# Install Java 11 (Ubuntu/Debian)
sudo apt install openjdk-11-jdk
sudo update-alternatives --config java

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

### K Runtime Issues

#### Error: Stack Overflow in K Execution

**Error**:
```
java.lang.StackOverflowError
        at org.kframework.backend.java.symbolic.JavaSymbolicKRun
```

**Cause**: Infinite recursion in K rules or very deep symbolic execution

**Solutions**:

#### Option 1: Increase Stack Size
```bash
export JAVA_OPTS="-Xss32m"      # 32MB stack size
kprove specs/your_spec.k
```

#### Option 2: Check for Infinite Recursion
```k
// Look for rules that might cause infinite loops
rule <k> problematicRule(X) => problematicRule(X +Int 1) </k>  // INFINITE!

// Add termination conditions
rule <k> problematicRule(X) => . </k> requires X >Int maxValue  // TERMINATE
rule <k> problematicRule(X) => problematicRule(X +Int 1) </k> 
     requires X <=Int maxValue
```

---

## SMT Solver Problems

### SMT Backend Issues

#### Error: Z3 Solver Timeout

**Error**:
```
[Error] SMT solver timeout: Z3 failed to solve within 30 seconds
        Query complexity: 2,847 constraints
```

**Solutions**:

#### Option 1: Increase SMT Timeout
```bash
kprove --smt-timeout 300 specs/your_spec.k  # 5 minutes
```

#### Option 2: Switch SMT Solver
```bash
kprove --smt-solver yices specs/your_spec.k  # Try Yices instead of Z3
```

#### Option 3: Simplify SMT Queries
```k
// Instead of complex bit-vector operations:
ensures (?Result &Int 255) ==Int ((A *Int B) &Int 255)

// Use simpler arithmetic constraints:
ensures ?Result ==Int ((A *Int B) modInt 256)
```

#### Error: SMT Solver Not Found

**Error**:
```
[Error] SMT solver 'z3' not found in PATH
```

**Solution**:
```bash
# Install Z3 (Ubuntu/Debian)
sudo apt install z3

# Install Z3 (macOS)
brew install z3

# Verify installation
z3 --version
which z3
```

---

## Debugging Strategies

### Verbose Output Analysis

#### Enable Maximum Verbosity
```bash
kprove --verbose --debug specs/your_spec.k 2>&1 | tee debug.log
```

#### Analyze Compilation Phase
```bash
kompile --verbose specs/your_spec.k -o debug-kompiled/
```

#### Check Intermediate K Output
```bash
# Look at generated K files
ls -la debug-kompiled/
cat debug-kompiled/compiled.txt
```

### Incremental Debugging

#### Step 1: Simplify to Minimal Case
```k
// Start with simplest possible claim
claim [minimal-test]
    <mlir> ... </mlir>
    <cmd> #always => #end </cmd>
    <entry> "TestModule" </entry>
    <ckts>
        <ckt>
            <cid> "TestModule" </cid>
            <locals> .Map </locals>        // Empty operations
            <out-ports> _ => ListItem(bits(42, 8) : i8) </out-ports>
        </ckt>
    </ckts>
    ensures true                          // Trivially true property
```

#### Step 2: Add Complexity Gradually
```k
// Add one operation at a time
<locals>
    %const |-> "hw.constant" ( .ValueIdList ) { value = 42 : i8 }
</locals>

// Add one constraint at a time  
requires A >=Int 0                       // Single constraint
requires A >=Int 0 andBool A <=Int 15    // Add second constraint
```

#### Step 3: Test Each Component Separately
```bash
# Test MLIR syntax
mlir-opt --verify-diagnostics cases/your_design.mlir

# Test K syntax  
kompile --syntax-only specs/your_spec.k

# Test specific claim
kprove --claim "simple-claim-only" specs/your_spec.k
```

### Logging and Tracing

#### Enable Detailed Logging
```bash
export K_OPTS="--verbose --debug-equational --trace-rewrites"
kprove specs/your_spec.k
```

#### Analyze Symbolic Execution Traces
```bash
# Generate execution trace
kprove --output-file trace.log specs/your_spec.k

# Look for stuck states
grep -A5 -B5 "stuck" trace.log

# Check constraint satisfiability  
grep -A10 -B10 "SMT" trace.log
```

---

## Frequently Asked Questions

### General Questions

#### Q: How long should verification take?

**A**: Depends on complexity:
- **Simple cases** (constant folding): 3-7 seconds
- **Medium cases** (4-bit arithmetic): 8-18 seconds  
- **Complex cases** (8-bit arithmetic): 45-120 seconds
- **Large cases** (16-bit+): 15+ minutes

If verification takes much longer, consider [performance optimizations](#performance-issues).

#### Q: How much memory is normal?

**A**: Typical memory usage:
- **Simple cases**: 50-100 MB
- **Medium cases**: 100-300 MB
- **Complex cases**: 300-1000 MB
- **Large cases**: 1-5 GB

#### Q: Can I run verification in parallel?

**A**: Yes, different claims can be verified in parallel:
```bash
# Run claims simultaneously
kprove --claim "claim-1" specs/your_spec.k &
kprove --claim "claim-2" specs/your_spec.k &
wait  # Wait for both to complete
```

### Technical Questions

#### Q: Why does my claim fail with no counterexample?

**A**: Several possible causes:
1. **Unsatisfiable constraints**: Check for contradictory requirements
2. **Type mismatches**: Verify MLIR types match K specification  
3. **Missing operations**: Ensure all MLIR operations are in `<locals>`
4. **Incorrect property**: Property might be mathematically incorrect

**Debug approach**:
```k
// Start with trivially true property
ensures true

// Add constraints incrementally
ensures ?Output >=Int 0              // Simple range check
ensures ?Output ==Int expectedValue  // Full correctness check
```

#### Q: How do I handle overflow/underflow correctly?

**A**: Use modular arithmetic:
```k
// For N-bit arithmetic, results wrap at 2^N
ensures ?Result ==Int ((A +Int B) &Int ((2 ^Int N) -Int 1))

// For 4-bit: results wrap at 16  
ensures ?Result ==Int ((A +Int B) &Int 15)

// For 8-bit: results wrap at 256
ensures ?Result ==Int ((A +Int B) &Int 255)
```

#### Q: Can I verify floating-point operations?

**A**: Currently not supported. K-CIRCT focuses on integer/bit-vector arithmetic. For floating-point:
- Use external tools (CBMC, KLEE)
- Implement custom floating-point semantics in K
- Use fixed-point approximations

#### Q: How do I verify sequential (clocked) logic?

**A**: Basic sequential support:
```k
<ckts>
    <ckt>
        <regs>
            register_name |-> bits(initialValue, width)
        </regs>
        <k> #Clock => .K </k>      // Clock-driven execution
    </ckt>
</ckts>
```

**Note**: Full sequential logic support is under development.

### Workflow Questions

#### Q: Should I verify before or after CIRCT optimizations?

**A**: Both! Verification serves different purposes:
- **Before optimization**: Verify original design correctness
- **After optimization**: Verify optimization preserves correctness  
- **Equivalence checking**: Prove optimized ≡ original

#### Q: How do I integrate with CI/CD pipelines?

**A**: Example CI integration:
```yaml
# .github/workflows/verification.yml
- name: Run K-CIRCT Verification
  run: |
    cd verification/
    ./scripts/run_all_verifications.sh
    # Fail CI if verification fails
    exit $?
```

#### Q: Can I generate verification certificates for compliance?

**A**: Yes, verification generates proof artifacts:
```bash
# Verification produces:
results/verification_summary.md          # Human-readable report
results/*/verification.log              # Detailed proof logs  
results/*/certificate.proof             # Machine-readable certificate
```

These can be used for safety standard compliance (DO-254, ISO 26262, etc.).

---

## Getting Additional Help

### Documentation Resources

1. **[README.md](../README.md)**: Main verification framework overview
2. **[DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)**: Complete development guide
3. **[Architecture Guide](architecture-guide.md)**: Technical architecture details
4. **[Case Studies](case-constant-folding.md)**: Detailed verification examples

### Community Support

1. **K Framework Community**: https://github.com/runtimeverification/k
2. **CIRCT Community**: https://github.com/llvm/circt
3. **Issue Reporting**: Create issues in the circt-semantics repository

### Professional Support

For production deployments or custom verification requirements:
- Runtime Verification: Professional K Framework support
- Academic Collaboration: Research partnerships for advanced verification

---

## Summary

This troubleshooting guide covers the most common issues encountered when using K-CIRCT verification. The key strategies for successful verification are:

1. **Start Simple**: Begin with minimal cases and add complexity gradually
2. **Check Dependencies**: Ensure K framework and all tools are properly installed
3. **Debug Incrementally**: Isolate problems by testing components separately  
4. **Monitor Performance**: Watch for memory/time bottlenecks and optimize accordingly
5. **Use Verbose Output**: Enable detailed logging to understand failure modes

Remember: formal verification can be complex, but systematic debugging usually leads to successful resolution of issues.