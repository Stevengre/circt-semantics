#!/bin/bash

# 设置脚本在出错时退出
set -e

input='ListItem(ListItem(bits (0 , 1) : !seq.clock) ListItem(bits (0 , 1) : i1) ListItem(bits (0 , 1) : i1) ListItem(bits (0 , 1) : !seq.clock) ListItem(bits (0 , 1) : i1) ListItem(bits (0 , 1) : i1) ListItem(bits (0 , 7) : i7) ListItem(bits (0 , 32) : i32) ListItem(bits (0 , 2) : i2) ListItem(bits (0 , 11) : i11) ListItem(bits (0 , 1) : !seq.clock) ListItem(bits (0 , 1) : i1) ListItem(bits (0 , 1) : i1) ListItem(bits (1 , 1) : i1) ListItem(bits (0 , 1) : i1) ListItem(bits (0 , 1) : i1) ListItem(bits (0 , 4) : i4) ListItem(bits (0 , 2) : i2) ListItem(bits (1 , 1) : i1) ListItem(bits (0 , 1) : i1) ListItem(bits (0 , 4) : i4) ListItem(bits (0 , 64) : i64) ListItem(bits (0 , 2) : i2) ListItem(bits (0 , 1) : i1) ListItem(bits (1 , 1) : i1) ListItem(bits (0 , 1) : i1) ListItem(bits (0 , 1) : i1) ListItem(bits (0 , 4) : i4) ListItem(bits (0 , 2) : i2) ListItem(bits (1 , 1) : i1) ListItem(bits (0 , 1) : i1) ListItem(bits (0 , 4) : i4) ListItem(bits (0 , 64) : i64) ListItem(bits (0 , 2) : i2) ListItem(bits (0 , 1) : i1))'

# 定义 krun 命令模板
krun_base_cmd="krun ~/data/rocket-small-master.generic.drop-hw-param-decl.mlir -v --definition main-kompiled -cEntry='\"RocketSystem\"' -cInput=$input"

# 定义 kast 命令模板
kast_cmd="kast -o kore -i program"

# 定义 krun_term 命令模板
krun_term_cmd="krun --parser 'cat' --term --definition main-kompiled"

# 设置初始 depth
next_depth=1000

# 最大并发进程数
max_concurrent=50

# 定义日志文件路径
log_file=~/data/krun_execution_times.log

# 创建日志文件，如果不存在
touch "$log_file"

# 函数：记录命令执行时间
run_with_time() {
    local cmd="$1"           # 要执行的命令

    # 记录开始时间
    local start_time=$(date +%s)

    # 执行命令
    eval "$cmd"
    local status=$?          # 获取命令的退出状态

    # 记录结束时间
    local end_time=$(date +%s)

    # 计算执行时间
    local duration=$((end_time - start_time))

    # 记录日志
    echo "Command: $cmd, Execution Time: ${duration} seconds, Status: $status" >> "$log_file"
}

run_with_time "kompile main.k --gen-bison-parser --bison-stack-max-depth 1000000000 -v -O3 -ccopt -g -o ~/data/df9d94e-opt-kompiled/" &

krun_cmd="krun ~/data/rocket-small-master.generic.drop-hw-param-decl.mlir -v -o kore --definition main-kompiled -cEntry='\"RocketSystem\"' -cInput='$input'"

run_with_time "$krun_cmd --output-file ~/data/final.kore" &

next_depth=10000

for ((i=0; i<80; i++)); do
    run_with_time "$krun_cmd --depth $next_depth --output-file ~/data/$next_depth.kore" &
    echo "Running depth $next_depth"
    next_depth=$((next_depth + 10000))
done

# 等待所有进程完成
wait

# 使用 kast 处理所有生成的 kore 文件
for kore_file in ~/data/*.kore; do
    run_with_time "kast -o kore -i pretty $kore_file > ${kore_file%.kore}.pretty" &
done

# 等待所有 kast 进程完成
wait

echo "All kore files processed."

# krun_term_cmd="krun --parser 'cat' --term --definition main-kompiled/ -o kore"

# # 设置初始深度
# next_depth=1000
# max_finished_depth=0

# # 最大并发进程数
# max_concurrent=50

# # 所有进程运行完成后退出的标志
# all_jobs_done=false

# # 启动初始的 50 个进程
# for ((i=0; i<max_concurrent; i++)); do
    
#     run_with_time "$krun_term_cmd ~/data/rocket-small-master.init.kore --depth $next_depth --output-file ~/data/$next_depth.kore" &
#     echo "Running depth $next_depth"
#     next_depth=$((next_depth + 1000))
# done

# # 持续监控并保持 50 个进程
# while true; do
#     # 使用 wait -n 等待任意一个后台进程结束
#     wait -n
#     echo "Waiting for depth $next_depth"

#     # 获得当前~/data/下最大的depth，要求*.kore不为空
#     max_finished_depth=$(ls -1 ~/data/*.kore | sort -r | head -n 1 | cut -d'.' -f1 | cut -d'_' -f1)
#     depth_to_run=$((next_depth - max_finished_depth))

#     run_with_time "kast -o kore -i pretty ~/data/$max_finished_depth.kore > ~/data/$max_finished_depth.pretty" &

#     run_with_time "$krun_term_cmd ~/data/$max_finished_depth.kore --depth $depth_to_run --output-file ~/data/$next_depth.kore" &
    
#     next_depth=$((next_depth + 1000))
# done