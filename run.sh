#!/usr/bin/bash
set -x
krun a.mlir -cEntry='"Foo"' -cInput="$(cat input.txt)" -d main-llvm