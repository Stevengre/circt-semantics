// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfrom_clock.h for the primary calling header

#include "Vfrom_clock__pch.h"
#include "Vfrom_clock__Syms.h"
#include "Vfrom_clock___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfrom_clock___024root___dump_triggers__ico(Vfrom_clock___024root* vlSelf);
#endif  // VL_DEBUG

void Vfrom_clock___024root___eval_triggers__ico(Vfrom_clock___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfrom_clock__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfrom_clock___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfrom_clock___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfrom_clock___024root___dump_triggers__act(Vfrom_clock___024root* vlSelf);
#endif  // VL_DEBUG

void Vfrom_clock___024root___eval_triggers__act(Vfrom_clock___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfrom_clock__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfrom_clock___024root___eval_triggers__act\n"); );
    // Body
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfrom_clock___024root___dump_triggers__act(vlSelf);
    }
#endif
}
