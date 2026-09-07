"""旧静态接口的实例隔离、名称映射与无副作用日志回归。"""

from __future__ import annotations

import io
import json
import logging
from pathlib import Path

import pytest

from kcirct.err_trace import KErrTrace, PathEdge, PathNode


def _graph(target: str, source: str) -> KErrTrace:
    trace = KErrTrace()
    trace.node_map[target] = PathNode(target)
    trace.build_edge(target, source, 'direct')
    return trace


def test_fresh_instances_do_not_share_graph_or_query_annotations() -> None:
    first = _graph('first/out', 'first/in')
    first.differenes.append('first/out')
    first.signal_port_mapping['first/result'] = 'first/out'
    second = KErrTrace()

    assert second.node_map == {}
    assert second.edge_map == []
    assert second.differenes == []
    assert second.signal_port_mapping == {}
    second.node_map['second/out'] = PathNode('second/out')
    second.build_edge('second/out', 'second/in', 'direct')
    assert set(first.node_map) == {'first/out', 'first/in'}
    assert len(first.edge_map) == 2


def test_loading_same_json_does_not_share_nodes_or_edges(tmp_path: Path) -> None:
    original = _graph('top/out', 'top/in')
    saved = tmp_path / 'graph.json'
    original.save_to_json(saved)
    first, second = KErrTrace(), KErrTrace()
    first.load_from_json(saved)
    second.load_from_json(saved)
    first.node_map['top/out'].edges_in.clear()
    first.edge_map[0].attr = 'changed'

    assert second.node_map['top/out'].edges_in == [0]
    assert second.edge_map[0].attr == 'direct'
    copied = tmp_path / 'copy.json'
    second.save_to_json(copied)
    assert json.loads(copied.read_text()) == json.loads(saved.read_text())
    assert set(json.loads(copied.read_text())) == {'nodes', 'edges'}


def test_legacy_mapping_remains_last_alias_and_instance_local(tmp_path: Path) -> None:
    # 只构造旧名称读取器消费的 cell，不伪装成一次真实仿真状态。
    mapping = tmp_path / 'names.kore'
    mapping.write_text(
        "Lbl'-LT-'hw-inputs'-GT-'{}(\"data_in\")\n"
        "Lbl'-LT-'hw-inports'-GT-'{}(\"top/%arg0\")\n"
        "Lbl'-LT-'hw-in-types'-GT-'{}()\n"
        "Lbl'-LT-'hw-outputs'-GT-'{}(\"first\",\"last\")\n"
        "Lbl'-LT-'hw-outports'-GT-'{}(\"top/%arg0\",\"top/%arg0\")\n"
        "Lbl'-LT-'hw-out-types'-GT-'{}()\n"
        "Lbl'-LT-'register'-GT-'{}()\n"
        "Lbl'-LT-'register-proc'-GT-'{}()\n"
    )
    first, second = KErrTrace(), KErrTrace()
    first.set_signal_port_mapping(mapping)

    assert first.change_vcdname2kname('top.last') == 'top/%arg0'
    assert first.signal_port_mapping == {'top/last': 'top/%arg0'}
    assert second.signal_port_mapping == {}
    with pytest.raises(KeyError):
        first.change_vcdname2kname('top.first')


@pytest.mark.parametrize('existing_log', [False, True])
def test_constructor_does_not_create_or_overwrite_logs(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, existing_log: bool
) -> None:
    monkeypatch.chdir(tmp_path)
    logfile = tmp_path / 'txt.log'
    if existing_log:
        logfile.write_text('调用者的既有日志\n')
    registered = dict(logging.Logger.manager.loggerDict)
    first, second = KErrTrace(), KErrTrace()
    first.logger.info('第一份查询')
    second.logger.warning('第二份查询')

    assert logfile.exists() is existing_log
    if existing_log:
        assert logfile.read_text() == '调用者的既有日志\n'
    assert logging.Logger.manager.loggerDict == registered
    assert first.logger is not second.logger
    assert first.logger.handlers[0] is not second.logger.handlers[0]


def test_explicit_log_handler_does_not_receive_other_instance_records() -> None:
    first, second = KErrTrace(), KErrTrace()
    output = io.StringIO()
    handler = logging.StreamHandler(output)
    first.logger.addHandler(handler)
    try:
        first.logger.info('first')
        second.logger.info('second')
        assert output.getvalue() == 'first\n'
    finally:
        first.logger.removeHandler(handler)
        handler.close()


def test_alternating_static_queries_keep_graphs_and_differences_separate(tmp_path: Path) -> None:
    first = _graph('first/out', 'first/in')
    second = _graph('second/out', 'second/in')
    first.differenes.append('first/in')
    before, other, after = (tmp_path / name for name in ('before.txt', 'other.txt', 'after.txt'))
    first.search_path_kname('first/out', before)
    second.search_path_kname('second/out', other)
    first.search_path_kname('first/out', after)

    assert before.read_bytes() == after.read_bytes()
    assert 'is defferenes' in before.read_text()
    assert 'is defferenes' not in other.read_text()
    assert 'first/' not in other.read_text()
    assert 'second/' not in before.read_text()


def test_legacy_node_and_edge_json_fields_are_unchanged() -> None:
    node = {
        'edges_in': [0],
        'edges_out': [1],
        'edge_id': 2,
        'name': 'top/value',
        'depth': 3,
        'is_firmem': False,
        'is_firreg': True,
        'is_constant': False,
    }
    edge = {'to': 'top/source', 'attr': 'seq.firreg', 'edge_id': 2}
    assert PathNode.from_dict(node).to_dict() == node
    assert PathEdge.from_dict(edge).to_dict() == edge
