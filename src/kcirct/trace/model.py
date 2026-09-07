"""离线 trace 共用的数据、身份、资源限制和停止原因契约。"""

from __future__ import annotations

import json
import math
import re
import types
from dataclasses import MISSING, dataclass, field, fields
from enum import Enum
from pathlib import PurePosixPath
from typing import Any, Literal, TypeVar, Union, get_args, get_origin, get_type_hints

SCHEMA_VERSION = 1
_Model = TypeVar('_Model', bound='JsonModel')
_HINTS: dict[type, dict[str, Any]] = {}


def _hints(model: type) -> dict[str, Any]:
    if model not in _HINTS:
        _HINTS[model] = get_type_hints(model)
    return _HINTS[model]


class StopCode(str, Enum):
    """CLI、Python、解析 worker 和报告共用的稳定停止码。"""

    INVALID_INPUT = 'invalid_input'
    UNSUPPORTED_SCHEMA = 'unsupported_schema'
    INVALID_BUDGET = 'invalid_budget'
    NODE_BUDGET = 'node_budget'
    STATE_BUDGET = 'state_budget'
    TIME_BUDGET = 'time_budget'
    STATE_BYTES_BUDGET = 'state_bytes_budget'
    READ_BYTES_BUDGET = 'read_bytes_budget'
    CACHE_BYTES_BUDGET = 'cache_bytes_budget'
    AST_NODES_BUDGET = 'ast_nodes_budget'
    AST_DEPTH_BUDGET = 'ast_depth_budget'
    MISSING_ARTIFACT = 'missing_artifact'
    HASH_MISMATCH = 'hash_mismatch'
    IDENTITY_MISMATCH = 'identity_mismatch'
    DUPLICATE_IDENTITY = 'duplicate_identity'
    INCOMPLETE_EXECUTION = 'incomplete_execution'
    METADATA_CORRUPTION = 'metadata_corruption'
    INCONSISTENT_EVIDENCE = 'inconsistent_evidence'
    NOT_RETAINED = 'not_retained'
    HISTORY_GAP = 'history_gap'
    WINDOW_BOUNDARY = 'window_boundary'
    INITIALIZATION = 'initialization'
    MISSING_VALUE = 'missing_value'
    AMBIGUOUS_TARGET = 'ambiguous_target'
    AMBIGUOUS_OBSERVATION = 'ambiguous_observation'
    OBSERVATION_MISMATCH = 'observation_mismatch'
    UNSUPPORTED_OPERATION = 'unsupported_operation'
    UNSUPPORTED_SHAPE = 'unsupported_shape'
    UNSUPPORTED_SEMANTICS = 'unsupported_semantics'
    UNSUPPORTED_MEMORY_ORDER = 'unsupported_memory_order'
    UNSUPPORTED_CLOCK = 'unsupported_clock'
    UNSUPPORTED_INITIALIZATION = 'unsupported_initialization'
    UNSUPPORTED_VALUE = 'unsupported_value'
    SOURCE_MISMATCH = 'source_mismatch'
    CYCLE = 'cycle'
    INTERNAL_ERROR = 'internal_error'
    UNKNOWN = 'unknown'


class TraceError(ValueError):
    """保留机器可判定的原因，异常文字只用于中文诊断。"""

    def __init__(self, code: StopCode | str, message: str, **details: Any):
        self.code = StopCode(code)
        self.message = message
        self.details = details
        super().__init__(message)


def _invalid(message: str) -> TraceError:
    return TraceError(StopCode.INVALID_INPUT, message)


def _json_value(value: Any) -> Any:
    if value is None or type(value) in (str, int, bool):
        return value
    if type(value) is float and math.isfinite(value):
        return value
    if isinstance(value, JsonModel):
        return value.to_dict()
    if isinstance(value, Enum):
        return value.value
    if isinstance(value, (list, tuple)):
        return [_json_value(item) for item in value]
    if isinstance(value, dict) and all(type(key) is str for key in value):
        return {key: _json_value(item) for key, item in value.items()}
    raise _invalid(f'不能无损表示为 JSON 的值：{type(value).__name__}')


def _decode(annotation: Any, value: Any, location: str) -> Any:
    origin, arguments = get_origin(annotation), get_args(annotation)
    if annotation is Any:
        return _json_value(value)
    if origin in (Union, types.UnionType):
        errors = []
        for alternative in arguments:
            try:
                return _decode(alternative, value, location)
            except TraceError as error:
                errors.append(error)
        for candidate_error in errors:
            if candidate_error.code != StopCode.INVALID_INPUT:
                raise candidate_error
        raise _invalid(f'{location} 的值类型不符合契约')
    if origin is Literal:
        if any(type(value) is type(item) and value == item for item in arguments):
            return value
        raise _invalid(f'{location} 必须为 {arguments} 之一')
    if origin in (tuple, list):
        if not isinstance(value, (tuple, list)):
            raise _invalid(f'{location} 必须是数组')
        if origin is tuple and len(arguments) > 1 and arguments[-1] is not Ellipsis:
            if len(value) != len(arguments):
                raise _invalid(f'{location} 数组长度不正确')
            decoded = [_decode(kind, item, location) for kind, item in zip(arguments, value, strict=True)]
        else:
            decoded = [_decode(arguments[0], item, location) for item in value]
        return tuple(decoded) if origin is tuple else decoded
    if origin is dict:
        if not isinstance(value, dict):
            raise _invalid(f'{location} 必须是对象')
        return {
            _decode(arguments[0], key, location): _decode(arguments[1], item, location) for key, item in value.items()
        }
    if isinstance(annotation, type) and issubclass(annotation, JsonModel):
        if isinstance(value, annotation):
            return value
        return annotation._from_dict(value, require_version=False)
    if isinstance(annotation, type) and issubclass(annotation, Enum):
        try:
            return annotation(value)
        except (ValueError, TypeError) as error:
            raise _invalid(f'{location} 包含未知代码 {value!r}') from error
    if annotation is float:
        if type(value) in (int, float) and math.isfinite(value):
            return value
        raise _invalid(f'{location} 必须是有限数值')
    if type(value) is annotation:
        return value
    raise _invalid(f'{location} 的值类型不符合契约')


@dataclass(frozen=True, kw_only=True)
class JsonModel:
    """所有公开 JSON 文档使用同一严格读取器；嵌套对象可省略版本。"""

    schema_version: int = SCHEMA_VERSION

    def __post_init__(self) -> None:
        if type(self.schema_version) is not int or self.schema_version != SCHEMA_VERSION:
            raise TraceError(StopCode.UNSUPPORTED_SCHEMA, f'不支持 schema_version={self.schema_version!r}')
        hints = _hints(type(self))
        for item in fields(self):
            # 构造器与 JSON 入口执行相同类型校验，冻结数组以免调用方随后修改它。
            object.__setattr__(self, item.name, _decode(hints[item.name], getattr(self, item.name), item.name))
        self._validate()

    def _validate(self) -> None:
        pass

    @classmethod
    def _from_dict(cls: type[_Model], document: Any, *, require_version: bool) -> _Model:
        if not isinstance(document, dict) or any(type(key) is not str for key in document):
            raise _invalid(f'{cls.__name__} 必须是 JSON 对象')
        if require_version and 'schema_version' not in document:
            raise TraceError(StopCode.UNSUPPORTED_SCHEMA, 'JSON 文档缺少 schema_version')
        if 'schema_version' in document and (
            type(document['schema_version']) is not int or document['schema_version'] != SCHEMA_VERSION
        ):
            raise TraceError(StopCode.UNSUPPORTED_SCHEMA, f'不支持 schema_version={document["schema_version"]!r}')
        definitions = {item.name: item for item in fields(cls)}
        unknown = set(document) - definitions.keys()
        if unknown:
            raise _invalid(f'{cls.__name__} 含未知字段：{sorted(unknown)}')
        missing = [
            name
            for name, item in definitions.items()
            if name not in document and item.default is MISSING and item.default_factory is MISSING
        ]
        if missing:
            raise _invalid(f'{cls.__name__} 缺少字段：{missing}')
        return cls(**document)

    @classmethod
    def from_dict(cls: type[_Model], document: dict[str, Any]) -> _Model:
        return cls._from_dict(document, require_version=True)

    @classmethod
    def from_json(cls: type[_Model], text: str) -> _Model:
        def unique_keys(items: list[tuple[str, Any]]) -> dict[str, Any]:
            result: dict[str, Any] = {}
            for key, value in items:
                if key in result:
                    raise _invalid(f'JSON 含重复字段：{key}')
                result[key] = value
            return result

        def invalid_constant(value: str) -> Any:
            raise _invalid(f'JSON 不允许非有限数：{value}')

        try:
            value = json.loads(text, object_pairs_hook=unique_keys, parse_constant=invalid_constant)
        except (json.JSONDecodeError, RecursionError) as error:
            raise _invalid(f'无法读取 JSON：{error}') from error
        return cls._from_dict(value, require_version=True)

    def to_dict(self) -> dict[str, Any]:
        return {item.name: _json_value(getattr(self, item.name)) for item in fields(self)}

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), ensure_ascii=False, indent=2, allow_nan=False) + '\n'


def _nonempty(value: str, name: str) -> None:
    if not value.strip():
        raise _invalid(f'{name} 不能为空')


def _nonnegative(value: int | None, name: str) -> None:
    if value is not None and value < 0:
        raise _invalid(f'{name} 不能小于零')


def _digest(value: str | None, name: str) -> None:
    if value is not None and re.fullmatch('[0-9a-f]{64}', value) is None:
        raise _invalid(f'{name} 必须是小写 SHA-256')


def _relative_path(value: str) -> None:
    if not value or PurePosixPath(value).is_absolute() or '\\' in value or '\x00' in value:
        raise _invalid('工件路径必须是相对于承载 JSON 的非空 POSIX 路径')


@dataclass(frozen=True)
class BitVector(JsonModel):
    width: int
    value: str

    def _validate(self) -> None:
        if self.width <= 0 or re.fullmatch(r'0|[1-9][0-9]*', self.value) is None:
            raise _invalid('位向量需要正位宽和规范无符号十进制字符串')
        if int(self.value).bit_length() > self.width:
            raise _invalid('位向量的值超过声明位宽')

    @property
    def unsigned(self) -> int:
        return int(self.value)

    @classmethod
    def from_int(cls, value: int, width: int) -> BitVector:
        if type(value) is not int:
            raise _invalid('位向量输入必须是整数')
        return cls(width=width, value=str(value))


@dataclass(frozen=True)
class BitRange(JsonModel):
    low: int
    high: int

    def _validate(self) -> None:
        if not 0 <= self.low <= self.high:
            raise _invalid('位范围应满足 0 <= low <= high（两端包含）')


@dataclass(frozen=True)
class ArtifactRef(JsonModel):
    role: str
    path: str
    sha256: str
    size_bytes: int
    compression: Literal['none', 'gzip'] = 'none'
    uncompressed_sha256: str | None = None
    uncompressed_size_bytes: int | None = None

    def _validate(self) -> None:
        _nonempty(self.role, 'role')
        _relative_path(self.path)
        _digest(self.sha256, 'sha256')
        _digest(self.uncompressed_sha256, 'uncompressed_sha256')
        _nonnegative(self.size_bytes, 'size_bytes')
        _nonnegative(self.uncompressed_size_bytes, 'uncompressed_size_bytes')
        if self.compression == 'gzip' and self.uncompressed_sha256 is None:
            raise _invalid('gzip 工件必须绑定未压缩内容 SHA-256')


@dataclass(frozen=True)
class RecordRef(JsonModel):
    path: str
    id: str | None = None
    sha256: str | None = None

    def _validate(self) -> None:
        _relative_path(self.path)
        _digest(self.sha256, 'sha256')


@dataclass(frozen=True)
class PortSpec(JsonModel):
    name: str
    direction: Literal['input', 'output']
    width: int
    aliases: tuple[str, ...] = ()

    def _validate(self) -> None:
        _nonempty(self.name, 'name')
        if self.width <= 0:
            raise _invalid('端口位宽必须为正整数')


@dataclass(frozen=True)
class CompletionEvidence(JsonModel):
    status: Literal['not_checked', 'completed', 'incomplete', 'unknown'] = 'not_checked'
    evidence: tuple[RecordRef, ...] = ()
    details: dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class StateIndexEntry(JsonModel):
    state_id: str
    phase: Literal['setup', 'post_eval']
    predecessor: str | None = None
    event_index: int | None = None
    evaluation: int | None = None
    time: int | None = None
    time_unit: str | None = None
    artifact: str | None = None
    content_sha256: str | None = None
    retention: Literal['retained', 'not_retained', 'missing'] = 'not_retained'
    completion: CompletionEvidence = field(default_factory=CompletionEvidence)

    def _validate(self) -> None:
        _nonempty(self.state_id, 'state_id')
        _digest(self.content_sha256, 'content_sha256')
        _nonnegative(self.event_index, 'event_index')
        _nonnegative(self.time, 'time')
        if self.phase == 'setup':
            if self.event_index is not None or self.evaluation is not None or self.predecessor is not None:
                raise _invalid('setup 是独立状态，不能填写 event、evaluation 或前驱')
        elif self.event_index is None or self.evaluation is None or self.evaluation <= 0:
            raise _invalid('post_eval 必须声明非负 event_index 和从 1 开始的 evaluation')
        if (self.time is None) != (self.time_unit is None):
            raise _invalid('time 与 time_unit 必须同时声明')
        if self.retention == 'retained' and self.artifact is None:
            raise _invalid('retained 状态必须绑定独立工件')
        if self.artifact is not None:
            _nonempty(self.artifact, 'artifact')
        if self.retention == 'not_retained' and self.artifact is not None:
            raise _invalid('not_retained 状态不能登记可读工件')


@dataclass(frozen=True)
class DumpIndexEntry(JsonModel):
    dump_id: str
    state_id: str
    event_index: int
    evaluation: int
    time: int
    time_unit: str
    values: dict[str, BitVector] = field(default_factory=dict)
    artifact: ArtifactRef | None = None
    phase: Literal['dump'] = 'dump'

    def _validate(self) -> None:
        _nonempty(self.dump_id, 'dump_id')
        _nonempty(self.state_id, 'state_id')
        _nonnegative(self.event_index, 'event_index')
        _nonnegative(self.time, 'time')
        _nonempty(self.time_unit, 'time_unit')
        if self.evaluation <= 0:
            raise _invalid('dump 必须绑定真实的、从 1 开始的 evaluation')


@dataclass(frozen=True)
class RunManifest(JsonModel):
    run_id: str
    top_module: str
    artifacts: dict[str, ArtifactRef] = field(default_factory=dict)
    ports: tuple[PortSpec, ...] = ()
    protocol: dict[str, Any] = field(default_factory=lambda: {'status': 'unknown'})
    identities: dict[str, Any] = field(default_factory=lambda: {'status': 'unknown'})
    parameters: dict[str, Any] = field(default_factory=lambda: {'status': 'unknown'})
    initialization: dict[str, Any] = field(default_factory=lambda: {'status': 'unknown'})
    commands: tuple[tuple[str, ...], ...] = ()
    state_index: ArtifactRef | None = None
    state_coverage: dict[str, Any] = field(default_factory=lambda: {'status': 'unknown'})
    completion: CompletionEvidence = field(default_factory=CompletionEvidence)
    origin: RecordRef | None = None
    origin_description: str | None = None

    def _validate(self) -> None:
        _nonempty(self.run_id, 'run_id')
        _nonempty(self.top_module, 'top_module')
        if len({item.path for item in self.artifacts.values()}) != len(self.artifacts):
            raise TraceError(StopCode.DUPLICATE_IDENTITY, 'manifest 存在重复工件路径')
        if len({item.name for item in self.ports}) != len(self.ports):
            raise TraceError(StopCode.DUPLICATE_IDENTITY, 'manifest 存在重复端口名')


@dataclass(frozen=True)
class Observation(JsonModel):
    phase: Literal['setup', 'post_eval', 'dump']
    event_index: int | None = None
    evaluation: int | None = None
    time: int | None = None
    time_unit: str | None = None
    sample: int | None = None
    state_id: str | None = None
    dump_id: str | None = None

    def _validate(self) -> None:
        for name in ('event_index', 'time', 'sample'):
            _nonnegative(getattr(self, name), name)
        if (self.time is None) != (self.time_unit is None):
            raise _invalid('time 与 time_unit 必须同时声明')
        if self.evaluation is not None and self.evaluation <= 0:
            raise _invalid('evaluation 从 1 开始')
        if self.phase == 'setup' and (self.event_index is not None or self.evaluation is not None):
            raise _invalid('setup 观测不能声明 event 或 evaluation')
        if self.phase == 'post_eval' and self.evaluation is None:
            raise _invalid('post_eval 观测必须声明 evaluation')
        if self.phase != 'setup' and all(
            value is None for value in (self.event_index, self.time, self.sample, self.state_id, self.dump_id)
        ):
            raise _invalid('观测必须提供 event、time、sample 或绑定状态身份')
        if self.phase != 'dump' and self.dump_id is not None:
            raise _invalid('dump_id 仅用于 dump 观测')


@dataclass(frozen=True)
class ObservationMap(JsonModel):
    run_id: str
    entries: tuple[Observation, ...]
    signals: tuple[PortSpec, ...]
    sampling_contract: dict[str, Any]
    columns: dict[str, str] = field(default_factory=dict)
    comparison_masks: dict[str, BitVector] = field(default_factory=dict)

    def _validate(self) -> None:
        _nonempty(self.run_id, 'run_id')


@dataclass(frozen=True)
class Target(JsonModel):
    kind: Literal['signal', 'register', 'memory_cell', 'memory_write_port']
    name: str | None = None
    target_id: str | None = None
    address: str | None = None
    bit_range: BitRange | None = None

    def _validate(self) -> None:
        if not self.name and not self.target_id:
            raise _invalid('目标必须指定 name 或 target_id')
        if self.kind == 'memory_cell':
            if self.address is None or re.fullmatch(r'0|[1-9][0-9]*', self.address) is None:
                raise _invalid('memory_cell 必须指定无损非负十进制 address 字符串')
        elif self.address is not None:
            raise _invalid('只有 memory_cell 目标能指定 address')


@dataclass(frozen=True)
class CheckSource(JsonModel):
    kind: Literal['csv', 'vcd', 'property', 'scoreboard', 'manual', 'unknown'] = 'unknown'
    identity: dict[str, Any] = field(default_factory=lambda: {'status': 'unknown'})
    configuration: dict[str, Any] = field(default_factory=dict)
    record: RecordRef | None = None
    generation_method: str = 'unknown'


@dataclass(frozen=True)
class CheckRecord(JsonModel):
    id: str
    run_id: str
    kind: Literal['value_mismatch', 'property_failure', 'suspicious_observation']
    targets: tuple[Target, ...]
    observation: Observation
    source: CheckSource = field(default_factory=CheckSource)
    expected: BitVector | None = None
    actual: BitVector | None = None
    comparison_mask: BitVector | None = None
    predicate: str | None = None
    predicate_interpretation: Literal['violation', 'requirement'] | None = None
    predicate_result: bool | None = None
    premises: tuple[str, ...] = ()

    def _validate(self) -> None:
        _nonempty(self.id, 'id')
        _nonempty(self.run_id, 'run_id')
        if not self.targets:
            raise _invalid('检查必须关联至少一个目标')
        if self.kind == 'value_mismatch':
            if self.expected is None or self.actual is None:
                raise _invalid('value_mismatch 必须包含 expected 和 actual')
            if self.expected.width != self.actual.width:
                raise _invalid('expected 与 actual 位宽不一致')
            mask = self.comparison_mask
            if mask is not None and mask.width != self.actual.width:
                raise _invalid('比较掩码位宽不一致')
            difference = self.expected.unsigned ^ self.actual.unsigned
            if not (difference if mask is None else difference & mask.unsigned):
                raise _invalid('value_mismatch 必须在声明掩码内确有差异')
        elif self.expected is not None or self.comparison_mask is not None:
            raise _invalid('性质失败和可疑观测不填写精确 expected 或比较掩码')
        if self.kind == 'property_failure':
            if not self.predicate or self.predicate_interpretation is None or self.predicate_result is None:
                raise _invalid('property_failure 必须保留原谓词、解释方式和测试侧结果')
            if self.predicate_result != (self.predicate_interpretation == 'violation'):
                raise _invalid('谓词结果没有表达性质失败')
        elif any(value is not None for value in (self.predicate, self.predicate_interpretation, self.predicate_result)):
            raise _invalid('只有 property_failure 可以包含谓词结果')


@dataclass(frozen=True)
class Budget(JsonModel):
    max_nodes: int = 10_000
    max_states: int = 1_024
    max_seconds: float = 60
    max_state_bytes: int = 64 * 1024 * 1024
    max_read_bytes: int = 2 * 1024 * 1024 * 1024
    max_cache_bytes: int = 128 * 1024 * 1024
    max_ast_nodes: int = 2_000_000
    max_ast_depth: int = 4_096

    def __post_init__(self) -> None:
        try:
            super().__post_init__()
        except TraceError as error:
            if error.code == StopCode.INVALID_INPUT:
                raise TraceError(StopCode.INVALID_BUDGET, error.message) from error
            raise

    def _validate(self) -> None:
        for item in fields(self):
            if item.name != 'schema_version' and getattr(self, item.name) <= 0:
                raise TraceError(StopCode.INVALID_BUDGET, f'{item.name} 必须大于零')


QueryBudget = Budget


@dataclass(frozen=True)
class QueryWindow(JsonModel):
    first_event: int | None = None
    last_event: int | None = None

    def _validate(self) -> None:
        _nonnegative(self.first_event, 'first_event')
        _nonnegative(self.last_event, 'last_event')
        if self.first_event is not None and self.last_event is not None and self.first_event > self.last_event:
            raise _invalid('窗口 first_event 不能晚于 last_event')


@dataclass(frozen=True)
class QueryRequest(JsonModel):
    target: Target
    observation: Observation
    check: RecordRef | None = None
    window: QueryWindow = field(default_factory=QueryWindow)
    budget: Budget = field(default_factory=Budget)


@dataclass(frozen=True)
class ValueRef(JsonModel):
    run_id: str
    state_id: str
    instance: str
    operation: str
    result: str
    view: Literal['observed', 'operand', 'committed', 'prior']
    address: str | None = None
    bit_range: BitRange | None = None

    def _validate(self) -> None:
        for name in ('run_id', 'state_id', 'instance', 'operation', 'result'):
            _nonempty(getattr(self, name), name)
        if self.address is not None and re.fullmatch(r'0|[1-9][0-9]*', self.address) is None:
            raise _invalid('地址必须为无损非负十进制字符串')


SourcePrecision = Literal[
    'exact', 'declaration', 'fused', 'unknown', 'source_missing', 'mapping_mismatch', 'unsupported_format', 'ir_only'
]


@dataclass(frozen=True)
class SourceLocation(JsonModel):
    precision: SourcePrecision
    source: ArtifactRef | None = None
    line: int | None = None
    column: int | None = None
    end_line: int | None = None
    end_column: int | None = None
    raw_location: str | None = None

    def _validate(self) -> None:
        for name in ('line', 'column', 'end_line', 'end_column'):
            value = getattr(self, name)
            if value is not None and value <= 0:
                raise _invalid(f'{name} 从 1 开始')
        if self.precision == 'exact' and (self.source is None or self.line is None):
            raise _invalid('精确源码位置必须绑定源文件与行号')


@dataclass(frozen=True)
class SourceBinding(JsonModel):
    run_id: str
    execution_ir: ArtifactRef
    debug_ir: ArtifactRef | None = None
    source_map: ArtifactRef | None = None
    sources: tuple[ArtifactRef, ...] = ()

    def _validate(self) -> None:
        _nonempty(self.run_id, 'run_id')
        for item, role in (
            (self.execution_ir, 'execution_ir'),
            (self.debug_ir, 'debug_ir'),
            (self.source_map, 'source_map'),
        ):
            if item is not None and item.role != role:
                raise _invalid(f'{role} 的工件角色必须为 {role}')
        if any(item.role not in {'source', 'rtl'} for item in self.sources):
            raise _invalid('sources 的工件角色必须为 source 或 rtl')


@dataclass(frozen=True)
class StopReason(JsonModel):
    code: StopCode
    message: str
    details: dict[str, Any] = field(default_factory=dict)

    def _validate(self) -> None:
        _nonempty(self.message, 'message')


@dataclass(frozen=True)
class TraceNode(JsonModel):
    id: str
    ref: ValueRef
    value: BitVector | None = None
    type: str | None = None
    operation_name: str | None = None
    attributes: dict[str, Any] = field(default_factory=dict)
    observation: Observation | None = None
    locations: tuple[SourceLocation, ...] = ()
    evidence: tuple[RecordRef, ...] = ()
    facts: dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class TraceEdge(JsonModel):
    source: str
    target: str
    kind: Literal['data', 'control', 'alias', 'prior_state', 'capture', 'write', 'static_candidate']
    label: str | None = None
    evidence: tuple[RecordRef, ...] = ()


@dataclass(frozen=True)
class Frontier(JsonModel):
    reason: StopReason
    node_id: str | None = None
    ref: ValueRef | None = None


@dataclass(frozen=True)
class StatusAxes(JsonModel):
    execution: Literal['unknown', 'not_checked', 'completed', 'incomplete', 'failed'] = 'not_checked'
    design_check: Literal['unknown', 'not_run', 'passed', 'failed', 'not_applicable'] = 'not_run'
    reference_comparison: Literal['unknown', 'not_run', 'matched', 'mismatched', 'not_applicable'] = 'not_run'
    metadata_integrity: Literal['unknown', 'not_checked', 'valid', 'invalid', 'partial'] = 'not_checked'
    query: Literal['not_run', 'complete', 'partial', 'rejected', 'error'] = 'not_run'


@dataclass(frozen=True)
class QueryCost(JsonModel):
    elapsed_seconds: float = 0
    nodes: int = 0
    states_read: int = 0
    read_bytes: int = 0
    peak_cache_bytes: int = 0

    def _validate(self) -> None:
        for item in fields(self):
            if item.name != 'schema_version' and getattr(self, item.name) < 0:
                raise _invalid(f'{item.name} 不能小于零')


@dataclass(frozen=True)
class HypothesisRecord(JsonModel):
    id: str
    report: RecordRef
    text: str
    node_ids: tuple[str, ...]
    observed_conditions: tuple[str, ...] = ()
    design_requirement: str | None = None
    requirement_source: RecordRef | None = None
    keep_stimulus: tuple[str, ...] = ()
    change_stimulus: tuple[str, ...] = ()
    required_history: tuple[str, ...] = ()
    observation_points: tuple[Target, ...] = ()
    check_source: CheckSource | None = None
    supports_when: str | None = None
    refutes_when: str | None = None
    oracle_status: Literal['needs_oracle', 'provided'] = 'needs_oracle'

    def _validate(self) -> None:
        _nonempty(self.id, 'id')
        _nonempty(self.text, 'text')
        if self.oracle_status == 'provided' and (
            not self.design_requirement or self.requirement_source is None or self.check_source is None
        ):
            raise _invalid('provided 必须同时给出独立设计要求、来源和检查依据')


@dataclass(frozen=True)
class FollowUpResult(JsonModel):
    id: str
    relation: Literal['follow_up', 'replay', 'regression']
    outcome: Literal['not_run', 'supports', 'refutes', 'inconclusive'] = 'not_run'
    hypothesis_id: str | None = None
    run: RecordRef | None = None
    check: RecordRef | None = None
    report: RecordRef | None = None
    submitted_by: str | None = None
    observations: tuple[RecordRef, ...] = ()
    comparison_scope: dict[str, Any] = field(default_factory=lambda: {'status': 'unknown'})
    details: dict[str, Any] = field(default_factory=dict)

    def _validate(self) -> None:
        _nonempty(self.id, 'id')
        if self.outcome != 'not_run' and (self.run is None or self.check is None or self.report is None):
            raise _invalid('已执行的后续结果必须关联 run、check 和 report')
        if self.outcome in {'supports', 'refutes'} and (not self.submitted_by or not self.observations):
            raise _invalid('支持或否定假设必须记录提交者和新观测依据')


@dataclass(frozen=True)
class TraceReport(JsonModel):
    report_id: str
    run_id: str
    request: QueryRequest
    status: StatusAxes = field(default_factory=StatusAxes)
    run: RecordRef | None = None
    check: CheckRecord | None = None
    nodes: tuple[TraceNode, ...] = ()
    edges: tuple[TraceEdge, ...] = ()
    frontier: tuple[Frontier, ...] = ()
    artifacts: tuple[ArtifactRef, ...] = ()
    scope: dict[str, Any] = field(default_factory=dict)
    limitations: tuple[str, ...] = ()
    cost: QueryCost = field(default_factory=QueryCost)
    hypotheses: tuple[HypothesisRecord, ...] = ()
    follow_up_results: tuple[FollowUpResult, ...] = ()

    def _validate(self) -> None:
        _nonempty(self.report_id, 'report_id')
        _nonempty(self.run_id, 'run_id')
        ids = {node.id for node in self.nodes}
        if len(ids) != len(self.nodes):
            raise TraceError(StopCode.DUPLICATE_IDENTITY, '报告包含重复 node id')
        if any(node.ref.run_id != self.run_id for node in self.nodes):
            raise TraceError(StopCode.IDENTITY_MISMATCH, '报告节点属于其他运行')
        if any(edge.source not in ids or edge.target not in ids for edge in self.edges):
            raise _invalid('报告边必须引用已保存的节点')
        if self.check is not None and self.check.run_id != self.run_id:
            raise TraceError(StopCode.IDENTITY_MISMATCH, '报告检查属于其他运行')
        if self.status.design_check == 'failed' and (self.check is None or self.check.kind == 'suspicious_observation'):
            raise _invalid('设计检查失败必须关联数值差异或性质失败依据')
