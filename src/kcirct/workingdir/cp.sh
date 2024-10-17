#!/bin/bash

# 如果如果没有第二个参数，则删除kompiled并复制
if [ -z "$2" ]; then
    rm -rf kompiled/
    cp -r ~/data/$1-kompiled kompiled/
else
    rm -rf opt-kompiled/
    cp -r ~/data/$1-opt-kompiled opt-kompiled/
fi
