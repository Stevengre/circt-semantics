// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Valways.h for the primary calling header

#include "Valways__pch.h"
#include "Valways___024root.h"

VL_ATTR_COLD void Valways___024root___eval_static(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___eval_static\n"); );
}

VL_ATTR_COLD void Valways___024root___eval_initial__TOP(Valways___024root* vlSelf);

VL_ATTR_COLD void Valways___024root___eval_initial(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___eval_initial\n"); );
    // Body
    Valways___024root___eval_initial__TOP(vlSelf);
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
}

VL_ATTR_COLD void Valways___024root___eval_final(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___eval_final\n"); );
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Valways___024root___dump_triggers__stl(Valways___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Valways___024root___eval_phase__stl(Valways___024root* vlSelf);

VL_ATTR_COLD void Valways___024root___eval_settle(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___eval_settle\n"); );
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
            Valways___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("sv/always/always.sv", 2, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Valways___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelf->__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Valways___024root___dump_triggers__stl(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VstlTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

void Valways___024root___ico_sequent__TOP__0(Valways___024root* vlSelf);

VL_ATTR_COLD void Valways___024root___eval_stl(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___eval_stl\n"); );
    // Body
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        Valways___024root___ico_sequent__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD void Valways___024root___eval_triggers__stl(Valways___024root* vlSelf);

VL_ATTR_COLD bool Valways___024root___eval_phase__stl(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___eval_phase__stl\n"); );
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Valways___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelf->__VstlTriggered.any();
    if (__VstlExecute) {
        Valways___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Valways___024root___dump_triggers__ico(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VicoTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VicoTriggered.word(0U))) {
        VL_DBG_MSGF("         'ico' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Valways___024root___dump_triggers__act(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___dump_triggers__act\n"); );
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
VL_ATTR_COLD void Valways___024root___dump_triggers__nba(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VnbaTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Valways___024root___ctor_var_reset(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->a = VL_RAND_RESET_I(8);
    vlSelf->b = VL_RAND_RESET_I(8);
    vlSelf->result = VL_RAND_RESET_I(8);
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = VL_RAND_RESET_I(1);
}
