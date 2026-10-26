"""独立有限轨迹检查器；只用整数参考行为，不导入 K 或被测 trace 解释器。"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def expected_values(interface: str, samples: list[dict]) -> list[int]:
    """按明确输入序列执行独立参考行为。"""
    result = []
    state, previous_clock = 7, None
    for sample in samples:
        values = {name: int(value['value']) for name, value in sample['values'].items()}
        if interface == 'add_one/v1':
            result.append((values['data'] + 1) % 256)
        elif interface == 'register_mux/v1':
            edge = values['clk'] == 1 and previous_clock in (None, 0)
            if edge:
                state = 0 if values['reset'] else values['a'] if values['sel'] else values['b']
            result.append(state)
            previous_clock = values['clk']
        else:
            raise ValueError(f'不支持的 checker interface：{interface}')
    return result


def check(document: dict) -> dict:
    """返回逐项预期和实际差异；没有观察样本不能得到 vacuous pass。"""
    samples = document['samples']
    if not samples:
        raise ValueError('独立检查需要非空观测')
    expected = expected_values(document['checker_interface'], samples)
    violations = []
    for index, (sample, value) in enumerate(zip(samples, expected, strict=True)):
        actual = int(sample['values']['result']['value'])
        if value != actual:
            violations.append(
                {'sample': index, 'expected': value, 'actual': actual, 'observation': sample['observation']}
            )
    return {
        'schema_version': 1,
        'kind': 'component_checker_result',
        'run_id': document['run_id'],
        'manifest_sha256': document['manifest_sha256'],
        'binding_sha256': document['binding_sha256'],
        'checker_sha256': document['checker_sha256'],
        'checker_interface': document['checker_interface'],
        'verdict': 'fail' if violations else 'pass',
        'samples_checked': len(samples),
        'expected': expected,
        'violations': violations,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    arguments = parser.parse_args()
    data = arguments.input.read_bytes()
    result = check(json.loads(data))
    result['input_sha256'] = hashlib.sha256(data).hexdigest()
    result['executed_checker_sha256'] = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    if result['executed_checker_sha256'] != result['checker_sha256']:
        raise ValueError('实际 checker 内容与本次绑定不同')
    with arguments.output.open('x') as stream:
        json.dump(result, stream, ensure_ascii=False, indent=2)
        stream.write('\n')
    print(json.dumps({'verdict': result['verdict'], 'samples': result['samples_checked']}, ensure_ascii=False))


if __name__ == '__main__':
    main()
