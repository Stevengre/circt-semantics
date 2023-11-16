# K-CIRCT: Towards a formal framework for CIRCT

CIRCT is built on top of the LLVM compiler infrastructure and is designed to support the development of hardware compiler transformations and analysis tools.

This project aims to provide a formal framework for CIRCT, which will allow us to formally reason about CIRCT transformations and CIRCT-based hardware designs.

K-CIRCT consists of 2 parts:

- An extensible semantics of CIRCT in K, continuously adapting to changes in CIRCT, provides a rigorous foundation for CIRCT.
- A user-friendly interface for the formal semantics, called `kirct`, allows users to utilize the semantics for simulation, symbolic execution, and verification. It's also easy to extend `kirct` in Python to support more features.

## Installation

### Prerequisites

- K Framework should be installed and added to the `PATH` environment variable. See [here](https://github.com/runtimeverification/k#quick-start) for installation instructions.
- `poetry` Python build tool is recommended to build the `kirct` tool. Follow the instructions [here](https://python-poetry.org/docs/#installing-with-pipx) to install `poetry`.

### Building

To obtain `kirct` to use the formal semantics, execute:
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

After building the project, you can access the `kimp` CLI via `poetry`:

```
poetry run kirct --help
```

or 

```
bin/kirct --help
```

