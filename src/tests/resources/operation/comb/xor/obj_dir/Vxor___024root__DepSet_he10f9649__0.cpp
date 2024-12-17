// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vxor.h for the primary calling header

#include "Vxor__pch.h"
#include "Vxor__Syms.h"
#include "Vxor___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vxor___024root___dump_triggers__ico(Vxor___024root* vlSelf);
#endif  // VL_DEBUG

void Vxor___024root___eval_triggers__ico(Vxor___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vxor__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vxor___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vxor___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vxor___024root___dump_triggers__act(Vxor___024root* vlSelf);
#endif  // VL_DEBUG

void Vxor___024root___eval_triggers__act(Vxor___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vxor__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vxor___024root___eval_triggers__act\n"); );
    // Body
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vxor___024root___dump_triggers__act(vlSelf);
    }
#endif
}
