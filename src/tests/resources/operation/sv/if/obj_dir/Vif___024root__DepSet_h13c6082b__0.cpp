// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vif.h for the primary calling header

#include "Vif__pch.h"
#include "Vif__Syms.h"
#include "Vif___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vif___024root___dump_triggers__ico(Vif___024root* vlSelf);
#endif  // VL_DEBUG

void Vif___024root___eval_triggers__ico(Vif___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vif__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vif___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vif___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vif___024root___dump_triggers__act(Vif___024root* vlSelf);
#endif  // VL_DEBUG

void Vif___024root___eval_triggers__act(Vif___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vif__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vif___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, ((IData)(vlSelf->clk) 
                                     & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))));
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vif___024root___dump_triggers__act(vlSelf);
    }
#endif
}

VL_INLINE_OPT void Vif___024root___nba_sequent__TOP__0(Vif___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vif__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vif___024root___nba_sequent__TOP__0\n"); );
    // Body
    VL_WRITEF_NX("[%0t] -Info: if.sv:10: %NFoo: hitIf\n",0,
                 64,VL_TIME_UNITED_Q(1),-12,vlSymsp->name());
}
