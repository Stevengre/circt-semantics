#!/bin/bash

# K-CIRCT Master Verification Script
# Runs all verification cases and generates comprehensive report

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$VERIFICATION_DIR")"

echo "==============================================="
echo "        K-CIRCT Verification Suite"
echo "==============================================="
echo "Running comprehensive verification of K-CIRCT semantics"
echo "Project root: $PROJECT_ROOT"
echo "Verification directory: $VERIFICATION_DIR"
echo ""

# Create master results directory
MASTER_RESULTS_DIR="$VERIFICATION_DIR/results"
mkdir -p "$MASTER_RESULTS_DIR"

# Initialize summary report
SUMMARY_REPORT="$MASTER_RESULTS_DIR/verification_summary.md"
cat > "$SUMMARY_REPORT" << 'EOF'
# K-CIRCT Verification Summary Report

Generated on: $(date)

## Overview

This report summarizes the verification results for K-CIRCT formal semantics.
Two main verification cases were executed:

1. **Constant Folding Equivalence**: Verifies that constant folding optimizations preserve semantic equivalence
2. **Arithmetic Safety**: Verifies overflow detection properties in 4-bit arithmetic operations

## Test Cases

EOF

# Add timestamp
echo "Generated on: $(date)" >> "$SUMMARY_REPORT"
echo "" >> "$SUMMARY_REPORT"

# Track verification results
TOTAL_VERIFICATIONS=0
PASSED_VERIFICATIONS=0
FAILED_VERIFICATIONS=0

echo "=== Phase 1: Environment Check ==="
echo "Checking verification environment..."

# Check K framework
if ! command -v kprove &> /dev/null; then
    echo "❌ K framework not found"
    echo "Please install K framework and ensure it's in PATH"
    exit 1
else
    K_VERSION=$(k --version 2>&1 | head -n1 || echo "K version unknown")
    echo "✅ K framework found: $K_VERSION"
fi

# Check if kompile is available
if ! command -v kompile &> /dev/null; then
    echo "❌ kompile not found"
    exit 1
else
    echo "✅ kompile found"
fi

echo ""

echo "=== Phase 2: Constant Folding Verification ==="
echo "Running constant folding equivalence verification..."
echo ""

if [[ -f "$SCRIPT_DIR/verify_constant_folding.sh" ]]; then
    chmod +x "$SCRIPT_DIR/verify_constant_folding.sh"
    
    if "$SCRIPT_DIR/verify_constant_folding.sh"; then
        echo "✅ CONSTANT FOLDING VERIFICATION: PASSED"
        PASSED_VERIFICATIONS=$((PASSED_VERIFICATIONS + 1))
        
        cat >> "$SUMMARY_REPORT" << 'EOF'
### 1. Constant Folding Equivalence: ✅ PASSED

**Property Verified**: `%c5 = hw.constant 5` + `%c3 = hw.constant 3` + `%sum = comb.add %c5, %c3` ≡ `%c8 = hw.constant 8`

**Claims Verified**:
- Original module correctness: 5 + 3 = 8
- Optimized module correctness: constant 8 
- Semantic equivalence: both versions produce identical outputs

**Verification Method**: K reachability analysis with symbolic execution

EOF
    else
        echo "❌ CONSTANT FOLDING VERIFICATION: FAILED"
        FAILED_VERIFICATIONS=$((FAILED_VERIFICATIONS + 1))
        
        cat >> "$SUMMARY_REPORT" << 'EOF'
### 1. Constant Folding Equivalence: ❌ FAILED

**Property**: Constant folding optimization equivalence
**Status**: Verification failed - see detailed logs

EOF
    fi
else
    echo "❌ Constant folding verification script not found"
    FAILED_VERIFICATIONS=$((FAILED_VERIFICATIONS + 1))
fi

TOTAL_VERIFICATIONS=$((TOTAL_VERIFICATIONS + 1))
echo ""

echo "=== Phase 3: Arithmetic Safety Verification ==="
echo "Running arithmetic safety and overflow detection verification..."
echo ""

if [[ -f "$SCRIPT_DIR/verify_arithmetic_safety.sh" ]]; then
    chmod +x "$SCRIPT_DIR/verify_arithmetic_safety.sh"
    
    if "$SCRIPT_DIR/verify_arithmetic_safety.sh"; then
        echo "✅ ARITHMETIC SAFETY VERIFICATION: PASSED"
        PASSED_VERIFICATIONS=$((PASSED_VERIFICATIONS + 1))
        
        cat >> "$SUMMARY_REPORT" << 'EOF'
### 2. Arithmetic Safety (4-bit Overflow Detection): ✅ PASSED

**Property Verified**: For 4-bit addition, overflow flag is true iff (a + b) ≥ 16

**Claims Verified**:
- General overflow detection: `overflow = 1 ⟺ (a + b) ≥ 16`
- No overflow case: when `(a + b) < 16`, then `overflow = 0` and `sum = a + b`  
- Overflow case: when `(a + b) ≥ 16`, then `overflow = 1` and `sum = (a + b) mod 16`

**Verification Method**: K symbolic execution with bit-vector constraints

EOF
    else
        echo "❌ ARITHMETIC SAFETY VERIFICATION: FAILED"
        FAILED_VERIFICATIONS=$((FAILED_VERIFICATIONS + 1))
        
        cat >> "$SUMMARY_REPORT" << 'EOF'
### 2. Arithmetic Safety (4-bit Overflow Detection): ❌ FAILED

**Property**: 4-bit arithmetic overflow detection
**Status**: Verification failed - see detailed logs

EOF
    fi
else
    echo "❌ Arithmetic safety verification script not found"
    FAILED_VERIFICATIONS=$((FAILED_VERIFICATIONS + 1))
fi

TOTAL_VERIFICATIONS=$((TOTAL_VERIFICATIONS + 1))

echo ""
echo "=== Phase 4: Generating Comprehensive Report ==="

# Add verification statistics to summary
cat >> "$SUMMARY_REPORT" << EOF

## Verification Statistics

- **Total Verifications**: $TOTAL_VERIFICATIONS
- **Passed**: $PASSED_VERIFICATIONS  
- **Failed**: $FAILED_VERIFICATIONS
- **Success Rate**: $(echo "scale=1; $PASSED_VERIFICATIONS * 100 / $TOTAL_VERIFICATIONS" | bc)%

## Technical Details

### K Framework Configuration
- K Version: $(k --version 2>&1 | head -n1 || echo "Unknown")
- Verification Date: $(date)
- Platform: $(uname -s) $(uname -m)

### File Structure
```
verification/
├── cases/
│   ├── constant_folding_original.mlir
│   ├── constant_folding_optimized.mlir
│   └── adder_4bit_overflow.mlir
├── specs/
│   ├── constant_folding_spec.k
│   └── arithmetic_safety_spec.k
├── scripts/
│   ├── verify_constant_folding.sh
│   ├── verify_arithmetic_safety.sh
│   └── run_all_verifications.sh
└── results/
    ├── constant_folding/
    ├── arithmetic_safety/
    └── verification_summary.md
```

### Verification Approach

The K-CIRCT verification uses formal methods to prove properties about MLIR hardware designs:

1. **Reachability Analysis**: K's symbolic execution engine explores all possible execution paths
2. **Bit-vector Semantics**: Hardware bit-widths and arithmetic are modeled precisely
3. **Symbolic Variables**: Claims use symbolic inputs (A:Int, B:Int) with constraints
4. **Property Specification**: Ensures clauses specify the properties to be verified

### Example Claim Structure

```k
claim
    <mlir> ... </mlir>
    <cmd> #always => #end </cmd>
    <ckts>
        <ckt>
            <args> ListItem ( bits ( A:Int , 4 ) : i4 ) ... </args>
            <out-ports> _ => ListItem ( bits ( ?Result , 4 ) : i4 ) </out-ports>
        </ckt>
    </ckts>
    requires A >=Int 0 andBool A <=Int 15
    ensures ?Result ==Int (A +Int B) mod 16
```

EOF

# Final verification status
echo ""
echo "==============================================="
echo "        Verification Complete"
echo "==============================================="

if [[ $FAILED_VERIFICATIONS -eq 0 ]]; then
    echo "🎉 ALL VERIFICATIONS PASSED!"
    echo ""
    echo "✅ Constant Folding Equivalence: VERIFIED"
    echo "✅ Arithmetic Safety (Overflow): VERIFIED" 
    echo ""
    echo "K-CIRCT formal semantics successfully verified for:"
    echo "- MLIR constant folding optimizations"
    echo "- Hardware arithmetic overflow detection"
    echo "- Bit-vector semantics preservation"
else
    echo "❌ SOME VERIFICATIONS FAILED"
    echo ""
    echo "Failed verifications: $FAILED_VERIFICATIONS/$TOTAL_VERIFICATIONS"
    echo "Please check detailed logs in: $MASTER_RESULTS_DIR"
fi

echo ""
echo "📊 Complete verification report: $SUMMARY_REPORT"
echo "📂 Detailed results in: $MASTER_RESULTS_DIR"

echo ""
echo "=== Future Verification Opportunities ==="
echo "1. Extend to more CIRCT dialects (seq, sv)"
echo "2. Verify larger hardware designs (processors, memory controllers)"
echo "3. Add temporal logic properties (LTL/CTL)"
echo "4. Integration with existing hardware verification flows"
echo "5. Prove compiler optimization correctness at scale"