// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Verror.h for the primary calling header

#include "Verror__pch.h"
#include "Verror__Syms.h"
#include "Verror___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Verror___024root___dump_triggers__ico(Verror___024root* vlSelf);
#endif  // VL_DEBUG

void Verror___024root___eval_triggers__ico(Verror___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Verror__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Verror___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Verror___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Verror___024root___dump_triggers__act(Verror___024root* vlSelf);
#endif  // VL_DEBUG

void Verror___024root___eval_triggers__act(Verror___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Verror__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Verror___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, ((IData)(vlSelf->clk) 
                                     & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))));
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Verror___024root___dump_triggers__act(vlSelf);
    }
#endif
}

VL_INLINE_OPT void Verror___024root___nba_sequent__TOP__0(Verror___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Verror__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Verror___024root___nba_sequent__TOP__0\n"); );
    // Body
    VL_STOP_MT("sv/error/error.sv", 10, "");
    VL_WRITEF_NX("[%0t] %%Error: error.sv:10: Assertion failed in %NFoo: error\n",0,
                 64,VL_TIME_UNITED_Q(1),-12,vlSymsp->name());
}
