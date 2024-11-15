import json
from pathlib import Path

DATA_PATH = Path(__file__).parent

# find all directories in DATA_PATH / 'modules'
COMB_DIRS = [dir for dir in (DATA_PATH / 'comb').iterdir() if dir.is_dir()]
COMB_TEST_IDS = [dir.name for dir in COMB_DIRS]
COMB_MLIR_FILES = [next(dir.glob('*.mlir')) for dir in COMB_DIRS]
COMB_MLIR_GNERIC_FILES = [next(dir.glob('*.generic.mlir')) for dir in COMB_DIRS]
# MODULES_EXPECTED_DIRS = [dir / 'expected' for dir in COMB_DIRS]
COMB_EXPECTED_TOP_MODULES = ['Foo' for mlir_file in COMB_MLIR_GNERIC_FILES]
COMB_INPUTS = [json.load(open(dir / 'test_data.json'))['inputs'] for dir in COMB_DIRS]

LEVEL1_DIRS = [dir for dir in (DATA_PATH).iterdir() if dir.is_dir()]

DIRS = {}
TEST_IDS = {}
MLIR_FILES = {}
MLIR_GNERIC_FILES = {}
EXPECTED_TOP_MODULES = {}
INPUTS = {}


for level1 in LEVEL1_DIRS:
    print(level1.name)
    if level1.name == '__pycache__' or level1.name == 'seq':
        continue
    name1 = level1.name
    DIRS[name1] = [dir for dir in (DATA_PATH / level1).iterdir() if dir.is_dir()]
    TEST_IDS[name1] = [dir.name for dir in DIRS[name1]]
    MLIR_FILES[name1] = [next(dir.glob('*.mlir')) for dir in DIRS[name1]]
    MLIR_GNERIC_FILES[name1] = [next(dir.glob('*.generic.mlir')) for dir in DIRS[name1]]
    EXPECTED_TOP_MODULES[name1] = ['Foo' for mlir_file in MLIR_GNERIC_FILES[name1]]
    INPUTS[name1] = [json.load(open(dir / 'test_data.json'))['inputs'] for dir in DIRS[name1]]
