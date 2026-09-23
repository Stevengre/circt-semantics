"""在可中止进程中读取 Kore；只传回查询需要的扁平配置视图。"""

from __future__ import annotations

import gzip
import hashlib
import json
import multiprocessing
import pickle
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, Any, NamedTuple

from .model import BitVector, Budget, CompletionEvidence, StopCode, TraceError

if TYPE_CHECKING:
    from collections.abc import Iterator
    from multiprocessing.connection import Connection
    from multiprocessing.process import BaseProcess

    from pyk.kore.syntax import Pattern

MAP = "Lbl'Unds'Map'Unds'"
MAP_ITEM = "Lbl'UndsPipe'-'-GT-Unds'"
MAP_EMPTY = "Lbl'Stop'Map"
LIST = "Lbl'Unds'List'Unds'"
LIST_ITEM = 'LblListItem'
LIST_EMPTY = "Lbl'Stop'List"
INSTANCE_MAP = "Lbl'Unds'HwInstanceCellMap'Unds'"
INSTANCE_ITEM = 'LblHwInstanceCellMapItem'
INSTANCE_EMPTY = "Lbl'Stop'HwInstanceCellMap"
BITS = "Lblbits'LParUndsCommUndsRParUnds'BITS-SYNTAX'Unds'Bits'Unds'BitsValue'Unds'Int"
_BLOCK_BYTES = 64 * 1024
_IPC_BYTES = 64 * 1024


class _Node(NamedTuple):
    tag: str
    symbol: str
    sorts: tuple[str, ...]
    value: str | None
    children: tuple[int, ...]


@dataclass(frozen=True, slots=True, eq=False)
class Term:
    """共享扁平 arena 的只读节点；孩子是索引，深树不会触发递归复制。"""

    arena: tuple[_Node, ...]
    index: int

    @property
    def tag(self) -> str:
        """返回节点类别，如 DV、App 或 Assoc，供结构解码区分形状。"""
        return self.arena[self.index].tag

    @property
    def symbol(self) -> str:
        """返回当前节点的 Kore 构造器符号。"""
        return self.arena[self.index].symbol

    @property
    def sorts(self) -> tuple[str, ...]:
        """返回保留原始 Kore 文本的 sort 参数，避免结构比较丢失类型。"""
        return self.arena[self.index].sorts

    @property
    def value(self) -> str | None:
        """返回 DV/String 的字面值；没有字面值的节点返回 None。"""
        return self.arena[self.index].value

    @property
    def args(self) -> tuple[Term, ...]:
        """为孩子索引创建共享同一 arena 的视图，不递归复制子树。"""
        return tuple(Term(self.arena, index) for index in self.arena[self.index].children)


def _shape(message: str, term: Term | None = None, **details: Any) -> TraceError:
    """构造形状不受支持的停止原因，并附上可定位节点的符号、类型和索引。"""
    if term is not None:
        details.update(symbol=term.symbol, sorts=term.sorts, node=term.index)
    return TraceError(StopCode.UNSUPPORTED_SHAPE, message, **details)


def unwrap(term: Term) -> Term:
    """仅去除合法单实参 injection；原始节点仍保留其 sort。"""
    while term.symbol == 'inj':
        if len(term.args) != 1 or len(term.sorts) != 2:
            raise _shape('inj 形状不受支持', term)
        term = term.args[0]
    return term


def scalar(term: Term, sorts: tuple[str, ...] | None = None) -> str:
    """去除合法 injection 后读取具体 DV 文本；可要求 sort 与指定类型完全一致。"""
    value = unwrap(term)
    if value.tag != 'DV' or value.value is None or (sorts is not None and value.sorts != sorts):
        raise _shape('需要有明确类型的具体值', term)
    return value.value


def _collection(term: Term, concat: str, empty: str, item: str) -> Iterator[Term]:
    """迭代展开集合连接构造器并保留元素次序，遇到未知构造器或 sort 参数即拒绝。"""
    pending = [unwrap(term)]
    while pending:
        current = pending.pop()
        if current.sorts:
            raise _shape('集合构造器不支持 sort 参数', current, collection=concat)
        if current.symbol == concat:
            pending.extend(reversed(current.args))
        elif current.symbol == empty and not current.args:
            continue
        elif current.symbol == item:
            yield current
        else:
            raise _shape('集合包含无法解码的形状', current, collection=concat)


def list_items(term: Term) -> tuple[Term, ...]:
    """解码 K List 为有序元素元组，并验证每个 ListItem 只有一个实参。"""
    result = []
    for item in _collection(term, LIST, LIST_EMPTY, LIST_ITEM):
        if len(item.args) != 1:
            raise _shape('ListItem 必须包含一个值', item)
        result.append(item.args[0])
    return tuple(result)


def map_items(term: Term) -> tuple[tuple[Term, Term], ...]:
    """按结构读取 Map；禁止将重复 key 静默覆盖。"""
    result = []
    seen: set[str] = set()
    for item in _collection(term, MAP, MAP_EMPTY, MAP_ITEM):
        if len(item.args) != 2:
            raise _shape('Map 条目必须包含 key 和 value', item)
        key, value = item.args
        identity = canonical_digest(key)
        if identity in seen:
            raise TraceError(StopCode.INCONSISTENT_EVIDENCE, 'K Map 含重复 key', node=key.index)
        seen.add(identity)
        result.append((key, value))
    return tuple(result)


def string_map(term: Term) -> dict[str, Term]:
    """将 K Map 解码成字符串键映射，拒绝非 String 键及去除 injection 后的重名键。"""
    result = {}
    for key, value in map_items(term):
        name = scalar(key, ('SortString{}',))
        if name in result:
            raise TraceError(StopCode.INCONSISTENT_EVIDENCE, '字符串 Map 含重复 key', key=name)
        result[name] = value
    return result


def canonical_digest(term: Term) -> str:
    """Map 忽略关联方式及条目顺序；其余类型、数值和 List 顺序参与比较。"""
    digests: dict[int, str] = {}
    # 只遍历集合的语义元素，避免二叉 Map 链的重复展开。
    pending: list[tuple[Term, bool, tuple[Term, ...], str]] = [(term, False, (), '')]
    while pending:
        current, visited, children, kind = pending.pop()
        if current.index in digests:
            continue
        if not visited:
            if current.symbol in (MAP, MAP_EMPTY, MAP_ITEM):
                entries = map_items(current)
                children = tuple(child for entry in entries for child in entry)
                kind = 'Map'
            elif current.symbol in (LIST, LIST_EMPTY, LIST_ITEM):
                children, kind = list_items(current), 'List'
            else:
                children, kind = current.args, current.tag
            pending.append((current, True, children, kind))
            pending.extend((child, False, (), '') for child in reversed(children))
            continue
        values: Any = [digests[child.index] for child in children]
        if kind == 'Map':
            values = sorted(zip(values[::2], values[1::2], strict=True))
        label = kind if kind in ('Map', 'List') else current.symbol
        content = [kind, label, current.sorts, current.value, values]
        digests[current.index] = hashlib.sha256(json.dumps(content, ensure_ascii=False).encode()).hexdigest()
    return digests[term.index]


def bit_vector(term: Term) -> BitVector:
    """将具体二态 Bits 的数值和位宽转为 BitVector，未知值形状或非法宽度统一拒绝。"""
    value = unwrap(term)
    if value.symbol != BITS or len(value.args) != 2:
        raise TraceError(StopCode.UNSUPPORTED_VALUE, '值不是受支持的二态 Bits', symbol=value.symbol)
    try:
        number = int(scalar(value.args[0], ('SortInt{}',)))
        width = int(scalar(value.args[1], ('SortInt{}',)))
        return BitVector.from_int(number, width)
    except (ValueError, TraceError) as error:
        raise TraceError(StopCode.UNSUPPORTED_VALUE, 'Bits 数值或位宽不合法', symbol=value.symbol) from error


@dataclass(frozen=True)
class Instance:
    id: str
    module: str
    inputs: tuple[tuple[str, str, Term], ...]
    outputs: tuple[tuple[str, str, Term], ...]


def _term_cells(term: Term) -> dict[str, Term]:
    """按 cell 构造器名称索引容器的直接孩子，拒绝非 cell 条目和重名 cell。"""
    cells = {}
    for child in term.args:
        if not child.symbol.startswith("Lbl'-LT-'") or not child.symbol.endswith("'-GT-'"):
            raise _shape('配置容器包含未知条目', child)
        name = child.symbol[9:-6]
        if name in cells:
            raise TraceError(StopCode.INCONSISTENT_EVIDENCE, '配置含重复 cell', cell=name)
        cells[name] = child
    return cells


def _cell_value(cells: dict[str, Term], name: str) -> Term:
    """提取指定必需 cell 的唯一内容，缺失或实参数量异常时停止。"""
    if name not in cells or len(cells[name].args) != 1:
        raise _shape('必需 cell 缺失或 arity 不受支持', cell=name)
    return cells[name].args[0]


def _instances(term: Term) -> tuple[Instance, ...]:
    """解码硬件实例及其输入输出端口，保留信号引用和完整类型节点。

    严格校验实例 cell 集、Map 键与实例身份，以及端口名称/信号/类型的等长关系，
    防止 zip 截断或重复身份把损坏元数据变成合法视图。
    """
    if len(term.args) != 2:
        raise _shape('hw-instances 必须包含实例集合和 setup cell', term)
    collection, setup = term.args
    if setup.symbol != "Lbl'-LT-'hw-setup-inst'-GT-'" or len(setup.args) != 1:
        raise _shape('hw-instances 缺少 setup cell', setup)
    list_items(setup.args[0])
    result = []
    ids: set[str] = set()
    required = {
        'hw-id',
        'hw-module',
        'hw-inputs',
        'hw-inports',
        'hw-in-types',
        'hw-outputs',
        'hw-outports',
        'hw-out-types',
    }
    for item in _collection(collection, INSTANCE_MAP, INSTANCE_EMPTY, INSTANCE_ITEM):
        if len(item.args) != 2:
            raise _shape('实例 MapItem 形状不受支持', item)
        key, instance = item.args
        cells = _term_cells(instance)
        if (
            instance.symbol != "Lbl'-LT-'hw-instance'-GT-'"
            or set(cells) != required
            or key.symbol != "Lbl'-LT-'hw-id'-GT-'"
            or len(key.args) != 1
        ):
            raise _shape('实例配置 cell 集不受支持', instance, cells=sorted(cells))
        name = scalar(_cell_value(cells, 'hw-id'), ('SortString{}',))
        if name in ids or scalar(key.args[0], ('SortString{}',)) != name:
            raise TraceError(StopCode.INCONSISTENT_EVIDENCE, '实例身份重复或 Map key 与 cell 不一致', instance=name)
        ids.add(name)
        ports = []
        for direction in ('in', 'out'):
            names = list_items(_cell_value(cells, f'hw-{direction}puts'))
            signals = list_items(_cell_value(cells, f'hw-{direction}ports'))
            types = list_items(_cell_value(cells, f'hw-{direction}-types'))
            if not len(names) == len(signals) == len(types):
                raise _shape('实例端口名称、信号与类型数量不匹配', instance, instance=name)
            ports.append(
                tuple(
                    (scalar(n, ('SortBareId{}',)), scalar(s, ('SortString{}',)), t)
                    for n, s, t in zip(names, signals, types, strict=True)
                )
            )
        result.append(Instance(name, scalar(_cell_value(cells, 'hw-module'), ('SortString{}',)), ports[0], ports[1]))
    return tuple(result)


@dataclass(frozen=True)
class DecodedState:
    cells: dict[str, Term]
    fingerprints: dict[str, str]
    completion: CompletionEvidence
    artifact_sha256: str
    uncompressed_sha256: str
    read_bytes: int
    ast_nodes: int
    ast_depth: int
    view_bytes: int

    @property
    def signals(self) -> dict[str, Term]:
        """读取当前状态的信号值映射，值仍为可进一步解码的 Term。"""
        return string_map(self.cells['signals'])

    @property
    def history(self) -> dict[str, Term]:
        """读取当前配置保存的前次信号视图；其真实性仍需与实际前驱核对。"""
        return string_map(self.cells['history'])

    @property
    def connection(self) -> dict[str, Term]:
        """读取信号到驱动操作或别名的连接映射。"""
        return string_map(self.cells['connection'])

    @property
    def register(self) -> dict[str, Term]:
        """读取需从 history 取值的端口登记，包括 firreg 位宽与 firmem 读写延迟。"""
        return string_map(self.cells['register'])

    @property
    def register_proc(self) -> dict[str, Term]:
        """读取 firmem 延迟读端口的 enable、address 和 mode 管线状态。"""
        return string_map(self.cells['register-proc'])

    @property
    def procedures(self) -> tuple[Term, ...]:
        """按原始 List 顺序返回过程定义。"""
        return list_items(self.cells['procedures'])

    @property
    def instances(self) -> tuple[Instance, ...]:
        """按已知 cell 布局解码实例、模块名及输入输出端口绑定。"""
        return _instances(self.cells['hw-instances'])


def metadata_differences(setup: DecodedState, state: DecodedState) -> tuple[str, ...]:
    """比较 setup 与目标状态的只读元数据指纹，返回发生变化的 cell 名称。"""
    return tuple(
        name
        for name in ('connection', 'procedures', 'register', 'hw-instances', 'top-module', 'top-ins')
        if setup.fingerprints[name] != state.fingerprints[name]
    )


def history_matches(predecessor: DecodedState, state: DecodedState) -> bool:
    """核对当前 history 的结构指纹是否等于给定真实前驱的 signals。"""
    return predecessor.fingerprints['signals'] == state.fingerprints['history']


def lexical_precheck(text: str, budget: Budget) -> tuple[int, int]:
    """使用 Kore lexer 识别字符串/注释，AST 创建前约束词法节点数和嵌套。"""
    from pyk.kore.lexer import TokenType, kore_lexer

    stack: list[Any] = []
    count = peak = 0
    pairs = {TokenType.RPAREN: TokenType.LPAREN, TokenType.RBRACE: TokenType.LBRACE}
    for token in kore_lexer(text):
        if token.type in (TokenType.LPAREN, TokenType.LBRACE):
            stack.append(token.type)
            peak = max(peak, len(stack))
            if peak > budget.max_ast_depth:
                raise TraceError(StopCode.AST_DEPTH_BUDGET, 'Kore 嵌套超过预算', ast_depth=peak)
        elif token.type in pairs:
            if not stack or stack.pop() != pairs[token.type]:
                raise TraceError(StopCode.INVALID_INPUT, 'Kore 括号不配对')
        # 每个 application/sort 起始标识和 DV 字符串均计入保守规模上界。
        if token.type not in {
            TokenType.EOF,
            TokenType.COMMA,
            TokenType.COLON,
            TokenType.LPAREN,
            TokenType.RPAREN,
            TokenType.LBRACE,
            TokenType.RBRACE,
        }:
            count += 1
            if count > budget.max_ast_nodes:
                raise TraceError(StopCode.AST_NODES_BUDGET, 'Kore 词法节点数超过预算', ast_nodes=count)
    if stack:
        raise TraceError(StopCode.INVALID_INPUT, 'Kore 括号未闭合')
    return count, peak


def _project(root: Pattern) -> tuple[tuple[_Node, ...], dict[str, int]]:
    """从完整 generatedTop 配置中选择查询所需 cell，投影为扁平 arena 和根索引。

    先校验已知配置布局，再以显式后序栈保留节点类型、sort、字面值和孩子关系；
    共享节点复用索引，避免深树递归复制或将未知 pattern 静默忽略。
    """
    from pyk.kore.syntax import DV, App, Assoc, String

    def children(parent: Pattern) -> dict[str, Pattern]:
        """将容器的直接 Kore cell 按名称索引，拒绝未知条目及重复 cell。"""
        result: dict[str, Pattern] = {}
        for child in parent.patterns:
            if not isinstance(child, App) or not child.symbol.startswith("Lbl'-LT-'"):
                raise _shape('配置容器形状不受支持', symbol=getattr(child, 'symbol', type(child).__name__))
            name = child.symbol[9:-6]
            if name in result:
                raise TraceError(StopCode.INCONSISTENT_EVIDENCE, '配置含重复 cell', cell=name)
            result[name] = child
        return result

    if not isinstance(root, App) or root.symbol != "Lbl'-LT-'generatedTop'-GT-'":
        raise _shape('需要完整 generatedTop 配置')
    top = children(root)
    if 'teq' not in top:
        raise _shape('配置缺少 teq')
    teq = children(top['teq'])
    required_containers = {'mlir', 'hardware', 'circt', 'hw'}
    if set(teq) != required_containers:
        raise _shape('teq 配置 cell 集不受支持', cells=sorted(teq))
    hardware = children(teq['hardware'])
    required_hardware = {
        'setup',
        'connection',
        'procedures',
        'register',
        'register-proc',
        'sv-logs',
        'signals',
        'history',
        'currents',
        'clock',
    }
    if set(hardware) != required_hardware:
        raise _shape('hardware 配置 cell 集不受支持', cells=sorted(hardware))
    selected = dict(hardware)
    for container, names in (
        ('mlir', ('prog',)),
        ('circt', ('cmd', 'top-module', 'top-ins')),
        ('hw', ('hw-instances',)),
    ):
        cells = children(teq[container])
        for name in names:
            if name not in cells:
                raise _shape('配置缺少必需 cell', cell=name)
            selected[name] = cells[name]
    # arena 按后序建立，父节点写入时所有孩子索引均已可用。
    roots = {}
    nodes: list[_Node] = []
    indices: dict[int, int] = {}
    for name, cell in selected.items():
        if name != 'hw-instances' and len(cell.patterns) != 1:
            raise _shape('配置 cell arity 不受支持', cell=name)
        value = cell if name == 'hw-instances' else cell.patterns[0]
        pending = [(value, False)]
        while pending:
            node, visited = pending.pop()
            if id(node) in indices:
                continue
            if not visited:
                pending.append((node, True))
                pending.extend((child, False) for child in reversed(node.patterns))
                continue
            if isinstance(node, DV):
                entry = _Node('DV', r'\dv', (node.sort.text,), node.value.value, ())
            elif isinstance(node, (App, Assoc)):
                entry = _Node(
                    type(node).__name__,
                    node.symbol,
                    tuple(sort.text for sort in node.sorts),
                    None,
                    tuple(indices[id(child)] for child in node.patterns),
                )
            elif isinstance(node, String):
                entry = _Node('String', '', (), node.value, ())
            else:
                raise _shape('必要 cell 包含不支持的 Kore pattern', pattern=type(node).__name__, cell=name)
            indices[id(node)] = len(nodes)
            nodes.append(entry)
        roots[name] = indices[id(value)]
    return tuple(nodes), roots


def _decode(text: str, budget: Budget) -> tuple[tuple[_Node, ...], dict[str, Any]]:
    """在 worker 内解析单个完整 Kore 配置，返回扁平节点及结构/完成状态元数据。

    词法预算检查先于 AST 创建；所有必需集合须通过结构校验。
    prog、setup、cmd 或 currents 尚有待执行内容时标记 incomplete，不替调用方推断设计正确性。
    """
    from pyk.kore.parser import KoreParser

    ast_nodes, depth = lexical_precheck(text, budget)
    # pyk 的递归仅存在于可终止的 worker 中；主进程维持默认递归限额。
    sys.setrecursionlimit(max(1000, min(100_000, depth * 10 + 1000)))
    parser = KoreParser(text)
    root = parser.pattern()
    if not parser.eof:
        raise TraceError(StopCode.INVALID_INPUT, '完整 Kore 配置之后还有内容')
    arena, roots = _project(root)
    cells = {name: Term(arena, index) for name, index in roots.items()}
    # 校验所有必要 Map，包括嵌套 memory Map 与 operation 属性 Map。
    fingerprints = {name: canonical_digest(term) for name, term in cells.items()}
    for name in ('connection', 'register', 'register-proc', 'signals', 'history'):
        string_map(cells[name])
    list_items(cells['procedures'])
    _instances(cells['hw-instances'])
    pending = [name for name in ('prog', 'setup', 'cmd') if cells[name].symbol != 'dotk' or cells[name].args]
    if cells['currents'].symbol != "Lbl'Stop'CurrentInfoCellMap" or cells['currents'].args:
        pending.append('currents')
    return arena, {
        'roots': roots,
        'fingerprints': fingerprints,
        'pending': pending,
        'ast_nodes': ast_nodes,
        'ast_depth': depth,
    }


class _HashingInput:
    """哈希与解压消费同一批原始字节，避免先哈希再打开时的混用窗口。"""

    def __init__(self, stream: Any, digest: Any) -> None:
        """绑定压缩原始流及其哈希累加器，让解压与身份校验消费同一份字节。"""
        self.stream, self.digest = stream, digest

    def read(self, size: int = -1) -> bytes:
        """返回顺序读出的原始字节，并把同一批字节累计到工件哈希。"""
        data: bytes = self.stream.read(size)
        self.digest.update(data)
        return data

    def seek(self, offset: int, /) -> object:
        """拒绝回退或重定位，避免重复/遗漏字节破坏压缩工件哈希。"""
        raise OSError('哈希解压流仅允许顺序读取')


def _load(path: str, compression: str, budget: Budget, remaining: int, counter: Any) -> tuple[str, str, str]:
    """按预算读取普通或 gzip 状态，返回 UTF-8 文本、工件哈希与解压内容哈希。

    counter 记录本次实际解压字节，单文件或剩余累计额度超限立即停止；
    失败时已消费的字节仍可由主进程计费。
    """
    artifact_hash = hashlib.sha256()
    content_hash = hashlib.sha256()
    blocks = []
    with Path(path).open('rb') as raw:
        stream = gzip.GzipFile(fileobj=_HashingInput(raw, artifact_hash)) if compression == 'gzip' else raw
        try:
            while True:
                # 最多多读一个字节，用实际读量区分恰好耗尽预算与真正超限。
                limit = min(_BLOCK_BYTES, budget.max_state_bytes - counter.value + 1, remaining - counter.value + 1)
                block = stream.read1(max(1, limit))
                if not block:
                    break
                counter.value += len(block)
                if counter.value > budget.max_state_bytes:
                    raise TraceError(StopCode.STATE_BYTES_BUDGET, '单状态解压字节超过预算')
                if counter.value > remaining:
                    raise TraceError(StopCode.READ_BYTES_BUDGET, '累计解压字节超过预算')
                content_hash.update(block)
                if compression == 'none':
                    artifact_hash.update(block)
                blocks.append(block)
        finally:
            if stream is not raw:
                stream.close()
    return b''.join(blocks).decode('utf-8'), artifact_hash.hexdigest(), content_hash.hexdigest()


def _send_frame(connection: Connection, message: tuple[Any, ...]) -> None:
    """以受限大小的 pickle 帧发送本地 worker 消息，超大单值明确拒绝。"""
    payload = pickle.dumps(message, protocol=5)
    if len(payload) > _IPC_BYTES:
        raise TraceError(
            StopCode.UNSUPPORTED_VALUE,
            '单个 Kore 值或元数据过大，无法在有界 IPC 包内返回',
            ipc_bytes=len(payload),
            max_ipc_bytes=_IPC_BYTES,
        )
    connection.send_bytes(payload)


def _send_error(connection: Connection, error: TraceError) -> None:
    """发送结构化停止原因；诊断过大时省略细节，保留错误码和截短后的说明。"""
    try:
        _send_frame(connection, ('error', error.code.value, error.message, error.details))
    except TraceError:
        # 错误本身也可能带有巨大的非法 token；只省略该诊断细节，不伪造读取成功。
        _send_frame(connection, ('error', error.code.value, error.message[:1024], {'details_omitted': True}))


def _worker(connection: Connection, budget: Budget, counter: Any) -> None:
    """循环接收状态读取请求，校验双层哈希、解析配置并分批返回扁平节点。

    节点帧按 IPC 上限缩小，单节点仍超限则失败；解码异常转换成稳定停止原因。
    收到结束标记或通信关闭即退出，主进程可在预算到期时直接终止此进程。
    """
    try:
        while True:
            job = connection.recv()
            if job is None:
                return
            path, compression, remaining, expected_artifact, expected_content = job
            try:
                text, artifact_hash, content_hash = _load(path, compression, budget, remaining, counter)
                for expected, actual, layer in (
                    (expected_artifact, artifact_hash, 'artifact'),
                    (expected_content, content_hash, 'uncompressed'),
                ):
                    if expected is not None and expected != actual:
                        raise TraceError(
                            StopCode.HASH_MISMATCH, 'Kore 工件哈希不匹配', layer=layer, expected=expected, actual=actual
                        )
                arena, metadata = _decode(text, budget)
                # 不发送整份 AST 或递归 pickle；每批传输后主进程重新检查截止时间。
                # 保守计算解码视图的 Python 对象成本，含 arena/根/指纹的容器开销。
                view_bytes = 16_384 + 8 * len(arena)
                offset = 0
                while offset < len(arena):
                    stop = min(offset + 128, len(arena))
                    while True:
                        batch = arena[offset:stop]
                        payload = pickle.dumps(('nodes', batch), protocol=5)
                        if len(payload) <= _IPC_BYTES or stop - offset == 1:
                            break
                        stop = offset + (stop - offset) // 2
                    if len(payload) > _IPC_BYTES:
                        raise TraceError(
                            StopCode.UNSUPPORTED_VALUE,
                            '单个 Kore 值过大，无法在有界 IPC 包内返回',
                            ipc_bytes=len(payload),
                            max_ipc_bytes=_IPC_BYTES,
                        )
                    view_bytes += sum(
                        sys.getsizeof(node)
                        + sys.getsizeof(node.symbol)
                        + sys.getsizeof(node.sorts)
                        + sum(map(sys.getsizeof, node.sorts))
                        + sys.getsizeof(node.value)
                        + sys.getsizeof(node.children)
                        + sum(map(sys.getsizeof, node.children))
                        for node in batch
                    )
                    connection.send_bytes(payload)
                    offset = stop
                metadata.update(artifact_sha256=artifact_hash, uncompressed_sha256=content_hash, view_bytes=view_bytes)
                _send_frame(connection, ('done', metadata))
            except TraceError as error:
                _send_error(connection, error)
            except FileNotFoundError:
                _send_error(connection, TraceError(StopCode.MISSING_ARTIFACT, 'Kore 工件不存在', path=path))
            except (ValueError, OSError, EOFError, RecursionError) as error:
                _send_error(
                    connection, TraceError(StopCode.INVALID_INPUT, 'Kore 工件无法解析', error=str(error), path=path)
                )
    except (EOFError, BrokenPipeError):
        return
    finally:
        connection.close()


class KoreReader:
    """一个查询的读取预算与 worker；失败读取也消耗预算，调用方自行保存 frontier。"""

    def __init__(self, budget: Budget | None = None, *, deadline: float | None = None) -> None:
        """建立单次查询的累计预算与截止时间，解析 worker 延迟到首次读取时启动。"""
        self.budget = budget or Budget()
        self.started_at = time.monotonic()
        self.deadline = min(
            deadline if deadline is not None else float('inf'), self.started_at + self.budget.max_seconds
        )
        self.read_bytes = 0
        self.states_read = 0
        self._process: BaseProcess | None = None
        self._connection: Connection | None = None
        self._counter: Any = None

    def __enter__(self) -> KoreReader:
        """返回当前 reader，以便在上下文结束时自动释放解析进程。"""
        return self

    def __exit__(self, *_args: Any) -> None:
        """无论读取是否抛错，都释放通信管道与解析进程。"""
        self.close()

    @property
    def elapsed_seconds(self) -> float:
        """返回从 reader 创建起计算的单调时钟耗时。"""
        return time.monotonic() - self.started_at

    def close(self) -> None:
        """关闭管道并限时终止 worker；常规终止无效时强制结束，支持重复调用。"""
        if self._connection is not None:
            self._connection.close()
            self._connection = None
        if self._process is not None:
            if self._process.is_alive():
                self._process.terminate()
            self._process.join(timeout=0.2)
            if self._process.is_alive():
                self._process.kill()
                self._process.join(timeout=0.2)
            self._process.close()
            self._process = None

    def _start(self) -> None:
        """首次使用时以 spawn 启动独立解析进程，并建立管道和解压字节共享计数器。"""
        if self._process is not None:
            return
        context = multiprocessing.get_context('spawn')
        parent, child = context.Pipe()
        self._counter = context.Value('Q', 0, lock=False)
        process = context.Process(target=_worker, args=(child, self.budget, self._counter), daemon=True)
        process.start()
        child.close()
        self._connection, self._process = parent, process

    def read(
        self,
        path: Path | str,
        *,
        compression: str | None = None,
        artifact_sha256: str | None = None,
        uncompressed_sha256: str | None = None,
    ) -> DecodedState:
        """在查询预算内读取一个状态，可同时校验工件与解压内容的预期哈希。

        主进程分帧接收视图并持续检查截止时间，超时会终止 worker；
        成功与失败都累计实际解压字节，已提交的读取也消耗状态次数预算。
        """
        before = self.read_bytes
        if time.monotonic() >= self.deadline:
            raise TraceError(StopCode.TIME_BUDGET, '查询读取时间预算已耗尽', read_bytes=0)
        if self.states_read >= self.budget.max_states:
            raise TraceError(StopCode.STATE_BUDGET, '状态读取次数预算已耗尽', read_bytes=0)
        if before >= self.budget.max_read_bytes:
            raise TraceError(StopCode.READ_BYTES_BUDGET, '累计解压字节预算已耗尽', read_bytes=0)
        path = Path(path)
        compression = compression or ('gzip' if path.suffix == '.gz' else 'none')
        if compression not in ('none', 'gzip'):
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, '不支持此状态压缩格式', compression=compression)
        self._start()
        assert self._connection is not None and self._process is not None
        connection = self._connection
        self._counter.value = 0
        self.states_read += 1
        nodes: list[_Node] = []
        try:
            connection.send(
                (str(path), compression, self.budget.max_read_bytes - before, artifact_sha256, uncompressed_sha256)
            )
            while True:
                remaining = self.deadline - time.monotonic()
                if remaining <= 0:
                    self.close()
                    raise TraceError(StopCode.TIME_BUDGET, '解析 worker 已到截止时间并终止')
                if not connection.poll(min(0.02, remaining)):
                    if not self._process.is_alive():
                        self.close()
                        raise TraceError(StopCode.INTERNAL_ERROR, '解析 worker 提前退出')
                    continue
                # 消息仅来自本地可信 worker，大小在反序列化之前受限。
                message = pickle.loads(connection.recv_bytes(maxlength=_IPC_BYTES))
                if message[0] == 'nodes':
                    nodes.extend(message[1])
                    continue
                if message[0] == 'error':
                    raise TraceError(message[1], message[2], **message[3])
                metadata = message[1]
                if time.monotonic() >= self.deadline:
                    self.close()
                    raise TraceError(StopCode.TIME_BUDGET, '读取视图传输超过截止时间')
                arena = tuple(nodes)
                return DecodedState(
                    cells={name: Term(arena, index) for name, index in metadata['roots'].items()},
                    fingerprints=metadata['fingerprints'],
                    completion=CompletionEvidence(
                        status='incomplete' if metadata['pending'] else 'completed',
                        details={'pending_cells': metadata['pending']},
                    ),
                    artifact_sha256=metadata['artifact_sha256'],
                    uncompressed_sha256=metadata['uncompressed_sha256'],
                    read_bytes=self._counter.value,
                    ast_nodes=metadata['ast_nodes'],
                    ast_depth=metadata['ast_depth'],
                    view_bytes=metadata['view_bytes'],
                )
        except (EOFError, BrokenPipeError) as error:
            self.close()
            raise TraceError(StopCode.INTERNAL_ERROR, '解析 worker 通信中断', read_bytes=self._counter.value) from error
        except TraceError as error:
            error.details.update(read_bytes=self._counter.value, total_read_bytes=before + self._counter.value)
            raise
        finally:
            # worker 失败或被终止后，共享计数器仍保留本次已消费的解压字节。
            self.read_bytes = before + self._counter.value
