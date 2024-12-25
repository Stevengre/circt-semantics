// Verilated -*- C++ -*-
// DESCRIPTION: main() calling loop, created with Verilator --main

#include <iostream>
#include <json/json.h>
#include <fstream>
#include "verilated.h"
#include <verilated_vcd_c.h>
#include "Vmul.h"
#include <typeinfo>


using namespace Json;
//======================

Vmul* topp;

// Requires -DVL_TIME_STAMP64
vluint64_t main_time = 0;
Value inputs;

void getInput(){
    std::ifstream ifs("./comb/mul/test_data.json");
    Value root;
    Reader r;
    r.parse(ifs, root);
    inputs = root["inputs"];
}

int main(int argc, char** argv, char**) {
    // Setup defaults and parse command line
    Verilated::debug(0);
    Verilated::commandArgs(argc, argv);
    // Construct the Verilated model, from Vtop.h generated from Verilating
    topp = new Vmul("Foo");
    VerilatedVcdC* tfp = new VerilatedVcdC; // 创建 VCD 对象
    Verilated::traceEverOn(true);
    topp->trace(tfp, 99); // 设置波形跟踪深度
    tfp->open("./comb/mul/trace_vtor.vcd"); // 打开 VCD 文件 ,这里写相对路径的话，我可以在operation目录下
    // Evaluate initials
    topp->eval();  // Evaluate
    // Simulate until $finisha

    getInput();

        std::chrono::high_resolution_clock::duration duration =
      std::chrono::high_resolution_clock::duration::zero();

    while (!Verilated::gotFinish() && main_time < inputs.size()) {
        // Evaluate model
        topp->a = inputs[int(main_time)][0][0].asInt();
        topp->b = inputs[int(main_time)][1][0].asInt();
        auto t_before = std::chrono::high_resolution_clock::now();
        topp->eval();
        auto t_after = std::chrono::high_resolution_clock::now();
        duration += t_after - t_before;
        tfp->dump(main_time);
        ++main_time;
        // std::cout<<int(topp->res) <<std::endl;
    }
    auto seconds = std::chrono::duration_cast<std::chrono::duration<double>>(
                         duration)
                         .count();
    std::cout<<seconds/inputs.size()<<std::endl;
    
    // Final model cleanup
    topp->final();
    VL_DO_DANGLING(delete topp, topp);
    tfp->close(); // 关闭 VCD 文件
    exit(0);
}
