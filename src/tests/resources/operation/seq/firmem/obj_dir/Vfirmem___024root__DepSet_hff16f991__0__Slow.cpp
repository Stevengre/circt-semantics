// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirmem.h for the primary calling header

#include "Vfirmem__pch.h"
#include "Vfirmem___024root.h"

VL_ATTR_COLD void Vfirmem___024root___eval_static(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_static\n"); );
}

VL_ATTR_COLD void Vfirmem___024root___eval_initial(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_initial\n"); );
    // Body
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
}

VL_ATTR_COLD void Vfirmem___024root___eval_final(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_final\n"); );
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirmem___024root___dump_triggers__stl(Vfirmem___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vfirmem___024root___eval_phase__stl(Vfirmem___024root* vlSelf);

VL_ATTR_COLD void Vfirmem___024root___eval_settle(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_settle\n"); );
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
            Vfirmem___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("seq/firmem/firmem.sv", 78, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Vfirmem___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelf->__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirmem___024root___dump_triggers__stl(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VstlTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

void Vfirmem___024root___ico_sequent__TOP__0(Vfirmem___024root* vlSelf);

VL_ATTR_COLD void Vfirmem___024root___eval_stl(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_stl\n"); );
    // Body
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        Vfirmem___024root___ico_sequent__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD void Vfirmem___024root___eval_triggers__stl(Vfirmem___024root* vlSelf);

VL_ATTR_COLD bool Vfirmem___024root___eval_phase__stl(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_phase__stl\n"); );
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Vfirmem___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelf->__VstlTriggered.any();
    if (__VstlExecute) {
        Vfirmem___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirmem___024root___dump_triggers__ico(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___dump_triggers__ico\n"); );
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
VL_ATTR_COLD void Vfirmem___024root___dump_triggers__act(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___dump_triggers__act\n"); );
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
VL_ATTR_COLD void Vfirmem___024root___dump_triggers__nba(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VnbaTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vfirmem___024root___ctor_var_reset(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->data_in_w = VL_RAND_RESET_I(8);
    vlSelf->data_in_rw = VL_RAND_RESET_I(8);
    vlSelf->addr_r = VL_RAND_RESET_I(2);
    vlSelf->addr_w = VL_RAND_RESET_I(2);
    vlSelf->addr_rw = VL_RAND_RESET_I(2);
    vlSelf->mode = VL_RAND_RESET_I(1);
    vlSelf->enable_r = VL_RAND_RESET_I(1);
    vlSelf->enable_w = VL_RAND_RESET_I(1);
    vlSelf->enable_rw = VL_RAND_RESET_I(1);
    vlSelf->read_out = VL_RAND_RESET_I(8);
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->Foo__DOT__memory_ext__DOT__Memory[__Vi0] = VL_RAND_RESET_I(8);
    }
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = VL_RAND_RESET_I(1);
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
