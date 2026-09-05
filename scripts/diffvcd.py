#!/usr/bin/env python3
import argparse
import re
import sys
from typing import Dict, List, Optional

from vcdvcd import VCDVCD, binary_string_to_hex

parser = argparse.ArgumentParser(description="Print the first difference between two VCD files")
parser.add_argument("file1", metavar="VCD1", help="first file to compare")
parser.add_argument("file2", metavar="VCD2", help="second file to compare")
parser.add_argument("--top1", metavar="INSTPATH", help="instance in first file to compare")
parser.add_argument("--top2", metavar="INSTPATH", help="instance in second file to compare")
parser.add_argument(
    "-f", "--filter", metavar="REGEX", action="append", default=[], help="only compare signals matching a regex"
)
parser.add_argument(
    "-i", "--ignore", metavar="REGEX", action="append", default=[], help="ignore signals matching a regex"
)
parser.add_argument("-l", "--list", action="store_true", help="list signals and exit")
parser.add_argument("-v", "--verbose", action="store_true", help="verbose output")
parser.add_argument("-a", "--after", type=int, help="only compare after time")
parser.add_argument("-b", "--before", type=int, help="only compare before time")
parser.add_argument(
    "--ignore-missing-signals",
    action="store_true",
    help="跳过任一侧完全没有采样值的共同信号；不影响 --list 的声明列表",
)
args = parser.parse_args()

if args.after is not None and args.before is not None and args.after > args.before:
    parser.error(f"--after ({args.after}) 不能晚于 --before ({args.before})")


def info(s: str):
    if args.verbose:
        sys.stderr.write(s)


def infoln(s: str):
    info(f"{s}\n")


# Collect the signals in both files.
vcd1 = VCDVCD(args.file1, only_sigs=True)
vcd2 = VCDVCD(args.file2, only_sigs=True)
infoln(f"{len(vcd1.signals)} signals in first file")
infoln(f"{len(vcd2.signals)} signals in second file")


# Extract signals under the requested top-level instance.
def filter_signals(signals: List[str], prefix: Optional[str]) -> Dict[str, str]:
    if prefix is None:
        return {s: s for s in signals}
    else:
        return {s[len(prefix) :]: s for s in signals if s.startswith(prefix)}


filtered_signals1 = filter_signals(vcd1.signals, args.top1)
filtered_signals2 = filter_signals(vcd2.signals, args.top2)
if args.top1 is not None:
    infoln(f"{len(filtered_signals1)} signals under `{args.top1}` in first file")
if args.top2 is not None:
    infoln(f"{len(filtered_signals2)} signals under `{args.top2}` in second file")

# Find the common signals.
common_signals = []
for key, sig1 in filtered_signals1.items():
    if sig2 := filtered_signals2.get(key):
        common_signals.append((key, sig1, sig2))
common_signals.sort()
infoln(f"{len(common_signals)} common signals")

# Filter the common signals.
for f in args.filter:
    f = re.compile(f)
    common_signals = [x for x in common_signals if f.search(x[0])]

# Filter out ignored signals.
for i in args.ignore:
    i = re.compile(i)
    common_signals = [x for x in common_signals if not i.search(x[0])]

if args.filter or args.ignore:
    infoln(f"{len(common_signals)} filtered and unignored signals")

# List the signals and exit if requested.
if args.list:
    for s in common_signals:
        print(s[0])
    sys.exit(0)

# Abort if there are no common signals to compare.
if not common_signals:
    sys.stderr.write("no commong signals between input files\n")
    sys.exit(1)

# Read the VCD files with only the interesting signals.
infoln("Reading first file")
vcd1 = VCDVCD(args.file1, signals=[x[1] for x in common_signals])
infoln("Reading second file")
vcd2 = VCDVCD(args.file2, signals=[x[2] for x in common_signals])

comparison_start = args.after if args.after is not None else 0
comparison_end = min(vcd1.endtime, vcd2.endtime)
if args.before is not None:
    comparison_end = min(comparison_end, args.before)
if comparison_start > comparison_end:
    sys.stderr.write(f"VCD 时间窗口没有交集：start={comparison_start}, end={comparison_end}\n")
    sys.exit(1)


def values_match(value1: Optional[str], value2: Optional[str]) -> bool:
    if value1 == value2:
        return True

    def is_zero(value: Optional[str]) -> bool:
        return value is not None and bool(value) and set(value) == {"0"}

    return value1 is None and is_zero(value2) or value2 is None and is_zero(value1)


def display_value(value: Optional[str]) -> str:
    return "None" if value is None else binary_string_to_hex(value)


# Compare each signal.
earliest_mismatches = []
compared_signals = 0
for signal, signame1, signame2 in common_signals:
    infoln(f"Comparing {signal}")
    signal1 = vcd1[signame1]
    signal2 = vcd2[signame2]

    if args.ignore_missing_signals and (not signal1.tv or not signal2.tv):
        missing_files = []
        if not signal1.tv:
            missing_files.append(args.file1)
        if not signal2.tv:
            missing_files.append(args.file2)
        infoln(f"跳过信号 {signal}：以下文件中没有采样值：{', '.join(missing_files)}")
        continue
    compared_signals += 1

    comparison_times = {comparison_start}
    comparison_times.update(t for t, _ in signal1.tv if comparison_start <= t <= comparison_end)
    comparison_times.update(t for t, _ in signal2.tv if comparison_start <= t <= comparison_end)
    for t in sorted(comparison_times):
        v1 = signal1[t]
        v2 = signal2[t]
        if values_match(v1, v2):
            continue
        if earliest_mismatches and t < earliest_mismatches[0][0]:
            earliest_mismatches = []
        if not earliest_mismatches or t == earliest_mismatches[0][0]:
            earliest_mismatches.append((t, v1, v2, signal))
        break

if args.ignore_missing_signals and compared_signals == 0:
    sys.stderr.write("跳过缺少采样值的信号后，没有可比较的信号\n")
    sys.exit(1)

for t, sig1, sig2, name in earliest_mismatches:
    print(f"{t}  {display_value(sig1)}  {display_value(sig2)}  {name}")
if earliest_mismatches:
    sys.exit(1)
