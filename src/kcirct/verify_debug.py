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
    elapsed_summary = f'elapsed_seconds={result.elapsed_seconds:.3f}; ' if hasattr(result, 'elapsed_seconds') else ''
    return (
        f'proof_id={proof.id}; '
        f'input_file={result.input_file}; '
        f'top_module={result.top_module}; '
        f'symbolic_widths={result.symbolic_widths}; '
        f'work_dir={result.work_dir}; '
        f'setup_state={result.setup_state}; '
        f'{elapsed_summary}'
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
        source_node = _read_node(kcfg_dir, source)
        source_constraints = _node_constraints(source_node)
        source_rendered = [_render_kast(constraint) for constraint in source_constraints]
        source_set = set(source_rendered)
        source_properties = _node_property_summary(source_node)
        if source_properties:
            lines.append('  source-properties:')
            for name, value in source_properties.items():
                lines.append(f'    {name}: {value}')
        for target in targets:
            target_node = _read_node(kcfg_dir, target)
            target_constraints = _node_constraints(target_node)
            target_rendered = [_render_kast(constraint) for constraint in target_constraints]
            added_constraints = [constraint for constraint in target_rendered if constraint not in source_set]
            lines.append(
                f'  target {target}: {len(target_constraints)} constraints ' f'({len(added_constraints)} new vs source)'
            )
            target_properties = _node_property_summary(target_node)
            changed_properties = {
                name: value for name, value in target_properties.items() if source_properties.get(name) != value
            }
            if changed_properties:
                lines.append('    changed-properties:')
                for name, value in changed_properties.items():
                    lines.append(f'      {name}: {value}')
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


def _read_node(kcfg_dir: Path, node_id: int) -> dict:
    node_json = kcfg_dir / 'nodes' / f'{node_id}.json'
    if not node_json.exists():
        return {}
    return json.loads(node_json.read_text())


def _node_constraints(node: dict) -> list[dict]:
    return node.get('cterm', {}).get('constraints', [])


def _node_property_summary(node: dict) -> dict[str, str]:
    properties: dict[str, str] = {}

    attrs = node.get('attrs', [])
    if attrs:
        properties['attrs'] = _render_collection(attrs)

    config = node.get('cterm', {}).get('config')
    if not isinstance(config, dict):
        return properties

    for cell_name in ('cmd', 'clock', 'signals', 'currents'):
        cell_value = _find_cell_value(config, cell_name)
        if cell_value is None:
            continue
        properties[cell_name] = _summarize_cell_value(cell_name, cell_value)

    return properties


def _find_cell_value(term: dict, cell_name: str) -> dict | None:
    if term.get('node') != 'KApply':
        return None

    label = term.get('label', {}).get('name')
    if label == f'<{cell_name}>':
        args = term.get('args', [])
        if len(args) == 1 and isinstance(args[0], dict):
            return args[0]
        return term

    for child in term.get('args', []):
        if not isinstance(child, dict):
            continue
        cell = _find_cell_value(child, cell_name)
        if cell is not None:
            return cell
    return None


def _summarize_cell_value(cell_name: str, term: dict) -> str:
    if cell_name == 'signals':
        return _summarize_map(term)
    if cell_name == 'currents':
        return _summarize_currents(term)
    return _render_kast(term)


def _summarize_map(term: dict, *, max_entries: int = 8) -> str:
    entries = [_render_kast(entry) for entry in _flatten_assoc(term, '_Map_') if _is_map_entry(entry)]
    return _render_collection(entries, prefix='{', suffix='}', max_items=max_entries)


def _summarize_currents(term: dict, *, max_entries: int = 6) -> str:
    items = _flatten_assoc(term, '_CurrentInfoCellMap_')
    rendered_items: list[str] = []
    for item in items:
        if item.get('node') != 'KApply' or item.get('label', {}).get('name') != '<current-info>':
            rendered_items.append(_render_kast(item))
            continue
        current_id = _find_cell_value(item, 'current-id')
        current = _find_cell_value(item, 'current')
        rendered_items.append(
            f'{_render_kast(current_id) if current_id is not None else "?"} -> '
            f'{_render_kast(current) if current is not None else "?"}'
        )
    return _render_collection(rendered_items, prefix='[', suffix=']', max_items=max_entries)


def _flatten_assoc(term: dict, label_name: str) -> list[dict]:
    if term.get('node') != 'KApply' or term.get('label', {}).get('name') != label_name:
        return [term]

    items: list[dict] = []
    for child in term.get('args', []):
        if isinstance(child, dict):
            items.extend(_flatten_assoc(child, label_name))
    return items


def _is_map_entry(term: dict) -> bool:
    return term.get('node') == 'KApply' and term.get('label', {}).get('name') == '_|->_'


def _render_collection(items: Sequence[str | dict], *, prefix: str = '[', suffix: str = ']', max_items: int = 8) -> str:
    rendered_items = [item if isinstance(item, str) else _render_kast(item) for item in items]
    visible_items = rendered_items[:max_items]
    if len(rendered_items) > max_items:
        visible_items.append(f'... {len(rendered_items) - max_items} more')
    return prefix + ', '.join(visible_items) + suffix


def _render_kast(term: dict) -> str:
    node_type = term.get('node')
    if node_type == 'KVariable':
        return term['name']
    if node_type == 'KToken':
        sort_name = term.get('sort', {}).get('name')
        token = term['token']
        if sort_name == 'String' and len(token) >= 2 and token[0] == '"' and token[-1] == '"':
            return token[1:-1]
        return term['token']
    if node_type == 'KSequence':
        items = term.get('items', [])
        if len(items) == 1:
            return _render_kast(items[0])
        return ' ~> '.join(_render_kast(item) for item in items) or '.K'
    if node_type == 'KApply':
        label = term.get('label', {}).get('name', '<label>')
        args = [_render_kast(arg) for arg in term.get('args', [])]
        if label.startswith('<') and label.endswith('>'):
            cell_name = label[1:-1]
            if len(args) == 1:
                return f'{cell_name}={args[0]}'
            return f'{cell_name}(' + ', '.join(args) + ')'
        if label == '#Equals' and len(args) == 2:
            if args[0] == 'true':
                return args[1]
            if args[1] == 'true':
                return args[0]
            if args[0] == 'false':
                return f'not ({args[1]})'
            if args[1] == 'false':
                return f'not ({args[0]})'
            return f'{args[0]} == {args[1]}'
        if label == '#Not' and len(args) == 1:
            exists_vars, exists_body = _flatten_exists(term.get('args', [])[0])
            if exists_vars:
                return f'not exists {", ".join(exists_vars)}. ({_render_kast(exists_body)})'
            return f'not ({args[0]})'
        if label == '_<=Int_' and len(args) == 2:
            return f'{args[0]} <= {args[1]}'
        if label == '_==K_' and len(args) == 2:
            return f'{args[0]} == {args[1]}'
        if label == '_==Int_' and len(args) == 2:
            return f'{args[0]} == {args[1]}'
        if label == 'notBool_' and len(args) == 1:
            return f'not ({args[0]})'
        if label == '_&Int_' and len(args) == 2:
            return f'({args[0]} & {args[1]})'
        if label == '_xorInt_' and len(args) == 2:
            return f'({args[0]} xor {args[1]})'
        if label == '_>>Int_' and len(args) == 2:
            return f'({args[0]} >> {args[1]})'
        if label == '#Exists' and len(args) == 2:
            exists_vars, exists_body = _flatten_exists(term)
            return f'exists {", ".join(exists_vars)}. ({_render_kast(exists_body)})'
        if label == 'bits(_,_)_BITS-SYNTAX_Bits_BitsValue_Int' and len(args) == 2:
            return f'bits({args[0]}, {args[1]})'
        if label == '_+Bits__BITS-SYNTAX_Bits_Bits_Bits' and len(args) == 2:
            return f'({args[0]} + {args[1]})'
        if label == 'BitsCast(_)_BITS-SYNTAX_Bits_Bits' and len(args) == 1:
            return f'cast({args[0]})'
        if label == 'BitsCast(_,_)_BITS-SYNTAX_Bits_Bits_Int' and len(args) == 2:
            return f'cast({args[0]}, {args[1]})'
        if label == 'BitsXor(_)_BITS-SYNTAX_Bits_List' and len(args) == 1:
            return _render_list_operator('xor', args[0])
        if label == 'BitsAnd(_)_BITS-SYNTAX_Bits_List' and len(args) == 1:
            return _render_list_operator('and', args[0])
        if label == 'BitsCmp(_,_,_)_BITS-SYNTAX_Bits_Int_Bits_Bits' and len(args) == 3:
            cmp_name = {'0': 'eq', '1': 'ne'}.get(args[0], f'cmp{args[0]}')
            return f'{cmp_name}({args[1]}, {args[2]})'
        if label == '.List':
            return '.List'
        if label == 'ListItem' and len(args) == 1:
            return args[0]
        if label == '_List_':
            return '[' + ', '.join(args) + ']'
        if label == '.Map':
            return '{}'
        if label == '_|->_' and len(args) == 2:
            return f'{args[0]} |-> {args[1]}'
        if label == '_Map_':
            entries = [_render_kast(entry) for entry in _flatten_assoc(term, '_Map_') if _is_map_entry(entry)]
            return _render_collection(entries, prefix='{', suffix='}')
        if label == '.CurrentInfoCellMap':
            return '[]'
        if label == '_CurrentInfoCellMap_':
            return _summarize_currents(term)
        return f'{label}(' + ', '.join(args) + ')'
    if node_type == 'KLabel':
        return term.get('name', '<label>')
    return json.dumps(term, ensure_ascii=True)


def _flatten_exists(term: dict) -> tuple[list[str], dict]:
    variables: list[str] = []
    current = term
    while current.get('node') == 'KApply' and current.get('label', {}).get('name') == '#Exists':
        args = current.get('args', [])
        if len(args) != 2:
            break
        variables.append(_render_kast(args[0]))
        current = args[1]
    return variables, current


def _render_list_operator(operator: str, rendered_list: str) -> str:
    if rendered_list.startswith('[') and rendered_list.endswith(']'):
        return f'{operator}({rendered_list[1:-1]})'
    return f'{operator}({rendered_list})'
