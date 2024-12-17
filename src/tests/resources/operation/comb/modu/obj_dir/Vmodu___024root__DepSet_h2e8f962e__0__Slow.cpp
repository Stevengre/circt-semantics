// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmodu.h for the primary calling header

#include "Vmodu__pch.h"
#include "Vmodu__Syms.h"
#include "Vmodu___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vmodu___024root___dump_triggers__stl(Vmodu___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vmodu___024root___eval_triggers__stl(Vmodu___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vmodu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmodu___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vmodu___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
