// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfor.h for the primary calling header

#include "Vfor__pch.h"
#include "Vfor__Syms.h"
#include "Vfor___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfor___024root___dump_triggers__ico(Vfor___024root* vlSelf);
#endif  // VL_DEBUG

void Vfor___024root___eval_triggers__ico(Vfor___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfor__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfor___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfor___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfor___024root___dump_triggers__act(Vfor___024root* vlSelf);
#endif  // VL_DEBUG

void Vfor___024root___eval_triggers__act(Vfor___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfor__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfor___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, ((IData)(vlSelf->clk) 
                                     & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))));
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfor___024root___dump_triggers__act(vlSelf);
    }
#endif
}

VL_INLINE_OPT void Vfor___024root___nba_sequent__TOP__0(Vfor___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfor__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfor___024root___nba_sequent__TOP__0\n"); );
    // Body
    vlSelf->Foo__DOT__unnamedblk1__DOT__i = 0U;
    while (((IData)(vlSelf->Foo__DOT__unnamedblk1__DOT__i) 
            < (IData)(vlSelf->b))) {
        VL_WRITEF_NX("[%0t] -Info: for.sv:11: %NFoo.unnamedblk1: This is a test\n",0,
                     64,VL_TIME_UNITED_Q(1),-12,vlSymsp->name());
        vlSelf->Foo__DOT__unnamedblk1__DOT__i = (0xffU 
                                                 & ((IData)(1U) 
                                                    + (IData)(vlSelf->Foo__DOT__unnamedblk1__DOT__i)));
    }
}
