// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vor.h for the primary calling header

#include "Vor__pch.h"
#include "Vor__Syms.h"
#include "Vor___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vor___024root___dump_triggers__ico(Vor___024root* vlSelf);
#endif  // VL_DEBUG

void Vor___024root___eval_triggers__ico(Vor___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vor__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vor___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vor___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vor___024root___dump_triggers__act(Vor___024root* vlSelf);
#endif  // VL_DEBUG

void Vor___024root___eval_triggers__act(Vor___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vor__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vor___024root___eval_triggers__act\n"); );
    // Body
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vor___024root___dump_triggers__act(vlSelf);
    }
#endif
}
