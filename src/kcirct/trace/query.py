"""请求内的值来源查询；静态连接只有经保存值和读取视图核对后才成为实际边。"""

from __future__ import annotations

import hashlib
import time
from dataclasses import dataclass, replace
from typing import TYPE_CHECKING, Any, Literal, cast
from uuid import uuid4

from .kore import bit_vector
from .model import (
    BitVector,
    Frontier,
    Observation,
    RecordRef,
    StatusAxes,
    StopCode,
    StopReason,
    TraceEdge,
    TraceError,
    TraceNode,
    TraceReport,
    ValueRef,
)
from .semantics import (
    SemanticsProfile,
    bind_semantics,
    evaluate_comb,
    evaluate_memory_write,
    evaluate_register,
    memory_contents,
    memory_dimensions,
    register_initial,
    register_width,
)
from .topology import TraceTopology, integer_type_width, memory_shape

if TYPE_CHECKING:
    from pathlib import Path

    from .artifacts import RunArtifacts
    from .kore import DecodedState
    from .model import CheckRecord, QueryRequest
    from .semantics import MemoryDecision
    from .topology import Operation, TargetBinding, TopologyNode


_REJECT = {
    StopCode.HASH_MISMATCH,
    StopCode.IDENTITY_MISMATCH,
    StopCode.DUPLICATE_IDENTITY,
    StopCode.METADATA_CORRUPTION,
    StopCode.INCONSISTENT_EVIDENCE,
    StopCode.INCOMPLETE_EXECUTION,
}
_BUDGET = {
    StopCode.NODE_BUDGET,
    StopCode.STATE_BUDGET,
    StopCode.TIME_BUDGET,
    StopCode.STATE_BYTES_BUDGET,
    StopCode.READ_BYTES_BUDGET,
    StopCode.CACHE_BYTES_BUDGET,
    StopCode.AST_NODES_BUDGET,
    StopCode.AST_DEPTH_BUDGET,
}


@dataclass(frozen=True)
class _Dependency:
    ref: ValueRef
    kind: Literal['data', 'control', 'alias', 'prior_state', 'capture', 'write', 'static_candidate']
    label: str
    expand: bool = True


@dataclass(frozen=True)
class _Write:
    operation: Operation
    decision: MemoryDecision
    refs: tuple[ValueRef, ...]
    values: tuple[BitVector, ...]
    prior_clock: BitVector | None
    dimensions: tuple[int, int, int]
    source_sha256: str


def _reason(error: TraceError) -> StopReason:
    return StopReason(error.code, error.message, error.details)


def _id(ref: ValueRef) -> str:
    return 'value:' + hashlib.sha256(ref.to_json().encode()).hexdigest()


class _Query:
    """非公共执行器；公开入口自行绑定来源，不接受调用者指定语义解释器。"""

    def __init__(
        self,
        run: RunArtifacts,
        request: QueryRequest,
        topology: TraceTopology,
        profile: SemanticsProfile,
        check: CheckRecord | None = None,
    ) -> None:
        self.run, self.request, self.topology, self.profile, self.check = run, request, topology, profile, check
        self.started = time.monotonic()
        self.deadline = min(run.reader.deadline, self.started + request.budget.max_seconds)
        self.nodes: dict[str, TraceNode] = {}
        self.edges: list[TraceEdge] = []
        self.frontier: list[Frontier] = []
        self.expanded: set[str] = set()
        self.state_ids = {run.setup_id}
        self.memory_writes: dict[tuple[str, str], _Write] = {}
        self.execution = 'not_checked'
        self.root: str | None = None

    def _tick(self) -> None:
        if time.monotonic() >= self.deadline:
            raise TraceError(StopCode.TIME_BUDGET, '查询达到截止时间')

    def _state(self, state_id: str) -> DecodedState:
        self._tick()
        entry = self.run.states.get(state_id)
        if entry is None:
            raise TraceError(StopCode.HISTORY_GAP, '状态索引缺少真实前驱', state_id=state_id)
        first, last = self.request.window.first_event, self.request.window.last_event
        if entry.event_index is not None and (
            (first is not None and entry.event_index < first) or (last is not None and entry.event_index > last)
        ):
            raise TraceError(StopCode.WINDOW_BOUNDARY, '已到用户指定的事件窗口边界', state_id=state_id)
        if entry.phase == 'setup' and first is not None and first > 0:
            raise TraceError(StopCode.WINDOW_BOUNDARY, 'setup 位于用户指定窗口之前')
        if state_id not in self.state_ids:
            if len(self.state_ids) >= self.request.budget.max_states:
                raise TraceError(StopCode.STATE_BUDGET, '查询达到不同状态位置的预算')
            self.state_ids.add(state_id)
        return self.run.read_state(state_id)

    def _ref(
        self,
        signal: str,
        state: str,
        view: Literal['observed', 'operand', 'committed', 'prior'],
        *,
        address: str | None = None,
    ) -> ValueRef:
        node = self.topology.nodes.get(signal)
        return ValueRef(
            self.run.manifest.run_id,
            state,
            node.instance_id if node and node.instance_id else '<unknown>',
            signal,
            signal,
            view,
            address=address,
        )

    def _value(self, ref: ValueRef, state: DecodedState) -> tuple[BitVector, dict[str, Any]]:
        node = self.topology.nodes.get(ref.result)
        prior = ref.view == 'prior' or (ref.view == 'operand' and node is not None and node.storage_kind is not None)
        cell = state.history if prior else state.signals
        if node is not None and node.storage_kind == 'memory_cell':
            if ref.address is None:
                raise TraceError(StopCode.UNSUPPORTED_SHAPE, '存储值查询需要 memory_cell 和明确地址')
            writer, dimensions = self._memory_shape(node.signal_id)
            del writer
            if int(ref.address) >= dimensions[0]:
                raise TraceError(StopCode.INVALID_INPUT, '请求地址超出存储深度')
            if ref.result not in cell and not prior and self.run.states[ref.state_id].phase != 'setup':
                raise TraceError(StopCode.MISSING_VALUE, '提交状态缺少存储 Map')
            memory = memory_contents(cell.get(ref.result), dimensions)
            value = memory.get(int(ref.address), BitVector.from_int(0, dimensions[1]))
            present = int(ref.address) in memory
            return self._slice(value, ref), {
                'saved_cell': 'history' if prior else 'signals',
                'saved_value': present,
                'address': ref.address,
                'memory_entry_present': present,
                'initialization': None if present else 'bound_empty_memory_default_zero',
            }
        if ref.result not in cell:
            if prior and node is not None and node.storage_kind == 'register' and node.operation is not None:
                value, contract = register_initial(node.operation, self.profile)
                return self._slice(value, ref), {
                    'saved_cell': 'history',
                    'saved_value': False,
                    'origin': 'initialization_contract',
                    'initialization': contract,
                    'history_entry_present': False,
                }
            raise TraceError(StopCode.MISSING_VALUE, '保存状态没有该读取视图的值', signal=ref.result, view=ref.view)
        value = self._slice(bit_vector(cell[ref.result]), ref)
        return value, {'saved_cell': 'history' if prior else 'signals', 'saved_value': True}

    @staticmethod
    def _slice(value: BitVector, ref: ValueRef) -> BitVector:
        if ref.bit_range is None:
            return value
        low, high = ref.bit_range.low, ref.bit_range.high
        if high >= value.width:
            raise TraceError(StopCode.INVALID_INPUT, '请求位范围超出保存值位宽')
        return BitVector.from_int((value.unsigned >> low) % (1 << (high - low + 1)), high - low + 1)

    def _add(self, ref: ValueRef, *, candidate: bool = False) -> str:
        identity = _id(ref)
        if identity in self.nodes:
            return identity
        if len(self.nodes) >= self.request.budget.max_nodes:
            raise TraceError(StopCode.NODE_BUDGET, '查询达到节点预算', max_nodes=self.request.budget.max_nodes)
        node = self.topology.nodes.get(ref.result)
        entry = self.run.states[ref.state_id]
        evidence: tuple[RecordRef, ...] = ()
        if entry.artifact is not None:
            artifact = self.run.manifest.artifacts[entry.artifact]
            evidence = (RecordRef(artifact.path, id=entry.state_id, sha256=artifact.sha256),)
        self.nodes[identity] = TraceNode(
            identity,
            ref,
            operation_name=(
                node.operation.name if node and node.operation else 'direct' if node and node.direct_source else None
            ),
            observation=Observation(
                entry.phase,
                state_id=entry.state_id,
                event_index=entry.event_index,
                evaluation=entry.evaluation,
                time=entry.time,
                time_unit=entry.time_unit,
            ),
            evidence=evidence,
            facts={'static_candidate': True} if candidate else {},
        )
        return identity

    def _populate(self, identity: str) -> None:
        node = self.nodes[identity]
        state = self._state(node.ref.state_id)
        if node.ref.result.startswith('procedure:'):
            operation = self.topology.procedures[int(node.ref.result.split(':')[1])]
            write = self._memory_write(operation.operands[0], node.ref.state_id, state)
            self.nodes[identity] = replace(
                node, operation_name=operation.name, facts=self._write_facts(write, node.ref)
            )
            return
        value, facts = self._value(node.ref, state)
        self.nodes[identity] = replace(node, value=value, type=f'i{value.width}', facts=facts)

    def _same(self, first: BitVector | None, second: BitVector, message: str, **details: Any) -> None:
        if first != second:
            raise TraceError(
                StopCode.INCONSISTENT_EVIDENCE,
                message,
                saved=first.to_dict() if first else None,
                computed=second.to_dict(),
                **details,
            )

    def _previous(self, ref: ValueRef) -> ValueRef:
        entry = self.run.states[ref.state_id]
        if entry.predecessor is None:
            raise TraceError(StopCode.INITIALIZATION, '来源已到 setup 初始化边界')
        try:
            self._state(entry.predecessor)
        except TraceError as error:
            if error.code in {StopCode.NOT_RETAINED, StopCode.MISSING_ARTIFACT}:
                raise TraceError(StopCode.HISTORY_GAP, '前驱状态未保留或缺失', state_id=entry.predecessor) from error
            raise
        self.run.predecessor(ref.state_id)
        return self._ref(ref.result, entry.predecessor, 'committed', address=ref.address)

    def _expand(self, identity: str) -> tuple[_Dependency, ...]:
        saved = self.nodes[identity]
        ref, node = saved.ref, self.topology.nodes.get(saved.ref.result)
        if ref.result.startswith('procedure:'):
            self._populate(identity)
            return self._write_dependencies(ref)
        if saved.value is None:
            self._populate(identity)
            saved = self.nodes[identity]
        state = self._state(ref.state_id)
        if ref.bit_range is not None:
            return (
                _Dependency(replace(ref, bit_range=None), 'data', f'bits:{ref.bit_range.high}:{ref.bit_range.low}'),
            )
        if node is None:
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, '信号没有 setup 声明', signal=ref.result)
        if node.unsupported:
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, node.unsupported, signal=ref.result)
        if ref.view == 'prior' or (ref.view == 'operand' and node.storage_kind):
            if saved.facts.get('origin') == 'initialization_contract':
                if self.run.states[ref.state_id].phase != 'setup':
                    self._previous(ref)
                return ()
            previous = self._previous(ref)
            actual, _ = self._value(previous, self._state(previous.state_id))
            self._same(saved.value, actual, '旧值与连续前驱提交值不一致')
            return (_Dependency(previous, 'prior_state', 'history = predecessor.signals'),)
        if self.run.states[ref.state_id].phase == 'setup':
            self.nodes[identity] = replace(saved, facts=dict(saved.facts, origin='setup_initial_value'))
            return ()
        if node.direct_source:
            source = self._ref(node.direct_source, ref.state_id, 'operand')
            value, _ = self._value(source, state)
            self._same(saved.value, value, 'direct 保存值与实际读取来源不一致')
            relation = next(
                (
                    edge.relation
                    for edge in self.topology.edges
                    if edge.source == node.direct_source and edge.target == ref.result
                ),
                'direct',
            )
            return (_Dependency(source, 'alias', relation),)
        if node.storage_kind:
            return self._storage(identity, node, state)
        if node.operation is None:
            ports = [
                port
                for port in self.topology.port_aliases
                if port.signal_id == ref.result and port.direction == 'input'
            ]
            if not ports:
                raise TraceError(StopCode.UNSUPPORTED_SHAPE, '无来源的保存信号不是已声明输入')
            self.nodes[identity] = replace(saved, facts=dict(saved.facts, origin='external_input_snapshot'))
            return ()
        if node.operation.name == 'seq.firmem.read_port':
            return self._read_port(identity, node, state)
        refs = tuple(self._ref(signal, ref.state_id, 'operand') for signal in node.operation.operands)
        values = tuple(self._value(operand, state)[0] for operand in refs)
        evaluation = evaluate_comb(node.operation, values)
        self._same(saved.value, evaluation.value, '组合规则重算与保存值不一致', operation=node.operation.name)
        self.nodes[identity] = replace(saved, facts=dict(saved.facts, **(evaluation.facts or {}), rule_verified=True))
        return tuple(
            _Dependency(
                refs[index],
                cast("Literal['control', 'data', 'static_candidate']", kind),
                f'operand:{index}',
                expand=kind != 'static_candidate',
            )
            for kind, indices in (
                ('control', evaluation.controls),
                ('data', evaluation.data),
                ('static_candidate', evaluation.candidates),
            )
            for index in indices
        )

    def _storage(self, identity: str, node: TopologyNode, state: DecodedState) -> tuple[_Dependency, ...]:
        if node.storage_kind == 'memory_cell':
            return self._memory_cell(identity, node, state)
        if node.storage_kind != 'register' or node.operation is None:
            raise TraceError(StopCode.UNSUPPORTED_OPERATION, '该存储操作尚无动态解释', operation=node.storage_kind)
        op = node.operation
        width = register_width(op)
        if node.width != width:
            raise TraceError(StopCode.INCONSISTENT_EVIDENCE, 'register 声明与 firreg 输出位宽不同')
        saved = self.nodes[identity]
        ref = saved.ref
        self._previous(ref)
        self._clock(op.operands[1])
        refs = tuple(self._ref(signal, ref.state_id, 'operand') for signal in op.operands)
        values = tuple(self._value(operand, state)[0] for operand in refs)
        old_ref = self._ref(ref.result, ref.state_id, 'prior')
        old, old_facts = self._value(old_ref, state)
        clock_ref = self._ref(op.operands[1], ref.state_id, 'prior')
        prior_clock = bit_vector(state.history[op.operands[1]]) if op.operands[1] in state.history else None
        decision = evaluate_register(op, values, old, prior_clock)
        self._same(saved.value, decision.value, '寄存器规则判定与保存的提交值不一致', decision=decision.decision)
        facts = dict(
            saved.facts,
            rule_verified=True,
            decision=decision.decision,
            edge=decision.edge,
            bootstrap=decision.bootstrap,
            clock_id=op.operands[1],
            clock=values[1].to_dict(),
            prior_clock=prior_clock.to_dict() if prior_clock is not None else None,
            prior_clock_origin='history' if prior_clock is not None else 'bound_missing_history_x',
            old=old.to_dict(),
            old_origin=old_facts.get('origin', 'saved_history'),
            initialization=old_facts.get('initialization'),
            next=values[0].to_dict(),
            reset=values[2].to_dict() if len(values) == 4 else None,
            reset_value=values[3].to_dict() if len(values) == 4 else None,
            commit=ref.to_dict(),
            native_operands=[operand.to_dict() for operand in refs],
            selected_operand=decision.selected,
        )
        self.nodes[identity] = replace(saved, facts=facts)
        dependencies = [_Dependency(refs[1], 'control', 'current_clock')]
        if prior_clock is not None:
            dependencies.append(_Dependency(clock_ref, 'control', 'prior_clock'))
        if len(refs) == 4:
            dependencies.append(
                _Dependency(refs[2], 'control' if decision.edge else 'static_candidate', 'sync_reset', decision.edge)
            )
        if decision.selected is None:
            dependencies.append(_Dependency(old_ref, 'prior_state', 'no_edge_hold'))
        else:
            dependencies.append(_Dependency(refs[decision.selected], 'capture', decision.decision))
        for index in (0, 3) if len(refs) == 4 else (0,):
            if index != decision.selected:
                dependencies.append(_Dependency(refs[index], 'static_candidate', f'operand:{index}', False))
        return tuple(dependencies)

    def _memory_shape(self, signal: str) -> tuple[Operation, tuple[int, int, int]]:
        node = self.topology.nodes.get(signal)
        if node is None:
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, '存储引用没有声明')
        users = [op for op in self.topology.procedures if op.operands and op.operands[0] == signal]
        users.extend(
            other.operation
            for other in self.topology.nodes.values()
            if other.operation is not None and other.operation.operands and other.operation.operands[0] == signal
        )
        writers = [op for op in users if op.name == 'seq.firmem.write_port']
        if len(writers) != 1 or any(op.name not in {'seq.firmem.write_port', 'seq.firmem.read_port'} for op in users):
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, '仅支持一个独立写口；多写口、合并口或未知存储用户不受支持')
        return writers[0], memory_dimensions(node, writers[0])

    def _write_ref(self, operation: Operation, state_id: str) -> ValueRef:
        return ValueRef(
            self.run.manifest.run_id,
            state_id,
            operation.instance_id or '<unknown>',
            f'procedure:{operation.procedure_index}',
            f'procedure:{operation.procedure_index}',
            'operand',
        )

    def _memory_write(self, signal: str, state_id: str, state: DecodedState) -> _Write:
        writer, dimensions = self._memory_shape(signal)
        self._previous(self._ref(signal, state_id, 'committed'))
        cache_key = state_id, signal
        if cache_key in self.memory_writes:
            cached = self.memory_writes[cache_key]
            if cached.source_sha256 != state.uncompressed_sha256:
                raise TraceError(StopCode.HASH_MISMATCH, '写索引的源状态发生变化')
            return cached
        self._clock(writer.operands[2])
        refs = tuple(self._ref(operand, state_id, 'operand') for operand in writer.operands[1:])
        values = tuple(self._value(ref, state)[0] for ref in refs)
        prior_clock = bit_vector(state.history[writer.operands[2]]) if writer.operands[2] in state.history else None
        before = memory_contents(state.history.get(signal), dimensions)
        if signal not in state.signals:
            raise TraceError(StopCode.MISSING_VALUE, '写口求值结束后没有存储 Map')
        after = memory_contents(state.signals[signal], dimensions)
        decision = evaluate_memory_write(dimensions, values, before, prior_clock)
        expected = dict(before)
        if decision.decision == 'write':
            expected[decision.address.unsigned] = decision.data
        if after != expected:
            raise TraceError(
                StopCode.INCONSISTENT_EVIDENCE,
                '单写口规则与保存存储前后状态不一致',
                memory_id=signal,
                state_id=state_id,
                decision=decision.decision,
                differing_addresses=[
                    str(address)
                    for address in sorted(set(after) | set(expected))
                    if after.get(address) != expected.get(address)
                ],
            )
        del before, after, expected
        result = _Write(writer, decision, refs, values, prior_clock, dimensions, state.uncompressed_sha256)
        self.memory_writes[cache_key] = result
        return result

    def _write_facts(self, write: _Write, ref: ValueRef) -> dict[str, Any]:
        decision = write.decision
        return {
            'decision': decision.decision,
            'edge': decision.edge,
            'bootstrap': decision.bootstrap,
            'memory_id': write.operation.operands[0],
            'clock_id': write.operation.operands[2],
            'address': decision.address.to_dict(),
            'data': decision.data.to_dict(),
            'enable': write.values[2].to_dict(),
            'clock': write.values[1].to_dict(),
            'prior_clock': write.prior_clock.to_dict() if write.prior_clock is not None else None,
            'prior_clock_origin': 'history' if write.prior_clock is not None else 'bound_missing_history_x',
            'mask': write.values[4].to_dict() if len(write.values) == 5 else None,
            'mask_origin': 'actual_operand' if len(write.values) == 5 else 'no_mask_operand_full_word',
            'old': decision.old.to_dict(),
            'new': decision.new.to_dict(),
            'scalar_operands': [operand.to_dict() for operand in write.refs],
            'native_operand_ids': list(write.operation.operands),
            'memory_map_view': 'pre_commit_signals_verified_against_history',
            'commit': ref.to_dict() if decision.decision == 'write' else None,
            'source_sha256': write.source_sha256,
            'rule_verified': True,
            'write_latency': 1,
            'write_queue': False,
            'prepare_scope': '实参来源由图中的 operand/history 与 firreg capture 边恢复，不推导固定事件偏移',
        }

    def _write_dependencies(self, ref: ValueRef) -> tuple[_Dependency, ...]:
        operation = self.topology.procedures[int(ref.result.split(':')[1])]
        write = self._memory_write(operation.operands[0], ref.state_id, self._state(ref.state_id))
        dependencies = [
            _Dependency(
                operand,
                'control' if index in (1, 2, 4) else 'data',
                ('address', 'clock', 'enable', 'data', 'mask')[index],
            )
            for index, operand in enumerate(write.refs)
        ]
        if write.prior_clock is not None:
            dependencies.append(
                _Dependency(self._ref(operation.operands[2], ref.state_id, 'prior'), 'control', 'prior_clock')
            )
        return tuple(dependencies)

    def _memory_cell(self, identity: str, node: TopologyNode, state: DecodedState) -> tuple[_Dependency, ...]:
        saved = self.nodes[identity]
        assert saved.ref.address is not None
        write = self._memory_write(node.signal_id, saved.ref.state_id, state)
        writes_address = write.decision.decision == 'write' and write.decision.address.unsigned == int(
            saved.ref.address
        )
        prior = self._ref(node.signal_id, saved.ref.state_id, 'prior', address=saved.ref.address)
        old, _ = self._value(prior, state)
        expected = write.decision.data if writes_address else old
        self._same(saved.value, expected, '请求地址的保存值与有效写或保持不一致')
        facts = dict(
            saved.facts,
            decision='memory_write' if writes_address else 'memory_hold',
            written_address=str(write.decision.address.unsigned) if write.decision.decision == 'write' else None,
            write_decision=write.decision.decision,
            old=old.to_dict(),
            new=expected.to_dict(),
            source_sha256=write.source_sha256,
            rule_verified=True,
        )
        self.nodes[identity] = replace(saved, facts=facts)
        dependencies = [
            _Dependency(prior, 'prior_state', 'overwritten_old_value' if writes_address else 'no_write_to_address')
        ]
        if writes_address:
            dependencies.append(
                _Dependency(
                    self._write_ref(write.operation, saved.ref.state_id), 'write', 'effective_same_address_write'
                )
            )
        return tuple(dependencies)

    def _read_port(self, identity: str, node: TopologyNode, state: DecodedState) -> tuple[_Dependency, ...]:
        saved, op = self.nodes[identity], node.operation
        assert op is not None
        if (
            op.unsupported
            or len(op.operands) not in (3, 4)
            or len(op.result_types) != 1
            or len(op.input_types) != len(op.operands)
        ):
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, '仅支持独立 RL0 read_port 的三或四实参整数形状')
        writer, dimensions = self._memory_shape(op.operands[0])
        del writer
        declaration_node = self.topology.nodes.get(op.operands[0])
        declaration = declaration_node.operation if declaration_node is not None else None
        if declaration is None or len(declaration.result_types) != 1:
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, '读口引用的存储声明缺少唯一结果类型')
        expected_types = (dimensions[2], 1) + ((1,) if len(op.operands) == 4 else ())
        if (
            tuple(integer_type_width(typ) for typ in op.input_types[1:]) != expected_types
            or integer_type_width(op.result_types[0]) != dimensions[1]
            or memory_shape(op.input_types[0]) != memory_shape(declaration.result_types[0])
        ):
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, '读口地址、使能或返回类型不匹配')
        self._clock(op.operands[2])
        refs = tuple(self._ref(signal, saved.ref.state_id, 'operand') for signal in op.operands[1:])
        values = tuple(self._value(ref, state)[0] for ref in refs)
        address, enable = values[0], values[2] if len(values) == 3 else BitVector.from_int(1, 1)
        if address.unsigned >= dimensions[0]:
            raise TraceError(StopCode.UNSUPPORTED_SHAPE, '读地址超出存储深度')
        dependencies = [_Dependency(refs[0], 'data', 'read_address')]
        if len(refs) == 3:
            dependencies.append(_Dependency(refs[2], 'control', 'read_enable'))
        if not enable.unsigned:
            self._same(saved.value, BitVector.from_int(0, dimensions[1]), '禁用读的保存值不是规则要求的零')
            self.nodes[identity] = replace(saved, facts=dict(saved.facts, decision='disabled_read', rule_verified=True))
            return tuple(dependencies)
        write = self._memory_write(op.operands[0], saved.ref.state_id, state)
        if write.decision.decision == 'write' and write.decision.address.unsigned == address.unsigned:
            raise TraceError(
                StopCode.UNSUPPORTED_MEMORY_ORDER,
                '同次求值读写同址；快照未记录读取调度顺序',
                memory_id=op.operands[0],
                address=str(address.unsigned),
                state_id=saved.ref.state_id,
            )
        prior = self._ref(op.operands[0], saved.ref.state_id, 'prior', address=str(address.unsigned))
        value, _ = self._value(prior, state)
        committed, _ = self._value(replace(prior, view='committed'), state)
        self._same(value, committed, '本次未写读地址但前后存储值不一致')
        self._same(saved.value, value, 'RL0 保存读值与可证明的地址值不一致')
        self.nodes[identity] = replace(
            saved,
            facts=dict(
                saved.facts, decision='read_unchanged_address', read_address=address.to_dict(), rule_verified=True
            ),
        )
        dependencies.append(_Dependency(prior, 'data', 'unchanged_address_history'))
        return tuple(dependencies)

    def _clock(self, signal: str) -> None:
        """允许已核验的一位输入/常量及 direct/to_clock 链，拒绝推断任意生成时钟。"""
        seen: set[str] = set()
        while signal not in seen:
            self._tick()
            seen.add(signal)
            node = self.topology.nodes.get(signal)
            if node is None or node.unsupported or node.storage_kind or node.width not in (None, 1):
                break
            if node.direct_source:
                signal = node.direct_source
                continue
            op = node.operation
            if node.width != 1:
                break
            if op is not None and op.name == 'seq.to_clock' and len(op.operands) == 1:
                signal = op.operands[0]
                continue
            if op is not None and op.name == 'hw.constant' and not op.operands:
                return
            if op is None and any(
                port.signal_id == signal
                and port.direction == 'input'
                and port.instance_id == self.run.manifest.top_module
                for port in self.topology.port_aliases
            ):
                return
            break
        raise TraceError(StopCode.UNSUPPORTED_CLOCK, '时钟不属于已验证的一位输入或 direct/to_clock 连接', signal=signal)

    def execute(self, binding: TargetBinding) -> TraceReport:
        active: set[str] = set()
        try:
            entry, dump = self.run.locate(self.request.observation)
            self._state(entry.state_id)
            self.execution = 'completed'
            if binding.signal_id is None:
                raise TraceError(StopCode.UNSUPPORTED_OPERATION, '该目标类型尚无动态解释', kind=binding.kind)
            root = self._ref(
                binding.signal_id,
                entry.state_id,
                'observed' if binding.kind == 'signal' else 'committed',
                address=binding.address,
            )
            root = replace(root, bit_range=self.request.target.bit_range)
            if binding.kind == 'memory_write_port':
                if binding.procedure_index is None:
                    raise TraceError(StopCode.IDENTITY_MISMATCH, '写口缺少 procedure 身份')
                root = self._write_ref(self.topology.procedures[binding.procedure_index], entry.state_id)
            self.root = self._add(root)
            self._populate(self.root)
            if dump is not None and binding.kind == 'signal':
                aliases = self.topology.nodes[binding.signal_id].aliases
                dumped = [value for name, value in dump.values.items() if name == binding.name or name in aliases]
                for value in dumped:
                    self._same(self.nodes[self.root].value, self._slice(value, root), 'dump 与保存的目标端口值不一致')
            stack = [(self.root, False)]
            while stack:
                identity, leaving = stack.pop()
                if leaving:
                    active.discard(identity)
                    self.expanded.add(identity)
                    continue
                if identity in self.expanded:
                    continue
                active.add(identity)
                stack.append((identity, True))
                try:
                    self._tick()
                    for dependency in self._expand(identity):
                        child = self._add(dependency.ref, candidate=not dependency.expand)
                        self.edges.append(TraceEdge(child, identity, dependency.kind, dependency.label))
                        if dependency.expand:
                            if child in active:
                                self.frontier.append(
                                    Frontier(StopReason(StopCode.CYCLE, '候选依赖在同一读取视图形成环'), child)
                                )
                            else:
                                stack.append((child, False))
                except TraceError as error:
                    self.frontier.append(Frontier(_reason(error), identity, self.nodes[identity].ref))
                    if error.code in _BUDGET or error.code in _REJECT:
                        for pending, leaving_pending in stack:
                            if not leaving_pending:
                                self.frontier.append(Frontier(_reason(error), pending, self.nodes[pending].ref))
                        break
        except TraceError as error:
            self.frontier.append(Frontier(_reason(error), self.root))
        return self.report()

    def report(self) -> TraceReport:
        rejected = any(item.reason.code in _REJECT for item in self.frontier)
        incomplete = any(item.reason.code == StopCode.INCOMPLETE_EXECUTION for item in self.frontier)
        metadata_invalid = any(item.reason.code == StopCode.METADATA_CORRUPTION for item in self.frontier)
        internal_error = any(item.reason.code == StopCode.INTERNAL_ERROR for item in self.frontier)
        status = StatusAxes(
            execution='incomplete' if incomplete else 'completed' if self.execution == 'completed' else 'not_checked',
            design_check='failed' if self.check and self.check.kind != 'suspicious_observation' else 'not_run',
            reference_comparison='not_run',
            metadata_integrity='invalid' if metadata_invalid else 'valid' if self.run.checked_states else 'not_checked',
            query='error' if internal_error else 'rejected' if rejected else 'partial' if self.frontier else 'complete',
        )
        artifacts = tuple(
            ref
            for ref in self.run.manifest.artifacts.values()
            if str(self.run.path.absolute().parent / ref.path) in self.run.verified_artifacts
        )
        return TraceReport(
            str(uuid4()),
            self.run.manifest.run_id,
            self.request,
            status,
            run=RecordRef(self.run.path.name, self.run.manifest.run_id, self.run.manifest_sha256),
            check=self.check,
            nodes=tuple(self.nodes.values()),
            edges=tuple(self.edges),
            frontier=tuple(self.frontier),
            artifacts=artifacts,
            scope={
                'root_node': self.root,
                'audit': self.run.audit,
                'semantics_binding': self.profile.binding,
                'semantics_source_sha256': self.profile.source_sha256,
                'definition_sha256': self.profile.definition_sha256,
                'memory_writes': [
                    dict(self._write_facts(write, self._write_ref(write.operation, state_id)), state_id=state_id)
                    for (state_id, _), write in self.memory_writes.items()
                ],
                'design_conclusion': '检查结果来自已提交的独立检查；来源查询本身不判定设计正确性',
            },
            limitations=self.profile.limitations,
            cost=replace(
                self.run.cost,
                nodes=len(self.nodes),
                states_read=len(self.state_ids),
            ),
        )


def query(
    run: RunArtifacts, request: QueryRequest, *, check: CheckRecord | None = None, check_carrier: Path | None = None
) -> TraceReport:
    """公共查询逻辑；每次由门面创建匹配 request.budget 的独立 RunArtifacts。"""
    topology = TraceTopology.from_run(run)
    binding = topology.resolve(request.target)
    if check is not None:
        from .checks import normalize_check

        check = normalize_check(run, topology, check, carrier=check_carrier)
        check_state, check_dump = run.locate(check.observation)
        query_state, query_dump = run.locate(request.observation)
        targets_match = any(
            topology.resolve(target).target_id == binding.target_id and target.bit_range == request.target.bit_range
            for target in check.targets
        )
        if (check_state.state_id, check_dump.dump_id if check_dump else None) != (
            query_state.state_id,
            query_dump.dump_id if query_dump else None,
        ) or not targets_match:
            raise TraceError(StopCode.INVALID_INPUT, '查询目标和位置必须属于所绑定检查')
    try:
        profile = bind_semantics(run)
    except TraceError as error:
        if error.code != StopCode.UNSUPPORTED_SEMANTICS:
            raise
        engine = _Query(run, request, topology, SemanticsProfile('unknown', 'unknown', False, 'unsupported'), check)
        engine.frontier.append(Frontier(_reason(error)))
        return engine.report()
    return _Query(run, request, topology, profile, check).execute(binding)
