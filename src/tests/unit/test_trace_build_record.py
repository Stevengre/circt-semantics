"""新构建通过来源关联进入已审阅规则集，错误或缺失关联仍拒绝。"""

from __future__ import annotations

import hashlib
import json
from dataclasses import replace
from typing import TYPE_CHECKING, Any

import pytest

from kcirct.kdist.build_record import BUILD_RECORD_NAME, BUILD_RECORD_SCHEMA, LLVM_BUILD_RECIPE, SUPPORTED_K_VERSION
from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.model import RunManifest, StopCode, TraceError
from kcirct.trace.semantics import bind_semantics

from .test_trace_query import _test_profile_bundle, artifact, small_run

if TYPE_CHECKING:
    from pathlib import Path


def _bundle(path: Path, monkeypatch: pytest.MonkeyPatch, build: str = 'new build') -> dict[str, Any]:
    """模拟编译阶段的独立来源记录，规则表故意只认可另一份历史产物。"""
    _test_profile_bundle(path, monkeypatch)
    manifest = RunManifest.from_json(path.read_text())
    hashes = manifest.identities['semantics_hashes']
    source = hashlib.sha256(json.dumps(hashes, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
    monkeypatch.setattr('kcirct.trace.semantics._PROFILES', {source: ('1' * 64, True)})
    monkeypatch.setattr('kcirct.trace.semantics._ADDITIONAL_BUILDS', {})
    artifacts = dict(manifest.artifacts)
    outputs = {}
    for name in ('definition.kore', 'compiled.bin', 'backend.txt', 'interpreter'):
        output = path.parent / name
        output.write_text(build + ':' + name)
        ref = artifact(output, path.parent, 'compiled_definition')
        artifacts['definition/' + name] = ref
        outputs[name] = ref.sha256
    identities = dict(manifest.identities, semantics_binding={'definition_sha256': outputs['definition.kore']})
    path.write_text(replace(manifest, artifacts=artifacts, identities=identities).to_json())
    record = {
        'schema': BUILD_RECORD_SCHEMA,
        'k_version': SUPPORTED_K_VERSION,
        'recipe': dict(LLVM_BUILD_RECIPE),
        'semantics_hashes': hashes,
        'artifacts': outputs,
    }
    _save_record(path, record)
    return record


def _save_record(path: Path, record: Any) -> None:
    """保存来源记录及其独立工件身份，允许测试构造内部关联冲突。"""
    receipt = path.parent / BUILD_RECORD_NAME
    receipt.write_text(json.dumps(record))
    manifest = RunManifest.from_json(path.read_text())
    artifacts = dict(manifest.artifacts)
    artifacts['definition/' + BUILD_RECORD_NAME] = artifact(receipt, path.parent, 'build_record')
    path.write_text(replace(manifest, artifacts=artifacts).to_json())


def test_different_fresh_builds_keep_actual_definition_identity(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """两个未登记的构建分别绑定自身原字节，不能把它们折叠成历史定义摘要。"""
    path = small_run(tmp_path)
    identities = []
    for build in ('first directory', 'second directory'):
        record = _bundle(path, monkeypatch, build)
        with RunArtifacts.open(path) as run:
            profile = bind_semantics(run)
        assert profile.definition_sha256 == record['artifacts']['definition.kore']
        identities.append(profile.definition_sha256)
    assert identities[0] != identities[1]


@pytest.mark.parametrize('field', ['schema', 'k_version', 'recipe', 'semantics_hashes', 'artifacts'])
def test_build_record_rejects_inconsistent_identity(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, field: str
) -> None:
    """记录的格式、工具链、配方、实际源码和输出集合都参与绑定。"""
    path = small_run(tmp_path)
    record = _bundle(path, monkeypatch)
    record[field] = {} if isinstance(record[field], dict) else 'unsupported'
    _save_record(path, record)
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as caught:
        bind_semantics(run)
    assert caught.value.code in {StopCode.UNSUPPORTED_SEMANTICS, StopCode.IDENTITY_MISMATCH}


@pytest.mark.parametrize('name', ['definition.kore', 'compiled.bin', 'backend.txt', 'interpreter'])
def test_build_record_rejects_output_from_another_build(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, name: str
) -> None:
    """即使更新运行清单的摘要，也不能将另一次构建的输出冒充本次记录。"""
    path = small_run(tmp_path)
    _bundle(path, monkeypatch)
    output = tmp_path / name
    output.write_text('different build output')
    manifest = RunManifest.from_json(path.read_text())
    artifacts = dict(manifest.artifacts)
    artifacts['definition/' + name] = artifact(output, tmp_path, 'compiled_definition')
    identities = dict(manifest.identities, semantics_binding={})
    path.write_text(replace(manifest, artifacts=artifacts, identities=identities).to_json())
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as caught:
        bind_semantics(run)
    assert caught.value.code == StopCode.IDENTITY_MISMATCH


def test_fresh_build_requires_receipt(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """运行声明的源码与输出摘要不能替代构建时产生的来源记录。"""
    path = small_run(tmp_path)
    _bundle(path, monkeypatch)
    manifest = RunManifest.from_json(path.read_text())
    artifacts = dict(manifest.artifacts)
    del artifacts['definition/' + BUILD_RECORD_NAME]
    path.write_text(replace(manifest, artifacts=artifacts).to_json())
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as caught:
        bind_semantics(run)
    assert caught.value.code == StopCode.UNSUPPORTED_SEMANTICS


def test_build_record_does_not_authorize_unreviewed_source(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """内容相互一致的构建记录也不能扩大解释器的规则支持范围。"""
    path = small_run(tmp_path)
    _bundle(path, monkeypatch)
    monkeypatch.setattr('kcirct.trace.semantics._PROFILES', {})
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as caught:
        bind_semantics(run)
    assert caught.value.code == StopCode.UNSUPPORTED_SEMANTICS


def test_build_record_does_not_override_explicit_conflict(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """新构建路径仍要求显式定义声明与本次产物一致。"""
    path = small_run(tmp_path)
    _bundle(path, monkeypatch)
    manifest = RunManifest.from_json(path.read_text())
    identities = dict(manifest.identities, semantics_binding={'definition_sha256': '3' * 64})
    path.write_text(replace(manifest, identities=identities).to_json())
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as caught:
        bind_semantics(run)
    assert caught.value.code == StopCode.IDENTITY_MISMATCH


def test_malformed_record_is_rejected_even_for_known_definition(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """已登记的历史输出不能掩盖与其一起提供的坏记录。"""
    path = small_run(tmp_path)
    _test_profile_bundle(path, monkeypatch)
    _save_record(path, [])
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as caught:
        bind_semantics(run)
    assert caught.value.code == StopCode.UNSUPPORTED_SEMANTICS


@pytest.mark.parametrize('name', [BUILD_RECORD_NAME, 'definition.kore', 'interpreter'])
def test_build_record_rejects_changed_artifact_bytes(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, name: str
) -> None:
    """来源记录和实际产物仍受运行工件内容校验保护。"""
    path = small_run(tmp_path)
    _bundle(path, monkeypatch)
    output = tmp_path / name
    output.write_bytes(output.read_bytes() + b'changed')
    with RunArtifacts.open(path) as run, pytest.raises(TraceError) as caught:
        bind_semantics(run)
    assert caught.value.code == StopCode.HASH_MISMATCH
