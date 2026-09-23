"""对同一 generic IR 绑定源码位置；源码定位精度不代表根因证明。"""

from __future__ import annotations

import hashlib
import json
import re
import time
from dataclasses import dataclass, field, replace
from pathlib import Path
from typing import TYPE_CHECKING, Any

from .model import SourceBinding, SourceLocation, StopCode, StopReason, TraceError

if TYPE_CHECKING:
    from collections.abc import Callable

    from .artifacts import RunArtifacts
    from .model import ArtifactRef, Budget, SourcePrecision
    from .topology import Operation


def _unsupported(message: str, **details: Any) -> TraceError:
    """将无法安全解析的 IR 或源码形状包装为统一的 UNSUPPORTED_SHAPE 错误。"""
    return TraceError(StopCode.UNSUPPORTED_SHAPE, message, **details)


@dataclass(frozen=True)
class _Token:
    kind: str
    value: str
    start: int
    end: int
    line: int
    column: int


@dataclass(frozen=True)
class _Location:
    kind: str
    raw: str
    file: str | None = None
    line: int | None = None
    column: int | None = None
    end_line: int | None = None
    end_column: int | None = None
    children: tuple[_Location, ...] = ()


@dataclass(frozen=True)
class IRInstruction:
    ordinal: int
    module_symbol: str | None
    name: str
    results: tuple[str, ...]
    operands: tuple[str, ...]
    line: int
    column: int
    end_line: int
    location: _Location | None
    start_token: int = field(repr=False)
    end_token: int = field(repr=False)
    regions: tuple[tuple[int, int], ...] = field(repr=False)


@dataclass(frozen=True)
class GenericIR:
    """不含位置差异的完整词法结构，以及从原文件解析的操作身份。"""

    structure: tuple[tuple[str, str], ...]
    operations: tuple[IRInstruction, ...]
    lines: tuple[str, ...]


def _lex(text: str, budget: Budget, check: Callable[[], None]) -> tuple[_Token, ...]:
    """将支持的 generic IR 文本分词，同时保留每个 token 的原始行列和文本偏移。

    忽略空白与注释，解码字符串转义；检查 token 数、注释深度和调用方截止时间。
    遇到不支持的符号或未闭合结构立即拒绝，避免继续生成不完整的结构指纹。
    """
    tokens: list[_Token] = []
    index = 0
    line = column = 1
    word = re.compile(r'[%@#^!]?[A-Za-z0-9_.$-]+(?:#[0-9]+)?')

    def advance(end: int) -> None:
        """消费当前位置到 end 的文本，并同步更新字符偏移及从 1 开始的行列坐标。"""
        nonlocal index, line, column
        piece = text[index:end]
        newlines = piece.count('\n')
        line += newlines
        column = len(piece.rsplit('\n', 1)[-1]) + 1 if newlines else column + len(piece)
        index = end

    while index < len(text):
        if len(tokens) % 256 == 0:
            check()
        if text[index].isspace():
            advance(index + 1)
            continue
        if text.startswith('//', index):
            end = text.find('\n', index)
            advance(len(text) if end < 0 else end)
            continue
        if text.startswith('/*', index):
            end, nesting = index + 2, 1
            while nesting:
                check()
                opening, closing = text.find('/*', end), text.find('*/', end)
                if closing < 0:
                    raise _unsupported('MLIR 块注释未闭合', line=line)
                if 0 <= opening < closing:
                    nesting += 1
                    end = opening + 2
                    if nesting > budget.max_ast_depth:
                        raise _unsupported('MLIR 注释嵌套超过支持范围')
                else:
                    nesting -= 1
                    end = closing + 2
            advance(end)
            continue
        start, token_line, token_column = index, line, column
        if text[index] == '"':
            end = index + 1
            decoded = bytearray()
            while end < len(text) and text[end] != '"':
                if (end - start) % 4096 == 0:
                    check()
                if text[end] == '\\':
                    end += 1
                    if end >= len(text):
                        break
                    if text[end] in ('"', '\\'):
                        decoded.extend(text[end].encode())
                        end += 1
                    elif end + 1 < len(text) and re.fullmatch('[0-9a-fA-F]{2}', text[end : end + 2]):
                        decoded.append(int(text[end : end + 2], 16))
                        end += 2
                    elif text[end] in 'ntr':
                        decoded.extend({'n': b'\n', 't': b'\t', 'r': b'\r'}[text[end]])
                        end += 1
                    else:
                        raise _unsupported('MLIR 字符串转义不受支持', line=line)
                else:
                    if text[end] == '\n':
                        raise _unsupported('MLIR 字符串不能直接跨行', line=line)
                    decoded.extend(text[end].encode())
                    end += 1
            if end >= len(text):
                raise _unsupported('MLIR 字符串未闭合', line=line)
            try:
                value = decoded.decode('utf-8')
            except UnicodeDecodeError as error:
                raise _unsupported('MLIR 字符串不是 UTF-8') from error
            kind, end = 'string', end + 1
        elif text.startswith('->', index) or text.startswith('::', index):
            kind, value, end = 'punct', text[index : index + 2], index + 2
        elif match := word.match(text, index):
            kind, value, end = 'word', match[0], match.end()
        elif text[index] in '()[]{}<>:,=+*/?|&;':
            kind, value, end = 'punct', text[index], index + 1
        else:
            raise _unsupported('MLIR 包含不支持的词法符号', line=line, column=column)
        tokens.append(_Token(kind, value, start, end, token_line, token_column))
        if len(tokens) > budget.max_ast_nodes:
            raise _unsupported('MLIR token 数超过支持预算')
        advance(end)
    return tuple(tokens)


def _matches(tokens: tuple[_Token, ...], budget: Budget) -> dict[int, int]:
    """建立起始括号到结束括号的索引，拒绝错配、未闭合及超出预算的嵌套。"""
    matching = {}
    stack = []
    pairs = {')': '(', ']': '[', '}': '{', '>': '<'}
    for index, token in enumerate(tokens):
        if token.kind != 'punct':
            continue
        if token.value in pairs.values():
            stack.append(index)
            if len(stack) > budget.max_ast_depth:
                raise _unsupported('MLIR 嵌套超过支持预算')
        elif token.value in pairs:
            if not stack or tokens[stack[-1]].value != pairs[token.value]:
                raise _unsupported('MLIR 括号不配对', line=token.line)
            opening = stack.pop()
            matching[opening] = index
    if stack:
        raise _unsupported('MLIR 括号未闭合', line=tokens[stack[-1]].line)
    return matching


def _split(tokens: tuple[_Token, ...], start: int, end: int, matching: dict[int, int]) -> list[tuple[int, int]]:
    """按 token 半开区间内的顶层逗号分段，利用括号配对跳过嵌套内容。"""
    result = []
    first = index = start
    while index < end:
        if tokens[index].kind == 'punct' and tokens[index].value == ',':
            result.append((first, index))
            first = index + 1
        index = matching.get(index, index) + 1
    if first < end:
        result.append((first, end))
    return result


def parse_generic(text: str, budget: Budget, *, check: Callable[[], None] = lambda: None) -> GenericIR:
    """解析受支持的 generic IR，返回忽略位置差异的完整结构及操作身份。

    先展开并校验位置别名，再提取操作、SSA 结果、区域和所属模块；所有非位置 token
    都参与结构比较。区域或根模块外存在未解析内容时拒绝，预算与截止时间由调用方提供。
    """
    tokens = _lex(text, budget, check)
    matching = _matches(tokens, budget)
    values = [token.value for token in tokens]
    aliases: dict[str, tuple[int, int]] = {}
    omitted: set[int] = set()
    loc_spans: dict[int, int] = {}
    # 只有顶层别名定义可从结构指纹中整体移除，避免把嵌套属性误判为声明。
    top_level = set()
    depth = 0
    for position, token in enumerate(tokens):
        if depth == 0:
            top_level.add(position)
        if token.kind == 'punct' and token.value in ('(', '[', '{', '<'):
            depth += 1
        elif token.kind == 'punct' and token.value in (')', ']', '}', '>'):
            depth -= 1
    index = 0
    while index < len(tokens):
        if (
            tokens[index].kind == 'word'
            and values[index] == 'loc'
            and index + 1 < len(tokens)
            and values[index + 1] == '('
        ):
            end = matching[index + 1] + 1
            loc_spans[index] = end
            if (
                index >= 2
                and index - 2 in top_level
                and values[index - 1] == '='
                and tokens[index - 2].kind == 'word'
                and values[index - 2].startswith('#')
            ):
                name = values[index - 2]
                if name in aliases:
                    raise _unsupported('location alias 重复定义', alias=name)
                aliases[name] = (index + 2, end - 1)
                omitted.update(range(index - 2, end))
            index = end
        else:
            index += 1

    # 递归深度不足以限制重复别名的扇出，因此同时约束总展开量。
    remaining_locations = min(budget.max_ast_nodes, 4 * len(tokens))

    def location(start: int, end: int, seen: tuple[str, ...] = (), nesting: int = 0) -> _Location:
        """将位置 token 区间解析为 unknown、文件范围或 fused 树，并展开已声明别名。

        记录别名访问链以拒绝循环，同时限制递归深度和总展开次数，避免共享别名指数展开。
        文件行列必须为正，范围终点不得早于起点；不支持的 location 形状明确报错。
        """
        nonlocal remaining_locations
        check()
        remaining_locations -= 1
        if nesting > 64 or remaining_locations < 0:
            raise _unsupported('location 嵌套或 alias 展开超过支持预算')
        if start >= end:
            raise _unsupported('location 不能为空')
        raw = text[tokens[start].start : tokens[end - 1].end]
        if end - start == 1 and tokens[start].kind == 'word' and values[start] in aliases:
            name = values[start]
            if name in seen:
                raise _unsupported('location alias 成环', alias=name)
            first, last = aliases[name]
            return replace(location(first, last, (*seen, name), nesting + 1), raw=raw)
        if end - start == 1 and tokens[start].kind == 'word' and values[start] == 'unknown':
            return _Location('unknown', raw)
        if (
            tokens[start].kind == 'word'
            and values[start] == 'loc'
            and start + 1 in matching
            and matching[start + 1] == end - 1
        ):
            return replace(location(start + 2, end - 1, seen, nesting + 1), raw=raw)
        if (
            tokens[start].kind == 'word'
            and values[start] == 'fused'
            and start + 1 < end
            and values[start + 1] == '['
            and matching[start + 1] == end - 1
        ):
            children = tuple(
                location(first, last, seen, nesting + 1) for first, last in _split(tokens, start + 2, end - 1, matching)
            )
            return _Location('fused', raw, children=children)
        if tokens[start].kind != 'string' or end - start < 5 or values[start + 1] != ':' or values[start + 3] != ':':
            raise _unsupported('location 形状不受支持', raw_location=raw)
        try:
            line, column = int(values[start + 2]), int(values[start + 4])
            end_line = end_column = None
            suffix = values[start + 5 : end]
            if suffix:
                if len(suffix) == 3 and suffix[:2] == ['to', ':']:
                    end_line, end_column = line, int(suffix[2])
                elif len(suffix) == 4 and suffix[0] == 'to' and suffix[2] == ':':
                    end_line, end_column = int(suffix[1]), int(suffix[3])
                else:
                    raise ValueError('range')
            if min(line, column, end_line or line, end_column or column) <= 0:
                raise ValueError('coordinate')
            if end_line is not None and (end_line, end_column or 0) < (line, column):
                raise ValueError('range')
        except ValueError as error:
            raise _unsupported('location 行列或范围不受支持', raw_location=raw) from error
        return _Location('file', raw, values[start], line, column, end_line, end_column)

    locations = {start: location(start + 2, end - 1) for start, end in loc_spans.items()}
    canonical = []
    index = 0
    excluded = set(omitted)
    while index < len(tokens):
        check()
        if index in omitted:
            index += 1
        elif index in loc_spans:
            end = loc_spans[index]
            # 属性中的 location 值保留一个占位；尾随位置和 block 参数位置被移除。
            if index and values[index - 1] in ('=', '[', ','):
                canonical.append(('location', 'value'))
            excluded.update(range(index, end))
            index = end
        else:
            token = tokens[index]
            canonical.append(
                ('location', 'value') if token.kind == 'word' and token.value in aliases else (token.kind, token.value)
            )
            index += 1

    # 位置归一化与操作识别分开：普通字符串属性仍须完整保留在结构指纹中。
    operations: list[IRInstruction] = []
    operation_ranges: dict[int, int] = {}
    region_ranges: list[tuple[int, int]] = []
    modules: list[tuple[int, int, str]] = []
    for index, token in enumerate(tokens):
        if index in excluded or token.kind != 'string' or index + 1 >= len(tokens) or values[index + 1] != '(':
            continue
        check()
        if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_.$-]*\.[A-Za-z0-9_.$-]+', token.value):
            raise _unsupported('需要带引号的 generic operation 名称', line=token.line)
        operand_end = matching[index + 1]
        operands = []
        for first, last in _split(tokens, index + 2, operand_end, matching):
            if last != first + 1 or not values[first].startswith('%'):
                raise _unsupported('generic operation 的实参形状不受支持', line=token.line)
            operands.append(values[first])
        cursor = operand_end + 1
        regions = []
        while cursor < len(tokens) and values[cursor] != ':':
            if cursor not in matching:
                raise _unsupported('generic operation 头部不受支持', line=token.line)
            end = matching[cursor]
            if values[cursor] == '(' and cursor + 1 < end and values[cursor + 1] == '{':
                for first, last_region in _split(tokens, cursor + 1, end, matching):
                    if values[first] != '{' or matching.get(first) != last_region - 1:
                        raise _unsupported('generic region 列表不受支持', line=token.line)
                    regions.append((first + 1, last_region - 1))
            cursor = end + 1
        if cursor + 1 >= len(tokens) or values[cursor + 1] != '(':
            raise _unsupported('generic operation 缺少函数类型', line=token.line)
        type_end = matching[cursor + 1] + 1
        if type_end + 1 >= len(tokens) or values[type_end] != '->':
            raise _unsupported('generic operation 函数类型不受支持', line=token.line)
        last = type_end + 1
        if values[last] == '(':
            last = matching[last] + 1
        else:
            if tokens[last].kind != 'word':
                raise _unsupported('generic operation 结果类型不受支持', line=token.line)
            last += 1
            if last < len(tokens) and values[last] == '<':
                last = matching[last] + 1
        loc = None
        if last in loc_spans:
            end = loc_spans[last]
            loc = locations[last]
            last = end
        results = []
        operation_start = index
        if index and values[index - 1] == '=':
            first = index - 2
            while first > 0 and tokens[first - 1].line == token.line:
                first -= 1
            operation_start = first
            for start, end in _split(tokens, first, index - 1, matching):
                if not values[start].startswith('%'):
                    raise _unsupported('generic operation 结果标识不受支持', line=token.line)
                if end == start + 1:
                    results.append(values[start])
                elif end == start + 3 and values[start + 1] == ':' and values[start + 2].isdigit():
                    count = int(values[start + 2])
                    if not 0 < count <= budget.max_ast_nodes:
                        raise _unsupported('generic 多结果数量超过支持范围')
                    results.extend(f'{values[start]}#{number}' for number in range(count))
                else:
                    raise _unsupported('generic 多结果形状不受支持', line=token.line)
        operation_ranges[operation_start] = last
        region_ranges.extend(regions)
        if token.value == 'hw.module':
            names = [
                values[pos + 2]
                for pos in range(operand_end + 1, cursor - 2)
                if values[pos : pos + 2] == ['sym_name', '='] and tokens[pos + 2].kind == 'string'
            ]
            if len(names) != 1:
                raise _unsupported('hw.module 缺少唯一 sym_name', line=token.line)
            modules.append((index, last, names[0]))
        operations.append(
            IRInstruction(
                len(operations),
                None,
                token.value,
                tuple(results),
                tuple(operands),
                token.line,
                token.column,
                tokens[last - 1].line,
                loc,
                index,
                last,
                tuple(regions),
            )
        )
    if not operations or operations[0].name != 'builtin.module':
        raise _unsupported('需要包含 builtin.module 的 generic IR')
    root = operations[0]
    for position in range(len(tokens)):
        if not root.start_token <= position < root.end_token and position not in omitted:
            raise _unsupported('builtin.module 之外存在未解析内容', line=tokens[position].line)
    # 每个 region 必须被操作或 block 标记完整消费，不能静默跳过未知指令。
    for first, last in region_ranges:
        cursor = first
        while cursor < last:
            check()
            if cursor in operation_ranges:
                cursor = operation_ranges[cursor]
            elif tokens[cursor].kind == 'word' and values[cursor].startswith('^'):
                cursor += 1
                if cursor < last and values[cursor] == '(':
                    cursor = matching[cursor] + 1
                if cursor >= last or values[cursor] != ':':
                    raise _unsupported('generic block 标记不受支持')
                cursor += 1
            else:
                raise _unsupported('generic region 中存在未解析内容', line=tokens[cursor].line)
    # 嵌套模块取包含操作的最小区间，使重复 SSA 名始终在正确模块内匹配。
    bound = []
    for operation in operations:
        candidates = [(end - start, name) for start, end, name in modules if start <= operation.start_token < end]
        module = min(candidates)[1] if candidates else None
        bound.append(replace(operation, module_symbol=module))
    return GenericIR(tuple(canonical), tuple(bound), tuple(text.splitlines()))


@dataclass
class SourceIndex:
    execution_ir: ArtifactRef
    ir: GenericIR | None = None
    debug: GenericIR | None = None
    precision: SourcePrecision = 'ir_only'
    issues: list[StopReason] = field(default_factory=list)
    source_files: dict[str, ArtifactRef] = field(default_factory=dict)
    source_texts: dict[str, tuple[str, ...]] = field(default_factory=dict)
    source_errors: dict[str, SourcePrecision] = field(default_factory=dict)
    artifact_paths: dict[str, Path] = field(default_factory=dict)

    def _ir_location(
        self, precision: SourcePrecision, instruction: IRInstruction | None = None, raw: str | None = None
    ) -> SourceLocation:
        """构造指向执行 IR 的降级位置，保留已知操作行列及未成功解析的原始位置描述。"""
        return SourceLocation(
            precision=precision,
            source=self.execution_ir,
            line=instruction.line if instruction else None,
            column=instruction.column if instruction else None,
            end_line=instruction.end_line if instruction else None,
            raw_location=raw,
        )

    def match(
        self,
        module_symbol: str | None,
        result_ssa: str | None = None,
        *,
        operation_name: str | None = None,
        operands: tuple[str, ...] | None = None,
        ordinal: int | None = None,
    ) -> IRInstruction | None:
        """按模块和已提供的结果、操作名、实参或序号约束寻找唯一执行 IR 操作。

        未解析 IR、无候选或多候选均返回 None，不依赖遍历顺序消除歧义。
        """
        if self.ir is None:
            return None
        candidates = [
            operation
            for operation in self.ir.operations
            if operation.module_symbol == module_symbol
            and (result_ssa is None or result_ssa in operation.results)
            and (operation_name is None or operation.name == operation_name)
            and (operands is None or operation.operands == operands)
            and (ordinal is None or operation.ordinal == ordinal)
        ]
        return candidates[0] if len(candidates) == 1 else None

    def locations(
        self,
        module_symbol: str | None,
        result_ssa: str | None = None,
        *,
        operation_name: str | None = None,
        operands: tuple[str, ...] | None = None,
        ordinal: int | None = None,
    ) -> tuple[SourceLocation, ...]:
        """为唯一匹配的执行 IR 操作返回源码候选，缺少依据时返回注明精度的 IR 位置。

        只有结构已核验的 debug IR 才按相同操作序号提供源码 location；缺位置信息显式标为 unknown。
        """
        instruction = self.match(
            module_symbol, result_ssa, operation_name=operation_name, operands=operands, ordinal=ordinal
        )
        if instruction is None:
            return (
                self._ir_location(
                    self.precision if self.debug is None else 'mapping_mismatch', raw='没有唯一匹配的执行 IR operation'
                ),
            )
        if self.debug is None:
            return (self._ir_location(self.precision, instruction),)
        location = self.debug.operations[instruction.ordinal].location
        if location is None:
            return (self._ir_location('unknown', instruction, '该 operation 未保存源码位置'),)
        return self._locations(location, instruction)

    def for_operation(self, operation: Operation) -> tuple[SourceLocation, ...]:
        """把运行拓扑操作转换成源码检索条件，无 SSA 结果的过程额外使用实参序列消除歧义。"""
        operands = None if operation.result_ssa else tuple(value.rsplit('/', 1)[-1] for value in operation.operands)
        return self.locations(
            operation.module_symbol, operation.result_ssa, operation_name=operation.name, operands=operands
        )

    def _locations(
        self, location: _Location, instruction: IRInstruction, fused: bool = False
    ) -> tuple[SourceLocation, ...]:
        """展开 fused 位置并校验绑定源文件与坐标，返回带真实定位精度的候选元组。

        缺失、损坏或越界时保留降级原因；源码列按 UTF-8 字节长度检查。声明和简单输出别名
        使用 declaration 精度，fused 子位置保留 fused 标记，均不升级为根因结论。
        """
        if location.kind == 'fused':
            return tuple(item for child in location.children for item in self._locations(child, instruction, True)) or (
                self._ir_location('unknown', instruction, location.raw),
            )
        if location.kind == 'unknown':
            return (self._ir_location('unknown', instruction, location.raw),)
        source = self.source_files.get(location.file or '')
        if source is None:
            return (
                SourceLocation(
                    precision='source_missing',
                    line=location.line,
                    column=location.column,
                    raw_location=f'{location.file}: {location.raw}',
                ),
            )
        if source.path in self.source_errors:
            return (self._ir_location(self.source_errors[source.path], instruction, location.raw),)
        lines = self.source_texts[source.path]
        assert location.line is not None and location.column is not None
        end_line, end_column = location.end_line or location.line, location.end_column or location.column
        if (
            end_line > len(lines)
            or location.column > len(lines[location.line - 1].encode()) + 1
            or (end_column > len(lines[end_line - 1].encode()) + 1)
        ):
            return (self._ir_location('mapping_mismatch', instruction, '源码位置超出绑定文件范围：' + location.raw),)
        # 这里标注声明/简单输出别名的位置，避免包装成精确运算根因行。
        line = lines[location.line - 1].strip()
        declaration = bool(
            re.match(r'(?:module|input|output|inout|reg|logic|integer|parameter|localparam|typedef)\b', line)
            or re.fullmatch(r'assign\s+[A-Za-z_$][\w$]*\s*=\s*[A-Za-z_$][\w$]*\s*;\s*(?://.*)?', line)
            or re.match(r'wire\b[^=;]*;', line)
        )
        precision: SourcePrecision = 'fused' if fused else 'declaration' if declaration else 'exact'
        return (
            SourceLocation(
                precision=precision,
                source=source,
                line=location.line,
                column=location.column,
                end_line=location.end_line,
                end_column=location.end_column,
                raw_location=location.raw,
            ),
        )


def bind_sources(
    run: RunArtifacts, binding: SourceBinding | Path | str | None = None, *, base_dir: Path | None = None
) -> SourceIndex:
    """为本次运行校验执行 IR、debug IR 与源码绑定，构造可降级的源码索引。

    各引用相对其承载 JSON 解析，并核对哈希、完整 IR 结构及可选 source-map 操作记录。
    普通绑定失败保留已解析的执行 IR 和原因；单个源码失败单独降级，超时则直接向上传播。
    """
    execution = [ref for ref in run.manifest.artifacts.values() if ref.role == 'execution_ir']
    if len(execution) != 1:
        raise TraceError(StopCode.MISSING_ARTIFACT, '运行需要唯一 execution_ir 才能定位 IR')
    result = SourceIndex(execution[0])
    carrier = (base_dir / 'source-binding.json') if base_dir else run.path

    def check() -> None:
        """检查源码绑定与运行读取器共享的截止时间，超时中止整个绑定过程。"""
        if time.monotonic() >= run.reader.deadline:
            raise TraceError(StopCode.TIME_BUDGET, '源码绑定已到查询截止时间')

    def read(ref: ArtifactRef, parent: Path) -> str:
        """读取已解析引用的未压缩 UTF-8 工件，限制字节数并复核读取后大小与哈希。

        成功核验的本地路径登记到索引，供后续报告引用重定位或证据复制使用。
        """
        check()
        if ref.compression != 'none':
            raise _unsupported('源码绑定只接受未压缩的文本工件', role=ref.role)
        path = run.resolve(ref, carrier=parent)
        with path.open('rb') as stream:
            data = stream.read(run.reader.budget.max_state_bytes + 1)
        check()
        if len(data) > run.reader.budget.max_state_bytes:
            raise _unsupported('源码工件超过单文件读取预算', role=ref.role)
        if len(data) != ref.size_bytes or hashlib.sha256(data).hexdigest() != ref.sha256:
            raise TraceError(StopCode.HASH_MISMATCH, '源码工件在读取期间发生变化', role=ref.role)
        result.artifact_paths[ref.sha256] = path
        return data.decode('utf-8')

    def unique(items: list[tuple[str, Any]]) -> dict[str, Any]:
        """作为 JSON 对象钩子拒绝 source-map 重复字段，避免后值覆盖校验依据。"""
        result = {}
        for key, value in items:
            if key in result:
                raise TraceError(StopCode.SOURCE_MISMATCH, 'source-map 含重复字段', field=key)
            result[key] = value
        return result

    def map_results(raw: Any, count: int) -> tuple[str, ...]:
        """解析 source-map 的逗号分隔 SSA 结果，展开受结果数约束的多结果缩写。"""
        if not isinstance(raw, str):
            raise TraceError(StopCode.SOURCE_MISMATCH, 'source-map SSA 字段必须是字符串')
        names = []
        for part in raw.split(',') if raw else []:
            match = re.fullmatch(r'(%[A-Za-z0-9_.$-]+(?:#[0-9]+)?)(?:\s*:\s*([1-9][0-9]*))?', part.strip())
            if match is None:
                raise TraceError(StopCode.SOURCE_MISMATCH, 'source-map SSA 形状不受支持')
            if match[2] is None:
                names.append(match[1])
            else:
                arity = int(match[2])
                if arity > count:
                    raise TraceError(StopCode.SOURCE_MISMATCH, 'source-map SSA 结果数量不一致')
                names.extend(f'{match[1]}#{number}' for number in range(arity))
        return tuple(names)

    try:
        result.ir = parse_generic(read(execution[0], run.path), run.reader.budget, check=check)
        if binding is None:
            return result
        if isinstance(binding, (str, Path)):
            carrier = Path(binding).absolute()
            with carrier.open('rb') as stream:
                contents = stream.read(run.reader.budget.max_state_bytes + 1)
            if len(contents) > run.reader.budget.max_state_bytes:
                raise _unsupported('SourceBinding 超过单文件读取预算')
            binding = SourceBinding.from_json(contents.decode('utf-8'))
        if binding.run_id != run.manifest.run_id or binding.execution_ir.sha256 != execution[0].sha256:
            raise TraceError(StopCode.SOURCE_MISMATCH, 'SourceBinding 与当前执行运行身份不一致')
        read(binding.execution_ir, carrier)
        if binding.debug_ir is None:
            return result
        debug = parse_generic(read(binding.debug_ir, carrier), run.reader.budget, check=check)
        # 只有去除位置后的完整结构相同，两个文件的操作序号才可用于一一对应。
        if result.ir.structure != debug.structure:
            raise TraceError(StopCode.SOURCE_MISMATCH, '执行和 debug IR 去除位置后的完整结构不一致')
        if len(result.ir.operations) != len(debug.operations):
            raise TraceError(StopCode.SOURCE_MISMATCH, '执行和 debug IR operation 身份无法一一对应')
        mapping: dict[str, Any] = {}
        if binding.source_map is not None:
            mapping = json.loads(read(binding.source_map, carrier), object_pairs_hook=unique)
            if (
                not isinstance(mapping, dict)
                or type(mapping.get('schema_version', 1)) is not int
                or mapping.get('schema_version', 1) != 1
                or mapping.get('executable_sha256') != execution[0].sha256
                or mapping.get('debug_sha256') != binding.debug_ir.sha256
            ):
                raise TraceError(StopCode.SOURCE_MISMATCH, 'source-map 没有绑定相同执行和 debug IR 哈希')
            if 'operations' in mapping:
                operations = mapping['operations']
                if not isinstance(operations, list) or len(operations) != len(debug.operations):
                    raise TraceError(StopCode.SOURCE_MISMATCH, 'source-map operation 数量不一致')
                for record, left, right in zip(operations, result.ir.operations, debug.operations, strict=True):
                    if (
                        not isinstance(record, dict)
                        or type(record.get('ordinal')) is not int
                        or record.get('ordinal') != left.ordinal
                        or record.get('op') != left.name
                        or record.get('executable_line') != left.line
                        or record.get('debug_line') != right.line
                        or record.get('debug_text') != debug.lines[right.line - 1]
                    ):
                        raise TraceError(StopCode.SOURCE_MISMATCH, 'source-map operation 与真实 IR 记录不一致')
                    if 'ssa' in record and map_results(record['ssa'], len(left.results)) != left.results:
                        raise TraceError(StopCode.SOURCE_MISMATCH, 'source-map SSA 与执行 IR 不一致')
        references = {ref.path: ref for ref in binding.sources}
        if len(references) != len(binding.sources):
            raise TraceError(StopCode.SOURCE_MISMATCH, 'SourceBinding sources 包含重复路径')
        source_files = mapping.get('source_files', {})
        if not isinstance(source_files, dict) or any(
            not isinstance(key, str) or not isinstance(value, str) or value not in references
            for key, value in source_files.items()
        ):
            raise TraceError(StopCode.SOURCE_MISMATCH, 'source_files 必须显式引用已绑定的 sources 路径')
        result.source_files = {ref.path: ref for ref in binding.sources}
        result.source_files.update({name: references[path] for name, path in source_files.items()})
        # 单个源码损坏不丢弃其他已核验位置；截止时间则属于整个查询的停止条件。
        for ref in binding.sources:
            try:
                result.source_texts[ref.path] = tuple(read(ref, carrier).splitlines())
            except TraceError as error:
                if error.code == StopCode.TIME_BUDGET:
                    raise
                result.issues.append(StopReason(error.code, error.message, error.details))
                result.source_errors[ref.path] = (
                    'source_missing' if error.code == StopCode.MISSING_ARTIFACT else 'mapping_mismatch'
                )
        result.debug = debug
        result.precision = 'exact'
    except (TraceError, OSError, ValueError) as error:
        if isinstance(error, TraceError) and error.code == StopCode.TIME_BUDGET:
            raise
        result.debug = None
        code = error.code if isinstance(error, TraceError) else StopCode.SOURCE_MISMATCH
        result.precision = 'unsupported_format' if code == StopCode.UNSUPPORTED_SHAPE else 'mapping_mismatch'
        result.issues.append(StopReason(code, str(error), error.details if isinstance(error, TraceError) else {}))
    return result
