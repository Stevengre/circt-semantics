#!/bin/bash

# K-CIRCT Constant Folding Verification Script
# Verifies that constant folding optimization preserves semantic equivalence

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$VERIFICATION_DIR")"

echo "=== K-CIRCT Constant Folding Verification ==="
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

# Check if MLIR files exist
ORIGINAL_MLIR="$VERIFICATION_DIR/cases/constant_folding_original.mlir"
OPTIMIZED_MLIR="$VERIFICATION_DIR/cases/constant_folding_optimized.mlir"
SPEC_FILE="$VERIFICATION_DIR/specs/constant_folding_spec.k"

if [[ ! -f "$ORIGINAL_MLIR" ]]; then
    echo "Error: Original MLIR file not found: $ORIGINAL_MLIR"
    exit 1
fi

if [[ ! -f "$OPTIMIZED_MLIR" ]]; then
    echo "Error: Optimized MLIR file not found: $OPTIMIZED_MLIR"
    exit 1
fi

if [[ ! -f "$SPEC_FILE" ]]; then
    echo "Error: Specification file not found: $SPEC_FILE"
    exit 1
fi

echo "Found all required files:"
echo "  Original MLIR: $ORIGINAL_MLIR"
echo "  Optimized MLIR: $OPTIMIZED_MLIR"
echo "  Specification: $SPEC_FILE"
echo ""

# Create output directory for verification results
OUTPUT_DIR="$VERIFICATION_DIR/results/constant_folding"
mkdir -p "$OUTPUT_DIR"

echo "=== Step 1: Kompiling K Specification ==="
cd "$PROJECT_ROOT"

# Compile the K specification
echo "Compiling constant folding specification..."
kompile -v "$SPEC_FILE" --syntax-module CONSTANT-FOLDING-SYNTAX --main-module CONSTANT-FOLDING-SPEC -o "$OUTPUT_DIR/constant-folding-kompiled"

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to compile K specification"
    exit 1
fi

echo "✓ K specification compiled successfully"
echo ""

echo "=== Step 2: Running Verification Claims ==="

# Verify original module produces expected result (8)
echo "Verifying original module correctness..."
kprove "$SPEC_FILE" --definition "$OUTPUT_DIR/constant-folding-kompiled" \
    --spec-module CONSTANT-FOLDING-SPEC \
    --claim "ConstantFoldingOriginal-claim-1" \
    --output-file "$OUTPUT_DIR/original_verification.log" \
    --verbose

if [[ $? -eq 0 ]]; then
    echo "✓ Original module verification PASSED"
else
    echo "✗ Original module verification FAILED"
    echo "See: $OUTPUT_DIR/original_verification.log"
fi

# Verify optimized module produces expected result (8)  
echo "Verifying optimized module correctness..."
kprove "$SPEC_FILE" --definition "$OUTPUT_DIR/constant-folding-kompiled" \
    --spec-module CONSTANT-FOLDING-SPEC \
    --claim "ConstantFoldingOptimized-claim-1" \
    --output-file "$OUTPUT_DIR/optimized_verification.log" \
    --verbose

if [[ $? -eq 0 ]]; then
    echo "✓ Optimized module verification PASSED"
else
    echo "✗ Optimized module verification FAILED"
    echo "See: $OUTPUT_DIR/optimized_verification.log"
fi

# Verify equivalence between original and optimized
echo "Verifying equivalence between original and optimized versions..."
kprove "$SPEC_FILE" --definition "$OUTPUT_DIR/constant-folding-kompiled" \
    --spec-module CONSTANT-FOLDING-SPEC \
    --claim "equivalence-claim" \
    --output-file "$OUTPUT_DIR/equivalence_verification.log" \
    --verbose

if [[ $? -eq 0 ]]; then
    echo "✓ Equivalence verification PASSED"
    echo ""
    echo "🎉 CONSTANT FOLDING VERIFICATION SUCCESSFUL!"
    echo "   Both the original (5 + 3) and optimized (8) versions produce identical results."
else
    echo "✗ Equivalence verification FAILED"
    echo "See: $OUTPUT_DIR/equivalence_verification.log"
fi

echo ""
echo "=== Verification Summary ==="
echo "Results saved to: $OUTPUT_DIR"
echo "- original_verification.log: Original module verification"
echo "- optimized_verification.log: Optimized module verification"  
echo "- equivalence_verification.log: Equivalence proof"
echo ""

echo "=== Next Steps ==="
echo "1. Review verification logs for detailed proof traces"
echo "2. Run arithmetic safety verification: ./verify_arithmetic_safety.sh"
echo "3. Check verification coverage with: ./check_coverage.sh"