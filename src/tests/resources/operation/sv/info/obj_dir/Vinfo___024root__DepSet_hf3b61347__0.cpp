// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vinfo.h for the primary calling header

#include "Vinfo__pch.h"
#include "Vinfo__Syms.h"
#include "Vinfo___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vinfo___024root___dump_triggers__ico(Vinfo___024root* vlSelf);
#endif  // VL_DEBUG

void Vinfo___024root___eval_triggers__ico(Vinfo___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vinfo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vinfo___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vinfo___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vinfo___024root___dump_triggers__act(Vinfo___024root* vlSelf);
#endif  // VL_DEBUG

void Vinfo___024root___eval_triggers__act(Vinfo___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vinfo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vinfo___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, ((IData)(vlSelf->clk) 
                                     & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))));
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vinfo___024root___dump_triggers__act(vlSelf);
    }
#endif
}

VL_INLINE_OPT void Vinfo___024root___nba_sequent__TOP__0(Vinfo___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vinfo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vinfo___024root___nba_sequent__TOP__0\n"); );
    // Body
    VL_WRITEF_NX("[%0t] -Info: info.sv:10: %NFoo: world\n",0,
                 64,VL_TIME_UNITED_Q(1),-12,vlSymsp->name());
}
