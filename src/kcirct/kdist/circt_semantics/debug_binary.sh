#!/bin/bash

L=0
R=${1:-10000}  # 默认值为10000，如果没有传入参数
MID=0
REMAIN_DEBUG=${2:-0}

# 确保 L 和 R 是整数
echo "R=$R"

while [ $L -le $R ]; do
    MID=$(printf "%.0f" $(echo "($L + $R) / 2" | bc -l))
    echo "Now mid: $MID"
    krun --term --parser 'cat' rocket-small-master.kore -o kore --depth $MID --output-file rocket-small-master$MID.kore.out-debug
    if [ $? -eq 0 ]; then
        L=$(( MID + 1 ))
    else
        R=$(( MID - 1 ))
    fi
done

if [ "$REMAIN_DEBUG" -eq 0 ]; then
    rm -f *.kore.out-debug  # 删除所有以 .out-debug 结尾的文件
    echo "Deleted all .out-debug files."
else
    echo "Debug mode is off. No files deleted."
fi

echo "Recent error depth: $MID"
