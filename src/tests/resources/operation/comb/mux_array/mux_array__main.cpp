// 独立逐元素参考模型；任意元素、任意输入事件不一致都会返回失败。
#include <array>
#include <fstream>
#include <iostream>
#include <json/json.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vmux_array.h"

int main(int argc, char** argv) {
    VerilatedContext context;
    context.commandArgs(argc, argv);
    context.randReset(0);
    context.traceEverOn(true);
    Vmux_array dut(&context, "Foo");
    VerilatedVcdC trace;
    trace.set_time_unit("1ns");
    trace.set_time_resolution("1ns");
    dut.trace(&trace, 99);
    trace.open("./comb/mux_array/trace_vtor.vcd");
    std::ifstream source("./comb/mux_array/test_data.json");
    Json::Value document;
    if (!source || !(source >> document) || !document["inputs"].isArray() || document["inputs"].empty()) {
        std::cerr << "输入文件缺失、无效或为空\n";
        return 2;
    }
    std::array<unsigned, 4> expected4{};
    std::array<unsigned, 32> expected32{};
    unsigned previous_clock = 0, edges = 0;
    const auto& inputs = document["inputs"];
    for (Json::ArrayIndex t = 0; t < inputs.size(); ++t) {
        const auto& row = inputs[t];
        if (row.size() != 33) return 2;
        if (!row[0][0].isUInt() || row[0][0].asUInt() >= (1u << 1) || row[0][1].asUInt() != 1) return 2;
        dut.sel = row[0][0].asUInt();
        if (!row[1][0].isUInt() || row[1][0].asUInt() >= (1u << 10) || row[1][1].asUInt() != 10) return 2;
        dut.d0 = row[1][0].asUInt();
        if (!row[2][0].isUInt() || row[2][0].asUInt() >= (1u << 10) || row[2][1].asUInt() != 10) return 2;
        dut.d1 = row[2][0].asUInt();
        if (!row[3][0].isUInt() || row[3][0].asUInt() >= (1u << 10) || row[3][1].asUInt() != 10) return 2;
        dut.d2 = row[3][0].asUInt();
        if (!row[4][0].isUInt() || row[4][0].asUInt() >= (1u << 10) || row[4][1].asUInt() != 10) return 2;
        dut.d3 = row[4][0].asUInt();
        if (!row[5][0].isUInt() || row[5][0].asUInt() >= (1u << 10) || row[5][1].asUInt() != 10) return 2;
        dut.d4 = row[5][0].asUInt();
        if (!row[6][0].isUInt() || row[6][0].asUInt() >= (1u << 10) || row[6][1].asUInt() != 10) return 2;
        dut.d5 = row[6][0].asUInt();
        if (!row[7][0].isUInt() || row[7][0].asUInt() >= (1u << 10) || row[7][1].asUInt() != 10) return 2;
        dut.d6 = row[7][0].asUInt();
        if (!row[8][0].isUInt() || row[8][0].asUInt() >= (1u << 10) || row[8][1].asUInt() != 10) return 2;
        dut.d7 = row[8][0].asUInt();
        if (!row[9][0].isUInt() || row[9][0].asUInt() >= (1u << 10) || row[9][1].asUInt() != 10) return 2;
        dut.d8 = row[9][0].asUInt();
        if (!row[10][0].isUInt() || row[10][0].asUInt() >= (1u << 10) || row[10][1].asUInt() != 10) return 2;
        dut.d9 = row[10][0].asUInt();
        if (!row[11][0].isUInt() || row[11][0].asUInt() >= (1u << 10) || row[11][1].asUInt() != 10) return 2;
        dut.d10 = row[11][0].asUInt();
        if (!row[12][0].isUInt() || row[12][0].asUInt() >= (1u << 10) || row[12][1].asUInt() != 10) return 2;
        dut.d11 = row[12][0].asUInt();
        if (!row[13][0].isUInt() || row[13][0].asUInt() >= (1u << 10) || row[13][1].asUInt() != 10) return 2;
        dut.d12 = row[13][0].asUInt();
        if (!row[14][0].isUInt() || row[14][0].asUInt() >= (1u << 10) || row[14][1].asUInt() != 10) return 2;
        dut.d13 = row[14][0].asUInt();
        if (!row[15][0].isUInt() || row[15][0].asUInt() >= (1u << 10) || row[15][1].asUInt() != 10) return 2;
        dut.d14 = row[15][0].asUInt();
        if (!row[16][0].isUInt() || row[16][0].asUInt() >= (1u << 10) || row[16][1].asUInt() != 10) return 2;
        dut.d15 = row[16][0].asUInt();
        if (!row[17][0].isUInt() || row[17][0].asUInt() >= (1u << 10) || row[17][1].asUInt() != 10) return 2;
        dut.d16 = row[17][0].asUInt();
        if (!row[18][0].isUInt() || row[18][0].asUInt() >= (1u << 10) || row[18][1].asUInt() != 10) return 2;
        dut.d17 = row[18][0].asUInt();
        if (!row[19][0].isUInt() || row[19][0].asUInt() >= (1u << 10) || row[19][1].asUInt() != 10) return 2;
        dut.d18 = row[19][0].asUInt();
        if (!row[20][0].isUInt() || row[20][0].asUInt() >= (1u << 10) || row[20][1].asUInt() != 10) return 2;
        dut.d19 = row[20][0].asUInt();
        if (!row[21][0].isUInt() || row[21][0].asUInt() >= (1u << 10) || row[21][1].asUInt() != 10) return 2;
        dut.d20 = row[21][0].asUInt();
        if (!row[22][0].isUInt() || row[22][0].asUInt() >= (1u << 10) || row[22][1].asUInt() != 10) return 2;
        dut.d21 = row[22][0].asUInt();
        if (!row[23][0].isUInt() || row[23][0].asUInt() >= (1u << 10) || row[23][1].asUInt() != 10) return 2;
        dut.d22 = row[23][0].asUInt();
        if (!row[24][0].isUInt() || row[24][0].asUInt() >= (1u << 10) || row[24][1].asUInt() != 10) return 2;
        dut.d23 = row[24][0].asUInt();
        if (!row[25][0].isUInt() || row[25][0].asUInt() >= (1u << 10) || row[25][1].asUInt() != 10) return 2;
        dut.d24 = row[25][0].asUInt();
        if (!row[26][0].isUInt() || row[26][0].asUInt() >= (1u << 10) || row[26][1].asUInt() != 10) return 2;
        dut.d25 = row[26][0].asUInt();
        if (!row[27][0].isUInt() || row[27][0].asUInt() >= (1u << 10) || row[27][1].asUInt() != 10) return 2;
        dut.d26 = row[27][0].asUInt();
        if (!row[28][0].isUInt() || row[28][0].asUInt() >= (1u << 10) || row[28][1].asUInt() != 10) return 2;
        dut.d27 = row[28][0].asUInt();
        if (!row[29][0].isUInt() || row[29][0].asUInt() >= (1u << 10) || row[29][1].asUInt() != 10) return 2;
        dut.d28 = row[29][0].asUInt();
        if (!row[30][0].isUInt() || row[30][0].asUInt() >= (1u << 10) || row[30][1].asUInt() != 10) return 2;
        dut.d29 = row[30][0].asUInt();
        if (!row[31][0].isUInt() || row[31][0].asUInt() >= (1u << 10) || row[31][1].asUInt() != 10) return 2;
        dut.d30 = row[31][0].asUInt();
        if (!row[32][0].isUInt() || row[32][0].asUInt() >= (1u << 10) || row[32][1].asUInt() != 10) return 2;
        dut.d31 = row[32][0].asUInt();
        const std::array<unsigned, 32> data = {dut.d0, dut.d1, dut.d2, dut.d3, dut.d4, dut.d5, dut.d6, dut.d7, dut.d8, dut.d9, dut.d10, dut.d11, dut.d12, dut.d13, dut.d14, dut.d15, dut.d16, dut.d17, dut.d18, dut.d19, dut.d20, dut.d21, dut.d22, dut.d23, dut.d24, dut.d25, dut.d26, dut.d27, dut.d28, dut.d29, dut.d30, dut.d31};
        for (unsigned i = 0; i < 4; ++i) expected4[i] = data[dut.sel ? i : 3-i];
        for (unsigned i = 0; i < 32; ++i) expected32[i] = data[dut.sel ? i : 31-i];
        dut.eval();
        trace.dump(t);
        if (dut.r4_0 != expected4[0]) { std::cerr << "事件 " << t << " 的 r4_0 不一致: " << unsigned(dut.r4_0) << " != " << expected4[0] << "\n"; trace.close(); return 1; }
        if (dut.r4_1 != expected4[1]) { std::cerr << "事件 " << t << " 的 r4_1 不一致: " << unsigned(dut.r4_1) << " != " << expected4[1] << "\n"; trace.close(); return 1; }
        if (dut.r4_2 != expected4[2]) { std::cerr << "事件 " << t << " 的 r4_2 不一致: " << unsigned(dut.r4_2) << " != " << expected4[2] << "\n"; trace.close(); return 1; }
        if (dut.r4_3 != expected4[3]) { std::cerr << "事件 " << t << " 的 r4_3 不一致: " << unsigned(dut.r4_3) << " != " << expected4[3] << "\n"; trace.close(); return 1; }
        if (dut.r32_0 != expected32[0]) { std::cerr << "事件 " << t << " 的 r32_0 不一致: " << unsigned(dut.r32_0) << " != " << expected32[0] << "\n"; trace.close(); return 1; }
        if (dut.r32_1 != expected32[1]) { std::cerr << "事件 " << t << " 的 r32_1 不一致: " << unsigned(dut.r32_1) << " != " << expected32[1] << "\n"; trace.close(); return 1; }
        if (dut.r32_2 != expected32[2]) { std::cerr << "事件 " << t << " 的 r32_2 不一致: " << unsigned(dut.r32_2) << " != " << expected32[2] << "\n"; trace.close(); return 1; }
        if (dut.r32_3 != expected32[3]) { std::cerr << "事件 " << t << " 的 r32_3 不一致: " << unsigned(dut.r32_3) << " != " << expected32[3] << "\n"; trace.close(); return 1; }
        if (dut.r32_4 != expected32[4]) { std::cerr << "事件 " << t << " 的 r32_4 不一致: " << unsigned(dut.r32_4) << " != " << expected32[4] << "\n"; trace.close(); return 1; }
        if (dut.r32_5 != expected32[5]) { std::cerr << "事件 " << t << " 的 r32_5 不一致: " << unsigned(dut.r32_5) << " != " << expected32[5] << "\n"; trace.close(); return 1; }
        if (dut.r32_6 != expected32[6]) { std::cerr << "事件 " << t << " 的 r32_6 不一致: " << unsigned(dut.r32_6) << " != " << expected32[6] << "\n"; trace.close(); return 1; }
        if (dut.r32_7 != expected32[7]) { std::cerr << "事件 " << t << " 的 r32_7 不一致: " << unsigned(dut.r32_7) << " != " << expected32[7] << "\n"; trace.close(); return 1; }
        if (dut.r32_8 != expected32[8]) { std::cerr << "事件 " << t << " 的 r32_8 不一致: " << unsigned(dut.r32_8) << " != " << expected32[8] << "\n"; trace.close(); return 1; }
        if (dut.r32_9 != expected32[9]) { std::cerr << "事件 " << t << " 的 r32_9 不一致: " << unsigned(dut.r32_9) << " != " << expected32[9] << "\n"; trace.close(); return 1; }
        if (dut.r32_10 != expected32[10]) { std::cerr << "事件 " << t << " 的 r32_10 不一致: " << unsigned(dut.r32_10) << " != " << expected32[10] << "\n"; trace.close(); return 1; }
        if (dut.r32_11 != expected32[11]) { std::cerr << "事件 " << t << " 的 r32_11 不一致: " << unsigned(dut.r32_11) << " != " << expected32[11] << "\n"; trace.close(); return 1; }
        if (dut.r32_12 != expected32[12]) { std::cerr << "事件 " << t << " 的 r32_12 不一致: " << unsigned(dut.r32_12) << " != " << expected32[12] << "\n"; trace.close(); return 1; }
        if (dut.r32_13 != expected32[13]) { std::cerr << "事件 " << t << " 的 r32_13 不一致: " << unsigned(dut.r32_13) << " != " << expected32[13] << "\n"; trace.close(); return 1; }
        if (dut.r32_14 != expected32[14]) { std::cerr << "事件 " << t << " 的 r32_14 不一致: " << unsigned(dut.r32_14) << " != " << expected32[14] << "\n"; trace.close(); return 1; }
        if (dut.r32_15 != expected32[15]) { std::cerr << "事件 " << t << " 的 r32_15 不一致: " << unsigned(dut.r32_15) << " != " << expected32[15] << "\n"; trace.close(); return 1; }
        if (dut.r32_16 != expected32[16]) { std::cerr << "事件 " << t << " 的 r32_16 不一致: " << unsigned(dut.r32_16) << " != " << expected32[16] << "\n"; trace.close(); return 1; }
        if (dut.r32_17 != expected32[17]) { std::cerr << "事件 " << t << " 的 r32_17 不一致: " << unsigned(dut.r32_17) << " != " << expected32[17] << "\n"; trace.close(); return 1; }
        if (dut.r32_18 != expected32[18]) { std::cerr << "事件 " << t << " 的 r32_18 不一致: " << unsigned(dut.r32_18) << " != " << expected32[18] << "\n"; trace.close(); return 1; }
        if (dut.r32_19 != expected32[19]) { std::cerr << "事件 " << t << " 的 r32_19 不一致: " << unsigned(dut.r32_19) << " != " << expected32[19] << "\n"; trace.close(); return 1; }
        if (dut.r32_20 != expected32[20]) { std::cerr << "事件 " << t << " 的 r32_20 不一致: " << unsigned(dut.r32_20) << " != " << expected32[20] << "\n"; trace.close(); return 1; }
        if (dut.r32_21 != expected32[21]) { std::cerr << "事件 " << t << " 的 r32_21 不一致: " << unsigned(dut.r32_21) << " != " << expected32[21] << "\n"; trace.close(); return 1; }
        if (dut.r32_22 != expected32[22]) { std::cerr << "事件 " << t << " 的 r32_22 不一致: " << unsigned(dut.r32_22) << " != " << expected32[22] << "\n"; trace.close(); return 1; }
        if (dut.r32_23 != expected32[23]) { std::cerr << "事件 " << t << " 的 r32_23 不一致: " << unsigned(dut.r32_23) << " != " << expected32[23] << "\n"; trace.close(); return 1; }
        if (dut.r32_24 != expected32[24]) { std::cerr << "事件 " << t << " 的 r32_24 不一致: " << unsigned(dut.r32_24) << " != " << expected32[24] << "\n"; trace.close(); return 1; }
        if (dut.r32_25 != expected32[25]) { std::cerr << "事件 " << t << " 的 r32_25 不一致: " << unsigned(dut.r32_25) << " != " << expected32[25] << "\n"; trace.close(); return 1; }
        if (dut.r32_26 != expected32[26]) { std::cerr << "事件 " << t << " 的 r32_26 不一致: " << unsigned(dut.r32_26) << " != " << expected32[26] << "\n"; trace.close(); return 1; }
        if (dut.r32_27 != expected32[27]) { std::cerr << "事件 " << t << " 的 r32_27 不一致: " << unsigned(dut.r32_27) << " != " << expected32[27] << "\n"; trace.close(); return 1; }
        if (dut.r32_28 != expected32[28]) { std::cerr << "事件 " << t << " 的 r32_28 不一致: " << unsigned(dut.r32_28) << " != " << expected32[28] << "\n"; trace.close(); return 1; }
        if (dut.r32_29 != expected32[29]) { std::cerr << "事件 " << t << " 的 r32_29 不一致: " << unsigned(dut.r32_29) << " != " << expected32[29] << "\n"; trace.close(); return 1; }
        if (dut.r32_30 != expected32[30]) { std::cerr << "事件 " << t << " 的 r32_30 不一致: " << unsigned(dut.r32_30) << " != " << expected32[30] << "\n"; trace.close(); return 1; }
        if (dut.r32_31 != expected32[31]) { std::cerr << "事件 " << t << " 的 r32_31 不一致: " << unsigned(dut.r32_31) << " != " << expected32[31] << "\n"; trace.close(); return 1; }
    }
    dut.final();
    trace.close();
    std::cout << "全部 " << inputs.size() << " 个输入事件及逐元素参考检查通过\n";
    return 0;
}
