from pathlib import Path

from kcirct.err_trance import KErrTrance
from tests.resources import DATA_PATH

# 解析Kore文本
input_kore = DATA_PATH / 'test_debug' / 'test.kore'
err_tracne_file = DATA_PATH / 'test_debug' / 'err_trance.json'
test_output = DATA_PATH / 'test_debug' / 'test.output'
rocket_kore = DATA_PATH / 'rocket-small' / 'setup.kore'
rocket_tance_file = DATA_PATH / 'rocket-small' / 'err_trance.json'
rocket_test_output = DATA_PATH / 'rocket-small' / 'test.output'
rocket_differences_name = DATA_PATH / 'rocket-small' / 'differencesname.txt'


def test_build_grapth(input_kore: Path, err_tracne_file: Path) -> None:
    k_err_trance = KErrTrance()
    k_err_trance.build_grapth(input_kore, err_tracne_file)


def test_k_err_trance(target: str, err_tracne_file: Path, test_output: Path) -> None:
    k_err_trance = KErrTrance()
    k_err_trance.set_signal_port_mapping(rocket_kore)

    with open(rocket_differences_name, 'r', encoding='utf-8') as file:
        lines = file.readlines()  # 读取所有行到列表中
        for line in lines:
            vcdname = line.strip()
            vcdname = 'RocketSystem.'+vcdname
            k_err_trance.differenes.append(k_err_trance.change_vcdname2kname(vcdname))

    k_err_trance.load_from_json(err_tracne_file)
    
    # k_err_trance.search_path_vcdname(target, test_output)
    top = 0
    while(top < len(k_err_trance.differenes)):
        k_err_trance.search_path(k_err_trance.differenes[top], test_output)
        input()
        top += 1

def trance_vcdname2kname() -> None:
    k_err_trance = KErrTrance()
    k_err_trance.load_from_json(rocket_tance_file)
    k_err_trance.set_signal_port_mapping(rocket_kore)
    while(1):
        vcdname = input("请输入vcdname:")
        vcdname = 'RocketSystem.'+vcdname
        print(k_err_trance.change_vcdname2kname(vcdname))

if __name__ == '__main__':
    test_build_grapth(rocket_kore, rocket_tance_file)

    # trance_vcdname2kname()
    test_target = r'tile_prci_domain.tile_reset_domain.tile.frontend.icache.io_resp_bits_data'
    test_target = 'RocketSystem.'+test_target
    test_target = test_target.replace('.', '/')
    test_k_err_trance(test_target, rocket_tance_file, rocket_test_output)
