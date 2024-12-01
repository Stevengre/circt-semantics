// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirreg.h for the primary calling header

#include "Vfirreg__pch.h"
#include "Vfirreg___024root.h"

VL_ATTR_COLD void Vfirreg___024root___eval_static(Vfirreg___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirreg___024root___eval_static\n"); );
}

VL_ATTR_COLD void Vfirreg___024root___eval_initial(Vfirreg___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirreg___024root___eval_initial\n"); );
    // Body
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
}

VL_ATTR_COLD void Vfirreg___024root___eval_final(Vfirreg___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirreg___024root___eval_final\n"); );
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirreg___024root___dump_triggers__stl(Vfirreg___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vfirreg___024root___eval_phase__stl(Vfirreg___024root* vlSelf);

VL_ATTR_COLD void Vfirreg___024root___eval_settle(Vfirreg___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirreg___024root___eval_settle\n"); );
    // Init
    IData/*31:0*/ __VstlIterCount;
    CData/*0:0*/ __VstlContinue;
    // Body
    __VstlIterCount = 0U;
    vlSelf->__VstlFirstIteration = 1U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        if (VL_UNLIKELY((0x64U < __VstlIterCount))) {
#ifdef VL_DEBUG
            Vfirreg___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("seq/firreg/firreg.sv", 46, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Vfirreg___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelf->__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirreg___024root___dump_triggers__stl(Vfirreg___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirreg___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VstlTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vfirreg___024root___stl_sequent__TOP__0(Vfirreg___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirreg___024root___stl_sequent__TOP__0\n"); );
    // Body
    vlSelf->res = vlSelf->Foo__DOT__reg_port;
}

VL_ATTR_COLD void Vfirreg___024root___eval_stl(Vfirreg___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirreg___024root___eval_stl\n"); );
    // Body
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        Vfirreg___024root___stl_sequent__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD void Vfirreg___024root___eval_triggers__stl(Vfirreg___024root* vlSelf);

VL_ATTR_COLD bool Vfirreg___024root___eval_phase__stl(Vfirreg___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirreg___024root___eval_phase__stl\n"); );
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Vfirreg___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelf->__VstlTriggered.any();
    if (__VstlExecute) {
        Vfirreg___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirreg___024root___dump_triggers__act(Vfirreg___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirreg___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VactTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge clk)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirreg___024root___dump_triggers__nba(Vfirreg___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirreg___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VnbaTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vfirreg___024root___ctor_var_reset(Vfirreg___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirreg___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->reset = VL_RAND_RESET_I(1);
    vlSelf->res = VL_RAND_RESET_I(8);
    vlSelf->Foo__DOT__reg_port = VL_RAND_RESET_I(8);
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = VL_RAND_RESET_I(1);
}
