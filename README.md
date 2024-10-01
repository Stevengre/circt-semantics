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


### Building

To obtain `kcirct` to use the formal semantics, execute:
```
make build
```

### Accessing compiled K definitions

The definitions are built with `kbuild`, which places the compiled definitions in `~/.kbuild`. To get an exact path to the definition, use:
```
poetry run kbuild which llvm # for LLVM
poetry run kbuild which haskell # for Haskell
```

Note that LLVM backend is for concrete execution, while Haskell backend is for symbolic execution and verification.

## Usage

After building the project, you can access the `kcirct` CLI via `poetry`:

```
poetry run kcirct --help
```

## Test
generator: generate generic mlir and adder.py (module of Adder)
model: MLIR module
context: all runtime context
vcd:
- class KimulatorVCD, manage vcd files, dump the result of simulation
- vcd.diff, comparing two vcd files.
