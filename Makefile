POETRY     := poetry
POETRY_RUN := $(POETRY) run
FIRTOOL_VERSION := 1.71.0


default: check test-unit

all: check cov

.PHONY: clean
clean: 
	rm -rf dist .coverage cov-* .mypy_cache .pytest_cache
	find -type d -name __pycache__ -prune -exec rm -rf {} \;

.PHONY: build
build: poetry-install
	$(POETRY) build


.PHONY: poetry-install
poetry-install:
	$(POETRY) install

.PHONY: kbuild-circt
kbuild-circt: poetry-install
	$(POETRY) build
	$(POETRY_RUN) kbuild kompile llvm
	$(POETRY_RUN) kbuild kompile haskell



# Tests

TEST_ARGS :=

test: test-all

test-all: poetry-install
	$(POETRY_RUN) pytest src/tests --maxfail=1 --verbose --durations=0 --numprocesses=4 --dist=worksteal $(TEST_ARGS)

test-unit: poetry-install
	$(POETRY_RUN) pytest src/tests/unit --maxfail=1 --verbose $(TEST_ARGS)

test-integration: poetry-install
	$(POETRY_RUN) pytest src/tests/integration --maxfail=1 --verbose --durations=0 --numprocesses=4 --dist=worksteal $(TEST_ARGS)

test-regression-new: poetry-install
	$(MAKE) -C regression-new

# Coverage

COV_ARGS :=

cov: cov-all

cov-%: TEST_ARGS += --cov=pyk --no-cov-on-fail --cov-branch --cov-report=term

cov-all: TEST_ARGS += --cov-report=html:cov-all-html $(COV_ARGS)
cov-all: test-all

cov-unit: TEST_ARGS += --cov-report=html:cov-unit-html $(COV_ARGS)
cov-unit: test-unit

cov-integration: TEST_ARGS += --cov-report=html:cov-integration-html $(COV_ARGS)
cov-integration: test-integration


# Profiling

PROF_ARGS :=

profile: poetry-install
	$(POETRY_RUN) pytest src/tests/profiling --maxfail=1 --verbose --durations=0 --numprocesses=4 --dist=worksteal $(PROF_ARGS)


# Checks and formatting

format: autoflake isort black
check: check-flake8 check-mypy check-autoflake check-isort check-black

check-flake8: poetry-install
	$(POETRY_RUN) flake8 src

check-mypy: poetry-install
	$(POETRY_RUN) mypy src

autoflake: poetry-install
	$(POETRY_RUN) autoflake --quiet --in-place src

check-autoflake: poetry-install
	$(POETRY_RUN) autoflake --quiet --check src

isort: poetry-install
	$(POETRY_RUN) isort src

check-isort: poetry-install
	$(POETRY_RUN) isort --check src

check-pydocstyle:
	$(POETRY_RUN) pydocstyle --ignore=D100,D101,D102,D103,D104 src

black: poetry-install
	$(POETRY_RUN) black src

check-black: poetry-install
	$(POETRY_RUN) black --check src

# Check external dependencies
# firtool --version should be 1.71.0

check-dependencies: 
	@echo "Checking external dependencies..."
	@firtool --version | grep $(FIRTOOL_VERSION) > /dev/null && echo "firtool version is correct" || (echo "firtool version is incorrect"; exit 1)

# Optional tools

SRC_FILES := $(shell find src -type f -name '*.py')

pyupgrade: poetry-install
	sh -c '$(POETRY_RUN) pyupgrade --py310-plus $(SRC_FILES); result=$$?; \
    if [ $$result -eq 1 ]; then \
        echo "pyupgrade returned 1, but continuing..."; \
    elif [ $$result -ne 0 ]; then \
        echo "pyupgrade failed with error code $$result"; \
        exit $$result; \
    fi'

# Documentation

pr: poetry-install format check pyupgrade test
