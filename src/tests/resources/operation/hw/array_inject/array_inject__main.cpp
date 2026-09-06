// 独立逐元素参考模型；任意元素、任意输入事件不一致都会返回失败。
#include <array>
#include <fstream>
#include <iostream>
#include <json/json.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Varray_inject.h"

int main(int argc, char** argv) {
    VerilatedContext context;
    context.commandArgs(argc, argv);
    context.randReset(0);
    context.traceEverOn(true);
    Varray_inject dut(&context, "Foo");
    VerilatedVcdC trace;
    trace.set_time_unit("1ns");
    trace.set_time_resolution("1ns");
    dut.trace(&trace, 99);
    trace.open("./hw/array_inject/trace_vtor.vcd");
    std::ifstream source("./hw/array_inject/test_data.json");
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
        if (row.size() != 40) return 2;
        if (!row[0][0].isUInt() || row[0][0].asUInt() >= (1u << 10) || row[0][1].asUInt() != 10) return 2;
        dut.d0 = row[0][0].asUInt();
        if (!row[1][0].isUInt() || row[1][0].asUInt() >= (1u << 10) || row[1][1].asUInt() != 10) return 2;
        dut.d1 = row[1][0].asUInt();
        if (!row[2][0].isUInt() || row[2][0].asUInt() >= (1u << 10) || row[2][1].asUInt() != 10) return 2;
        dut.d2 = row[2][0].asUInt();
        if (!row[3][0].isUInt() || row[3][0].asUInt() >= (1u << 10) || row[3][1].asUInt() != 10) return 2;
        dut.d3 = row[3][0].asUInt();
        if (!row[4][0].isUInt() || row[4][0].asUInt() >= (1u << 10) || row[4][1].asUInt() != 10) return 2;
        dut.d4 = row[4][0].asUInt();
        if (!row[5][0].isUInt() || row[5][0].asUInt() >= (1u << 10) || row[5][1].asUInt() != 10) return 2;
        dut.d5 = row[5][0].asUInt();
        if (!row[6][0].isUInt() || row[6][0].asUInt() >= (1u << 10) || row[6][1].asUInt() != 10) return 2;
        dut.d6 = row[6][0].asUInt();
        if (!row[7][0].isUInt() || row[7][0].asUInt() >= (1u << 10) || row[7][1].asUInt() != 10) return 2;
        dut.d7 = row[7][0].asUInt();
        if (!row[8][0].isUInt() || row[8][0].asUInt() >= (1u << 10) || row[8][1].asUInt() != 10) return 2;
        dut.d8 = row[8][0].asUInt();
        if (!row[9][0].isUInt() || row[9][0].asUInt() >= (1u << 10) || row[9][1].asUInt() != 10) return 2;
        dut.d9 = row[9][0].asUInt();
        if (!row[10][0].isUInt() || row[10][0].asUInt() >= (1u << 10) || row[10][1].asUInt() != 10) return 2;
        dut.d10 = row[10][0].asUInt();
        if (!row[11][0].isUInt() || row[11][0].asUInt() >= (1u << 10) || row[11][1].asUInt() != 10) return 2;
        dut.d11 = row[11][0].asUInt();
        if (!row[12][0].isUInt() || row[12][0].asUInt() >= (1u << 10) || row[12][1].asUInt() != 10) return 2;
        dut.d12 = row[12][0].asUInt();
        if (!row[13][0].isUInt() || row[13][0].asUInt() >= (1u << 10) || row[13][1].asUInt() != 10) return 2;
        dut.d13 = row[13][0].asUInt();
        if (!row[14][0].isUInt() || row[14][0].asUInt() >= (1u << 10) || row[14][1].asUInt() != 10) return 2;
        dut.d14 = row[14][0].asUInt();
        if (!row[15][0].isUInt() || row[15][0].asUInt() >= (1u << 10) || row[15][1].asUInt() != 10) return 2;
        dut.d15 = row[15][0].asUInt();
        if (!row[16][0].isUInt() || row[16][0].asUInt() >= (1u << 10) || row[16][1].asUInt() != 10) return 2;
        dut.d16 = row[16][0].asUInt();
        if (!row[17][0].isUInt() || row[17][0].asUInt() >= (1u << 10) || row[17][1].asUInt() != 10) return 2;
        dut.d17 = row[17][0].asUInt();
        if (!row[18][0].isUInt() || row[18][0].asUInt() >= (1u << 10) || row[18][1].asUInt() != 10) return 2;
        dut.d18 = row[18][0].asUInt();
        if (!row[19][0].isUInt() || row[19][0].asUInt() >= (1u << 10) || row[19][1].asUInt() != 10) return 2;
        dut.d19 = row[19][0].asUInt();
        if (!row[20][0].isUInt() || row[20][0].asUInt() >= (1u << 10) || row[20][1].asUInt() != 10) return 2;
        dut.d20 = row[20][0].asUInt();
        if (!row[21][0].isUInt() || row[21][0].asUInt() >= (1u << 10) || row[21][1].asUInt() != 10) return 2;
        dut.d21 = row[21][0].asUInt();
        if (!row[22][0].isUInt() || row[22][0].asUInt() >= (1u << 10) || row[22][1].asUInt() != 10) return 2;
        dut.d22 = row[22][0].asUInt();
        if (!row[23][0].isUInt() || row[23][0].asUInt() >= (1u << 10) || row[23][1].asUInt() != 10) return 2;
        dut.d23 = row[23][0].asUInt();
        if (!row[24][0].isUInt() || row[24][0].asUInt() >= (1u << 10) || row[24][1].asUInt() != 10) return 2;
        dut.d24 = row[24][0].asUInt();
        if (!row[25][0].isUInt() || row[25][0].asUInt() >= (1u << 10) || row[25][1].asUInt() != 10) return 2;
        dut.d25 = row[25][0].asUInt();
        if (!row[26][0].isUInt() || row[26][0].asUInt() >= (1u << 10) || row[26][1].asUInt() != 10) return 2;
        dut.d26 = row[26][0].asUInt();
        if (!row[27][0].isUInt() || row[27][0].asUInt() >= (1u << 10) || row[27][1].asUInt() != 10) return 2;
        dut.d27 = row[27][0].asUInt();
        if (!row[28][0].isUInt() || row[28][0].asUInt() >= (1u << 10) || row[28][1].asUInt() != 10) return 2;
        dut.d28 = row[28][0].asUInt();
        if (!row[29][0].isUInt() || row[29][0].asUInt() >= (1u << 10) || row[29][1].asUInt() != 10) return 2;
        dut.d29 = row[29][0].asUInt();
        if (!row[30][0].isUInt() || row[30][0].asUInt() >= (1u << 10) || row[30][1].asUInt() != 10) return 2;
        dut.d30 = row[30][0].asUInt();
        if (!row[31][0].isUInt() || row[31][0].asUInt() >= (1u << 10) || row[31][1].asUInt() != 10) return 2;
        dut.d31 = row[31][0].asUInt();
        if (!row[32][0].isUInt() || row[32][0].asUInt() >= (1u << 2) || row[32][1].asUInt() != 2) return 2;
        dut.idx4 = row[32][0].asUInt();
        if (!row[33][0].isUInt() || row[33][0].asUInt() >= (1u << 5) || row[33][1].asUInt() != 5) return 2;
        dut.idx32 = row[33][0].asUInt();
        if (!row[34][0].isUInt() || row[34][0].asUInt() >= (1u << 10) || row[34][1].asUInt() != 10) return 2;
        dut.value = row[34][0].asUInt();
        if (!row[35][0].isUInt() || row[35][0].asUInt() >= (1u << 2) || row[35][1].asUInt() != 2) return 2;
        dut.s0 = row[35][0].asUInt();
        if (!row[36][0].isUInt() || row[36][0].asUInt() >= (1u << 2) || row[36][1].asUInt() != 2) return 2;
        dut.s1 = row[36][0].asUInt();
        if (!row[37][0].isUInt() || row[37][0].asUInt() >= (1u << 2) || row[37][1].asUInt() != 2) return 2;
        dut.s2 = row[37][0].asUInt();
        if (!row[38][0].isUInt() || row[38][0].asUInt() >= (1u << 2) || row[38][1].asUInt() != 2) return 2;
        dut.idx3 = row[38][0].asUInt();
        if (!row[39][0].isUInt() || row[39][0].asUInt() >= (1u << 2) || row[39][1].asUInt() != 2) return 2;
        dut.value3 = row[39][0].asUInt();
        const std::array<unsigned, 32> data = {dut.d0, dut.d1, dut.d2, dut.d3, dut.d4, dut.d5, dut.d6, dut.d7, dut.d8, dut.d9, dut.d10, dut.d11, dut.d12, dut.d13, dut.d14, dut.d15, dut.d16, dut.d17, dut.d18, dut.d19, dut.d20, dut.d21, dut.d22, dut.d23, dut.d24, dut.d25, dut.d26, dut.d27, dut.d28, dut.d29, dut.d30, dut.d31};
        if (dut.idx3 >= 3) return 2;
        for (unsigned i = 0; i < 4; ++i) expected4[i] = i == dut.idx4 ? dut.value : data[i];
        for (unsigned i = 0; i < 32; ++i) expected32[i] = i == dut.idx32 ? dut.value : data[i];
        std::array<unsigned, 3> expected3 = {dut.s0, dut.s1, dut.s2};
        expected3[dut.idx3] = dut.value3;
        dut.eval();
        trace.dump(t);
        if (dut.original4_0 != dut.d0) { std::cerr << "原数组元素 4:0 被修改\n"; trace.close(); return 1; }
        if (dut.original4_1 != dut.d1) { std::cerr << "原数组元素 4:1 被修改\n"; trace.close(); return 1; }
        if (dut.original4_2 != dut.d2) { std::cerr << "原数组元素 4:2 被修改\n"; trace.close(); return 1; }
        if (dut.original4_3 != dut.d3) { std::cerr << "原数组元素 4:3 被修改\n"; trace.close(); return 1; }
        if (dut.original32_0 != dut.d0) { std::cerr << "原数组元素 32:0 被修改\n"; trace.close(); return 1; }
        if (dut.original32_1 != dut.d1) { std::cerr << "原数组元素 32:1 被修改\n"; trace.close(); return 1; }
        if (dut.original32_2 != dut.d2) { std::cerr << "原数组元素 32:2 被修改\n"; trace.close(); return 1; }
        if (dut.original32_3 != dut.d3) { std::cerr << "原数组元素 32:3 被修改\n"; trace.close(); return 1; }
        if (dut.original32_4 != dut.d4) { std::cerr << "原数组元素 32:4 被修改\n"; trace.close(); return 1; }
        if (dut.original32_5 != dut.d5) { std::cerr << "原数组元素 32:5 被修改\n"; trace.close(); return 1; }
        if (dut.original32_6 != dut.d6) { std::cerr << "原数组元素 32:6 被修改\n"; trace.close(); return 1; }
        if (dut.original32_7 != dut.d7) { std::cerr << "原数组元素 32:7 被修改\n"; trace.close(); return 1; }
        if (dut.original32_8 != dut.d8) { std::cerr << "原数组元素 32:8 被修改\n"; trace.close(); return 1; }
        if (dut.original32_9 != dut.d9) { std::cerr << "原数组元素 32:9 被修改\n"; trace.close(); return 1; }
        if (dut.original32_10 != dut.d10) { std::cerr << "原数组元素 32:10 被修改\n"; trace.close(); return 1; }
        if (dut.original32_11 != dut.d11) { std::cerr << "原数组元素 32:11 被修改\n"; trace.close(); return 1; }
        if (dut.original32_12 != dut.d12) { std::cerr << "原数组元素 32:12 被修改\n"; trace.close(); return 1; }
        if (dut.original32_13 != dut.d13) { std::cerr << "原数组元素 32:13 被修改\n"; trace.close(); return 1; }
        if (dut.original32_14 != dut.d14) { std::cerr << "原数组元素 32:14 被修改\n"; trace.close(); return 1; }
        if (dut.original32_15 != dut.d15) { std::cerr << "原数组元素 32:15 被修改\n"; trace.close(); return 1; }
        if (dut.original32_16 != dut.d16) { std::cerr << "原数组元素 32:16 被修改\n"; trace.close(); return 1; }
        if (dut.original32_17 != dut.d17) { std::cerr << "原数组元素 32:17 被修改\n"; trace.close(); return 1; }
        if (dut.original32_18 != dut.d18) { std::cerr << "原数组元素 32:18 被修改\n"; trace.close(); return 1; }
        if (dut.original32_19 != dut.d19) { std::cerr << "原数组元素 32:19 被修改\n"; trace.close(); return 1; }
        if (dut.original32_20 != dut.d20) { std::cerr << "原数组元素 32:20 被修改\n"; trace.close(); return 1; }
        if (dut.original32_21 != dut.d21) { std::cerr << "原数组元素 32:21 被修改\n"; trace.close(); return 1; }
        if (dut.original32_22 != dut.d22) { std::cerr << "原数组元素 32:22 被修改\n"; trace.close(); return 1; }
        if (dut.original32_23 != dut.d23) { std::cerr << "原数组元素 32:23 被修改\n"; trace.close(); return 1; }
        if (dut.original32_24 != dut.d24) { std::cerr << "原数组元素 32:24 被修改\n"; trace.close(); return 1; }
        if (dut.original32_25 != dut.d25) { std::cerr << "原数组元素 32:25 被修改\n"; trace.close(); return 1; }
        if (dut.original32_26 != dut.d26) { std::cerr << "原数组元素 32:26 被修改\n"; trace.close(); return 1; }
        if (dut.original32_27 != dut.d27) { std::cerr << "原数组元素 32:27 被修改\n"; trace.close(); return 1; }
        if (dut.original32_28 != dut.d28) { std::cerr << "原数组元素 32:28 被修改\n"; trace.close(); return 1; }
        if (dut.original32_29 != dut.d29) { std::cerr << "原数组元素 32:29 被修改\n"; trace.close(); return 1; }
        if (dut.original32_30 != dut.d30) { std::cerr << "原数组元素 32:30 被修改\n"; trace.close(); return 1; }
        if (dut.original32_31 != dut.d31) { std::cerr << "原数组元素 32:31 被修改\n"; trace.close(); return 1; }
        if (dut.original3_0 != dut.s0) { std::cerr << "原数组元素 3:0 被修改\n"; trace.close(); return 1; }
        if (dut.original3_1 != dut.s1) { std::cerr << "原数组元素 3:1 被修改\n"; trace.close(); return 1; }
        if (dut.original3_2 != dut.s2) { std::cerr << "原数组元素 3:2 被修改\n"; trace.close(); return 1; }
        if (dut.singleton != dut.value || dut.negative_last != dut.value) { std::cerr << "单元素或负数字面量索引检查失败\n"; trace.close(); return 1; }
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
        if (dut.r3_0 != expected3[0]) { std::cerr << "事件 " << t << " 的 r3_0 不一致: " << unsigned(dut.r3_0) << " != " << expected3[0] << "\n"; trace.close(); return 1; }
        if (dut.r3_1 != expected3[1]) { std::cerr << "事件 " << t << " 的 r3_1 不一致: " << unsigned(dut.r3_1) << " != " << expected3[1] << "\n"; trace.close(); return 1; }
        if (dut.r3_2 != expected3[2]) { std::cerr << "事件 " << t << " 的 r3_2 不一致: " << unsigned(dut.r3_2) << " != " << expected3[2] << "\n"; trace.close(); return 1; }
    }
    dut.final();
    trace.close();
    std::cout << "全部 " << inputs.size() << " 个输入事件及逐元素参考检查通过\n";
    return 0;
}
