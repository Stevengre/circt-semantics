#!/bin/sh
exec kore-exec \
    vdefinition.kore \
    --output result.kore \
    --module MAIN \
    --strategy all \
    --max-counterexamples 1 \
    --smt-timeout 125 \
    --smt-retry-limit 3 \
    --smt-reset-interval 100 \
    --smt z3 \
    --log-level \
    warning \
    --enable-log-timestamps \
    --prove spec.kore \
    --spec-module SPEC-MLIR \
    --graph-search breadth-first \
     \
     \
     \
     \
     \
     \
    "$@"
