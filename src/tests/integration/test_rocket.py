from __future__ import annotations

import json
import time
from threading import Lock, Thread
from typing import TYPE_CHECKING

from kcirct.api import KCIRCT

from ..resources import DATA_PATH

if TYPE_CHECKING:
    from pathlib import Path

ROCKET_SMALL_MLIR_FILE = DATA_PATH / 'rocket-test' / 'rocket-small-master.generic.mlir'
ROCKET_SMALL_KORE_FILE = DATA_PATH / 'rocket-test' / 'rocket-small-master.kore'
ROCKET_SMALL_INIT_STATE = DATA_PATH / 'rocket-test' / 'rocket-small-master.init.kore'
ROCKET_SMALL_OUT_DIR = DATA_PATH / 'rocket-test'


# def test_rocket_small_try() -> None:
#     kcirct = KCIRCT()
#     # TODO: KoreParser 太太太太慢了，而且是递归的
#     # kore = kcirct.compile(ROCKET_SMALL_MLIR_FILE, output_file=ROCKET_SMALL_KORE_FILE)
#     inputs = [
#         (0, 1),
#         (0, 1),
#         (0, 1),
#         (0, 1),
#         (0, 1),
#         (0, 7),
#         (0, 32),
#         (0, 2),
#         (0, 11),
#         (0, 1),
#         (0, 1),
#         (0, 1),
#         (1, 1),
#         (0, 1),
#         (0, 1),
#         (0, 4),
#         (0, 2),
#         (1, 1),
#         (0, 1),
#         (0, 4),
#         (0, 64),
#         (0, 2),
#         (0, 1),
#         (1, 1),
#         (0, 1),
#         (0, 1),
#         (0, 4),
#         (0, 2),
#         (1, 1),
#         (0, 1),
#         (0, 4),
#         (0, 64),
#         (0, 2),
#         (0, 1),
#     ]
#     kcirct.init_state(ROCKET_SMALL_KORE_FILE, ROCKET_SMALL_INIT_STATE, 'RocketSystem', inputs)


def test_rocket_small() -> None:
    kcirct = KCIRCT()
    # kcirct_opt = KCIRCT(use_opt=True)
    # TODO: KoreParser 太太太太慢了，而且是递归的
    # kore = kcirct.compile(ROCKET_SMALL_MLIR_FILE, output_file=ROCKET_SMALL_KORE_FILE)
    # inputs = [
    #     (0, 1),
    #     (0, 1),
    #     (0, 1),
    #     (0, 1),
    #     (0, 1),
    #     (0, 7),
    #     (0, 32),
    #     (0, 2),
    #     (0, 11),
    #     (0, 1),
    #     (0, 1),
    #     (0, 1),
    #     (1, 1),
    #     (0, 1),
    #     (0, 1),
    #     (0, 4),
    #     (0, 2),
    #     (1, 1),
    #     (0, 1),
    #     (0, 4),
    #     (0, 64),
    #     (0, 2),
    #     (0, 1),
    #     (1, 1),
    #     (0, 1),
    #     (0, 1),
    #     (0, 4),
    #     (0, 2),
    #     (1, 1),
    #     (0, 1),
    #     (0, 4),
    #     (0, 64),
    #     (0, 2),
    #     (0, 1),
    # ]
    # kcirct.init_state(ROCKET_SMALL_MLIR_FILE, ROCKET_SMALL_INIT_STATE, 'RocketSystem', inputs)

    def run_krun_fast(input: Path, output: Path, depth: int | None = None) -> None:
        start = time.time()
        kcirct.krun_fast(input, output, depth)
        end = time.time()
        data = {
            'input': str(input),
            'output': str(output),
            'time': str(end - start),
            'depth': str(depth),
        }
        with open(output.parent / f'depth_{depth}.json', 'w') as json_file:
            json.dump(data, json_file, indent=4)

    max_threads = 100
    thread_count = 0
    lock = Lock()

    def start_new_thread() -> None:
        nonlocal thread_count
        depth = thread_count * 10000
        thread = Thread(
            target=run_krun_fast,
            args=(ROCKET_SMALL_KORE_FILE, ROCKET_SMALL_OUT_DIR / f'rocket-small-master.dep{depth}.out', depth),
        )
        thread.start()
        with lock:
            thread_count += 1

    threads = [Thread(target=start_new_thread) for _ in range(max_threads)]
    for thread in threads:
        thread.start()

    while True:
        for i, thread in enumerate(threads):
            if not thread.is_alive():
                print(f'Thread {i} terminated, starting a new thread')
                threads[i] = Thread(target=start_new_thread)
                threads[i].start()
        time.sleep(1)  # 每隔一段时间检查一次线程状态


if __name__ == '__main__':
    test_rocket_small()
