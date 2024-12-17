// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfatal.h for the primary calling header

#include "Vfatal__pch.h"
#include "Vfatal__Syms.h"
#include "Vfatal___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfatal___024root___dump_triggers__ico(Vfatal___024root* vlSelf);
#endif  // VL_DEBUG

void Vfatal___024root___eval_triggers__ico(Vfatal___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfatal__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfatal___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfatal___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfatal___024root___dump_triggers__act(Vfatal___024root* vlSelf);
#endif  // VL_DEBUG

void Vfatal___024root___eval_triggers__act(Vfatal___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfatal__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfatal___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, ((IData)(vlSelf->clk) 
                                     & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))));
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfatal___024root___dump_triggers__act(vlSelf);
    }
#endif
}

VL_INLINE_OPT void Vfatal___024root___nba_sequent__TOP__0(Vfatal___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfatal__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfatal___024root___nba_sequent__TOP__0\n"); );
    // Body
    VL_STOP_MT("sv/fatal/fatal.sv", 10, "");
    VL_WRITEF_NX("[%0t] %%Fatal: fatal.sv:10: Assertion failed in %NFoo\n",0,
                 64,VL_TIME_UNITED_Q(1),-12,vlSymsp->name());
}
