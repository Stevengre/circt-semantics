#include "VAdder.h" // need to be changed
// #include "verilated.h"
#include "verilated_vcd_c.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <random>

int main(int argc, char** argv) {
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    contextp->traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC();

    // VAdder* top = new VAdder{contextp}; // need to be changed
    VAdder* top = new VAdder("Adder"); // need to be changed
    top->trace(tfp, 99); // Trace 99 levels of hierarchy (or see below)
    // tfp->dumpvars(1, "t"); // trace 1 level under "t"
    tfp->open("wave.vcd"); // 打开vcd

    std::random_device rd;
    std::default_random_engine generator(rd());
    std::uniform_int_distribution<int> distribution(0, 255);

    int sim_time = 10;
    while (!contextp->gotFinish() && contextp->time() < sim_time) {
        int a = distribution(generator);
        top->io_a = a;
        top->eval();
        tfp->dump(contextp->time()); // dump wave
        printf("time = %ld\n", contextp->time());
        printf("io_a = %d, res_out2 = %d, res_out1 = %d\n", a, top->res_out2, top->res_out1);
        contextp->timeInc(1);
        // printf("a = %d, b = %d, f = %d\n", a, b, top->f);
        // assert(top->f == (a ^ b));
    }
    top->final();
    tfp->close();
    delete contextp;
    return 0;
}