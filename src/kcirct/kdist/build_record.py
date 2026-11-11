"""记录本地可信编译器实际使用的源码、参数与输出身份；不充当签名证明。"""

from __future__ import annotations

import hashlib
import json
from enum import Enum
from pathlib import Path
from tempfile import NamedTemporaryFile
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from collections.abc import Mapping

BUILD_RECORD_NAME = 'kcirct-build.json'
BUILD_RECORD_SCHEMA = 'kcirct-build-v1'
SUPPORTED_K_VERSION = 'v7.1.323'
LLVM_BUILD_RECIPE = {
    'backend': 'llvm',
    'main_file': 'circt_semantics/circt-core.k',
    'main_module': 'CIRCT-CORE',
    'syntax_module': 'CIRCT-CORE-SYNTAX',
}
BUILD_ARTIFACTS = ('definition.kore', 'compiled.bin', 'backend.txt', 'interpreter')


def file_sha256(path: Path) -> str:
    """分块计算文件摘要，避免将 interpreter 等较大产物整体读入内存。"""
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def semantics_hashes(source_root: Path) -> dict[str, str]:
    """绑定实际构建源码目录中的全部 K 和 Markdown 语义文件。"""
    return {
        path.relative_to(source_root).as_posix(): file_sha256(path)
        for path in sorted(source_root.rglob('*'))
        if path.is_file() and path.suffix in {'.k', '.md'}
    }


def build_recipe(arguments: Mapping[str, Any], source_dir: Path) -> dict[str, Any]:
    """保留实际编译参数；主文件使用依赖目录相对路径，其余选项不省略。"""

    def encode(value: Any) -> Any:
        """将编译器参数中的枚举、路径和序列显式转换为 JSON 数据。"""
        if isinstance(value, Enum):
            return encode(value.value)
        if isinstance(value, Path):
            return str(value)
        if isinstance(value, dict):
            return {key: encode(item) for key, item in value.items()}
        if isinstance(value, (tuple, list)):
            return [encode(item) for item in value]
        if value is None or isinstance(value, (str, bool, int, float)):
            return value
        raise TypeError(f'无法记录编译参数类型：{type(value).__name__}')

    recipe = {key: encode(value) for key, value in arguments.items()}
    if 'main_file' in recipe:
        main_file = Path(recipe['main_file']).resolve()
        try:
            recipe['main_file'] = main_file.relative_to(source_dir.resolve()).as_posix()
        except ValueError:
            # 外部主文件保持绝对位置，不会冒充受支持的相对入口。
            recipe['main_file'] = str(main_file)
    return recipe


def write_build_record(output_dir: Path, *, k_version: str, recipe: dict[str, Any], hashes: dict[str, str]) -> None:
    """完成输出身份采集后原子发布来源记录；默认 LLVM 配方必须产出全部执行工件。"""
    if recipe == LLVM_BUILD_RECIPE:
        missing = [name for name in BUILD_ARTIFACTS if not (output_dir / name).is_file()]
        if missing:
            raise ValueError(f'LLVM 构建缺少执行工件：{", ".join(missing)}')
    artifacts = {name: file_sha256(output_dir / name) for name in BUILD_ARTIFACTS if (output_dir / name).is_file()}
    record = {
        'schema': BUILD_RECORD_SCHEMA,
        'k_version': k_version,
        'recipe': recipe,
        'semantics_hashes': hashes,
        'artifacts': artifacts,
    }
    temporary: Path | None = None
    try:
        with NamedTemporaryFile(
            mode='w', encoding='utf-8', dir=output_dir, prefix=BUILD_RECORD_NAME + '.', delete=False
        ) as f:
            temporary = Path(f.name)
            json.dump(record, f, sort_keys=True, indent=2, allow_nan=False)
            f.write('\n')
        temporary.replace(output_dir / BUILD_RECORD_NAME)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
