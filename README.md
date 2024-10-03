# K-CIRCT: Towards a formal framework for CIRCT

CIRCT is built on top of the LLVM compiler infrastructure and is designed to support the development of hardware compiler transformations and analysis tools.

This project aims to provide a formal framework for CIRCT, which will allow us to formally reason about CIRCT transformations and CIRCT-based hardware designs.

K-CIRCT consists of 2 parts:

- `src/kproj`: An extensible and composable semantics of CIRCT in K as a rigorous foundation for CIRCT.
- `src/kirct`: A user-friendly interface for the formal semantics, called `kirct`, which allows users to utilize the semantics for simulation. It's also easy to extend `kirct` in Python to support more features. And we will support symbolic execution and verification in the future.

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

## Test

- src/tests/unit: Simple tests that do not require kompile
- src/tests/integration: Tests that require kompile. `make circt-semantics` is required.
- src/tests/profiling: Tests for profiling. `make circt-semantics` is required.

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
