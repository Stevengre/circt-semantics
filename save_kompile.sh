#!/bin/bash

kompile ./src/kcirct/kdist/circt_semantics/main.k --gen-bison-parser --bison-stack-max-depth 1000000000 -o ~/data/$1-kompiled &
kompile ./src/kcirct/kdist/circt_semantics/main.k --gen-bison-parser --bison-stack-max-depth 1000000000 -O3 -ccopt -g -o ~/data/$1-opt-kompiled
