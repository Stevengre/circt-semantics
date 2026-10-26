"""显式启用的进程内解析缓存；命中仍须读取并核验原始状态，绝不保存 pickle。"""

from __future__ import annotations

import hashlib
import json
import platform
from collections import OrderedDict
from contextlib import contextmanager
from contextvars import ContextVar
from copy import deepcopy
from dataclasses import replace
from importlib.metadata import version
from pathlib import Path
from typing import TYPE_CHECKING, Any

from .model import StopCode, TraceError

if TYPE_CHECKING:
    from collections.abc import Iterator

    from .kore import DecodedState, KoreReader
    from .model import RunManifest

_ACTIVE: ContextVar[ParsedStateCache | None] = ContextVar('kcirct_trace_parse_cache', default=None)


def analyzer_identity() -> str:
    """逐次绑定实际解释器源码与依赖版本，源码更改后不能复用旧 namespace。"""
    directory = Path(__file__).parent
    sources = {
        name: hashlib.sha256((directory / name).read_bytes()).hexdigest()
        for name in ('parse_cache.py', 'kore.py', 'model.py', 'artifacts.py', 'topology.py', 'semantics.py', 'query.py')
    }
    identity = {
        'format': 1,
        'sources': sources,
        'python': platform.python_version(),
        'kframework': version('kframework'),
    }
    return hashlib.sha256(json.dumps(identity, sort_keys=True).encode()).hexdigest()


def configure_reader(reader: KoreReader, manifest: RunManifest, manifest_sha256: str) -> None:
    """将当前显式缓存绑定到当前 manifest/profile；没有激活时保留旧读取行为。"""
    cache = _ACTIVE.get()
    if cache is None:
        return
    identity = {
        'manifest_sha256': manifest_sha256,
        'identities': manifest.identities,
        'analyzer_sha256': analyzer_identity(),
    }
    reader.parse_cache = cache
    reader.cache_namespace = hashlib.sha256(json.dumps(identity, sort_keys=True).encode()).hexdigest()


def _copy(state: DecodedState) -> DecodedState:
    """只共享不可变 arena；复制可变字典，调用者不能污染之后查询的缓存视图。"""
    return replace(
        state,
        cells=dict(state.cells),
        fingerprints=dict(state.fingerprints),
        completion=replace(state.completion, details=deepcopy(state.completion.details)),
    )


class ParsedStateCache:
    """LRU 持有已验证的扁平视图，不持久化，不跨进程继承证据。"""

    def __init__(self, max_bytes: int = 128 * 1024 * 1024) -> None:
        """指定缓存保留内存上限；当前请求更小的 max_cache_bytes 同样生效。"""
        if type(max_bytes) is not int or max_bytes <= 0:
            raise TraceError(StopCode.INVALID_BUDGET, '解析缓存内存预算必须为正整数')
        self.max_bytes = max_bytes
        self._entries: OrderedDict[tuple[str, str, str], DecodedState] = OrderedDict()
        self.bytes = 0
        self.peak_bytes = 0
        self.metrics: dict[str, int | float] = {
            'hits': 0,
            'misses': 0,
            'parse_calls': 0,
            'evictions': 0,
            'oversize_bypasses': 0,
            'reads': 0,
            'failed_reads': 0,
            'read_bytes': 0,
            'load_seconds': 0.0,
            'decode_seconds': 0.0,
        }

    @contextmanager
    def activate(self) -> Iterator[ParsedStateCache]:
        """在当前执行上下文启用；退出只取消自动绑定，可复用该对象开启另一轮。"""
        token = _ACTIVE.set(self)
        try:
            yield self
        finally:
            _ACTIVE.reset(token)

    def _trim(self, limit: int) -> None:
        """根据当前请求和缓存自身的较小上限淘汰旧条目。"""
        while self._entries and self.bytes > limit:
            _, state = self._entries.popitem(last=False)
            self.bytes -= state.view_bytes
            self.metrics['evictions'] += 1

    def lookup(self, namespace: str, artifact: str, content: str, limit: int) -> DecodedState | None:
        """取出待重新核验的候选；lookup 成功并不算验证命中。"""
        self._trim(min(self.max_bytes, limit))
        key = namespace, artifact, content
        state = self._entries.get(key)
        if state is None:
            self.metrics['misses'] += 1
            return None
        self._entries.move_to_end(key)
        return _copy(state)

    def remember(self, namespace: str, state: DecodedState, limit: int) -> None:
        """只保存解析器成功返回的视图；超大状态不进入缓存。"""
        limit = min(self.max_bytes, limit)
        self._trim(limit)
        if state.view_bytes > limit:
            self.metrics['oversize_bypasses'] += 1
            return
        key = namespace, state.artifact_sha256, state.uncompressed_sha256
        old = self._entries.pop(key, None)
        if old is not None:
            self.bytes -= old.view_bytes
        self._trim(limit - state.view_bytes)
        self._entries[key] = _copy(state)
        self.bytes += state.view_bytes
        self.peak_bytes = max(self.peak_bytes, self.bytes)

    def statistics(self) -> dict[str, Any]:
        """返回本对象的实际累计计数；不注入报告的语义审计字段。"""
        return dict(self.metrics, retained_bytes=self.bytes, peak_bytes=self.peak_bytes, entries=len(self._entries))

    def clear(self) -> None:
        """丢弃保留视图，累计计数仍可用于实验记录。"""
        self._entries.clear()
        self.bytes = 0
