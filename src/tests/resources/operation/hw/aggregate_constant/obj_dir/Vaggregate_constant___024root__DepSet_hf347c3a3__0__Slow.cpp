// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vaggregate_constant.h for the primary calling header

#include "Vaggregate_constant__pch.h"
#include "Vaggregate_constant___024root.h"

VL_ATTR_COLD void Vaggregate_constant___024root___eval_static(Vaggregate_constant___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root___eval_static\n"); );
}

VL_ATTR_COLD void Vaggregate_constant___024root___eval_initial__TOP(Vaggregate_constant___024root* vlSelf);

VL_ATTR_COLD void Vaggregate_constant___024root___eval_initial(Vaggregate_constant___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root___eval_initial\n"); );
    // Body
    Vaggregate_constant___024root___eval_initial__TOP(vlSelf);
}

VL_ATTR_COLD void Vaggregate_constant___024root___eval_initial__TOP(Vaggregate_constant___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root___eval_initial__TOP\n"); );
    // Body
    vlSelf->res = 0x1bU;
}

VL_ATTR_COLD void Vaggregate_constant___024root___eval_final(Vaggregate_constant___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root___eval_final\n"); );
}

VL_ATTR_COLD void Vaggregate_constant___024root___eval_settle(Vaggregate_constant___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root___eval_settle\n"); );
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vaggregate_constant___024root___dump_triggers__act(Vaggregate_constant___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VactTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vaggregate_constant___024root___dump_triggers__nba(Vaggregate_constant___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VnbaTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vaggregate_constant___024root___ctor_var_reset(Vaggregate_constant___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->res = VL_RAND_RESET_I(6);
}
