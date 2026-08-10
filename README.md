# K-CIRCT: Towards a formal framework for CIRCT

CIRCT is built on top of the LLVM compiler infrastructure and is designed to support the development of hardware compiler transformations and analysis tools.

This project aims to provide a formal framework for CIRCT, which will allow us to formally reason about CIRCT transformations and CIRCT-based hardware designs.

K-CIRCT consists of 3 parts:

- `src/kproj`: An extensible and composable semantics of CIRCT in K as a rigorous foundation for CIRCT.
- `src/kirct`: A user-friendly interface for the formal semantics, called `kirct`, which allows users to utilize the semantics for simulation. It's also easy to extend `kirct` in Python to support more features.
- `verification/`: A comprehensive formal verification framework enabling mathematical proofs of hardware design correctness and compiler optimization equivalence using K framework claims and symbolic execution.

## Installation

### Prerequisites

- K Framework should be installed and added to the `PATH` environment variable. See [here](https://github.com/runtimeverification/k#quick-start) for installation instructions.
- CIRCT should be installed and added to the `PATH` environment variable, making `circt-opt` and `arcilator` accessible in the shell. See [here](https://github.com/llvm/circt) for installation instructions.
- `poetry` Python build tool is recommended to build the `kirct` tool. Follow the instructions [here](https://python-poetry.org/docs/#installing-with-pipx) to install `poetry`.

For testing the project, you need to install `verilator` and `iverilog` in your system.

- `verilator`: See [here](https://www.veripool.org/verilator/install/) for installation instructions.
- `iverilog`: See [here](https://github.com/steveicarus/iverilog) for installation instructions.

The recommended version for these tools are included in the Makefile. You can use the following command to check the versions:

```bash
make check-dependencies
```

If something goes wrong, you can check the dependencies of the K framework [here](https://github.com/runtimeverification/k/blob/d0d2553f1254991600a830b108d98fe9febc1f5a/install-build-deps).


### Building

To obtain `kcirct` to use the formal semantics, execute:

```
make kcirct
```

### Accessing compiled K definitions

The definitions are built with `kdist`. To build the definitions, run:

```
make circt-semantics
```

To get an exact path to the definition, use:

```
poetry run kdist which llvm # for LLVM Backend
```

Note that LLVM backend is for concrete execution, while Haskell backend is for symbolic execution and verification.

For more information about `kdist`, please use `poetry run kdist --help`.

## Usage

After building the project, you can access the `kcirct` CLI via `poetry`:

```
poetry run kcirct --help
```

Note that you need to run the following command to make `diffvcd.py` executable:

```
chmod u+x src/kcirct/lib/diffvcd.py
```

## Formal Verification Framework

K-CIRCT includes a comprehensive verification framework located in `verification/` that enables:

- **Mathematical Hardware Verification**: Prove hardware design correctness for all possible inputs
- **Compiler Transformation Verification**: Verify CIRCT optimizations preserve semantic equivalence
- **Safety Property Verification**: Prove critical safety properties like overflow detection

### Quick Start Verification

```bash
# Run all verification cases
./verification/scripts/run_all_verifications.sh

# Individual verification cases
./verification/scripts/verify_constant_folding.sh    # Compiler optimization equivalence
./verification/scripts/verify_arithmetic_safety.sh  # Hardware overflow detection
```

### Verification Cases Included

1. **Constant Folding Equivalence** - Proves compiler optimizations preserve semantics
2. **Arithmetic Safety Properties** - Verifies 4-bit overflow detection correctness

For complete documentation, see [verification/README.md](verification/README.md).

## Test

- src/tests/unit: Simple tests that do not require kompile
- src/tests/integration: Tests that require kompile. `make circt-semantics` is required.
- src/tests/profiling: Tests for profiling. `make circt-semantics` is required.

use this symbolic proof
```
poetry run kcirct verify \
  src/tests/resources/verify/assert_true/assert_true.generic.mlir \
  --top-module AssertTrue \
  --symbolic \
  --symbolic-input-widths 8 \
  --max-depth 50 \
  --max-iterations 3
```

use this concrete verify
```
poetry run kcirct verify \
  src/tests/resources/verify/assert_true/assert_true.generic.mlir \
  --top-module AssertTrue \
  --inputs 1:8 \
  --backend llvm
```

generator: generate generic mlir and adder.py (module of Adder)
model: MLIR module
context: all runtime context
vcd:
- class KimulatorVCD, manage vcd files, dump the result of simulation
- vcd.diff, comparing two vcd files.

## TODO

- [ ] scripts/mlir2kast.py: transform mlir to kast
- [ ] scripts/hardware-setup.py: setup hardware for continuous simulation
- [ ] scripts/hardware-run.py: run hardware
- [ ] scripts/hardware-sim.py: run simulation
- [ ] scripts/hardware-veri.py: run verification
- [ ] scripts/hardware-sym.py: run symbolic execution
- [ ] scripts/hardware-bench.py: run benchmark
- [ ] scripts/hardware-test.py: run test

K_OPTS+=-Xms64m -Xmx8192m -Xss32m

`pip3 install fire`
