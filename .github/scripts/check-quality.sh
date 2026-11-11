#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

# Git 不递归列出子模块内容；本地未提交的新文件仍参与检查。
mapfile -d '' -t python_files < <(git ls-files --cached --others --exclude-standard -z -- 'src/**/*.py')
if ((${#python_files[@]} == 0)); then
  echo '未找到项目 Python 文件，无法执行代码质量检查。' >&2
  exit 1
fi

# flake8/mypy 的项目配置已有资源目录排除规则。
poetry run flake8 src
poetry run mypy src
# 预留校验方法中的 docstring + pass 是合法结构；保留未使用导入等其余检查。
poetry run autoflake --quiet --check --ignore-pass-after-docstring "${python_files[@]}"
poetry run isort --check "${python_files[@]}"
poetry run black --check "${python_files[@]}"
