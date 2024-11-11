LLVM (http://llvm.org/):
  LLVM version 19.0.0git
  Optimized build.
CIRCT firtool-1.71.0

template: see comb/add/add__main.cpp
请修改cpp中:
#include "Vconcat.h"
Vconcat* topp;
    std::ifstream ifs("./comb/concat/test_data.json");
    topp = new Vconcat("Foo");
    tfp->open("./comb/concat/trace_vtor.vcd"); // 打开 VCD 文件 ,这里写相对路径的话，我可以在operation目录下
