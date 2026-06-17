from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, Sequence

if TYPE_CHECKING:
    from ._prove import AssertProofResult
    from .api import KCIRCT


@dataclass(frozen=True)
class AssertProofDebugArtifacts:
    output_dir: Path
    summary_file: Path
    branch_summary_file: Path | None
    setup_pretty_file: Path | None
    state_pretty_files: list[Path]


def summarize_assert_proof(result: AssertProofResult) -> str:
    proof = result.proof
    pending_ids = [node.id for node in proof.pending]
    failing_ids = [node.id for node in proof.failing]
    return (
        f'proof_id={proof.id}; '
        f'input_file={result.input_file}; '
        f'top_module={result.top_module}; '
        f'symbolic_widths={result.symbolic_widths}; '
        f'work_dir={result.work_dir}; '
        f'setup_state={result.setup_state}; '
        f'{proof.one_line_summary}; '
        f'pending={pending_ids}; '
        f'failing={failing_ids}'
    )


def dump_assertion_debug_artifacts(
    kcirct: KCIRCT,
    result: AssertProofResult,
    *,
    output_dir: Path | None = None,
    state_files: Sequence[Path] | None = None,
) -> AssertProofDebugArtifacts:
    output_dir = output_dir or result.work_dir / 'debug'
    output_dir.mkdir(parents=True, exist_ok=True)

    summary_file = output_dir / 'proof-summary.txt'
    summary_file.write_text(f'{summarize_assert_proof(result)}\n{result.note}\n')

    branch_summary_file: Path | None = None
    branch_summary = summarize_assertion_branches(result)
    if branch_summary:
        branch_summary_file = output_dir / 'proof-branches.txt'
        branch_summary_file.write_text(branch_summary)

    setup_pretty_file: Path | None = None
    if result.setup_state.exists():
        setup_pretty_file = output_dir / 'setup.pretty'
        _write_readable_file(kcirct, result.setup_state, setup_pretty_file)

    state_pretty_files: list[Path] = []
    for state_file in state_files or ():
        pretty_file = output_dir / f'{state_file.name}.pretty'
        _write_readable_file(kcirct, state_file, pretty_file)
        state_pretty_files.append(pretty_file)

    return AssertProofDebugArtifacts(
        output_dir=output_dir,
        summary_file=summary_file,
        branch_summary_file=branch_summary_file,
        setup_pretty_file=setup_pretty_file,
        state_pretty_files=state_pretty_files,
    )


def summarize_assertion_branches(result: AssertProofResult, *, max_constraints_per_target: int = 3) -> str:
    kcfg_dir = _proof_kcfg_dir(result)
    kcfg_json = kcfg_dir / 'kcfg.json'
    if not kcfg_json.exists():
        return ''

    kcfg = json.loads(kcfg_json.read_text())
    ndbranches = kcfg.get('ndbranches', [])
    if not ndbranches:
        return 'No non-deterministic proof branches recorded.\n'

    lines: list[str] = []
    for branch in ndbranches:
        source = int(branch['source'])
        targets = [int(target) for target in branch['targets']]
        lines.append(f'Branch {source} -> {targets}')
        source_constraints = _node_constraints(kcfg_dir, source)
        source_rendered = [_render_kast(constraint) for constraint in source_constraints]
        source_set = set(source_rendered)
        for target in targets:
            target_constraints = _node_constraints(kcfg_dir, target)
            target_rendered = [_render_kast(constraint) for constraint in target_constraints]
            added_constraints = [constraint for constraint in target_rendered if constraint not in source_set]
            lines.append(
                f'  target {target}: {len(target_constraints)} constraints ' f'({len(added_constraints)} new vs source)'
            )
            if added_constraints:
                for constraint in added_constraints[:max_constraints_per_target]:
                    lines.append(f'    + {constraint}')
                remaining = len(added_constraints) - max_constraints_per_target
                if remaining > 0:
                    lines.append(f'    + ... {remaining} more')
        lines.append('')

    return '\n'.join(lines).rstrip() + '\n'


def _write_readable_file(kcirct: KCIRCT, source_file: Path, target_file: Path) -> None:
    try:
        kcirct.write_pretty(source_file, target_file)
    except Exception as err:
        target_file.write_text(f'Failed to pretty print {source_file}:\n{err}\n')


def _proof_kcfg_dir(result: AssertProofResult) -> Path:
    return result.work_dir / 'proof' / result.proof.id / 'kcfg'


def _node_constraints(kcfg_dir: Path, node_id: int) -> list[dict]:
    node_json = kcfg_dir / 'nodes' / f'{node_id}.json'
    if not node_json.exists():
        return []
    node = json.loads(node_json.read_text())
    return node.get('cterm', {}).get('constraints', [])


def _render_kast(term: dict) -> str:
    node_type = term.get('node')
    if node_type == 'KVariable':
        return term['name']
    if node_type == 'KToken':
        return term['token']
    if node_type == 'KSequence':
        items = term.get('items', [])
        return ' ~> '.join(_render_kast(item) for item in items) or '.K'
    if node_type == 'KApply':
        label = term.get('label', {}).get('name', '<label>')
        args = [_render_kast(arg) for arg in term.get('args', [])]
        if label == '#Equals' and len(args) == 2:
            return f'{args[0]} == {args[1]}'
        if label == '#Not' and len(args) == 1:
            return f'not ({args[0]})'
        if label == '_<=Int_' and len(args) == 2:
            return f'{args[0]} <= {args[1]}'
        if label == '_==K_' and len(args) == 2:
            return f'{args[0]} ==K {args[1]}'
        if label == '_&Int_' and len(args) == 2:
            return f'({args[0]} &Int {args[1]})'
        if label == '#Exists' and len(args) == 2:
            return f'exists {args[0]}. ({args[1]})'
        if label == 'bits(_,_)_BITS-SYNTAX_Bits_BitsValue_Int' and len(args) == 2:
            return f'bits({args[0]}, {args[1]})'
        if label == '_+Bits__BITS-SYNTAX_Bits_Bits_Bits' and len(args) == 2:
            return f'({args[0]} +Bits {args[1]})'
        if label == 'BitsCast(_)_BITS-SYNTAX_Bits_Bits' and len(args) == 1:
            return f'BitsCast({args[0]})'
        if label == 'BitsCast(_,_)_BITS-SYNTAX_Bits_Bits_Int' and len(args) == 2:
            return f'BitsCast({args[0]}, {args[1]})'
        if label == '.List':
            return '.List'
        if label == 'ListItem' and len(args) == 1:
            return f'ListItem({args[0]})'
        if label == '_List_':
            return '[' + ', '.join(args) + ']'
        return f'{label}(' + ', '.join(args) + ')'
    if node_type == 'KLabel':
        return term.get('name', '<label>')
    return json.dumps(term, ensure_ascii=True)
