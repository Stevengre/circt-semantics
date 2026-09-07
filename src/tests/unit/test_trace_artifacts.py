"""用独立小状态核对文件身份、连续历史、元数据与旧格式边界。"""

from __future__ import annotations

import gzip
import hashlib
import json
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING, Any

import pytest
from pyk.kore.parser import KoreParser
from pyk.kore.prelude import SORT_K_ITEM, inj, map_pattern
from pyk.kore.syntax import DV, App, SortApp, String

from kcirct.trace.artifacts import RunArtifacts, exact_time
from kcirct.trace.kore import BITS, KoreReader, bit_vector
from kcirct.trace.model import (
    ArtifactRef,
    Budget,
    CompletionEvidence,
    DumpIndexEntry,
    Observation,
    RunManifest,
    StateIndexEntry,
    StopCode,
    TraceError,
)

if TYPE_CHECKING:
    from pyk.kore.syntax import Pattern

FIXTURE = Path(__file__).parents[1] / 'resources/trace/unit/minimal-state.kore'


def _sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _artifact(path: Path, role: str, root: Path, raw: bytes | None = None) -> ArtifactRef:
    return ArtifactRef(
        role,
        path.relative_to(root).as_posix(),
        _sha(path),
        path.stat().st_size,
        compression='gzip' if raw is not None else 'none',
        uncompressed_sha256=hashlib.sha256(raw).hexdigest() if raw is not None else None,
        uncompressed_size_bytes=len(raw) if raw is not None else None,
    )


def _string(value: str) -> Pattern:
    sort = SortApp('SortString')
    return inj(sort, SORT_K_ITEM, DV(sort, String(value)))


def _bits(value: int) -> Pattern:
    int_sort = SortApp('SortInt')
    return inj(
        SortApp('SortBits'),
        SORT_K_ITEM,
        App(
            BITS,
            args=(inj(int_sort, SortApp('SortBitsValue'), DV(int_sort, String(str(value)))), DV(int_sort, String('8'))),
        ),
    )


def _signals(value: int) -> Pattern:
    return map_pattern((_string('Demo/%a'), _bits(7)), (_string('Demo/%r'), _bits(value)))


def _state_text(current: int, prior: int, extra: dict[str, Pattern] | None = None) -> str:
    root = KoreParser(FIXTURE.read_text()).pattern()
    replacements = {'signals': _signals(current), 'history': _signals(prior), **(extra or {})}

    def change(node: Pattern) -> Pattern:
        if isinstance(node, App):
            for name, value in replacements.items():
                if node.symbol == "Lbl'-LT-'" + name + "'-GT-'":
                    return App(node.symbol, args=(value,))
        return node

    return root.bottom_up(change).text


def _publish(root: Path, manifest: RunManifest, records: list[StateIndexEntry | DumpIndexEntry]) -> Path:
    index = root / 'trace-states.jsonl'
    index.write_text(''.join(json.dumps(record.to_dict(), ensure_ascii=False) + '\n' for record in records))
    manifest = replace(manifest, state_index=_artifact(index, 'state_index', root))
    path = root / 'trace-run.json'
    path.write_text(manifest.to_json())
    return path


def _bundle(
    root: Path, *, extra: dict[str, Pattern] | None = None, recorded_complete: bool = True
) -> tuple[Path, RunManifest, list[StateIndexEntry | DumpIndexEntry]]:
    root.mkdir()
    artifacts = {}
    records: list[StateIndexEntry | DumpIndexEntry] = []
    for index in range(5):
        raw = _state_text(index, max(0, index - 1), extra if index == 2 else None).encode()
        path = root / ('setup.kore' if index == 0 else f'state-{index}.kore.gz')
        path.write_bytes(raw if index == 0 else gzip.compress(raw))
        key = f'state-{index}'
        artifacts[key] = _artifact(path, 'state', root, raw if index else None)
        records.append(
            StateIndexEntry(
                'setup' if index == 0 else f'e{(index - 1) // 2}v{1 + (index - 1) % 2}',
                'setup' if index == 0 else 'post_eval',
                predecessor=None if index == 0 else records[-1].state_id,
                event_index=None if index == 0 else (index - 1) // 2,
                evaluation=None if index == 0 else 1 + (index - 1) % 2,
                time=None if index == 0 else 5 * ((index - 1) // 2),
                time_unit=None if index == 0 else '1ns',
                artifact=key,
                content_sha256=hashlib.sha256(raw).hexdigest(),
                retention='retained',
                completion=CompletionEvidence(status='completed' if recorded_complete else 'not_checked'),
            )
        )
    for event in range(2):
        records.append(DumpIndexEntry(f'dump-{event}', f'e{event}v2', event, 2, event * 5, '1ns'))
    manifest = RunManifest(
        'run-a',
        'Demo',
        artifacts=artifacts,
        protocol={'evaluations_per_input': 2, 'timescale': '1ns'},
        identities={'semantics_binding': {'status': 'unverified'}},
    )
    return _publish(root, manifest, records), manifest, records


def test_readonly_loading_checks_scope_and_real_predecessor(tmp_path: Path) -> None:
    path, _, _ = _bundle(tmp_path / 'run', recorded_complete=False)
    before = {file.name: _sha(file) for file in path.parent.iterdir()}
    with RunArtifacts.open(path) as run:
        state = run.read_state('e1v1')
        previous = run.predecessor('e1v1')
        assert bit_vector(state.signals['Demo/%r']).unsigned == 3
        assert bit_vector(previous.signals['Demo/%r']).unsigned == 2
        assert run.manifest.completion.status == 'not_checked'
        assert run.states['e1v1'].completion.status == 'not_checked'
        assert run.audit['states']['e1v1']['observed_completion'] == 'completed'
        assert run.audit['history_edges'] == [['e0v2', 'e1v1']]
        assert run.audit['semantics_binding']['status'] == 'unverified'
        assert 'e0v1' not in run.audit['states']
        assert run.cost.states_read == 3
    assert {file.name: _sha(file) for file in path.parent.iterdir()} == before


def test_locate_uses_explicit_event_evaluation_and_exact_time(tmp_path: Path) -> None:
    path, _, _ = _bundle(tmp_path / 'run')
    with RunArtifacts.open(path) as run:
        entry, dump = run.locate(Observation('dump', time=5000, time_unit='ps'))
        assert entry.state_id == 'e1v2'
        assert dump is not None and dump.dump_id == 'dump-1'
        entry, dump = run.locate(Observation('post_eval', event_index=1, evaluation=1))
        assert entry.state_id == 'e1v1' and dump is None
        with pytest.raises(TraceError) as error:
            run.locate(Observation('dump', time=3, time_unit='ns'))
        assert error.value.code == StopCode.AMBIGUOUS_OBSERVATION
        with pytest.raises(TraceError):
            run.locate(Observation('dump', sample=1))
    assert exact_time((1 << 60) + 1, '10ns') == ((1 << 60) + 1) * 10_000_000


@pytest.mark.parametrize('corruption', ['missing', 'size', 'hash', 'index_hash', 'manifest_hash'])
def test_modified_or_missing_material_cannot_reuse_cached_evidence(tmp_path: Path, corruption: str) -> None:
    path, _, _ = _bundle(tmp_path / 'run')
    with RunArtifacts.open(path) as run:
        run.read_state('e0v1')
        state = path.parent / 'state-1.kore.gz'
        if corruption == 'missing':
            state.unlink()
        elif corruption == 'size':
            state.write_bytes(state.read_bytes() + b'0')
        elif corruption == 'hash':
            content = bytearray(state.read_bytes())
            content[20] ^= 1
            state.write_bytes(content)
        else:
            changed = path if corruption == 'manifest_hash' else path.parent / 'trace-states.jsonl'
            changed.write_text(changed.read_text() + '\n')
        with pytest.raises(TraceError) as error:
            run.read_state('e0v1')
        assert error.value.code == (StopCode.MISSING_ARTIFACT if corruption == 'missing' else StopCode.HASH_MISMATCH)


def test_explicit_relocation_keeps_original_hash_binding(tmp_path: Path) -> None:
    path, _, _ = _bundle(tmp_path / 'run')
    moved = tmp_path / 'moved-state.gz'
    original = path.parent / 'state-2.kore.gz'
    original.rename(moved)
    with RunArtifacts.open(path, relocations={'state-2.kore.gz': moved}) as run:
        assert bit_vector(run.read_state('e0v2').signals['Demo/%r']).unsigned == 2
    moved.write_bytes(b'new content')
    with RunArtifacts.open(path, relocations={'state-2.kore.gz': moved}) as run, pytest.raises(TraceError) as error:
        run.read_state('e0v2')
    assert error.value.code == StopCode.HASH_MISMATCH


def test_equivalent_entry_paths_keep_identity_and_audit_paths_stable(tmp_path: Path) -> None:
    path, _, _ = _bundle(tmp_path / 'run')
    detour = path.parent / 'detour'
    detour.mkdir()
    equivalent = detour / '..' / path.name
    with RunArtifacts.open(path.resolve()) as canonical, RunArtifacts.open(equivalent) as dotted:
        canonical.read_state('e0v1')
        dotted.read_state('e0v1')
        assert canonical.path == dotted.path == path.resolve()
        assert canonical.manifest.run_id == dotted.manifest.run_id
        assert canonical.manifest_sha256 == dotted.manifest_sha256
        assert canonical.audit['artifacts'] == dotted.audit['artifacts']


def test_equivalent_relocation_paths_keep_resolution_and_audit_stable(tmp_path: Path) -> None:
    path, _, _ = _bundle(tmp_path / 'run')
    moved = tmp_path / 'relocated' / 'state-2.kore.gz'
    moved.parent.mkdir()
    (path.parent / 'state-2.kore.gz').rename(moved)
    detour = moved.parent / 'detour'
    detour.mkdir()
    equivalent = detour / '..' / moved.name
    ref = 'state-2.kore.gz'
    with RunArtifacts.open(path, relocations={ref: moved.resolve()}) as canonical, RunArtifacts.open(
        path, relocations={ref: equivalent}
    ) as dotted:
        canonical.read_state('e0v2')
        dotted.read_state('e0v2')
        assert canonical.relocations == dotted.relocations == {ref: moved.resolve()}
        assert canonical.resolve(canonical.manifest.artifacts['state-2']) == moved.resolve()
        assert dotted.resolve(dotted.manifest.artifacts['state-2']) == moved.resolve()
        assert canonical.audit['artifacts'] == dotted.audit['artifacts']


def test_references_resolve_against_their_own_json_carrier(tmp_path: Path) -> None:
    path, _, _ = _bundle(tmp_path / 'run')
    binding_dir = tmp_path / 'source-binding'
    binding_dir.mkdir()
    source = binding_dir / 'design.v'
    source.write_text('运行绑定的历史源码')
    (path.parent / 'design.v').write_text('同名文件不属于该绑定')
    reference = _artifact(source, 'source', binding_dir)
    with RunArtifacts.open(path) as run:
        assert run.resolve(reference, carrier=binding_dir / 'binding.json') == source
        with pytest.raises(TraceError) as error:
            run.resolve(reference)
        assert error.value.code == StopCode.HASH_MISMATCH


@pytest.mark.parametrize('fault', ['duplicate_id', 'duplicate_position', 'dump_state', 'dump_eval', 'unknown_artifact'])
def test_index_identities_are_not_silently_overwritten(tmp_path: Path, fault: str) -> None:
    path, manifest, records = _bundle(tmp_path / 'run')
    state = records[1]
    assert isinstance(state, StateIndexEntry)
    if fault == 'duplicate_id':
        records.append(state)
    elif fault == 'duplicate_position':
        records.append(replace(state, state_id='alias'))
    elif fault == 'dump_state':
        records.append(DumpIndexEntry('extra', 'missing', 1, 2, 5, 'ns'))
    elif fault == 'dump_eval':
        records.append(DumpIndexEntry('extra', 'e1v2', 1, 1, 5, 'ns'))
    else:
        records[1] = replace(state, artifact='not-registered')
    _publish(path.parent, manifest, records)
    with pytest.raises(TraceError):
        RunArtifacts.open(path)


@pytest.mark.parametrize('gap', ['missing_index', 'not_retained', 'missing_file', 'jump'])
def test_sparse_local_prior_is_available_but_cannot_prove_continuous_history(tmp_path: Path, gap: str) -> None:
    path, manifest, records = _bundle(tmp_path / 'run')
    state = records[2]
    assert isinstance(state, StateIndexEntry)
    if gap == 'missing_index':
        records.pop(2)
        records = [record for record in records if not isinstance(record, DumpIndexEntry) or record.state_id != 'e0v2']
    elif gap == 'not_retained':
        records[2] = replace(state, retention='not_retained', artifact=None)
    elif gap == 'missing_file':
        (path.parent / 'state-2.kore.gz').unlink()
    else:
        current = records[3]
        assert isinstance(current, StateIndexEntry)
        records[3] = replace(current, predecessor='e0v1')
    _publish(path.parent, manifest, records)
    with RunArtifacts.open(path) as run:
        assert bit_vector(run.read_state('e1v1').history['Demo/%r']).unsigned == 2
        with pytest.raises(TraceError) as error:
            run.predecessor('e1v1')
        assert error.value.code == StopCode.HISTORY_GAP


def test_corrupt_metadata_and_incomplete_state_stop_trusted_explanation(tmp_path: Path) -> None:
    cases: tuple[tuple[str, dict[str, Pattern], StopCode], ...] = (
        (
            'metadata',
            {'connection': map_pattern((_string('Demo/%out'), _string('wrong')))},
            StopCode.METADATA_CORRUPTION,
        ),
        ('unfinished', {'cmd': App('LblPending')}, StopCode.INCOMPLETE_EXECUTION),
    )
    for label, extra, expected in cases:
        path, _, _ = _bundle(tmp_path / label, extra=extra)
        with RunArtifacts.open(path) as run:
            run.read_state('e0v1')
            with pytest.raises(TraceError) as error:
                run.read_state('e0v2')
            assert error.value.code == expected


def test_history_mismatch_is_not_replaced_with_recomputed_values(tmp_path: Path) -> None:
    path, _, _ = _bundle(tmp_path / 'run', extra={'history': _signals(99)})
    with RunArtifacts.open(path) as run:
        assert bit_vector(run.read_state('e0v2').history['Demo/%r']).unsigned == 99
        with pytest.raises(TraceError) as error:
            run.predecessor('e0v2')
        assert error.value.code == StopCode.INCONSISTENT_EVIDENCE


def test_lru_stays_bounded_and_reloads_evicted_views(tmp_path: Path) -> None:
    path, _, _ = _bundle(tmp_path / 'run')
    with KoreReader() as reader:
        size = reader.read(path.parent / 'setup.kore').view_bytes
    with RunArtifacts.open(path, budget=Budget(max_cache_bytes=2 * size + 1024)) as run:
        run.read_state('e0v1')
        initial_reads = run.reader.states_read
        run.read_state('e0v1')
        assert run.reader.states_read == initial_reads
        run.read_state('e0v2')
        run.read_state('e1v1')
        before = run.reader.states_read
        run.read_state('e0v1')
        assert run.reader.states_read > before
        assert run.peak_cache_bytes <= run.reader.budget.max_cache_bytes
        assert run.cache_bytes <= run.reader.budget.max_cache_bytes


def test_same_claimed_raw_hash_does_not_bypass_different_gzip_validation(tmp_path: Path) -> None:
    path, manifest, records = _bundle(tmp_path / 'run')
    first = manifest.artifacts['state-1']
    second = manifest.artifacts['state-2']
    second_entry = records[2]
    assert isinstance(second_entry, StateIndexEntry)
    false_artifacts = {**manifest.artifacts, 'state-2': replace(second, uncompressed_sha256=first.uncompressed_sha256)}
    records[2] = replace(second_entry, content_sha256=first.uncompressed_sha256)
    _publish(path.parent, replace(manifest, artifacts=false_artifacts), records)
    with RunArtifacts.open(path) as run:
        run.read_state('e0v1')
        with pytest.raises(TraceError) as error:
            run.read_state('e0v2')
        assert error.value.code == StopCode.HASH_MISMATCH


def test_alternating_runs_with_same_state_names_do_not_share_values(tmp_path: Path) -> None:
    first, _, _ = _bundle(tmp_path / 'first')
    second, manifest, records = _bundle(tmp_path / 'second', extra={'signals': _signals(77)})
    _publish(second.parent, replace(manifest, run_id='run-b'), records)
    with RunArtifacts.open(first) as run_a, RunArtifacts.open(second) as run_b:
        assert bit_vector(run_a.read_state('e0v2').signals['Demo/%r']).unsigned == 2
        assert bit_vector(run_b.read_state('e0v2').signals['Demo/%r']).unsigned == 77
        assert bit_vector(run_a.read_state('e0v2').signals['Demo/%r']).unsigned == 2


def _legacy(root: Path, *, failed: bool = False, protocol: bool = True) -> Path:
    path, _, records = _bundle(root)
    (root / 'design.generic.mlir').write_text('bound execution IR')
    (root / 'inputs.json').write_text('{"schema_version":1,"events":[]}')
    old = [
        {
            'event_index': entry.event_index,
            'evaluation': entry.evaluation,
            'time': entry.time,
            'path': f'state-{index}.kore.gz',
            'source_path': '/old/rolling/simulated.0.kore',
            'sha256_uncompressed': entry.content_sha256,
        }
        for index, entry in enumerate(records[:5])
        if index and isinstance(entry, StateIndexEntry)
    ]
    (root / 'states.json').write_text(json.dumps(old))
    result: dict[str, Any] = {
        'schema_version': 1,
        'top_module': 'Demo',
        'status': 'execution_error' if failed else 'pass',
        'stage': 'execution' if failed else 'complete',
        'event_index': 1,
        'evaluation': 2,
        'event_time': 5,
        'events_completed': 1 if failed else 2,
        'input_sha256': _sha(root / 'design.generic.mlir'),
        'inputs_sha256': _sha(root / 'inputs.json'),
        'last_state': '/old/last-state.kore',
        'definition_dir': '/unavailable/old-definition',
        'definition_sha256': '0' * 64,
    }
    if protocol:
        result.update(evaluations_per_input=2, timescale='1ns')
    path = root / 'result.json'
    path.write_text(json.dumps(result))
    return path


def test_legacy_normalization_is_new_readonly_and_does_not_fabricate_old_audits(tmp_path: Path) -> None:
    source = _legacy(tmp_path / 'legacy')
    before = {path.name: _sha(path) for path in source.parent.iterdir()}
    output = tmp_path / 'normalized'
    with RunArtifacts.open(source, normalization_output=output) as run:
        assert run.manifest.run_id.startswith('legacy-')
        assert run.manifest.completion.status == 'not_checked'
        assert run.manifest.identities['semantics_binding']['status'] == 'unknown'
        assert all(entry.completion.status == 'not_checked' for entry in run.states.values())
        assert any('definition.kore' in text for text in run.manifest.state_coverage['limitations'])
        assert bit_vector(run.predecessor('event-1.eval-1').signals['Demo/%r']).unsigned == 2
        assert run.locate(Observation('dump', event_index=1))[0].evaluation == 2
        assert run.manifest.origin is not None and run.manifest.origin.sha256 == _sha(source)
    assert {path.name: _sha(path) for path in source.parent.iterdir()} == before
    with pytest.raises(TraceError):
        RunArtifacts.open(source, normalization_output=output)


def test_legacy_missing_protocol_does_not_invent_dump_or_event_boundary(tmp_path: Path) -> None:
    source = _legacy(tmp_path / 'legacy', protocol=False)
    with RunArtifacts.open(source, normalization_output=tmp_path / 'normalized') as run:
        assert run.manifest.protocol['status'] == 'unknown'
        assert not run.dumps
        assert bit_vector(run.read_state('event-1.eval-1').signals['Demo/%r']).unsigned == 3
        with pytest.raises(TraceError) as error:
            run.predecessor('event-1.eval-1')
        assert error.value.code == StopCode.HISTORY_GAP


def test_legacy_does_not_use_rolling_or_unbound_failed_last_state(tmp_path: Path) -> None:
    source = _legacy(tmp_path / 'legacy', failed=True)
    (source.parent / 'states.json').write_text('[]')
    (source.parent / 'last-state.kore').write_text(_state_text(7, 6))
    with RunArtifacts.open(source, normalization_output=tmp_path / 'normalized') as run:
        assert set(run.states) == {'setup'}
        assert any('last-state' in text for text in run.manifest.state_coverage['limitations'])
    index = [
        {'event_index': 0, 'evaluation': 1, 'time': 0, 'path': 'simulated.0.kore', 'sha256_uncompressed': '0' * 64}
    ]
    (source.parent / 'states.json').write_text(json.dumps(index))
    with pytest.raises(TraceError) as error:
        RunArtifacts.open(source, normalization_output=tmp_path / 'another')
    assert error.value.code == StopCode.NOT_RETAINED


def test_legacy_wrong_input_hash_is_rejected(tmp_path: Path) -> None:
    source = _legacy(tmp_path / 'legacy')
    (source.parent / 'inputs.json').write_text('different inputs')
    with pytest.raises(TraceError) as error:
        RunArtifacts.open(source, normalization_output=tmp_path / 'normalized')
    assert error.value.code == StopCode.HASH_MISMATCH


def test_absent_index_does_not_discover_unregistered_archives(tmp_path: Path) -> None:
    path, manifest, _ = _bundle(tmp_path / 'run')
    path.write_text(manifest.to_json())
    with RunArtifacts.open(path) as run:
        assert run.states == {}
        assert run.issues[0].code == StopCode.NOT_RETAINED
        with pytest.raises(TraceError):
            run.read_state('e0v1')


def test_many_short_index_records_cannot_bypass_total_metadata_limit(tmp_path: Path) -> None:
    path, manifest, records = _bundle(tmp_path / 'run')
    _publish(path.parent, manifest, records * 50)
    limit = path.stat().st_size + 100
    index = path.parent / 'trace-states.jsonl'
    assert all(len(line.encode()) < limit for line in index.read_text().splitlines())
    assert index.stat().st_size > limit
    with pytest.raises(TraceError) as error:
        RunArtifacts.open(path, budget=Budget(max_state_bytes=limit))
    assert error.value.code == StopCode.STATE_BYTES_BUDGET
    assert '索引元数据' in error.value.message
