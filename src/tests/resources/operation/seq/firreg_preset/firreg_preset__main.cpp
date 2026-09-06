// 参考模型按显式初值初始化，只在上升沿更新；每个事件检查全部输出。
#include <array>
#include <fstream>
#include <iostream>
#include <json/json.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vfirreg_preset.h"

int main(int argc, char** argv) {
    VerilatedContext context;
    context.commandArgs(argc, argv);
    context.randReset(0);
    context.traceEverOn(true);
    Vfirreg_preset dut(&context, "Foo");
    VerilatedVcdC trace;
    trace.set_time_unit("1ns");
    trace.set_time_resolution("1ns");
    dut.trace(&trace, 99);
    trace.open("./seq/firreg_preset/trace_vtor.vcd");
    std::ifstream source("./seq/firreg_preset/test_data.json");
    Json::Value document;
    if (!source || !(source >> document) || !document["inputs"].isArray() || document["inputs"].empty()) {
        std::cerr << "输入文件缺失、无效或为空\n";
        return 2;
    }
    const auto& inputs = document["inputs"];
    const std::array<unsigned, 5> widths = {1, 1, 1, 4, 8};
    const std::array<const char*, 6> names = {"q4", "q8", "qneg", "qbit", "plain", "next4"};
    unsigned q4 = 5, q8 = 0xA5, qneg = 0xFF, qbit = 1, plain = 0, previous_clock = 0;
    for (Json::ArrayIndex t = 0; t < inputs.size(); ++t) {
        const auto& row = inputs[t];
        if (row.size() != widths.size()) return 2;
        for (unsigned i = 0; i < widths.size(); ++i) {
            if (row[i].size() != 2 || !row[i][0].isUInt() ||
                row[i][0].asUInt() >= (1u << widths[i]) || row[i][1].asUInt() != widths[i]) return 2;
        }
        dut.clk = row[0][0].asUInt();
        dut.reset = row[1][0].asUInt();
        dut.enable = row[2][0].asUInt();
        dut.d4 = row[3][0].asUInt();
        dut.d8 = row[4][0].asUInt();
        if (t == 0 && dut.clk != 0) {
            std::cerr << "首个事件须从低电平开始，以单独观察 preset\n";
            return 2;
        }
        if (!previous_clock && dut.clk) {
            if (dut.reset) {
                q4 = 2;
                q8 = 60;
            } else if (dut.enable) {
                q4 = (q4 + 1) & 15;
                q8 = dut.d8;
            }
            qneg = dut.d8;
            qbit = dut.enable;
            plain = dut.d4;
        }
        previous_clock = dut.clk;
        dut.eval();
        trace.dump(t);
        const std::array<unsigned, 6> expected = {q4, q8, qneg, qbit, plain, (q4 + 1) & 15};
        const std::array<unsigned, 6> actual = {dut.q4, dut.q8, dut.qneg, dut.qbit, dut.plain, dut.next4};
        for (unsigned i = 0; i < expected.size(); ++i) {
            if (actual[i] != expected[i]) {
                std::cerr << "事件 " << t << " 的 " << names[i] << " 不一致: "
                          << actual[i] << " != " << expected[i] << "\n";
                trace.close();
                return 1;
            }
        }
    }
    dut.final();
    trace.close();
    std::cout << "全部 " << inputs.size() << " 个事件的初值、反馈、保持和同步复位检查通过\n";
    return 0;
}
