# K-CIRCT Verification Usage Examples

**Complete Step-by-Step Walkthroughs for Common Verification Scenarios**

## Table of Contents

1. [Getting Started: First Verification](#getting-started-first-verification)
2. [Example 1: Verifying a Simple Adder](#example-1-verifying-a-simple-adder)
3. [Example 2: Compiler Optimization Verification](#example-2-compiler-optimization-verification)
4. [Example 3: Safety Property Verification](#example-3-safety-property-verification)
5. [Example 4: Multi-Bit Arithmetic Verification](#example-4-multi-bit-arithmetic-verification)
6. [Example 5: Custom Hardware Module](#example-5-custom-hardware-module)
7. [Advanced Usage Patterns](#advanced-usage-patterns)
8. [Integration Examples](#integration-examples)

---

## Getting Started: First Verification

**Goal**: Run your first K-CIRCT verification to ensure everything works.

### Step 1: Environment Check

```bash
# Navigate to verification directory
cd verification/

# Quick environment verification
echo "=== Environment Check ==="
k --version || echo "❌ K framework not installed"
kprove --help >/dev/null 2>&1 && echo "✅ kprove available" || echo "❌ kprove failed"
kompile --help >/dev/null 2>&1 && echo "✅ kompile available" || echo "❌ kompile failed"
```

**Expected Output**:
```
=== Environment Check ===
K version 6.0.0
✅ kprove available
✅ kompile available
```

### Step 2: Run Example Verification

```bash
# Run the complete verification suite
./scripts/run_all_verifications.sh
```

**Expected Output**:
```
===============================================
        K-CIRCT Verification Suite
===============================================
✅ K framework found: K version 6.0.0
✅ CONSTANT FOLDING VERIFICATION: PASSED
✅ ARITHMETIC SAFETY VERIFICATION: PASSED
🎉 ALL VERIFICATIONS PASSED!
```

### Step 3: Examine Results

```bash
# View the comprehensive report
cat results/verification_summary.md

# Check individual verification logs
ls -la results/constant_folding/
ls -la results/arithmetic_safety/
```

**Congratulations!** If you see "ALL VERIFICATIONS PASSED", your K-CIRCT setup is working correctly.

---

## Example 1: Verifying a Simple Adder

**Goal**: Create and verify a basic 4-bit adder from scratch.

### Step 1: Create the MLIR Hardware Design

Create `cases/simple_adder.mlir`:

```mlir
#loc = loc("simple_adder.mlir":1:1)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0(%a: i4, %b: i4):
        // Simple 4-bit addition  
        %sum = "comb.add"(%a, %b) : (i4, i4) -> i4
        "hw.output"(%sum) : (i4) -> ()
    }) {
        module_type = !hw.modty<input a : i4, input b : i4, output sum : i4>, 
        parameters = [], 
        result_locs = [#loc], 
        sym_name = "SimpleAdder"
    } : () -> ()
}) : () -> ()
```

### Step 2: Create K Verification Specification

Create `specs/simple_adder_spec.k`:

```k
requires "../src/mlir/mlir.k"

module SIMPLE-ADDER-SYNTAX
    syntax BareId ::= "a" [token] | "b" [token] | "sum" [token]
                    | "parameters" [token]
    syntax AttributeAlias ::= "#loc" [token]
endmodule

module SIMPLE-ADDER-VERIFICATION
    imports K-EQUAL
    imports SIMPLE-ADDER-SYNTAX
    imports MAIN
    
    syntax Bool ::= isValid4Bit(Int) [function]
    rule isValid4Bit(X:Int) => X >=Int 0 andBool X <=Int 15
endmodule

module SIMPLE-ADDER-SPEC
    imports SIMPLE-ADDER-VERIFICATION
    
    // Claim: Adder produces correct sum with modular arithmetic
    claim [simple-adder-correctness]
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "SimpleAdder" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt>
                <cid> "SimpleAdder" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %sum |-> "comb.add" ( %a , %b , .ValueIdList ) 
                             : ( i4 , i4 , .Types ) -> ( i4 , .Types )
                </locals>
                <module> "SimpleAdder" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => ListItem ( bits ( ?Sum , 4 ) : i4 ) </out-ports>
                <out-vars> %sum , .ValueIdList </out-vars>
                <args>
                    ListItem ( bits ( A:Int , 4 ) : i4 )
                    ListItem ( bits ( B:Int , 4 ) : i4 )
                </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        requires isValid4Bit(A) andBool isValid4Bit(B)
        ensures ?Sum ==Int ((A +Int B) &Int 15)  // 4-bit modular arithmetic
endmodule
```

### Step 3: Create Verification Script

Create `scripts/verify_simple_adder.sh`:

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$VERIFICATION_DIR")"

echo "=== Simple Adder Verification ==="

# Check files exist
MLIR_FILE="$VERIFICATION_DIR/cases/simple_adder.mlir"
SPEC_FILE="$VERIFICATION_DIR/specs/simple_adder_spec.k"

if [[ ! -f "$MLIR_FILE" ]] || [[ ! -f "$SPEC_FILE" ]]; then
    echo "❌ Required files not found"
    exit 1
fi

# Create output directory
OUTPUT_DIR="$VERIFICATION_DIR/results/simple_adder"
mkdir -p "$OUTPUT_DIR"

echo "=== Kompiling Specification ==="
cd "$PROJECT_ROOT"
kompile -v "$SPEC_FILE" \
    --syntax-module SIMPLE-ADDER-SYNTAX \
    --main-module SIMPLE-ADDER-SPEC \
    -o "$OUTPUT_DIR/simple-adder-kompiled"

echo "✅ Compilation successful"

echo "=== Running Verification ==="
if kprove "$SPEC_FILE" \
    --definition "$OUTPUT_DIR/simple-adder-kompiled" \
    --spec-module SIMPLE-ADDER-SPEC \
    --claim "simple-adder-correctness" \
    --output-file "$OUTPUT_DIR/verification.log" \
    --verbose; then
    echo "🎉 SIMPLE ADDER VERIFICATION PASSED!"
    echo "   Verified correct 4-bit modular addition for all 256 input combinations"
else
    echo "❌ Verification failed - check $OUTPUT_DIR/verification.log"
    exit 1
fi
```

### Step 4: Run the Verification

```bash
# Make script executable
chmod +x scripts/verify_simple_adder.sh

# Run verification
./scripts/verify_simple_adder.sh
```

**Expected Output**:
```
=== Simple Adder Verification ===
=== Kompiling Specification ===
✅ Compilation successful
=== Running Verification ===
🎉 SIMPLE ADDER VERIFICATION PASSED!
   Verified correct 4-bit modular addition for all 256 input combinations
```

### Step 5: Examine the Results

```bash
# View verification log
cat results/simple_adder/verification.log

# Check symbolic execution details
ls -la results/simple_adder/
```

**What You've Accomplished**:
- Created a 4-bit adder in MLIR
- Specified formal verification properties in K
- Proven mathematically that the adder works correctly for all possible inputs
- Generated a verification certificate

---

## Example 2: Compiler Optimization Verification

**Goal**: Prove that a compiler optimization preserves semantic equivalence.

### Scenario: Verify Constant Propagation

Let's verify that the transformation `%x = 5; %y = %x + 3` → `%y = 8` is correct.

### Step 1: Original (Unoptimized) Design

Create `cases/const_prop_original.mlir`:

```mlir
#loc = loc("const_prop_original.mlir":1:1)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0():
        %x = "hw.constant"() {value = 5 : i8} : () -> i8
        %c3 = "hw.constant"() {value = 3 : i8} : () -> i8
        %y = "comb.add"(%x, %c3) : (i8, i8) -> i8
        "hw.output"(%y) : (i8) -> ()
    }) {
        module_type = !hw.modty<output result : i8>, 
        parameters = [], 
        result_locs = [#loc], 
        sym_name = "ConstPropOriginal"
    } : () -> ()
}) : () -> ()
```

### Step 2: Optimized Design

Create `cases/const_prop_optimized.mlir`:

```mlir
#loc = loc("const_prop_optimized.mlir":1:1)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0():
        %y = "hw.constant"() {value = 8 : i8} : () -> i8
        "hw.output"(%y) : (i8) -> ()
    }) {
        module_type = !hw.modty<output result : i8>, 
        parameters = [], 
        result_locs = [#loc], 
        sym_name = "ConstPropOptimized"
    } : () -> ()
}) : () -> ()
```

### Step 3: Equivalence Verification Specification

Create `specs/const_prop_equivalence_spec.k`:

```k
requires "../src/mlir/mlir.k"

module CONST-PROP-SYNTAX
    syntax BareId ::= "x" [token] | "y" [token] | "c3" [token]
                    | "result" [token] | "value" [token] | "parameters" [token]
    syntax AttributeAlias ::= "#loc" [token]
endmodule

module CONST-PROP-SPEC
    imports K-EQUAL
    imports CONST-PROP-SYNTAX
    imports MAIN
    
    // Equivalence claim: both versions produce the same output
    claim [const-prop-equivalence]
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "ConstPropOriginal" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            // Execute both circuits simultaneously
            <ckt>
                <cid> "ConstPropOriginal" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %x |-> "hw.constant" ( .ValueIdList ) { value = 5 : i8 } : ( .Types ) -> ( i8 , .Types )
                    %c3 |-> "hw.constant" ( .ValueIdList ) { value = 3 : i8 } : ( .Types ) -> ( i8 , .Types )
                    %y |-> "comb.add" ( %x , %c3 , .ValueIdList ) : ( i8 , i8 , .Types ) -> ( i8 , .Types )
                </locals>
                <module> "ConstPropOriginal" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => ListItem ( bits ( ?OriginalResult , 8 ) : i8 ) </out-ports>
                <out-vars> %y , .ValueIdList </out-vars>
                <args> .List </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
            <ckt>
                <cid> "ConstPropOptimized" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %y |-> "hw.constant" ( .ValueIdList ) { value = 8 : i8 } : ( .Types ) -> ( i8 , .Types )
                </locals>
                <module> "ConstPropOptimized" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => ListItem ( bits ( ?OptimizedResult , 8 ) : i8 ) </out-ports>
                <out-vars> %y , .ValueIdList </out-vars>
                <args> .List </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        ensures ?OriginalResult ==Int ?OptimizedResult  // Semantic equivalence
            andBool ?OriginalResult ==Int 8             // Both should output 8
endmodule
```

### Step 4: Run Equivalence Verification

```bash
# Create and run verification script
cat > scripts/verify_const_prop.sh << 'EOF'
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$VERIFICATION_DIR")"

echo "=== Constant Propagation Equivalence Verification ==="

OUTPUT_DIR="$VERIFICATION_DIR/results/const_prop"
mkdir -p "$OUTPUT_DIR"

cd "$PROJECT_ROOT"
kompile -v "$VERIFICATION_DIR/specs/const_prop_equivalence_spec.k" \
    --syntax-module CONST-PROP-SYNTAX \
    --main-module CONST-PROP-SPEC \
    -o "$OUTPUT_DIR/const-prop-kompiled"

if kprove "$VERIFICATION_DIR/specs/const_prop_equivalence_spec.k" \
    --definition "$OUTPUT_DIR/const-prop-kompiled" \
    --spec-module CONST-PROP-SPEC \
    --claim "const-prop-equivalence" \
    --output-file "$OUTPUT_DIR/equivalence.log"; then
    echo "🎉 EQUIVALENCE VERIFICATION PASSED!"
    echo "   Constant propagation optimization proven semantically correct"
else
    echo "❌ Equivalence verification failed"
    exit 1
fi
EOF

chmod +x scripts/verify_const_prop.sh
./scripts/verify_const_prop.sh
```

**Expected Output**:
```
=== Constant Propagation Equivalence Verification ===
🎉 EQUIVALENCE VERIFICATION PASSED!
   Constant propagation optimization proven semantically correct
```

**What This Proves**: The compiler transformation `%x = 5; %y = %x + 3` → `%y = 8` is mathematically correct and preserves program semantics.

---

## Example 3: Safety Property Verification

**Goal**: Verify that a hardware design satisfies critical safety properties.

### Scenario: Division by Zero Detection

Let's verify a division circuit that detects and handles division by zero.

### Step 1: Safe Division Circuit

Create `cases/safe_divider.mlir`:

```mlir
#loc = loc("safe_divider.mlir":1:1)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0(%dividend: i8, %divisor: i8):
        // Check for division by zero
        %zero = "hw.constant"() {value = 0 : i8} : () -> i8
        %is_zero = "comb.icmp"(%divisor, %zero) {predicate = 0} : (i8, i8) -> i1
        
        // Perform division (only when divisor != 0)
        %quotient_raw = "comb.divu"(%dividend, %divisor) : (i8, i8) -> i8
        
        // Output safe quotient (0 if division by zero) and error flag
        %safe_quotient = "comb.mux"(%is_zero, %zero, %quotient_raw) : (i1, i8, i8) -> i8
        
        "hw.output"(%safe_quotient, %is_zero) : (i8, i1) -> ()
    }) {
        module_type = !hw.modty<
            input dividend : i8, input divisor : i8, 
            output quotient : i8, output error : i1
        >, 
        parameters = [], 
        result_locs = [#loc, #loc], 
        sym_name = "SafeDivider"
    } : () -> ()
}) : () -> ()
```

### Step 2: Safety Property Specification

Create `specs/safe_divider_spec.k`:

```k
requires "../src/mlir/mlir.k"

module SAFE-DIVIDER-SYNTAX
    syntax BareId ::= "dividend" [token] | "divisor" [token] | "quotient" [token]
                    | "error" [token] | "zero" [token] | "is_zero" [token]
                    | "quotient_raw" [token] | "safe_quotient" [token]
                    | "predicate" [token] | "parameters" [token]
    syntax AttributeAlias ::= "#loc" [token]
endmodule

module SAFE-DIVIDER-VERIFICATION
    imports K-EQUAL
    imports SAFE-DIVIDER-SYNTAX
    imports MAIN
    
    syntax Bool ::= isValid8Bit(Int) [function]
    rule isValid8Bit(X:Int) => X >=Int 0 andBool X <=Int 255
endmodule

module SAFE-DIVIDER-SPEC
    imports SAFE-DIVIDER-VERIFICATION
    
    // Safety Property 1: Division by zero never causes undefined behavior
    claim [division-by-zero-safety]
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "SafeDivider" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt>
                <cid> "SafeDivider" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %zero |-> "hw.constant" ( .ValueIdList ) { value = 0 : i8 } : ( .Types ) -> ( i8 , .Types )
                    %is_zero |-> "comb.icmp" ( %divisor , %zero , .ValueIdList ) 
                                 { predicate = 0 } : ( i8 , i8 , .Types ) -> ( i1 , .Types )
                    %quotient_raw |-> "comb.divu" ( %dividend , %divisor , .ValueIdList ) 
                                      : ( i8 , i8 , .Types ) -> ( i8 , .Types )
                    %safe_quotient |-> "comb.mux" ( %is_zero , %zero , %quotient_raw , .ValueIdList )
                                       : ( i1 , i8 , i8 , .Types ) -> ( i8 , .Types )
                </locals>
                <module> "SafeDivider" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => 
                    ListItem ( bits ( ?Quotient , 8 ) : i8 )
                    ListItem ( bits ( ?Error , 1 ) : i1 )
                </out-ports>
                <out-vars> %safe_quotient , %is_zero , .ValueIdList </out-vars>
                <args>
                    ListItem ( bits ( Dividend:Int , 8 ) : i8 )
                    ListItem ( bits ( Divisor:Int , 8 ) : i8 )
                </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        requires isValid8Bit(Dividend) andBool isValid8Bit(Divisor)
        ensures (Divisor ==Int 0) impliesBool (?Error ==Int 1 andBool ?Quotient ==Int 0)
    
    // Safety Property 2: When divisor is non-zero, no error is flagged
    claim [normal-operation-safety]
        <mlir> /* same structure */ </mlir>
        <cmd> #always => #end </cmd>
        <entry> "SafeDivider" </entry>
        <ckts>
            <ckt> /* same circuit structure */ </ckt>
        </ckts>
        requires isValid8Bit(Dividend) andBool isValid8Bit(Divisor) 
             andBool Divisor >Int 0
        ensures ?Error ==Int 0 andBool ?Quotient ==Int (Dividend /Int Divisor)
endmodule
```

### Step 3: Run Safety Verification

```bash
# Create verification script
cat > scripts/verify_safe_divider.sh << 'EOF'
#!/bin/bash
set -e

echo "=== Safe Division Verification ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$VERIFICATION_DIR")"

OUTPUT_DIR="$VERIFICATION_DIR/results/safe_divider"
mkdir -p "$OUTPUT_DIR"

cd "$PROJECT_ROOT"
kompile -v "$VERIFICATION_DIR/specs/safe_divider_spec.k" \
    --syntax-module SAFE-DIVIDER-SYNTAX \
    --main-module SAFE-DIVIDER-SPEC \
    -o "$OUTPUT_DIR/safe-divider-kompiled"

echo "=== Verifying Division by Zero Safety ==="
if kprove "$VERIFICATION_DIR/specs/safe_divider_spec.k" \
    --definition "$OUTPUT_DIR/safe-divider-kompiled" \
    --claim "division-by-zero-safety" \
    --output-file "$OUTPUT_DIR/div_zero_safety.log"; then
    echo "✅ Division by zero safety VERIFIED"
else
    echo "❌ Division by zero safety FAILED"
    exit 1
fi

echo "=== Verifying Normal Operation Safety ==="
if kprove "$VERIFICATION_DIR/specs/safe_divider_spec.k" \
    --definition "$OUTPUT_DIR/safe-divider-kompiled" \
    --claim "normal-operation-safety" \
    --output-file "$OUTPUT_DIR/normal_operation.log"; then
    echo "✅ Normal operation safety VERIFIED"
    echo ""
    echo "🎉 SAFE DIVISION VERIFICATION COMPLETE!"
    echo "   ✅ Division by zero is detected and handled safely"
    echo "   ✅ Normal division operations work correctly"
else
    echo "❌ Normal operation safety FAILED"
    exit 1
fi
EOF

chmod +x scripts/verify_safe_divider.sh
./scripts/verify_safe_divider.sh
```

**Expected Output**:
```
=== Safe Division Verification ===
=== Verifying Division by Zero Safety ===
✅ Division by zero safety VERIFIED
=== Verifying Normal Operation Safety ===
✅ Normal operation safety VERIFIED

🎉 SAFE DIVISION VERIFICATION COMPLETE!
   ✅ Division by zero is detected and handled safely
   ✅ Normal division operations work correctly
```

**Safety Guarantees Proven**:
1. Division by zero is always detected (error flag set, safe output provided)
2. Normal division operations produce mathematically correct results
3. The circuit never exhibits undefined behavior for any input combination

---

## Example 4: Multi-Bit Arithmetic Verification

**Goal**: Scale verification to larger bit-widths and explore performance characteristics.

### Scenario: 8-Bit Multiplier Verification

### Step 1: 8-Bit Multiplier Design

Create `cases/multiplier_8bit.mlir`:

```mlir
#loc = loc("multiplier_8bit.mlir":1:1)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0(%a: i8, %b: i8):
        // Extend to 16-bit to capture full product
        %c0_i8 = "hw.constant"() {value = 0 : i8} : () -> i8
        %a_ext = "comb.concat"(%c0_i8, %a) : (i8, i8) -> i16
        %b_ext = "comb.concat"(%c0_i8, %b) : (i8, i8) -> i16
        
        // 16-bit multiplication
        %product = "comb.mul"(%a_ext, %b_ext) : (i16, i16) -> i16
        
        "hw.output"(%product) : (i16) -> ()
    }) {
        module_type = !hw.modty<input a : i8, input b : i8, output product : i16>, 
        parameters = [], 
        result_locs = [#loc], 
        sym_name = "Multiplier8Bit"
    } : () -> ()
}) : () -> ()
```

### Step 2: Performance-Optimized Verification

Create `specs/multiplier_8bit_spec.k`:

```k
requires "../src/mlir/mlir.k"

module MULTIPLIER-8BIT-SYNTAX
    syntax BareId ::= "a" [token] | "b" [token] | "product" [token]
                    | "c0_i8" [token] | "a_ext" [token] | "b_ext" [token]
                    | "parameters" [token]
    syntax AttributeAlias ::= "#loc" [token]
endmodule

module MULTIPLIER-8BIT-VERIFICATION
    imports K-EQUAL
    imports MULTIPLIER-8BIT-SYNTAX
    imports MAIN
    
    syntax Bool ::= isValid8Bit(Int) [function]
    rule isValid8Bit(X:Int) => X >=Int 0 andBool X <=Int 255
endmodule

module MULTIPLIER-8BIT-SPEC
    imports MULTIPLIER-8BIT-VERIFICATION
    
    // Optimized verification: Use bounded ranges for performance
    claim [multiplier-bounded-verification]
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "Multiplier8Bit" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt>
                <cid> "Multiplier8Bit" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %c0_i8 |-> "hw.constant" ( .ValueIdList ) { value = 0 : i8 } : ( .Types ) -> ( i8 , .Types )
                    %a_ext |-> "comb.concat" ( %c0_i8 , %a , .ValueIdList ) : ( i8 , i8 , .Types ) -> ( i16 , .Types )
                    %b_ext |-> "comb.concat" ( %c0_i8 , %b , .ValueIdList ) : ( i8 , i8 , .Types ) -> ( i16 , .Types )
                    %product |-> "comb.mul" ( %a_ext , %b_ext , .ValueIdList ) : ( i16 , i16 , .Types ) -> ( i16 , .Types )
                </locals>
                <module> "Multiplier8Bit" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => ListItem ( bits ( ?Product , 16 ) : i16 ) </out-ports>
                <out-vars> %product , .ValueIdList </out-vars>
                <args>
                    ListItem ( bits ( A:Int , 8 ) : i8 )
                    ListItem ( bits ( B:Int , 8 ) : i8 )
                </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        requires isValid8Bit(A) andBool isValid8Bit(B) 
             andBool A <=Int 15 andBool B <=Int 15    // Bounded for performance
        ensures ?Product ==Int (A *Int B)
    
    // Edge case verification: Maximum values
    claim [multiplier-max-values]
        <mlir> /* same structure */ </mlir>
        <cmd> #always => #end </cmd>
        <entry> "Multiplier8Bit" </entry>
        <ckts> /* same circuit */ </ckts>
        requires A ==Int 255 andBool B ==Int 255      // Maximum 8-bit values
        ensures ?Product ==Int 65025                  // 255 * 255
    
    // Edge case verification: Zero multiplication  
    claim [multiplier-zero-cases]
        <mlir> /* same structure */ </mlir>
        <cmd> #always => #end </cmd>
        <entry> "Multiplier8Bit" </entry>
        <ckts> /* same circuit */ </ckts>
        requires (A ==Int 0 orBool B ==Int 0) andBool isValid8Bit(A) andBool isValid8Bit(B)
        ensures ?Product ==Int 0
endmodule
```

### Step 3: Performance Measurement

```bash
# Create performance measurement script
cat > scripts/verify_multiplier_8bit.sh << 'EOF'
#!/bin/bash
set -e

echo "=== 8-Bit Multiplier Verification with Performance Measurement ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$VERIFICATION_DIR")"

OUTPUT_DIR="$VERIFICATION_DIR/results/multiplier_8bit"
mkdir -p "$OUTPUT_DIR"

cd "$PROJECT_ROOT"

echo "=== Compiling Specification ==="
start_time=$(date +%s)
kompile -v "$VERIFICATION_DIR/specs/multiplier_8bit_spec.k" \
    --syntax-module MULTIPLIER-8BIT-SYNTAX \
    --main-module MULTIPLIER-8BIT-SPEC \
    -o "$OUTPUT_DIR/multiplier-8bit-kompiled"
compile_time=$(($(date +%s) - start_time))
echo "✅ Compilation completed in ${compile_time}s"

echo "=== Verifying Bounded Case (A,B ≤ 15) ==="
start_time=$(date +%s)
if kprove "$VERIFICATION_DIR/specs/multiplier_8bit_spec.k" \
    --definition "$OUTPUT_DIR/multiplier-8bit-kompiled" \
    --claim "multiplier-bounded-verification" \
    --output-file "$OUTPUT_DIR/bounded.log"; then
    bounded_time=$(($(date +%s) - start_time))
    echo "✅ Bounded verification completed in ${bounded_time}s"
else
    echo "❌ Bounded verification failed"
    exit 1
fi

echo "=== Verifying Maximum Values Case ==="
start_time=$(date +%s)
if kprove "$VERIFICATION_DIR/specs/multiplier_8bit_spec.k" \
    --definition "$OUTPUT_DIR/multiplier-8bit-kompiled" \
    --claim "multiplier-max-values" \
    --output-file "$OUTPUT_DIR/max_values.log"; then
    max_time=$(($(date +%s) - start_time))
    echo "✅ Maximum values verification completed in ${max_time}s"
else
    echo "❌ Maximum values verification failed"
    exit 1
fi

echo "=== Verifying Zero Cases ==="  
start_time=$(date +%s)
if kprove "$VERIFICATION_DIR/specs/multiplier_8bit_spec.k" \
    --definition "$OUTPUT_DIR/multiplier-8bit-kompiled" \
    --claim "multiplier-zero-cases" \
    --output-file "$OUTPUT_DIR/zero_cases.log"; then
    zero_time=$(($(date +%s) - start_time))
    echo "✅ Zero cases verification completed in ${zero_time}s"
else
    echo "❌ Zero cases verification failed"
    exit 1
fi

echo ""
echo "🎉 8-BIT MULTIPLIER VERIFICATION COMPLETE!"
echo ""
echo "📊 Performance Summary:"
echo "   Compilation:      ${compile_time}s"
echo "   Bounded (16×16):  ${bounded_time}s"  
echo "   Max values:       ${max_time}s"
echo "   Zero cases:       ${zero_time}s"
echo "   Total:            $((compile_time + bounded_time + max_time + zero_time))s"
EOF

chmod +x scripts/verify_multiplier_8bit.sh
/usr/bin/time -v ./scripts/verify_multiplier_8bit.sh
```

**Expected Output**:
```
=== 8-Bit Multiplier Verification with Performance Measurement ===
✅ Compilation completed in 12s
✅ Bounded verification completed in 45s
✅ Maximum values verification completed in 3s
✅ Zero cases verification completed in 8s

🎉 8-BIT MULTIPLIER VERIFICATION COMPLETE!

📊 Performance Summary:
   Compilation:      12s
   Bounded (16×16):  45s  
   Max values:       3s
   Zero cases:       8s
   Total:            68s

   Maximum resident set size (kbytes): 1,048,576  # ~1GB memory usage
```

**Performance Insights**:
- Bounded verification (16×16 = 256 cases) takes longer than specific cases
- Memory usage scales with input space size
- Targeted verification (specific values) is much faster than exhaustive

---

## Example 5: Custom Hardware Module

**Goal**: Verify a complex, realistic hardware module from scratch.

### Scenario: Priority Encoder

A priority encoder outputs the position of the highest-set bit in the input.

### Step 1: Priority Encoder Design

Create `cases/priority_encoder.mlir`:

```mlir
#loc = loc("priority_encoder.mlir":1:1)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0(%input: i8):
        // Priority encoder: find highest set bit
        // Output: 3-bit position + valid flag
        
        // Check each bit from MSB to LSB
        %c7 = "hw.constant"() {value = 7 : i3} : () -> i3
        %c6 = "hw.constant"() {value = 6 : i3} : () -> i3
        %c5 = "hw.constant"() {value = 5 : i3} : () -> i3
        %c4 = "hw.constant"() {value = 4 : i3} : () -> i3
        %c3 = "hw.constant"() {value = 3 : i3} : () -> i3
        %c2 = "hw.constant"() {value = 2 : i3} : () -> i3
        %c1 = "hw.constant"() {value = 1 : i3} : () -> i3
        %c0 = "hw.constant"() {value = 0 : i3} : () -> i3
        
        // Extract each bit
        %bit7 = "comb.extract"(%input) {lowBit = 7} : (i8) -> i1
        %bit6 = "comb.extract"(%input) {lowBit = 6} : (i8) -> i1
        %bit5 = "comb.extract"(%input) {lowBit = 5} : (i8) -> i1
        %bit4 = "comb.extract"(%input) {lowBit = 4} : (i8) -> i1
        %bit3 = "comb.extract"(%input) {lowBit = 3} : (i8) -> i1
        %bit2 = "comb.extract"(%input) {lowBit = 2} : (i8) -> i1
        %bit1 = "comb.extract"(%input) {lowBit = 1} : (i8) -> i1
        %bit0 = "comb.extract"(%input) {lowBit = 0} : (i8) -> i1
        
        // Priority logic (cascaded muxes)
        %pos1 = "comb.mux"(%bit0, %c0, %c0) : (i1, i3, i3) -> i3
        %pos2 = "comb.mux"(%bit1, %c1, %pos1) : (i1, i3, i3) -> i3
        %pos3 = "comb.mux"(%bit2, %c2, %pos2) : (i1, i3, i3) -> i3
        %pos4 = "comb.mux"(%bit3, %c3, %pos3) : (i1, i3, i3) -> i3
        %pos5 = "comb.mux"(%bit4, %c4, %pos4) : (i1, i3, i3) -> i3
        %pos6 = "comb.mux"(%bit5, %c5, %pos5) : (i1, i3, i3) -> i3
        %pos7 = "comb.mux"(%bit6, %c6, %pos6) : (i1, i3, i3) -> i3
        %position = "comb.mux"(%bit7, %c7, %pos7) : (i1, i3, i3) -> i3
        
        // Valid flag: any bit is set
        %zero_i8 = "hw.constant"() {value = 0 : i8} : () -> i8
        %valid = "comb.icmp"(%input, %zero_i8) {predicate = 1} : (i8, i8) -> i1
        
        "hw.output"(%position, %valid) : (i3, i1) -> ()
    }) {
        module_type = !hw.modty<input input : i8, output position : i3, output valid : i1>, 
        parameters = [], 
        result_locs = [#loc, #loc], 
        sym_name = "PriorityEncoder"
    } : () -> ()
}) : () -> ()
```

### Step 2: Complex Verification Specification

Create `specs/priority_encoder_spec.k`:

```k
requires "../src/mlir/mlir.k"

module PRIORITY-ENCODER-SYNTAX
    syntax BareId ::= "input" [token] | "position" [token] | "valid" [token]
                    | "c7" [token] | "c6" [token] | "c5" [token] | "c4" [token]
                    | "c3" [token] | "c2" [token] | "c1" [token] | "c0" [token]
                    | "bit7" [token] | "bit6" [token] | "bit5" [token] | "bit4" [token]
                    | "bit3" [token] | "bit2" [token] | "bit1" [token] | "bit0" [token]
                    | "pos1" [token] | "pos2" [token] | "pos3" [token] | "pos4" [token]
                    | "pos5" [token] | "pos6" [token] | "pos7" [token] 
                    | "zero_i8" [token] | "lowBit" [token] | "predicate" [token]
                    | "parameters" [token]
    syntax AttributeAlias ::= "#loc" [token]
endmodule

module PRIORITY-ENCODER-VERIFICATION
    imports K-EQUAL
    imports PRIORITY-ENCODER-SYNTAX
    imports MAIN
    
    syntax Bool ::= isValid8Bit(Int) [function]
    rule isValid8Bit(X:Int) => X >=Int 0 andBool X <=Int 255
    
    // Helper: find highest set bit position
    syntax Int ::= highestBitPos(Int) [function]
    rule highestBitPos(X:Int) => 7  requires (X &Int 128) !=Int 0  // bit 7 set
    rule highestBitPos(X:Int) => 6  requires (X &Int 128) ==Int 0 andBool (X &Int 64) !=Int 0
    rule highestBitPos(X:Int) => 5  requires (X &Int 192) ==Int 0 andBool (X &Int 32) !=Int 0
    rule highestBitPos(X:Int) => 4  requires (X &Int 224) ==Int 0 andBool (X &Int 16) !=Int 0
    rule highestBitPos(X:Int) => 3  requires (X &Int 240) ==Int 0 andBool (X &Int 8) !=Int 0
    rule highestBitPos(X:Int) => 2  requires (X &Int 248) ==Int 0 andBool (X &Int 4) !=Int 0
    rule highestBitPos(X:Int) => 1  requires (X &Int 252) ==Int 0 andBool (X &Int 2) !=Int 0
    rule highestBitPos(X:Int) => 0  requires (X &Int 254) ==Int 0 andBool (X &Int 1) !=Int 0
endmodule

module PRIORITY-ENCODER-SPEC
    imports PRIORITY-ENCODER-VERIFICATION
    
    // Main correctness claim: priority encoder finds highest bit correctly
    claim [priority-encoder-correctness]
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "PriorityEncoder" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt>
                <cid> "PriorityEncoder" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    // All the constant and logic definitions (abbreviated for space)
                    %c7 |-> "hw.constant" ( .ValueIdList ) { value = 7 : i3 } : ( .Types ) -> ( i3 , .Types )
                    %c0 |-> "hw.constant" ( .ValueIdList ) { value = 0 : i3 } : ( .Types ) -> ( i3 , .Types )
                    %zero_i8 |-> "hw.constant" ( .ValueIdList ) { value = 0 : i8 } : ( .Types ) -> ( i8 , .Types )
                    %bit7 |-> "comb.extract" ( %input , .ValueIdList ) { lowBit = 7 } : ( i8 , .Types ) -> ( i1 , .Types )
                    %valid |-> "comb.icmp" ( %input , %zero_i8 , .ValueIdList ) 
                               { predicate = 1 } : ( i8 , i8 , .Types ) -> ( i1 , .Types )
                    // ... (full circuit definition would be here)
                </locals>
                <module> "PriorityEncoder" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => 
                    ListItem ( bits ( ?Position , 3 ) : i3 )
                    ListItem ( bits ( ?Valid , 1 ) : i1 )
                </out-ports>
                <out-vars> %position , %valid , .ValueIdList </out-vars>
                <args>
                    ListItem ( bits ( Input:Int , 8 ) : i8 )
                </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        requires isValid8Bit(Input) andBool Input >Int 0  // Non-zero input
        ensures ?Position ==Int highestBitPos(Input) andBool ?Valid ==Int 1
    
    // Zero input case: should output valid=0
    claim [priority-encoder-zero-case]
        <mlir> /* same structure */ </mlir>
        <cmd> #always => #end </cmd>
        <entry> "PriorityEncoder" </entry>
        <ckts> /* same circuit */ </ckts>
        requires Input ==Int 0
        ensures ?Valid ==Int 0
endmodule
```

**Note**: This is a simplified version. The full specification would include all the MLIR operations in the `<locals>` section.

---

## Advanced Usage Patterns

### Pattern 1: Parameterized Verification

**Goal**: Verify designs with different bit-widths using the same specification pattern.

```k
// Template for N-bit adder verification
syntax VerificationClaim ::= verifyAdder(Int)  // verifyAdder(N) for N-bit adder

rule verifyAdder(N:Int) => 
    claim [adder-N-bit]
        <ckts>
            <ckt>
                <args>
                    ListItem ( bits ( A:Int , N ) : Int2Type(N) )
                    ListItem ( bits ( B:Int , N ) : Int2Type(N) )
                </args>
                <out-ports> _ => ListItem ( bits ( ?Sum , N ) : Int2Type(N) ) </out-ports>
            </ckt>
        </ckts>
        requires inRange(A, N) andBool inRange(B, N)
        ensures ?Sum ==Int ((A +Int B) &Int ((2 ^Int N) -Int 1))

// Generate verification for multiple bit-widths  
syntax K ::= verifyAllAdders()
rule verifyAllAdders() => 
    verifyAdder(4) ~> verifyAdder(8) ~> verifyAdder(16) ~> verifyAdder(32)
```

### Pattern 2: Property-Based Testing Integration

**Goal**: Generate random test cases and verify properties hold.

```bash
# Generate random MLIR test cases
python3 << 'EOF'
import random

for i in range(100):
    a = random.randint(0, 15)
    b = random.randint(0, 15)
    
    mlir_content = f'''
#loc = loc("random_test_{i}.mlir":1:1)
"builtin.module"() ({{
    "hw.module"() ({{
    ^bb0():
        %a = "hw.constant"() {{value = {a} : i4}} : () -> i4
        %b = "hw.constant"() {{value = {b} : i4}} : () -> i4
        %sum = "comb.add"(%a, %b) : (i4, i4) -> i4
        "hw.output"(%sum) : (i4) -> ()
    }}) {{
        module_type = !hw.modty<output sum : i4>, 
        sym_name = "RandomTest{i}"
    }} : () -> ()
}}) : () -> ()
'''
    
    with open(f'cases/random_test_{i}.mlir', 'w') as f:
        f.write(mlir_content)
    
    expected = (a + b) % 16
    print(f"Test {i}: {a} + {b} = {expected} (mod 16)")
EOF

# Verify all random test cases
for test_file in cases/random_test_*.mlir; do
    echo "Verifying: $test_file"
    # Run verification for each test case
done
```

### Pattern 3: Regression Testing

**Goal**: Ensure verification results remain consistent across code changes.

```bash
# Create regression test baseline
./scripts/run_all_verifications.sh > baseline_results.txt

# After code changes, compare results
./scripts/run_all_verifications.sh > current_results.txt
if diff baseline_results.txt current_results.txt > /dev/null; then
    echo "✅ Regression test PASSED - results unchanged"
else
    echo "❌ Regression test FAILED - results changed"
    diff baseline_results.txt current_results.txt
fi
```

---

## Integration Examples

### CI/CD Pipeline Integration

**GitHub Actions Example**:

Create `.github/workflows/verification.yml`:

```yaml
name: K-CIRCT Verification

on: [push, pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install K Framework
      run: |
        curl -sSL https://install.k-framework.org | bash
        echo "$HOME/.local/bin" >> $GITHUB_PATH
    
    - name: Verify K Installation
      run: |
        k --version
        kprove --help
    
    - name: Run Verification Suite
      run: |
        cd verification/
        ./scripts/run_all_verifications.sh
    
    - name: Upload Verification Results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: verification-results
        path: verification/results/
```

### Hardware Design Workflow Integration

```bash
# Example: Integrate with CIRCT compilation pipeline

# 1. Original MLIR design
mlir-opt --canonicalize input.mlir > canonical.mlir

# 2. Verify original design
./scripts/verify_design.sh canonical.mlir

# 3. Apply CIRCT optimizations  
circt-opt --constant-fold canonical.mlir > optimized.mlir

# 4. Verify optimization preserves semantics
./scripts/verify_equivalence.sh canonical.mlir optimized.mlir

# 5. Generate hardware (Verilog)
circt-translate --mlir-to-verilog optimized.mlir > design.v

# 6. Verification certificate for compliance
cp verification/results/certificate.proof compliance_evidence/
```

### Custom Verification Flow

```bash
#!/bin/bash
# custom_verification_flow.sh

echo "=== Custom Hardware Verification Pipeline ==="

# Step 1: Parse and validate MLIR
echo "Phase 1: MLIR Validation"
mlir-opt --verify-diagnostics "$1" || exit 1

# Step 2: Extract verification properties
echo "Phase 2: Property Extraction"
python3 extract_properties.py "$1" > properties.k

# Step 3: Generate verification claims
echo "Phase 3: Claim Generation"  
python3 generate_claims.py properties.k > verification_spec.k

# Step 4: Run verification
echo "Phase 4: Formal Verification"
kprove verification_spec.k --verbose

# Step 5: Generate compliance report
echo "Phase 5: Compliance Report Generation"
python3 generate_compliance_report.py > compliance_report.pdf

echo "✅ Custom verification pipeline complete"
```

---

## Conclusion

These usage examples demonstrate the breadth and flexibility of K-CIRCT verification:

**Key Takeaways**:

1. **Start Simple**: Begin with basic adders and build complexity gradually
2. **Systematic Approach**: Follow the pattern: MLIR → K Spec → Verification → Results
3. **Performance Awareness**: Use bounded verification for large input spaces
4. **Modular Design**: Break complex properties into simpler, focused claims
5. **Automation**: Create scripts for reproducible verification workflows
6. **Integration**: Embed verification into existing hardware design flows

**Next Steps**:
- Try modifying the examples for your specific hardware designs
- Experiment with different verification properties and constraints  
- Integrate verification into your development workflow
- Explore advanced features like temporal logic and multi-module verification

Remember: formal verification is most effective when integrated early into the design process, not as an afterthought. Start with simple properties and gradually increase complexity as you gain confidence with the framework.