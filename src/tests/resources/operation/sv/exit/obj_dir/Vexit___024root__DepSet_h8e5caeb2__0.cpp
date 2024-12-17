// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vexit.h for the primary calling header

#include "Vexit__pch.h"
#include "Vexit__Syms.h"
#include "Vexit___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vexit___024root___dump_triggers__ico(Vexit___024root* vlSelf);
#endif  // VL_DEBUG

void Vexit___024root___eval_triggers__ico(Vexit___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vexit__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexit___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vexit___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vexit___024root___dump_triggers__act(Vexit___024root* vlSelf);
#endif  // VL_DEBUG

void Vexit___024root___eval_triggers__act(Vexit___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vexit__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexit___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, ((IData)(vlSelf->clk) 
                                     & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))));
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vexit___024root___dump_triggers__act(vlSelf);
    }
#endif
}
