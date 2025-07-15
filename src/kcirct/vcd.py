from __future__ import annotations

import json
import re
import subprocess
from dataclasses import dataclass
from functools import cached_property
from typing import TYPE_CHECKING, TextIO

if TYPE_CHECKING:
    from pathlib import Path


@dataclass
class Signal:
    name: str
    abbrev: str
    num_bits: int
    type: str


@dataclass
class Module:
    name: str
    signals: list[Signal]
    children: list[Module]


class Abbrev:
    _rest: int = 0

    @classmethod
    def gen(cls) -> str:
        cls._rest += 1
        t: int = cls._rest
        abbrev = ''
        while t != 0:
            c = (t % 84) + 33
            if c >= ord('0'):
                c += 10
            abbrev += chr(int(c))
            t //= 84
        return abbrev


class KVCD:
    __vcd_file: TextIO
    _mlir_path: Path
    _state_json_path: Path | None
    abbrevs: dict[str, str]
    time: int
    time_scale: str
    filename: str
    memory_dump: bool
    firmem: dict[str, list[int]]  # name -> (data_size, addr)

    def __init__(
        self,
        vcd_path: Path,
        mlir_path: Path,
        state_json_path: Path | None = None,
        time_scale: str = '1s',
        memory_dump: bool = False,
    ):
        self.__vcd_file = open(vcd_path, 'w')
        self.memory_dump = memory_dump
        self._mlir_path = mlir_path
        self._state_json_path = state_json_path
        if self._state_json_path is None:
            self._state_json_path = mlir_path.parent / 'state.json'
            self.generate_json()
        self.time = 0
        self.time_scale = time_scale
        self.abbrevs = {}
        self.firmem = {}
        self._init()
        return

    def __del__(self) -> None:
        if self.__vcd_file:
            self.__vcd_file.close()
        return

    def generate_json(self) -> subprocess.CompletedProcess:
        """Generate state JSON from MLIR"""
        args = ['arcilator', str(self._mlir_path), '--state-file=' + str(self._state_json_path), '--observe-ports']
        return subprocess.run(args, stdout=subprocess.PIPE)

    @cached_property
    def modules(self) -> tuple[Module, dict[str, Module]]:
        modules: dict[str, Module] = {}

        def _add_to_module(signal: Signal, modules: dict[str, Module]) -> None:
            module_hierarchy = signal.name.split('/')[:-1]
            prev_module: Module | None = None
            idx = 0
            while idx < len(module_hierarchy):
                module_name = '/'.join(module_hierarchy[: idx + 1])
                if module_name not in modules:
                    modules[module_name] = Module(module_name, [], [])
                if prev_module and modules[module_name] not in prev_module.children:
                    prev_module.children.append(modules[module_name])
                prev_module = modules[module_name]
                idx += 1

            if prev_module is None:
                raise RuntimeError('Unexpected None module')
            prev_module.signals.append(signal)

        assert self._state_json_path is not None
        with open(self._state_json_path, 'r') as f:
            state_json = json.load(f)
        assert len(state_json) == 1, 'state.json should only have one module'
        module = state_json[0]
        top_module_name = module['name']
        states = module['states']

        for state in states:
            signal_name = f"{top_module_name}/{state['name']}"
            signal_abbrev = Abbrev.gen()
            self.abbrevs[signal_name] = signal_abbrev
            signal = Signal(
                name=signal_name,
                abbrev=signal_abbrev,
                num_bits=state['numBits'],
                type=state['type'],
            )
            _add_to_module(signal, modules)
            # 暂且规定firmem的module名字规则为***_ext
            if self.memory_dump:
                module_names = signal_name.rsplit('/', 2)
                if len(module_names) > 1 and module_names[1].endswith('_ext'):
                    firmem_name = signal_name.rsplit('/', 1)[0]
                    if firmem_name not in self.firmem:
                        self.firmem[firmem_name] = [-1, -1]
                    if module_names[2].endswith('addr'):
                        self.firmem[firmem_name][1] = 2**signal.num_bits
                    elif module_names[2].endswith('data'):
                        self.firmem[firmem_name][0] = signal.num_bits
        if self.memory_dump:
            for firmem_name, (databits, addr) in self.firmem.items():
                for i in range(addr):
                    signal_name = f'{firmem_name}/Memory[{i}]'
                    signal_abbrev = Abbrev.gen()
                    self.abbrevs[signal_name] = signal_abbrev
                    signal = Signal(
                        name=signal_name,
                        abbrev=signal_abbrev,
                        num_bits=databits,
                        type='wire',
                    )
                    _add_to_module(signal, modules)

        return modules[top_module_name], modules

    def _write_line(self, s: str, indent: int = 0) -> None:
        self.__vcd_file.write(f'{" " * indent}{s}\n')

    def _init(self) -> None:
        # write header
        self._write_line('$version Generated by KCIRCT $end')
        self._write_line(f'$timescale {self.time_scale} $end')

        # write top module header and input/output signals
        self._write_line(f'$scope module {self.modules[0].name} $end', 1)  # type: ignore
        for signal in self.modules[0].signals:
            if signal.type == 'input' or signal.type == 'output':
                s = f'$var wire {signal.num_bits} {self.abbrevs[signal.name]} {signal.name.split("/")[-1]}'
                if signal.num_bits > 1:
                    s += f' [{signal.num_bits - 1}:0]'
                s += ' $end'
                self._write_line(s, 2)

        # write all the modules
        def _write_signal(signal: Signal, indent: int) -> None:
            s = '$var '
            if signal.type == 'wire':
                s += 'wire '
            elif signal.type == 'register':
                s += 'reg '
            elif signal.type == 'input' or signal.type == 'output':
                return
            else:
                print(f'unsupported signal type: {signal.type}')
                print(signal)
                return

            s += f'{signal.num_bits} {self.abbrevs[signal.name]} {signal.name.split("/")[-1]}'
            if signal.num_bits > 1:
                s += f' [{signal.num_bits - 1}:0]'
            s += ' $end'
            self._write_line(s, indent)

        def _write_modules(module: Module, indent: int) -> None:
            self._write_line(f'$scope module {module.name.split("/")[-1]} $end', indent)
            for signal in module.signals:
                _write_signal(signal, indent + 1)
            for child in module.children:
                _write_modules(child, indent + 1)
            self._write_line('$upscope $end', indent)

        _write_modules(self.modules[0], 2)
        # write top module end
        self._write_line('$upscope $end', 1)
        self._write_line('$enddefinitions $end')

    def write_values(self, ports: dict[str, tuple[int, int]]) -> None:
        for signal_name, signal_values in ports.items():
            memory_check_name = signal_name.rsplit('/', 1)[1]
            pattern = r'Memory\[\d+\]$'
            if bool(re.search(pattern, memory_check_name)) and (not self.memory_dump):
                continue
            if signal_values[1] == 1:
                self.__vcd_file.write(f'{signal_values[0]}{self.abbrevs[signal_name]}\n')
            else:
                self.__vcd_file.write(
                    f"b{format(signal_values[0], '0{}b'.format(signal_values[1]))} {self.abbrevs[signal_name]}\n"
                )

    def dump(self, ports: dict[str, tuple[int, int]]) -> None:
        self.__vcd_file.write(f'\n#{self.time}\n')
        self.write_values(ports)
        return

    # def dump(self, t: int) -> None:
    #     def write_values(signals: Iterable[Signal], vcd_f: TextIO) -> None:
    #         for signal in signals:
    #             if signal.num_bits == 1:
    #                 vcd_f.write(f'{signal.signal_value}{signal.abbrev}\n')
    #             else:
    #                 vcd_f.write(f"b{format(signal.signal_value, '0{}b'.format(signal.num_bits))} {signal.abbrev}\n")

    #     self.__vcd_file.write(f'\n#{t}\n')  # type: ignore
    #     if t == self.top.context.sim_time:  # type: ignore
    #         write_values(_changed_signal, self.__vcd_file)  # type: ignore
    #         _changed_signal.clear()
    #     else:
    #         write_values(_changed_signal_history[t], self.__vcd_file)  # type: ignore
    #         _changed_signal_history[t].clear()
    #     return

    def close(self) -> None:
        self.__vcd_file.close()  # type: ignore
        return
