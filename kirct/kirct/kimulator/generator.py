from pathlib import Path


class Generator:
    source: Path
    output: Path
    temp_dir: Path

    def __init__(self, source: Path, output: Path, temp_dir: Path):
        self.source = source
        self.output = output
        self.temp_dir = temp_dir


