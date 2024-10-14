#!/bin/bash

export K_OPTS=-Xmx128G

# 运行第二个 kompile 命令并将其放入后台运行
start_time=$(date +%s)
kompile ./src/kcirct/kdist/circt_semantics/main.k --gen-bison-parser --bison-stack-max-depth 1000000000 -O3 -ccopt -g -o ~/data/$1-opt-kompiled &
pid2=$!
echo "Optimized kompiling started with PID: $pid2 " &

# 运行第一个 kompile 命令并将其放入后台运行
kompile ./src/kcirct/kdist/circt_semantics/main.k --gen-bison-parser --bison-stack-max-depth 1000000000 -o ~/data/$1-kompiled &
pid1=$!
echo "Kompiling started with PID: $pid1" 

# 等待第一个 kompile 命令完成并输出消息
wait $pid1
end_time=$(date +%s)
echo "Time taken for kompiling: $((end_time - start_time)) seconds"
echo "Kompiling done"


# 等待第二个 kompile 命令完成并输出消息
wait $pid2
end_time=$(date +%s)
echo "Time taken for optimized kompiling: $((end_time - start_time)) seconds"
echo "Optimized kompiling done"
