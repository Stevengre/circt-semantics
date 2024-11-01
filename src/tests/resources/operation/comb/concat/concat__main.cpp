// Verilated -*- C++ -*-
// DESCRIPTION: main() calling loop, created with Verilator --main

#include "verilated.h"
#include "Vconcat.h"
#include <verilated_vcd_c.h>
#include<iostream>

//======================

Vconcat* topp;

// Requires -DVL_TIME_STAMP64
vluint64_t main_time = 0;
int main(int argc, char** argv, char**) {
    // Setup defaults and parse command line
    Verilated::debug(0);
    Verilated::commandArgs(argc, argv);
    // Construct the Verilated model, from Vtop.h generated from Verilating
    topp = new Vconcat("Foo");
    VerilatedVcdC* tfp = new VerilatedVcdC; // 创建 VCD 对象
    Verilated::traceEverOn(true);
    topp->trace(tfp, 99); // 设置波形跟踪深度
    tfp->open("./comb/concat/trace_vtor.vcd"); // 打开 VCD 文件 ,这里写相对路径的话，我可以在operation目录下
        //运行Vconcat
    // Evaluate initials
    topp->eval();  // Evaluate
    // Simulate until $finish
    while (!Verilated::gotFinish() && main_time < 1) {
        // Evaluate model
        topp->a = 2;
        topp->b = 1;
        topp->eval();
        tfp->dump(main_time);
        ++main_time;
        std::cout<<int(topp->res) <<std::endl;
    }
    
    // Final model cleanup
    topp->final();
    VL_DO_DANGLING(delete topp, topp);
    tfp->close(); // 关闭 VCD 文件
    exit(0);
}
