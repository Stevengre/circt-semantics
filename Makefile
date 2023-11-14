all: poetry


# Building
# --------

PYTHON_BIN   := python3.12
KIRCT_DIR    := ./kirct
POETRY       := poetry -C $(KIRCT_DIR)
POETRY_RUN   := $(POETRY) run --


.PHONY: poetry-env
poetry-env:
	$(POETRY) env use $(PYTHON_BIN)

poetry: poetry-env
	$(POETRY) install

shell: poetry
	$(POETRY) shell

build: poetry-env
	$(MAKE) -C $(KIRCT_DIR) build

clean: poetry-env
	$(MAKE) -C $(KIRCT_DIR) clean

# Tests
# -----
## ref to https://github.com/runtimeverification/evm-semantics/blob/master/Makefile

# Example Tests

# Conformance Tests

# Proof Tests

# Integration Tests

# Smoke Tests

# Interactive Tests