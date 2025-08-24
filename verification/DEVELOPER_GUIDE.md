# K-CIRCT Verification Framework: Developer Guide

**Complete Guide to Adding New Verification Cases**

This guide provides step-by-step instructions for extending the K-CIRCT verification framework with new hardware verification cases. Whether you're verifying compiler optimizations, hardware safety properties, or complex circuit behaviors, this guide will walk you through the entire process.

## 📋 Table of Contents

1. [Prerequisites and Setup](#prerequisites-and-setup)
2. [Verification Case Development Workflow](#verification-case-development-workflow)
3. [MLIR Hardware Module Design](#mlir-hardware-module-design)
4. [K Specification Writing](#k-specification-writing)
5. [Verification Script Creation](#verification-script-creation)
6. [Testing and Validation](#testing-and-validation)
7. [Integration with Master Scripts](#integration-with-master-scripts)
8. [Advanced Verification Patterns](#advanced-verification-patterns)
9. [Performance Optimization](#performance-optimization)
10. [Troubleshooting Common Issues](#troubleshooting-common-issues)

---

## Prerequisites and Setup

### Required Knowledge

- **MLIR/CIRCT**: Understanding of MLIR operations and CIRCT dialects (`hw`, `comb`, `sv`, `seq`)
- **K Framework**: Basic familiarity with K's syntax and reachability logic
- **Hardware Design**: Digital circuit concepts (combinational/sequential logic, bit-vectors)
- **Formal Methods**: Understanding of symbolic execution and property verification

### Development Environment

```bash
# 1. Install K Framework (version 6.0+)
curl -sSL https://install.k-framework.org | bash
export PATH="$PATH:$HOME/.local/bin"

# 2. Verify K installation
k --version && kprove --help && kompile --help

# 3. Set up K-CIRCT repository
git clone <circt-semantics-repo>
cd ext/circt-semantics
```

### Directory Structure Setup

```bash
verification/
├── cases/your_new_case.mlir          # Your MLIR hardware design
├── specs/your_new_case_spec.k        # Your K verification specification
├── scripts/verify_your_new_case.sh   # Your verification script
└── results/your_new_case/            # Generated results (auto-created)
```

---

## Verification Case Development Workflow

### Phase 1: Problem Definition

1. **Define the Property to Verify**
   ```
   Example: "Multiplier produces correct product for all 4-bit inputs"
   Mathematical: ∀a,b ∈ [0,15] : multiply(a,b) = a × b
   ```

2. **Identify Input/Output Constraints**
   ```
   Inputs: 4-bit unsigned integers (range [0,15])
   Outputs: 8-bit product (range [0,225])
   Properties: No overflow for 8-bit output, exact multiplication
   ```

3. **Choose Verification Strategy**
   - **Exhaustive**: Cover all possible inputs (suitable for small input spaces)
   - **Constrained**: Use specific input ranges or conditions
   - **Equivalence**: Compare two different implementations

### Phase 2: MLIR Design

4. **Create Hardware Module** (`cases/multiplier_4bit.mlir`)
5. **Validate MLIR Syntax** (ensure CIRCT can parse it)
6. **Test with Sample Inputs** (optional simulation)

### Phase 3: K Specification

7. **Write K Claims** (`specs/multiplier_4bit_spec.k`)
8. **Define Symbolic Variables** and constraints
9. **Specify Verification Properties**

### Phase 4: Automation

10. **Create Verification Script** (`scripts/verify_multiplier_4bit.sh`)
11. **Test Individual Verification**
12. **Integrate with Master Scripts**

---

## MLIR Hardware Module Design

### Example: 4-Bit Multiplier

```mlir
// cases/multiplier_4bit.mlir
#loc = loc("multiplier_4bit.mlir":1:1)
#loc1 = loc("multiplier_4bit.mlir":2:1)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0(%a: i4, %b: i4):
        // Extend inputs to prevent intermediate overflow
        %a_ext = "comb.concat"(%c0_i4, %a) : (i4, i4) -> i8
        %b_ext = "comb.concat"(%c0_i4, %b) : (i4, i4) -> i8
        %c0_i4 = "hw.constant"() {value = 0 : i4} : () -> i4
        
        // Perform 8-bit multiplication
        %product = "comb.mul"(%a_ext, %b_ext) : (i8, i8) -> i8
        
        "hw.output"(%product) : (i8) -> ()
    }) {
        module_type = !hw.modty<input a : i4, input b : i4, output product : i8>, 
        parameters = [], 
        result_locs = [#loc1], 
        sym_name = "Multiplier4Bit"
    } : () -> ()
}) : () -> ()
```

### MLIR Design Best Practices

1. **Consistent Naming**
   ```mlir
   sym_name = "ModuleNameCamelCase"    # Module names in CamelCase
   %input_name : i4                    # Variables in snake_case
   #loc = loc("filename.mlir":1:1)     # Location attributes for debugging
   ```

2. **Type Safety**
   ```mlir
   // Explicit bit-width specifications
   %a: i4                              # 4-bit input
   %product: i8                        # 8-bit output
   %constant = "hw.constant"() {value = 42 : i8} : () -> i8
   ```

3. **Hardware Realism**
   ```mlir
   // Use realistic hardware constructs
   %a_ext = "comb.concat"(%zero, %a)   # Zero-extension (realistic)
   // Avoid abstract operations that don't map to hardware
   ```

4. **Module Type Declarations**
   ```mlir
   module_type = !hw.modty<
       input a : i4, 
       input b : i4, 
       output product : i8
   >
   ```

### Supported CIRCT Operations

#### Combinational Logic (`comb` dialect)
```mlir
%add = "comb.add"(%a, %b) : (i8, i8) -> i8               # Addition
%sub = "comb.sub"(%a, %b) : (i8, i8) -> i8               # Subtraction  
%mul = "comb.mul"(%a, %b) : (i8, i8) -> i8               # Multiplication
%and = "comb.and"(%a, %b) : (i8, i8) -> i8               # Bitwise AND
%or = "comb.or"(%a, %b) : (i8, i8) -> i8                 # Bitwise OR
%xor = "comb.xor"(%a, %b) : (i8, i8) -> i8               # Bitwise XOR
%shl = "comb.shl"(%a, %shift) : (i8, i3) -> i8           # Left shift
%shr = "comb.shru"(%a, %shift) : (i8, i3) -> i8          # Right shift (unsigned)
%extract = "comb.extract"(%a) {lowBit = 4} : (i8) -> i4   # Bit extraction
%concat = "comb.concat"(%high, %low) : (i4, i4) -> i8     # Concatenation
%mux = "comb.mux"(%sel, %a, %b) : (i1, i8, i8) -> i8     # Multiplexer
%icmp = "comb.icmp"(%a, %b) {predicate = 2} : (i8, i8) -> i1  # Comparison (eq, ne, etc.)
```

#### Hardware Structures (`hw` dialect)
```mlir
%const = "hw.constant"() {value = 42 : i8} : () -> i8     # Constants
"hw.output"(%result) : (i8) -> ()                        # Module outputs
"hw.module"() ({ ... }) { sym_name = "ModName" }         # Module definition
```

---

## K Specification Writing

### Template Structure

```k
requires "../src/mlir/mlir.k"

module YOUR-CASE-SYNTAX
    // Define tokens used in your MLIR
    syntax BareId ::= "a" [token] | "b" [token] | "product" [token]
                    | "value" [token] | "parameters" [token]
    
    syntax AttributeAlias ::= "#loc" [token] | "#loc1" [token]
endmodule

module YOUR-CASE-VERIFICATION
    imports K-EQUAL
    imports YOUR-CASE-SYNTAX  
    imports MAIN
    
    // Helper functions and simplification rules
    syntax Bool ::= isValid4Bit(Int) [function]
    rule isValid4Bit(X:Int) => X >=Int 0 andBool X <=Int 15
endmodule

module YOUR-CASE-SPEC
    imports YOUR-CASE-VERIFICATION
    
    // Your verification claims go here
    claim [your-claim-name]
        // ... claim structure ...
endmodule
```

### Claim Structure Deep Dive

```k
claim [descriptive-claim-name]
    // === MLIR Context (usually standard) ===
    <mlir>
        <prog> .K </prog>
        <phase> #build </phase>
        <types> .Map </types>
        <attrs> .Map </attrs>
        <table> .Map </table>
    </mlir>
    
    // === Execution Control ===
    <cmd> #always => #end </cmd>              // Run to completion
    <entry> "YourModuleName" </entry>         // Entry point module
    <input> .List </input>                    // No external inputs for comb logic
    <clock> 0 </clock>                        // Clock cycle (0 for combinational)
    <running> .List </running>                // Running processes (empty)
    <boot> .List </boot>                      // Boot processes (empty)
    
    // === Circuit Structure ===
    <ckts>
        <ckt>
            <cid> "YourModuleName" </cid>
            <always> .List </always>          // Always blocks (empty for comb)
            <initial> .List </initial>        // Initial blocks (empty for comb)
            <k> #HwOutput => .K </k>          // K continuation (standard)
            <parent> "" </parent>             // Parent module (empty for top-level)
            <last> .Map </last>               // Last values (empty initially)
            
            // === The Heart: MLIR Operations ===
            <locals>
                // Map your MLIR operations exactly as they appear
                %a_ext |-> "comb.concat" ( %c0_i4 , %a , .ValueIdList ) 
                           : ( i4 , i4 , .Types ) -> ( i8 , .Types )
                %b_ext |-> "comb.concat" ( %c0_i4 , %b , .ValueIdList ) 
                           : ( i4 , i4 , .Types ) -> ( i8 , .Types )
                %product |-> "comb.mul" ( %a_ext , %b_ext , .ValueIdList ) 
                            : ( i8 , i8 , .Types ) -> ( i8 , .Types )
            </locals>
            
            <module> "YourModuleName" </module>
            
            // === Input/Output Ports ===
            <in-ports> .List </in-ports>      // Input port information
            <in-vars> .ValueIdAndTypeList </in-vars>  // Input variable mapping
            <out-ports> _ => ListItem ( bits ( ?Product , 8 ) : i8 ) </out-ports>
            <out-vars> %product , .ValueIdList </out-vars>
            
            // === Symbolic Inputs ===
            <args>
                ListItem ( bits ( A:Int , 4 ) : i4 )    // Symbolic input A
                ListItem ( bits ( B:Int , 4 ) : i4 )    // Symbolic input B
            </args>
            
            <regs> .Map </regs>               // Register state (empty for comb)
            <wires> .Map </wires>             // Wire connections (empty)
        </ckt>
    </ckts>
    
    // === Verification Specification ===
    requires isValid4Bit(A) andBool isValid4Bit(B)    // Input constraints
    ensures ?Product ==Int (A *Int B)                 // Property to verify
```

### Key K Specification Patterns

#### 1. Symbolic Variables
```k
// Symbolic inputs with constraints
<args>
    ListItem ( bits ( A:Int , 4 ) : i4 )     // A represents all possible 4-bit values
    ListItem ( bits ( B:Int , 4 ) : i4 )     // B represents all possible 4-bit values
</args>

// Constraint symbolic variables
requires A >=Int 0 andBool A <=Int 15        // A ∈ [0,15]
     andBool B >=Int 0 andBool B <=Int 15    // B ∈ [0,15]
```

#### 2. Output Capture
```k
// Capture symbolic outputs
<out-ports> _ => 
    ListItem ( bits ( ?Result , 8 ) : i8 )     // ?Result captures the output
    ListItem ( bits ( ?Overflow , 1 ) : i1 )   // Multiple outputs supported
</out-ports>

// Verify properties of outputs
ensures ?Result ==Int (A *Int B)               // Exact multiplication
    andBool ?Result >=Int 0                    // Non-negative result
    andBool ?Result <=Int 225                  // Maximum possible (15*15)
```

#### 3. Complex Properties
```k
// Conditional properties
ensures (A ==Int 0 orBool B ==Int 0) impliesBool (?Result ==Int 0)

// Range properties  
ensures ?Result >=Int (A *Int B) andBool ?Result <=Int (A *Int B)

// Bitwise properties
ensures (?Result &Int 255) ==Int ?Result       // Result fits in 8 bits
```

#### 4. Multiple Claims Strategy
```k
// Claim 1: General correctness
claim [multiplier-correctness]
    // ... full claim ...
    requires isValid4Bit(A) andBool isValid4Bit(B)
    ensures ?Product ==Int (A *Int B)

// Claim 2: Edge case - zero inputs
claim [multiplier-zero-cases]  
    // ... full claim ...
    requires (A ==Int 0 orBool B ==Int 0)
    ensures ?Product ==Int 0

// Claim 3: Maximum values
claim [multiplier-max-case]
    // ... full claim ...
    requires A ==Int 15 andBool B ==Int 15
    ensures ?Product ==Int 225
```

---

## Verification Script Creation

### Template Script

```bash
#!/bin/bash
# scripts/verify_your_new_case.sh

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$VERIFICATION_DIR")"

echo "=== K-CIRCT Your New Case Verification ==="
echo "Script directory: $SCRIPT_DIR"
echo "Verification directory: $VERIFICATION_DIR"
echo "Project root: $PROJECT_ROOT"
echo ""

# Check K framework availability
if ! command -v kprove &> /dev/null; then
    echo "Error: K framework (kprove) not found in PATH"
    echo "Please install K framework: https://github.com/runtimeverification/k"
    exit 1
fi

# Check required files
MLIR_FILE="$VERIFICATION_DIR/cases/your_new_case.mlir"
SPEC_FILE="$VERIFICATION_DIR/specs/your_new_case_spec.k"

if [[ ! -f "$MLIR_FILE" ]]; then
    echo "Error: MLIR file not found: $MLIR_FILE"
    exit 1
fi

if [[ ! -f "$SPEC_FILE" ]]; then
    echo "Error: K specification file not found: $SPEC_FILE"
    exit 1
fi

echo "Found required files:"
echo "  MLIR: $MLIR_FILE"
echo "  Specification: $SPEC_FILE"
echo ""

# Create output directory
OUTPUT_DIR="$VERIFICATION_DIR/results/your_new_case"
mkdir -p "$OUTPUT_DIR"

echo "=== Step 1: Kompiling K Specification ==="
cd "$PROJECT_ROOT"

# Compile the specification
kompile -v "$SPEC_FILE" \
    --syntax-module YOUR-CASE-SYNTAX \
    --main-module YOUR-CASE-SPEC \
    -o "$OUTPUT_DIR/your-case-kompiled"

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to compile K specification"
    exit 1
fi

echo "✓ K specification compiled successfully"
echo ""

echo "=== Step 2: Running Verification Claims ==="

# Run each claim individually
CLAIMS=("your-claim-1" "your-claim-2" "your-claim-3")
PASSED_CLAIMS=0
TOTAL_CLAIMS=${#CLAIMS[@]}

for claim in "${CLAIMS[@]}"; do
    echo "Verifying claim: $claim"
    
    if kprove "$SPEC_FILE" \
        --definition "$OUTPUT_DIR/your-case-kompiled" \
        --spec-module YOUR-CASE-SPEC \
        --claim "$claim" \
        --output-file "$OUTPUT_DIR/${claim}_verification.log" \
        --verbose; then
        echo "✓ Claim '$claim' PASSED"
        PASSED_CLAIMS=$((PASSED_CLAIMS + 1))
    else
        echo "✗ Claim '$claim' FAILED"
        echo "  See: $OUTPUT_DIR/${claim}_verification.log"
    fi
    echo ""
done

# Summary
echo "=== Verification Summary ==="
echo "Claims passed: $PASSED_CLAIMS/$TOTAL_CLAIMS"

if [[ $PASSED_CLAIMS -eq $TOTAL_CLAIMS ]]; then
    echo "🎉 YOUR NEW CASE VERIFICATION SUCCESSFUL!"
    exit 0
else
    echo "❌ Some claims failed. Check logs in: $OUTPUT_DIR"
    exit 1
fi
```

### Script Best Practices

1. **Error Handling**
   ```bash
   set -e                          # Exit on any error
   set -u                          # Exit on undefined variables
   set -o pipefail                 # Fail on pipe errors
   ```

2. **Path Management**
   ```bash
   # Robust path calculation
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
   ```

3. **Dependency Checking**
   ```bash
   # Check all dependencies upfront
   for cmd in kprove kompile; do
       if ! command -v "$cmd" &> /dev/null; then
           echo "Error: $cmd not found"
           exit 1
       fi
   done
   ```

4. **Informative Output**
   ```bash
   echo "=== Phase: Description ==="     # Clear phase separation
   echo "✓ Success message"              # Success indicators
   echo "✗ Failure message"              # Failure indicators  
   echo "🎉 Celebration message"         # Final success
   ```

---

## Testing and Validation

### 1. Syntax Validation

```bash
# Test MLIR syntax
mlir-opt cases/your_new_case.mlir --verify-diagnostics

# Test K specification syntax
kompile specs/your_new_case_spec.k --syntax-module YOUR-CASE-SYNTAX
```

### 2. Individual Claim Testing

```bash
# Test each claim separately
kprove specs/your_new_case_spec.k \
    --claim "your-claim-1" \
    --definition "./results/your_new_case/kompiled" \
    --verbose --debug
```

### 3. Performance Testing

```bash
# Measure verification time
time ./scripts/verify_your_new_case.sh

# Profile memory usage
/usr/bin/time -v ./scripts/verify_your_new_case.sh
```

### 4. Regression Testing

```bash
# Ensure existing tests still pass
./scripts/run_all_verifications.sh

# Compare results with known good runs
diff results/your_new_case/summary.log expected_results/
```

---

## Integration with Master Scripts

### 1. Update `run_all_verifications.sh`

Add your case to the master verification script:

```bash
# Around line 120, add your verification case:
echo "=== Phase 3: Your New Case Verification ==="
echo "Running your new case verification..."

if [[ -f "$SCRIPT_DIR/verify_your_new_case.sh" ]]; then
    chmod +x "$SCRIPT_DIR/verify_your_new_case.sh"
    
    if "$SCRIPT_DIR/verify_your_new_case.sh"; then
        echo "✅ YOUR NEW CASE VERIFICATION: PASSED"
        PASSED_VERIFICATIONS=$((PASSED_VERIFICATIONS + 1))
        
        cat >> "$SUMMARY_REPORT" << 'EOF'
### 3. Your New Case: ✅ PASSED

**Property Verified**: Your mathematical property description

**Claims Verified**:
- Claim 1 description
- Claim 2 description  
- Claim 3 description

**Verification Method**: K symbolic execution with bit-vector constraints

EOF
    else
        echo "❌ YOUR NEW CASE VERIFICATION: FAILED"
        FAILED_VERIFICATIONS=$((FAILED_VERIFICATIONS + 1))
    fi
fi

TOTAL_VERIFICATIONS=$((TOTAL_VERIFICATIONS + 1))
```

### 2. Update Documentation

Add your case to the main `README.md`:

```markdown
3. **Your New Case** - Description of what it verifies
```

---

## Advanced Verification Patterns

### 1. Sequential Logic Verification

For circuits with registers and clocks:

```k
claim [sequential-claim]
    <ckts>
        <ckt>
            // Add register state
            <regs>
                register_name |-> bits(InitialValue:Int, Width)
            </regs>
            
            // Clock-driven execution
            <k> #Clock => .K </k>
            
            // Multiple clock cycles
            <locals>
                %reg |-> "seq.firreg" (%input) { reset = %reset, clock = %clk }
            </locals>
        </ckt>
    </ckts>
    requires ...
    ensures ... // Properties after N clock cycles
```

### 2. Parametric Verification

For designs with configurable parameters:

```k
// Verify for multiple bit-widths
claim [parametric-claim-8bit]
    // ... 8-bit version ...

claim [parametric-claim-16bit] 
    // ... 16-bit version ...

claim [parametric-claim-32bit]
    // ... 32-bit version ...
```

### 3. Multi-Module Verification

For hierarchical designs:

```k
<ckts>
    <ckt>
        <cid> "TopModule" </cid>
        <locals>
            %instance |-> "hw.instance" "SubModule" (%inputs) : (...) -> (...)
        </locals>
    </ckt>
    <ckt>
        <cid> "SubModule" </cid>
        <locals> ... sub-module operations ... </locals>
    </ckt>
</ckts>
```

### 4. Property-Based Testing Patterns

```k
// Universal quantification
ensures forAll(X:Int, 
    (X >=Int 0 andBool X <=Int 15) impliesBool 
    (?Output >=Int someFunction(X))
)

// Existential quantification
ensures exists(X:Int, 
    ?Output ==Int X andBool X >=Int 0
)
```

---

## Performance Optimization

### 1. Constraint Optimization

```k
// Instead of large ranges:
requires A >=Int 0 andBool A <=Int 65535  // 16-bit: 65536 cases

// Use targeted constraints:
requires A >=Int 0 andBool A <=Int 15     // 4-bit: 16 cases
     andBool A =/=Int 7                   // Exclude specific problematic values
```

### 2. Claim Decomposition

```k
// Instead of one complex claim:
claim [big-complex-claim]
    requires ComplexCondition1 andBool ComplexCondition2 andBool ComplexCondition3
    ensures ComplexProperty1 andBool ComplexProperty2 andBool ComplexProperty3

// Break into smaller claims:
claim [simple-claim-1]
    requires ComplexCondition1
    ensures ComplexProperty1

claim [simple-claim-2]
    requires ComplexCondition2
    ensures ComplexProperty2
```

### 3. Symbolic Variable Management

```k
// Minimize symbolic variables
<args>
    ListItem ( bits ( A:Int , 4 ) : i4 )       // Only what you need
    // Don't add unnecessary symbolic variables
</args>

// Use concrete values when possible
requires A ==Int 5                            // Concrete value
// Instead of: A >=Int 5 andBool A <=Int 5    // Unnecessary constraint
```

---

## Troubleshooting Common Issues

### 1. Compilation Errors

**Error**: `Module not found: YOUR-CASE-SYNTAX`
```bash
# Solution: Check module names match exactly
module YOUR-CASE-SYNTAX    # In spec file
kompile --syntax-module YOUR-CASE-SYNTAX  # In script
```

**Error**: `Token not defined: your_token`
```bash
# Solution: Add all tokens used in MLIR
syntax BareId ::= "your_token" [token]
                | "another_token" [token]
```

### 2. Runtime Verification Errors

**Error**: `Claim failed: requires condition not met`
```bash
# Solution: Check your constraint logic
requires A >=Int 0 andBool A <=Int 15  # Correct 4-bit range
# Not: requires A >=Int 0 andBool A <=Int 16  # Wrong range
```

**Error**: `Symbolic execution timeout`
```bash
# Solution: Reduce complexity or add timeouts
kprove --timeout 300 specs/your_case_spec.k  # 5 minute timeout
```

### 3. MLIR Operation Mapping

**Error**: `Operation not found in locals`
```bash
# Solution: Ensure exact MLIR operation mapping
// In MLIR:
%result = "comb.add"(%a, %b) : (i8, i8) -> i8

// In K spec (must match exactly):
%result |-> "comb.add" ( %a , %b , .ValueIdList ) : ( i8 , i8 , .Types ) -> ( i8 , .Types )
```

### 4. Debugging Strategies

```bash
# 1. Enable verbose output
kprove --verbose specs/your_case_spec.k

# 2. Check intermediate states
kprove --debug specs/your_case_spec.k

# 3. Simplify claims progressively
# Start with trivial claim, then add complexity

# 4. Check K framework logs
ls -la .k-*                    # Look for temporary K files
```

---

## Example: Complete Walkthrough

Let's implement a complete example: **4-Bit Comparator Verification**

### Step 1: MLIR Design

```mlir
// cases/comparator_4bit.mlir
#loc = loc("comparator_4bit.mlir":1:1)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0(%a: i4, %b: i4):
        // Comparison operations
        %eq = "comb.icmp"(%a, %b) {predicate = 0} : (i4, i4) -> i1  // Equal
        %lt = "comb.icmp"(%a, %b) {predicate = 8} : (i4, i4) -> i1  // Less than
        %gt = "comb.icmp"(%a, %b) {predicate = 4} : (i4, i4) -> i1  // Greater than
        
        "hw.output"(%eq, %lt, %gt) : (i1, i1, i1) -> ()
    }) {
        module_type = !hw.modty<
            input a : i4, input b : i4, 
            output eq : i1, output lt : i1, output gt : i1
        >, 
        parameters = [], 
        result_locs = [#loc, #loc, #loc], 
        sym_name = "Comparator4Bit"
    } : () -> ()
}) : () -> ()
```

### Step 2: K Specification

```k
// specs/comparator_4bit_spec.k
requires "../src/mlir/mlir.k"

module COMPARATOR-4BIT-SYNTAX
    syntax BareId ::= "a" [token] | "b" [token] 
                    | "eq" [token] | "lt" [token] | "gt" [token]
                    | "predicate" [token] | "parameters" [token]
    
    syntax AttributeAlias ::= "#loc" [token]
endmodule

module COMPARATOR-4BIT-VERIFICATION
    imports K-EQUAL
    imports COMPARATOR-4BIT-SYNTAX
    imports MAIN
    
    syntax Bool ::= isValid4Bit(Int) [function]
    rule isValid4Bit(X:Int) => X >=Int 0 andBool X <=Int 15
endmodule

module COMPARATOR-4BIT-SPEC
    imports COMPARATOR-4BIT-VERIFICATION
    
    // Claim 1: Mutual exclusivity (exactly one comparison result is true)
    claim [comparator-mutual-exclusivity]
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "Comparator4Bit" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt>
                <cid> "Comparator4Bit" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %eq |-> "comb.icmp" ( %a , %b , .ValueIdList ) { predicate = 0 } : ( i4 , i4 , .Types ) -> ( i1 , .Types )
                    %lt |-> "comb.icmp" ( %a , %b , .ValueIdList ) { predicate = 8 } : ( i4 , i4 , .Types ) -> ( i1 , .Types )
                    %gt |-> "comb.icmp" ( %a , %b , .ValueIdList ) { predicate = 4 } : ( i4 , i4 , .Types ) -> ( i1 , .Types )
                </locals>
                <module> "Comparator4Bit" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => 
                    ListItem ( bits ( ?Eq , 1 ) : i1 )
                    ListItem ( bits ( ?Lt , 1 ) : i1 ) 
                    ListItem ( bits ( ?Gt , 1 ) : i1 )
                </out-ports>
                <out-vars> %eq , %lt , %gt , .ValueIdList </out-vars>
                <args>
                    ListItem ( bits ( A:Int , 4 ) : i4 )
                    ListItem ( bits ( B:Int , 4 ) : i4 )
                </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        requires isValid4Bit(A) andBool isValid4Bit(B)
        ensures (?Eq +Int ?Lt +Int ?Gt) ==Int 1  // Exactly one output is true
    
    // Claim 2: Equality correctness
    claim [comparator-equality]
        // ... same structure ...
        requires isValid4Bit(A) andBool isValid4Bit(B)
        ensures (?Eq ==Int 1) ==Bool (A ==Int B)
    
    // Claim 3: Less than correctness  
    claim [comparator-less-than]
        // ... same structure ...
        requires isValid4Bit(A) andBool isValid4Bit(B)
        ensures (?Lt ==Int 1) ==Bool (A <Int B)
    
    // Claim 4: Greater than correctness
    claim [comparator-greater-than]
        // ... same structure ...
        requires isValid4Bit(A) andBool isValid4Bit(B)
        ensures (?Gt ==Int 1) ==Bool (A >Int B)
endmodule
```

### Step 3: Verification Script

```bash
#!/bin/bash
# scripts/verify_comparator_4bit.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$VERIFICATION_DIR")"

echo "=== K-CIRCT 4-Bit Comparator Verification ==="
echo ""

# Check dependencies
if ! command -v kprove &> /dev/null; then
    echo "Error: K framework not found"
    exit 1
fi

# Check files
MLIR_FILE="$VERIFICATION_DIR/cases/comparator_4bit.mlir"
SPEC_FILE="$VERIFICATION_DIR/specs/comparator_4bit_spec.k"

for file in "$MLIR_FILE" "$SPEC_FILE"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: Required file not found: $file"
        exit 1
    fi
done

OUTPUT_DIR="$VERIFICATION_DIR/results/comparator_4bit"
mkdir -p "$OUTPUT_DIR"

echo "=== Kompiling Specification ==="
cd "$PROJECT_ROOT"

kompile -v "$SPEC_FILE" \
    --syntax-module COMPARATOR-4BIT-SYNTAX \
    --main-module COMPARATOR-4BIT-SPEC \
    -o "$OUTPUT_DIR/comparator-kompiled"

echo "✓ Compilation successful"
echo ""

echo "=== Running Verification Claims ==="

CLAIMS=("comparator-mutual-exclusivity" "comparator-equality" 
        "comparator-less-than" "comparator-greater-than")
PASSED=0

for claim in "${CLAIMS[@]}"; do
    echo "Verifying: $claim"
    
    if kprove "$SPEC_FILE" \
        --definition "$OUTPUT_DIR/comparator-kompiled" \
        --spec-module COMPARATOR-4BIT-SPEC \
        --claim "$claim" \
        --output-file "$OUTPUT_DIR/${claim}.log"; then
        echo "✓ $claim PASSED"
        PASSED=$((PASSED + 1))
    else
        echo "✗ $claim FAILED"
    fi
done

echo ""
echo "=== Results ==="
if [[ $PASSED -eq ${#CLAIMS[@]} ]]; then
    echo "🎉 4-BIT COMPARATOR VERIFICATION SUCCESSFUL!"
    echo "All ${#CLAIMS[@]} claims verified:"
    printf '  ✓ %s\n' "${CLAIMS[@]}"
else
    echo "❌ $PASSED/${#CLAIMS[@]} claims passed"
fi
```

### Step 4: Integration

Add to `run_all_verifications.sh`:

```bash
echo "=== Phase N: 4-Bit Comparator Verification ==="
if "$SCRIPT_DIR/verify_comparator_4bit.sh"; then
    echo "✅ COMPARATOR VERIFICATION: PASSED"
    PASSED_VERIFICATIONS=$((PASSED_VERIFICATIONS + 1))
else
    echo "❌ COMPARATOR VERIFICATION: FAILED"
    FAILED_VERIFICATIONS=$((FAILED_VERIFICATIONS + 1))
fi
TOTAL_VERIFICATIONS=$((TOTAL_VERIFICATIONS + 1))
```

---

This completes the comprehensive Developer Guide for the K-CIRCT Verification Framework. The guide provides everything needed to add new verification cases, from initial design through integration with the existing framework.