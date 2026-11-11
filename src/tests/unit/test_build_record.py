"""编译来源必须来自实际依赖，并且只能在完整、稳定的构建后发布。"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from types import SimpleNamespace
from typing import TYPE_CHECKING, Any

import pytest
from pyk.ktool.kompile import PykBackend

from kcirct.kdist import plugin
from kcirct.kdist.build_record import (
    BUILD_ARTIFACTS,
    BUILD_RECORD_NAME,
    BUILD_RECORD_SCHEMA,
    LLVM_BUILD_RECIPE,
    SUPPORTED_K_VERSION,
    build_recipe,
    semantics_hashes,
)

if TYPE_CHECKING:
    from collections.abc import Callable


def _source(tmp_path: Path) -> tuple[Path, Path]:
    """创建与安装包不同的编译依赖，确保记录不从当前安装包倒填。"""
    source = tmp_path / 'dependency'
    semantics = source / 'circt_semantics'
    semantics.mkdir(parents=True)
    (semantics / 'circt-core.k').write_text('module ACTUAL-DEPENDENCY endmodule')
    (semantics / 'rules.md').write_text('```k\nrule X => X\n```')
    (semantics / 'helper.py').write_text('ignored = True')
    output = tmp_path / 'output'
    output.mkdir()
    return source, output


def _compiler(output_dir: Path, **_kwargs: Any) -> None:
    """模拟 compiler 产出，为所有执行工件提供不同内容。"""
    for name in BUILD_ARTIFACTS:
        (output_dir / name).write_text('compiled:' + name)


def _build(
    source: Path,
    output: Path,
    monkeypatch: pytest.MonkeyPatch,
    compiler: Callable[..., None] = _compiler,
    target: plugin.KompileTarget | None = None,
) -> None:
    """调用真实 kdist target，仅替换外部编译器和工具版本查询。"""
    monkeypatch.setattr(plugin, 'kompile', compiler)
    monkeypatch.setattr(plugin, 'k_version', lambda: SimpleNamespace(text=SUPPORTED_K_VERSION))
    selected = target or plugin.__TARGETS__['llvm']
    assert isinstance(selected, plugin.KompileTarget)
    selected.build(output, {'circt-semantics.source': source}, {}, False)


def test_build_records_actual_dependency_and_all_outputs(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """默认 LLVM 配方记录真实依赖及四份执行工件，不携带构建路径身份。"""
    source, output = _source(tmp_path)
    _build(source, output, monkeypatch)
    record = json.loads((output / BUILD_RECORD_NAME).read_text())
    assert record == {
        'schema': BUILD_RECORD_SCHEMA,
        'k_version': SUPPORTED_K_VERSION,
        'recipe': LLVM_BUILD_RECIPE,
        'semantics_hashes': {
            name: hashlib.sha256((source / 'circt_semantics' / name).read_bytes()).hexdigest()
            for name in ('circt-core.k', 'rules.md')
        },
        'artifacts': {name: hashlib.sha256(('compiled:' + name).encode()).hexdigest() for name in BUILD_ARTIFACTS},
    }
    assert str(tmp_path) not in json.dumps(record)
    assert list(output.glob(BUILD_RECORD_NAME + '.*')) == []


@pytest.mark.parametrize('failure', ['compiler', 'changed_source', 'added_source', 'missing_output'])
def test_failed_or_unstable_build_has_no_record(tmp_path: Path, monkeypatch: pytest.MonkeyPatch, failure: str) -> None:
    """失败、输入变化或产物缺失不能沿用旧 receipt 或发布不完整的新记录。"""
    source, output = _source(tmp_path)
    record = output / BUILD_RECORD_NAME
    record.write_text('stale receipt')

    def compiler(output_dir: Path, **kwargs: Any) -> None:
        assert not record.exists()
        if failure == 'compiler':
            raise RuntimeError('compiler failed')
        _compiler(output_dir, **kwargs)
        if failure == 'changed_source':
            (source / 'circt_semantics/circt-core.k').write_text('changed')
        elif failure == 'added_source':
            (source / 'circt_semantics/extra.k').write_text('extra')
        elif failure == 'missing_output':
            (output_dir / 'interpreter').unlink()

    with pytest.raises((RuntimeError, ValueError)):
        _build(source, output, monkeypatch, compiler)
    assert not record.exists()
    assert list(output.glob(BUILD_RECORD_NAME + '.*')) == []


def test_empty_source_does_not_retain_old_record(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """编译前的输入检查失败同样使旧来源记录失效。"""
    source, output = _source(tmp_path)
    for path in (source / 'circt_semantics').glob('*'):
        path.unlink()
    (output / BUILD_RECORD_NAME).write_text('stale receipt')
    with pytest.raises(ValueError, match='没有可记录'):
        _build(source, output, monkeypatch)
    assert not (output / BUILD_RECORD_NAME).exists()


def test_recipe_preserves_changed_options(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """带额外选项的编译不得把实际配方伪装成默认 LLVM 配方。"""
    source, output = _source(tmp_path)
    target = plugin.KompileTarget(
        lambda root: {
            **LLVM_BUILD_RECIPE,
            'backend': PykBackend.LLVM,
            'main_file': root / LLVM_BUILD_RECIPE['main_file'],
            'opt_level': 3,
            'ccopts': ('-g', '-DFOO'),
        }
    )
    _build(source, output, monkeypatch, target=target)
    recipe = json.loads((output / BUILD_RECORD_NAME).read_text())['recipe']
    assert recipe == {**LLVM_BUILD_RECIPE, 'opt_level': 3, 'ccopts': ['-g', '-DFOO']}
    assert recipe != LLVM_BUILD_RECIPE


def test_external_main_file_does_not_match_supported_recipe(tmp_path: Path) -> None:
    """同名外部入口不能通过主文件的 basename 冒充受支持入口。"""
    source, _ = _source(tmp_path)
    external = tmp_path / 'external/circt_semantics/circt-core.k'
    recipe = build_recipe({**LLVM_BUILD_RECIPE, 'main_file': external}, source)
    assert recipe['main_file'] == str(external)
    assert recipe != LLVM_BUILD_RECIPE


def test_non_llvm_recipe_is_recorded_without_llvm_interpreter(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """其他后端可以产生来源记录，但记录自身不能冒充受支持的 LLVM 执行配方。"""
    source, output = _source(tmp_path)

    def compiler(output_dir: Path, **_kwargs: Any) -> None:
        (output_dir / 'definition.kore').write_text('haskell definition')

    target = plugin.__TARGETS__['haskell']
    assert isinstance(target, plugin.KompileTarget)
    _build(source, output, monkeypatch, compiler, target)
    record = json.loads((output / BUILD_RECORD_NAME).read_text())
    assert record['recipe']['backend'] == 'haskell'
    assert record['recipe'] != LLVM_BUILD_RECIPE
    assert set(record['artifacts']) == {'definition.kore'}


def test_cache_manifest_tracks_recipe_and_writer(monkeypatch: pytest.MonkeyPatch) -> None:
    """构建记录协议及实现变化都进入 kdist 缓存身份，旧无 receipt 缓存会失效。"""
    monkeypatch.setattr(plugin, 'k_version', lambda: SimpleNamespace(text=SUPPORTED_K_VERSION))
    target = plugin.__TARGETS__['llvm']
    manifest = target.manifest()
    assert manifest['context'] == {'k-version': SUPPORTED_K_VERSION, 'build-record-schema': BUILD_RECORD_SCHEMA}
    assert {Path(name).name for name in manifest['source']} == {'plugin.py', 'build_record.py'}


def test_source_identity_uses_relative_paths_and_file_contents(tmp_path: Path) -> None:
    """语义摘要涵盖嵌套文件并排除非语义辅助文件，不依赖所在构建根。"""
    source, _ = _source(tmp_path)
    nested = source / 'circt_semantics/dialects'
    nested.mkdir()
    (nested / 'rule.k').write_text('rule X => Y')
    hashes = semantics_hashes(source / 'circt_semantics')
    assert set(hashes) == {'circt-core.k', 'rules.md', 'dialects/rule.k'}
    assert hashes['dialects/rule.k'] == hashlib.sha256(b'rule X => Y').hexdigest()
