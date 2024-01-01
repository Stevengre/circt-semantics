from pathlib import Path
from .context import Signal, Abbrev
import subprocess
from pyk.utils import ensure_dir_path
import json, copy


# todo: improve efficiency
# todo: support multiple modules
# inputs: generic_mlir_path, signals, model_name, module_name
HEADER_TEMPLATE = """from pathlib import Path
from kirct.kimulator.model import KimulatorModel, KimulatorContext, Signal

generic_mlir_path: str = '{generic_mlir_path}'

{signals}

kimulator_context: KimulatorContext = KimulatorContext()
kimulator_context.trace_ever_on(True)
{context_signals}

{models}
"""

# inputs: sid, name, mlir_gen_name, spaces=len(sid) , is_input, signal_type
SIGNAL_TEMPLATE = """{sid} = Signal(name='{name}',
          {spaces}abbrev="{abbrev}",
          {spaces}mlir_gen_name='{mlir_gen_name}',
          {spaces}is_input={is_input},
          {spaces}num_bits={num_bits},
          {spaces}signal_type='{signal_type}',
          {spaces}signal_value=0)
"""

# inputs: mlir_gen_name, sid
CONTEXT_SIGNAL_TEMPLATE = """kimulator_context.signals['{mlir_gen_name}'] = {sid}\n"""

# inputs: model_name, module_name, spaces=' ' * len(model_name), model_signals, model_children
MODEL_TEMPLATE = """{model_name}: KimulatorModel = KimulatorModel(module_name='{module_name}',
                                  {spaces}source_file=generic_mlir_path,
                                  {spaces}signals={{{model_signals}}},
                                  {spaces}children={{{model_children}}},
                                  {spaces}context=kimulator_context)
"""

# inputs: name, sid
MODEL_SIGNAL_TEMPLATE = """'{name}': {sid},
{spaces}"""

# inputs: instance_name
MODEL_CHILD_TEMPLATE = """'{name}': {model},
{spaces}"""


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
        # Step1. Generate state.json & *.generic.mlir
        self.generate_json()
        self.generate_generic()
        # Step2. Extract signals from state.json
        signals = {}
        top_module_name = ''
        with open(self._state_json_path, 'r') as f:
            state = json.load(f)
            # todo: Now, we just saw one module in state.json. If there is some uncovered situation, we need to
            #  handle it.
            for module in state:
                top_module_name = str(module['name'])
                for s in module['states']:
                    if str(s['name']) not in signals.keys():
                        signals[str(s['name'])] = Signal(
                            name=str(s['name']).split('/')[-1],
                            abbrev=Abbrev.gen().replace("'", "\\'") if "'" in Abbrev.gen() else Abbrev.gen(),
                            mlir_gen_name=str(s['name']),
                            is_input=(str(s['type']) == 'input'),
                            num_bits=int(s['numBits']),
                            signal_type=str(s['type']),
                            signal_value=0
                        )
                    else:
                        if str(s['type']) == 'input' or str(s['type']) == 'output':
                            signals[str(s['name'])].is_input = (str(s['type']) == 'input')
                        else:
                            signals[str(s['name'])].signal_type = str(s['type'])
        # Step3. Generate Python simulation header
        str_generic_mlir_path = str(self._generic_mlir_path)
        str_signals = ""
        str_context_signals = ""
        str_models = []
        model_signals = {}
        model_children = {top_module_name.lower() + "_model": []}
        model_names = []
        model_names_map_instance = {}
        for signal in signals.values():
            sid = signal.mlir_gen_name.replace('/', '_') + "_signal"
            nested = signal.mlir_gen_name.split('/')
            if len(nested) == 1:
                model_name = top_module_name.lower() + "_model"
                model_names_map_instance[model_name] = top_module_name.lower()
            elif len(nested) > 1:
                model_name = '_'.join([s.lower() for s in nested[:-1]]) + "_model"
                model_names_map_instance[model_name] = nested[-2].lower()
            else:
                raise Exception("Unexpected signal name")
            str_signals += SIGNAL_TEMPLATE.format(
                sid=sid,
                mlir_gen_name=signal.mlir_gen_name,
                name=signal.name,
                abbrev=signal.abbrev,
                spaces=' ' * len(sid),
                is_input=signal.is_input,
                num_bits=signal.num_bits,
                signal_type=signal.signal_type
            )
            str_context_signals += CONTEXT_SIGNAL_TEMPLATE.format(
                mlir_gen_name=signal.mlir_gen_name,
                sid=sid
            )
            if model_signals.get(model_name) is None:
                model_signals[model_name] = [{'name': signal.name, 'sid': sid}]
                if model_name not in model_names:
                    model_names.append(model_name)
            else:
                model_signals[model_name].append({'name': signal.name, 'sid': sid})
            if len(nested) > 1:
                i = 0
                father_name = top_module_name.lower() + "_model"
                child_name = '_'.join([s.lower() for s in nested[0:(i + 1)]]) + "_model"
                while i < len(nested) - 1:
                    if model_children.get(father_name) is None:
                        model_children[father_name] = [child_name]
                    elif child_name not in model_children[father_name]:
                        model_children[father_name].append(child_name)
                    i += 1
                    father_name = child_name
                    child_name = '_'.join([s.lower() for s in nested[0:(i + 1)]]) + "_model"

        fathers = [top_module_name.lower() + "_model"]
        model_children_backup = copy.deepcopy(model_children)
        while model_names:
            model_name = fathers[-1]
            module_name = model_name.split('_')[-2]
            if top_module_name.lower() + "_model" == model_name:
                module_name = top_module_name
            if model_children.get(model_name) is None or model_children[model_name] == []:
                str_models.append(MODEL_TEMPLATE.format(
                    model_name=model_name,
                    module_name=module_name,
                    spaces=' ' * len(model_name),
                    model_signals="".join([MODEL_SIGNAL_TEMPLATE.format(
                        name=s['name'],
                        sid=s['sid'],
                        spaces=' ' * (43 + len(model_name))
                    ) for s in model_signals.get(model_name, [])]),
                    model_children="".join([MODEL_CHILD_TEMPLATE.format(
                        name=model_names_map_instance[child],
                        model=child,
                        spaces=' ' * (44 + len(model_name))
                    ) for child in model_children_backup.get(model_name, [])])
                ))
                # delete all this child in model_children
                for child in model_children.values():
                    if model_name in child:
                        child.remove(model_name)
                if model_name in model_names:
                    model_names.remove(model_name)
                fathers.pop()
            else:
                fathers.append(model_children[model_name][-1])

        module_output = HEADER_TEMPLATE.format(
            generic_mlir_path=str_generic_mlir_path,
            signals=str_signals,
            context_signals=str_context_signals,
            models="".join(str_models)
        )
        with open(self._header_path, 'w') as f:
            f.write(module_output)

    def generate_json(self) -> subprocess.CompletedProcess:
        """Generate state JSON from MLIR"""
        args = ["arcilator", 
                str(self.source), 
                "--state-file=" 
                + str(self._state_json_path),
                "--observe-ports"]
        return subprocess.run(args, stdout=subprocess.PIPE)

    def generate_generic(self) -> subprocess.CompletedProcess:
        """Generate generic MLIR from MLIR"""
        args = ["circt-opt",
                "--mlir-print-op-generic",
                str(self.source),
                "-o",
                str(self._generic_mlir_path)]
        return subprocess.run(args, stdout=subprocess.PIPE)


