from pathlib import Path

DATA_PATH = Path(__file__).parent

# find all directories in DATA_PATH / 'modules'
MODULES_DIRS = [dir for dir in (DATA_PATH / 'modules').iterdir() if dir.is_dir()]
MODULES_TEST_IDS = [dir.name for dir in MODULES_DIRS]
MODULES_MLIR_FILES = [next(dir.glob('*.mlir')) for dir in MODULES_DIRS]
MODULES_EXPECTED_DIRS = [dir / 'expected' for dir in MODULES_DIRS]
MODULES_EXPECTED_GENERIC_MLIR_FILES = [next(dir.glob('*.generic.mlir')) for dir in MODULES_EXPECTED_DIRS]
