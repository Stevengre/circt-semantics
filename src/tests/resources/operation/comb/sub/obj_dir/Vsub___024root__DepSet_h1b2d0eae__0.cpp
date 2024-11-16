// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vsub.h for the primary calling header

#include "Vsub__pch.h"
#include "Vsub__Syms.h"
#include "Vsub___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vsub___024root___dump_triggers__ico(Vsub___024root* vlSelf);
#endif  // VL_DEBUG

void Vsub___024root___eval_triggers__ico(Vsub___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vsub__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsub___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vsub___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vsub___024root___dump_triggers__act(Vsub___024root* vlSelf);
#endif  // VL_DEBUG

void Vsub___024root___eval_triggers__act(Vsub___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vsub__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsub___024root___eval_triggers__act\n"); );
    // Body
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vsub___024root___dump_triggers__act(vlSelf);
    }
#endif
}
