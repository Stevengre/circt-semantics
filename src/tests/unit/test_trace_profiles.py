"""额外编译身份必须精确匹配源码/定义对，不能降低已有内容校验。"""

from __future__ import annotations

import hashlib
import json
from dataclasses import replace
from typing import TYPE_CHECKING

import pytest

from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.model import RunManifest, StopCode, TraceError
from kcirct.trace.semantics import bind_semantics

from .test_trace_query import _test_profile_bundle, small_run

if TYPE_CHECKING:
    from pathlib import Path


def test_additional_build_requires_exact_source_definition_pair(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """只有额外表明确登记的源码和定义对可用；其他定义不因源码相同被接受。"""
    path = small_run(tmp_path)
    _test_profile_bundle(path, monkeypatch)
    manifest = RunManifest.from_json(path.read_text())
    source = hashlib.sha256(
        json.dumps(manifest.identities['semantics_hashes'], sort_keys=True, separators=(',', ':')).encode()
    ).hexdigest()
    definition = manifest.artifacts['definition/definition.kore'].sha256
    monkeypatch.setattr('kcirct.trace.semantics._PROFILES', {source: ('1' * 64, True)})
    monkeypatch.setattr('kcirct.trace.semantics._ADDITIONAL_BUILDS', {(source, definition): True})
    with RunArtifacts.open(path) as run:
        assert bind_semantics(run).definition_sha256 == definition
    monkeypatch.setattr('kcirct.trace.semantics._ADDITIONAL_BUILDS', {(source, '2' * 64): True})
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as caught:
        bind_semantics(run)
    assert caught.value.code == StopCode.UNSUPPORTED_SEMANTICS


def test_additional_build_cannot_override_explicit_conflict(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """显式编译身份声明与原字节冲突仍为拒绝，不被额外构建表修正。"""
    path = small_run(tmp_path)
    _test_profile_bundle(path, monkeypatch)
    manifest = RunManifest.from_json(path.read_text())
    source = hashlib.sha256(
        json.dumps(manifest.identities['semantics_hashes'], sort_keys=True, separators=(',', ':')).encode()
    ).hexdigest()
    definition = manifest.artifacts['definition/definition.kore'].sha256
    monkeypatch.setattr('kcirct.trace.semantics._ADDITIONAL_BUILDS', {(source, definition): True})
    identities = dict(manifest.identities, semantics_binding={'definition_sha256': '3' * 64})
    path.write_text(replace(manifest, identities=identities).to_json())
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as caught:
        bind_semantics(run)
    assert caught.value.code == StopCode.IDENTITY_MISMATCH
