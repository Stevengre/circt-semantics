"""从独立定义的小状态核对解码、配置拒绝及结构比较。"""

from __future__ import annotations

import hashlib
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from pyk.kore.parser import KoreParser
from pyk.kore.prelude import SORT_K_ITEM, inj, list_pattern, map_pattern
from pyk.kore.syntax import DV, App, SortApp, String

from kcirct.trace.kore import (
    KoreReader,
    bit_vector,
    canonical_digest,
    history_matches,
    list_items,
    map_items,
    metadata_differences,
    scalar,
)
from kcirct.trace.model import StopCode, TraceError

if TYPE_CHECKING:
    from pyk.kore.syntax import Pattern

FIXTURE = Path(__file__).parents[1] / 'resources/trace/unit/minimal-state.kore'


def _item(value: str, sort: str = 'String') -> Pattern:
    """构造指定 sort 的具体值并注入 KItem，用于区分文本相同但类型不同的节点。"""
    source = SortApp('Sort' + sort)
    return inj(source, SORT_K_ITEM, DV(source, String(value)))


def _changed(tmp_path: Path, name: str, replacement: Pattern) -> Path:
    """替换 fixture 中指定 cell 的内容并写入临时状态文件。"""
    root = KoreParser(FIXTURE.read_text()).pattern()
    symbol = "Lbl'-LT-'" + name + "'-GT-'"

    def change(node: Pattern) -> Pattern:
        """在自底向上遍历中仅替换目标 cell，其余 Kore 节点保持不变。"""
        return App(symbol, args=(replacement,)) if isinstance(node, App) and node.symbol == symbol else node

    path = tmp_path / f'{name}.kore'
    path.write_text(root.bottom_up(change).text)
    return path


def test_configuration_views_and_aliases() -> None:
    """验证最小配置可解码信号、历史、存储器、寄存器过程及共享信号的端口别名。"""
    with KoreReader() as reader:
        state = reader.read(FIXTURE)
    assert state.completion.status == 'completed'
    assert set(state.signals) == {'Demo/%a', 'Demo/%r', 'Demo/%mem'}
    assert bit_vector(state.signals['Demo/%a']).unsigned == 7
    assert bit_vector(state.signals['Demo/%r']).unsigned == 9
    assert bit_vector(state.history['Demo/%r']).unsigned == 5
    address, value = map_items(state.signals['Demo/%mem'])[0]
    assert (bit_vector(address).unsigned, bit_vector(address).width) == (2, 5)
    assert (bit_vector(value).unsigned, bit_vector(value).width) == (513, 10)
    assert scalar(state.connection['Demo/%out']) == 'Demo/%r'
    assert len(state.register) == 1
    assert [bit_vector(value).unsigned for value in list_items(state.register_proc['Demo/%read'])] == [1, 2, 0]
    (instance,) = state.instances
    assert (instance.id, instance.module) == ('Demo', 'DemoMod')
    assert [(name, signal) for name, signal, _ in instance.outputs] == [('result', 'Demo/%r'), ('mirror', 'Demo/%r')]
    assert scalar(instance.inputs[0][2]) == 'i8'
    assert scalar(state.cells['top-module']) == 'Demo'


def test_gzip_and_plain_bind_both_hash_layers() -> None:
    """验证普通与 gzip 状态结构一致，原始内容哈希相同而工件哈希独立，读取预算按解压量计。"""
    with KoreReader() as reader:
        plain = reader.read(FIXTURE)
        zipped = reader.read(
            FIXTURE.with_suffix('.kore.gz'),
            artifact_sha256=hashlib.sha256(FIXTURE.with_suffix('.kore.gz').read_bytes()).hexdigest(),
            uncompressed_sha256=hashlib.sha256(FIXTURE.read_bytes()).hexdigest(),
        )
        assert reader.states_read == 2
        assert reader.read_bytes == 2 * FIXTURE.stat().st_size
    assert plain.fingerprints == zipped.fingerprints
    assert plain.uncompressed_sha256 == zipped.uncompressed_sha256
    assert plain.artifact_sha256 != zipped.artifact_sha256


@pytest.mark.parametrize('layer', ['artifact_sha256', 'uncompressed_sha256'])
def test_wrong_hash_is_rejected_and_charged(layer: str) -> None:
    """验证任一哈希层不符均报告对应层错误，失败读取仍消耗字节预算。"""
    with KoreReader() as reader:
        with pytest.raises(TraceError) as caught:
            reader.read(FIXTURE, **{layer: '0' * 64})
        assert caught.value.code == StopCode.HASH_MISMATCH
        assert caught.value.details['layer'] == ('artifact' if layer == 'artifact_sha256' else 'uncompressed')
        assert reader.read_bytes == FIXTURE.stat().st_size


def test_map_order_is_ignored_but_types_and_lists_are_not(tmp_path: Path) -> None:
    """验证结构比较忽略 Map 条目顺序，但保留节点类型和 List 顺序差异。"""
    pairs = [(_item('x'), _item('one')), (_item('y'), _item('two'))]
    with KoreReader() as reader:
        first = reader.read(_changed(tmp_path, 'connection', map_pattern(*pairs)))
        second = reader.read(_changed(tmp_path, 'connection', map_pattern(*reversed(pairs))))
        assert metadata_differences(first, second) == ()
        typed = reader.read(
            _changed(tmp_path, 'connection', map_pattern((_item('x'), _item('one', 'BareId')), pairs[1]))
        )
        assert metadata_differences(first, typed) == ('connection',)
        one = reader.read(_changed(tmp_path, 'procedures', list_pattern(_item('a'), _item('b'))))
        two = reader.read(_changed(tmp_path, 'procedures', list_pattern(_item('b'), _item('a'))))
        assert metadata_differences(one, two) == ('procedures',)


def test_map_duplicate_keys_are_not_overwritten(tmp_path: Path) -> None:
    """验证重复 Map 键触发证据冲突，不能由字典覆盖静默吞掉。"""
    duplicate = map_pattern((_item('x'), _item('a')), (_item('x'), _item('b')))
    with KoreReader() as reader, pytest.raises(TraceError) as caught:
        reader.read(_changed(tmp_path, 'connection', duplicate))
    assert caught.value.code == StopCode.INCONSISTENT_EVIDENCE


def test_history_checks_actual_predecessor(tmp_path: Path) -> None:
    """验证 history 比较使用真实前驱 signals，当前状态不能自动充当自身前驱。"""
    root = KoreParser(FIXTURE.read_text()).pattern()
    pending = [root]
    while pending:
        node = pending.pop()
        if isinstance(node, App) and node.symbol == "Lbl'-LT-'signals'-GT-'":
            signals = node.args[0]
            break
        pending.extend(node.patterns)
    else:
        pytest.fail('独立 fixture 缺少 signals')
    with KoreReader() as reader:
        predecessor = reader.read(FIXTURE)
        assert not history_matches(predecessor, predecessor)
        following = reader.read(_changed(tmp_path, 'history', signals))
        assert history_matches(predecessor, following)


@pytest.mark.parametrize('cell', ['prog', 'setup', 'cmd', 'currents'])
def test_pending_execution_is_not_completed(tmp_path: Path, cell: str) -> None:
    """验证任一执行相关 cell 尚有内容时标记 incomplete 并保留该 cell 名称。"""
    with KoreReader() as reader:
        state = reader.read(_changed(tmp_path, cell, App('LblPending')))
    assert state.completion.status == 'incomplete'
    assert cell in state.completion.details['pending_cells']


def test_unknown_cell_layout_stops_explicitly(tmp_path: Path) -> None:
    """验证未知配置 cell 导致明确的形状拒绝，并在诊断中保留未知名称。"""
    path = tmp_path / 'unknown.kore'
    path.write_text(FIXTURE.read_text().replace("Lbl'-LT-'register-proc'-GT-'", "Lbl'-LT-'future-proc'-GT-'"))
    with KoreReader() as reader, pytest.raises(TraceError) as caught:
        reader.read(path)
    assert caught.value.code == StopCode.UNSUPPORTED_SHAPE
    assert 'future-proc' in caught.value.details['cells']


def test_unknown_operation_keeps_full_type_and_attributes(tmp_path: Path) -> None:
    """验证未知操作仍保留符号、sort、属性及类型，但不能伪装成可解码 Bits 值。"""
    operation = App(
        'LblFutureOperation',
        sorts=(SortApp('SortFuture'),),
        args=(
            _item('future.op'),
            list_pattern(_item('Demo/%a')),
            map_pattern((_item('mode'), _item('x'))),
            _item('i127', 'SignlessIntegerType'),
        ),
    )
    with KoreReader() as reader:
        state = reader.read(_changed(tmp_path, 'connection', map_pattern((_item('Demo/%out'), operation))))
    decoded = state.connection['Demo/%out']
    assert decoded.symbol == 'LblFutureOperation'
    assert decoded.sorts == ('SortFuture{}',)
    assert scalar(decoded.args[3]) == 'i127'
    assert scalar(map_items(decoded.args[2])[0][1]) == 'x'
    with pytest.raises(TraceError) as caught:
        bit_vector(decoded)
    assert caught.value.code == StopCode.UNSUPPORTED_VALUE


def test_wrong_port_arity_is_not_truncated(tmp_path: Path) -> None:
    """验证端口类型数量不足时拒绝状态，不能通过 zip 截断产生貌似完整的端口表。"""
    with KoreReader() as reader, pytest.raises(TraceError) as caught:
        reader.read(_changed(tmp_path, 'hw-out-types', list_pattern(_item('i8', 'SignlessIntegerType'))))
    assert caught.value.code == StopCode.UNSUPPORTED_SHAPE


def test_no_cross_reader_state_or_artifact_changes() -> None:
    """验证独立 reader 不共享 arena 或读取计数，并保持源工件内容不变。"""
    digest = hashlib.sha256(FIXTURE.read_bytes()).hexdigest()
    with KoreReader() as first, KoreReader() as second:
        a, b = first.read(FIXTURE), second.read(FIXTURE)
        assert a.cells['signals'].arena is not b.cells['signals'].arena
        assert canonical_digest(a.cells['signals']) == canonical_digest(b.cells['signals'])
        assert first.states_read == second.states_read == 1
    assert hashlib.sha256(FIXTURE.read_bytes()).hexdigest() == digest


@pytest.mark.parametrize('content', ['broken', FIXTURE.read_text() + ' extra{}()'])
def test_malformed_or_trailing_kore_is_rejected(tmp_path: Path, content: str) -> None:
    """验证无效 Kore 和完整配置后的多余内容均作为非法输入拒绝。"""
    path = tmp_path / 'bad.kore'
    path.write_text(content)
    with KoreReader() as reader, pytest.raises(TraceError) as caught:
        reader.read(path)
    assert caught.value.code == StopCode.INVALID_INPUT
