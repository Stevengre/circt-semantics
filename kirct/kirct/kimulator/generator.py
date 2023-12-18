from pathlib import Path
import subprocess
from pyk.utils import ensure_dir_path
import json


# todo: improve efficiency
# todo: support multiple modules
# inputs: generic_mlir_path, signals, model_name, module_name
HEADER_TEMPLATE = """
from pathlib import Path
from kirct.kimulator.model import KimulatorModel, KimulatorContext, Signal

generic_mlir_path: str = '{generic_mlir_path}'
kimulator_context: KimulatorContext = KimulatorContext()
kimulator_context.trace_ever_on(True)

kimulator_context.signals = {{
{signals}}}

{model_name}: KimulatorModel = KimulatorModel(module_name='{module_name}', source_file=generic_mlir_path, signals={{}}, context=kimulator_context)

for signal in kimulator_context.signals.values():
    {model_name}.signals[signal.name] = signal
"""

# inputs: mlir_gen_name, spaces=len(mlir_gen_name), name, is_input, signal_type
SIGNAL_TEMPLATE = """    '{mlir_gen_name}': Signal(name='{name}',
               {spaces}abbrev=kimulator_context.gen_abbrev(),
               {spaces}mlir_gen_name='{mlir_gen_name}',
               {spaces}is_input={is_input},
               {spaces}num_bits={num_bits},
               {spaces}signal_type='{signal_type}',
               {spaces}signal_value=0),
"""


class Generator:
    source: Path
    output_dir: Path | None
    temp_dir: Path | None
    _generic_mlir_path: Path
    _state_json_path: Path
    _header_path: Path

    def __init__(self, source: Path, *, output_dir: Path = None, temp_dir: Path = None):
        self.source = source
        if output_dir is None:
            output_dir = source.parent.joinpath(self.source.stem)
        if temp_dir is None:
            temp_dir = source.parent.joinpath(self.source.stem)
        ensure_dir_path(output_dir)
        ensure_dir_path(temp_dir)
        self.output_dir = output_dir
        self.temp_dir = temp_dir
        self._generic_mlir_path = self.output_dir.joinpath(self.source.stem + ".generic.mlir")
        self._state_json_path = self.temp_dir.joinpath("state.json")
        self._header_path = self.output_dir.joinpath(self.source.stem.lower() +".py")

    def generate(self):
        """Generate generic MLIR and Python simulation header from MLIR"""
        self.generate_json()
        self.generate_generic()
        module_output = ""
        with open(self._state_json_path, 'r') as f:
            state = json.load(f)
            for module in state:
                module_name = str(module['name'])
                model_name = module_name.lower() + "_model"
                print()
                signals = ""
                for s in module['states']:
                    signals += SIGNAL_TEMPLATE.format(
                        mlir_gen_name=str(s['name']),
                        name=str(s['name']).split('/')[-1],
                        spaces=' ' * len(str(s['name'])),
                        is_input=str(str(s['type']) != 'output'),
                        num_bits=str(s['numBits']),
                        signal_type=str(s['type'])
                    )
                print()
                module_output += HEADER_TEMPLATE.format(
                    generic_mlir_path=str(self._generic_mlir_path),
                    signals=signals,
                    model_name=model_name,
                    module_name=module_name
                )
        with open(self._header_path, 'w') as f:
            f.write(module_output)

    def generate_json(self) -> subprocess.CompletedProcess:
        """Generate state JSON from MLIR"""
        args = ["arcilator", 
                str(self.source), 
                "--state-file=" 
                + str(self._state_json_path)]
        return subprocess.run(args, stdout=subprocess.PIPE)

    def generate_generic(self) -> subprocess.CompletedProcess:
        """Generate generic MLIR from MLIR"""
        args = ["circt-opt",
                "--mlir-print-op-generic",
                str(self.source),
                "-o",
                str(self._generic_mlir_path)]
        return subprocess.run(args, stdout=subprocess.PIPE)


