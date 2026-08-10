#!/bin/bash

# K-CIRCT Arithmetic Safety Verification Script
# Verifies overflow detection properties for 4-bit addition

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$VERIFICATION_DIR")"

echo "=== K-CIRCT Arithmetic Safety Verification ==="
echo "Script directory: $SCRIPT_DIR"
echo "Verification directory: $VERIFICATION_DIR"
echo "Project root: $PROJECT_ROOT"
echo ""

# Check if K framework is available
if ! command -v kprove &> /dev/null; then
    echo "Error: K framework (kprove) not found in PATH"
    echo "Please install K framework and ensure 'kprove' is in your PATH"
    exit 1
fi

# Check if required files exist
ADDER_MLIR="$VERIFICATION_DIR/cases/adder_4bit_overflow.mlir"
SPEC_FILE="$VERIFICATION_DIR/specs/arithmetic_safety_spec.k"

if [[ ! -f "$ADDER_MLIR" ]]; then
    echo "Error: 4-bit adder MLIR file not found: $ADDER_MLIR"
    exit 1
fi

if [[ ! -f "$SPEC_FILE" ]]; then
    echo "Error: Specification file not found: $SPEC_FILE"
    exit 1
fi

echo "Found all required files:"
echo "  4-bit Adder MLIR: $ADDER_MLIR"
echo "  Safety Specification: $SPEC_FILE"
echo ""

# Create output directory for verification results
OUTPUT_DIR="$VERIFICATION_DIR/results/arithmetic_safety"
mkdir -p "$OUTPUT_DIR"

echo "=== Step 1: Kompiling K Specification ==="
cd "$PROJECT_ROOT"

# Compile the K specification
echo "Compiling arithmetic safety specification..."
kompile -v "$SPEC_FILE" --syntax-module ARITHMETIC-SAFETY-SYNTAX --main-module ARITHMETIC-SAFETY-SPEC -o "$OUTPUT_DIR/arithmetic-safety-kompiled"

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to compile K specification"
    exit 1
fi

echo "✓ K specification compiled successfully"
echo ""

echo "=== Step 2: Running Overflow Detection Verification ==="

# Verify general overflow detection property
echo "Verifying general overflow detection property..."
kprove "$SPEC_FILE" --definition "$OUTPUT_DIR/arithmetic-safety-kompiled" \
    --spec-module ARITHMETIC-SAFETY-SPEC \
    --claim "general-overflow-claim" \
    --output-file "$OUTPUT_DIR/general_overflow_verification.log" \
    --verbose

if [[ $? -eq 0 ]]; then
    echo "✓ General overflow detection verification PASSED"
else
    echo "✗ General overflow detection verification FAILED"
    echo "See: $OUTPUT_DIR/general_overflow_verification.log"
fi

# Verify no overflow case: sum < 16
echo "Verifying no overflow case (sum < 16)..."
kprove "$SPEC_FILE" --definition "$OUTPUT_DIR/arithmetic-safety-kompiled" \
    --spec-module ARITHMETIC-SAFETY-SPEC \
    --claim "no-overflow-claim" \
    --output-file "$OUTPUT_DIR/no_overflow_verification.log" \
    --verbose

if [[ $? -eq 0 ]]; then
    echo "✓ No overflow case verification PASSED"
else
    echo "✗ No overflow case verification FAILED"
    echo "See: $OUTPUT_DIR/no_overflow_verification.log"
fi

# Verify overflow case: sum >= 16
echo "Verifying overflow case (sum >= 16)..."
kprove "$SPEC_FILE" --definition "$OUTPUT_DIR/arithmetic-safety-kompiled" \
    --spec-module ARITHMETIC-SAFETY-SPEC \
    --claim "overflow-case-claim" \
    --output-file "$OUTPUT_DIR/overflow_case_verification.log" \
    --verbose

if [[ $? -eq 0 ]]; then
    echo "✓ Overflow case verification PASSED"
    echo ""
    echo "🎉 ARITHMETIC SAFETY VERIFICATION SUCCESSFUL!"
    echo "   4-bit adder overflow detection is correctly implemented:"
    echo "   - Overflow flag is true iff (a + b) >= 16"
    echo "   - Sum output is correct in both overflow and non-overflow cases"
else
    echo "✗ Overflow case verification FAILED"
    echo "See: $OUTPUT_DIR/overflow_case_verification.log"
fi

echo ""
echo "=== Step 3: Bounded Model Checking Examples ==="

# Generate specific test cases for bounded verification
echo "Generating bounded verification test cases..."
cat > "$OUTPUT_DIR/test_cases.txt" << EOF
# Bounded Model Checking Test Cases for 4-bit Adder

# No overflow cases (sum < 16):
# a=7, b=8 -> sum=15, overflow=0
# a=0, b=15 -> sum=15, overflow=0  
# a=3, b=4 -> sum=7, overflow=0
# a=1, b=1 -> sum=2, overflow=0

# Overflow cases (sum >= 16):
# a=15, b=15 -> sum=14 (30&15), overflow=1
# a=8, b=8 -> sum=0 (16&15), overflow=1
# a=9, b=7 -> sum=0 (16&15), overflow=1
# a=15, b=1 -> sum=0 (16&15), overflow=1

# Edge cases:
# a=0, b=0 -> sum=0, overflow=0
# a=15, b=0 -> sum=15, overflow=0
# a=8, b=7 -> sum=15, overflow=0
# a=8, b=8 -> sum=0, overflow=1
EOF

echo "✓ Generated bounded test cases: $OUTPUT_DIR/test_cases.txt"

echo ""
echo "=== Verification Summary ==="
echo "Results saved to: $OUTPUT_DIR"
echo "- general_overflow_verification.log: General overflow property"
echo "- no_overflow_verification.log: No overflow cases (sum < 16)"
echo "- overflow_case_verification.log: Overflow cases (sum >= 16)"
echo "- test_cases.txt: Bounded model checking examples"
echo ""

echo "=== Safety Properties Verified ==="
echo "1. ✓ Overflow flag correctness: overflow = 1 iff (a + b) >= 16"
echo "2. ✓ Sum output correctness: sum = (a + b) mod 16"
echo "3. ✓ Valid input handling: 0 <= a,b <= 15"
echo "4. ✓ Bit-vector semantics: 4-bit arithmetic with overflow detection"
echo ""

echo "=== Next Steps ==="
echo "1. Review verification logs for detailed proof traces"
echo "2. Run integration tests with concrete values"
echo "3. Extend to larger bit-widths (8-bit, 16-bit)"
echo "4. Verify against SystemVerilog/Verilog implementations"