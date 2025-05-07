import subprocess
from pathlib import Path

from __init__ import DIALECT_OPERATIONS

DATA_PATH = Path(__file__).parent

if __name__ == "__main__":
    for dialect, operations in DIALECT_OPERATIONS.items():
        for operation in operations:
            mlir_path = f'{dialect}/{operation}/{operation}.mlir'
            result = subprocess.run(['make', 'buildVcd', f'FILE_MLIR={mlir_path}'])
