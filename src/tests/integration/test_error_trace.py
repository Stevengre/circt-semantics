from pathlib import Path
from typing import List

from kcirct.api import KCIRCT
from kcirct.err_trace import KErrTrace
from kcirct.vcd import KVCD
from tests.resources import DATA_PATH

# 解析Kore文本
test_mlir_file = DATA_PATH / 'error_trace_test' / 'test.generic.mlir'
input_kore = DATA_PATH / 'error_trace_test' / 'simulated.0.kore'
err_trace_file = DATA_PATH / 'error_trace_test' / 'err_trace.json'
test_output = [
    DATA_PATH / 'error_trace_test' / name
    for name in ('test1k.output', 'test1vcd.output', 'testlistk.output', 'testlistvcd.output')
]
test_differences_name = [
    DATA_PATH / 'error_trace_test' / name for name in ('differencesname.txt', 'differencesnameK.txt')
]
rocket_kore = DATA_PATH / 'rocket-small' / 'setup.kore'
rocket_tance_file = DATA_PATH / 'rocket-small' / 'err_trnce.json'
rocket_test_output = DATA_PATH / 'rocket-small' / 'test.output'
rocket_differences_name = DATA_PATH / 'rocket-small' / ('dfnames2.txt', 'differencesname.txt')[0]


def test_build_grapth(input_kore: Path, err_tracne_file: Path) -> None:
    k_err_trnce = KErrTrace()
    k_err_trnce.build_grapth(input_kore, err_tracne_file)


def test_vcd_list_err_trace(input_list_file: Path, input_kore: Path, err_tracne_file: Path, test_output: Path) -> None:
    k_err_trnce = KErrTrace()
    k_err_trnce.set_signal_port_mapping(input_kore)
    original_names = []

    with open(input_list_file, 'r', encoding='utf-8') as file:
        lines = file.readlines()  # 读取所有行到列表中
        for line in lines:
            vcdname = line.strip()
            original_names.append(vcdname)
            k_err_trnce.differenes.append(k_err_trnce.change_vcdname2kname(vcdname))

    k_err_trnce.load_from_json(err_tracne_file)

    top = 0
    while top < len(k_err_trnce.differenes):
        print(original_names[top])
        k_err_trnce.search_path_kname(k_err_trnce.differenes[top], test_output)
        input()
        top += 1


def test_k_list_err_trnce(input_list_file: Path, err_tracne_file: Path, test_output: Path) -> None:
    k_err_trnce = KErrTrace()

    with open(input_list_file, 'r', encoding='utf-8') as file:
        lines = file.readlines()  # 读取所有行到列表中
        for line in lines:
            vcdname = line.strip()
            k_err_trnce.differenes.append(vcdname)

    k_err_trnce.load_from_json(err_tracne_file)

    top = 0
    while top < len(k_err_trnce.differenes):
        print(k_err_trnce.differenes[top])
        k_err_trnce.search_path_kname(k_err_trnce.differenes[top], test_output)
        input()
        top += 1


def test_err_trnce(
    target: str, k_target: str, input_kore: Path, err_tracne_file: Path, test_output_k: Path, test_output_vcd: Path
) -> None:
    k_err_trnce = KErrTrace()
    k_err_trnce.set_signal_port_mapping(input_kore)
    k_err_trnce.load_from_json(err_tracne_file)

    k_err_trnce.search_path_kname(k_target, test_output_k)

    k_err_trnce.search_path_vcdname(target, test_output_vcd)


def trace_vcdname2kname() -> None:
    # This is an example of transforming vcddiff output into kname format.
    # The vcddiff output was generated with the --top1 flag, which removes the prefix from signal names.
    k_err_trnce = KErrTrace()
    k_err_trnce.load_from_json(rocket_tance_file)
    k_err_trnce.set_signal_port_mapping(rocket_kore)
    while 1:
        vcdname = input("请输入vcdname:")
        vcdname = 'RocketSystem.' + vcdname
        print(k_err_trnce.change_vcdname2kname(vcdname))


def test_build_kore(mlir_file: Path, top_module: str, inputs: List[List[tuple[int, int]]]) -> None:

    kcirct = KCIRCT()

    kcirct.ensure_env()
    # KCIRCT Parsing: from mlir to kore
    kcirct.compile_fast(mlir_file, mlir_file.parent / 'pgm.kore')
    # KCIRCT Preprocessing
    kcirct.run_preprocess_fast(mlir_file.parent / 'pgm.kore', mlir_file.parent / 'preprocessed.kore')
    # KCIRCT Hardware Setup & Initialization
    kcirct.run_setup_fast(mlir_file.parent / 'preprocessed.kore', mlir_file.parent / 'setup.kore', top_module)
    # KCIRCT Simulation

    vcd_path = mlir_file.parent / 'test.vcd'
    if vcd_path.exists():
        vcd_path.unlink()
    vcd = KVCD(vcd_path=vcd_path, mlir_path=mlir_file)
    vcd.time = 0
    rounds = 0
    input = inputs[0]
    kcirct.run_simulate_fast(mlir_file.parent / 'setup.kore', mlir_file.parent / f'simulated.{rounds&1}.kore', input)
    vcd.dump(kcirct.read_ports_fast(mlir_file.parent / f'simulated.{rounds&1}.kore'))
    rounds += 1
    print(str(vcd.time) + str(mlir_file))


if __name__ == '__main__':
    test_build_kore(test_mlir_file, 'Foo', [[(1, 1), (192, 8), (87, 8)]])
    test_build_grapth(input_kore, err_trace_file)

    # trace_vcdname2kname()
    test_target = r'Foo.i0.io_a'  # accepts the port name format displayed by vcddiff.
    test_k_target = r'Foo/i0/%arg0'  # accepts the k item name format.
    test_err_trnce(test_target, test_k_target, input_kore, err_trace_file, test_output[0], test_output[1])
    test_vcd_list_err_trace(test_differences_name[0], input_kore, err_trace_file, test_output[3])
    test_k_list_err_trnce(test_differences_name[1], err_trace_file, test_output[2])
    # During testing, press Enter in the console to output the next item's test result
    # from the list into the output file each time.
