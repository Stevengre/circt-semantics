import re
import tempfile
import os
import sys

firtool = 'firtool'

def get_cases():
    with open('./examples/sv.md') as f:
        file = f.read()

    cases = re.findall(r'([^`]*)\n```mlir\n(.*?)\n```', file, re.S)
    for c in cases:
        print(c)


def case2generic():
    with open('./examples/sv.md') as f:
        file = f.read()

    cases = re.findall(r'([^`]*)\n```mlir\n(.*?)\n```', file, re.S)

    generic_cases = []
    for op, example in cases:
        with tempfile.NamedTemporaryFile('w', suffix='.mlir') as tmpfile:
            tmpfile.write(example)
            tmpfile.flush()
            cmd = f'{firtool} {tmpfile.name} --ir-hw --mlir-print-op-generic --disable-opt'
            print(op.strip(), file=sys.stderr)
            generic_cases.append((op.strip(), os.popen(cmd).read()))

    generic_cases = list(map(lambda c: f'{c[0]}\n```mlir\n{c[1].strip()}\n```', generic_cases))
    print('\n\n'.join(generic_cases))