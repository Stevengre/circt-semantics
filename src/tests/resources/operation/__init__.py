import json
from pathlib import Path

DATA_PATH = Path(__file__).parent

# find all directories in DATA_PATH / 'modules'
COMB_DIRS = [dir for dir in (DATA_PATH / 'comb').iterdir() if dir.is_dir()]
COMB_TEST_IDS = [dir.name for dir in COMB_DIRS]
COMB_MLIR_FILES = [next(dir.glob('*.mlir')) for dir in COMB_DIRS]
COMB_MLIR_GNERIC_FILES = [next(dir.glob('*.generic.mlir')) for dir in COMB_DIRS]
# MODULES_EXPECTED_DIRS = [dir / 'expected' for dir in COMB_DIRS]
MODULES_EXPECTED_TOP_MODULES = [mlir_file.stem.capitalize() for mlir_file in COMB_MLIR_GNERIC_FILES]
MODULES_INPUTS = [json.load(open(dir / 'test_data.json'))['inputs'] for dir in COMB_DIRS]
