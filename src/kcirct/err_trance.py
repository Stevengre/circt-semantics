import json
import logging
import sys
from collections import deque
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Union

import pyk.kore.syntax
from pyk.kore.parser import KoreParser

from .api import KCIRCT

sys.setrecursionlimit(1000000)


@dataclass
class PathEdge:
    to: str
    attr: str
    edge_id: int
    # Source, Compare {specific relationship type} left/right {id}, Possible source, Condition, Update,
    # Possible write update, Read source, Read address, Possible read source, Write address, Possible write update

    def to_dict(self) -> dict:
        return asdict(self)  # 使用 dataclass 的 asdict 自动转换

    @classmethod
    def from_dict(cls, data: dict) -> 'PathEdge':
        return cls(**data)  # 直接通过字典构造对象


class PathNode:
    edges_in: list[int]
    edges_out: list[int]
    egde_id: int
    name: str
    depth: int
    is_firmem: bool
    is_firreg: bool
    is_constant: bool

    def __init__(self, name: str):
        self.edges_in = []
        self.edges_out = []
        self.edge_id = 0
        self.name = name
        self.depth = 0
        self.is_firmem = False
        self.is_firreg = False
        self.is_constant = False

    def to_dict(self) -> dict:
        return {
            "edges_in": self.edges_in,
            "edges_out": self.edges_out,
            "edge_id": self.edge_id,
            "name": self.name,
            "depth": self.depth,
            "is_firmem": self.is_firmem,
            "is_firreg": self.is_firreg,
            "is_constant": self.is_constant,
        }

    @classmethod
    def from_dict(cls, data: dict) -> 'PathNode':
        node = cls(data["name"])
        node.edges_in = data["edges_in"]
        node.edges_out = data["edges_out"]
        node.edge_id = data["edge_id"]
        node.depth = data["depth"]
        node.is_firmem = data["is_firmem"]
        node.is_firreg = data["is_firreg"]
        node.is_constant = data["is_constant"]
        return node


class KErrTrance:
    node_map: dict[str, PathNode] = {}
    edge_map: list[PathEdge] = []
    logger: logging.Logger
    differenes: list[str] = []
    signal_port_mapping: dict[str, str] = {}

    def __init__(self) -> None:
        self.logger = logging.getLogger('test_koreparser')
        self.logger.propagate = False
        self.logger.setLevel(logging.INFO)
        file_handler = logging.FileHandler('txt.log', mode='w')
        file_handler.setFormatter(logging.Formatter('%(levelname)s - %(message)s'))
        self.logger.addHandler(file_handler)

    def set_signal_port_mapping(self, sate_file: Path) -> None:
        par: dict[str, str] = KCIRCT.read_signal_port_mapping(sate_file)
        self.signal_port_mapping = {v: k for k, v in par.items()}

    @staticmethod
    def print_pattern_info(pattern) -> None:  # type: ignore
        # 根据模式类型打印特定信息
        print(f"Type: {type(pattern).__name__}")
        if hasattr(pattern, 'name'):
            print(f"Name: {pattern.name}")
        if hasattr(pattern, 'symbol'):
            print(f"Symbol: {pattern.symbol}")
        if hasattr(pattern, 'sort'):
            print(f"Sort: {pattern.sort}")
        if hasattr(pattern, 'value'):
            print(f"Value: {pattern.value}")
        if hasattr(pattern, 'left') and hasattr(pattern, 'right'):
            print("Binary pattern with left and right children")
        if hasattr(pattern, 'var') and hasattr(pattern, 'pattern'):
            print("Quantifier pattern with variable and body")
        if hasattr(pattern, 'op_sort'):
            print(f"peration sort: {pattern.op_sort}")

    # 定义遍历函数
    def traverse(self, pattern, depth=0) -> None:  # type: ignore
        indent = "  " * depth
        print(f"{indent}Type: {type(pattern).__name__}")

        # 根据模式类型打印特定信息
        if hasattr(pattern, 'name'):
            print(f"{indent}Name: {pattern.name}")
        if hasattr(pattern, 'symbol'):
            print(f"{indent}Symbol: {pattern.symbol}")
        if hasattr(pattern, 'sort'):
            print(f"{indent}Sort: {pattern.sort}")
        if hasattr(pattern, 'value'):
            print(f"{indent}Value: {pattern.value}")
        if hasattr(pattern, 'left') and hasattr(pattern, 'right'):
            print(f"{indent}Binary pattern with left and right children")
        if hasattr(pattern, 'var') and hasattr(pattern, 'pattern'):
            print(f"{indent}Quantifier pattern with variable and body")
        if hasattr(pattern, 'op_sort'):
            print(f"{indent}Operation sort: {pattern.op_sort}")

        # 递归遍历子模式
        for i, subpattern in enumerate(pattern.patterns):
            print(f"{indent}Child {i}:")
            self.traverse(subpattern, depth + 1)

    @staticmethod
    def find_with_symbol_name(
        pattern: Any, symbol_name: str  # type: ignore
    ) -> Union[pyk.kore.syntax.DV, pyk.kore.syntax.App, pyk.kore.syntax.LeftAssoc]:
        for _, subpattern in enumerate(pattern.patterns):
            if subpattern.symbol == symbol_name:
                return subpattern
        assert 0

    def build_edge(self, to: str, st: str, attr: str) -> None:
        self.node_map[to].depth = -1
        if st not in self.node_map:
            self.node_map[st] = PathNode(st)
        self.edge_map.append(PathEdge(to=st, attr=attr, edge_id=self.node_map[to].edge_id))
        self.node_map[to].edges_in.append(len(self.edge_map) - 1)
        self.edge_map.append(PathEdge(to=to, attr=attr, edge_id=self.node_map[to].edge_id))
        self.node_map[st].edges_out.append(len(self.edge_map) - 1)

    def build_op_edge(self, to: str, list_partten: pyk.kore.syntax.Pattern, op_name: str) -> None:
        for _, subpattern in enumerate(list_partten.patterns):
            _item_pattern = subpattern.patterns[0].patterns[0]
            assert isinstance(_item_pattern, pyk.kore.syntax.DV)
            st = str(_item_pattern.value.value)
            self.build_edge(to=to, st=st, attr=op_name)
        self.node_map[to].edge_id += 1

    def build_firmem_write_edge(self, list_partten: pyk.kore.syntax.Pattern, op_name: str) -> None:
        _target_parttern = list_partten.patterns[0].patterns[0].patterns[0]
        assert isinstance(_target_parttern, pyk.kore.syntax.DV)
        _target_name = str(_target_parttern.value.value)
        if _target_name not in self.node_map.keys():
            self.node_map[_target_name] = PathNode(_target_name)
        for i, item_parttern in enumerate(list_partten.patterns):
            if i == 0:
                continue
            _st_parttern = item_parttern.patterns[0].patterns[0]
            assert isinstance(_st_parttern, pyk.kore.syntax.DV)
            _st_name = str(_st_parttern.value.value)
            self.build_edge(_target_name, _st_name, op_name)
        self.node_map[_target_name].edge_id += 1

    def build_conncetion_path(self, root) -> None:  # type: ignore
        for i, subpattern in enumerate(root.patterns):
            self.logger.info(f"Child {i}:")
            assert subpattern.symbol == "Lbl'UndsPipe'-'-GT-Unds'"
            _inj_pattern = subpattern.patterns[0]
            assert _inj_pattern.symbol == 'inj'
            op_target_parttern = _inj_pattern.patterns[0]

            assert isinstance(op_target_parttern, pyk.kore.syntax.DV)
            self.logger.info(str(op_target_parttern.value.value))
            op_target_name = str(op_target_parttern.value.value)
            self.logger.info(f"op_target_name:{op_target_name}")
            if op_target_name not in self.node_map:
                self.node_map[op_target_name] = PathNode(op_target_name)

            _inj_pattern = subpattern.patterns[1]
            _rhs_pattern = _inj_pattern.patterns[0]
            if isinstance(_rhs_pattern, pyk.kore.syntax.DV):
                self.logger.info("direct: " + str(_rhs_pattern.value.value))
                self.build_edge(op_target_name, _rhs_pattern.value.value, "direct")
                self.node_map[op_target_name].edge_id += 1
            else:
                assert _rhs_pattern.symbol == (
                    "Lbl'UndsLParUndsRParLBraUndsRBraColnUndsUnds"
                    "'MLIR-HELPER-SYNTAX'Unds'StdOp'Unds'String'Unds'List'Unds'Map'Unds'StdFT"
                )
                _op_name_pattern = _rhs_pattern.patterns[0]
                assert isinstance(_op_name_pattern, pyk.kore.syntax.DV)
                op_name = str(_op_name_pattern.value.value)
                self.logger.info("op name: " + op_name)
                if op_name in ['hw.constant', 'hw.aggregate_constant']:
                    self.node_map[op_target_name].is_constant = True
                    continue
                if op_name == "seq.firmem":
                    self.node_map[op_target_name].is_firmem = True
                    continue
                if op_name == "seq.firreg":
                    self.node_map[op_target_name].is_firreg = True

                _list_parttern = _rhs_pattern.patterns[1]
                assert isinstance(_list_parttern, pyk.kore.syntax.LeftAssoc)
                if op_name != "seq.firmem.read_write_port":
                    self.build_op_edge(op_target_name, _list_parttern, op_name)
                    self.build_firmem_write_edge(_list_parttern, op_name)

    def build_procedure_path(self, root) -> None:  # type: ignore
        _procedure_list_parttern = root.patterns[0]
        assert isinstance(_procedure_list_parttern, pyk.kore.syntax.LeftAssoc)
        assert _procedure_list_parttern.symbol == "Lbl'Unds'List'Unds'"
        for _, subpattern in enumerate(_procedure_list_parttern.patterns):
            _inj_parttern = subpattern.patterns[0]
            assert _inj_parttern.symbol == 'inj'  # type: ignore
            _op_parttern = _inj_parttern.patterns[0]
            _op_name_pattern = _op_parttern.patterns[0]
            assert isinstance(_op_name_pattern, pyk.kore.syntax.DV)
            _op_name = str(_op_name_pattern.value.value)
            if _op_name != 'seq.firmem.write_port':
                continue
            _write_list_parttern = _op_parttern.patterns[1]
            assert isinstance(_write_list_parttern, pyk.kore.syntax.LeftAssoc)
            assert _write_list_parttern.symbol == "Lbl'Unds'List'Unds'"

            self.build_firmem_write_edge(_write_list_parttern, _op_name)

    def build_grapth(self, source_file: Path, target_file: Path) -> None:
        # 从这里开始构建
        # 解析kore
        with open(source_file, "r", encoding="utf-8") as f:
            kore_text = f.read()

        parser = KoreParser(kore_text)
        pattern = parser.pattern()

        _generated_top_parttern = pattern
        _teq_parttern = self.find_with_symbol_name(_generated_top_parttern, "Lbl'-LT-'teq'-GT-'")
        assert _teq_parttern.symbol == "Lbl'-LT-'teq'-GT-'"

        _mlir_parttern = self.find_with_symbol_name(_teq_parttern, "Lbl'-LT-'mlir'-GT-'")
        assert _mlir_parttern.symbol == "Lbl'-LT-'mlir'-GT-'"

        _hardware_parttern = self.find_with_symbol_name(_teq_parttern, "Lbl'-LT-'hardware'-GT-'")
        assert _hardware_parttern.symbol == "Lbl'-LT-'hardware'-GT-'"

        _connection_parttern = self.find_with_symbol_name(_hardware_parttern, "Lbl'-LT-'connection'-GT-'")
        assert _connection_parttern.symbol == "Lbl'-LT-'connection'-GT-'"

        _map_of_connection_parttern = _connection_parttern.patterns[0]
        assert _map_of_connection_parttern.symbol == "Lbl'Unds'Map'Unds'"  # type: ignore
        #前面是定位到<connection>
        self.build_conncetion_path(_map_of_connection_parttern)

        _procedure_parttern = self.find_with_symbol_name(_hardware_parttern, "Lbl'-LT-'procedures'-GT-'")
        assert _procedure_parttern.symbol == "Lbl'-LT-'procedures'-GT-'"

        self.build_procedure_path(_procedure_parttern)
        self.path_compression() #压缩direct路径
        self.save_to_json(target_file)

    def path_compression(self) -> None:
        #压缩direct路径
        for node_name, node in self.node_map.items():
            if node.is_firmem or len(node.edges_in) != 1:
                continue
            if self.edge_map[node.edges_in[0]].attr != 'direct':
                continue
            que = [node_name]
            while len(self.node_map[que[-1]].edges_in) > 0:
                father_edge = self.node_map[que[-1]].edges_in[0]
                if self.edge_map[father_edge].attr != 'direct':
                    break
                que.append(self.edge_map[father_edge].to)
            for i in range(len(que) - 1):
                self.edge_map[self.node_map[que[i]].edges_in[0]].to = que[-1]

    def save_to_json(self, filename: Path) -> None:
        data = {
            "nodes": {name: node.to_dict() for name, node in self.node_map.items()},
            "edges": [edge.to_dict() for edge in self.edge_map],
        }
        with open(filename, "w") as f:
            json.dump(data, f, indent=2)

    def load_from_json(self, filename: Path) -> None:
        with open(filename) as f:
            data = json.load(f)

        self.node_map = {name: PathNode.from_dict(node_data) for name, node_data in data["nodes"].items()}
        self.edge_map = [PathEdge.from_dict(edge_data) for edge_data in data["edges"]]

    def search_path_kname(self, target: str, output_file: Path) -> None:
        flag_map: dict[str, tuple[int, str, str]] = {target: (0, 'target', 'target')}
        q: deque[str] = deque()
        q.append(str(target))
        while q:
            node = q.popleft()
            (now_dep, _, _) = flag_map[node]
            for edge_name in self.node_map[node].edges_in:
                to_name = self.edge_map[edge_name].to
                if to_name not in flag_map:
                    new_dep = now_dep + 1
                    flag_map[to_name] = (new_dep, self.edge_map[edge_name].attr, node)
                    if self.node_map[to_name].is_firmem or self.node_map[to_name].is_firreg:
                        #如果是firreg或者firmem，因为其内容来自于上一个周期或着更早周期，
                        #所以在单个周期具体查询节点的依赖关系中，已经算是起点。
                        continue
                    q.append(to_name)
        with open(output_file, 'w') as f:
            f.write(f'{target} size: {len(flag_map)}\n')
            for name, attr in flag_map.items():
                if name in self.differenes:
                    f.write('is defferenes : \n')
                if self.node_map[name].is_firmem:
                    f.write('is firmem :')
                elif self.node_map[name].is_firreg:
                    f.write('is firreg :')
                elif self.node_map[name].is_constant:
                    f.write('is constant :')
                f.write('depth:' + str(attr[0]) + '   ' + name + '\n')

    def change_vcdname2kname(self, vcdname: str) -> str:
        vcdname = vcdname.replace('.', '/')
        return self.signal_port_mapping[vcdname]

    def search_path_vcdname(self, target: str, output_file: Path) -> None:
        target = target.replace('.', '/')
        new_target = self.signal_port_mapping[target]
        print(new_target)
        self.search_path_kname(new_target, output_file)
