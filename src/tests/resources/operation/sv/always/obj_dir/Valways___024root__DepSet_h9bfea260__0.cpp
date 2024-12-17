// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Valways.h for the primary calling header

#include "Valways__pch.h"
#include "Valways__Syms.h"
#include "Valways___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Valways___024root___dump_triggers__ico(Valways___024root* vlSelf);
#endif  // VL_DEBUG

void Valways___024root___eval_triggers__ico(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Valways___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Valways___024root___dump_triggers__act(Valways___024root* vlSelf);
#endif  // VL_DEBUG

void Valways___024root___eval_triggers__act(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, ((IData)(vlSelf->clk) 
                                     & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))));
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Valways___024root___dump_triggers__act(vlSelf);
    }
#endif
}

VL_INLINE_OPT void Valways___024root___nba_sequent__TOP__0(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___nba_sequent__TOP__0\n"); );
    // Body
    VL_WRITEF_NX("[%0t] %%Warning: always.sv:10: %NFoo: hello\n",0,
                 64,VL_TIME_UNITED_Q(1),-12,vlSymsp->name());
}
