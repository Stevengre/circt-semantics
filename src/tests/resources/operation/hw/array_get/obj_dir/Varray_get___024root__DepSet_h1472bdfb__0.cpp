// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Varray_get.h for the primary calling header

#include "Varray_get__pch.h"
#include "Varray_get___024root.h"

VL_INLINE_OPT void Varray_get___024root___ico_sequent__TOP__0(Varray_get___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root___ico_sequent__TOP__0\n"); );
    // Body
    vlSelf->res = (0xffU & ((IData)(vlSelf->a) + (IData)(vlSelf->b)));
}

void Varray_get___024root___eval_ico(Varray_get___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root___eval_ico\n"); );
    // Body
    if ((1ULL & vlSelf->__VicoTriggered.word(0U))) {
        Varray_get___024root___ico_sequent__TOP__0(vlSelf);
    }
}

void Varray_get___024root___eval_triggers__ico(Varray_get___024root* vlSelf);

bool Varray_get___024root___eval_phase__ico(Varray_get___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root___eval_phase__ico\n"); );
    // Init
    CData/*0:0*/ __VicoExecute;
    // Body
    Varray_get___024root___eval_triggers__ico(vlSelf);
    __VicoExecute = vlSelf->__VicoTriggered.any();
    if (__VicoExecute) {
        Varray_get___024root___eval_ico(vlSelf);
    }
    return (__VicoExecute);
}

void Varray_get___024root___eval_act(Varray_get___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root___eval_act\n"); );
}

void Varray_get___024root___eval_nba(Varray_get___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root___eval_nba\n"); );
}

void Varray_get___024root___eval_triggers__act(Varray_get___024root* vlSelf);

bool Varray_get___024root___eval_phase__act(Varray_get___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root___eval_phase__act\n"); );
    // Init
    VlTriggerVec<0> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Varray_get___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelf->__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelf->__VactTriggered, vlSelf->__VnbaTriggered);
        vlSelf->__VnbaTriggered.thisOr(vlSelf->__VactTriggered);
        Varray_get___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Varray_get___024root___eval_phase__nba(Varray_get___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root___eval_phase__nba\n"); );
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelf->__VnbaTriggered.any();
    if (__VnbaExecute) {
        Varray_get___024root___eval_nba(vlSelf);
        vlSelf->__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Varray_get___024root___dump_triggers__ico(Varray_get___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Varray_get___024root___dump_triggers__nba(Varray_get___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Varray_get___024root___dump_triggers__act(Varray_get___024root* vlSelf);
#endif  // VL_DEBUG

void Varray_get___024root___eval(Varray_get___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root___eval\n"); );
    // Init
    IData/*31:0*/ __VicoIterCount;
    CData/*0:0*/ __VicoContinue;
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VicoIterCount = 0U;
    vlSelf->__VicoFirstIteration = 1U;
    __VicoContinue = 1U;
    while (__VicoContinue) {
        if (VL_UNLIKELY((0x64U < __VicoIterCount))) {
#ifdef VL_DEBUG
            Varray_get___024root___dump_triggers__ico(vlSelf);
#endif
            VL_FATAL_MT("hw/array_get/array_get.sv", 2, "", "Input combinational region did not converge.");
        }
        __VicoIterCount = ((IData)(1U) + __VicoIterCount);
        __VicoContinue = 0U;
        if (Varray_get___024root___eval_phase__ico(vlSelf)) {
            __VicoContinue = 1U;
        }
        vlSelf->__VicoFirstIteration = 0U;
    }
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
            Varray_get___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("hw/array_get/array_get.sv", 2, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelf->__VactIterCount = 0U;
        vlSelf->__VactContinue = 1U;
        while (vlSelf->__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelf->__VactIterCount))) {
#ifdef VL_DEBUG
                Varray_get___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("hw/array_get/array_get.sv", 2, "", "Active region did not converge.");
            }
            vlSelf->__VactIterCount = ((IData)(1U) 
                                       + vlSelf->__VactIterCount);
            vlSelf->__VactContinue = 0U;
            if (Varray_get___024root___eval_phase__act(vlSelf)) {
                vlSelf->__VactContinue = 1U;
            }
        }
        if (Varray_get___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Varray_get___024root___eval_debug_assertions(Varray_get___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root___eval_debug_assertions\n"); );
}
#endif  // VL_DEBUG
