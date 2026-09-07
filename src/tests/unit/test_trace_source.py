"""源码关系须来自绑定字节和同一 IR 结构，测试预期独立定义。"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

import pytest

from kcirct.trace.artifacts import RunArtifacts
from kcirct.trace.model import ArtifactRef, Budget, RunManifest, SourceBinding, StopCode, TraceError
from kcirct.trace.source import bind_sources, parse_generic

EXECUTION = """#port = loc(unknown)
"builtin.module"() ({
  "hw.module"() <{sym_name = "Demo", module_type = !hw.modty<input a : i8, output y : i8>, result_locs = [#port]}> ({
  ^bb0(%a: i8):
    %0 = "comb.add"(%a, %a) <{note = "literal loc(unknown) #port"}> : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) : () -> ()
}) : () -> ()
"""
DEBUG = """#newport = loc(unknown)
"builtin.module"() ({
  "hw.module"() <{sym_name = "Demo", module_type = !hw.modty<input a : i8, output y : i8>, result_locs = [#newport]}> ({
  ^bb0(%a: i8 loc("old/rtl/dut.v":1:1)):
    %0 = "comb.add"(%a, %a) <{note = "literal loc(unknown) #port"}> : (i8, i8) -> i8 loc(#here)
    "hw.output"(%0) : (i8) -> () loc(unknown)
  }) : () -> () loc(unknown)
}) : () -> () loc(unknown)
#here = loc("old/rtl/dut.v":2:1 to :17)
"""
RTL = 'module Demo(input a, output y);\nassign y = a + a;\nendmodule\n'


def _artifact(path: Path, role: str, carrier: Path) -> ArtifactRef:
    contents = path.read_bytes()
    return ArtifactRef(
        role, path.relative_to(carrier.parent).as_posix(), hashlib.sha256(contents).hexdigest(), len(contents)
    )


def _fixture(
    tmp_path: Path,
    *,
    execution: str = EXECUTION,
    debug: str = DEBUG,
    rtl: str = RTL,
    mapping: dict[str, Any] | None = None,
) -> tuple[Path, Path, Path]:
    run_dir, binding_dir = tmp_path / 'run', tmp_path / 'bindings'
    run_dir.mkdir()
    binding_dir.mkdir()
    (run_dir / 'execution.mlir').write_text(execution)
    manifest = run_dir / 'trace-run.json'
    run = RunManifest(
        'run-a', 'Demo', artifacts={'execution_ir': _artifact(run_dir / 'execution.mlir', 'execution_ir', manifest)}
    )
    manifest.write_text(run.to_json())
    carrier = binding_dir / 'source-binding.json'
    (binding_dir / 'execution.mlir').write_text(execution)
    (binding_dir / 'debug.mlir').write_text(debug)
    source = binding_dir / 'dut.v'
    source.write_text(rtl)
    execution_ref = _artifact(binding_dir / 'execution.mlir', 'execution_ir', carrier)
    debug_ref = _artifact(binding_dir / 'debug.mlir', 'debug_ir', carrier)
    mapping = {
        'schema_version': 1,
        'executable_sha256': execution_ref.sha256,
        'debug_sha256': debug_ref.sha256,
        'source_files': {'old/rtl/dut.v': 'dut.v'},
        **(mapping or {}),
    }
    (binding_dir / 'map.json').write_text(json.dumps(mapping))
    binding = SourceBinding(
        'run-a',
        execution_ref,
        debug_ref,
        _artifact(binding_dir / 'map.json', 'source_map', carrier),
        (_artifact(source, 'rtl', carrier),),
    )
    carrier.write_text(binding.to_json())
    return manifest, carrier, source


def test_location_aliases_block_arguments_and_complete_structure() -> None:
    left, right = parse_generic(EXECUTION, Budget()), parse_generic(DEBUG, Budget())
    assert left.structure == right.structure
    assert len(left.operations) == 4
    operation = right.operations[2]
    assert (operation.module_symbol, operation.name, operation.results, operation.operands) == (
        'Demo',
        'comb.add',
        ('%0',),
        ('%a', '%a'),
    )
    assert operation.location is not None
    assert (operation.location.file, operation.location.line, operation.location.column) == ('old/rtl/dut.v', 2, 1)


def test_binding_resolves_from_its_own_json_and_has_exact_region(tmp_path: Path) -> None:
    manifest, carrier, source = _fixture(tmp_path)
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
        (location,) = index.locations('Demo', '%0', operation_name='comb.add')
        assert not index.issues
        assert location.precision == 'exact'
        assert (location.line, location.column, location.end_line, location.end_column) == (2, 1, 2, 17)
        assert location.source is not None and location.source.sha256 == hashlib.sha256(source.read_bytes()).hexdigest()
        assert index.artifact_paths[location.source.sha256] == source
        assert str(carrier.parent / 'execution.mlir') in run.verified_artifacts
        assert str(manifest.parent / 'execution.mlir') in run.verified_artifacts


@pytest.mark.parametrize(
    ('before', 'after'),
    [
        ('"comb.add"(%a, %a)', '"comb.add"(%a, %other)'),
        ('(i8, i8) -> i8', '(i8, i8) -> i16'),
        ('note = "literal loc(unknown) #port"', 'note = "changed loc(unknown) #port"'),
        ('%0 =', '%1 ='),
        ('sym_name = "Demo"', 'sym_name = "Other"'),
    ],
)
def test_same_operation_names_cannot_hide_changed_structure(tmp_path: Path, before: str, after: str) -> None:
    manifest, carrier, _ = _fixture(tmp_path, debug=DEBUG.replace(before, after))
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    assert index.precision == 'mapping_mismatch'
    assert index.issues[0].code == StopCode.SOURCE_MISMATCH
    (location,) = index.locations('Demo', '%0')
    assert location.precision == 'mapping_mismatch'
    assert location.source is not None and location.source.role == 'execution_ir'


def test_comments_and_string_delimiters_are_not_source_syntax() -> None:
    commented = DEBUG.replace('"comb.add"', '/* outer /* inner */ loc("fake":1:2) */ "comb.add"')
    assert parse_generic(EXECUTION, Budget()).structure == parse_generic(commented, Budget()).structure
    different = DEBUG.replace('literal loc(unknown) #port', 'literal loc(unknown) #newport')
    assert parse_generic(EXECUTION, Budget()).structure != parse_generic(different, Budget()).structure


def test_quoted_alias_string_is_never_normalized() -> None:
    left = EXECUTION.replace('literal loc(unknown) #port', '#port')
    right = DEBUG.replace('literal loc(unknown) #port', '#newport')
    assert parse_generic(left, Budget()).structure != parse_generic(right, Budget()).structure


def test_source_map_cannot_override_actual_debug_operation(tmp_path: Path) -> None:
    operations = [
        {
            'ordinal': op.ordinal,
            'op': op.name,
            'executable_line': op.line,
            'debug_line': op.line,
            'debug_text': DEBUG.splitlines()[op.line - 1],
        }
        for op in parse_generic(EXECUTION, Budget()).operations
    ]
    operations[2]['debug_line'] = 999
    manifest, carrier, _ = _fixture(tmp_path, mapping={'operations': operations})
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    assert index.precision == 'mapping_mismatch'


def test_source_map_cannot_override_result_identity(tmp_path: Path) -> None:
    operations = [
        {
            'ordinal': left.ordinal,
            'op': left.name,
            'ssa': ', '.join(left.results),
            'executable_line': left.line,
            'debug_line': right.line,
            'debug_text': DEBUG.splitlines()[right.line - 1],
        }
        for left, right in zip(
            parse_generic(EXECUTION, Budget()).operations, parse_generic(DEBUG, Budget()).operations, strict=True
        )
    ]
    operations[2]['ssa'] = '%other'
    manifest, carrier, _ = _fixture(tmp_path, mapping={'operations': operations})
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    assert index.precision == 'mapping_mismatch'
    assert index.issues[0].code == StopCode.SOURCE_MISMATCH


def test_explicit_source_path_mapping_is_required(tmp_path: Path) -> None:
    manifest, carrier, _ = _fixture(tmp_path, mapping={'source_files': {}})
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    (location,) = index.locations('Demo', '%0')
    assert location.precision == 'source_missing'
    assert location.source is None
    assert 'old/rtl/dut.v' in (location.raw_location or '')


def test_changed_source_file_never_uses_current_same_name(tmp_path: Path) -> None:
    manifest, carrier, source = _fixture(tmp_path)
    source.write_text(source.read_text().replace('a + a', 'a - a'))
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    (location,) = index.locations('Demo', '%0')
    assert location.precision == 'mapping_mismatch'
    assert index.issues[0].code == StopCode.HASH_MISMATCH


def test_missing_source_downgrades_without_losing_ir(tmp_path: Path) -> None:
    manifest, carrier, source = _fixture(tmp_path)
    source.unlink()
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    (location,) = index.locations('Demo', '%0')
    assert location.precision == 'source_missing'
    assert location.source is not None and location.source.role == 'execution_ir'
    assert location.line == 5


def test_without_debug_binding_only_ir_is_claimed(tmp_path: Path) -> None:
    manifest, _, _ = _fixture(tmp_path)
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run)
    (location,) = index.locations('Demo', '%0')
    assert location.precision == 'ir_only'
    assert location.line == 5


def test_unknown_location_is_explicit(tmp_path: Path) -> None:
    manifest, carrier, _ = _fixture(tmp_path, debug=DEBUG.replace('loc(#here)', 'loc(unknown)'))
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    (location,) = index.locations('Demo', '%0')
    assert location.precision == 'unknown'


def test_fused_locations_preserve_each_candidate(tmp_path: Path) -> None:
    debug = DEBUG.replace('loc(#here)', 'loc(fused[#here, #second])') + '#second = loc("old/rtl/dut.v":1:1)\n'
    manifest, carrier, _ = _fixture(tmp_path, debug=debug)
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    locations = index.locations('Demo', '%0')
    assert [(location.precision, location.line) for location in locations] == [('fused', 2), ('fused', 1)]


def test_fused_location_filename_punctuation_is_string_content() -> None:
    debug = DEBUG.replace('loc(#here)', 'loc(fused[",":2:1, #here])')
    location = parse_generic(debug, Budget()).operations[2].location
    assert location is not None
    assert [child.file for child in location.children] == [',', 'old/rtl/dut.v']


def test_simple_output_alias_is_declaration_precision(tmp_path: Path) -> None:
    manifest, carrier, _ = _fixture(tmp_path, rtl=RTL.replace('a + a', 'a    '))
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    (location,) = index.locations('Demo', '%0')
    assert location.precision == 'declaration'


@pytest.mark.parametrize('location', ['callsite(#here at #here)', '#undefined', 'fused', ''])
def test_unsupported_locations_downgrade_to_ir(tmp_path: Path, location: str) -> None:
    manifest, carrier, _ = _fixture(tmp_path, debug=DEBUG.replace('loc(#here)', f'loc({location})'))
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    assert index.precision == 'unsupported_format'
    assert index.ir is not None
    assert index.locations('Demo', '%0')[0].source is not None


def test_cyclic_location_aliases_are_rejected() -> None:
    with pytest.raises(TraceError):
        parse_generic(
            DEBUG.replace('#here = loc("old/rtl/dut.v":2:1 to :17)', '#here = loc(#again)\n#again = loc(#here)'),
            Budget(),
        )


def test_fused_depth_is_bounded_before_python_recursion() -> None:
    nested = 'fused[' * 70 + 'unknown' + ']' * 70
    with pytest.raises(TraceError) as caught:
        parse_generic(DEBUG.replace('loc(#here)', f'loc({nested})'), Budget())
    assert caught.value.code == StopCode.UNSUPPORTED_SHAPE


def test_alias_expansion_is_bounded_by_input_size() -> None:
    aliases = '#chain0 = loc(unknown)\n' + ''.join(
        f'#chain{number} = loc(fused[#chain{number - 1}, #chain{number - 1}])\n' for number in range(1, 20)
    )
    with pytest.raises(TraceError) as caught:
        parse_generic(DEBUG.replace('loc(#here)', 'loc(#chain19)') + aliases, Budget())
    assert caught.value.code == StopCode.UNSUPPORTED_SHAPE


def test_wrong_run_identity_does_not_bind_sources(tmp_path: Path) -> None:
    manifest, carrier, _ = _fixture(tmp_path)
    carrier.write_text(carrier.read_text().replace('"run-a"', '"run-b"'))
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    assert index.precision == 'mapping_mismatch'


def test_procedure_mapping_uses_operands_and_rejects_ambiguity(tmp_path: Path) -> None:
    extra = '    "seq.firmem.write_port"(%a, %0) : (i8, i8) -> ()\n'
    execution = EXECUTION.replace('    "hw.output"', extra * 2 + '    "hw.output"')
    debug = DEBUG.replace('    "hw.output"', extra * 2 + '    "hw.output"')
    manifest, carrier, _ = _fixture(tmp_path, execution=execution, debug=debug)
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    assert index.match('Demo', operation_name='seq.firmem.write_port', operands=('%a', '%0')) is None
    assert (
        index.locations('Demo', operation_name='seq.firmem.write_port', operands=('%a', '%0'))[0].precision
        == 'mapping_mismatch'
    )


def test_parser_checks_budget_deadline() -> None:
    def check() -> None:
        raise TraceError(StopCode.TIME_BUDGET, '测试截止')

    with pytest.raises(TraceError) as caught:
        parse_generic(EXECUTION, Budget(), check=check)
    assert caught.value.code == StopCode.TIME_BUDGET


def test_unsupported_custom_format_is_explicit(tmp_path: Path) -> None:
    manifest, carrier, _ = _fixture(tmp_path, debug='module { hw.module @Demo() {} }')
    with RunArtifacts.open(manifest) as run:
        index = bind_sources(run, carrier)
    assert index.precision == 'unsupported_format'


@pytest.mark.parametrize(
    'text',
    [EXECUTION + 'trailing_garbage', EXECUTION.replace('    "hw.output"', '    unparsed_instruction\n    "hw.output"')],
)
def test_unparsed_ir_content_is_never_accepted(text: str) -> None:
    with pytest.raises(TraceError) as caught:
        parse_generic(text, Budget())
    assert caught.value.code == StopCode.UNSUPPORTED_SHAPE
