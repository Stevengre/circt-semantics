// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vshrs.h for the primary calling header

#include "Vshrs__pch.h"
#include "Vshrs__Syms.h"
#include "Vshrs___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vshrs___024root___dump_triggers__ico(Vshrs___024root* vlSelf);
#endif  // VL_DEBUG

void Vshrs___024root___eval_triggers__ico(Vshrs___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vshrs__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vshrs___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vshrs___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vshrs___024root___dump_triggers__act(Vshrs___024root* vlSelf);
#endif  // VL_DEBUG

void Vshrs___024root___eval_triggers__act(Vshrs___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vshrs__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vshrs___024root___eval_triggers__act\n"); );
    // Body
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vshrs___024root___dump_triggers__act(vlSelf);
    }
#endif
}
